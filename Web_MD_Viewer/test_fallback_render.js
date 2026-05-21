/* Offline-fallback renderer test — extracts the inline fallback used by viewer.js
   when marked.js fails to load, and renders a sample to prove no crashes. */
const fs = require('fs');

// ── Pure-functional copies of viewer.js (offline path) ───────────────────
function escapeHtml(s) { return String(s||'').replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
function stripInlineMd(s) { return String(s||'').replace(/\*\*/g,'').replace(/__/g,'').replace(/`/g,'').replace(/<[^>]+>/g,'').trim(); }
function slugify(s) { return String(s||'').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^\w\s-]/g,'').trim().replace(/\s+/g,'-').slice(0,80); }

function inlineFmt(s) {
  let out = escapeHtml(s);
  out = out.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, '<img alt="$1" src="$2">');
  out = out.replace(/\[([^\]]+)\]\(([^)]+)\)/g, (_,t,u)=>{const ext=/^https?:\/\//.test(u);return `<a href="${u}"${ext?' target="_blank" rel="noopener"':''}>${t}</a>`;});
  out = out.replace(/\*\*([^*]+)\*\*/g,'<strong>$1</strong>');
  out = out.replace(/\*([^*]+)\*/g,'<em>$1</em>');
  out = out.replace(/`([^`]+)`/g,'<code>$1</code>');
  return out;
}

function renderCodeBlock(code, lang) {
  const isAscii = /[┌┐└┘─│├┤┬┴┼▶▲▼◀]/.test(code);
  if (isAscii) return `<pre class="diagram"><code>${escapeHtml(code)}</code></pre>`;
  if (lang === 'json' && /\$schema/.test(code)) {
    return `<div class="schema-viewer"><div class="schema-viewer-header"><span>JSON SCHEMA</span></div><pre><code class="language-json">${escapeHtml(code)}</code></pre></div>`;
  }
  if (/^ya?ml$/.test(lang||'')) return `<pre class="yaml-config"><code>${escapeHtml(code)}</code></pre>`;
  return `<pre><code>${escapeHtml(code)}</code></pre>`;
}

function decorateBlockquote(innerHtml) {
  const stripped = (innerHtml||'').replace(/<[^>]+>/g,' ').trim();
  if (/^\*?\*?Especifica[çc][ãa]o/i.test(stripped)) return `<blockquote class="spec">${innerHtml}</blockquote>`;
  return `<blockquote>${innerHtml}</blockquote>`;
}

function transformCell(html) { return html
  .replace(/🟢\s*ALTO/gi,'<span class="farol-pill alto">🟢 ALTO</span>')
  .replace(/🟡\s*M[ÉE]DIO/gi,'<span class="farol-pill medio">🟡 MÉDIO</span>')
  .replace(/🔴\s*BAIXO/gi,'<span class="farol-pill baixo">🔴 BAIXO</span>'); }

function renderFallback(text) {
  const tocItems=[]; let firstH1=null;
  const lines = text.split('\n'); const out=[]; let i=0; let h2i=0,h3i=0;
  const flush = (b)=>{ if(b.length){const j=b.join(' ').trim();if(j)out.push(`<p>${inlineFmt(j)}</p>`); b.length=0;} };
  let para=[];
  while(i<lines.length){
    const line=lines[i];
    if (line.trim().startsWith('```')) {
      flush(para);
      const lang=line.trim().slice(3).trim(); const codeLines=[]; i++;
      while(i<lines.length && !lines[i].trim().startsWith('```')){codeLines.push(lines[i]);i++;}
      i++; out.push(renderCodeBlock(codeLines.join('\n'),lang)); continue;
    }
    const h=line.match(/^(#{1,6})\s+(.+)/);
    if (h) {
      flush(para); const d=h[1].length, txt=h[2].trim(), clean=stripInlineMd(txt);
      const slug = slugify(clean)+'-'+(d===2?`h2-${++h2i}`:d===3?`h3-${++h3i}`:`h${d}`);
      if (d===1){ firstH1=clean; out.push(`<h1 id="${slug}" class="exec-content-h1-suppressed">${inlineFmt(txt)}</h1>`); }
      else { if (d===2||d===3) tocItems.push({depth:d,text:clean,slug}); out.push(`<h${d} id="${slug}">${inlineFmt(txt)}</h${d}>`); }
      i++; continue;
    }
    if (/^---+\s*$/.test(line)) { flush(para); out.push('<hr>'); i++; continue; }
    if (line.startsWith('>')) {
      flush(para);
      const qs=[];
      while(i<lines.length && (lines[i].startsWith('>') || lines[i].trim()==='')){
        if (lines[i].trim()===''){i++;continue;}
        qs.push(lines[i].replace(/^>\s?/,'')); i++;
      }
      const inner = qs.length===1?`<p>${inlineFmt(qs[0])}</p>`:qs.map(l=>`<p>${inlineFmt(l)}</p>`).join('');
      out.push(decorateBlockquote(inner)); continue;
    }
    if (line.includes('|') && i+1<lines.length && /^\s*\|?\s*[-:]+/.test(lines[i+1])) {
      flush(para);
      const headers=line.split('|').map(s=>s.trim()).filter(Boolean);
      i+=2; const rows=[];
      while(i<lines.length && lines[i].includes('|') && lines[i].trim()){
        rows.push(lines[i].split('|').map(s=>s.trim()).filter((s,idx,a)=>!(idx===0&&s==='')&&!(idx===a.length-1&&s==='')));
        i++;
      }
      const thead='<tr>'+headers.map(c=>`<th>${inlineFmt(c)}</th>`).join('')+'</tr>';
      const tbody=rows.map(r=>'<tr>'+r.map(c=>`<td>${transformCell(inlineFmt(c))}</td>`).join('')+'</tr>').join('');
      out.push(`<div class="table-wrap"><div class="table-wrap-scroll"><table><thead>${thead}</thead><tbody>${tbody}</tbody></table></div></div>`);
      continue;
    }
    if (/^\s*[-*+]\s+/.test(line) || /^\s*\d+\.\s+/.test(line)) {
      flush(para);
      const isOl = /^\s*\d+\.\s+/.test(line);
      const items=[];
      while(i<lines.length && (/^\s*[-*+]\s+/.test(lines[i]) || /^\s*\d+\.\s+/.test(lines[i]) || /^\s{2,}/.test(lines[i]))) {
        if (/^\s*[-*+]\s+/.test(lines[i]) || /^\s*\d+\.\s+/.test(lines[i])) items.push(lines[i].replace(/^\s*[-*+]\s+|\s*\d+\.\s+/,''));
        else if (items.length) items[items.length-1]+=' '+lines[i].trim();
        i++;
      }
      out.push(`<${isOl?'ol':'ul'}>${items.map(x=>`<li>${inlineFmt(x)}</li>`).join('')}</${isOl?'ol':'ul'}>`); continue;
    }
    if (line.trim()===''){ flush(para); i++; continue; }
    para.push(line); i++;
  }
  flush(para);
  return { html: out.join('\n'), toc: tocItems, title: firstH1 };
}

const samples = [
  '/mnt/c/VMs/Projetos/VMs/Agentificacao_DN_Minsait/AgentificacaoDeOfertas-v0/docs/agentes/01_AGENTE_1_QUALIFICACAO.md',
  '/mnt/c/VMs/Projetos/VMs/Agentificacao_DN_Minsait/AgentificacaoDeOfertas-v0/docs/agentes/04_MAPEAMENTO_KB_ACERVO.md'
];

console.log('\n═════ Offline fallback parser smoke test ═════\n');
for (const p of samples) {
  const text = fs.readFileSync(p, 'utf8');
  try {
    const t0 = Date.now();
    const { html, toc, title } = renderFallback(text);
    const ms = Date.now() - t0;
    console.log(`✅ ${p.split('/').pop()}`);
    console.log(`   title: "${title}"`);
    console.log(`   html: ${(html.length/1024).toFixed(1)} KB · toc: ${toc.length} items · ${ms}ms`);
    // Spot-check: does it contain a diagram block, a table, a list?
    console.log(`   diagrams: ${(html.match(/pre class="diagram"/g)||[]).length}`);
    console.log(`   schemas:  ${(html.match(/class="schema-viewer"/g)||[]).length}`);
    console.log(`   tables:   ${(html.match(/<table>/g)||[]).length}`);
    console.log(`   farois:   ${(html.match(/farol-pill/g)||[]).length}`);
    console.log('');
  } catch (e) {
    console.log(`❌ ${p.split('/').pop()}: ${e.message}\n`);
  }
}
