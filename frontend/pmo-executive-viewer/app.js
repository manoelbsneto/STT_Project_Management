/* =============================================
   PMO Executive Viewer — App Script
   Built on DSS Universal Standard v3.0
   - Hero: Canvas 2D Geodesic Sphere
   - IntersectionObserver scroll reveals
   - Markdown → State-Based C-Level Dashboard Renderer
   - Dynamically Editable Checkboxes, Sorting, and Global Search
   ============================================= */

(function () {
  'use strict';

  const $ = id => document.getElementById(id);
  const fileInput     = $('fileInput'),
        heroSection   = $('heroSection'),
        dashboard     = $('dashboard'),
        dropZone      = $('dropZone'),
        btnDemo       = $('btnDemo'),
        sidebarNav    = $('dynamicNav'),
        topbarTitle   = $('topbarTitle'),
        topbarEyebrow = $('topbarEyebrow'),
        topbarDate    = $('topbarDate'),
        topbarEnv     = $('topbarEnv'),
        topbarGate    = $('topbarGate'),
        kpiRow        = $('kpiRow'),
        dynSections   = $('dynamicSections'),
        footerTs      = $('footerTs'),
        btnNavHome    = $('btnNavHome'),
        heroCanvas    = $('heroCanvas'),
        btnLangToggle = $('btnLangToggle'),
        globalSearch  = $('globalSearch');

  /* ════════════════════════════════════════
     IN-MEMORY STATE MODEL
     ════════════════════════════════════════ */
  const state = {
    rawMarkdown: '',
    meta: { title: '', date: '', env: '', bot: '' },
    sections: [],
    searchQuery: '',
    currentLang: localStorage.getItem('pmo_lang') || 'en'
  };

  /* ════════════════════════════════════════
     INTERNATIONALIZATION (i18n) DICTIONARY
     ════════════════════════════════════════ */
  const i18n = {
    en: {
      hero_eyebrow: "Executive Intelligence Platform · v3.0",
      hero_title: "Transform <span class=\"hero__title--accent\">Status Data</span><br>into Executive Insight",
      hero_desc: "Upload any project .md status file and instantly render a brand-compliant C-level dashboard with real-time KPI extraction, built entirely on the official Indra corporate palette.",
      upload_file: "Upload Status File",
      load_demo: "Load Demo",
      drag_hint: "Drag & drop supported",
      kpi_overview: "KPI Overview",
      passed: "Passed",
      pending: "Pending",
      failed: "Failed",
      completion_rate: "Completion Rate",
      badge_pass: "● Pass",
      badge_pending: "● Pending",
      badge_fail: "● Fail",
      search_placeholder: "Search details...",
      status_report: "Status Report",
      drop_hint: "Drop your .md file here",
      footer_brand: "<span class=\"footer-accent\">Minsait</span> · Indra Group · PMO Executive Intelligence",
      total_items: "Total Items",
      completion: "Completion",
      on_track: "▲ On Track",
      at_risk: "▼ At Risk",
      critical: "▼ Critical",
      clear_search: "Clear Search",
      no_search_matches: "No Search Matches",
      no_search_desc: "No content in any section matches your search term \"<strong>{query}</strong>\".",
      error_title: "Parsing Failed",
      error_desc: "The file could not be parsed. Please check if it is a valid markdown file containing headings (##) and sections.",
      error_retry: "Load Demo Data",
      loading_data: "Loading Status Data...",
      gate_ship: "Ship",
      gate_conditional: "Conditional",
      gate_noship: "No-Ship",
      section: "Section"
    },
    pt: {
      hero_eyebrow: "Plataforma de Inteligência Executiva · v3.0",
      hero_title: "Transforme <span class=\"hero__title--accent\">Dados de Status</span><br>em Insight Executivo",
      hero_desc: "Faça upload de qualquer arquivo .md de status do projeto e renderize instantaneamente um painel de nível executivo em conformidade com a marca, com extração de KPI em tempo real, construído inteiramente na paleta corporativa oficial da Indra.",
      upload_file: "Carregar Arquivo",
      load_demo: "Carregar Demo",
      drag_hint: "Suporte para arrastar e soltar",
      kpi_overview: "Visão Geral de KPIs",
      passed: "Aprovados",
      pending: "Pendentes",
      failed: "Falhos",
      completion_rate: "Taxa de Conclusão",
      badge_pass: "● Sucesso",
      badge_pending: "● Pendente",
      badge_fail: "● Falha",
      search_placeholder: "Pesquisar detalhes...",
      status_report: "Relatório de Status",
      drop_hint: "Solte seu arquivo .md aqui",
      footer_brand: "<span class=\"footer-accent\">Minsait</span> · Grupo Indra · Inteligência Executiva de PMO",
      total_items: "Total de Itens",
      completion: "Conclusão",
      on_track: "▲ No Prazo",
      at_risk: "▼ Em Risco",
      critical: "▼ Crítico",
      clear_search: "Limpar Busca",
      no_search_matches: "Nenhum Resultado",
      no_search_desc: "Nenhum conteúdo em qualquer seção corresponde ao termo de busca \"<strong>{query}</strong>\".",
      error_title: "Falha na Leitura",
      error_desc: "O arquivo não pôde ser processado. Verifique se é um arquivo markdown válido contendo títulos (##) e seções.",
      error_retry: "Carregar Dados Demo",
      loading_data: "Carregando Dados de Status...",
      gate_ship: "Liberar",
      gate_conditional: "Condicional",
      gate_noship: "Bloquear",
      section: "Seção"
    }
  };

  function translatePage() {
    const lang = state.currentLang;
    const dict = i18n[lang] || i18n.en;

    const btnLangText = btnLangToggle?.querySelector('.lang-text');
    if (btnLangText) {
      btnLangText.textContent = lang.toUpperCase();
    }

    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.dataset.i18n;
      if (dict[key]) {
        el.innerHTML = dict[key];
      }
    });

    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
      const key = el.dataset.i18nPlaceholder;
      if (dict[key]) {
        el.setAttribute('placeholder', dict[key]);
      }
    });
  }

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
    const l = t.toLowerCase().replace(/[*_`]/g, '').trim();
    for (const [k, v] of Object.entries(SM)) if (l.includes(k)) return v;
    return '';
  }

  function detectGate(mdString) {
    const l = mdString.toLowerCase();
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
    const meta = { title: '', date: '', env: '', bot: '' };
    let blockIdCounter = 0;

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
      if (/^## (.+)/.test(ln)) {
        cur = { heading: ln.replace(/^## /, '').trim(), blocks: [] };
        sections.push(cur); continue;
      }
      if (!cur) continue;

      // Table
      if (ln.trim().startsWith('|') && ln.includes('|')) {
        const tl = [ln]; let j = i + 1;
        while (j < lines.length && lines[j].trim().startsWith('|')) { tl.push(lines[j]); j++; }
        if (tl.length >= 2) {
          const parsed = parseTable(tl);
          const statusColIndex = parsed.h.findIndex(col => /status/i.test(col));
          
          const rows = parsed.d.map((cells, rowIndex) => {
            let originalStatus = '';
            let completed = false;
            if (statusColIndex >= 0) {
              originalStatus = cells[statusColIndex] || '';
              const stClass = classify(originalStatus);
              completed = (stClass === 'pass' || stClass === 'done' || stClass === 'completed' || stClass === 'ship' || stClass === 'ready');
            }
            return {
              id: `row-${blockIdCounter}-${rowIndex}`,
              cells: [...cells],
              originalCells: [...cells],
              originalStatus: originalStatus,
              completed: completed
            };
          });

          cur.blocks.push({
            id: `block-${blockIdCounter++}`,
            type: 'table',
            headers: parsed.h,
            rows: rows,
            statusColIndex: statusColIndex,
            sortColumnIndex: null,
            sortAscending: true
          });
          i = j - 1;
          continue;
        }
      }
      // Ordered list or Unordered list
      if (/^\d+\.\s/.test(ln.trim()) || /^[-*]\s/.test(ln.trim())) {
        const items = [];
        let j = i;
        while (j < lines.length && (/^\d+\.\s/.test(lines[j].trim()) || /^[-*]\s/.test(lines[j].trim()))) {
          const text = lines[j].trim().replace(/^\d+\.\s*/, '').replace(/^[-*]\s*/, '');
          let completed = false;
          let cleanText = text;
          let isChecklist = false;
          if (text.startsWith('[ ]')) {
            completed = false;
            cleanText = text.substring(3).trim();
            isChecklist = true;
          } else if (text.startsWith('[x]') || text.startsWith('[X]')) {
            completed = true;
            cleanText = text.substring(3).trim();
            isChecklist = true;
          }
          
          items.push({
            id: `item-${blockIdCounter}-${items.length}`,
            text: cleanText,
            completed: completed,
            isChecklist: isChecklist
          });
          j++;
        }
        
        cur.blocks.push({
          id: `block-${blockIdCounter++}`,
          type: 'list',
          items: items
        });
        i = j - 1;
        continue;
      }
      // Code
      if (ln.trim().startsWith('```')) {
        const cl = []; let j = i + 1;
        while (j < lines.length && !lines[j].trim().startsWith('```')) { cl.push(lines[j]); j++; }
        cur.blocks.push({
          id: `block-${blockIdCounter++}`,
          type: 'code',
          content: cl.join('\n')
        });
        i = j;
        continue;
      }
      if (ln.trim()) {
        cur.blocks.push({
          id: `block-${blockIdCounter++}`,
          type: 'p',
          text: ln.trim()
        });
      }
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

  /* ════════════════════════════════════════
     TEXT RENDER UTILITIES
     ════════════════════════════════════════ */
  function escapeHtml(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function inlineMD(t) {
    return t
      .replace(/`([^`]+)`/g, '<code>$1</code>')
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/\*([^*]+)\*/g, '<em>$1</em>');
  }

  /**
   * highlightHtml — highlight plain text (NOT HTML) search matches.
   * NEVER pass already-escaped HTML here; escape first, then call this.
   * @param {string} text - plain text string (already escaped)
   * @param {string} query - raw query string
   * @returns {string} text with <mark> wrappers around matches
   */
  function highlightHtml(text, query) {
    if (!query) return text;
    // Escape the user's query for use in a regex literal
    const safeQuery = query.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    try {
      const regex = new RegExp(`(${safeQuery})`, 'gi');
      return text.replace(regex, '<mark class="search-highlight">$1</mark>');
    } catch (e) {
      // If the query produces an invalid regex (edge case), return unhighlighted
      return text;
    }
  }

  function pill(t, query) {
    const c = classify(t);
    const clean = t.replace(/[*_`]/g, '').trim();
    const highlighted = highlightHtml(escapeHtml(clean), query);
    return c ? `<span class="pill ${c}">${highlighted}</span>` : highlighted;
  }

  function renderCell(cellText, isStatus, query) {
    if (isStatus) {
      return pill(cellText, query);
    } else {
      const escaped = escapeHtml(cellText);
      const highlighted = highlightHtml(escaped, query);
      return inlineMD(highlighted);
    }
  }

  /* ════════════════════════════════════════
     KPI CALCULATOR FROM CURRENT STATE
     ════════════════════════════════════════ */
  function extractKPIs(sections) {
    const kpis = [];
    let pass = 0, pend = 0, fail = 0, total = 0;
    const dict = i18n[state.currentLang] || i18n.en;
    for (const s of sections) {
      for (const b of s.blocks) {
        if (b.type !== 'table' || b.statusColIndex < 0) continue;
        for (const row of b.rows) {
          total++;
          if (row.completed) {
            pass++;
          } else {
            const st = (row.cells[b.statusColIndex] || '').toLowerCase().replace(/[*_`]/g, '');
            if (st.includes('fail') || st.includes('noship') || st.includes('error')) {
              fail++;
            } else {
              pend++;
            }
          }
        }
      }
    }
    if (total > 0) {
      kpis.push({ l: dict.total_items, v: total, c: 'c' });
      kpis.push({ l: dict.passed,      v: pass,  c: 's' });
      kpis.push({ l: dict.pending,     v: pend,  c: pend ? 'w' : 's' });
      kpis.push({ l: dict.failed,      v: fail,  c: fail ? 'e' : 's' });
      const pct = Math.round((pass / total) * 100);
      kpis.push({ l: dict.completion, v: pct + '%', c: pct >= 80 ? 's' : pct >= 50 ? 'w' : 'e' });
    }
    return kpis;
  }

  /* ════════════════════════════════════════
     SEARCH FILTERING CRITERIA
     ════════════════════════════════════════ */
  function hasVisibleContent(sec, query) {
    if (!query) return true;
    const q = query.toLowerCase();
    
    if (sec.heading.toLowerCase().includes(q)) return true;

    for (const b of sec.blocks) {
      if (b.type === 'table') {
        if (b.headers.some(h => h.toLowerCase().includes(q))) return true;
        if (b.rows.some(r => r.cells.some(c => c.toLowerCase().includes(q)))) return true;
      } else if (b.type === 'list') {
        if (b.items.some(item => item.text.toLowerCase().includes(q))) return true;
      } else if (b.type === 'code') {
        if (b.content.toLowerCase().includes(q)) return true;
      } else if (b.type === 'p') {
        if (b.text.toLowerCase().includes(q)) return true;
      }
    }
    return false;
  }

  /* ════════════════════════════════════════
     INTERACTIVE COMPONENT ACTIONS (Toggles/Sorts)
     ════════════════════════════════════════ */
  function toggleRowCheckbox(rowId, blockId, sectionIndex, checked) {
    const sec = state.sections[sectionIndex];
    if (!sec) return;
    const block = sec.blocks.find(b => b.id === blockId);
    if (!block || block.type !== 'table') return;
    const row = block.rows.find(r => r.id === rowId);
    if (!row) return;

    row.completed = checked;
    if (block.statusColIndex >= 0) {
      if (checked) {
        row.cells[block.statusColIndex] = 'PASS';
      } else {
        const origClass = classify(row.originalStatus);
        const origIsPass = (origClass === 'pass' || origClass === 'done' || origClass === 'completed' || origClass === 'ship' || origClass === 'ready');
        row.cells[block.statusColIndex] = origIsPass ? 'PENDING' : row.originalStatus;
      }
    }
    
    renderDashboard(false);
    pulseKPIs();
  }

  function toggleSelectAll(blockId, sectionIndex, checked) {
    const sec = state.sections[sectionIndex];
    if (!sec) return;
    const block = sec.blocks.find(b => b.id === blockId);
    if (!block || block.type !== 'table') return;

    const query = state.searchQuery.toLowerCase();

    block.rows.forEach(row => {
      // If a search query is active, only toggle rows that match the query
      const matches = !query || 
                      block.headers.some(hdr => hdr.toLowerCase().includes(query)) ||
                      row.cells.some(cell => cell.toLowerCase().includes(query));
      
      if (matches) {
        row.completed = checked;
        if (block.statusColIndex >= 0) {
          if (checked) {
            row.cells[block.statusColIndex] = 'PASS';
          } else {
            const origClass = classify(row.originalStatus);
            const origIsPass = (origClass === 'pass' || origClass === 'done' || origClass === 'completed' || origClass === 'ship' || origClass === 'ready');
            row.cells[block.statusColIndex] = origIsPass ? 'PENDING' : row.originalStatus;
          }
        }
      }
    });
    
    renderDashboard(false);
    pulseKPIs();
  }

  function toggleListCheckbox(itemId, blockId, sectionIndex, checked) {
    const sec = state.sections[sectionIndex];
    if (!sec) return;
    const block = sec.blocks.find(b => b.id === blockId);
    if (!block || block.type !== 'list') return;
    const item = block.items.find(i => i.id === itemId);
    if (!item) return;

    item.completed = checked;
    renderDashboard(false);
    pulseKPIs();
  }

  function sortTable(blockId, sectionIndex, columnIndex) {
    const sec = state.sections[sectionIndex];
    if (!sec) return;
    const block = sec.blocks.find(b => b.id === blockId);
    if (!block || block.type !== 'table') return;

    if (block.sortColumnIndex === columnIndex) {
      block.sortAscending = !block.sortAscending;
    } else {
      block.sortColumnIndex = columnIndex;
      block.sortAscending = true;
    }

    const dir = block.sortAscending ? 1 : -1;

    block.rows.sort((rowA, rowB) => {
      let valA = rowA.cells[columnIndex] || '';
      let valB = rowB.cells[columnIndex] || '';

      const numA = parseFloat(valA.replace(/[^\d.-]/g, ''));
      const numB = parseFloat(valB.replace(/[^\d.-]/g, ''));
      if (!isNaN(numA) && !isNaN(numB)) {
        return (numA - numB) * dir;
      }

      return valA.localeCompare(valB, undefined, { numeric: true, sensitivity: 'base' }) * dir;
    });

    renderDashboard(false);
  }

    // ── KPI Pulse Animation ──
  function pulseKPIs() {
    const cards = kpiRow.querySelectorAll('.kpi-card');
    cards.forEach(card => {
      card.classList.add('kpi-card--pulse');
      card.addEventListener('animationend', () => {
        card.classList.remove('kpi-card--pulse');
      }, { once: true });
    });
  }

  // ── Skeleton Loader (Accessible, i18n-ready) ──
  function showSkeleton() {
    heroSection.style.display = 'none';
    dashboard.style.display = 'block';
    $('kpiSection').style.display = 'none';
    
    const dict = i18n[state.currentLang] || i18n.en;
    topbarTitle.textContent = dict.loading_data || 'Loading...';
    topbarEyebrow.textContent = '...';
    topbarDate.querySelector('span').textContent = '—';
    topbarEnv.querySelector('span').textContent = '—';
    topbarGate.innerHTML = '';
    
    dynSections.innerHTML = `
      <div class="skeleton-container" role="status" aria-live="polite" aria-busy="true" aria-label="${dict.loading_data || 'Loading status data'}">
        <div class="skeleton-card">
          <div class="skeleton-bar skeleton-bar--title" aria-hidden="true"></div>
          <div class="skeleton-bar skeleton-bar--line" aria-hidden="true"></div>
          <div class="skeleton-bar skeleton-bar--line" aria-hidden="true"></div>
          <div class="skeleton-bar skeleton-bar--short" aria-hidden="true"></div>
        </div>
        <div class="skeleton-card">
          <div class="skeleton-bar skeleton-bar--title" aria-hidden="true"></div>
          <div class="skeleton-bar skeleton-bar--line" aria-hidden="true"></div>
          <div class="skeleton-bar skeleton-bar--line" aria-hidden="true"></div>
          <div class="skeleton-bar skeleton-bar--short" aria-hidden="true"></div>
        </div>
      </div>
    `;
  }

  function showErrorState(msg) {
    heroSection.style.display = 'none';
    dashboard.style.display = 'block';
    $('kpiSection').style.display = 'none';
    
    const dict = i18n[state.currentLang] || i18n.en;
    topbarTitle.textContent = dict.error_title;
    topbarEyebrow.textContent = 'ERROR';
    topbarDate.querySelector('span').textContent = '—';
    topbarEnv.querySelector('span').textContent = '—';
    topbarGate.innerHTML = '';
    
    dynSections.innerHTML = `
      <div class="error-alert-box">
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
          <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
        </svg>
        <h3>${dict.error_title}</h3>
        <p>${msg || dict.error_desc}</p>
        <button class="btn btn-secondary" id="btnErrorRetry" type="button">${dict.error_retry}</button>
      </div>
    `;
    
    const retryBtn = $('btnErrorRetry');
    if (retryBtn) {
      retryBtn.addEventListener('click', () => {
        btnDemo.click();
      });
    }
  }

  /*
     RENDER DASHBOARD
     Refactored to use Event Delegation for all interactions.
  */
  function renderDashboard(resetScroll = true) {
    const { meta, sections } = state;
    const query = state.searchQuery;
    const gate = detectGate(JSON.stringify(sections));
    const dict = i18n[state.currentLang] || i18n.en;

    /* ── Topbar ── */
    topbarTitle.textContent = meta.title || dict.status_report;
    topbarEyebrow.textContent = (meta.bot || 'PMO STATUS REPORT').toUpperCase();
    topbarDate.querySelector('span').textContent = meta.date || new Date().toISOString().slice(0, 10);
    topbarEnv.querySelector('span').textContent = meta.env ? meta.env.split('(')[0].trim() : '—';

    const gm = {
      noship:      { l: dict.gate_noship,      c: 'noship' },
      conditional: { l: dict.gate_conditional,  c: 'conditional' },
      ship:        { l: dict.gate_ship,         c: 'ship' }
    };
    const g = gm[gate] || gm.noship;
    topbarGate.innerHTML = `<span class="gate-pill ${g.c}">${g.l}</span>`;

    /* ── Sidebar colour sync ── */
    const logo = document.querySelector('.sidebar__logo');
    if (logo) {
      logo.style.background =
        gate === 'ship' ? 'var(--indra-success)' :
        gate === 'conditional' ? 'var(--indra-warning)' :
        'var(--indra-error)';
      logo.style.color = 'var(--indra-white)';
      logo.style.transition = 'background var(--duration-normal) var(--ease-out)';
    }

    /* ── KPI recalculation ── */
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
        let changeHtml = '';
        if (k.l === dict.completion) {
          if (k.c === 's') changeHtml = `<div class="kpi-change up">${dict.on_track}</div>`;
          else if (k.c === 'w') changeHtml = `<div class="kpi-change down">${dict.at_risk}</div>`;
          else changeHtml = `<div class="kpi-change down">${dict.critical}</div>`;
        }
        d.innerHTML = `
          <div class="kpi-label">${k.l}</div>
          <div class="kpi-val ${k.c}">${k.v}</div>
          ${changeHtml}
        `;
        kpiRow.appendChild(d);
      });
    }

    /* ── Sidebar nav buttons ── */
    sidebarNav.innerHTML = '';
    let visibleSectionCount = 0;
    sections.forEach((sec, idx) => {
      if (!hasVisibleContent(sec, query)) return;
      const btn = document.createElement('button');
      btn.className = 'sidebar-btn';
      btn.type = 'button';
      btn.title = sec.heading;
      btn.dataset.target = 'sec-' + idx;
      btn.innerHTML = `
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="3" width="18" height="18" rx="0"/>
          <path d="M3 9h18"/>
        </svg>
      `;
      btn.addEventListener('click', () => {
        document.getElementById('sec-' + idx)?.scrollIntoView({ behavior: 'smooth' });
        document.querySelectorAll('.sidebar-btn').forEach(b => b.classList.remove('sidebar-btn--active'));
        btn.classList.add('sidebar-btn--active');
      });
      sidebarNav.appendChild(btn);
      visibleSectionCount++;
    });

    /* ── Sections ── */
    dynSections.innerHTML = '';
    sections.forEach((sec, idx) => {
      if (!hasVisibleContent(sec, query)) return;

      const el = document.createElement('section');
      el.className = 'exec-section';
      el.id = 'sec-' + idx;
      el.setAttribute('data-animate', '');
      el.style.transitionDelay = (idx * 80) + 'ms';

      let h = `<p class="sec-eyebrow">${dict.section} ${String(idx + 1).padStart(2, '0')}</p>`;
      h += `<h2 class="sec-title">${highlightHtml(escapeHtml(sec.heading), query)}</h2>`;

      for (const b of sec.blocks) {
        if (b.type === 'table') {
          const filteredRows = b.rows.filter(row => {
            if (!query) return true;
            const q = query.toLowerCase();
            if (b.headers.some(hdr => hdr.toLowerCase().includes(q))) return true;
            return row.cells.some(cell => cell.toLowerCase().includes(q));
          });

          if (filteredRows.length === 0) continue;

          const allCompleted = filteredRows.length > 0 && filteredRows.every(r => r.completed);

          let tblHtml = `<div class="table-wrap">
            <table class="data-table" data-block-id="${b.id}">
              <thead>
                <tr>
                  <th style="width: 40px;">
                    <input type="checkbox" class="tbl-check select-all" data-block-id="${b.id}" ${allCompleted ? 'checked' : ''} aria-label="Select all rows">
                  </th>`;
          
          b.headers.forEach((hdr, ci) => {
            let sortIndicator = '';
            if (b.sortColumnIndex === ci) {
              sortIndicator = `<span class="sort-indicator">${b.sortAscending ? '▲' : '▼'}</span>`;
            }
            tblHtml += `<th class="sort-header" data-column-index="${ci}">${highlightHtml(escapeHtml(hdr), query)}${sortIndicator}</th>`;
          });

          tblHtml += `</tr></thead><tbody>`;

          filteredRows.forEach(row => {
            tblHtml += `<tr class="${row.completed ? 'completed-row' : ''}">
              <td>
                <input type="checkbox" class="tbl-check row-check" data-row-id="${row.id}" ${row.completed ? 'checked' : ''} aria-label="Select row">
              </td>`;
            row.cells.forEach((cell, ci) => {
              tblHtml += `<td>${renderCell(cell, ci === b.statusColIndex, query)}</td>`;
            });
            for (let p = row.cells.length; p < b.headers.length; p++) {
              tblHtml += '<td></td>';
            }
            tblHtml += '</tr>';
          });

          tblHtml += `</tbody></table></div>`;
          h += tblHtml;

        } else if (b.type === 'list') {
          const filteredItems = b.items.filter(item => {
            if (!query) return true;
            return item.text.toLowerCase().includes(query.toLowerCase());
          });

          if (filteredItems.length === 0) continue;

          h += `<ol class="exec-list" data-block-id="${b.id}">`;
          filteredItems.forEach(item => {
            h += `<li class="has-checkbox ${item.completed ? 'completed-item' : ''}">
              <input type="checkbox" class="list-check" data-item-id="${item.id}" ${item.completed ? 'checked' : ''} aria-label="Toggle completed">
              <span>${highlightHtml(inlineMD(escapeHtml(item.text)), query)}</span>
            </li>`;
          });
          h += '</ol>';

        } else if (b.type === 'code') {
          if (query && !b.content.toLowerCase().includes(query.toLowerCase())) continue;
          h += `<div class="exec-code">${highlightHtml(escapeHtml(b.content), query)}</div>`;

        } else if (b.type === 'p') {
          if (query && !b.text.toLowerCase().includes(query.toLowerCase())) continue;
          h += `<p class="exec-p">${highlightHtml(inlineMD(escapeHtml(b.text)), query)}</p>`;
        }
      }
      el.innerHTML = h;
      dynSections.appendChild(el);
    });

    /* ── Empty state on search ── */
    if (visibleSectionCount === 0 && query) {
      const emptyCard = document.createElement('div');
      emptyCard.className = 'glass-card';
      emptyCard.style.margin = '48px auto';
      emptyCard.style.maxWidth = '500px';
      emptyCard.style.textAlign = 'center';
      emptyCard.style.padding = '40px 24px';
      
      const descText = dict.no_search_desc.replace('{query}', escapeHtml(query));
      
      emptyCard.innerHTML = `
        <div style="font-size: 40px; color: var(--indra-cyan); margin-bottom: 16px;">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="display: inline-block;">
            <circle cx="11" cy="11" r="8"/><path d="M21 21l-4.35-4.35"/><path d="M8 11h6"/>
          </svg>
        </div>
        <h3 class="text-h3" style="margin-bottom: 8px;">${dict.no_search_matches}</h3>
        <p class="exec-p" style="margin: 0 auto 24px; font-size: 14px; color: var(--indra-light);">
          ${descText}
        </p>
        <button class="btn btn-secondary" id="btnClearSearch" type="button">${dict.clear_search}</button>
      `;
      dynSections.appendChild(emptyCard);
      $('btnClearSearch').addEventListener('click', () => {
        if (globalSearch) {
          globalSearch.value = '';
        }
        state.searchQuery = '';
        renderDashboard(false);
      });
    }

    const locale = state.currentLang === 'pt' ? 'pt-BR' : 'en-US';
    const prefix = state.currentLang === 'pt' ? 'Renderizado em ' : 'Rendered ';
    footerTs.textContent = prefix + new Date().toLocaleString(locale);

    heroSection.style.display = 'none';
    dashboard.style.display = 'block';
    if (resetScroll) {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    observeAnimated(dashboard);
    // Event Delegation: ONE listener on dynSections replaces per-element listeners
    // bindEvents removed; delegation attached to dynSections
  }

  /* ════════════════════════════════════════
     DATA LOAD AND LOADER BRIDGE
     ════════════════════════════════════════ */
  function loadAndRenderMD(mdText) {
    showSkeleton();
    
    setTimeout(() => {
      try {
        if (!mdText || !mdText.trim()) {
          throw new Error('Empty status file.');
        }
        
        const parsed = parseMD(mdText);
        
        if (!parsed.meta.title && parsed.sections.length === 0) {
          throw new Error('No valid sections or titles found.');
        }
        
        state.rawMarkdown = mdText;
        state.meta = parsed.meta;
        state.sections = parsed.sections;
        state.searchQuery = '';
        if (globalSearch) {
          globalSearch.value = '';
        }
        renderDashboard(true);
      } catch (err) {
        console.error(err);
        const dict = i18n[state.currentLang] || i18n.en;
        showErrorState(dict.error_desc);
      }
    }, 300); // 300ms simulated transition
  }

  // ════════════════════════════════════════
  //  EVENT DELEGATION — single listener for all dashboard interactions
  // ════════════════════════════════════════
  dynSections.addEventListener('click', (e) => {
    const target = e.target;
    
    // 1. Sort headers click
    const sortHeader = target.closest('.sort-header');
    if (sortHeader) {
      const table = sortHeader.closest('table');
      const secIdx  = parseInt(table.closest('section').id.replace('sec-', ''));
      const blockId = table.dataset.blockId;
      const colIdx  = parseInt(sortHeader.dataset.columnIndex);
      sortTable(blockId, secIdx, colIdx);
      return;
    }

    // 2. "Select All" checkbox in table header
    const selectAll = target.closest('.select-all');
    if (selectAll) {
      const table   = selectAll.closest('table');
      const secIdx  = parseInt(table.closest('section').id.replace('sec-', ''));
      const blockId = selectAll.dataset.blockId;
      toggleSelectAll(blockId, secIdx, selectAll.checked);
      return;
    }

    // 3. Individual row checkbox
    const rowCheck = target.closest('.row-check');
    if (rowCheck) {
      const table   = rowCheck.closest('table');
      const secIdx  = parseInt(table.closest('section').id.replace('sec-', ''));
      const blockId = table.dataset.blockId;
      const rowId   = rowCheck.dataset.rowId;
      toggleRowCheckbox(rowId, blockId, secIdx, rowCheck.checked);
      return;
    }

    // 4. List item checkbox
    const listCheck = target.closest('.list-check');
    if (listCheck) {
      const ol      = listCheck.closest('ol');
      const secIdx  = parseInt(ol.closest('section').id.replace('sec-', ''));
      const blockId = ol.dataset.blockId;
      const itemId  = listCheck.dataset.itemId;
      toggleListCheckbox(itemId, blockId, secIdx, listCheck.checked);
      return;
    }
  });

  /* ════════════════════════════════════════
     FILE HANDLING & TRIGGERS
     ════════════════════════════════════════ */
  function handleFile(f) {
    if (!f) return;
    const r = new FileReader();
    r.onload = e => { loadAndRenderMD(e.target.result); };
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

  // Global search input listener
  if (globalSearch) {
    globalSearch.addEventListener('input', (e) => {
      state.searchQuery = e.target.value.trim();
      renderDashboard(false);
    });
  }

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
     DEMO DATA LOAD
     ════════════════════════════════════════ */
  btnDemo.addEventListener('click', () => {
    loadAndRenderMD(
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
    );
  });

  // Language toggle click
  if (btnLangToggle) {
    btnLangToggle.addEventListener('click', () => {
      state.currentLang = state.currentLang === 'en' ? 'pt' : 'en';
      localStorage.setItem('pmo_lang', state.currentLang);
      translatePage();
      if (state.rawMarkdown) {
        renderDashboard(false);
      }
    });
  }

  // Initial translation on boot
  translatePage();

})();
