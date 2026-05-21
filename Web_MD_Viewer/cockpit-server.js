/**
 * cockpit-server.js
 * PMO Cockpit - Real-time monitoring dashboard for M2
 */

const http = require('http');
const fs = require('fs');
const fsPromises = require('fs/promises');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const M2_DIR = path.join(ROOT, '.planning', 'milestones', 'M2_card_first_revision_v2');
const GOV_DIR = path.join(M2_DIR, 'governance');
const PHASES_DIR = path.join(M2_DIR, 'phases');

// Static M2 Phase 1 fleet roster (12 AI agents). Order matches dispatch sequence.
const FLEET_ROSTER = [
  { id: 'CODEX-1-LEAD',       family: 'Codex #1',     model: 'Codex 5.5',          tracks: 'A.1, A.2 + integrator', prompt_id: 'codex1_lead' },
  { id: 'CODEX-1-SUB-A',      family: 'Codex #1',     model: 'Codex 5.5 (sub)',    tracks: 'A.3, A.4',              prompt_id: 'codex1_sub_a' },
  { id: 'CODEX-1-SUB-B',      family: 'Codex #1',     model: 'Codex 5.5 (sub)',    tracks: 'B (SharePoint)',        prompt_id: 'codex1_sub_b' },
  { id: 'CODEX-1-SUB-C',      family: 'Codex #1',     model: 'Codex 5.5 (sub)',    tracks: 'A.5, H',                prompt_id: 'codex1_sub_c' },
  { id: 'CODEX-2-LEAD',       family: 'Codex #2',     model: 'Codex 5.5',          tracks: 'D.1-D.6',               prompt_id: 'codex2_lead' },
  { id: 'CODEX-2-SUB-A',      family: 'Codex #2',     model: 'Codex 5.5 (sub)',    tracks: 'D.7-D.12',              prompt_id: 'codex2_sub_a' },
  { id: 'CODEX-2-SUB-B',      family: 'Codex #2',     model: 'Codex 5.5 (sub)',    tracks: 'D.13-D.18',             prompt_id: 'codex2_sub_b' },
  { id: 'CODEX-2-SUB-C',      family: 'Codex #2',     model: 'Codex 5.5 (sub)',    tracks: 'G (cleanup)',           prompt_id: 'codex2_sub_c' },
  { id: 'OPUS-2',             family: 'Opus',         model: 'Opus 4.7',           tracks: 'E (routing), F (topics)', prompt_id: 'opus2' },
  { id: 'GEMINI-FLASH-LEAD',  family: 'Gemini Flash', model: 'Gemini Flash 3.5',   tracks: 'C.1 deploy/cards',      prompt_id: 'gemini_flash_lead' },
  { id: 'GEMINI-FLASH-SUB-1', family: 'Gemini Flash', model: 'Gemini Flash 3.5 (sub)', tracks: 'C.2 frontend',      prompt_id: 'gemini_flash_sub_1' },
  { id: 'GEMINI-FLASH-SUB-2', family: 'Gemini Flash', model: 'Gemini Flash 3.5 (sub)', tracks: 'C.3 gap analysis', prompt_id: 'gemini_flash_sub_2' }
];

// Stale heartbeat thresholds (ms)
const STALE_MS = 5 * 60 * 1000;   // 5 min → STALE
const DEAD_MS  = 10 * 60 * 1000;  // 10 min → DEAD

let config = {
  port: 7777,
  host: '127.0.0.1',
  polling_default_ms: 5000,
  activity_log_default_limit: 50
};

try {
  const configRaw = fs.readFileSync(path.join(__dirname, 'cockpit-config.json'), 'utf-8');
  Object.assign(config, JSON.parse(configRaw));
} catch (e) {
  console.log('[WARN] Could not load cockpit-config.json, using defaults.');
}

// ---------------------------------------------------------
// Parsers
// ---------------------------------------------------------

async function parseCheckinBoard() {
  try {
    const content = await fsPromises.readFile(path.join(GOV_DIR, 'CHECKIN_BOARD.md'), 'utf-8');
    const result = {
      active_agents_table: [],
      recently_completed: [],
      phase_tracker: [],
      stats: { total_agents_in_fleet: 13, currently_active: 0, currently_blocked: 0, tasks_in_queue: 0, tasks_completed_this_phase: 0 }
    };

    function parseTable(sectionRegex) {
      const out = [];
      const m = content.match(sectionRegex);
      if (!m) return out;
      const lines = m[0].split('\n').filter(l => l.trim().startsWith('|'));
      if (lines.length < 3) return out;
      // Header row → normalised keys
      const headers = lines[0].split('|').slice(1, -1).map(h => h.trim().toLowerCase().replace(/\s+/g, '_'));
      // Skip header (idx 0) + separator row (idx 1)
      for (let i = 2; i < lines.length; i++) {
        const cols = lines[i].split('|').slice(1, -1).map(c => c.trim());
        if (cols.length !== headers.length) continue;
        const row = {};
        headers.forEach((h, idx) => { row[h] = cols[idx]; });
        out.push(row);
      }
      return out;
    }

    // Active Agents
    const activeRows = parseTable(/## Active Agents \(right now\)[\s\S]*?(?=##|$)/);
    activeRows.forEach(row => {
      if (row.agent_id && !row.agent_id.startsWith('(')) {
        result.active_agents_table.push(row);
        if (row.status === 'IN_PROGRESS' || row.status === 'CLAIMED') result.stats.currently_active++;
        if (row.status === 'BLOCKED') result.stats.currently_blocked++;
      }
    });

    // Recently Completed
    const completedRows = parseTable(/## Recently Completed[^\n]*\n[\s\S]*?(?=##|$)/);
    completedRows.forEach(row => {
      if (row.agent_id && !row.agent_id.startsWith('(')) {
        result.recently_completed.push(row);
        if (row.status === 'DONE' || row.status === 'READY_FOR_REVIEW') result.stats.tasks_completed_this_phase++;
      }
    });

    // Phase Tracker
    const phaseRows = parseTable(/## Phase Tracker[\s\S]*?(?=##|$)/);
    phaseRows.forEach(row => {
      if (row.phase) result.phase_tracker.push(row);
    });

    return result;
  } catch (e) {
    console.error('[WARN] Error parsing CHECKIN_BOARD.md:', e.message);
    return null;
  }
}

async function parseActivityLog(sinceStr, limit) {
  try {
    const content = await fsPromises.readFile(path.join(GOV_DIR, 'ACTIVITY_LOG.md'), 'utf-8');
    const lines = content.split('\n');
    let entries = [];
    const sinceTime = sinceStr ? new Date(sinceStr).getTime() : 0;

    for (let i = lines.length - 1; i >= 0; i--) {
      const line = lines[i].trim();
      if (!line) continue;
      const match = line.match(/^\[(.*?)\]\s+(\w+)\s+\|\s+([\w-]+)\s+\|(.*)$/);
      if (match) {
        const ts = match[1];
        const tsTime = new Date(ts).getTime();
        if (sinceTime && tsTime <= sinceTime) {
            // Because we iterate from bottom (newest) to top (oldest),
            // once we hit something older or equal to `sinceTime`, we can stop.
            break;
        }

        const operation = match[2];
        const agent_id = match[3];
        const rest = match[4];

        const fieldsObj = {};
        let task_id = "";
        rest.split('|').forEach(part => {
          const kv = part.split(':');
          if (kv.length >= 2) {
            const key = kv[0].trim().toLowerCase().replace(/\s+/g, '_');
            const val = kv.slice(1).join(':').trim();
            fieldsObj[key] = val;
          } else if (part.includes('task')) {
             task_id = part.replace('task', '').trim();
          }
        });

        entries.push({
          timestamp: ts,
          operation,
          agent_id,
          task_id,
          fields: fieldsObj,
          raw: line
        });

        if (entries.length >= limit) break;
      }
    }
    return {
      total_entries: entries.length, // approximation, this is returned_entries actually.
      returned_entries: entries.length,
      entries
    };
  } catch (e) {
    console.error('[WARN] Error parsing ACTIVITY_LOG.md:', e.message);
    return { total_entries: 0, returned_entries: 0, entries: [] };
  }
}

async function parseFileLocks() {
  try {
    const content = await fsPromises.readFile(path.join(GOV_DIR, 'FILE_LOCK_TABLE.md'), 'utf-8');
    const result = { active_locks: [], recent_history: [] };
    const lockMatch = content.match(/## Active Locks[\s\S]*?(?=##|$)/);
    if (lockMatch) {
      const lines = lockMatch[0].split('\n').filter(l => l.trim().startsWith('|'));
      if (lines.length > 2) {
        const headers = lines[0].split('|').map(h => h.trim().toLowerCase().replace(/\s+/g, '_')).filter(h => h);
        for (let i = 2; i < lines.length; i++) {
          const cols = lines[i].split('|').map(c => c.trim()).filter(c => c !== '');
          if (cols.length === headers.length) {
            const lock = {};
            headers.forEach((h, idx) => { lock[h] = cols[idx]; });
            if (lock.status === 'LOCKED') {
               const acquired = new Date(lock.acquired_at).getTime();
               const now = Date.now();
               const ageSeconds = (now - acquired) / 1000;
               lock.is_stale = ageSeconds > 1200; // 20 mins
               lock.age_seconds = ageSeconds;
               result.active_locks.push(lock);
            }
          }
        }
      }
    }
    return result;
  } catch (e) {
    console.error('[WARN] Error parsing FILE_LOCK_TABLE.md:', e.message);
    return { active_locks: [], recent_history: [] };
  }
}

async function parseHandoffs() {
  try {
    const content = await fsPromises.readFile(path.join(GOV_DIR, 'HANDOFF_LOG.md'), 'utf-8');
    const result = { active_handoffs_pending: [], handoff_history: [], graph: { nodes: [], edges: [] } };
    
    // Parse Active Handoffs Table
    const activeMatch = content.match(/## Active Handoffs[\s\S]*?(?=##|$)/);
    if (activeMatch) {
      const lines = activeMatch[0].split('\n').filter(l => l.trim().startsWith('|'));
      if (lines.length > 2) {
        const headers = lines[0].split('|').map(h => h.trim().toLowerCase().replace(/\s+/g, '_')).filter(h => h);
        for (let i = 2; i < lines.length; i++) {
          const cols = lines[i].split('|').map(c => c.trim()).filter(c => c !== '');
          if (cols.length === headers.length && !cols[0].includes('(none yet)')) {
            const handoff = {};
            headers.forEach((h, idx) => { handoff[h] = cols[idx]; });
            result.active_handoffs_pending.push(handoff);
          }
        }
      }
    }

    // Parse Handoff Stream
    const streamMatch = content.match(/## Handoff Stream[\s\S]*/);
    if (streamMatch) {
      const lines = streamMatch[0].split('\n');
      let currentHandoff = null;
      for (const line of lines) {
        if (line.startsWith('[')) {
          // New handoff entry
          if (currentHandoff) result.handoff_history.push(currentHandoff);
          currentHandoff = { raw_header: line, details: [] };
          
          const regex = /^\[(.*?)\]\s+(HANDOFF|PHASE_HANDOFF)\s+\|\s+(.*)$/;
          const match = line.match(regex);
          if (match) {
             currentHandoff.timestamp = match[1];
             currentHandoff.type = match[2];
             currentHandoff.meta = match[3];
             
             // Extract graph info if possible
             if (currentHandoff.type === 'HANDOFF') {
                const parts = currentHandoff.meta.split('|');
                let from = "", to = "";
                parts.forEach(p => {
                   if (p.includes('from:')) from = p.split('from:')[1].trim();
                   if (p.includes('to:')) to = p.split('to:')[1].trim();
                });
                if (from && to) {
                   if (!result.graph.nodes.includes(from)) result.graph.nodes.push(from);
                   if (!result.graph.nodes.includes(to)) result.graph.nodes.push(to);
                   result.graph.edges.push({ source: from, target: to });
                }
             }
          }
        } else if (currentHandoff && line.trim()) {
           currentHandoff.details.push(line.trim());
        }
      }
      if (currentHandoff) result.handoff_history.push(currentHandoff);
    }
    
    return result;
  } catch (e) {
    console.error('[WARN] Error parsing HANDOFF_LOG.md:', e.message);
    return { active_handoffs_pending: [], handoff_history: [], graph: { nodes: [], edges: [] } };
  }
}

async function getPrompts() {
  try {
    const dispatchDir = path.join(PHASES_DIR, '01_discovery', 'dispatch');
    const files = await fsPromises.readdir(dispatchDir);
    const prompts = [];
    for (const f of files) {
      if (f.endsWith('.md') && f !== 'README.md') {
        const stat = await fsPromises.stat(path.join(dispatchDir, f));
        prompts.push({
          id: f.replace('.md', ''),
          filename: f,
          size_bytes: stat.size,
          last_modified: stat.mtime.toISOString(),
          execution_status: 'UNKNOWN'
        });
      }
    }
    return {
      phase: 1,
      dispatch_path: "phases/01_discovery/dispatch/",
      prompts
    };
  } catch (e) {
    return { phase: 1, dispatch_path: "", prompts: [] };
  }
}

// ---------------------------------------------------------
// Fleet model — builds consolidated lifecycle for all 12 agents
// ---------------------------------------------------------

async function buildFleet() {
  // Load full ACTIVITY_LOG (no limit) so we can compute timestamps from origin
  const al = await parseActivityLog(null, 100000);
  const cb = await parseCheckinBoard();
  const recentlyCompleted = cb ? cb.recently_completed : [];
  const activeAgents = cb ? cb.active_agents_table : [];
  const now = Date.now();

  // Group activity log entries by agent_id
  const byAgent = {};
  for (const e of al.entries) {
    if (!byAgent[e.agent_id]) byAgent[e.agent_id] = [];
    byAgent[e.agent_id].push(e);
  }
  // ACTIVITY_LOG is parsed newest-first by parseActivityLog. Sort ascending by timestamp.
  for (const k of Object.keys(byAgent)) {
    byAgent[k].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
  }

  const fleet = FLEET_ROSTER.map((member, idx) => {
    const events = byAgent[member.id] || [];
    const checkin   = events.find(e => e.operation === 'CHECKIN');
    const checkout  = [...events].reverse().find(e => e.operation === 'CHECKOUT');
    // Sign-of-life events: any operation that proves the agent is active.
    // Strict HEARTBEAT-only is too aggressive — many agents emit LOCK/UNLOCK/WARNING/HANDOFF
    // which prove they are running even without a formal heartbeat.
    const liveOps = new Set(['CHECKIN', 'HEARTBEAT', 'LOCK', 'UNLOCK', 'HANDOFF', 'WARNING', 'RESOLUTION', 'INTEGRATOR_VALIDATION']);
    const lastBeat  = [...events].reverse().find(e => liveOps.has(e.operation));
    const errors    = events.filter(e => e.operation === 'ERROR');
    const warnings  = events.filter(e => e.operation === 'WARNING');
    const lastError = errors[errors.length - 1];
    const lastWarn  = warnings[warnings.length - 1];

    // Cross-reference Recently Completed table for explicit Started/Finished
    const completedRow = recentlyCompleted.find(r => r.agent_id === member.id);
    const activeRow    = activeAgents.find(r => r.agent_id === member.id);

    const startedAt  = (checkin && checkin.timestamp)
                    || (completedRow && completedRow.started)
                    || (activeRow && activeRow.started)
                    || null;
    const finishedAt = (checkout && checkout.timestamp)
                    || (completedRow && completedRow.finished)
                    || null;

    let status = 'PENDING';
    let checkoutStatus = null;
    if (checkout) {
      checkoutStatus = (checkout.fields && checkout.fields.status) || (completedRow && completedRow.status) || 'DONE';
      status = checkoutStatus;
    } else if (completedRow) {
      checkoutStatus = completedRow.status;
      status = completedRow.status;
    } else if (checkin) {
      status = 'IN_PROGRESS';
      // Heartbeat freshness override
      if (lastBeat) {
        const ageMs = now - new Date(lastBeat.timestamp).getTime();
        if (ageMs > DEAD_MS) status = 'DEAD';
        else if (ageMs > STALE_MS) status = 'STALE';
      }
    }

    // Duration
    let durationMs = null;
    if (startedAt && finishedAt) {
      const a = new Date(startedAt).getTime();
      const b = new Date(finishedAt).getTime();
      if (!isNaN(a) && !isNaN(b)) durationMs = b - a;
    } else if (startedAt && !finishedAt && status === 'IN_PROGRESS') {
      durationMs = now - new Date(startedAt).getTime();
    }

    // Rerun heuristic:
    //   needs_rerun = true if last CHECKOUT had status = BLOCKED with reason != external dependency wait
    //                 OR if there is an ERROR after last CHECKIN with no later RESOLUTION
    let needsRerun = false;
    let rerunReason = null;
    if (checkoutStatus === 'BLOCKED') {
      const reason = (checkout && checkout.fields && checkout.fields.reason) || (completedRow && completedRow.deliverables) || '';
      const isDependencyWait = /waiting on|integrator|depend|prereq|requires?\b|handoff not present|not yet\s+(?:available|present)|absent|blocked on|track [A-Z]\.\d|track\s+[A-Z]\b/i.test(reason);
      if (!isDependencyWait) {
        needsRerun = true;
        rerunReason = reason || 'BLOCKED checkout without dependency wait reason';
      } else {
        rerunReason = 'BLOCKED on dependency: ' + reason;
      }
    }
    if (status === 'DEAD') {
      needsRerun = true;
      rerunReason = 'No heartbeat for >10 min';
    }
    if (lastError) {
      const laterResolution = events.find(e => e.operation === 'RESOLUTION' && new Date(e.timestamp) > new Date(lastError.timestamp));
      if (!laterResolution) {
        needsRerun = true;
        rerunReason = (rerunReason ? rerunReason + '; ' : '') + 'Unresolved ERROR in log';
      }
    }

    return {
      order: idx + 1,
      id: member.id,
      family: member.family,
      model: member.model,
      tracks: member.tracks,
      prompt_id: member.prompt_id,
      status,
      checkout_status: checkoutStatus,
      started_at: startedAt,
      finished_at: finishedAt,
      duration_ms: durationMs,
      last_seen: lastBeat ? lastBeat.timestamp : null,
      heartbeat_age_seconds: lastBeat ? Math.round((now - new Date(lastBeat.timestamp).getTime()) / 1000) : null,
      error_count: errors.length,
      warning_count: warnings.length,
      last_error: lastError ? { timestamp: lastError.timestamp, raw: lastError.raw } : null,
      last_warning: lastWarn ? { timestamp: lastWarn.timestamp, raw: lastWarn.raw } : null,
      needs_rerun: needsRerun,
      rerun_reason: rerunReason,
      deliverables: completedRow ? completedRow.deliverables : null
    };
  });

  // Roll-up KPIs
  const kpis = {
    total: fleet.length,
    pending: fleet.filter(a => a.status === 'PENDING').length,
    in_progress: fleet.filter(a => a.status === 'IN_PROGRESS' || a.status === 'STALE').length,
    done: fleet.filter(a => a.status === 'DONE').length,
    ready_for_review: fleet.filter(a => a.status === 'READY_FOR_REVIEW').length,
    blocked: fleet.filter(a => a.status === 'BLOCKED').length,
    dead: fleet.filter(a => a.status === 'DEAD').length,
    needs_rerun: fleet.filter(a => a.needs_rerun).length
  };

  return { fleet, kpis };
}

// ---------------------------------------------------------
// HTTP Server
// ---------------------------------------------------------

const server = http.createServer(async (req, res) => {
  const reqTime = Date.now();
  const parsedUrl = new URL(req.url, `http://${config.host}:${config.port}`);
  const pathname = parsedUrl.pathname;

  res.setHeader('Access-Control-Allow-Origin', '*');

  let status = 200;
  let responseData = null;
  let isJson = true;

  try {
    if (pathname === '/api/health') {
      responseData = {
        status: "ok",
        version: "1.0.0",
        uptime_seconds: process.uptime(),
        server_time: new Date().toISOString()
      };
    } else if (pathname === '/api/cockpit/snapshot') {
      const cb = await parseCheckinBoard();
      const al = await parseActivityLog(null, 50);
      const phasesState = cb ? cb.phase_tracker : [];
      let current_phase = 1;

      const { fleet, kpis: fleetKpis } = await buildFleet();

      // Backwards-compatible "agents" array (used by other views)
      const agents = fleet.map(f => ({
        id: f.id,
        status: f.status,
        phase: current_phase,
        current_task: f.tracks,
        heartbeat_status: f.status === 'DEAD' ? 'dead'
                         : f.status === 'STALE' ? 'stale'
                         : f.status === 'IN_PROGRESS' ? 'alive'
                         : f.status === 'DONE' || f.status === 'READY_FOR_REVIEW' ? 'done'
                         : 'idle'
      }));

      responseData = {
        snapshot_time: new Date().toISOString(),
        kpis: {
          active_agents: fleetKpis.in_progress,
          total_agents: fleetKpis.total,
          tasks_done_current_phase: fleetKpis.done + fleetKpis.ready_for_review,
          tasks_in_progress: fleetKpis.in_progress,
          tasks_blocked: fleetKpis.blocked,
          tasks_pending: fleetKpis.pending,
          tasks_needs_rerun: fleetKpis.needs_rerun,
          tasks_dead: fleetKpis.dead,
          current_phase: current_phase,
          current_phase_progress_pct: Math.round(((fleetKpis.done + fleetKpis.ready_for_review) / fleetKpis.total) * 100),
          project_eta_iso: ""
        },
        fleet,
        fleet_kpis: fleetKpis,
        agents,
        recent_activity: al.entries,
        phase_state: {
          current_phase,
          phases: phasesState
        }
      };
    } else if (pathname === '/api/fleet') {
      responseData = await buildFleet();
    } else if (pathname === '/api/agents/roster') {
       const cb = await parseCheckinBoard();
       responseData = { agents: cb ? cb.active_agents_table : [] };
    } else if (pathname === '/api/checkin-board') {
       responseData = await parseCheckinBoard();
    } else if (pathname === '/api/activity-log') {
       const since = parsedUrl.searchParams.get('since');
       const limit = parseInt(parsedUrl.searchParams.get('limit')) || config.activity_log_default_limit;
       responseData = await parseActivityLog(since, limit);
    } else if (pathname === '/api/file-locks') {
       responseData = await parseFileLocks();
    } else if (pathname === '/api/handoffs') {
       responseData = await parseHandoffs();
    } else if (pathname === '/api/prompts/list') {
       responseData = await getPrompts();
    } else if (pathname.startsWith('/api/prompts/') && pathname.endsWith('/content')) {
       const id = pathname.split('/')[3];
       if (!/^[a-z0-9_]+$/.test(id)) {
          status = 404;
          responseData = { error: "Invalid prompt ID" };
       } else {
          try {
             const fp = path.join(PHASES_DIR, '01_discovery', 'dispatch', id + '.md');
             const content = await fsPromises.readFile(fp, 'utf-8');
             const stat = await fsPromises.stat(fp);
             responseData = {
                id,
                content,
                size_bytes: stat.size,
                last_modified: stat.mtime.toISOString()
             };
          } catch(e) {
             status = 404;
             responseData = { error: "Not found" };
          }
       }
    } else if (pathname === '/api/phases/state') {
       const cb = await parseCheckinBoard();
       responseData = {
          current_phase: 1,
          phases: cb ? cb.phase_tracker : []
       };
    } else {
       // Serve static files
       let fp = path.join(__dirname, pathname === '/' ? 'index.html' : pathname);
       try {
          const stat = await fsPromises.stat(fp);
          if (stat.isDirectory()) {
             fp = path.join(fp, 'index.html');
             await fsPromises.stat(fp);
          }
          const ext = path.extname(fp).toLowerCase();
          const mime = {
             '.html': 'text/html; charset=utf-8',
             '.js': 'text/javascript; charset=utf-8',
             '.css': 'text/css; charset=utf-8',
             '.json': 'application/json; charset=utf-8',
             '.png': 'image/png',
             '.svg': 'image/svg+xml; charset=utf-8'
          }[ext] || 'application/octet-stream';
          
          res.setHeader('Content-Type', mime);
          const rs = fs.createReadStream(fp);
          rs.pipe(res);
          console.log(`[${new Date().toISOString()}] GET ${pathname} 200 ${Date.now()-reqTime}ms`);
          return;
       } catch (e) {
          status = 404;
          responseData = { error: "Not found" };
       }
    }
  } catch (err) {
    status = 500;
    responseData = { error: "Internal Server Error" };
    console.error(`[${new Date().toISOString()}] Server Error:`, err);
  }

  if (isJson && responseData !== null) {
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.writeHead(status);
    res.end(JSON.stringify(responseData));
  } else if (responseData !== null) {
    res.writeHead(status);
    res.end(responseData);
  }
  
  console.log(`[${new Date().toISOString()}] GET ${pathname} ${status} ${Date.now()-reqTime}ms`);
});

if (require.main === module) {
  server.listen(config.port, config.host, () => {
    console.log(`[${new Date().toISOString()}] PMO Cockpit Server v1.0.0`);
    console.log(`[${new Date().toISOString()}] Listening on http://${config.host}:${config.port}`);
    console.log(`[${new Date().toISOString()}] Watching governance: ${GOV_DIR}`);
    console.log(`[${new Date().toISOString()}] Ready.`);
  });
}

module.exports = {
  parseCheckinBoard,
  parseActivityLog,
  parseFileLocks,
  parseHandoffs,
  getPrompts,
  buildFleet,
  FLEET_ROSTER,
  server
};
