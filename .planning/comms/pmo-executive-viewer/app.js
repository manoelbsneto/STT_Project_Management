(function() {
  'use strict';
  const $ = id => document.getElementById(id);

  const App = {
    canvas: $('particleCanvas'),
    ctx: null,
    particles: [],
    
    init() {
      this.ctx = this.canvas.getContext('2d');
      window.addEventListener('resize', () => this.resize());
      this.resize();
      
      this.createParticles();
      this.draw();
      
      // Events
      if($('btnDemo')) $('btnDemo').addEventListener('click', () => this.loadDemo());
      if($('fileInputHero')) $('fileInputHero').addEventListener('change', e => this.handleFile(e.target.files[0]));
      
      $('btnCloseDrawer').addEventListener('click', () => this.closeDrawer());
      $('drawerOverlay').addEventListener('click', () => this.closeDrawer());
    },

    getParticleColor() {
      const style = getComputedStyle(document.documentElement);
      return style.getPropertyValue('--particle-color').trim() || '0, 176, 189';
    },

    resize() {
      this.canvas.width = window.innerWidth;
      this.canvas.height = window.innerHeight;
    },

    createParticles() {
      this.particles = [];
      const count = Math.min(60, Math.floor(window.innerWidth / 20));
      for (let i = 0; i < count; i++) {
        this.particles.push({
          x: Math.random() * this.canvas.width,
          y: Math.random() * this.canvas.height,
          r: Math.random() * 1.5 + 0.5,
          vx: (Math.random() - 0.5) * 0.2,
          vy: (Math.random() - 0.5) * 0.2,
          a: Math.random() * 0.5 + 0.1
        });
      }
    },

    draw() {
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
      const rgb = this.getParticleColor();
      
      for (let p of this.particles) {
        p.x += p.vx; p.y += p.vy;
        if (p.x < 0) p.x = this.canvas.width; if (p.x > this.canvas.width) p.x = 0;
        if (p.y < 0) p.y = this.canvas.height; if (p.y > this.canvas.height) p.y = 0;
        this.ctx.beginPath(); this.ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        this.ctx.fillStyle = `rgba(${rgb},${p.a})`; this.ctx.fill();
      }
      requestAnimationFrame(() => this.draw());
    },

    animateCounter(element, start, end, duration) {
      const startTime = performance.now();
      const endVal = parseFloat(end);
      if(isNaN(endVal)) {
        element.textContent = end;
        return;
      }
      
      const suffixMatch = end.toString().match(/[^0-9.]+$/);
      const suffix = suffixMatch ? suffixMatch[0] : '';

      function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        const current = start + (endVal - start) * eased;
        
        element.textContent = Math.floor(current) + suffix;
        if (progress < 1) requestAnimationFrame(update);
        else element.textContent = end;
      }
      requestAnimationFrame(update);
    },

    navigate(viewId, targetBtn) {
      // Deactivate all navs
      document.querySelectorAll('.nav-link').forEach(b => b.classList.remove('active'));
      if(targetBtn) targetBtn.classList.add('active');
      
      $('heroView').classList.remove('active');
      $('view-overview').classList.add('active');

      if (viewId.startsWith('view-sec-')) {
        const target = $(viewId);
        if(target) {
          window.scrollTo({
            top: target.offsetTop - 80,
            behavior: 'smooth'
          });
        }
      } else {
        window.scrollTo({top:0});
      }
    },

    openDrawer(data) {
      let html = '';
      data.h.forEach((header, i) => {
        const val = data.d[i] || '—';
        const isStatus = /status/i.test(header);
        let displayVal = val;
        if (isStatus) {
          const cat = Parser.classify(val);
          const cName = cat === 'pass' ? 'badge--success' : cat === 'fail' ? 'badge--error' : cat === 'pending' ? 'badge--warning' : 'badge--neutral';
          displayVal = `<span class="badge ${cName}">● ${val.replace(/[*_`]/g, '')}</span>`;
        } else {
          displayVal = Parser.inline(val);
        }
        html += `<div class="detail-item"><div class="detail-label">${header}</div><div class="detail-value text-body">${displayVal}</div></div>`;
      });
      $('drawerBody').innerHTML = html;
      $('drawerOverlay').classList.add('open');
      $('drawer').classList.add('open');
    },

    closeDrawer() {
      $('drawerOverlay').classList.remove('open');
      $('drawer').classList.remove('open');
    },

    handleFile(f) {
      if (!f) return;
      const r = new FileReader();
      r.onload = e => this.render(Parser.parse(e.target.result));
      r.readAsText(f, 'utf-8');
    },

    loadDemo() {
      this.render(Parser.parse(`# PMO 360 Status Report\n\nDate: ${new Date().toISOString().slice(0,10)}\nEnvironment: ColOfertasBrasilPro\n\n## Latest Updates\n\n| Area | Status | Evidence |\n|---|---|---|\n| Solution v1.8 import | COMPLETED | Import report had no critical failures; workflow replacement notices were processed. |\n| v1.9 ConsultarProjeto parser fix | COMPLETED | Topic parser package imported/published; test passed. |\n| v1.10 project lookup normalization | COMPLETED | Flow-side normalization strips tags before SharePoint lookup. |\n| v1.11 audit cleanup | COMPLETED | Removed non-ASCII bot text from package. |\n\n## Gap Status Ordered By Priority\n\n| Priority | Component | Status | Action |\n|---|---|---|---|\n| P0 | DB Migration | PENDING | Awaiting DBA |\n| P1 | Cache Layer | FAIL | Memory leak detected |\n\nStatus: NO-SHIP`));
    },

    render(parsed) {
      const { meta, sections } = parsed;
      
      // Header Updates
      if(meta.title) $('dashSuperTitle').textContent = meta.title;
      $('dashTitle').textContent = meta.title || 'PMO 360 Status Report';
      $('dashDate').innerHTML = `DATE: ${meta.date || new Date().toISOString().slice(0,10)}`;
      $('dashEnv').innerHTML = `ENV: ${meta.env || 'Production'}`;
      
      const gate = Parser.detectGate(JSON.stringify(parsed));
      const gHtml = gate.toUpperCase();
      const gClass = gate === 'ship' ? 'badge badge--success' : gate === 'noship' ? 'badge badge--error' : 'badge badge--warning';
      
      const headerGate = $('dashGateHeader');
      headerGate.textContent = `● ${gHtml}`;
      headerGate.className = `nav-tag ${gClass}`;

      // KPIs on Overview
      const kpis = Parser.extractKPIs(sections);
      const grid = $('kpiGrid');
      grid.innerHTML = '';
      if (kpis.length) {
        kpis.forEach((k, i) => {
          const staggerClass = `stagger-${(i % 4) + 1}`;
          grid.innerHTML += `
            <div class="glass-card animate-in ${staggerClass}">
              <p class="kpi-label">${k.l}</p>
              <p class="kpi-value financial-value" data-val="${k.v}">0</p>
            </div>
          `;
        });
      }

      // Dynamic Menu & Views
      const sNav = $('sectionNav');
      const dViews = $('dynamicViews');
      sNav.innerHTML = '';
      dViews.innerHTML = '';

      // Add "Overview" to nav
      const overBtn = document.createElement('button');
      overBtn.className = 'nav-link active';
      overBtn.textContent = 'Overview';
      overBtn.onclick = (e) => this.navigate('view-overview', e.currentTarget);
      sNav.appendChild(overBtn);

      sections.forEach((sec, idx) => {
        const viewId = `view-sec-${idx}`;

        // Create Nav Item
        const btn = document.createElement('button');
        btn.className = 'nav-link';
        btn.textContent = sec.heading.substring(0,22);
        btn.onclick = (e) => this.navigate(viewId, e.currentTarget);
        sNav.appendChild(btn);

        // Create Section Content
        let h = `<div class="content-section" id="${viewId}" style="margin-bottom: 64px;">
                   <div class="section-eyebrow animate-in stagger-1">SECTION ${idx + 1}</div>
                   <h2 class="section-title animate-in stagger-2" style="font-size:32px; margin-bottom: 24px;">${sec.heading}</h2>`;
                   
        sec.blocks.forEach((b, blockIdx) => {
          const staggerClass = `stagger-${(blockIdx % 3) + 2}`;
          if (b.type === 'table') {
            const { h: hd, d } = Parser.parseTable(b.lines);
            const si = hd.findIndex(x => /status/i.test(x));
            h += `<div class="table-container animate-in ${staggerClass}"><table class="table"><thead><tr>`;
            hd.forEach(c => h += `<th>${c}</th>`);
            h += '</tr></thead><tbody>';
            d.forEach(r => {
              const rowData = JSON.stringify({ h: hd, d: r }).replace(/'/g, "&#39;");
              h += `<tr onclick='window.App.openDrawer(${rowData})'>`;
              r.forEach((c, ci) => {
                if (ci === si) {
                  const cat = Parser.classify(c);
                  const cName = cat === 'pass' ? 'badge--success' : cat === 'fail' ? 'badge--error' : cat === 'pending' ? 'badge--warning' : 'badge--neutral';
                  h += `<td><span class="badge ${cName}">● ${c.replace(/[*_`]/g, '')}</span></td>`;
                } else {
                  h += `<td>${Parser.inline(c)}</td>`;
                }
              });
              h += '</tr>';
            });
            h += '</tbody></table></div>';
          } else {
            h += `<p class="animate-in ${staggerClass} text-body" style="margin-bottom: 16px;">${Parser.inline(b.text)}</p>`;
          }
        });
        h += '</div>';
        dViews.innerHTML += h;
      });

      // Trigger countUp for KPIs
      setTimeout(() => {
        $('view-overview').querySelectorAll('.financial-value[data-val]').forEach(el => {
          const val = el.getAttribute('data-val');
          this.animateCounter(el, 0, val, 1500);
        });
      }, 300);
      
      this.navigate('view-overview', overBtn);
    }
  };

  window.App = App;

  // --- Parser Module ---
  const Parser = {
    SM: { pass:'pass', done:'pass', completed:'pass', ship:'pass', ready:'pass',
          pending:'pending', partial:'pending', conditional:'pending',
          fail:'fail', failing:'fail', noship:'fail', 'no-ship':'fail', error:'fail' },
    
    classify(t) {
      const l = t.toLowerCase().replace(/[*_`]/g, '');
      for (const [k, v] of Object.entries(this.SM)) if (l.includes(k)) return v;
      return '';
    },
    
    detectGate(str) {
      const l = str.toLowerCase();
      if (l.includes('no-ship') || l.includes('noship')) return 'noship';
      if (l.includes('conditional')) return 'conditional';
      if (/\bship\b/.test(l)) return 'ship';
      return 'noship';
    },

    parse(raw) {
      const lines = raw.split('\n'), sections = [];
      let cur = null, meta = { title: '', date: '', env: '' };
      
      for (let i=0; i<lines.length; i++) {
        const ln = lines[i];
        if (/^# /.test(ln) && !meta.title) { meta.title = ln.replace(/^# /, '').trim(); continue; }
        if (/^Date:/i.test(ln)) { meta.date = ln.replace(/^Date:\s*/i, '').trim(); continue; }
        if (/^Environment:/i.test(ln)) { meta.env = ln.replace(/^Environment:\s*/i, '').trim(); continue; }
        if (/^## /.test(ln)) { cur = { heading: ln.replace(/^## /, '').trim(), blocks: [] }; sections.push(cur); continue; }
        if (!cur) continue;
        
        if (ln.trim().startsWith('|') && ln.includes('|')) {
          const tl = [ln]; let j = i+1;
          while (j < lines.length && lines[j].trim().startsWith('|')) { tl.push(lines[j]); j++; }
          if (tl.length >= 2) { cur.blocks.push({ type: 'table', lines: tl }); i = j-1; continue; }
        }
        if (ln.trim()) cur.blocks.push({ type: 'p', text: ln.trim() });
      }
      return { meta, sections };
    },

    parseTable(tl) {
      const rows = tl.filter(l => !l.trim().match(/^\|[\s\-:|]+\|$/));
      if (!rows.length) return { h: [], d: [] };
      const h = rows[0].split('|').map(c => c.trim()).filter(Boolean);
      const d = rows.slice(1).map(r => r.split('|').map(c => c.trim()).filter(Boolean));
      return { h, d };
    },

    inline(t) {
      return t.replace(/`([^`]+)`/g, '<code style="font-family:var(--font-mono); color:var(--indra-cyan);">$1</code>')
              .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
              .replace(/\*([^*]+)\*/g, '<em>$1</em>');
    },

    extractKPIs(secs) {
      const kpis = []; let pass = 0, pend = 0, fail = 0, total = 0;
      for (const s of secs) {
        for (const b of s.blocks) {
          if (b.type !== 'table') continue;
          const { h, d } = this.parseTable(b.lines);
          const si = h.findIndex(x => /status/i.test(x));
          if (si < 0) continue;
          for (const r of d) {
            const st = this.classify(r[si] || ''); total++;
            if (st === 'pass') pass++; else if (st === 'fail') fail++; else pend++;
          }
        }
      }
      if (total > 0) {
        kpis.push({ l: 'Total Items', v: total });
        kpis.push({ l: 'Passed', v: pass });
        kpis.push({ l: 'Pending', v: pend });
        kpis.push({ l: 'Failed', v: fail });
        kpis.push({ l: 'Completion', v: Math.round((pass/total)*100) + '%' });
      }
      return kpis;
    }
  };

  App.init();
})();
