/**
 * cockpit.js — PMO Cockpit Frontend Orchestrator
 * Premium Indra DSS edition: Mission Control hero + animated KPIs +
 * geodesic sphere canvas + scroll reveals + audio cues.
 */

const Cockpit = (() => {
  const config = {
    apiBase: 'http://127.0.0.1:7777/api',
    refreshMs: 5000
  };

  const state = {
    snapshot: null,
    lastUpdate: null,
    pollInterval: null,
    revealObserver: null,
    canvasInitialized: false,
    kpiAnimated: {}, // tracks animated values to avoid re-running counter on every poll
    isSnapshotMode: false,
    snapshotFilename: null,
    isOffline: false
  };

  /* =====================================================================
     AUDIO ENGINE — synthesized cues (Web Audio)
     ===================================================================== */
  const AudioEngine = (() => {
    let ctx;
    function getCtx() {
      if (!ctx) ctx = new (window.AudioContext || window.webkitAudioContext)();
      if (ctx.state === 'suspended') ctx.resume();
      return ctx;
    }
    function tone(freq, type, dur, vol = 0.08) {
      try {
        const c = getCtx();
        const o = c.createOscillator();
        const g = c.createGain();
        o.type = type;
        o.frequency.setValueAtTime(freq, c.currentTime);
        g.gain.setValueAtTime(vol, c.currentTime);
        g.gain.exponentialRampToValueAtTime(0.001, c.currentTime + dur);
        o.connect(g); g.connect(c.destination);
        o.start();
        o.stop(c.currentTime + dur);
      } catch (e) {}
    }
    return {
      click:   () => tone(900, 'sine', 0.08, 0.04),
      ding:    () => { tone(1200, 'sine', 0.10); setTimeout(() => tone(1600, 'sine', 0.18), 90); },
      alarm:   () => { tone(420, 'square', 0.18); setTimeout(() => tone(420, 'square', 0.18), 220); },
      fanfare: () => { tone(523, 'triangle', 0.10); setTimeout(() => tone(659, 'triangle', 0.10), 100); setTimeout(() => tone(784, 'triangle', 0.20), 200); }
    };
  })();

  /* =====================================================================
     INIT
     ===================================================================== */
  function init() {
    bindEvents();
    bindHashNavigation();
    initTheme();
    initRevealObserver();
    startPolling();
    refresh(true); // initial silent refresh
  }

  function bindEvents() {
    document.getElementById('btnRefreshCockpit')?.addEventListener('click', () => {
      refresh(false);
      AudioEngine.click();
    });
    document.getElementById('btnExportSnapshot')?.addEventListener('click', exportSnapshot);
    document.getElementById('themeToggle')?.addEventListener('click', toggleTheme);
    document.getElementById('sidebarToggle')?.addEventListener('click', toggleSidebar);

    // Load snapshot from file
    const btnLoad = document.getElementById('btnLoadSnapshot');
    const fileInput = document.getElementById('snapshotFileInput');
    btnLoad?.addEventListener('click', () => fileInput?.click());
    fileInput?.addEventListener('change', handleSnapshotFile);
    document.getElementById('btnReturnToLive')?.addEventListener('click', returnToLive);
    document.getElementById('agentFilterStatus')?.addEventListener('change', renderAgentRoster);
    document.getElementById('agentSearch')?.addEventListener('input', renderAgentRoster);
    document.getElementById('activityFilterOp')?.addEventListener('change', renderActivityFeed);

    document.querySelectorAll('#cockpitNav .nav-item').forEach(el => {
      el.addEventListener('click', (e) => {
        e.preventDefault();
        const view = el.dataset.view;
        if (view) window.location.hash = '#' + view;
      });
      el.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          const view = el.dataset.view;
          if (view) window.location.hash = '#' + view;
        }
      });
    });
  }

  /* =====================================================================
     THEME (dark / light) — persisted to localStorage; auto-detect on first visit
     ===================================================================== */
  function initTheme() {
    const stored = localStorage.getItem('cockpit_theme');
    let theme;
    if (stored === 'light' || stored === 'dark') {
      theme = stored;
    } else if (window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches) {
      theme = 'light';
    } else {
      theme = 'dark';
    }
    document.documentElement.setAttribute('data-theme', theme);
  }

  function toggleTheme() {
    const cur = document.documentElement.getAttribute('data-theme') || 'dark';
    const next = cur === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('cockpit_theme', next);
    AudioEngine.click();
    showToast(`Switched to ${next} theme`, 'success');
  }

  function toggleSidebar() {
    document.getElementById('appSidebar')?.classList.toggle('is-collapsed');
    AudioEngine.click();
    // Force canvas resize after sidebar transition
    setTimeout(() => window.dispatchEvent(new Event('resize')), 300);
  }

  /* Reduced motion preference */
  function prefersReducedMotion() {
    return window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  }

  function bindHashNavigation() {
    window.addEventListener('hashchange', handleHashChange);
    if (!window.location.hash) {
      window.location.hash = '#dispatch';
    } else {
      handleHashChange();
    }
  }

  function handleHashChange() {
    const hash = window.location.hash.replace('#', '') || 'dispatch';
    navigateTo(hash);
  }

  function navigateTo(viewId) {
    document.querySelectorAll('#cockpitNav .nav-item').forEach(el => {
      el.classList.toggle('active', el.dataset.view === viewId);
    });
    document.querySelectorAll('.cockpit-view').forEach(el => el.classList.add('view-hidden'));
    const target = document.getElementById('view' + viewId.charAt(0).toUpperCase() + viewId.slice(1));
    if (target) target.classList.remove('view-hidden');
    renderCurrentView();
  }

  function startPolling() {
    if (state.pollInterval) clearInterval(state.pollInterval);
    state.pollInterval = setInterval(() => {
      if (state.isSnapshotMode) return; // freeze polling while viewing uploaded file
      refresh(true);
    }, config.refreshMs);
  }

  /* =====================================================================
     SNAPSHOT FILE LOADER (offline / point-in-time view)
     ===================================================================== */
  function handleSnapshotFile(e) {
    const file = e.target.files && e.target.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = (ev) => {
      try {
        const data = JSON.parse(ev.target.result);
        if (!data || !Array.isArray(data.fleet) || !data.fleet_kpis) {
          throw new Error('Invalid snapshot format — expected JSON exported by this cockpit (must contain `fleet` array and `fleet_kpis` object)');
        }
        enterSnapshotMode(data, file.name);
      } catch (err) {
        showToast('Load failed: ' + err.message, 'error');
      } finally {
        // Reset input so same file can be selected again
        e.target.value = '';
      }
    };
    reader.onerror = () => showToast('Could not read file', 'error');
    reader.readAsText(file);
  }

  function enterSnapshotMode(data, filename) {
    state.snapshot = data;
    state.isSnapshotMode = true;
    state.snapshotFilename = filename;
    state.lastUpdate = data.snapshot_time ? new Date(data.snapshot_time) : new Date();
    state.kpiAnimated = {}; // re-animate counters for new data

    document.querySelector('.app-shell')?.classList.add('is-snapshot-mode');
    const banner = document.getElementById('snapshotBanner');
    if (banner) banner.hidden = false;
    const fileEl = document.getElementById('snapshotBannerFile');
    if (fileEl) fileEl.textContent = filename;
    const timeEl = document.getElementById('snapshotBannerTime');
    if (timeEl) {
      const t = state.lastUpdate;
      timeEl.textContent = 'Snapshot time: ' + (isNaN(t.getTime()) ? 'unknown' : t.toLocaleString());
    }
    // Update topbar mode badge
    const modeBadge = document.getElementById('modeBadge');
    if (modeBadge) {
      modeBadge.textContent = 'SNAPSHOT';
      modeBadge.style.background = 'rgba(255, 193, 7, 0.18)';
      modeBadge.style.borderColor = 'rgba(255, 193, 7, 0.6)';
      modeBadge.style.color = 'var(--indra-gold)';
    }

    updateLastUpdateUI();
    renderCurrentView();
    AudioEngine.ding();
    showToast(`Loaded: ${filename}`, 'success');
  }

  function returnToLive() {
    state.isSnapshotMode = false;
    state.snapshotFilename = null;
    state.kpiAnimated = {};
    document.querySelector('.app-shell')?.classList.remove('is-snapshot-mode');
    const banner = document.getElementById('snapshotBanner');
    if (banner) banner.hidden = true;
    const modeBadge = document.getElementById('modeBadge');
    if (modeBadge) {
      modeBadge.textContent = 'LIVE';
      modeBadge.style.background = '';
      modeBadge.style.borderColor = '';
      modeBadge.style.color = '';
    }
    AudioEngine.click();
    showToast('Returned to live mode', 'success');
    refresh(false);
  }

  async function refresh(silent) {
    if (state.isSnapshotMode) {
      // Don't fetch over the user's loaded file
      if (!silent) {
        renderCurrentView();
        showToast('Snapshot mode active — click "Return to Live" to resume polling', 'error');
      }
      return;
    }
    const btn = document.getElementById('btnRefreshCockpit');
    const banner = document.getElementById('connectionBanner');
    const shell = document.querySelector('.app-shell');
    const startedAt = performance.now();
    if (!silent && btn) btn.classList.add('is-loading');
    try {
      const res = await fetch(`${config.apiBase}/cockpit/snapshot`);
      if (!res.ok) throw new Error('HTTP ' + res.status);
      state.snapshot = await res.json();
      state.lastUpdate = new Date();
      state.isOffline = false;
      banner?.classList.remove('is-visible');
      shell?.classList.remove('is-offline');
      updateLastUpdateUI();
      renderCurrentView();
      if (!silent) {
        // Min-duration so spinner is perceivable on local server
        const elapsed = performance.now() - startedAt;
        await new Promise(r => setTimeout(r, Math.max(0, 350 - elapsed)));
        showToast('Snapshot refreshed', 'success');
      }
    } catch (e) {
      console.warn('Snapshot fetch failed:', e);
      state.isOffline = true;
      const el = document.getElementById('lastUpdateTimestamp');
      if (el) el.textContent = 'Connection lost — retrying…';
      banner?.classList.add('is-visible');
      shell?.classList.add('is-offline');
      if (!silent) showToast('Refresh failed: ' + e.message, 'error');
    } finally {
      if (btn) setTimeout(() => btn.classList.remove('is-loading'), 400);
    }
  }

  function updateLastUpdateUI() {
    if (!state.lastUpdate) return;
    const el = document.getElementById('lastUpdateTimestamp');
    if (el) el.textContent = 'Last update: ' + state.lastUpdate.toLocaleTimeString();
  }

  function renderCurrentView() {
    if (!state.snapshot) return;
    const view = window.location.hash.replace('#', '') || 'dispatch';
    if (view === 'dispatch') {
      renderMissionHero();
      renderDispatchConsole();
      bindReveals();
    }
    else if (view === 'dashboard') renderDashboard();
    else if (view === 'agents') renderAgentRoster();
    else if (view === 'activity') renderActivityFeed();
    else if (view === 'phases') renderPhaseTracker();
    else if (view === 'handoffs') renderHandoffs();
    else if (view === 'prompts') renderPromptsList();
  }

  /* =====================================================================
     MISSION HERO — animated KPI cluster + progress bar
     ===================================================================== */
  function renderMissionHero() {
    const grid = document.getElementById('missionKpiGrid');
    if (!grid) return;
    const k = state.snapshot.fleet_kpis || {};
    const total = k.total || 0;
    const doneAll = (k.done || 0) + (k.ready_for_review || 0);
    const completion = total ? Math.round((doneAll / total) * 100) : 0;

    const kpis = [
      { label: 'Fleet',        value: total,            cls: 'is-pending' },
      { label: 'In Progress',  value: k.in_progress || 0, cls: 'is-progress' },
      { label: 'Done',         value: doneAll,          cls: 'is-done' },
      { label: 'Blocked',      value: k.blocked || 0,   cls: 'is-blocked' },
      { label: 'Needs Rerun',  value: k.needs_rerun || 0, cls: 'is-rerun' },
      { label: 'Completion',   value: completion,       cls: 'is-completion', suffix: '%' }
    ];

    grid.innerHTML = kpis.map(kpi => `
      <div class="mission-kpi ${kpi.cls}">
        <div class="mission-kpi-label">${kpi.label}</div>
        <div class="mission-kpi-value" data-target="${kpi.value}" data-suffix="${kpi.suffix || ''}">0${kpi.suffix || ''}</div>
      </div>
    `).join('');

    // Animate counters (only first time the value changes)
    grid.querySelectorAll('.mission-kpi-value').forEach((el, i) => {
      const target = parseInt(el.dataset.target);
      const suffix = el.dataset.suffix || '';
      const key = kpis[i].label;
      if (state.kpiAnimated[key] === target) {
        el.textContent = target + suffix;
        return;
      }
      state.kpiAnimated[key] = target;
      animateCount(el, target, suffix, 1200);
    });

    // Progress bar
    const fill = document.getElementById('missionProgressFill');
    if (fill) fill.style.width = completion + '%';

    // Phase label
    const phaseLbl = document.getElementById('missionPhaseLabel');
    if (phaseLbl && state.snapshot.kpis) {
      phaseLbl.textContent = (state.snapshot.kpis.current_phase || 1) + ' / 9';
    }
  }

  function animateCount(el, target, suffix, duration) {
    if (prefersReducedMotion()) {
      el.textContent = target.toLocaleString() + suffix;
      return;
    }
    const start = performance.now();
    function step(now) {
      const t = Math.min((now - start) / duration, 1);
      const eased = 1 - Math.pow(1 - t, 3);
      const v = Math.round(target * eased);
      el.textContent = v.toLocaleString() + suffix;
      if (t < 1) requestAnimationFrame(step);
    }
    requestAnimationFrame(step);
  }

  /* =====================================================================
     HERO CANVAS — geodesic sphere (Canvas 2D)
     ===================================================================== */
  function initHeroCanvas() {
    if (state.canvasInitialized) return;
    if (prefersReducedMotion()) return; // honor user preference
    const canvas = document.getElementById('missionHeroCanvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    state.canvasInitialized = true;

    function resize() {
      const r = canvas.parentElement.getBoundingClientRect();
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      canvas.width = r.width * dpr;
      canvas.height = r.height * dpr;
      canvas.style.width = r.width + 'px';
      canvas.style.height = r.height + 'px';
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    }
    resize();
    window.addEventListener('resize', resize);

    // Build icosahedron
    const phi = (1 + Math.sqrt(5)) / 2;
    const verts = [
      [-1, phi, 0], [1, phi, 0], [-1, -phi, 0], [1, -phi, 0],
      [0, -1, phi], [0, 1, phi], [0, -1, -phi], [0, 1, -phi],
      [phi, 0, -1], [phi, 0, 1], [-phi, 0, -1], [-phi, 0, 1]
    ].map(v => { const l = Math.hypot(...v); return v.map(x => x / l); });

    let faces = [
      [0,11,5],[0,5,1],[0,1,7],[0,7,10],[0,10,11],
      [1,5,9],[5,11,4],[11,10,2],[10,7,6],[7,1,8],
      [3,9,4],[3,4,2],[3,2,6],[3,6,8],[3,8,9],
      [4,9,5],[2,4,11],[6,2,10],[8,6,7],[9,8,1]
    ];

    const cache = {};
    function midIdx(a, b) {
      const k = Math.min(a, b) + '-' + Math.max(a, b);
      if (cache[k] !== undefined) return cache[k];
      const m = [(verts[a][0] + verts[b][0]) / 2, (verts[a][1] + verts[b][1]) / 2, (verts[a][2] + verts[b][2]) / 2];
      const l = Math.hypot(...m);
      verts.push([m[0] / l, m[1] / l, m[2] / l]);
      cache[k] = verts.length - 1;
      return cache[k];
    }
    for (let s = 0; s < 2; s++) {
      const nf = [];
      for (const [a, b, c] of faces) {
        const ab = midIdx(a, b), bc = midIdx(b, c), ca = midIdx(c, a);
        nf.push([a, ab, ca], [b, bc, ab], [c, ca, bc], [ab, bc, ca]);
      }
      faces = nf;
    }
    const edgeSet = new Set();
    const edges = [];
    for (const [a, b, c] of faces) {
      [[a, b], [b, c], [c, a]].forEach(([i, j]) => {
        const k = Math.min(i, j) + '-' + Math.max(i, j);
        if (!edgeSet.has(k)) { edgeSet.add(k); edges.push([i, j]); }
      });
    }

    // Pulse particles on edges
    const particles = Array.from({ length: 12 }, () => ({
      edge: Math.floor(Math.random() * edges.length),
      t: Math.random(),
      speed: 0.0015 + Math.random() * 0.0035,
      size: 1.5 + Math.random() * 2.5
    }));

    let rotX = 0, rotY = 0;
    let parallaxX = 0, parallaxY = 0;
    document.addEventListener('mousemove', (e) => {
      parallaxX = (e.clientX / window.innerWidth - 0.5) * 0.04;
      parallaxY = (e.clientY / window.innerHeight - 0.5) * 0.04;
    });

    function project(v) {
      let x = v[0] * Math.cos(rotY) + v[2] * Math.sin(rotY);
      let z = -v[0] * Math.sin(rotY) + v[2] * Math.cos(rotY);
      let y = v[1];
      const ny = y * Math.cos(rotX) - z * Math.sin(rotX);
      const nz = y * Math.sin(rotX) + z * Math.cos(rotX);
      y = ny; z = nz;
      x += parallaxX; y += parallaxY;
      const cw = canvas.clientWidth, ch = canvas.clientHeight;
      const scale = Math.min(cw, ch) * 0.34;
      const persp = 4 / (4 + z);
      return [cw * 0.72 + x * scale * persp, ch * 0.5 - y * scale * persp, z];
    }

    function frame() {
      const cw = canvas.clientWidth, ch = canvas.clientHeight;
      ctx.clearRect(0, 0, cw, ch);
      rotY += 0.0009;
      rotX += 0.00025;

      // Edges
      for (const [i, j] of edges) {
        const p1 = project(verts[i]);
        const p2 = project(verts[j]);
        const avgZ = (p1[2] + p2[2]) / 2;
        const a = Math.max(0.04, 0.10 + (1 + avgZ) * 0.14);
        ctx.beginPath();
        ctx.moveTo(p1[0], p1[1]);
        ctx.lineTo(p2[0], p2[1]);
        ctx.strokeStyle = `rgba(0, 176, 189, ${a})`;
        ctx.lineWidth = 0.55;
        ctx.stroke();
      }

      // Vertices
      for (const v of verts) {
        const [x, y, z] = project(v);
        const a = Math.max(0.06, 0.12 + (1 + z) * 0.22);
        const s = 1 + (1 + z) * 0.5;
        ctx.beginPath();
        ctx.arc(x, y, s, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(63, 150, 174, ${a})`;
        ctx.fill();
      }

      // Particles travelling along edges
      for (const p of particles) {
        p.t += p.speed;
        if (p.t > 1) { p.t = 0; p.edge = Math.floor(Math.random() * edges.length); }
        const [i, j] = edges[p.edge];
        const v = [
          verts[i][0] + (verts[j][0] - verts[i][0]) * p.t,
          verts[i][1] + (verts[j][1] - verts[i][1]) * p.t,
          verts[i][2] + (verts[j][2] - verts[i][2]) * p.t
        ];
        const [x, y] = project(v);
        ctx.beginPath();
        ctx.arc(x, y, p.size, 0, Math.PI * 2);
        ctx.fillStyle = 'rgba(186, 223, 243, 0.78)';
        ctx.fill();
      }

      requestAnimationFrame(frame);
    }
    requestAnimationFrame(frame);
  }

  /* =====================================================================
     SCROLL REVEAL
     ===================================================================== */
  function initRevealObserver() {
    if (!('IntersectionObserver' in window)) return;
    state.revealObserver = new IntersectionObserver((entries) => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.classList.add('is-visible');
          state.revealObserver.unobserve(e.target);
        }
      });
    }, { threshold: 0.10, rootMargin: '0px 0px -40px 0px' });
    bindReveals();
  }

  function bindReveals() {
    if (!state.revealObserver) return;
    document.querySelectorAll('[data-reveal]:not(.is-visible)').forEach(el => state.revealObserver.observe(el));
  }

  /* =====================================================================
     DISPATCH CONSOLE
     ===================================================================== */
  function renderDispatchConsole() {
    const container = document.getElementById('dispatchContainer');
    if (!container) return;

    const fleet = (state.snapshot && state.snapshot.fleet) || [];
    const dispatchState = JSON.parse(localStorage.getItem('cockpit_dispatch_state') || '{}');

    if (fleet.length === 0) {
      container.innerHTML = '<div class="panel" style="padding: 32px; text-align: center; color: var(--text-muted);">No fleet data — verify ACTIVITY_LOG is reachable.</div>';
      return;
    }

    // Group by family preserving order
    const groups = {};
    fleet.forEach(a => { (groups[a.family] = groups[a.family] || []).push(a); });

    let html = '';
    let panelIdx = 2;
    Object.keys(groups).forEach(family => {
      html += `<section class="dispatch-family" data-reveal data-reveal-delay="${Math.min(panelIdx, 5)}">
                 <header class="dispatch-family-header">
                   <h3>${escapeHtml(family)}</h3>
                   <span class="dispatch-family-count">${groups[family].length} agents</span>
                 </header>
                 <div class="dispatch-table-wrap">
                 <table class="dispatch-table">
                   <thead>
                     <tr>
                       <th>#</th>
                       <th>Agent</th>
                       <th>Tracks</th>
                       <th>Status</th>
                       <th>Started</th>
                       <th>Finished</th>
                       <th>Duration</th>
                       <th>Last Seen</th>
                       <th>Errors</th>
                       <th>Action</th>
                     </tr>
                   </thead>
                   <tbody>`;

      groups[family].forEach(a => {
        const dispatched = !!(dispatchState[a.id] && dispatchState[a.id].timestamp);
        let effective = a.status;
        if (a.status === 'PENDING' && dispatched) effective = 'DISPATCHED';
        const badgeClass = 'status-' + effective.toLowerCase().replace(/_/g, '-');
        const rowCls = a.needs_rerun ? 'row-rerun' : '';

        html += `<tr class="${rowCls}" data-id="${escapeAttr(a.id)}">
                   <td class="dispatch-order">${String(a.order).padStart(2, '0')}</td>
                   <td class="dispatch-agent">
                     <div class="agent-id">${escapeHtml(a.id)}</div>
                     <div class="agent-model">${escapeHtml(a.model)}</div>
                   </td>
                   <td class="dispatch-tracks">${escapeHtml(a.tracks)}</td>
                   <td>
                     <span class="status-badge ${badgeClass}">${escapeHtml(effective.replace(/_/g, ' '))}</span>
                     ${a.needs_rerun ? `<span class="rerun-flag" title="${escapeAttr(a.rerun_reason || 'Rerun recommended')}">⟳ Rerun</span>` : ''}
                   </td>
                   <td class="dispatch-time">${formatTime(a.started_at)}</td>
                   <td class="dispatch-time">${formatTime(a.finished_at)}</td>
                   <td class="dispatch-duration">${formatDuration(a.duration_ms)}</td>
                   <td class="dispatch-time">${formatRelative(a.last_seen)}</td>
                   <td class="dispatch-errors">${
                     a.error_count > 0 ? `<span class="err-count">${a.error_count} ERR</span>` : ''
                   }${
                     a.warning_count > 0 ? `<span class="warn-count">${a.warning_count} WRN</span>` : ''
                   }${
                     a.error_count === 0 && a.warning_count === 0 ? '<span style="color:var(--text-faint)">—</span>' : ''
                   }</td>
                   <td class="dispatch-actions">
                     <button class="btn btn-xs btn-outline" onclick="Cockpit.copyPrompt('${escapeAttr(a.prompt_id)}')" title="Copy prompt to clipboard">Copy</button>
                     <button class="btn btn-xs ${dispatched ? 'btn-outline' : 'btn-cyan'}" onclick="Cockpit.toggleDispatch('${escapeAttr(a.id)}')">${dispatched ? 'Revoke' : 'Dispatch'}</button>
                   </td>
                 </tr>`;
      });

      html += `   </tbody>
                </table>
                </div>
              </section>`;
      panelIdx++;
    });

    container.innerHTML = html;

    const btnReset = document.getElementById('btnSequenceReset');
    if (btnReset) {
      btnReset.onclick = () => {
        if (confirm('Reset all local dispatch flags?')) {
          localStorage.removeItem('cockpit_dispatch_state');
          AudioEngine.alarm();
          renderDispatchConsole();
        }
      };
    }
  }

  function escapeAttr(s) {
    return String(s || '')
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }
  function escapeHtml(s) { return escapeAttr(s); }

  function formatTime(iso) {
    if (!iso) return '<span style="color:var(--text-faint)">—</span>';
    try {
      const d = new Date(iso);
      if (isNaN(d.getTime())) return iso;
      return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false });
    } catch (e) { return iso; }
  }

  function formatRelative(iso) {
    if (!iso) return '<span style="color:var(--text-faint)">—</span>';
    try {
      const d = new Date(iso);
      const ageS = Math.round((Date.now() - d.getTime()) / 1000);
      if (ageS < 60) return ageS + 's ago';
      if (ageS < 3600) return Math.floor(ageS / 60) + 'm ago';
      if (ageS < 86400) return Math.floor(ageS / 3600) + 'h ago';
      return Math.floor(ageS / 86400) + 'd ago';
    } catch (e) { return iso; }
  }

  function formatDuration(ms) {
    if (ms == null) return '<span style="color:var(--text-faint)">—</span>';
    const s = Math.round(ms / 1000);
    if (s < 60) return s + 's';
    const m = Math.floor(s / 60);
    if (m < 60) return m + 'm ' + (s % 60) + 's';
    const h = Math.floor(m / 60);
    return h + 'h ' + (m % 60) + 'm';
  }

  function toggleDispatch(agentId) {
    const ds = JSON.parse(localStorage.getItem('cockpit_dispatch_state') || '{}');
    const action = ds[agentId] ? 'Revoke dispatch flag for' : 'Dispatch';
    if (!confirm(`${action} ${agentId}?`)) return;
    if (ds[agentId]) { delete ds[agentId]; AudioEngine.click(); showToast('Dispatch flag revoked: ' + agentId); }
    else { ds[agentId] = { timestamp: Date.now() }; AudioEngine.ding(); showToast('Dispatched: ' + agentId, 'success'); }
    localStorage.setItem('cockpit_dispatch_state', JSON.stringify(ds));
    renderDispatchConsole();
  }

  async function copyPrompt(promptId) {
    try {
      const res = await fetch(`${config.apiBase}/prompts/${promptId}/content`);
      if (!res.ok) throw new Error('HTTP ' + res.status);
      const data = await res.json();
      await navigator.clipboard.writeText(data.content);
      AudioEngine.ding();
      showToast(`Prompt copied (${data.size_bytes.toLocaleString()} bytes)`, 'success');
    } catch (e) {
      showToast('Copy failed: ' + e.message, 'error');
    }
  }

  /* =====================================================================
     DASHBOARD / ROSTER / ACTIVITY / PHASES (kept compatible)
     ===================================================================== */
  function renderDashboard() {
    const k = state.snapshot.kpis || {};
    const row = document.getElementById('cockpitKpis');
    if (!row) return;
    row.innerHTML = `
      <div class="kpi-card" tabindex="0" role="button" onclick="window.location.hash='#agents'" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();window.location.hash='#agents'}">
        <div class="kpi-title">Active Agents</div>
        <div class="kpi-value" style="--kpi-color: var(--indra-cyan)">${k.active_agents || 0}<span style="font-size:18px;color:var(--text-faint)"> / ${k.total_agents || 0}</span></div>
      </div>
      <div class="kpi-card" tabindex="0" role="button" onclick="window.location.hash='#activity'" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();window.location.hash='#activity'}">
        <div class="kpi-title">Tasks Done</div>
        <div class="kpi-value" style="--kpi-color: var(--indra-success)">${k.tasks_done_current_phase || 0}</div>
      </div>
      <div class="kpi-card">
        <div class="kpi-title">Tasks Blocked</div>
        <div class="kpi-value" style="--kpi-color: var(--indra-warning)">${k.tasks_blocked || 0}</div>
      </div>
      <div class="kpi-card" tabindex="0" role="button" onclick="window.location.hash='#phases'" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();window.location.hash='#phases'}">
        <div class="kpi-title">Current Phase</div>
        <div class="kpi-value" style="--kpi-color: var(--indra-cyan)">P${k.current_phase || 1}</div>
      </div>
    `;

    const feed = document.getElementById('dashActivityFeed');
    if (feed) {
      feed.innerHTML = (state.snapshot.recent_activity || []).slice(0, 10).map(activityHtml).join('')
        || '<li class="activity-empty">No activity yet.</li>';
    }
    const strip = document.getElementById('dashAgentStrip');
    if (strip) {
      strip.innerHTML = (state.snapshot.fleet || []).map(a => {
        const hb = a.status === 'IN_PROGRESS' ? 'alive'
                : a.status === 'STALE' ? 'stale'
                : a.status === 'DEAD' ? 'dead'
                : (a.status === 'DONE' || a.status === 'READY_FOR_REVIEW') ? 'done'
                : 'idle';
        return `<div class="strip-item" tabindex="0" role="button" onclick="window.location.hash='#agents'" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();window.location.hash='#agents'}"><span class="heartbeat-dot ${hb}"></span>${escapeHtml(a.id)}</div>`;
      }).join('');
    }
  }

  const OP_LABEL = { HEARTBEAT:'Heartbeat', CHECKIN:'Check-in', CHECKOUT:'Check-out',
                     HANDOFF:'Handoff', LOCK:'Locked', UNLOCK:'Unlocked',
                     ERROR:'Error', WARNING:'Warning' };
  function opLabel(op){ return OP_LABEL[op] || (op ? op.charAt(0)+op.slice(1).toLowerCase() : 'Event'); }

  function activityHtml(act) {
    const time = act.timestamp ? new Date(act.timestamp).toLocaleTimeString([], { hour12: false }) : '--:--';
    const op = (act.operation || 'EVT').toLowerCase();
    const fieldsStr = (act.fields && Object.keys(act.fields).length)
      ? '· ' + Object.entries(act.fields).slice(0, 3).map(([k, v]) => k + ': ' + v).join(' · ')
      : '';
    return `
      <li class="activity-item">
        <div class="activity-time">${escapeHtml(time)}</div>
        <div class="activity-op op-${escapeAttr(op)}">${escapeHtml(opLabel(act.operation))}</div>
        <div class="activity-agent">${escapeHtml(act.agent_id || '')}</div>
        <div class="activity-details">${escapeHtml(act.task_id || '')} ${escapeHtml(fieldsStr)}</div>
      </li>
    `;
  }

  function renderActivityFeed() {
    const feed = document.getElementById('fullActivityFeed');
    if (!feed) return;
    const filter = document.getElementById('activityFilterOp')?.value || 'all';
    let items = state.snapshot.recent_activity || [];
    if (filter !== 'all') {
      if (filter === 'LOCK') items = items.filter(a => a.operation === 'LOCK' || a.operation === 'UNLOCK');
      else items = items.filter(a => a.operation === filter);
    }
    feed.innerHTML = items.map(activityHtml).join('') || '<li class="activity-empty">No activity matches filter.</li>';
  }

  function renderAgentRoster() {
    const grid = document.getElementById('agentRosterGrid');
    if (!grid) return;
    const filterStatus = document.getElementById('agentFilterStatus')?.value || 'all';
    const filterText = (document.getElementById('agentSearch')?.value || '').toLowerCase();

    let agents = state.snapshot.fleet || [];
    if (filterStatus !== 'all') agents = agents.filter(a => (a.status || '').toLowerCase() === filterStatus);
    if (filterText) agents = agents.filter(a =>
      a.id.toLowerCase().includes(filterText) ||
      (a.tracks || '').toLowerCase().includes(filterText)
    );

    grid.innerHTML = agents.map(a => {
      const hb = a.status === 'IN_PROGRESS' ? 'alive'
              : a.status === 'STALE' ? 'stale'
              : a.status === 'DEAD' ? 'dead'
              : (a.status === 'DONE' || a.status === 'READY_FOR_REVIEW') ? 'done'
              : 'idle';
      const badgeCls = 'status-' + a.status.toLowerCase().replace(/_/g, '-');
      return `
        <div class="agent-card">
          <div class="agent-card-header">
            <span class="agent-card-title">${escapeHtml(a.id)}</span>
            <span class="status-badge ${badgeCls}">${escapeHtml(a.status.replace(/_/g, ' '))}</span>
          </div>
          <div class="agent-card-body">
            <p><span class="heartbeat-dot ${hb}"></span> ${escapeHtml(a.family)} · ${escapeHtml(a.model)}</p>
            <p>Tracks: <span class="val">${escapeHtml(a.tracks)}</span></p>
            <p>Started: <span class="val">${formatTime(a.started_at).replace(/<[^>]+>/g, '') || '—'}</span></p>
            <p>Finished: <span class="val">${formatTime(a.finished_at).replace(/<[^>]+>/g, '') || '—'}</span></p>
          </div>
          <div class="agent-card-footer">
            <button class="btn-link" onclick="Cockpit.copyPrompt('${escapeAttr(a.prompt_id)}')">Copy prompt →</button>
          </div>
        </div>
      `;
    }).join('') || '<div style="grid-column:1/-1;text-align:center;padding:48px;color:var(--text-muted)">No agents match filter.</div>';
  }

  function renderPhaseTracker() {
    const stepper = document.getElementById('phaseStepper');
    if (!stepper) return;
    const phases = (state.snapshot.phase_state && state.snapshot.phase_state.phases) || [];
    if (phases.length === 0) {
      stepper.innerHTML = '<div style="grid-column:1/-1;padding:32px;text-align:center;color:var(--text-muted);">No phase data available.</div>';
      return;
    }
    stepper.innerHTML = phases.map((p, idx) => {
      const cls = (p.status || 'waiting').toLowerCase();
      return `
        <div class="phase-step ${cls}" tabindex="0" role="button" onclick="Cockpit.showPhaseDetail(${idx})" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();Cockpit.showPhaseDetail(${idx})}">
          <div class="phase-label">${escapeHtml(String(p.phase))}</div>
          <div class="phase-status">${escapeHtml(p.status || 'WAITING')}</div>
        </div>
      `;
    }).join('');
  }

  function showPhaseDetail(idx) {
    const p = state.snapshot.phase_state.phases[idx];
    const el = document.getElementById('phaseDetail');
    if (!p || !el) return;
    el.innerHTML = `
      <h3 style="font-size:14px;font-weight:600;color:var(--text-primary);margin-bottom:8px;">Phase ${escapeHtml(String(p.phase))} · ${escapeHtml(p.status)}</h3>
      <p style="font-size:12px;color:var(--text-muted);margin-bottom:6px;font-family:var(--font-mono);">Active agents: ${escapeHtml(p.active_agents || '—')}</p>
      <p style="font-size:12px;color:var(--text-muted);font-family:var(--font-mono);">Started: ${escapeHtml(p.started || '—')}</p>
    `;
  }

  /* =====================================================================
     HANDOFFS — list view of agent-to-agent transfers
     ===================================================================== */
  async function renderHandoffs() {
    const root = document.getElementById('handoffGraph');
    if (!root) return;
    root.innerHTML = '<div style="padding:48px;text-align:center;color:var(--text-muted);">Loading handoffs…</div>';
    try {
      const res = await fetch(`${config.apiBase}/handoffs`);
      if (!res.ok) throw new Error('HTTP ' + res.status);
      const data = await res.json();
      const handoffs = (data.handoff_history || []).filter(h => h.timestamp);
      // Sort newest first
      handoffs.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));

      const stats = {
        total: handoffs.length,
        phaseTransitions: handoffs.filter(h => h.type === 'PHASE_HANDOFF').length,
        uniqueFrom: new Set(handoffs.map(h => extractField(h.meta, 'from'))).size,
        uniqueTo: new Set(handoffs.map(h => extractField(h.meta, 'to'))).size
      };

      root.innerHTML = `
        <div style="padding: var(--s-6);">
          <div class="handoff-summary">
            <div class="handoff-stat">
              <div class="handoff-stat-label">Total Handoffs</div>
              <div class="handoff-stat-value">${stats.total}</div>
            </div>
            <div class="handoff-stat">
              <div class="handoff-stat-label">Phase Transitions</div>
              <div class="handoff-stat-value">${stats.phaseTransitions}</div>
            </div>
            <div class="handoff-stat">
              <div class="handoff-stat-label">Sender Agents</div>
              <div class="handoff-stat-value">${stats.uniqueFrom}</div>
            </div>
            <div class="handoff-stat">
              <div class="handoff-stat-label">Receiver Agents</div>
              <div class="handoff-stat-value">${stats.uniqueTo}</div>
            </div>
          </div>
          ${handoffs.length === 0 ? '<div class="activity-empty">No handoffs recorded yet.</div>' : `
            <ul class="handoff-list">
              ${handoffs.map(h => {
                const from = extractField(h.meta, 'from') || '—';
                const to   = extractField(h.meta, 'to') || '—';
                const taskCompleted = (h.details || []).find(l => l.startsWith('task_completed:'))?.replace('task_completed:', '').trim() || '';
                const t = h.timestamp ? new Date(h.timestamp).toLocaleTimeString([], { hour12: false }) : '--';
                return `
                  <li class="handoff-item">
                    <div class="handoff-time">${t}</div>
                    <div class="handoff-from">${escapeHtml(from)}</div>
                    <div class="handoff-arrow">→</div>
                    <div class="handoff-to">${escapeHtml(to)}</div>
                    <div class="handoff-meta">${escapeHtml(taskCompleted)}</div>
                  </li>
                `;
              }).join('')}
            </ul>
          `}
        </div>
      `;
    } catch (e) {
      root.innerHTML = `<div style="padding:48px;text-align:center;color:var(--indra-error);">Failed to load handoffs: ${escapeHtml(e.message)}</div>`;
    }
  }

  function extractField(meta, key) {
    if (!meta) return '';
    const re = new RegExp(`${key}:\\s*([^|]+)`);
    const m = meta.match(re);
    return m ? m[1].trim() : '';
  }

  /* =====================================================================
     PROMPTS LIST
     ===================================================================== */
  async function renderPromptsList() {
    const root = document.getElementById('promptList');
    if (!root) return;
    root.innerHTML = '<p style="color:var(--text-muted);">Loading prompts…</p>';
    try {
      const res = await fetch(`${config.apiBase}/prompts/list`);
      if (!res.ok) throw new Error('HTTP ' + res.status);
      const data = await res.json();
      const fleet = (state.snapshot && state.snapshot.fleet) || [];
      const promptToAgent = {};
      fleet.forEach(a => { promptToAgent[a.prompt_id] = a; });

      root.innerHTML = `
        <div class="agent-grid">
          ${data.prompts.map(p => {
            const agent = promptToAgent[p.id];
            return `
              <div class="agent-card">
                <div class="agent-card-header">
                  <span class="agent-card-title">${escapeHtml(p.id)}</span>
                  ${agent ? `<span class="status-badge status-${agent.status.toLowerCase().replace(/_/g,'-')}">${escapeHtml(agent.status.replace(/_/g,' '))}</span>` : ''}
                </div>
                <div class="agent-card-body">
                  <p>${agent ? escapeHtml(agent.id + ' · ' + agent.tracks) : escapeHtml(p.filename)}</p>
                  <p>Size: <span class="val">${(p.size_bytes / 1024).toFixed(1)} KB</span></p>
                  <p>Modified: <span class="val">${escapeHtml(new Date(p.last_modified).toLocaleString())}</span></p>
                </div>
                <div class="agent-card-footer" style="display:flex;gap:8px;">
                  <button class="btn btn-xs btn-cyan" onclick="Cockpit.copyPrompt('${escapeAttr(p.id)}')">Copy</button>
                </div>
              </div>
            `;
          }).join('')}
        </div>
      `;
    } catch (e) {
      root.innerHTML = `<p style="color:var(--indra-error);">Failed to load: ${escapeHtml(e.message)}</p>`;
    }
  }

  /* =====================================================================
     EXPORT + TOAST
     ===================================================================== */
  function exportSnapshot() {
    if (!state.snapshot) return;
    const blob = new Blob([JSON.stringify(state.snapshot, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'cockpit_snapshot_' + Date.now() + '.json';
    document.body.appendChild(a); a.click(); document.body.removeChild(a);
    URL.revokeObjectURL(url);
    AudioEngine.fanfare();
    showToast('Snapshot exported', 'success');
  }

  function showToast(msg, type) {
    const c = document.getElementById('toastContainer');
    if (!c) return;
    const el = document.createElement('div');
    el.className = 'toast' + (type ? ' toast-' + type : '');
    el.textContent = msg;
    c.appendChild(el);
    setTimeout(() => {
      el.style.transition = 'opacity 250ms, transform 250ms';
      el.style.opacity = '0';
      el.style.transform = 'translateX(20px)';
      setTimeout(() => el.remove(), 280);
    }, 2800);
  }

  return { init, showPhaseDetail, toggleDispatch, copyPrompt };
})();

document.addEventListener('DOMContentLoaded', Cockpit.init);
