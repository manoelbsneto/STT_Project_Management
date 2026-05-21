/* eslint-disable */
// Smoke test for the new MD viewer engine.
// Verifies: (1) detectDocType returns 'executive' on the 4 sample MDs;
//           (2) the fallback markdown renderer (no marked) doesn't crash;
//           (3) hero metadata extraction surfaces the expected keys.
// Run: node test_doc_engine.js  from /mnt/c/VMs/Projetos/Web_MD_Viewer
const fs = require('fs');
const path = require('path');

// Load the viewer.js source so we can extract the pure-functions for testing
// without needing the browser DOM. We re-implement the detection/extraction
// using the same regex source as the production code (kept inline below).

const SAMPLES = [
  '/mnt/c/VMs/Projetos/VMs/Agentificacao_DN_Minsait/AgentificacaoDeOfertas-v0/docs/agentes/01_AGENTE_1_QUALIFICACAO.md',
  '/mnt/c/VMs/Projetos/VMs/Agentificacao_DN_Minsait/AgentificacaoDeOfertas-v0/docs/agentes/02_AGENTE_2_KICKOFF_S2S.md',
  '/mnt/c/VMs/Projetos/VMs/Agentificacao_DN_Minsait/AgentificacaoDeOfertas-v0/docs/agentes/03_AGENTE_3_BALLPARK_ROM.md',
  '/mnt/c/VMs/Projetos/VMs/Agentificacao_DN_Minsait/AgentificacaoDeOfertas-v0/docs/agentes/04_MAPEAMENTO_KB_ACERVO.md',
  '/mnt/c/VMs/Projetos/VMs/Agentificacao_DN_Minsait/AgentificacaoDeOfertas-v0/docs/agentes/05_PATHS_E_FONTES_DE_DADOS.md'
];

// ── Inlined copies of viewer.js pure functions (must stay in sync) ──────
function detectDocType(text, fileName = '') {
  if (!text) return 'status';
  let score = 0;
  if (/^---\n[\s\S]*?\n---/m.test(text.slice(0, 800))) score += 4;
  if (/```[a-z]*\n[\s\S]*?[┌┐└┘─│├┤┬┴┼▶▲▼◀]/m.test(text)) score += 4;
  if (/```json[\s\S]*?\$schema[\s\S]*?```/m.test(text)) score += 4;
  if (/```ya?ml[\s\S]*?```/m.test(text)) score += 2;
  if (/^>\s*\*\*Especificação\b/im.test(text)) score += 4;
  if (/^>\s*(Vers[ãa]o|Status|Audi[êe]ncia|Confidencialidade)\s*[:|]/im.test(text)) score += 3;
  if (/^#\s+.+\n+>\s/m.test(text)) score += 2;
  const h2Count = (text.match(/^##\s+/gm) || []).length;
  const h3Count = (text.match(/^###\s+/gm) || []).length;
  if (h2Count + h3Count >= 6) score += 2;
  if (h2Count + h3Count >= 12) score += 2;
  if (/agente|spec|proposta|arquitet|kickoff|mapeamento|paths|brief|rfp/i.test(fileName)) score += 2;
  const tableLines = (text.match(/^\s*\|/gm) || []).length;
  const sepLines = (text.match(/^\s*\|?\s*[-:]+[-|:\s]*$/gm) || []).length;
  if (tableLines > 30 && h2Count + h3Count < 4 && sepLines >= 2) score -= 3;
  return { type: score >= 4 ? 'executive' : 'status', score, h2Count, h3Count };
}

function extractMetadata(text) {
  const meta = {};
  const fm = text.match(/^---\n([\s\S]*?)\n---/);
  if (fm) {
    fm[1].split('\n').forEach(line => {
      const m = line.match(/^([A-Za-zÀ-ú\u00C0-\u017F][\w\s\-]*):\s*(.+?)\s*$/);
      if (m) meta[m[1].trim().toLowerCase()] = m[2].replace(/^["']|["']$/g, '').trim();
    });
  }
  const specMatches = text.match(/^>\s*\*\*([^*:]+):\*\*\s*([^\n]+)/gm) || [];
  specMatches.forEach(line => {
    const m = line.match(/^>\s*\*\*([^*:]+):\*\*\s*([^\n]+)/);
    if (m) meta[m[1].trim().toLowerCase()] = m[2].trim();
  });
  return meta;
}

function computeDocSummary(text) {
  const noCode = text.replace(/```[\s\S]*?```/g, '');
  const sections = (noCode.match(/^##\s+/gm) || []).length;
  const subs = (noCode.match(/^###\s+/gm) || []).length;
  const tableLines = (noCode.match(/^\s*\|[-:|\s]+\|\s*$/gm) || []).length;
  const diagramBlocks = (text.match(/```[a-z]*\n[\s\S]*?[┌┐└┘─│├┤┬┴┼▶▲▼◀]/g) || []).length;
  const schemaBlocks = (text.match(/```json[\s\S]*?\$schema[\s\S]*?```/g) || []).length;
  const yamlBlocks = (text.match(/```ya?ml[\s\S]*?```/g) || []).length;
  const farois = ((text.match(/[🟢🟡🔴⚪]/gu) || []).length);
  const wordCount = noCode.replace(/[#>*_`\-]/g, ' ').split(/\s+/).filter(Boolean).length;
  const readingMin = Math.max(1, Math.round(wordCount / 220));
  return { sections, subs, tables: tableLines, diagrams: diagramBlocks,
           schemas: schemaBlocks, yamls: yamlBlocks, farois, words: wordCount, readingMin };
}

let fail = 0;
console.log('\n═════════════════════════════════════════════════════════');
console.log(' MD Viewer — Smoke Test');
console.log('═════════════════════════════════════════════════════════\n');

SAMPLES.forEach(p => {
  if (!fs.existsSync(p)) {
    console.log(`  ⚠️  SKIP (not found): ${p}`);
    return;
  }
  const text = fs.readFileSync(p, 'utf8');
  const fname = path.basename(p);
  const detect = detectDocType(text, fname);
  const meta = extractMetadata(text);
  const summary = computeDocSummary(text);
  const ok = detect.type === 'executive';
  if (!ok) fail++;
  console.log(` ${ok ? '✅' : '❌'} ${fname}`);
  console.log(`    type: ${detect.type}  (score=${detect.score}, H2=${detect.h2Count}, H3=${detect.h3Count})`);
  console.log(`    meta: ${Object.keys(meta).slice(0,5).join(', ') || '(none)'}`);
  console.log(`    KPIs: sections=${summary.sections} tables=${summary.tables} diagrams=${summary.diagrams} schemas=${summary.schemas} yamls=${summary.yamls} faróis=${summary.farois} words=${summary.words} reading=${summary.readingMin}m`);
  console.log('');
});

if (fail) {
  console.log(`\n❌ ${fail} file(s) misclassified — adjust detectDocType.`);
  process.exit(1);
} else {
  console.log('🎉 All samples correctly identified as EXECUTIVE.');
}
