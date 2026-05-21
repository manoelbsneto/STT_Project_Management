/* ──────────────────────────────────────────────────────────────────────
   Indra MD Viewer — dual-mode engine
   • Status Log mode  → legacy KPI dashboard + table + timeline (preserved)
   • Executive Doc mode (NEW) → premium C-Level Markdown rendering with
     hero, KPI strip, sticky TOC, ASCII-art diagrams, JSON Schema cards,
     YAML configs, callouts, faróis, auto-export to print/HTML.
   ────────────────────────────────────────────────────────────────────── */
(function () {
  'use strict';

  // ─── STATE ────────────────────────────────────────────────────────────
  const state = {
    files: [],
    entries: [],
    docs: [],            // executive documents: { id, name, raw, html, toc, meta, kpis, summary }
    activeDocId: null,
    page: 1,
    pageSize: 15,
    sortCol: null,
    sortDir: 'asc',
    activeView: 'Dashboard'
  };

  // ─── DOM HELPERS ──────────────────────────────────────────────────────
  const $ = id => document.getElementById(id);
  const navBtns = {
    Dashboard: $('navDashboard'),
    Upload:    $('navUpload'),
    Document:  $('navDocument'),
    Table:     $('navTable'),
    Timeline:  $('navTimeline')
  };
  const views = {
    Dashboard: $('viewDashboard'),
    Upload:    $('viewUpload'),
    Document:  $('viewDocument'),
    Table:     $('viewTable'),
    Timeline:  $('viewTimeline')
  };
  const dropZone     = $('dropZone'),
        fileInput    = $('fileInput'),
        fileInputFull= $('fileInputFull'),
        fileInputDoc = $('fileInputDoc'),
        dropZoneFull = $('dropZoneFull'),
        docEmptyDrop = $('docEmptyDrop'),
        fileQueue    = $('fileQueue'),
        btnProcess   = $('btnProcess'),
        progressRing = $('progressRing'),
        progressPct  = $('progressPct'),
        actFeed      = $('activityFeed'),
        toastBox     = $('toastContainer'),
        modeBadge    = $('modeBadge');
  const circumference = 2 * Math.PI * 58;

  // ─── SIDEBAR PROJECT HEADER ──────────────────────────────────────────
  // Atualiza o cabeçalho "PROJETO ATUAL" + barra de progresso na sidebar.
  // - name: texto exibido (ex: nome do arquivo, "Sem documento", "Processando…")
  // - pct:  0..100 (largura da barra cyan→teal)
  function updateSidebarProject(name, pct) {
    const elName = document.getElementById('sidebarProjectName');
    const elBar  = document.getElementById('sidebarProjectBar');
    const elWrap = elBar?.parentElement;
    if (elName) {
      elName.textContent = name || 'Sem documento';
      elName.title = name || 'Sem documento carregado';
    }
    if (elBar) {
      const clamped = Math.max(0, Math.min(100, Number(pct) || 0));
      elBar.style.width = clamped + '%';
      if (elWrap) elWrap.setAttribute('aria-valuenow', String(Math.round(clamped)));
    }
  }

  // ─── SIDEBAR TOGGLE (mobile) ─────────────────────────────────────────
  const sidebarEl = document.getElementById('appSidebar');
  document.getElementById('sidebarToggle')?.addEventListener('click', () => {
    sidebarEl?.classList.toggle('open');
  });

  // ─── NAVIGATION ───────────────────────────────────────────────────────
  function switchView(name) {
    if (!views[name]) return;
    state.activeView = name;
    Object.keys(views).forEach(k => {
      if (!views[k]) return;
      const isActive = k === name;
      views[k].classList.toggle('view-hidden', !isActive);
      views[k].style.display = isActive ? '' : 'none';
      navBtns[k]?.classList.toggle('active', isActive);
    });
    if (modeBadge) {
      const isExec = name === 'Document';
      modeBadge.textContent = isExec ? 'EXECUTIVE' : 'STATUS LOG';
      modeBadge.dataset.mode = isExec ? 'executive' : 'status';
    }
    if (name === 'Table') {
      renderTable($('statusTableBodyFull'), $('tableInfoFull'), $('tablePaginationFull'),
                  $('tableSearchFull'), $('tableStatusFilterFull'));
    }
    if (name === 'Timeline') renderTimeline();
    if (name === 'Document' && state.activeDocId) {
      // re-run scrollspy on view change
      requestAnimationFrame(initScrollSpy);
    }
  }
  Object.keys(navBtns).forEach(k => navBtns[k]?.addEventListener('click', () => switchView(k)));

  // ─── TOAST ────────────────────────────────────────────────────────────
  function toast(msg, type = 'info') {
    if (!toastBox) return;
    const el = document.createElement('div');
    el.className = `toast ${type}`;
    el.innerHTML = `<span>${escapeHtml(msg)}</span>`;
    toastBox.appendChild(el);
    setTimeout(() => { el.classList.add('removing'); setTimeout(() => el.remove(), 300); }, 3500);
  }
  function escapeHtml(s = '') {
    return String(s).replace(/[&<>"']/g, m => ({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m]));
  }

  // ─── FILE HANDLING (queue) ────────────────────────────────────────────
  function addFiles(fileList) {
    [...fileList].forEach(f => {
      const ext = f.name.split('.').pop().toLowerCase();
      if (!['md', 'markdown', 'txt', 'docx', 'doc'].includes(ext)) {
        toast(`Unsupported: ${f.name}`, 'error');
        return;
      }
      if (state.files.find(x => x.file.name === f.name)) return;
      state.files.push({ file: f, status: 'pending', progress: 0 });
    });
    renderFileQueue();
    btnProcess.disabled = state.files.filter(f => f.status === 'pending').length === 0;
    addActivity('info', `${fileList.length} file(s) queued`);

    // Atualiza header da sidebar com o último arquivo recebido
    const last = state.files[state.files.length - 1];
    if (last) updateSidebarProject(last.file.name.replace(/\.[^.]+$/, ''), 15);

    // Auto-process .md immediately for instant executive rendering
    autoProcessMarkdown();
  }

  function renderFileQueue() {
    if (!fileQueue) return;
    fileQueue.innerHTML = state.files.map((f, i) => `
      <div class="file-item" data-idx="${i}">
        <div class="file-item-icon">
          <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
          </svg>
        </div>
        <div class="file-item-info">
          <div class="file-item-name">${escapeHtml(f.file.name)}</div>
          <div class="file-item-size">${(f.file.size / 1024).toFixed(1)} KB</div>
          ${f.status === 'processing'
            ? `<div class="file-item-progress"><div class="file-item-progress-bar" style="width:${f.progress}%"></div></div>`
            : ''}
        </div>
        <span class="file-item-status ${f.status}">${f.status}</span>
        ${f.status === 'pending'
          ? `<button class="file-item-remove" onclick="window._removeFile(${i})" aria-label="Remove">✕</button>`
          : ''}
      </div>`).join('');
  }
  window._removeFile = i => {
    state.files.splice(i, 1);
    renderFileQueue();
    btnProcess.disabled = !state.files.some(f => f.status === 'pending');
  };

  // ─── DRAG & DROP ──────────────────────────────────────────────────────
  function setupDrop(zone, input) {
    if (!zone) return;
    ['dragenter', 'dragover'].forEach(e =>
      zone.addEventListener(e, ev => { ev.preventDefault(); zone.classList.add('drag-over'); }));
    ['dragleave', 'drop'].forEach(e =>
      zone.addEventListener(e, () => zone.classList.remove('drag-over')));
    zone.addEventListener('drop', ev => {
      ev.preventDefault();
      addFiles(ev.dataTransfer.files);
    });
    if (input) {
      zone.addEventListener('click', e => {
        if (!e.target.closest('label') && !e.target.closest('button') && !e.target.closest('input')) {
          input.click();
        }
      });
      input.addEventListener('change', () => { addFiles(input.files); input.value = ''; });
    }
  }
  setupDrop(dropZone, fileInput);
  setupDrop(dropZoneFull, fileInputFull);
  setupDrop(docEmptyDrop, fileInputDoc);

  // Allow drop anywhere on the document view itself
  if (views.Document) {
    views.Document.addEventListener('dragover', e => e.preventDefault());
    views.Document.addEventListener('drop', e => {
      e.preventDefault();
      addFiles(e.dataTransfer.files);
    });
  }

  // ─── FILE READER ──────────────────────────────────────────────────────
  function readFileText(file) {
    return new Promise((resolve, reject) => {
      const ext = file.name.split('.').pop().toLowerCase();
      if (ext === 'docx' || ext === 'doc') {
        const reader = new FileReader();
        reader.onload = e => {
          const bytes = new Uint8Array(e.target.result);
          let text = '';
          const decoder = new TextDecoder('utf-8', { fatal: false });
          const raw = decoder.decode(bytes);
          const matches = raw.match(/<w:t[^>]*>([^<]*)<\/w:t>/g);
          if (matches) text = matches.map(m => m.replace(/<[^>]+>/g, '')).join(' ');
          else text = raw.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ');
          resolve(text);
        };
        reader.onerror = reject;
        reader.readAsArrayBuffer(file);
      } else {
        const reader = new FileReader();
        reader.onload = e => resolve(e.target.result);
        reader.onerror = reject;
        reader.readAsText(file);
      }
    });
  }

  // ─── DOC TYPE DETECTOR ────────────────────────────────────────────────
  // Returns 'executive' or 'status'
  function detectDocType(text, fileName = '') {
    if (!text) return 'status';

    let score = 0;
    // Strong executive signals
    if (/^---\n[\s\S]*?\n---/m.test(text.slice(0, 800))) score += 4;            // YAML frontmatter
    if (/```[a-z]*\n[\s\S]*?[┌┐└┘─│├┤┬┴┼▶▲▼◀]/m.test(text)) score += 4;          // ASCII-art diagrams
    if (/```json[\s\S]*?\$schema[\s\S]*?```/m.test(text)) score += 4;             // JSON Schema
    if (/```ya?ml[\s\S]*?```/m.test(text)) score += 2;                            // YAML blocks
    if (/^>\s*\*\*Especificação\b/im.test(text)) score += 4;                      // PT spec marker
    if (/^>\s*(Vers[ãa]o|Status|Audi[êe]ncia|Confidencialidade)\s*[:|]/im.test(text)) score += 3;
    if (/^#\s+.+\n+>\s/m.test(text)) score += 2;                                  // H1 followed by blockquote (common spec pattern)

    // Heading density — exec docs have many H2/H3
    const h2Count = (text.match(/^##\s+/gm) || []).length;
    const h3Count = (text.match(/^###\s+/gm) || []).length;
    if (h2Count + h3Count >= 6) score += 2;
    if (h2Count + h3Count >= 12) score += 2;

    // Filename hints
    if (/agente|spec|proposta|arquitet|kickoff|mapeamento|paths|brief|rfp/i.test(fileName)) score += 2;

    // Anti-signals (status logs are usually short, table-heavy without diagrams)
    const tableLines = (text.match(/^\s*\|/gm) || []).length;
    const sepLines = (text.match(/^\s*\|?\s*[-:]+[-|:\s]*$/gm) || []).length;
    if (tableLines > 30 && h2Count + h3Count < 4 && sepLines >= 2) score -= 3;

    return score >= 4 ? 'executive' : 'status';
  }

  // ─── PROCESS FILES (dispatcher) ───────────────────────────────────────
  let autoProcessing = false;
  async function autoProcessMarkdown() {
    if (autoProcessing) return;
    autoProcessing = true;
    const pending = state.files.filter(f => f.status === 'pending' && /\.(md|markdown|txt)$/i.test(f.file.name));
    for (const fobj of pending) {
      fobj.status = 'processing';
      renderFileQueue();
      updateSidebarProject(fobj.file.name.replace(/\.[^.]+$/, ''), 50);
      try {
        const text = await readFileText(fobj.file);
        const docType = detectDocType(text, fobj.file.name);
        if (docType === 'executive') {
          ingestExecutiveDoc(text, fobj.file.name);
          fobj.status = 'done';
          fobj.progress = 100;
          updateSidebarProject(fobj.file.name.replace(/\.[^.]+$/, ''), 100);
          toast(`Documento executivo carregado: ${fobj.file.name}`, 'success');
          addActivity('ok', `<strong>${escapeHtml(fobj.file.name)}</strong> renderizado em modo executivo`);
        } else {
          // legacy status pipeline
          const newEntries = parseContent(text, fobj.file.name);
          newEntries.forEach(e => { e.id = state.entries.length + 1; state.entries.push(e); });
          fobj.status = 'done';
          fobj.progress = 100;
          updateSidebarProject(fobj.file.name.replace(/\.[^.]+$/, ''), 100);
          addActivity('ok', `<strong>${escapeHtml(fobj.file.name)}</strong> → ${newEntries.length} entries parsed`);
          toast(`${fobj.file.name}: ${newEntries.length} entries`, 'success');
          updateKPIs();
          drawChart();
          renderTable($('statusTableBody'), $('tableInfo'), $('tablePagination'),
                      $('tableSearch'), $('tableStatusFilter'));
          $('tableSection').style.display = '';
          $('tableSubtitle').textContent =
            `${state.entries.length} entries from ${state.files.filter(f => f.status === 'done').length} files`;
        }
      } catch (err) {
        fobj.status = 'error';
        addActivity('error', `Failed: ${escapeHtml(fobj.file.name)} — ${escapeHtml(err.message || String(err))}`);
        toast(`Error: ${fobj.file.name}`, 'error');
        console.error(err);
      }
      renderFileQueue();
    }
    btnProcess.disabled = !state.files.some(f => f.status === 'pending');
    autoProcessing = false;
  }

  // ─── LEGACY STATUS-LOG PARSER (preserved) ─────────────────────────────
  function parseContent(text, sourceName) {
    const entries = [];
    const now = new Date();
    const statusPatterns = [
      { re: /\b(error|fail(ed|ure)?|critical|exception|crash|fatal|broke[n]?|no.?ship|no.?publish|no.?go|rejected?)\b/i, status: 'error' },
      { re: /\b(block(ed|er)?|action.?required|stopp?ed|cancelled|removed|excluded|retired|destroyed)\b/i, status: 'blocked' },
      { re: /\b(warn(ing)?|alert|caution|deprecated|risk|degrad(ed)?|high.?risk|attention)\b/i, status: 'warning' },
      { re: /\b(partial(ly)?|in.?progress|wip|ongoing|working|review|draft|preview)\b/i, status: 'partial' },
      { re: /\b(pend(ing|ente)?|scheduled|queued|awaiting|wait(ing)?|to.?do|not.?started|backlog|future|planned)\b/i, status: 'pending' },
      { re: /\b(ok|pass(ed)?|success(ful)?|done|complet(e[do]?|ado)|finished|deployed?|operational|green|active|running|approved|go\b|correc?to|procesado|resolved|verified|confirmed|clean|shipped|live)\b/i, status: 'ok' },
      { re: /\b(accept(ed)?|acknowledge[d]?|known|residue|non.?runtime|skipped)\b/i, status: 'accepted' },
      { re: /\b(info(rmation)?|note|fyi|reference|context|N\/A)\b/i, status: 'info' }
    ];
    function detectStatus(t) {
      for (const p of statusPatterns) if (p.re.test(t)) return p.status;
      return 'info';
    }
    const rawLines = text.split('\n');
    let inCodeBlock = false, currentSection = 'General';
    const sections = [];
    let currentLines = [];
    for (const line of rawLines) {
      if (line.trim().startsWith('```')) { inCodeBlock = !inCodeBlock; continue; }
      if (inCodeBlock) continue;
      const headerMatch = line.match(/^#{1,4}\s+(.+)/);
      if (headerMatch) {
        if (currentLines.length) sections.push({ title: currentSection, lines: currentLines });
        currentSection = headerMatch[1].trim();
        currentLines = [];
      } else currentLines.push(line);
    }
    if (currentLines.length) sections.push({ title: currentSection, lines: currentLines });

    for (const section of sections) {
      const tableBlocks = [];
      let tblStart = -1;
      for (let i = 0; i < section.lines.length; i++) {
        const line = section.lines[i];
        if (line.includes('|') && line.trim().split('|').filter(Boolean).length >= 2) {
          if (tblStart === -1) tblStart = i;
        } else if (tblStart !== -1) {
          tableBlocks.push(section.lines.slice(tblStart, i)); tblStart = -1;
        }
      }
      if (tblStart !== -1) tableBlocks.push(section.lines.slice(tblStart));
      for (const tblLines of tableBlocks) {
        if (tblLines.length < 2) continue;
        const headerIdx = tblLines.findIndex(l => l.includes('|') && !l.match(/^\s*\|?\s*[-:]+[-|:\s]*$/));
        const sepIdx    = tblLines.findIndex(l => l.match(/^\s*\|?\s*[-:]+[-|:\s]*$/));
        if (headerIdx === -1 || sepIdx === -1) continue;
        const headerCells = tblLines[headerIdx].split('|').map(c => c.trim()).filter(Boolean);
        for (let i = sepIdx + 1; i < tblLines.length; i++) {
          const line = tblLines[i];
          if (line.match(/^\s*\|?\s*[-:]+[-|:\s]*$/)) continue;
          const cells = line.split('|').map(c => c.trim()).filter(Boolean);
          if (cells.length < 2) continue;
          const fullText = cells.join(' ');
          let project = cells[0], statusText = fullText;
          const statusColIdx = headerCells.findIndex(h => /result|status|state|gate|decision/i.test(h));
          if (statusColIdx !== -1 && cells[statusColIdx]) statusText = cells[statusColIdx];
          const status = detectStatus(statusText);
          const nameColIdx = headerCells.findIndex(h => /name|task|item|feature|gate|test|display|check/i.test(h));
          if (nameColIdx !== -1 && cells[nameColIdx]) project = cells[nameColIdx];
          const tsMatch = fullText.match(/(\d{4}[-/]\d{2}[-/]\d{2}[\sT]?\d{2}:\d{2})/);
          entries.push({
            id: entries.length + 1, source: sourceName,
            project: project.replace(/`/g, '').slice(0, 80),
            status,
            statusRaw: statusText.replace(/`/g, '').slice(0, 40),
            category: section.title.slice(0, 40),
            timestamp: tsMatch ? tsMatch[1] : now.toISOString().slice(0, 16),
            details: fullText.replace(/`/g, '').slice(0, 200)
          });
        }
      }
      for (const line of section.lines) {
        if (line.includes('|') || !line.trim() || line.trim().length < 5) continue;
        const kvMatch = line.match(/^[\s\-*]*(.+?):\s*[`"]*(\w[\w\s\-/.]*)[`"]*/);
        const bulletMatch = line.match(/^[\s\-*]+(.{10,})/);
        const match = kvMatch || bulletMatch;
        if (!match) continue;
        const content = kvMatch ? `${match[1]}: ${match[2]}` : match[1].trim();
        if (content.length < 5) continue;
        const status = detectStatus(content);
        if (status === 'info' && !kvMatch) continue;
        const tsMatch = content.match(/(\d{4}[-/]\d{2}[-/]\d{2}[\sT]?\d{2}:\d{2})/);
        entries.push({
          id: entries.length + 1, source: sourceName,
          project: (kvMatch ? match[1] : content).replace(/`/g, '').slice(0, 80),
          status,
          statusRaw: (kvMatch ? match[2] : status).replace(/`/g, '').slice(0, 40),
          category: section.title.slice(0, 40),
          timestamp: tsMatch ? tsMatch[1] : now.toISOString().slice(0, 16),
          details: content.replace(/`/g, '').slice(0, 200)
        });
      }
    }
    return entries;
  }

  // Manual "Process All" still works (legacy + executive)
  btnProcess?.addEventListener('click', () => autoProcessMarkdown());

  function updateProgress(pct) {
    if (!progressRing) return;
    progressRing.style.strokeDashoffset = circumference - (pct * circumference);
    progressPct.textContent = Math.round(pct * 100) + '%';
  }
  function updateKPIs() {
    const ok = state.entries.filter(e => ['ok', 'accepted'].includes(e.status)).length;
    const warn = state.entries.filter(e => ['warning', 'partial'].includes(e.status)).length;
    const err = state.entries.filter(e => ['error', 'blocked'].includes(e.status)).length;
    const pend = state.entries.filter(e => ['pending', 'info'].includes(e.status)).length;
    const files = state.files.filter(f => f.status === 'done').length;
    animateValue($('kpiFiles'), files);
    animateValue($('kpiOk'), ok);
    animateValue($('kpiWarning'), warn);
    animateValue($('kpiError'), err);
    $('breakOk').textContent = ok;
    $('breakWarn').textContent = warn;
    $('breakErr').textContent = err;
    $('breakPend').textContent = pend;
    updateProgress(state.files.length ? files / state.files.length : 0);
  }
  function animateValue(el, target) {
    if (!el) return;
    const start = parseInt(el.textContent) || 0;
    const diff = target - start;
    const dur = 600, t0 = performance.now();
    function tick(now) {
      const p = Math.min((now - t0) / dur, 1);
      el.textContent = Math.round(start + diff * (1 - Math.pow(1 - p, 3)));
      if (p < 1) requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
  }
  function addActivity(type, html) {
    if (!actFeed) return;
    const dotClass = { ok: 'success', warning: 'warning', error: 'error', info: 'info' };
    const empty = actFeed.querySelector('.activity-empty');
    if (empty) empty.remove();
    const li = document.createElement('li');
    li.innerHTML = `<span class="activity-dot ${dotClass[type] || 'info'}"></span>
                    <div><div class="activity-text">${html}</div>
                    <div class="activity-time">${new Date().toLocaleTimeString()}</div></div>`;
    actFeed.prepend(li);
    if (actFeed.children.length > 20) actFeed.lastChild.remove();
  }

  // ─── STATUS TABLE / SEARCH / SORT / EXPORT (preserved) ────────────────
  function renderTable(tbody, info, pagination, searchInput, filterSelect) {
    if (!tbody) return;
    let data = [...state.entries];
    const q = searchInput?.value?.toLowerCase() || '';
    const sf = filterSelect?.value || 'all';
    if (q) data = data.filter(e => (e.project + e.source + e.details + e.category).toLowerCase().includes(q));
    if (sf !== 'all') data = data.filter(e => e.status === sf);
    if (state.sortCol) {
      data.sort((a, b) => {
        let va = a[state.sortCol] || '', vb = b[state.sortCol] || '';
        if (state.sortCol === 'id') { va = +va; vb = +vb; }
        else { va = String(va).toLowerCase(); vb = String(vb).toLowerCase(); }
        return va < vb ? (state.sortDir === 'asc' ? -1 : 1) : va > vb ? (state.sortDir === 'asc' ? 1 : -1) : 0;
      });
    }
    const totalPages = Math.max(1, Math.ceil(data.length / state.pageSize));
    if (state.page > totalPages) state.page = totalPages;
    const start = (state.page - 1) * state.pageSize;
    const pageData = data.slice(start, start + state.pageSize);
    tbody.innerHTML = pageData.map(e => `<tr>
      <td style="font-family:var(--font-mono);font-size:12px;color:var(--indra-light)">${e.id}</td>
      <td class="col-source">${escapeHtml(e.source)}</td>
      <td class="col-project">${escapeHtml(e.project)}</td>
      <td><span class="tbl-status ${e.status}">${e.status}</span></td>
      <td style="font-size:12px">${escapeHtml(e.category)}</td>
      <td style="font-size:12px;font-family:var(--font-mono);color:var(--indra-light)">${escapeHtml(e.timestamp)}</td>
      <td class="col-details" title="${escapeHtml(e.details)}">${escapeHtml(e.details)}</td>
    </tr>`).join('') ||
      '<tr><td colspan="7" style="text-align:center;padding:32px;color:var(--indra-light)">No entries — upload files to populate</td></tr>';
    if (info) info.textContent = `Showing ${pageData.length} of ${data.length} entries`;
    if (pagination) {
      let btns = '';
      if (totalPages > 1) {
        btns += `<button class="page-btn" data-p="${Math.max(1, state.page - 1)}">‹</button>`;
        for (let i = 1; i <= Math.min(totalPages, 7); i++)
          btns += `<button class="page-btn ${i === state.page ? 'active' : ''}" data-p="${i}">${i}</button>`;
        if (totalPages > 7) btns += `<button class="page-btn" data-p="${totalPages}">${totalPages}</button>`;
        btns += `<button class="page-btn" data-p="${Math.min(totalPages, state.page + 1)}">›</button>`;
      }
      pagination.innerHTML = btns;
      pagination.querySelectorAll('.page-btn').forEach(b => b.addEventListener('click', () => {
        state.page = +b.dataset.p;
        renderTable(tbody, info, pagination, searchInput, filterSelect);
      }));
    }
  }
  document.querySelectorAll('.data-table thead th.sortable').forEach(th => {
    th.addEventListener('click', () => {
      const col = th.dataset.sort;
      if (state.sortCol === col) state.sortDir = state.sortDir === 'asc' ? 'desc' : 'asc';
      else { state.sortCol = col; state.sortDir = 'asc'; }
      document.querySelectorAll('.data-table thead th').forEach(h => h.classList.remove('sort-asc', 'sort-desc'));
      th.classList.add(state.sortDir === 'asc' ? 'sort-asc' : 'sort-desc');
      renderTable($('statusTableBody'), $('tableInfo'), $('tablePagination'), $('tableSearch'), $('tableStatusFilter'));
      renderTable($('statusTableBodyFull'), $('tableInfoFull'), $('tablePaginationFull'),
                  $('tableSearchFull'), $('tableStatusFilterFull'));
    });
  });
  ['tableSearch', 'tableSearchFull'].forEach(id => {
    $(id)?.addEventListener('input', () => {
      state.page = 1;
      renderTable($('statusTableBody'), $('tableInfo'), $('tablePagination'), $('tableSearch'), $('tableStatusFilter'));
      renderTable($('statusTableBodyFull'), $('tableInfoFull'), $('tablePaginationFull'),
                  $('tableSearchFull'), $('tableStatusFilterFull'));
    });
  });
  ['tableStatusFilter', 'tableStatusFilterFull'].forEach(id => {
    $(id)?.addEventListener('change', () => {
      state.page = 1;
      renderTable($('statusTableBody'), $('tableInfo'), $('tablePagination'), $('tableSearch'), $('tableStatusFilter'));
      renderTable($('statusTableBodyFull'), $('tableInfoFull'), $('tablePaginationFull'),
                  $('tableSearchFull'), $('tableStatusFilterFull'));
    });
  });

  function exportCSV() {
    if (!state.entries.length) { toast('No data to export', 'error'); return; }
    const header = 'ID,Source,Project,Status,Category,Timestamp,Details';
    const rows = state.entries.map(e =>
      `${e.id},"${e.source}","${e.project}",${e.status},"${e.category}","${e.timestamp}","${e.details.replace(/"/g, '""')}"`);
    const blob = new Blob([header + '\n' + rows.join('\n')], { type: 'text/csv' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `status_export_${Date.now()}.csv`;
    a.click(); URL.revokeObjectURL(a.href);
    toast('CSV exported', 'success');
  }
  $('btnExportCSV')?.addEventListener('click', exportCSV);
  $('btnExportCSVFull')?.addEventListener('click', exportCSV);

  function renderTimeline() {
    const container = $('timelineContainer');
    if (!container) return;
    if (!state.entries.length) {
      container.innerHTML = `<div class="timeline-empty">
        <svg viewBox="0 0 24 24" width="48" height="48" fill="none" stroke="rgba(255,255,255,0.15)" stroke-width="1.5">
          <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
        </svg><p>No events yet</p></div>`;
      return;
    }
    const sorted = [...state.entries].reverse().slice(0, 50);
    container.innerHTML = sorted.map(e => `<div class="timeline-event ${e.status}">
      <div class="timeline-event-time">${escapeHtml(e.timestamp)}</div>
      <div class="timeline-event-text"><strong>[${e.status.toUpperCase()}]</strong>
        ${escapeHtml(e.project)} <span style="color:var(--indra-light)">— ${escapeHtml(e.source)}</span></div>
    </div>`).join('');
  }

  $('globalSearch')?.addEventListener('input', function () {
    const q = this.value.toLowerCase();
    if (!q) return;
    if (state.entries.length) {
      switchView('Table');
      $('tableSearchFull').value = q;
      state.page = 1;
      renderTable($('statusTableBodyFull'), $('tableInfoFull'), $('tablePaginationFull'),
                  $('tableSearchFull'), $('tableStatusFilterFull'));
    }
  });

  // ─── STATUS CHART (Canvas 2D, preserved) ──────────────────────────────
  const chartCanvas = $('statusChart');
  const chartCtx = chartCanvas ? chartCanvas.getContext('2d') : null;
  function resizeChart() {
    if (!chartCanvas) return;
    chartCanvas.width = chartCanvas.parentElement.offsetWidth;
    chartCanvas.height = chartCanvas.parentElement.offsetHeight;
    drawChart();
  }
  function drawChart() {
    if (!chartCtx) return;
    const w = chartCanvas.width, h = chartCanvas.height;
    const padL = 48, padR = 20, padT = 20, padB = 40;
    const cw = w - padL - padR, ch = h - padT - padB;
    chartCtx.clearRect(0, 0, w, h);
    const fileNames = [...new Set(state.entries.map(e => e.source))];
    if (!fileNames.length) {
      chartCtx.fillStyle = 'rgba(255,255,255,0.15)';
      chartCtx.font = '14px Inter';
      chartCtx.textAlign = 'center';
      chartCtx.fillText('Upload files to see status distribution', w / 2, h / 2);
      return;
    }
    const fileData = fileNames.map(name => {
      const items = state.entries.filter(e => e.source === name);
      return {
        name: name.length > 12 ? name.slice(0, 10) + '…' : name,
        ok: items.filter(e => e.status === 'ok').length,
        warn: items.filter(e => e.status === 'warning').length,
        err: items.filter(e => e.status === 'error').length,
        info: items.filter(e => e.status === 'info').length,
        total: items.length
      };
    });
    const maxVal = Math.max(...fileData.map(d => d.total)) * 1.2 || 10;
    chartCtx.strokeStyle = 'rgba(179,193,218,0.08)';
    chartCtx.lineWidth = 1;
    for (let i = 0; i <= 5; i++) {
      const y = padT + (ch / 5) * i;
      chartCtx.beginPath(); chartCtx.moveTo(padL, y); chartCtx.lineTo(w - padR, y); chartCtx.stroke();
      chartCtx.fillStyle = '#7A9CAE'; chartCtx.font = '10px Inter'; chartCtx.textAlign = 'right';
      chartCtx.fillText(Math.round(maxVal - (maxVal / 5) * i), padL - 8, y + 4);
    }
    const barW = Math.min(60, (cw / fileData.length) * 0.6);
    const gap = cw / fileData.length;
    const colors = { ok: '#27AE60', warn: '#FF9800', err: '#E91E63', info: '#00B0BD' };
    fileData.forEach((d, i) => {
      const x = padL + gap * i + (gap - barW) / 2;
      let y = padT + ch;
      const segments = [
        { val: d.ok, color: colors.ok },
        { val: d.warn, color: colors.warn },
        { val: d.err, color: colors.err },
        { val: d.info, color: colors.info }
      ];
      segments.forEach(seg => {
        const segH = (seg.val / maxVal) * ch;
        if (segH > 0) {
          y -= segH;
          chartCtx.fillStyle = seg.color;
          chartCtx.globalAlpha = 0.8;
          chartCtx.beginPath();
          if (chartCtx.roundRect) chartCtx.roundRect(x, y, barW, segH, [3, 3, 0, 0]);
          else chartCtx.rect(x, y, barW, segH);
          chartCtx.fill();
          chartCtx.globalAlpha = 1;
        }
      });
      chartCtx.fillStyle = '#7A9CAE'; chartCtx.font = '10px Inter'; chartCtx.textAlign = 'center';
      chartCtx.fillText(d.name, padL + gap * i + gap / 2, h - 8);
    });
    if (fileData.length > 1) {
      chartCtx.beginPath();
      fileData.forEach((d, i) => {
        const x = padL + gap * i + gap / 2;
        const y = padT + ch - (d.total / maxVal) * ch;
        if (i === 0) chartCtx.moveTo(x, y);
        else {
          const px = padL + gap * (i - 1) + gap / 2;
          const py = padT + ch - (fileData[i - 1].total / maxVal) * ch;
          const cpx = (px + x) / 2;
          chartCtx.bezierCurveTo(cpx, py, cpx, y, x, y);
        }
      });
      chartCtx.strokeStyle = '#00B0BD'; chartCtx.lineWidth = 2; chartCtx.stroke();
      fileData.forEach((d, i) => {
        const x = padL + gap * i + gap / 2;
        const y = padT + ch - (d.total / maxVal) * ch;
        chartCtx.beginPath(); chartCtx.arc(x, y, 3.5, 0, Math.PI * 2);
        chartCtx.fillStyle = '#00B0BD'; chartCtx.fill();
        chartCtx.strokeStyle = '#002B3A'; chartCtx.lineWidth = 2; chartCtx.stroke();
      });
    }
  }
  window.addEventListener('resize', resizeChart);
  setTimeout(resizeChart, 100);

  // ╔══════════════════════════════════════════════════════════════════════╗
  // ║                EXECUTIVE DOCUMENT MODE  (NEW)                       ║
  // ╚══════════════════════════════════════════════════════════════════════╝

  // Public entry: turn raw markdown into a doc record and render it.
  function ingestExecutiveDoc(rawText, fileName) {
    const id = `doc-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    const originalRaw = rawText;
    // ── Aplica edições locais salvas (modo edição) se existirem ──
    const savedEdit = getDocEdit(fileName);
    let edited = false;
    if (savedEdit !== undefined && savedEdit !== originalRaw) {
      rawText = savedEdit;
      edited = true;
    }
    const meta = extractMetadata(rawText);
    const summary = computeDocSummary(rawText);
    const { html, toc, title, tagline, contentText } = renderMarkdown(rawText);

    const doc = { id, name: fileName, raw: rawText, originalRaw, html, toc, meta, summary, title, tagline, contentText };

    // replace if same name exists
    const existingIdx = state.docs.findIndex(d => d.name === fileName);
    if (existingIdx !== -1) state.docs[existingIdx] = doc;
    else state.docs.push(doc);

    state.activeDocId = id;
    renderDocTabs();
    renderActiveDoc();
    switchView('Document');
    if (edited) {
      setTimeout(() => toast(`"${fileName}" carregado com edições locais salvas`, 'info'), 250);
    }
  }

  // ─── 1) Metadata extractor ────────────────────────────────────────────
  function extractMetadata(text) {
    const meta = {};
    // YAML frontmatter (if any)
    const fm = text.match(/^---\n([\s\S]*?)\n---/);
    if (fm) {
      fm[1].split('\n').forEach(line => {
        const m = line.match(/^([A-Za-zÀ-ú\u00C0-\u017F][\w\s\-]*):\s*(.+?)\s*$/);
        if (m) meta[m[1].trim().toLowerCase()] = m[2].replace(/^["']|["']$/g, '').trim();
      });
    }
    // Indra-style spec metadata: `> **Versão:** 1.0`
    const specMatches = text.match(/^>\s*\*\*([^*:]+):\*\*\s*([^\n]+)/gm) || [];
    specMatches.forEach(line => {
      const m = line.match(/^>\s*\*\*([^*:]+):\*\*\s*([^\n]+)/);
      if (m) meta[m[1].trim().toLowerCase()] = m[2].trim();
    });
    return meta;
  }

  // ─── 2) Doc summary (auto-KPIs) ───────────────────────────────────────
  function computeDocSummary(text) {
    // Strip code blocks for accurate counts of headings
    const noCode = text.replace(/```[\s\S]*?```/g, '');
    const sections = (noCode.match(/^##\s+/gm) || []).length;
    const subs = (noCode.match(/^###\s+/gm) || []).length;
    const tableLines = (noCode.match(/^\s*\|[-:|\s]+\|\s*$/gm) || []).length; // separator lines = #tables
    const diagramBlocks = (text.match(/```[a-z]*\n[\s\S]*?[┌┐└┘─│├┤┬┴┼▶▲▼◀]/g) || []).length;
    const schemaBlocks = (text.match(/```json[\s\S]*?\$schema[\s\S]*?```/g) || []).length;
    const yamlBlocks   = (text.match(/```ya?ml[\s\S]*?```/g) || []).length;
    const farois = ((text.match(/[🟢🟡🔴⚪]/gu) || []).length);
    const wordCount = noCode.replace(/[#>*_`\-]/g, ' ').split(/\s+/).filter(Boolean).length;
    const readingMin = Math.max(1, Math.round(wordCount / 220));
    return { sections, subs, tables: tableLines, diagrams: diagramBlocks,
             schemas: schemaBlocks, yamls: yamlBlocks, farois, words: wordCount, readingMin };
  }

  // ─── 3) Markdown → HTML pipeline ──────────────────────────────────────
  // Uses marked.js if available (CDN), else a minimal fallback parser.
  function renderMarkdown(rawText) {
    const tocItems = [];
    let firstH1 = null;
    let taglineLines = [];

    // Detect tagline = first blockquote right after H1, before any H2
    const taglineMatch = rawText.match(/^#\s+([^\n]+)\n+((?:>[^\n]*\n)+)/m);
    let tagline = '';
    if (taglineMatch) {
      // First > line of the blockquote, stripped of bold/italic markers
      const blockquote = taglineMatch[2].split('\n').filter(l => l.startsWith('>')).map(l => l.replace(/^>\s?/, ''));
      // Skip if it's pure metadata (key:value lines starting with **Foo:** )
      const firstNonMeta = blockquote.find(l =>
        l.trim() && !/^\*\*[^*]+:\*\*/.test(l.trim())
      );
      tagline = (firstNonMeta || '').replace(/\*\*/g, '').trim();
    }

    let html = '';
    if (window.marked && window.DOMPurify) {
      html = renderWithMarked(rawText, tocItems, ref => firstH1 = ref);
    } else {
      // Defer once to give CDN scripts a chance
      html = renderFallback(rawText, tocItems, ref => firstH1 = ref);
      // Try again after a short delay if libs are still loading
      if (!window.marked) {
        setTimeout(() => {
          if (window.marked && window.DOMPurify && state.activeDocId) {
            renderActiveDoc(true); // re-render with marked when ready
          }
        }, 700);
      }
    }

    const title = firstH1 || 'Documento';
    return { html, toc: tocItems, title, tagline, contentText: rawText };
  }

  function renderWithMarked(rawText, tocItems, onH1) {
    const renderer = new marked.Renderer();
    let h2Idx = 0, h3Idx = 0;

    renderer.heading = function (text, level, raw) {
      // marked v12 calls renderer.heading({ text, depth, raw, tokens }) — handle both
      let textVal, depth, rawVal;
      if (typeof text === 'object' && text !== null) {
        textVal = text.text;
        depth = text.depth;
        rawVal = text.raw || text.text;
      } else {
        textVal = text; depth = level; rawVal = raw || text;
      }
      const cleanText = stripInlineMd(textVal);
      const slug = slugify(cleanText) + '-' + (depth === 2 ? `h2-${++h2Idx}` : depth === 3 ? `h3-${++h3Idx}` : `h${depth}`);
      if (depth === 1) {
        if (onH1) onH1(cleanText);
        return `<h1 id="${slug}" class="exec-content-h1-suppressed">${textVal}</h1>`;
      }
      if (depth === 2 || depth === 3) tocItems.push({ depth, text: cleanText, slug });
      return `<h${depth} id="${slug}">${textVal}</h${depth}>`;
    };

    renderer.code = function (codeOrToken, info) {
      let code, lang;
      if (typeof codeOrToken === 'object' && codeOrToken !== null) {
        code = codeOrToken.text || ''; lang = (codeOrToken.lang || '').trim();
      } else { code = codeOrToken; lang = (info || '').trim(); }
      return renderCodeBlock(code, lang);
    };

    renderer.table = function (tokenOrHeader, body) {
      // marked v12 → token object; older → (header, body) strings
      let headerHtml, bodyHtml;
      if (typeof tokenOrHeader === 'object' && tokenOrHeader !== null && Array.isArray(tokenOrHeader.header)) {
        headerHtml = '<tr>' + tokenOrHeader.header.map(c => `<th>${marked.parseInline(c.text || '')}</th>`).join('') + '</tr>';
        bodyHtml = tokenOrHeader.rows.map(row =>
          '<tr>' + row.map(c => `<td>${transformCell(marked.parseInline(c.text || ''))}</td>`).join('') + '</tr>'
        ).join('');
      } else {
        headerHtml = tokenOrHeader || '';
        bodyHtml = (body || '').replace(/<td>([\s\S]*?)<\/td>/g, (m, inner) => `<td>${transformCell(inner)}</td>`);
      }
      return `<div class="table-wrap"><div class="table-wrap-scroll"><table>
        <thead>${headerHtml}</thead><tbody>${bodyHtml}</tbody></table></div></div>`;
    };

    renderer.blockquote = function (quoteOrToken) {
      const inner = typeof quoteOrToken === 'object' && quoteOrToken.tokens
        ? marked.parser(quoteOrToken.tokens)
        : (quoteOrToken || '');
      return decorateBlockquote(inner);
    };

    renderer.link = function (hrefOrToken, title, text) {
      let href, t, txt;
      if (typeof hrefOrToken === 'object' && hrefOrToken !== null) {
        href = hrefOrToken.href; t = hrefOrToken.title; txt = marked.parseInline(hrefOrToken.text || '');
      } else { href = hrefOrToken; t = title; txt = text; }
      const isExternal = /^https?:\/\//i.test(href);
      const target = isExternal ? ' target="_blank" rel="noopener"' : '';
      return `<a href="${href}"${target}${t ? ` title="${escapeHtml(t)}"` : ''}>${txt}</a>`;
    };

    try {
      marked.use({
        gfm: true, breaks: false,
        renderer,
        ...(window.hljs ? {
          highlight(code, lang) {
            try {
              if (lang && hljs.getLanguage(lang)) return hljs.highlight(code, { language: lang }).value;
              return hljs.highlightAuto(code).value;
            } catch { return code; }
          }
        } : {})
      });
      const dirty = marked.parse(rawText);
      return DOMPurify.sanitize(dirty, {
        ADD_ATTR: ['target', 'rel', 'id', 'class'],
        ADD_TAGS: ['svg', 'path', 'circle', 'rect', 'line']
      });
    } catch (err) {
      console.warn('marked failed, using fallback', err);
      return renderFallback(rawText, tocItems, onH1);
    }
  }

  function transformCell(html) {
    return html
      .replace(/🟢\s*ALTO/gi,           '<span class="farol-pill alto">🟢 ALTO</span>')
      .replace(/🟢\s*M[ÉE]DIO[\s-]*ALTO/gi, '<span class="farol-pill medio-alto">🟢 MED-ALTO</span>')
      .replace(/🟡\s*M[ÉE]DIO[\s-]*ALTO/gi, '<span class="farol-pill medio-alto">🟡 MED-ALTO</span>')
      .replace(/🟡\s*M[ÉE]DIO/gi,       '<span class="farol-pill medio">🟡 MÉDIO</span>')
      .replace(/🔴\s*M[ÉE]DIO[\s-]*BAIXO/gi, '<span class="farol-pill medio-baixo">🔴 MED-BAIXO</span>')
      .replace(/🔴\s*BAIXO/gi,          '<span class="farol-pill baixo">🔴 BAIXO</span>')
      .replace(/⚪\s*BAIXO/gi,          '<span class="farol-pill baixo">⚪ BAIXO</span>');
  }

  function decorateBlockquote(innerHtml) {
    const stripped = (innerHtml || '').replace(/<[^>]+>/g, ' ').trim();
    const head = stripped.slice(0, 80);
    let cls = '', icon = '';
    if (/^\*?\*?Especifica[çc][ãa]o/i.test(stripped) || /^Especifica[çc][ãa]o/i.test(stripped)) {
      return `<blockquote class="spec">${innerHtml}</blockquote>`;
    }
    if (/^[⚠]/.test(stripped) || /^WARN(ING)?\b/i.test(head))   { cls = 'warn';    icon = '⚠️'; }
    else if (/^[✅]/.test(stripped) || /^OK\b/i.test(head))      { cls = 'success'; icon = '✅'; }
    else if (/^[❌🚫]/.test(stripped) || /^ERR/i.test(head))      { cls = 'error';   icon = '❌'; }
    else if (/^[📌📖🔍🔥🎯💡ℹ️]/.test(stripped))                  { cls = 'info';    icon = stripped.slice(0, 2).match(/[📌📖🔍🔥🎯💡ℹ️]/)?.[0] || 'ℹ️'; }
    if (cls) {
      return `<blockquote class="callout ${cls}"><span class="callout-icon">${icon}</span><div class="callout-body">${innerHtml}</div></blockquote>`;
    }
    return `<blockquote>${innerHtml}</blockquote>`;
  }

  function renderCodeBlock(code, lang) {
    const langClass = lang ? `language-${lang}` : '';
    const isAscii = /[┌┐└┘─│├┤┬┴┼▶▲▼◀]/.test(code);
    if (isAscii) {
      return `<pre class="diagram"><code>${escapeHtml(code)}</code></pre>`;
    }
    if (lang === 'json' && /\$schema/.test(code)) {
      const id = 'schema-' + Math.random().toString(36).slice(2, 8);
      const highlighted = window.hljs ? hljs.highlight(code, { language: 'json' }).value : escapeHtml(code);
      return `<div class="schema-viewer" id="${id}">
        <div class="schema-viewer-header">
          <span>JSON SCHEMA</span>
          <button class="schema-toggle" onclick="document.getElementById('${id}').classList.toggle('collapsed'); this.textContent = this.textContent === 'EXPAND' ? 'COLLAPSE' : 'EXPAND';">COLLAPSE</button>
        </div>
        <pre><code class="language-json">${highlighted}</code></pre>
      </div>`;
    }
    if (/^ya?ml$/.test(lang || '')) {
      const highlighted = window.hljs ? hljs.highlight(code, { language: 'yaml' }).value : escapeHtml(code);
      return `<pre class="yaml-config"><code class="language-yaml">${highlighted}</code></pre>`;
    }
    const highlighted = window.hljs && lang && hljs.getLanguage(lang)
      ? hljs.highlight(code, { language: lang }).value
      : escapeHtml(code);
    return `<pre><code class="${langClass}">${highlighted}</code></pre>`;
  }

  function stripInlineMd(s) {
    return String(s || '').replace(/\*\*/g, '').replace(/__/g, '').replace(/`/g, '').replace(/<[^>]+>/g, '').trim();
  }
  function slugify(s) {
    return String(s || '').toLowerCase()
      .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .replace(/[^\w\s-]/g, '').trim().replace(/\s+/g, '-').slice(0, 80);
  }

  // ─── Fallback minimal renderer (no CDN) ───────────────────────────────
  // Handles: headings, paragraphs, ul/ol, blockquotes, fenced code, tables, inline code, bold, italic, links.
  function renderFallback(text, tocItems, onH1) {
    const lines = text.split('\n');
    let out = [];
    let i = 0;
    let h2i = 0, h3i = 0;

    const flushPara = (buf) => {
      if (buf.length) {
        const joined = buf.join(' ').trim();
        if (joined) out.push(`<p>${inlineFmt(joined)}</p>`);
        buf.length = 0;
      }
    };

    let para = [];
    while (i < lines.length) {
      const line = lines[i];

      // Fenced code
      if (line.trim().startsWith('```')) {
        flushPara(para);
        const lang = line.trim().slice(3).trim();
        const codeLines = [];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) { codeLines.push(lines[i]); i++; }
        i++; // skip closing ```
        out.push(renderCodeBlock(codeLines.join('\n'), lang));
        continue;
      }
      // Heading
      const h = line.match(/^(#{1,6})\s+(.+)/);
      if (h) {
        flushPara(para);
        const depth = h[1].length;
        const txt = h[2].trim();
        const clean = stripInlineMd(txt);
        const slug = slugify(clean) + '-' + (depth === 2 ? `h2-${++h2i}` : depth === 3 ? `h3-${++h3i}` : `h${depth}`);
        if (depth === 1) { if (onH1) onH1(clean); out.push(`<h1 id="${slug}" class="exec-content-h1-suppressed">${inlineFmt(txt)}</h1>`); }
        else {
          if (depth === 2 || depth === 3) tocItems.push({ depth, text: clean, slug });
          out.push(`<h${depth} id="${slug}">${inlineFmt(txt)}</h${depth}>`);
        }
        i++; continue;
      }
      // HR
      if (/^---+\s*$/.test(line)) {
        flushPara(para);
        out.push('<hr>'); i++; continue;
      }
      // Blockquote
      if (line.startsWith('>')) {
        flushPara(para);
        const qLines = [];
        while (i < lines.length && (lines[i].startsWith('>') || lines[i].trim() === '')) {
          if (lines[i].trim() === '') { i++; continue; }
          qLines.push(lines[i].replace(/^>\s?/, '')); i++;
        }
        const inner = qLines.length === 1 ? `<p>${inlineFmt(qLines[0])}</p>` :
          qLines.map(l => `<p>${inlineFmt(l)}</p>`).join('');
        out.push(decorateBlockquote(inner));
        continue;
      }
      // Table (simple GFM)
      if (line.includes('|') && i + 1 < lines.length && /^\s*\|?\s*[-:]+/.test(lines[i + 1])) {
        flushPara(para);
        const headerCells = line.split('|').map(s => s.trim()).filter(Boolean);
        i += 2;
        const rows = [];
        while (i < lines.length && lines[i].includes('|') && lines[i].trim()) {
          rows.push(lines[i].split('|').map(s => s.trim()).filter((s, idx, arr) => !(idx === 0 && s === '') && !(idx === arr.length - 1 && s === '')));
          i++;
        }
        const thead = '<tr>' + headerCells.map(c => `<th>${inlineFmt(c)}</th>`).join('') + '</tr>';
        const tbody = rows.map(r => '<tr>' + r.map(c => `<td>${transformCell(inlineFmt(c))}</td>`).join('') + '</tr>').join('');
        out.push(`<div class="table-wrap"><div class="table-wrap-scroll"><table><thead>${thead}</thead><tbody>${tbody}</tbody></table></div></div>`);
        continue;
      }
      // List (UL or OL)
      if (/^\s*[-*+]\s+/.test(line) || /^\s*\d+\.\s+/.test(line)) {
        flushPara(para);
        const isOl = /^\s*\d+\.\s+/.test(line);
        const items = [];
        while (i < lines.length && (/^\s*[-*+]\s+/.test(lines[i]) || /^\s*\d+\.\s+/.test(lines[i]) || /^\s{2,}/.test(lines[i]))) {
          if (/^\s*[-*+]\s+/.test(lines[i]) || /^\s*\d+\.\s+/.test(lines[i])) {
            items.push(lines[i].replace(/^\s*[-*+]\s+|\s*\d+\.\s+/, ''));
          } else if (items.length) {
            items[items.length - 1] += ' ' + lines[i].trim();
          }
          i++;
        }
        out.push(`<${isOl ? 'ol' : 'ul'}>${items.map(it => `<li>${inlineFmt(it)}</li>`).join('')}</${isOl ? 'ol' : 'ul'}>`);
        continue;
      }
      // Empty line -> flush paragraph
      if (line.trim() === '') {
        flushPara(para); i++; continue;
      }
      para.push(line);
      i++;
    }
    flushPara(para);
    return out.join('\n');
  }

  function inlineFmt(s) {
    let out = escapeHtml(s);
    // images first
    out = out.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img alt="$1" src="$2">');
    // links
    out = out.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (m, t, u) => {
      const ext = /^https?:\/\//.test(u);
      return `<a href="${u}"${ext ? ' target="_blank" rel="noopener"' : ''}>${t}</a>`;
    });
    // bold + italic
    out = out.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
    out = out.replace(/\*([^*]+)\*/g, '<em>$1</em>');
    out = out.replace(/__([^_]+)__/g, '<strong>$1</strong>');
    out = out.replace(/_([^_]+)_/g, '<em>$1</em>');
    // inline code
    out = out.replace(/`([^`]+)`/g, '<code>$1</code>');
    return out;
  }

  // ─── 4) Render the active doc into the DOM ────────────────────────────
  function renderActiveDoc(forceRerender = false) {
    const doc = state.docs.find(d => d.id === state.activeDocId);
    const empty = $('docEmpty');
    const shell = $('docShell');
    if (!doc) {
      if (empty) empty.style.display = '';
      if (shell) shell.hidden = true;
      return;
    }
    if (empty) empty.style.display = 'none';
    if (shell) shell.hidden = false;

    if (forceRerender) {
      const re = renderMarkdown(doc.raw);
      doc.html = re.html;
      doc.toc = re.toc;
      doc.title = re.title;
      doc.tagline = re.tagline;
    }

    // HERO
    const hero = $('execHero');
    const meta = doc.meta || {};
    const metaPills = [];
    const knownKeys = ['versão','versao','status','audiência','audiencia','confidencialidade','última atualização','ultima atualizacao'];
    Object.entries(meta).forEach(([k, v]) => {
      if (!v) return;
      const isConf = /confidencial/i.test(k);
      metaPills.push(
        `<span class="exec-meta-pill${isConf ? ' confidential' : ''}"><span class="meta-key">${escapeHtml(k)}</span>${escapeHtml(v)}</span>`
      );
    });
    hero.innerHTML = `
      <div class="exec-hero-eyebrow">${escapeHtml(doc.name)}</div>
      <h1 class="exec-hero-title">${escapeHtml(doc.title || 'Documento Executivo')}</h1>
      ${doc.tagline ? `<p class="exec-hero-tagline">${escapeHtml(doc.tagline)}</p>` : ''}
      ${metaPills.length ? `<div class="exec-meta">${metaPills.join('')}</div>` : ''}
    `;

    // KPIs
    const k = doc.summary;
    const kpis = [
      { label: 'Seções', val: k.sections, sub: `${k.subs} subseções` },
      { label: 'Tabelas', val: k.tables, sub: 'tabelas executivas' },
      { label: 'Diagramas', val: k.diagrams, sub: 'arquiteturas ASCII' },
      { label: 'Schemas', val: k.schemas, sub: `${k.yamls} YAML` },
      { label: 'Faróis', val: k.farois, sub: 'sinais 🟢🟡🔴' },
      { label: 'Leitura', val: `${k.readingMin}m`, sub: `${k.words.toLocaleString('pt-BR')} palavras` }
    ];
    $('execKpis').innerHTML = kpis.map(item => `
      <div class="exec-kpi">
        <span class="exec-kpi-label">${item.label}</span>
        <span class="exec-kpi-value">${item.val}</span>
        <span class="exec-kpi-sub">${item.sub}</span>
      </div>`).join('');

    // TOC
    const toc = $('execToc');
    if (doc.toc.length) {
      toc.innerHTML = `<div class="exec-toc-title">Sumário</div>
        <ul>${doc.toc.map(t =>
          `<li class="toc-${t.depth === 2 ? 'h2' : 'h3'}"><a href="#${t.slug}" data-slug="${t.slug}">${escapeHtml(t.text)}</a></li>`
        ).join('')}</ul>`;
      toc.style.display = '';
      toc.querySelectorAll('a').forEach(a => {
        a.addEventListener('click', e => {
          e.preventDefault();
          const target = document.getElementById(a.dataset.slug);
          if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });
      });
    } else {
      toc.innerHTML = '';
      toc.style.display = 'none';
    }

    // CONTENT
    $('execContent').innerHTML = doc.html;

    // Re-highlight code blocks that were inserted via fallback (marked + hljs already handles its own)
    if (window.hljs) {
      $('execContent').querySelectorAll('pre code').forEach(el => {
        try { hljs.highlightElement(el); } catch { /* noop */ }
      });
    }

    // FOOTER
    const editingNow = $('docShell')?.classList.contains('edit-mode');
    const hasLocalEdits = (doc.originalRaw !== undefined) && (doc.raw !== doc.originalRaw);
    $('execFooter').innerHTML = `
      <div class="footer-source">
        📁 ${escapeHtml(doc.name)} · ${(doc.raw.length / 1024).toFixed(1)} KB
        ${hasLocalEdits ? '<span class="footer-edited-badge" title="Há edições locais não exportadas">● editado localmente</span>' : ''}
      </div>
      <div class="footer-actions">
        <button id="btnEditDoc" class="${editingNow ? 'is-active' : ''}">
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right:6px;vertical-align:-2px"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
          ${editingNow ? 'Sair da edição' : 'Editar'}
        </button>
        <button id="btnDownloadMd">Baixar .md</button>
        <button id="btnRestoreDoc" ${hasLocalEdits ? '' : 'disabled'}>Restaurar original</button>
        <button id="btnPrintDoc">Imprimir / PDF</button>
        <button id="btnDownloadHtml">Baixar HTML</button>
        <button id="btnReloadDoc">Recarregar</button>
      </div>`;
    $('btnEditDoc')?.addEventListener('click', toggleDocEditMode);
    $('btnDownloadMd')?.addEventListener('click', downloadCurrentDocAsMd);
    $('btnRestoreDoc')?.addEventListener('click', restoreCurrentDoc);
    $('btnPrintDoc')?.addEventListener('click', () => window.print());
    $('btnDownloadHtml')?.addEventListener('click', () => exportDocHtml(doc));
    $('btnReloadDoc')?.addEventListener('click', () => renderActiveDoc(true));

    requestAnimationFrame(initScrollSpy);
  }

  function exportDocHtml(doc) {
    const blob = new Blob([
      `<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8">
      <title>${escapeHtml(doc.title)} — ${escapeHtml(doc.name)}</title>
      <link rel="stylesheet" href="styles.css"><link rel="stylesheet" href="viewer.css">
      </head><body class="doc-export"><main class="exec-content" style="margin:32px auto;max-width:960px">
      ${doc.html}</main></body></html>`
    ], { type: 'text/html' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = doc.name.replace(/\.md$/i, '') + '.html';
    a.click(); URL.revokeObjectURL(a.href);
    toast('HTML exportado', 'success');
  }

  // ─── 4.5) Document Edit Mode (NEW) ───────────────────────────────────
  // Editor de markdown ao vivo com auto-save em localStorage.
  // Estrutura: { [fileName]: editedRawContent }
  const EDIT_STORAGE_KEY = 'web-md-viewer-doc-edits';

  function loadAllDocEdits() {
    try { return JSON.parse(localStorage.getItem(EDIT_STORAGE_KEY)) || {}; }
    catch { return {}; }
  }
  function getDocEdit(docName) {
    return loadAllDocEdits()[docName];
  }
  function saveDocEdit(docName, content) {
    const all = loadAllDocEdits();
    all[docName] = content;
    try { localStorage.setItem(EDIT_STORAGE_KEY, JSON.stringify(all)); }
    catch (e) { toast('Falha ao salvar edição local: ' + e.message, 'error'); }
  }
  function removeDocEdit(docName) {
    const all = loadAllDocEdits();
    delete all[docName];
    try { localStorage.setItem(EDIT_STORAGE_KEY, JSON.stringify(all)); }
    catch { /* noop */ }
  }

  let docEditDebounceId = null;

  function toggleDocEditMode() {
    const shell = $('docShell');
    if (!shell) return;
    const wasEditing = shell.classList.contains('edit-mode');
    shell.classList.toggle('edit-mode');
    if (!wasEditing) {
      ensureDocEditorPane();
    }
    // Re-render footer to update button label
    renderActiveDoc(false);
  }

  function ensureDocEditorPane() {
    const doc = state.docs.find(d => d.id === state.activeDocId);
    if (!doc) return;
    let pane = document.getElementById('execEditorPane');
    if (pane) {
      // Atualiza textarea com raw atual (caso doc tenha mudado)
      const ta = pane.querySelector('#execEditorTextarea');
      if (ta && ta.value !== doc.raw) ta.value = doc.raw;
      return;
    }

    pane = document.createElement('div');
    pane.id = 'execEditorPane';
    pane.className = 'exec-editor-pane';
    pane.innerHTML = `
      <div class="exec-editor-header">
        <div class="exec-editor-title">
          <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
          Editor de Markdown
        </div>
        <div class="exec-editor-status">Pronto — preview atualiza automaticamente</div>
      </div>
      <textarea class="exec-editor-textarea" id="execEditorTextarea" spellcheck="false" placeholder="Edite o markdown aqui..."></textarea>
    `;
    // Insere acima de .doc-layout
    const layout = document.querySelector('#docShell .doc-layout');
    if (layout && layout.parentElement) {
      layout.parentElement.insertBefore(pane, layout);
    }

    const ta = pane.querySelector('#execEditorTextarea');
    const status = pane.querySelector('.exec-editor-status');
    ta.value = doc.raw;

    ta.addEventListener('input', () => {
      status.textContent = 'Editando...';
      status.classList.remove('saved', 'unchanged');
      clearTimeout(docEditDebounceId);
      docEditDebounceId = setTimeout(() => {
        const liveDoc = state.docs.find(d => d.id === state.activeDocId);
        if (!liveDoc) return;
        const newRaw = ta.value;
        liveDoc.raw = newRaw;
        try {
          liveDoc.summary = computeDocSummary(newRaw);
          liveDoc.meta = extractMetadata(newRaw);
          const re = renderMarkdown(newRaw);
          liveDoc.html = re.html;
          liveDoc.toc = re.toc;
          liveDoc.title = re.title;
          liveDoc.tagline = re.tagline;
        } catch (err) {
          status.textContent = '⚠ Erro ao parsear: ' + err.message;
          return;
        }
        // Atualiza apenas as áreas afetadas (sem recriar editor)
        const content = $('execContent');
        if (content) {
          content.innerHTML = liveDoc.html;
          if (window.hljs) {
            content.querySelectorAll('pre code').forEach(el => {
              try { hljs.highlightElement(el); } catch { /* noop */ }
            });
          }
        }
        // TOC
        const tocEl = $('execToc');
        if (tocEl && liveDoc.toc.length) {
          tocEl.innerHTML = `<div class="exec-toc-title">Sumário</div>
            <ul>${liveDoc.toc.map(t =>
              `<li class="toc-${t.depth === 2 ? 'h2' : 'h3'}"><a href="#${t.slug}" data-slug="${t.slug}">${escapeHtml(t.text)}</a></li>`
            ).join('')}</ul>`;
          tocEl.style.display = '';
          tocEl.querySelectorAll('a').forEach(a => {
            a.addEventListener('click', e => {
              e.preventDefault();
              const target = document.getElementById(a.dataset.slug);
              if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
          });
        }
        // Persistência
        if (liveDoc.originalRaw !== undefined && newRaw === liveDoc.originalRaw) {
          removeDocEdit(liveDoc.name);
          status.textContent = '○ Igual ao original (sem alterações)';
          status.classList.add('unchanged');
        } else {
          saveDocEdit(liveDoc.name, newRaw);
          status.textContent = '✓ Salvo localmente · ' + new Date().toLocaleTimeString('pt-BR');
          status.classList.add('saved');
        }
        // Atualiza footer (KB, badge)
        const editingNow = $('docShell')?.classList.contains('edit-mode');
        const hasLocalEdits = (liveDoc.originalRaw !== undefined) && (liveDoc.raw !== liveDoc.originalRaw);
        const footerSource = $('execFooter')?.querySelector('.footer-source');
        if (footerSource) {
          footerSource.innerHTML = `📁 ${escapeHtml(liveDoc.name)} · ${(liveDoc.raw.length / 1024).toFixed(1)} KB${hasLocalEdits ? '<span class="footer-edited-badge" title="Há edições locais não exportadas">● editado localmente</span>' : ''}`;
        }
        const restoreBtn = $('btnRestoreDoc');
        if (restoreBtn) restoreBtn.disabled = !hasLocalEdits;
        requestAnimationFrame(initScrollSpy);
      }, 320);
    });
  }

  function downloadCurrentDocAsMd() {
    const doc = state.docs.find(d => d.id === state.activeDocId);
    if (!doc) {
      toast('Nenhum documento ativo para baixar', 'warning');
      return;
    }
    const fname = doc.name.endsWith('.md') ? doc.name : doc.name + '.md';
    const blob = new Blob([doc.raw], { type: 'text/markdown;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fname;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(() => URL.revokeObjectURL(url), 250);
    toast(`"${fname}" exportado`, 'success');
  }

  function restoreCurrentDoc() {
    const doc = state.docs.find(d => d.id === state.activeDocId);
    if (!doc) return;
    if (doc.originalRaw === undefined) {
      toast('Sem versão original disponível para restaurar', 'warning');
      return;
    }
    if (doc.raw === doc.originalRaw) {
      toast('Documento já está no estado original', 'info');
      return;
    }
    if (!confirm(`Restaurar "${doc.name}" para o conteúdo original? Edições locais deste documento serão descartadas.`)) return;
    doc.raw = doc.originalRaw;
    removeDocEdit(doc.name);
    doc.summary = computeDocSummary(doc.raw);
    doc.meta = extractMetadata(doc.raw);
    const re = renderMarkdown(doc.raw);
    doc.html = re.html;
    doc.toc = re.toc;
    doc.title = re.title;
    doc.tagline = re.tagline;
    const ta = document.getElementById('execEditorTextarea');
    if (ta) ta.value = doc.raw;
    renderActiveDoc(false);
    toast('Documento restaurado para o original', 'success');
  }

  // ─── 5) Document tabs ─────────────────────────────────────────────────
  function renderDocTabs() {
    const tabs = $('docTabs');
    if (!tabs) return;
    tabs.innerHTML = state.docs.map(d => `
      <div class="doc-tab ${d.id === state.activeDocId ? 'active' : ''}" data-id="${d.id}" role="tab" aria-selected="${d.id === state.activeDocId}">
        <span class="doc-tab-name" title="${escapeHtml(d.name)}">${escapeHtml(d.title || d.name)}</span>
        <button class="doc-tab-close" data-close="${d.id}" aria-label="Fechar">×</button>
      </div>
    `).join('');
    tabs.querySelectorAll('.doc-tab').forEach(el => {
      el.addEventListener('click', e => {
        if (e.target.matches('.doc-tab-close')) return;
        state.activeDocId = el.dataset.id;
        renderDocTabs();
        renderActiveDoc();
      });
    });
    tabs.querySelectorAll('.doc-tab-close').forEach(btn => {
      btn.addEventListener('click', e => {
        e.stopPropagation();
        const id = btn.dataset.close;
        const idx = state.docs.findIndex(d => d.id === id);
        if (idx === -1) return;
        state.docs.splice(idx, 1);
        if (state.activeDocId === id) {
          state.activeDocId = state.docs[idx]?.id || state.docs[idx - 1]?.id || null;
        }
        renderDocTabs();
        renderActiveDoc();
      });
    });
  }

  // ─── 6) Scrollspy ─────────────────────────────────────────────────────
  let scrollSpyObserver = null;
  function initScrollSpy() {
    if (scrollSpyObserver) scrollSpyObserver.disconnect();
    const content = $('execContent');
    const toc = $('execToc');
    if (!content || !toc) return;
    const headings = content.querySelectorAll('h2[id], h3[id]');
    if (!headings.length) return;
    const tocLinks = new Map();
    toc.querySelectorAll('a[data-slug]').forEach(a => tocLinks.set(a.dataset.slug, a));
    scrollSpyObserver = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const slug = entry.target.id;
          tocLinks.forEach(a => a.classList.remove('active'));
          const link = tocLinks.get(slug);
          if (link) link.classList.add('active');
        }
      });
    }, { rootMargin: '-90px 0px -70% 0px', threshold: [0, 1] });
    headings.forEach(h => scrollSpyObserver.observe(h));
  }

  // ─── INIT ─────────────────────────────────────────────────────────────
  switchView('Dashboard');
  addActivity('info', 'MD Viewer initialized · executive mode ready');
  drawChart();
})();
