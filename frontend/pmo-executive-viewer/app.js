/* =============================================
   PMO Executive Viewer — App Script
   Built on DSS Universal Standard v3.0
   - Hero: Canvas 2D Geodesic Sphere
   - IntersectionObserver scroll reveals
   - Markdown → DSS-compliant dashboard renderer
   ============================================= */

(function () {
  'use strict';

  const $ = id => document.getElementById(id);
  const fileInput   = $('fileInput'),
        heroSection = $('heroSection'),
        dashboard   = $('dashboard'),
        dropZone    = $('dropZone'),
        btnDemo     = $('btnDemo'),
        sidebarNav  = $('dynamicNav'),
        sidebarGate = $('sidebarGate'),
        topbarTitle   = $('topbarTitle'),
        topbarEyebrow = $('topbarEyebrow'),
        topbarDate    = $('topbarDate'),
        topbarEnv     = $('topbarEnv'),
        topbarGate    = $('topbarGate'),
        kpiRow        = $('kpiRow'),
        dynSections   = $('dynamicSections'),
        footerTs      = $('footerTs'),
        btnNavHome    = $('btnNavHome'),
        heroCanvas    = $('heroCanvas');

  /* ════════════════════════════════════════
     SCROLL REVEAL — DSS [data-animate]
     ════════════════════════════════════════ */
  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('animate-in');
        revealObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });

  function observeAnimated(root = document) {
    root.querySelectorAll('[data-animate]:not(.animate-in)').forEach(el => revealObserver.observe(el));
  }
  observeAnimated();

  /* ════════════════════════════════════════
     HERO GEODESIC SPHERE — DSS Canvas 2D
     ════════════════════════════════════════ */
  if (heroCanvas) {
    const ctx = heroCanvas.getContext('2d');

    function resizeHero() {
      const parent = heroCanvas.parentElement;
      heroCanvas.width  = parent.offsetWidth;
      heroCanvas.height = parent.offsetHeight;
    }
    resizeHero();
    window.addEventListener('resize', resizeHero);

    // Icosahedron base
    const phi = (1 + Math.sqrt(5)) / 2;
    const icoVertices = [
      [-1, phi, 0], [1, phi, 0], [-1, -phi, 0], [1, -phi, 0],
      [0, -1, phi], [0, 1, phi], [0, -1, -phi], [0, 1, -phi],
      [phi, 0, -1], [phi, 0, 1], [-phi, 0, -1], [-phi, 0, 1]
    ].map(v => {
      const l = Math.sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
      return [v[0]/l, v[1]/l, v[2]/l];
    });

    const icoFaces = [
      [0,11,5],[0,5,1],[0,1,7],[0,7,10],[0,10,11],
      [1,5,9],[5,11,4],[11,10,2],[10,7,6],[7,1,8],
      [3,9,4],[3,4,2],[3,2,6],[3,6,8],[3,8,9],
      [4,9,5],[2,4,11],[6,2,10],[8,6,7],[9,8,1]
    ];

    function midpoint(a, b) {
      const m = [(a[0]+b[0])/2, (a[1]+b[1])/2, (a[2]+b[2])/2];
      const l = Math.sqrt(m[0]*m[0] + m[1]*m[1] + m[2]*m[2]);
      return [m[0]/l, m[1]/l, m[2]/l];
    }

    let vertices = [...icoVertices];
    let faces = [...icoFaces];
    const midCache = {};

    function getMidIndex(i1, i2) {
      const key = Math.min(i1, i2) + '-' + Math.max(i1, i2);
      if (midCache[key] !== undefined) return midCache[key];
      const mid = midpoint(vertices[i1], vertices[i2]);
      vertices.push(mid);
      midCache[key] = vertices.length - 1;
      return midCache[key];
    }

    for (let s = 0; s < 2; s++) {
      const newFaces = [];
      for (const [a, b, c] of faces) {
        const ab = getMidIndex(a, b);
        const bc = getMidIndex(b, c);
        const ca = getMidIndex(c, a);
        newFaces.push([a, ab, ca], [b, bc, ab], [c, ca, bc], [ab, bc, ca]);
      }
      faces = newFaces;
    }

    // Edges
    const edgeSet = new Set();
    const edges = [];
    for (const [a, b, c] of faces) {
      [[a, b], [b, c], [c, a]].forEach(([i, j]) => {
        const key = Math.min(i, j) + '-' + Math.max(i, j);
        if (!edgeSet.has(key)) { edgeSet.add(key); edges.push([i, j]); }
      });
    }

    // Pulse particles travelling along edges
    const particles = [];
    for (let i = 0; i < 8; i++) {
      particles.push({
        edge: Math.floor(Math.random() * edges.length),
        t: Math.random(),
        speed: 0.002 + Math.random() * 0.003,
        size: 1.5 + Math.random() * 2
      });
    }

    let rotX = 0, rotY = 0;
    let parallaxX = 0, parallaxY = 0;

    document.addEventListener('mousemove', (e) => {
      parallaxX = (e.clientX / window.innerWidth - 0.5) * 0.02;
      parallaxY = (e.clientY / window.innerHeight - 0.5) * 0.02;
    });

    function project(v) {
      let x = v[0]*Math.cos(rotY) + v[2]*Math.sin(rotY);
      let z = -v[0]*Math.sin(rotY) + v[2]*Math.cos(rotY);
      let y = v[1];
      const ny = y*Math.cos(rotX) - z*Math.sin(rotX);
      const nz = y*Math.sin(rotX) + z*Math.cos(rotX);
      y = ny; z = nz;
      x += parallaxX; y += parallaxY;
      const scale = Math.min(heroCanvas.width, heroCanvas.height) * 0.28;
      const perspective = 4 / (4 + z);
      return [
        heroCanvas.width / 2 + x * scale * perspective,
        heroCanvas.height / 2 - y * scale * perspective,
        z
      ];
    }

    function renderHero() {
      ctx.clearRect(0, 0, heroCanvas.width, heroCanvas.height);
      rotY += 0.001;
      rotX += 0.0003;

      for (const [i, j] of edges) {
        const [x1, y1, z1] = project(vertices[i]);
        const [x2, y2, z2] = project(vertices[j]);
        const avgZ = (z1 + z2) / 2;
        const alpha = 0.08 + (1 + avgZ) * 0.12;
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.strokeStyle = `rgba(0, 176, 189, ${Math.max(0.03, alpha)})`;
        ctx.lineWidth = 0.6;
        ctx.stroke();
      }

      for (const v of vertices) {
        const [x, y, z] = project(v);
        const alpha = 0.1 + (1 + z) * 0.2;
        const size = 1 + (1 + z) * 0.5;
        ctx.beginPath();
        ctx.arc(x, y, size, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(63, 150, 174, ${Math.max(0.05, alpha)})`;
        ctx.fill();
      }

      for (const p of particles) {
        p.t += p.speed;
        if (p.t > 1) { p.t = 0; p.edge = Math.floor(Math.random() * edges.length); }
        const [i, j] = edges[p.edge];
        const v = [
          vertices[i][0] + (vertices[j][0] - vertices[i][0]) * p.t,
          vertices[i][1] + (vertices[j][1] - vertices[i][1]) * p.t,
          vertices[i][2] + (vertices[j][2] - vertices[i][2]) * p.t,
        ];
        const [x, y] = project(v);
        ctx.beginPath();
        ctx.arc(x, y, p.size, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(186, 223, 243, 0.7)`;
        ctx.fill();
      }

      requestAnimationFrame(renderHero);
    }
    renderHero();
  }

  /* ════════════════════════════════════════
     STATUS CLASSIFIER
     ════════════════════════════════════════ */
  const SM = {
    pass: 'pass', done: 'done', completed: 'completed',
    ship: 'ship', ready: 'ready',
    pending: 'pending', partial: 'partial',
    conditional: 'conditional', blocking: 'blocking',
    fail: 'fail', failing: 'fail',
    'no-ship': 'noship', noship: 'noship',
    error: 'error',
    'action required': 'action',
    implemented: 'implemented', open: 'open', info: 'info'
  };

  function classify(t) {
    const l = t.toLowerCase().replace(/[*_`]/g, '');
    for (const [k, v] of Object.entries(SM)) if (l.includes(k)) return v;
    return '';
  }

  function detectGate(md) {
    const l = md.toLowerCase();
    if (l.includes('no-ship') || l.includes('noship')) return 'noship';
    if (l.includes('conditional')) return 'conditional';
    if (/\bship\b/.test(l)) return 'ship';
    return 'noship';
  }

  /* ════════════════════════════════════════
     MARKDOWN PARSER
     ════════════════════════════════════════ */
  function parseMD(raw) {
    const lines = raw.split('\n'), sections = [];
    let cur = null;
    const meta = { title: '', date: '', env: '', bot: '', pkg: '', pub: '' };

    for (let i = 0; i < lines.length; i++) {
      const ln = lines[i];

      if (/^# (.+)/.test(ln) && !meta.title) {
        meta.title = ln.replace(/^# /, '').trim(); continue;
      }
      if (/^Date:/i.test(ln)) {
        meta.date = ln.replace(/^Date:\s*/i, '').trim(); continue;
      }
      if (/^Environment:/i.test(ln)) {
        meta.env = ln.replace(/^Environment:\s*/i, '').trim(); continue;
      }
      if (/^Bot:/i.test(ln)) {
        meta.bot = ln.replace(/^Bot:\s*/i, '').trim(); continue;
      }
      if (/^Latest package/i.test(ln)) {
        meta.pkg = ln.replace(/^Latest package[^:]*:\s*/i, '').replace(/`/g, '').trim(); continue;
      }
      if (/^Latest publish/i.test(ln)) {
        meta.pub = ln.replace(/^Latest publish[^:]*:\s*/i, '').trim(); continue;
      }
      if (/^## (.+)/.test(ln)) {
        cur = { heading: ln.replace(/^## /, '').trim(), blocks: [] };
        sections.push(cur); continue;
      }
      if (!cur) continue;

      // Table
      if (ln.trim().startsWith('|') && ln.includes('|')) {
        const tl = [ln]; let j = i + 1;
        while (j < lines.length && lines[j].trim().startsWith('|')) { tl.push(lines[j]); j++; }
        if (tl.length >= 2) { cur.blocks.push({ type: 'table', lines: tl }); i = j - 1; continue; }
      }
      // Ordered list
      if (/^\d+\.\s/.test(ln.trim())) {
        const items = [ln.trim().replace(/^\d+\.\s*/, '')]; let j = i + 1;
        while (j < lines.length && /^\d+\.\s/.test(lines[j].trim())) {
          items.push(lines[j].trim().replace(/^\d+\.\s*/, '')); j++;
        }
        cur.blocks.push({ type: 'list', items }); i = j - 1; continue;
      }
      // Unordered list
      if (/^[-*]\s/.test(ln.trim())) {
        const items = [ln.trim().replace(/^[-*]\s*/, '')]; let j = i + 1;
        while (j < lines.length && /^[-*]\s/.test(lines[j].trim())) {
          items.push(lines[j].trim().replace(/^[-*]\s*/, '')); j++;
        }
        cur.blocks.push({ type: 'list', items }); i = j - 1; continue;
      }
      // Code
      if (ln.trim().startsWith('```')) {
        const cl = []; let j = i + 1;
        while (j < lines.length && !lines[j].trim().startsWith('```')) { cl.push(lines[j]); j++; }
        cur.blocks.push({ type: 'code', content: cl.join('\n') }); i = j; continue;
      }
      if (ln.trim()) cur.blocks.push({ type: 'p', text: ln.trim() });
    }
    return { meta, sections };
  }

  function parseTable(tl) {
    const rows = tl.filter(l => !l.trim().match(/^\|[\s\-:|]+\|$/));
    if (!rows.length) return { h: [], d: [] };
    const h = rows[0].split('|').map(c => c.trim()).filter(Boolean);
    const d = rows.slice(1).map(r => r.split('|').map(c => c.trim()).filter(Boolean));
    return { h, d };
  }

  function escapeHtml(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function inlineMD(t) {
    return t
      .replace(/`([^`]+)`/g, '<code>$1</code>')
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/\*([^*]+)\*/g, '<em>$1</em>');
  }

  function pill(t) {
    const c = classify(t);
    const clean = t.replace(/[*_`]/g, '').trim();
    return c ? `<span class="pill ${c}">${escapeHtml(clean)}</span>` : escapeHtml(clean);
  }

  function extractKPIs(secs) {
    const kpis = [];
    let pass = 0, pend = 0, fail = 0, total = 0;
    for (const s of secs) for (const b of s.blocks) {
      if (b.type !== 'table') continue;
      const { h, d } = parseTable(b.lines);
      const si = h.findIndex(x => /status/i.test(x));
      if (si < 0) continue;
      for (const r of d) {
        const st = (r[si] || '').toLowerCase().replace(/[*_`]/g, '');
        total++;
        if (st.includes('pass') || st.includes('done') || st.includes('completed')) pass++;
        else if (st.includes('fail') || st.includes('noship')) fail++;
        else pend++;
      }
    }
    if (total > 0) {
      kpis.push({ l: 'Total Items', v: total, c: 'c' });
      kpis.push({ l: 'Passed',      v: pass,  c: 's' });
      kpis.push({ l: 'Pending',     v: pend,  c: pend ? 'w' : 's' });
      kpis.push({ l: 'Failed',      v: fail,  c: fail ? 'e' : 's' });
      const pct = Math.round((pass / total) * 100);
      kpis.push({ l: 'Completion', v: pct + '%', c: pct >= 80 ? 's' : pct >= 50 ? 'w' : 'e' });
    }
    return kpis;
  }

  /* ════════════════════════════════════════
     RENDER
     ════════════════════════════════════════ */
  function render(parsed) {
    const { meta, sections } = parsed;
    const gate = detectGate(JSON.stringify(parsed));

    // Topbar
    topbarTitle.textContent = meta.title || 'Status Report';
    topbarEyebrow.textContent = (meta.bot || 'PMO STATUS REPORT').toUpperCase();
    topbarDate.querySelector('span').textContent = meta.date || new Date().toISOString().slice(0, 10);
    topbarEnv.querySelector('span').textContent = meta.env ? meta.env.split('(')[0].trim() : '—';

    const gm = {
      noship:      { l: 'No-Ship',      c: 'noship' },
      conditional: { l: 'Conditional',  c: 'conditional' },
      ship:        { l: 'Ship',         c: 'ship' }
    };
    const g = gm[gate];
    topbarGate.innerHTML = `<span class="gate-pill ${g.c}">${g.l}</span>`;

    // Sidebar gate
    sidebarGate.className = 'sidebar__status' +
      (gate === 'ship' ? ' ship' : gate === 'conditional' ? ' conditional' : '');
    sidebarGate.querySelector('.gate-label').textContent = g.l.toUpperCase();

    // KPIs
    const kpis = extractKPIs(sections);
    kpiRow.innerHTML = '';
    if (!kpis.length) {
      $('kpiSection').style.display = 'none';
    } else {
      $('kpiSection').style.display = '';
      kpis.forEach((k, i) => {
        const d = document.createElement('div');
        d.className = 'kpi-card';
        d.setAttribute('data-animate', '');
        d.style.transitionDelay = (i * 80) + 'ms';
        d.innerHTML = `<div class="kpi-label">${k.l}</div><div class="kpi-val ${k.c}">${k.v}</div>`;
        kpiRow.appendChild(d);
      });
    }

    // Sidebar nav buttons (flat DSS style)
    sidebarNav.innerHTML = '<div class="nav-section-label">Sections</div>';
    sections.forEach((s, i) => {
      const btn = document.createElement('button');
      btn.className = 'sidebar-btn';
      btn.type = 'button';
      btn.dataset.target = 'sec-' + i;
      const label = s.heading.length > 24 ? s.heading.slice(0, 22) + '…' : s.heading;
      btn.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8">
          <rect x="3" y="3" width="18" height="18" rx="0"/>
          <path d="M3 9h18"/>
        </svg>
        <span>${escapeHtml(label)}</span>
      `;
      btn.addEventListener('click', () => {
        document.getElementById('sec-' + i)?.scrollIntoView({ behavior: 'smooth' });
        document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('sidebar-btn--active'));
        btn.classList.add('sidebar-btn--active');
      });
      sidebarNav.appendChild(btn);
    });

    // Sections
    dynSections.innerHTML = '';
    sections.forEach((sec, idx) => {
      const el = document.createElement('section');
      el.className = 'exec-section';
      el.id = 'sec-' + idx;
      el.setAttribute('data-animate', '');
      el.style.transitionDelay = (idx * 80) + 'ms';

      let h = `<p class="sec-eyebrow">Section ${String(idx + 1).padStart(2, '0')}</p>`;
      h += `<h2 class="sec-title">${escapeHtml(sec.heading)}</h2>`;

      for (const b of sec.blocks) {
        if (b.type === 'table') {
          const { h: hd, d } = parseTable(b.lines);
          const si = hd.findIndex(x => /status/i.test(x));
          h += '<div class="table-wrap"><table class="exec-table"><thead><tr>';
          hd.forEach(c => { h += `<th>${escapeHtml(c)}</th>`; });
          h += '</tr></thead><tbody>';
          d.forEach(r => {
            h += '<tr>';
            r.forEach((c, ci) => { h += `<td>${ci === si ? pill(c) : inlineMD(escapeHtml(c))}</td>`; });
            for (let p = r.length; p < hd.length; p++) h += '<td></td>';
            h += '</tr>';
          });
          h += '</tbody></table></div>';
        } else if (b.type === 'list') {
          h += '<ol class="exec-list">';
          b.items.forEach(i => { h += `<li>${inlineMD(escapeHtml(i))}</li>`; });
          h += '</ol>';
        } else if (b.type === 'code') {
          h += `<div class="exec-code">${escapeHtml(b.content)}</div>`;
        } else {
          h += `<p class="exec-p">${inlineMD(escapeHtml(b.text))}</p>`;
        }
      }
      el.innerHTML = h;
      dynSections.appendChild(el);
    });

    footerTs.textContent = 'Rendered ' + new Date().toLocaleString('pt-BR');

    // Transition
    heroSection.style.display = 'none';
    dashboard.style.display = 'block';
    window.scrollTo({ top: 0, behavior: 'smooth' });

    // Re-observe new [data-animate] elements
    observeAnimated(dashboard);

    // Home button
    btnNavHome.onclick = () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
      document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('sidebar-btn--active'));
      btnNavHome.classList.add('sidebar-btn--active');
    };
  }

  /* ════════════════════════════════════════
     FILE HANDLING
     ════════════════════════════════════════ */
  function handleFile(f) {
    if (!f) return;
    const r = new FileReader();
    r.onload = e => { render(parseMD(e.target.result)); };
    r.readAsText(f, 'utf-8');
  }
  fileInput.addEventListener('change', e => handleFile(e.target.files[0]));

  // Drag & drop
  let dc = 0;
  document.addEventListener('dragenter', e => {
    e.preventDefault(); dc++; dropZone.classList.add('active');
  });
  document.addEventListener('dragleave', e => {
    e.preventDefault(); dc--; if (dc <= 0) { dc = 0; dropZone.classList.remove('active'); }
  });
  document.addEventListener('dragover', e => e.preventDefault());
  document.addEventListener('drop', e => {
    e.preventDefault(); dc = 0; dropZone.classList.remove('active');
    handleFile(e.dataTransfer.files[0]);
  });

  // Scroll spy
  window.addEventListener('scroll', () => {
    const btns = sidebarNav.querySelectorAll('.sidebar-btn');
    let active = null;
    btns.forEach(b => {
      const el = document.getElementById(b.dataset.target);
      if (el && el.getBoundingClientRect().top <= 120) active = b;
    });
    btns.forEach(b => b.classList.remove('sidebar-btn--active'));
    if (active) active.classList.add('sidebar-btn--active');
    else btnNavHome.classList.add('sidebar-btn--active');
  });

  /* ════════════════════════════════════════
     DEMO DATA
     ════════════════════════════════════════ */
  btnDemo.addEventListener('click', () => {
    render(parseMD(
`# PMO 360 Status Report

Date: ${new Date().toISOString().slice(0, 10)}
Environment: ColOfertasBrasilPro
Bot: Assistente PMO V2

## Latest Updates

| Area | Status | Evidence |
|---|---|---|
| Solution v1.13 import and publish | PASS | CriarTarefa duplicate guard, fresh create, and cancel guard passed with SharePoint proof. |
| v1.14 soft-delete package | PASS | Solution/PMO_v11_Tarefas_1_14_SOFT_DELETE_FIX.zip exists and static soft-delete audit passed 35/35 checks. |
| ConsultarPortfolio runtime | PASS | Live SharePoint aggregation returned active portfolio counts. |
| ConsultarProjeto runtime | PASS | Two-step and direct projeto= lookup returned live project details. |
| AtualizarStatus runtime | PASS | Teste Smoke Final V5 updated Projetos and Status Diario. Pilot Mobile App Corporativo needs data repair only. |
| RegistrarRisco runtime | PASS | SharePoint confirmed RISK-6851D4E6 in Riscos e Bloqueios. |
| RegistrarBloqueio runtime | PASS | SharePoint confirmed BLOCK-F8577225 in Riscos e Bloqueios. |
| PedirDecisao runtime | PASS | SharePoint confirmed DEC-C930FF9A in Decisoes do Board. |

## Pending Gap Status Ordered By Severity

| Severity | Gap / Workstream | Current Status | Next Step | Next-Hour Estimate |
|---|---|---|---|---|
| P0 Critical | v1.14 ExcluirProjeto / ExcluirTarefa soft-delete runtime | PACKAGE READY / STATIC PASS | Import and publish v1.14, then prove project and task soft-delete with Deleted=true and audit fields. | 30-55 min |
| P1 High | Pilot project Title data repair | PENDING APPROVAL | Set Title = NomeProjeto for affected pilot rows such as Mobile App Corporativo; retest AtualizarStatus on pilot data. | 10-20 min |
| P1 High | Recurrence and alert flows runtime proof | PARTIAL PASS / FRESH PROOF PENDING | Capture updated run evidence for daily/weekly portfolio, red alert, critical risk escalation, and decision response. | 30-60 min |
| P1 High | Planner sync metrics | PENDING UPDATED EVIDENCE | Trigger or inspect PMO_PA_SyncPlannerStats_Standard and verify project metric fields. | 20-40 min |
| P2 Medium | Final live solution export and audit | PENDING | Export after v1.14 runtime proof and run stop-ship/static audits against the fresh export. | 20-40 min |
| P2 Medium | Training/runbook screenshots | PENDING | Capture final workflow screenshots and update the evidence matrix. | 30-60 min |

## Next Hour Plan

1. Import and publish Solution/PMO_v11_Tarefas_1_14_SOFT_DELETE_FIX.zip.
2. Run ExcluirProjeto positive and cancel tests against Projeto Smoke v113 Cancel.
3. Run ExcluirTarefa positive test against one exact task line, if a safe task target is available.
4. Verify SharePoint rows remain physically present and active queries exclude Deleted=true rows.
5. If time remains, repair pilot Title data and collect Planner/recurrence evidence.

## Current Gate View

Status: NO-SHIP until v1.14 runtime proof and final export audit are complete.

Reason: Core read/write P0 smoke tests are green, but PM-friendly removal is now the remaining P0 release capability and must be proven in live Copilot + SharePoint before release.`
    ));
  });

})();
