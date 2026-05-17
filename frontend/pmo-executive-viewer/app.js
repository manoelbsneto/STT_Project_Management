(function(){
'use strict';
const $=id=>document.getElementById(id);
const fileInput=$('fileInput'),heroSection=$('heroSection'),dashboard=$('dashboard'),
  dropZone=$('dropZone'),btnDemo=$('btnDemo'),sidebarNav=$('dynamicNav'),
  sidebarGate=$('sidebarGate'),topbarTitle=$('topbarTitle'),topbarEyebrow=$('topbarEyebrow'),
  topbarDate=$('topbarDate'),topbarEnv=$('topbarEnv'),topbarGate=$('topbarGate'),
  kpiRow=$('kpiRow'),dynSections=$('dynamicSections'),footerTs=$('footerTs'),
  btnNavHome=$('btnNavHome'),canvas=$('particleCanvas');

// === PARTICLES ===
const ctx=canvas.getContext('2d');let particles=[];
function resizeCanvas(){canvas.width=window.innerWidth;canvas.height=window.innerHeight}
window.addEventListener('resize',resizeCanvas);resizeCanvas();
function createParticles(){
  particles=[];const count=Math.floor(window.innerWidth/18);
  for(let i=0;i<count;i++){particles.push({
    x:Math.random()*canvas.width,y:Math.random()*canvas.height,
    r:Math.random()*1.5+.3,vx:(Math.random()-.5)*.3,vy:(Math.random()-.5)*.3,
    a:Math.random()*.4+.1
  })}
}
createParticles();
function drawParticles(){
  ctx.clearRect(0,0,canvas.width,canvas.height);
  for(const p of particles){
    p.x+=p.vx;p.y+=p.vy;
    if(p.x<0)p.x=canvas.width;if(p.x>canvas.width)p.x=0;
    if(p.y<0)p.y=canvas.height;if(p.y>canvas.height)p.y=0;
    ctx.beginPath();ctx.arc(p.x,p.y,p.r,0,Math.PI*2);
    ctx.fillStyle=`rgba(0,176,189,${p.a})`;ctx.fill();
  }
  // Draw connections
  for(let i=0;i<particles.length;i++){
    for(let j=i+1;j<particles.length;j++){
      const dx=particles[i].x-particles[j].x,dy=particles[i].y-particles[j].y;
      const dist=Math.sqrt(dx*dx+dy*dy);
      if(dist<120){
        ctx.beginPath();ctx.moveTo(particles[i].x,particles[i].y);
        ctx.lineTo(particles[j].x,particles[j].y);
        ctx.strokeStyle=`rgba(0,176,189,${.06*(1-dist/120)})`;
        ctx.lineWidth=.5;ctx.stroke();
      }
    }
  }
  requestAnimationFrame(drawParticles);
}
drawParticles();

// === STATUS MAP ===
const SM={pass:'pass',done:'done',completed:'completed',ship:'ship',ready:'ready',
  pending:'pending',partial:'partial',conditional:'conditional',blocking:'blocking',
  fail:'fail',failing:'fail','no-ship':'noship',noship:'noship',error:'error',
  'action required':'action',implemented:'implemented',open:'open',info:'info'};

function classify(t){
  const l=t.toLowerCase().replace(/[*_`]/g,'');
  for(const[k,v]of Object.entries(SM))if(l.includes(k))return v;
  return '';
}
function detectGate(md){
  const l=md.toLowerCase();
  if(l.includes('no-ship')||l.includes('noship'))return'noship';
  if(l.includes('conditional'))return'conditional';
  if(/\bship\b/.test(l))return'ship';
  return'noship';
}

// === MD PARSER ===
function parseMD(raw){
  const lines=raw.split('\n'),sections=[];let cur=null;
  const meta={title:'',date:'',env:'',bot:'',pkg:'',pub:''};
  for(let i=0;i<lines.length;i++){
    const ln=lines[i];
    if(/^# (.+)/.test(ln)&&!meta.title){meta.title=ln.replace(/^# /,'').trim();continue}
    if(/^Date:/i.test(ln)){meta.date=ln.replace(/^Date:\s*/i,'').trim();continue}
    if(/^Environment:/i.test(ln)){meta.env=ln.replace(/^Environment:\s*/i,'').trim();continue}
    if(/^Bot:/i.test(ln)){meta.bot=ln.replace(/^Bot:\s*/i,'').trim();continue}
    if(/^Latest package/i.test(ln)){meta.pkg=ln.replace(/^Latest package[^:]*:\s*/i,'').replace(/`/g,'').trim();continue}
    if(/^Latest publish/i.test(ln)){meta.pub=ln.replace(/^Latest publish[^:]*:\s*/i,'').trim();continue}
    if(/^## (.+)/.test(ln)){cur={heading:ln.replace(/^## /,'').trim(),blocks:[]};sections.push(cur);continue}
    if(!cur)continue;
    // Table
    if(ln.trim().startsWith('|')&&ln.includes('|')){
      const tl=[ln];let j=i+1;
      while(j<lines.length&&lines[j].trim().startsWith('|')){tl.push(lines[j]);j++}
      if(tl.length>=2){cur.blocks.push({type:'table',lines:tl});i=j-1;continue}
    }
    // Ordered list
    if(/^\d+\.\s/.test(ln.trim())){
      const items=[ln.trim().replace(/^\d+\.\s*/,'')];let j=i+1;
      while(j<lines.length&&/^\d+\.\s/.test(lines[j].trim())){items.push(lines[j].trim().replace(/^\d+\.\s*/,''));j++}
      cur.blocks.push({type:'list',items});i=j-1;continue;
    }
    // Unordered list
    if(/^[-*]\s/.test(ln.trim())){
      const items=[ln.trim().replace(/^[-*]\s*/,'')];let j=i+1;
      while(j<lines.length&&/^[-*]\s/.test(lines[j].trim())){items.push(lines[j].trim().replace(/^[-*]\s*/,''));j++}
      cur.blocks.push({type:'list',items});i=j-1;continue;
    }
    // Code
    if(ln.trim().startsWith('```')){
      const cl=[];let j=i+1;
      while(j<lines.length&&!lines[j].trim().startsWith('```')){cl.push(lines[j]);j++}
      cur.blocks.push({type:'code',content:cl.join('\n')});i=j;continue;
    }
    if(ln.trim())cur.blocks.push({type:'p',text:ln.trim()});
  }
  return{meta,sections};
}

function parseTable(tl){
  const rows=tl.filter(l=>!l.trim().match(/^\|[\s\-:|]+\|$/));
  if(!rows.length)return{h:[],d:[]};
  const h=rows[0].split('|').map(c=>c.trim()).filter(Boolean);
  const d=rows.slice(1).map(r=>r.split('|').map(c=>c.trim()).filter(Boolean));
  return{h,d};
}

function inlineMD(t){
  return t.replace(/`([^`]+)`/g,'<code style="font-family:var(--mono);font-size:12px;background:rgba(0,176,189,.08);padding:2px 7px;border-radius:4px;color:var(--sky)">$1</code>')
    .replace(/\*\*([^*]+)\*\*/g,'<strong>$1</strong>').replace(/\*([^*]+)\*/g,'<em>$1</em>');
}

function pill(t){
  const c=classify(t),clean=t.replace(/[*_`]/g,'').trim();
  return c?`<span class="pill ${c}">${clean}</span>`:clean;
}

function extractKPIs(secs){
  const kpis=[];let pass=0,pend=0,fail=0,total=0;
  for(const s of secs)for(const b of s.blocks){
    if(b.type!=='table')continue;
    const{h,d}=parseTable(b.lines);
    const si=h.findIndex(x=>/status/i.test(x));if(si<0)continue;
    for(const r of d){
      const st=(r[si]||'').toLowerCase().replace(/[*_`]/g,'');total++;
      if(st.includes('pass')||st.includes('done')||st.includes('completed'))pass++;
      else if(st.includes('fail')||st.includes('noship'))fail++;
      else pend++;
    }
  }
  if(total>0){
    kpis.push({l:'Total Items',v:total,c:'c'});
    kpis.push({l:'Passed',v:pass,c:'s'});
    kpis.push({l:'Pending',v:pend,c:pend?'w':'s'});
    kpis.push({l:'Failed',v:fail,c:fail?'e':'s'});
    const pct=Math.round((pass/total)*100);
    kpis.push({l:'Completion',v:pct+'%',c:pct>=80?'s':pct>=50?'w':'e'});
  }
  return kpis;
}

// === RENDER ===
function render(parsed){
  const{meta,sections}=parsed;
  const gate=detectGate(JSON.stringify(parsed));
  // Topbar
  topbarTitle.textContent=meta.title||'Status Report';
  topbarEyebrow.textContent=meta.bot||'PMO STATUS REPORT';
  topbarDate.querySelector('span').textContent=meta.date||new Date().toISOString().slice(0,10);
  topbarEnv.querySelector('span').textContent=meta.env?meta.env.split('(')[0].trim():'—';
  const gm={noship:{l:'NO-SHIP',c:'noship'},conditional:{l:'CONDITIONAL',c:'conditional'},ship:{l:'SHIP',c:'ship'}};
  const g=gm[gate];
  topbarGate.innerHTML=`<span class="gate-pill ${g.c}">${g.l}</span>`;
  // Sidebar gate
  sidebarGate.className='sidebar__status'+(gate==='ship'?' ship':gate==='conditional'?' conditional':'');
  sidebarGate.querySelector('.gate-label').textContent=g.l;
  // KPIs
  const kpis=extractKPIs(sections);kpiRow.innerHTML='';
  if(!kpis.length){$('kpiSection').style.display='none'}
  else{$('kpiSection').style.display='';
    kpis.forEach((k,i)=>{
      const d=document.createElement('div');d.className='kpi-card';
      d.style.animationDelay=i*80+'ms';
      d.innerHTML=`<div class="kpi-label">${k.l}</div><div class="kpi-val ${k.c}">${k.v}</div>`;
      kpiRow.appendChild(d);
    });
  }
  // Sidebar nav
  sidebarNav.innerHTML='<div class="nav-section-label">SECTIONS</div>';
  sections.forEach((s,i)=>{
    const btn=document.createElement('button');btn.className='sidebar-btn';
    btn.dataset.target='sec-'+i;
    const label=s.heading.length>24?s.heading.slice(0,22)+'…':s.heading;
    btn.innerHTML=`<div class="sidebar-btn__3d"><div class="sidebar-btn__face sidebar-btn__face--front">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18"/></svg>
      <span>${label}</span></div><div class="sidebar-btn__face sidebar-btn__face--bottom"></div></div>
      <div class="sidebar-btn__glow"></div>`;
    btn.addEventListener('click',()=>{
      document.getElementById('sec-'+i)?.scrollIntoView({behavior:'smooth'});
      document.querySelectorAll('.sidebar-btn').forEach(b=>b.classList.remove('sidebar-btn--active'));
      btn.classList.add('sidebar-btn--active');
    });
    sidebarNav.appendChild(btn);
  });
  // Sections
  dynSections.innerHTML='';
  sections.forEach((sec,idx)=>{
    const el=document.createElement('section');el.className='exec-section page-transition';
    el.id='sec-'+idx;el.style.animationDelay=idx*80+'ms';
    let h=`<p class="sec-eyebrow">Section ${idx+1}</p><h2 class="sec-title">${sec.heading}</h2>`;
    for(const b of sec.blocks){
      if(b.type==='table'){
        const{h:hd,d}=parseTable(b.lines);
        const si=hd.findIndex(x=>/status/i.test(x));
        h+='<div class="table-wrap"><table class="exec-table"><thead><tr>';
        hd.forEach(c=>{h+=`<th>${c}</th>`});
        h+='</tr></thead><tbody>';
        d.forEach(r=>{h+='<tr>';r.forEach((c,ci)=>{h+=`<td>${ci===si?pill(c):inlineMD(c)}</td>`});
          for(let p=r.length;p<hd.length;p++)h+='<td></td>';h+='</tr>'});
        h+='</tbody></table></div>';
      }else if(b.type==='list'){
        h+='<ol class="exec-list">';b.items.forEach(i=>{h+=`<li>${inlineMD(i)}</li>`});h+='</ol>';
      }else if(b.type==='code'){
        h+=`<div class="exec-code">${b.content.replace(/</g,'&lt;')}</div>`;
      }else{h+=`<p class="exec-p">${inlineMD(b.text)}</p>`}
    }
    el.innerHTML=h;dynSections.appendChild(el);
  });
  footerTs.textContent='Rendered '+new Date().toLocaleString('pt-BR');
  // Transition
  heroSection.style.display='none';dashboard.style.display='block';
  dashboard.classList.add('page-transition');
  window.scrollTo({top:0,behavior:'smooth'});
  // Home btn
  btnNavHome.onclick=()=>{window.scrollTo({top:0,behavior:'smooth'});
    document.querySelectorAll('.sidebar-btn').forEach(b=>b.classList.remove('sidebar-btn--active'));
    btnNavHome.classList.add('sidebar-btn--active')};
}

// === FILE HANDLING ===
function handleFile(f){if(!f)return;const r=new FileReader();
  r.onload=e=>{render(parseMD(e.target.result))};r.readAsText(f,'utf-8')}
fileInput.addEventListener('change',e=>handleFile(e.target.files[0]));

// Drag & drop
let dc=0;
document.addEventListener('dragenter',e=>{e.preventDefault();dc++;dropZone.classList.add('active')});
document.addEventListener('dragleave',e=>{e.preventDefault();dc--;if(dc<=0){dc=0;dropZone.classList.remove('active')}});
document.addEventListener('dragover',e=>e.preventDefault());
document.addEventListener('drop',e=>{e.preventDefault();dc=0;dropZone.classList.remove('active');handleFile(e.dataTransfer.files[0])});

// Scroll spy
window.addEventListener('scroll',()=>{
  const btns=sidebarNav.querySelectorAll('.sidebar-btn');let active=null;
  btns.forEach(b=>{const el=document.getElementById(b.dataset.target);
    if(el&&el.getBoundingClientRect().top<=120)active=b});
  btns.forEach(b=>b.classList.remove('sidebar-btn--active'));
  if(active)active.classList.add('sidebar-btn--active');
  else btnNavHome.classList.add('sidebar-btn--active');
});

// DEMO DATA
btnDemo.addEventListener('click',()=>{
  render(parseMD(`# PMO 360 Status Report\n\nDate: ${new Date().toISOString().slice(0,10)}\nEnvironment: ColOfertasBrasilPro\nBot: Assistente PMO V2\n\n## Latest Updates\n\n| Area | Status | Evidence |\n|---|---|---|\n| Solution v1.13 import and publish | PASS | CriarTarefa duplicate guard, fresh create, and cancel guard passed with SharePoint proof. |\n| v1.14 soft-delete package | PASS | Solution/PMO_v11_Tarefas_1_14_SOFT_DELETE_FIX.zip exists and static soft-delete audit passed 35/35 checks. |\n| ConsultarPortfolio runtime | PASS | Live SharePoint aggregation returned active portfolio counts. |\n| ConsultarProjeto runtime | PASS | Two-step and direct projeto= lookup returned live project details. |\n| AtualizarStatus runtime | PASS | Teste Smoke Final V5 updated Projetos and Status Diario. Pilot Mobile App Corporativo needs data repair only. |\n| RegistrarRisco runtime | PASS | SharePoint confirmed RISK-6851D4E6 in Riscos e Bloqueios. |\n| RegistrarBloqueio runtime | PASS | SharePoint confirmed BLOCK-F8577225 in Riscos e Bloqueios. |\n| PedirDecisao runtime | PASS | SharePoint confirmed DEC-C930FF9A in Decisoes do Board. |\n\n## Pending Gap Status Ordered By Severity\n\n| Severity | Gap / Workstream | Current Status | Next Step | Next-Hour Estimate |\n|---|---|---|---|---|\n| P0 Critical | v1.14 ExcluirProjeto / ExcluirTarefa soft-delete runtime | PACKAGE READY / STATIC PASS | Import and publish v1.14, then prove project and task soft-delete with Deleted=true and audit fields. | 30-55 min |\n| P1 High | Pilot project Title data repair | PENDING APPROVAL | Set Title = NomeProjeto for affected pilot rows such as Mobile App Corporativo; retest AtualizarStatus on pilot data. | 10-20 min |\n| P1 High | Recurrence and alert flows runtime proof | PARTIAL PASS / FRESH PROOF PENDING | Capture updated run evidence for daily/weekly portfolio, red alert, critical risk escalation, and decision response. | 30-60 min |\n| P1 High | Planner sync metrics | PENDING UPDATED EVIDENCE | Trigger or inspect PMO_PA_SyncPlannerStats_Standard and verify project metric fields. | 20-40 min |\n| P2 Medium | Final live solution export and audit | PENDING | Export after v1.14 runtime proof and run stop-ship/static audits against the fresh export. | 20-40 min |\n| P2 Medium | Training/runbook screenshots | PENDING | Capture final workflow screenshots and update the evidence matrix. | 30-60 min |\n\n## Next Hour Plan\n\n1. Import and publish Solution/PMO_v11_Tarefas_1_14_SOFT_DELETE_FIX.zip.\n2. Run ExcluirProjeto positive and cancel tests against Projeto Smoke v113 Cancel.\n3. Run ExcluirTarefa positive test against one exact task line, if a safe task target is available.\n4. Verify SharePoint rows remain physically present and active queries exclude Deleted=true rows.\n5. If time remains, repair pilot Title data and collect Planner/recurrence evidence.\n\n## Current Gate View\n\nStatus: NO-SHIP until v1.14 runtime proof and final export audit are complete.\n\nReason: Core read/write P0 smoke tests are green, but PM-friendly removal is now the remaining P0 release capability and must be proven in live Copilot + SharePoint before release.`));
});
})();
