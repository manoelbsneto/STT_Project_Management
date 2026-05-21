# GEMINI FLASH 3.5 — PMO Cockpit Build & Deploy

**Agent ID:** GEMINI-FLASH-COCKPIT
**Date:** 2026-05-20
**Project sub-initiative:** PMO Cockpit (M2 monitoring tool)
**Role:** Senior Fullstack Developer + DevOps + QA
**Architect:** Opus 4.7 (specification authored)
**Owner:** Manoel Benicio
**Target deployment:** `D:\VMs\Projetos\STT_Project_Management\Web_MD_Viewer\`
**Time budget:** 4-6 hours hard limit

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT. Use ONLY this prompt + referenced files. Treat as fresh first encounter.

This task is INDEPENDENT from the M2 milestone agent fleet. You are NOT one of the 12 M2 phase 1 agents. You build the monitoring tool that will observe them.

---

## Mandatory Read-Before-Start

```text
.planning/cockpit/SPECIFICATION.md  ← FULL SPEC (1100+ lines, read end-to-end)
Web_MD_Viewer/index.html            ← existing entry point (you'll transform it)
Web_MD_Viewer/styles.css            ← preserve as-is
Web_MD_Viewer/viewer.css            ← preserve as-is
Web_MD_Viewer/viewer.js             ← preserve as-is, may import from
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_BOARD.md
.planning/milestones/M2_card_first_revision_v2/governance/ACTIVITY_LOG.md
.planning/milestones/M2_card_first_revision_v2/governance/FILE_LOCK_TABLE.md
.planning/milestones/M2_card_first_revision_v2/governance/HANDOFF_LOG.md
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/dispatch/README.md
.planning/AGENT_CONTRACT.md
```

In your first response, confirm each of those 12 files was read.

---

## Hard Constraints

- **Use ONLY Node.js 18+ built-in modules** in `cockpit-server.js`. Zero npm dependencies. No `npm install` required.
- **Do NOT modify** `styles.css`, `viewer.css`, or `viewer.js`. They are preserved as-is.
- **Do NOT delete** the existing `index.html` — backup it first as `index_legacy_backup.html`.
- **Bind server to 127.0.0.1 only** (NEVER 0.0.0.0).
- **Read-only on all server endpoints** — no POST/PUT/DELETE in v1.
- **Markdown rendering**: reuse the existing `viewer.js` pipeline (marked + DOMPurify + highlight.js). Do not introduce new markdown libraries.
- **No external CDN required at runtime** beyond what `viewer.js` already loads. Cockpit must work offline if browser cached the libs.
- **Browser support**: Chrome/Edge/Firefox latest 2 versions. No IE.
- **Accessibility WCAG 2.1 AA mandatory** — color contrast, keyboard nav, ARIA roles, status conveyed by text+icon+color.
- **No authentication** in v1 (single-user localhost).
- **Path traversal protection** on `/api/prompts/<id>/content` — whitelist regex `^[a-z0-9_]+\.md$` and resolve against dispatch dir.

---

## Deliverables (12 files)

```
D:\VMs\Projetos\STT_Project_Management\Web_MD_Viewer\
├── index.html                 (TRANSFORMED per spec §9)
├── index_legacy_backup.html   (NEW — copy of original index.html)
├── styles.css                 (UNCHANGED — preserve)
├── viewer.css                 (UNCHANGED — preserve)
├── viewer.js                  (UNCHANGED — preserve)
├── cockpit.css                (NEW — additive cockpit styles per spec §4)
├── cockpit.js                 (NEW — orchestrator + state mgmt per spec §8)
├── cockpit-server.js          (NEW — Node http server per spec §7)
├── cockpit-config.json        (NEW — port/host/polling config)
├── package.json               (NEW — npm metadata only, no deps)
├── README.md                  (NEW — quickstart per spec §11)
└── tests/
    ├── test_cockpit_parsers.js     (NEW)
    ├── test_cockpit_renderers.js   (NEW)
    ├── test_cockpit_state.js       (NEW)
    ├── test_server_endpoints.js    (NEW)
    ├── test_server_path_traversal.js (NEW)
    └── test_server_health.js       (NEW)
```

Total new: 1 transformed + 1 backup + 5 new code files + 1 README + 1 config + 1 package.json + 6 test files = 16 files written.

---

## Build Sequence (recommended order)

### Step 1 — Backup + understand (15 min)

1. Copy `Web_MD_Viewer/index.html` → `Web_MD_Viewer/index_legacy_backup.html` (untouched).
2. Read full spec end-to-end.
3. Inspect the 5 governance files in M2 to understand the parsers' input data.

### Step 2 — Backend (90 min)

Build `cockpit-server.js` per spec §7. Implement endpoints in this order:
1. `GET /api/health` (proves server runs)
2. `GET /` and static asset serving
3. `GET /api/agents/roster` (parses CHECKIN_BOARD.md Active Agents)
4. `GET /api/checkin-board` (full parse)
5. `GET /api/activity-log?since=&limit=&filter=`
6. `GET /api/file-locks`
7. `GET /api/handoffs`
8. `GET /api/prompts/list`
9. `GET /api/prompts/<id>/content`
10. `GET /api/phases/state`
11. `GET /api/cockpit/snapshot` (composes from above)

Test each endpoint as you go using `curl http://localhost:7777/api/health`.

Implement caching (2s TTL) and ETags last.

### Step 3 — Frontend HTML structure (30 min)

Transform `index.html` per spec §9:
- Replace sidebar nav with new 7 items
- Replace main content with 6 view divs
- Add polling indicator
- Keep top bar branding + theme toggle

### Step 4 — Frontend CSS (45 min)

Build `cockpit.css` additive over existing styles per spec §4. Include:
- KPI sparklines
- Agent card layout (CSS grid auto-fit)
- Heartbeat pulse animation
- Status badge variants (READY, IN_PROGRESS, BLOCKED, DEAD, etc.)
- Activity feed entry styling
- Phase tracker stepper
- Reduced motion respect

### Step 5 — Frontend JS — orchestrator + dashboard view (60 min)

Build `cockpit.js`:
1. Module pattern with `init()` entry
2. Polling loop (5s default, configurable)
3. State management
4. `renderDashboard()` — KPI cards + recent activity strip
5. Hash-based navigation
6. Polling progress bar animation

### Step 6 — Frontend JS — remaining views (90 min)

Implement in priority order (each ~15-20 min):
- `renderAgentRoster()` (FR-02)
- `renderActivityFeed()` (FR-03) with filters
- `renderPhaseTracker()` (FR-04)
- `renderPromptsLibrary()` (FR-06) — uses `viewer.js` for markdown
- `renderHandoffMap()` (FR-05) — SVG-based, fixed positions for v1
- Active Prompt Detail modal (FR-07)
- Global search (FR-09)
- Export snapshot (FR-10)

### Step 7 — Tests (45 min)

Implement 6 test files per spec §10. Use Node 18 built-in test runner:

```javascript
import { test } from 'node:test';
import assert from 'node:assert';

test('CHECKIN_BOARD parser extracts active agents', () => {
  const sample = `## Active Agents (right now)\n\n| Agent ID | ... |`;
  const result = parseCheckinBoard(sample);
  assert.strictEqual(result.active_agents_table.length, 2);
});
```

Run: `node --test tests/`

### Step 8 — Smoke test against live data (30 min)

1. Start server: `node cockpit-server.js`
2. Open browser at `http://localhost:7777`
3. Verify all 6 views render
4. Manually edit `governance/ACTIVITY_LOG.md` with a new entry → verify appears in cockpit within 5s
5. Click around: agent → prompt detail → back → filter → search
6. Test export snapshot
7. Test stop server → reconnect

### Step 9 — Self-validation against acceptance criteria (15 min)

Run through all 22 hard gates in spec §12. For each, mark PASS/FAIL with evidence. Any FAIL → fix before declaring done.

### Step 10 — Documentation + handoff (15 min)

1. Write `README.md` per spec §11
2. Write `cockpit-config.json`
3. Write `package.json` per spec §11
4. Final commit summary

---

## Acceptance Criteria — Final Gate

You will run these checks yourself before declaring DONE:

### Functional (must all PASS)

- [ ] Server starts with single `node cockpit-server.js` command, no errors
- [ ] All 10 API endpoints return 200 with expected JSON shape
- [ ] `/api/prompts/../../etc/passwd` returns 404, not 500 or file content
- [ ] All 6 views render without console errors
- [ ] Polling indicator visibly animates every 5s
- [ ] Activity feed updates within 5s of governance file change
- [ ] All 13 agent cards display when CHECKIN_BOARD has 13 entries
- [ ] DEAD agent (>10min no heartbeat) shown in red with warning
- [ ] Phase tracker stepper reflects phase status correctly
- [ ] Click on agent card → prompt detail modal opens
- [ ] Filter on activity feed reduces visible entries immediately
- [ ] Filter on agent roster works
- [ ] Theme toggle still works (preserved)
- [ ] Legacy MD viewer accessible via `#legacy` nav item
- [ ] Export snapshot downloads valid JSON

### Non-functional

- [ ] Initial page load <800ms
- [ ] Polling round-trip <150ms
- [ ] Memory usage server <50MB after 1h
- [ ] No console warnings on Chrome 110+, Firefox 110+
- [ ] WCAG 2.1 AA contrast verified (manual check on key elements)
- [ ] Keyboard navigation reaches every interactive element
- [ ] `prefers-reduced-motion: reduce` respected

### Tests

- [ ] `node --test tests/` returns exit code 0
- [ ] All 6 test files have at least 3 test cases each
- [ ] Tests cover happy path + edge case + error case

### Robustness

- [ ] Server graceful when governance dir doesn't exist (returns empty state, not crash)
- [ ] Server graceful when activity log has malformed entries (skips with warning)
- [ ] Browser shows "Connection lost" banner when server stops, reconnects when server restarts
- [ ] Browser refresh re-renders without losing nav state (URL hash preserved)

---

## Constraints on YOUR work

- Do NOT call out to external APIs.
- Do NOT use `npm install`.
- Do NOT modify any `.planning/` file (read only).
- Do NOT modify any `.planning/milestones/M2_card_first_revision_v2/` file (read only — including governance files).
- Do NOT execute or trigger any of the M2 phase 1 agent prompts.
- Do NOT modify the existing `index.html` until you have backed it up to `index_legacy_backup.html`.
- Do NOT introduce new fonts, colors, or design tokens beyond what spec §4 defines.
- Do NOT use any framework (React, Vue, Svelte, etc.).
- Do NOT use any bundler (webpack, esbuild, vite, etc.).
- Do NOT use TypeScript.
- Do NOT use any preprocessor (Sass, Less, etc.).

The cockpit must run with: `node cockpit-server.js` and a browser. That's it.

---

## Submission Protocol

When DONE:

1. Write a final report file:
   `Web_MD_Viewer/BUILD_REPORT_20260520.md`
   
   Containing:
   - Files delivered (with sizes)
   - Test results (`node --test tests/` output)
   - Acceptance criteria checklist with PASS/FAIL per item
   - Any deviations from spec (with justification)
   - Performance measurements (load time, polling latency, memory)
   - Screenshots or descriptions of each of 6 views
   - Known limitations / future work suggestions

2. Print to terminal: `BUILD COMPLETE — see Web_MD_Viewer/BUILD_REPORT_20260520.md`

3. Stand down. Do not start Phase 1 dispatch — that's the Owner's job after cockpit is verified working.

---

## Time Budget Breakdown

| Step | Estimate | Cumulative |
|---|---:|---:|
| 1 — Backup + read | 15 min | 0:15 |
| 2 — Backend | 90 min | 1:45 |
| 3 — HTML structure | 30 min | 2:15 |
| 4 — CSS | 45 min | 3:00 |
| 5 — JS orchestrator + dashboard | 60 min | 4:00 |
| 6 — JS remaining views | 90 min | 5:30 |
| 7 — Tests | 45 min | 6:15 |
| 8 — Smoke test | 30 min | 6:45 |
| 9 — Self-validation | 15 min | 7:00 |
| 10 — Docs + report | 15 min | 7:15 |

**Hard limit: 8 hours.**

If you exceed step 6 by >20% (i.e., still in step 6 at 6h mark), trigger an early checkpoint to Owner — partial deploy is fine for v1 if dashboard + agent roster + activity feed are working; phase tracker / handoff map / prompts library can ship as v1.1.

---

## Begin

1. Confirm 12 mandatory references read (especially the full SPECIFICATION.md)
2. Acknowledge hard constraints
3. Execute Steps 1-10 in order
4. Submit BUILD_REPORT
