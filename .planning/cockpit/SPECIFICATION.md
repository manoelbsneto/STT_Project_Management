# PMO Cockpit — Architectural Specification

**Project:** Indra Intelligence PMO Cockpit
**Author:** Opus 4.7 (Principal Solutions Architect + UI/UX Lead + Senior Fullstack + QA Lead + DevOps Lead)
**Date:** 2026-05-20 18:33 BRT
**Status:** Spec Locked — Ready for Build
**Build owner:** Gemini Flash 3.5 (delivery)
**Target deployment:** `D:\VMs\Projetos\STT_Project_Management\Web_MD_Viewer\`
**Reused base:** existing `index.html` + `styles.css` + `viewer.css` + `viewer.js` (Indra Intelligence design system)

---

## 1. Executive Summary

### What it is

The **PMO Cockpit** is a single-pane-of-glass real-time monitoring dashboard for the M2 multi-agent execution. It lets the Owner (and architect) see at any moment:

- Which agents are active right now (out of 13)
- What task each agent is doing
- Heartbeat status (alive / dead / blocked)
- Phase progress (1 through 9)
- File lock collisions
- Cross-agent handoffs
- Full audit timeline
- Dispatch prompt library with execution status

### Why it matters

13 agents in parallel across 3 AI models on a 4-day project = chaos without observability. Without a cockpit, the Owner cannot:
- Detect dead agents within the 10-minute SLA
- Verify protocol compliance (CHECK-IN, HEARTBEAT, FILE LOCK)
- Drive Phase gate decisions with confidence
- Audit agent behavior for compliance / forensics
- Communicate progress to stakeholders professionally

The cockpit gives Fortune 500-level operational visibility on a desktop tool, no cloud required.

### Outcome (Definition of Done)

A web page accessible at `http://localhost:7777` that shows real-time M2 governance state, polled every 5 seconds, served by a small local Node.js server. Owner opens it, leaves it on second monitor, has total control.

---

## 2. Personas

### P1 — Owner (Manoel) — Primary user

**Goals:** Monitor 13 agents, approve gates, detect issues fast, ship M2.

**Pain points (without cockpit):**
- Reading raw markdown logs is slow
- Easy to miss a dead agent
- No clear "where are we" view
- No cross-agent dependency visibility

**Cockpit primary use:**
- Dashboard view as default — all KPIs at glance
- Click on agent → drill into their activity
- Click on phase → see what's blocking
- Filter activity log when investigating

### P2 — Architect (Opus 4.7) — Secondary

**Goals:** Validate agent compliance, write next phase specs, make decisions.

**Pain:** Same as owner, plus needs cross-phase trends.

### P3 — Stakeholder (future) — View-only

**Goals:** During smoke / cutover, see status without disturbing.

**Cockpit use:** Read-only mode (can be activated by URL param `?role=viewer`).

---

## 3. Architecture Overview

### Component diagram

```
┌──────────────────────────────────────────────────────────┐
│  Browser (Chrome/Edge — desktop)                         │
│  ┌─────────────────────────────────────────────────┐     │
│  │  index.html (Cockpit shell)                     │     │
│  │  ├── styles.css (base — Indra design system)    │     │
│  │  ├── viewer.css (typography/markdown)           │     │
│  │  ├── cockpit.css (NEW additive)                 │     │
│  │  ├── viewer.js (markdown engine — reused)       │     │
│  │  └── cockpit.js (NEW orchestrator + state mgmt) │     │
│  └─────────────────────────────────────────────────┘     │
│              ▲                                           │
│              │ Fetch every 5s                            │
└──────────────┼───────────────────────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────────────────────┐
│  cockpit-server.js (Node.js, http only — NO npm deps)    │
│  Port: 7777                                              │
│  Endpoints:                                              │
│   GET /api/cockpit/snapshot         (full state)         │
│   GET /api/agents/roster            (13 agents)          │
│   GET /api/checkin-board            (parsed)             │
│   GET /api/activity-log?since=&limit=                    │
│   GET /api/file-locks                                    │
│   GET /api/handoffs                                      │
│   GET /api/prompts/list                                  │
│   GET /api/prompts/<id>/content                          │
│   GET /api/phases/state                                  │
│   GET /api/health                                        │
│   GET /                              (serves index.html) │
│   GET /<asset>                       (serves css/js)     │
└──────────────┬───────────────────────────────────────────┘
               │ fs.readFile (no watcher for v1)
               ▼
┌──────────────────────────────────────────────────────────┐
│  Filesystem                                              │
│  .planning/milestones/M2_card_first_revision_v2/         │
│    governance/                                           │
│      ├── CHECKIN_BOARD.md          (live snapshot)       │
│      ├── ACTIVITY_LOG.md           (append-only)         │
│      ├── FILE_LOCK_TABLE.md        (locks)               │
│      ├── HANDOFF_LOG.md            (handoffs)            │
│      └── CHECKIN_CHECKOUT_PROTOCOL.md (rules)            │
│    phases/01_discovery/                                  │
│      ├── SPEC.md                                         │
│      ├── HANDOFF.md                (when phase ends)     │
│      └── dispatch/                                       │
│          ├── README.md             (index)               │
│          └── *.md                  (12 prompts)          │
│    PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md     │
└──────────────────────────────────────────────────────────┘
```

### Tech stack

| Layer | Choice | Rationale |
|---|---|---|
| Backend | Node.js 18+ built-in `http` + `fs` modules | Zero npm dependencies → trivial to ship, no security audit overhead, works offline |
| Frontend | Vanilla JS (no framework) | Reuses existing `viewer.js`. No React/Vue overhead. Single dev (Gemini Flash) can ship fast. |
| Markdown rendering | Existing `viewer.js` (marked + DOMPurify + highlight.js via CDN with fallback) | Already in project, premium quality |
| Charting | Pure SVG inline (no chart.js) | Already done in existing `viewer.js`. Lightweight. |
| State management | Plain JS module pattern + polling loop | No Redux. Simple. |
| Real-time mechanism | Polling 5s (configurable) | WebSocket overkill for 1 user; polling simpler + safer |
| Authentication | None for v1 (localhost-only, single user) | Security is OS-level (only local user accesses) |

### Data flow

```
Agent writes to ACTIVITY_LOG.md
       ↓ (filesystem)
Server reads files on each /api/* request
       ↓ parses → JSON
Browser polls every 5s → updates DOM
       ↓
Owner sees update within 5s of write
```

No file watcher needed for v1. Polling 5s gives "near real-time" feel without complexity.

### Concurrency considerations

- Server reads are read-only (`fs.readFileSync` or async). Multiple agents writing simultaneously to ACTIVITY_LOG.md (which is append-only) is safe per protocol design — agents never overwrite, only append.
- Race conditions on CHECKIN_BOARD.md table updates: out of scope for cockpit (governance protocol handles it via timestamp-wins).
- Server graceful handling of partial writes (file truncated mid-read): try-catch + retry next poll.

---

## 4. UI / UX Design System

### Reused tokens (from `styles.css`)

```css
--indra-deep:    /* deep navy/black */
--indra-cyan:    /* primary accent */
--indra-teal:    /* secondary accent */
--indra-success: /* green */
--indra-warning: /* amber */
--indra-error:   /* red */
--indra-light:   /* muted text */
--ease-out:      /* motion easing */
```

### New tokens (cockpit-specific)

```css
--cockpit-agent-active:  hsl(170 80% 50%);  /* cyan-green */
--cockpit-agent-idle:    hsl(220 15% 45%);  /* dimmed */
--cockpit-agent-blocked: hsl(35 100% 60%);  /* amber */
--cockpit-agent-dead:    hsl(0 75% 55%);    /* red */
--cockpit-agent-done:    hsl(140 65% 50%);  /* solid green */

--cockpit-card-bg:       rgba(255,255,255,0.03);
--cockpit-card-border:   rgba(255,255,255,0.06);
--cockpit-card-hover:    rgba(255,255,255,0.05);

--cockpit-grid-gap:      16px;
--cockpit-pulse-anim:    cockpit-pulse 2s var(--ease-out) infinite;
```

### Typography

- Inter (already loaded) for UI
- JetBrains Mono (already loaded) for code/timestamps
- Sizes: 11px (caption), 13px (body), 15px (subtitle), 18px (title), 24px (heading), 36px (KPI value)

### Layout grid

```
┌─────────────────────────────────────────────────────────┐
│  TOP BAR (h: 56px)                                      │
├──────┬──────────────────────────────────────────────────┤
│      │                                                  │
│      │  MAIN VIEW (variable per active nav item)       │
│      │                                                  │
│ SIDE │  ┌─────────────────────────────────────────┐     │
│ NAV  │  │  KPI ROW (h: 120px)                    │     │
│      │  └─────────────────────────────────────────┘     │
│ 248px│  ┌─────────────────────────────────────────┐     │
│      │  │  GRID (agents / activity / etc.)       │     │
│      │  │  flex-grow: 1                          │     │
│      │  └─────────────────────────────────────────┘     │
│      │                                                  │
└──────┴──────────────────────────────────────────────────┘
```

### Motion principles

- Heartbeat indicator: pulsing dot (2s cycle, opacity 1 → 0.4)
- New activity entry: slide-in-from-top (200ms)
- Agent status change: color crossfade (300ms)
- Phase transition: progress bar fill (500ms ease-out)
- All animations respect `prefers-reduced-motion: reduce`

### Accessibility (WCAG 2.1 AA)

- Color contrast: all text ≥4.5:1 (verified against `--indra-deep` background)
- Keyboard navigation: all interactive elements tab-focusable
- Screen reader: ARIA roles + live regions for activity feed
- Status communicated by both color AND text (no color-only signals)
- Focus indicators: visible 2px ring on `--indra-cyan`

---

## 5. Functional Requirements

### FR-01 — Cockpit Overview (Default View)

**Path:** `/` (URL hash: `#dashboard`)
**Layout:** KPI Row + Live Activity Feed (right) + Agent Quick Status Strip (bottom)

KPI cards (5 total):

| KPI | Source | Refresh | Color |
|---|---|---|---|
| Active Agents | `CHECKIN_BOARD.md` Active Agents row count | 5s | cyan |
| Tasks DONE this phase | `ACTIVITY_LOG.md` count of CHECKOUT with status: DONE in current phase | 5s | success |
| Tasks BLOCKED | `ACTIVITY_LOG.md` count of CHECKOUT with status: BLOCKED | 5s | warning |
| Phase progress | `CHECKIN_BOARD.md` Phase Tracker section | 10s | cyan |
| Project ETA | computed from current phase + remaining phases × estimated effort | 30s | teal |

Each card shows:
- Number / value
- Trend arrow (↑ ↓ →) compared to last poll
- Mini sparkline (last 12 polls = 1 minute history)
- Click → drill-down view

### FR-02 — Agent Roster Grid

**Path:** `/agents` (URL hash: `#agents`)
**Layout:** 13 cards in CSS grid (auto-fit, minmax(280px, 1fr))

Each agent card displays:

```
┌──────────────────────────────────┐
│ ● CODEX-1-LEAD       [IN_PROG.] │
│   Codex 5.5 · Track A.1+A.2     │
│ ─────────────────────────────── │
│ Heartbeat: ● 2s ago              │
│ Progress: ▓▓▓▓▓░░░░ 52%          │
│ Step: Extracting topic inventory │
│ ─────────────────────────────── │
│ Locked files: 1                  │
│ Last action: HEARTBEAT @ 18:35   │
│                  [View prompt →] │
└──────────────────────────────────┘
```

Status badge colors:
- `READY` — gray
- `CLAIMED` — blue
- `IN_PROGRESS` — cyan with pulse animation
- `BLOCKED` — amber
- `DONE` — solid green
- `DEAD` — red with warning icon
- `REWORK` — orange
- `CANCELLED` — gray strikethrough

Heartbeat indicator:
- Green dot if last heartbeat <5min ago
- Amber if 5-10min
- Red if >10min (DEAD)

Filter bar at top:
- All / Active / Blocked / Dead / Done
- By model: Codex / Opus / Gemini / Owner
- By phase: 1-9
- Search by Agent ID

### FR-03 — Live Activity Feed

**Path:** `/activity` (URL hash: `#activity`)
**Layout:** Vertical streaming list, newest at top

Each entry:

```
[18:35:42] HEARTBEAT  CODEX-1-LEAD
  task A.1+A.2 · progress 52% · extracting topics
```

Entry visual treatment:
- Operation type as colored chip (CHECKIN=blue, HEARTBEAT=cyan, LOCK=amber, UNLOCK=green, CHECKOUT=teal, HANDOFF=purple, OWNER_*=indra-cyan, ERROR=red)
- Agent ID as bold mono text
- Timestamp in JetBrains Mono, dimmer color
- Click entry → expand for full context

Auto-refresh every 5s. New entries slide in from top with 200ms animation.

Filter bar:
- By operation type (multi-select)
- By agent (multi-select)
- By time range (last 5min, 30min, 1h, 4h, all)
- Search free text

Pagination: load last 100 by default; "Load more" button for older.

### FR-04 — Phase Tracker

**Path:** `/phases` (URL hash: `#phases`)
**Layout:** Horizontal stepper + per-phase detail panel

Stepper:

```
[●]──[●]──[○]──[ ]──[ ]──[ ]──[ ]──[ ]──[ ]
P1   P2   P3   P4   P5   P6   P7   P8   P9
DONE READY ...
```

Phase states:
- `DONE` — solid filled circle, green
- `IN_PROGRESS` — pulsing cyan circle
- `READY` — empty circle, ready border
- `WAITING` — empty circle, dimmed
- `BLOCKED` — circle with red X

Click on phase → detail panel below:
- Phase name + goal
- Effort estimate vs actual
- Tasks: total / done / in-progress / blocked
- Active agents in this phase
- Handoff log filtered to this phase
- Owner gates (if any)

### FR-05 — Handoff Map

**Path:** `/handoffs` (URL hash: `#handoffs`)
**Layout:** SVG graph visualization (force-directed or DAG layout)

- Nodes = agents (13 total)
- Edges = handoffs from `HANDOFF_LOG.md` (directional with arrow)
- Edge thickness = number of handoffs
- Edge color = recency (recent=cyan, old=dim)
- Node size = activity count (more active = larger)

Click on edge → list of handoff entries between those 2 agents.
Click on node → filter activity feed to that agent.

For v1, can ship as SVG with manual layout (positions defined by phase). Force-directed layout = nice-to-have for v2.

### FR-06 — Prompts Library

**Path:** `/prompts` (URL hash: `#prompts`)
**Layout:** File tree (left) + content pane (right)

File tree:
```
M2 Phase 1 Dispatch (12 prompts)
├── codex1_lead.md            [DONE]
├── codex1_sub_a.md           [IN_PROGRESS]
├── codex1_sub_b.md           [READY]
├── codex1_sub_c.md           [READY]
├── codex2_lead.md            [READY]
├── ... (etc.)
└── README.md (index)
```

Each entry has badge showing execution status (joined from CHECKIN_BOARD).

Content pane: rendered markdown using existing `viewer.js`.

Toolbar above content:
- "Copy to clipboard" button
- "Open in OS editor" button
- "View agent activity" button (jumps to activity feed filtered by that agent)

### FR-07 — Active Prompt Detail (Drill-down from Agent Card)

When user clicks "View prompt →" on an agent card:
- Opens modal or full-screen view
- Left: rendered prompt markdown
- Right: agent's activity timeline filtered
- Top: agent status header

### FR-08 — Real-time Refresh

- Default polling interval: 5 seconds
- Configurable via URL param `?refresh=10` (in seconds, range 1-60)
- Visual indicator when polling: subtle progress bar at top of page (1px height, fills over 5s)
- When server unreachable: show banner "Connection lost — retrying in 5s. Last update: HH:MM:SS"
- Manual refresh button in top bar

### FR-09 — Filter & Search

Global search (top bar) searches across:
- Agent IDs
- Task IDs
- File paths in locks
- Activity log entries
- Prompt content

Results grouped by source.

### FR-10 — Export / Snapshot

Top bar action: "Export current state"
- Downloads JSON file with full snapshot at click time
- Filename: `cockpit_snapshot_<timestamp>.json`
- Useful for archival, post-mortem, sharing

---

### FR-11 — Dispatch Console (Mission Control) ← **PRIMARY view, default landing page**

**Path:** `/dispatch` (URL hash: `#dispatch`)
**Importance:** This is THE main view — Owner spends most time here. Set as default landing page (replacing `#dashboard` as default if Owner prefers).

**Vision:** SpaceX launch-console feel. Owner has a single screen showing every agent ready to be dispatched, what's online, and what's missing. Click → copy prompt → paste in agent IDE → return to Cockpit → see new agent online within 5s.

#### Layout

```
╔════════════════════════════════════════════════════════════════════╗
║ MISSION CONTROL — M2 Phase 1 Discovery Dispatch                    ║
║ ──────────────────────────────────────────────────────────────────  ║
║ Wave progress: ▓▓▓▓░░░░░░░░  4/12 dispatched · 2/12 online · 0 done ║
║ Wave time: 00:03:45 elapsed · ETA all online: 02:15                ║
║ Sound on check-in: [🔊 ON]  Reset wave: [↺]  Snapshot: [💾]         ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                     ║
║ ┌─ CODEX 5.5 INSTANCE #1 ─────────────────────────────────────────┐ ║
║ │ Order  Agent              State          Heartbeat     Actions  │ ║
║ │ ─────────────────────────────────────────────────────────────── │ ║
║ │  ①  ✅ CODEX-1-LEAD       IN_PROGRESS    ● 8s ago     [📋][📂] │ ║
║ │  ⑤  ⏳ CODEX-1-SUB-A      DISPATCHED     awaiting     [📋][↩] │ ║
║ │  ⑥  ⬜ CODEX-1-SUB-B      PENDING        —            [📋][✓] │ ║
║ │  ⑦  ⬜ CODEX-1-SUB-C      PENDING        —            [📋][✓] │ ║
║ └─────────────────────────────────────────────────────────────────┘ ║
║                                                                     ║
║ ┌─ CODEX 5.5 INSTANCE #2 ─────────────────────────────────────────┐ ║
║ │  ②  ✅ CODEX-2-LEAD       IN_PROGRESS    ● 12s ago    [📋][📂] │ ║
║ │  ⑧  ⬜ CODEX-2-SUB-A      PENDING        —            [📋][✓] │ ║
║ │  ⑨  ⬜ CODEX-2-SUB-B      PENDING        —            [📋][✓] │ ║
║ │  ⑩  ⬜ CODEX-2-SUB-C      PENDING        —            [📋][✓] │ ║
║ └─────────────────────────────────────────────────────────────────┘ ║
║                                                                     ║
║ ┌─ OPUS 4.7 INSTANCE #2 ──────────────────────────────────────────┐ ║
║ │  ④  ⏳ OPUS-2             DISPATCHED     awaiting     [📋][↩] │ ║
║ └─────────────────────────────────────────────────────────────────┘ ║
║                                                                     ║
║ ┌─ GEMINI FLASH 3.5 FAMILY ───────────────────────────────────────┐ ║
║ │  ③  ✅ GEMINI-FLASH-LEAD  IN_PROGRESS    ● 5s ago     [📋][📂] │ ║
║ │  ⑪  ⬜ GEMINI-FLASH-SUB-1 PENDING        —            [📋][✓] │ ║
║ │  ⑫  ⬜ GEMINI-FLASH-SUB-2 PENDING        —            [📋][✓] │ ║
║ └─────────────────────────────────────────────────────────────────┘ ║
║                                                                     ║
╚════════════════════════════════════════════════════════════════════╝
```

#### Per-row details

Each agent row shows:

| Column | Content | Notes |
|---|---|---|
| **Order** | Numbered badge (①, ②, etc.) | Recommended dispatch order, draggable to reorder |
| **State icon** | ✅⏳⬜⚠️💀 | Visual state at glance |
| **Agent ID** | bold mono text | Click → drill into Agent Roster detail |
| **State badge** | text color-coded | Per state machine (below) |
| **Heartbeat** | "● 8s ago" green / amber / red | Updates every 5s |
| **Actions** | Buttons | See action set below |

#### Actions per row

| Button | Icon | Behavior |
|---|---|---|
| **Copy prompt** | 📋 | Fetches `/api/prompts/<id>/content`, calls `navigator.clipboard.writeText(content)`, shows toast "Copied X bytes — paste in agent IDE" |
| **Open file** | 📂 | Opens absolute file path in OS default editor (uses `<a href="file://...">` link) |
| **Mark dispatched** | ✓ | Marks state as DISPATCHED in localStorage with timestamp. Disables until agent CHECKINS or owner resets. |
| **Reset / undo** | ↩ | Clears DISPATCHED state in localStorage. Available only if state was DISPATCHED but agent never checked in. |

#### State machine per agent

```
PENDING (initial)
    ↓ owner clicks "Copy prompt"
PENDING (still — copy doesn't change state, owner still might not paste)
    ↓ owner clicks "Mark dispatched"
DISPATCHED (localStorage timestamp recorded)
    ↓ agent CHECKINS to ACTIVITY_LOG
CHECKED_IN (auto, ACTIVITY_LOG observed)
    ↓ first HEARTBEAT
IN_PROGRESS (auto)
    ↓ HEARTBEAT every 5min
IN_PROGRESS (sustained)
    ↓ no heartbeat 5-10 min
STALE (warning amber)
    ↓ no heartbeat >10 min
DEAD (red, requires owner intervention)

OR from IN_PROGRESS:
    ↓ CHECKOUT with status DONE
DONE (green checkmark, locked)

OR from any state:
    ↓ CHECKOUT with status BLOCKED
BLOCKED (red, requires owner triage)
```

#### State storage

| State | Source | Persistence |
|---|---|---|
| PENDING | inferred (no DISPATCHED, no CHECKIN) | implicit |
| DISPATCHED | localStorage key `cockpit.dispatch.<agent_id>` | survives page refresh |
| CHECKED_IN | ACTIVITY_LOG.md `CHECKIN` entry | persistent (file) |
| IN_PROGRESS | ACTIVITY_LOG.md `HEARTBEAT` entry | persistent (file) |
| STALE / DEAD | computed from heartbeat age | live computation |
| DONE / BLOCKED | ACTIVITY_LOG.md `CHECKOUT` entry | persistent (file) |

**No server-side write needed.** localStorage holds the "dispatched intent" client-side. Once agent CHECKINS, ACTIVITY_LOG becomes source of truth.

#### Wave progress KPIs (top header)

| KPI | Computation |
|---|---|
| `dispatched_count` | localStorage entries with DISPATCHED state |
| `online_count` | ACTIVITY_LOG distinct agents with recent CHECKIN/HEARTBEAT (<10min) |
| `done_count` | ACTIVITY_LOG distinct agents with CHECKOUT status:DONE |
| `wave_time` | now - earliest DISPATCHED timestamp in localStorage |
| `eta_all_online` | (online_count + dispatched_pending) / time-per-agent average extrapolation |

#### Audio feedback (optional)

When toggled ON, browser plays a short chime sound:
- on each agent transition PENDING → DISPATCHED (soft "click")
- on each agent transition DISPATCHED → CHECKED_IN (success "ding")
- on each agent transition IN_PROGRESS → DEAD (alert "alarm")
- on wave completion (all agents DONE) (triumphant fanfare)

Sounds are tiny (.wav 1-2KB each), embedded as base64 data URIs in `cockpit.js` to avoid HTTP requests.

`localStorage.cockpit.audio_enabled` persists preference.

#### Reorder mode

Toggleable: top bar "⚙ Reorder" button enters drag-mode. Owner can drag rows to change order (visual only — doesn't affect agent behavior, just owner's mental model). Order saved to `localStorage.cockpit.dispatch_order`.

Default order matches the recommended dispatch sequence from `dispatch/README.md`.

#### Reset wave

"↺ Reset" button clears all localStorage `cockpit.dispatch.*` keys after confirmation modal:
> "Reset wave? This clears your local dispatch tracking but does NOT affect agents that already CHECKED-IN. Their state remains based on ACTIVITY_LOG. Continue?"

#### Wave snapshot

"💾 Snapshot" button downloads JSON with:
- All agents and their states at click time
- localStorage values
- Wave KPIs
- Filename: `dispatch_wave_M2P1_<timestamp>.json`

Useful for handoff between Owner sessions or post-mortem.

#### Acceptance criteria for FR-11

- [ ] All 12 M2 Phase 1 agents listed with correct order, model, family grouping
- [ ] Click "📋 Copy" copies full prompt content to clipboard within 200ms
- [ ] Click "✓ Mark dispatched" updates row to DISPATCHED state, persists to localStorage
- [ ] When ACTIVITY_LOG gets new CHECKIN entry, corresponding row auto-transitions to CHECKED_IN within 5s of poll
- [ ] HEARTBEAT freshness color-coded correctly (green <5min, amber 5-10min, red >10min)
- [ ] Wave progress KPIs update on every poll
- [ ] Reset wave clears localStorage, agents remain at their actual log-derived state
- [ ] Audio toggle ON → chime sounds on state transitions
- [ ] Snapshot download works with valid JSON
- [ ] Reorder drag-and-drop saves to localStorage
- [ ] Default view = `#dispatch` (Mission Control)
- [ ] Visual fidelity matches Fortune 500 / SpaceX-launch-console aesthetic

---

## 6. Non-Functional Requirements

### Performance

| Metric | Target |
|---|---|
| Server cold start | <500ms |
| `/api/cockpit/snapshot` response | <100ms (with all 5 governance files parsed) |
| Initial page load | <800ms (assuming localhost) |
| Polling round-trip + DOM update | <150ms |
| Large activity log (10000 entries) | server caps at 200 newest by default; "Load more" for older |
| Memory footprint server | <50MB |
| Memory footprint browser | <100MB |

### Compatibility

| Browser | Min version | Status |
|---|---|---|
| Chrome / Edge | 110+ | Primary |
| Firefox | 110+ | Primary |
| Safari | 16+ | Best-effort |

Not supported: IE, mobile browsers (cockpit is desktop tool).

### Accessibility (WCAG 2.1 AA)

- Color contrast 4.5:1 minimum
- Keyboard navigation for all interactive elements
- ARIA roles and live regions for dynamic content
- Status conveyed by text + icon + color (never color-only)
- Focus visible on all focusable elements
- `prefers-reduced-motion` respected

### Reliability

- Server restart picks up where it left off (stateless server, all state in files)
- Browser refresh re-renders without losing context
- Graceful degradation when files missing (show empty state, not error)
- Graceful degradation when CDN markdown libs unavailable (use built-in fallback in `viewer.js`)

### Security

- Bind server to `127.0.0.1` only (not `0.0.0.0`) — no network exposure
- No authentication v1 (single-user localhost)
- Read-only on all endpoints (no POST/PUT/DELETE in v1)
- File path traversal protection in `/api/prompts/<id>/content` (whitelist allowed paths)
- No execution of arbitrary code from files (markdown rendered through DOMPurify)

### Observability

- Server logs every request to stdout (timestamp + method + path + status + duration)
- Errors logged with stack trace
- Optional: write structured access log to `Web_MD_Viewer/logs/access.log`

---

## 7. Backend Specification — `cockpit-server.js`

### Tech constraints

- **Node.js 18+** built-in modules only: `http`, `fs/promises`, `path`, `url`, `crypto`
- **NO npm dependencies** for v1 (zero install, just `node cockpit-server.js`)
- Single file (~400-500 lines target)

### Server lifecycle

```javascript
// pseudo-code
const PORT = 7777;
const HOST = '127.0.0.1';
const ROOT = path.resolve(__dirname, '..'); // project root
const M2_GOVERNANCE = path.join(ROOT, '.planning', 'milestones', 'M2_card_first_revision_v2', 'governance');
const M2_PHASES = path.join(ROOT, '.planning', 'milestones', 'M2_card_first_revision_v2', 'phases');
const STATIC_DIR = __dirname;

http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${HOST}:${PORT}`);
  // route + serve
}).listen(PORT, HOST);
```

### Endpoint contracts

#### `GET /api/health`

```json
{
  "status": "ok",
  "version": "1.0.0",
  "uptime_seconds": 3600,
  "server_time": "2026-05-20T18:35:00-03:00"
}
```

#### `GET /api/cockpit/snapshot`

Returns combined state for the dashboard view.

```json
{
  "snapshot_time": "2026-05-20T18:35:00-03:00",
  "kpis": {
    "active_agents": 7,
    "total_agents": 13,
    "tasks_done_current_phase": 3,
    "tasks_in_progress": 7,
    "tasks_blocked": 1,
    "current_phase": 1,
    "current_phase_progress_pct": 35,
    "project_eta_iso": "2026-05-22T18:00:00-03:00"
  },
  "agents": [/* see /api/agents/roster */],
  "recent_activity": [/* last 50 from activity log */],
  "phase_state": {/* see /api/phases/state */}
}
```

#### `GET /api/agents/roster`

Returns the 13 agents with current state.

```json
{
  "agents": [
    {
      "id": "CODEX-1-LEAD",
      "model": "Codex 5.5",
      "role": "Lead + Track A.1+A.2 + integrator",
      "phase": 1,
      "status": "IN_PROGRESS",
      "current_task": "A.1+A.2",
      "started_at": "2026-05-20T18:14:30-03:00",
      "last_seen": "2026-05-20T18:35:12-03:00",
      "progress_pct": 52,
      "current_step": "Extracting topic inventory",
      "files_locked": 1,
      "heartbeat_age_seconds": 18,
      "heartbeat_status": "alive",
      "prompt_file": "phases/01_discovery/dispatch/codex1_lead.md"
    },
    ...
  ]
}
```

`heartbeat_status` enum: `alive` (<5min), `stale` (5-10min), `dead` (>10min), `idle` (never started), `done`.

#### `GET /api/checkin-board`

Raw parse of `CHECKIN_BOARD.md`:

```json
{
  "active_agents_table": [
    {"agent_id": "CODEX-1-LEAD", "status": "IN_PROGRESS", "phase": 1, ...}
  ],
  "phase_tracker": [
    {"phase": 1, "status": "IN_PROGRESS", "started": "...", "completed": null, "active_agents": ["CODEX-1-LEAD", ...]},
    {"phase": 2, "status": "WAITING", ...}
  ],
  "stats": {
    "total_agents_in_fleet": 13,
    "currently_active": 7,
    "currently_blocked": 1,
    "tasks_in_queue": 12,
    "tasks_completed_this_phase": 3
  }
}
```

#### `GET /api/activity-log?since=<ISO>&limit=<N>&filter=<op_type>`

Returns activity log entries.

```json
{
  "total_entries": 1247,
  "returned_entries": 50,
  "entries": [
    {
      "timestamp": "2026-05-20T18:35:42-03:00",
      "operation": "HEARTBEAT",
      "agent_id": "CODEX-1-LEAD",
      "task_id": "A.1+A.2",
      "fields": {
        "progress": "52%",
        "current_step": "Extracting topic inventory"
      },
      "raw": "[2026-05-20T18:35:42-03:00] HEARTBEAT | CODEX-1-LEAD | task A.1+A.2 | progress: 52% | current step: Extracting topic inventory"
    },
    ...
  ]
}
```

Default: `limit=50`, newest first.

#### `GET /api/file-locks`

```json
{
  "active_locks": [
    {
      "file_path": ".../A_dataverse_inventory/INVENTORY_TOPICS.md",
      "agent_id": "CODEX-1-LEAD",
      "status": "LOCKED",
      "acquired_at": "2026-05-20T18:34:00-03:00",
      "expected_release_at": "2026-05-20T18:39:00-03:00",
      "age_seconds": 90,
      "is_stale": false
    }
  ],
  "recent_history": [/* last 20 released locks */]
}
```

#### `GET /api/handoffs`

```json
{
  "active_handoffs_pending": [
    {"timestamp": "...", "from": "CODEX-1-SUB-B", "to": "CODEX-2-SUB-C", "task": "B → G dependency", "received": false}
  ],
  "handoff_history": [/* all entries from HANDOFF_LOG.md */],
  "graph": {
    "nodes": [{"id": "CODEX-1-LEAD", "phase": 1, "activity_count": 47}, ...],
    "edges": [{"from": "CODEX-1-SUB-B", "to": "CODEX-2-SUB-C", "count": 1, "last_at": "..."}, ...]
  }
}
```

#### `GET /api/prompts/list`

```json
{
  "phase": 1,
  "dispatch_path": "phases/01_discovery/dispatch/",
  "prompts": [
    {
      "id": "codex1_lead",
      "filename": "codex1_lead.md",
      "agent_id": "CODEX-1-LEAD",
      "title": "CODEX 5.5 #1 LEAD — M2 Phase 1 Discovery",
      "size_bytes": 12345,
      "execution_status": "IN_PROGRESS",
      "started_at": "...",
      "last_seen": "..."
    },
    ...
  ]
}
```

#### `GET /api/prompts/<id>/content`

Returns raw markdown for the prompt. ID = filename without `.md`.

```json
{
  "id": "codex1_lead",
  "agent_id": "CODEX-1-LEAD",
  "content": "# CODEX 5.5 #1 LEAD — M2 Phase 1 Discovery\n\n...",
  "size_bytes": 12345,
  "last_modified": "2026-05-20T18:14:00-03:00"
}
```

Path traversal protection: only filenames matching `^[a-z0-9_]+\.md$` accepted; resolved path must be under dispatch directory.

#### `GET /api/phases/state`

```json
{
  "current_phase": 1,
  "phases": [
    {
      "id": 1,
      "name": "Discovery",
      "status": "IN_PROGRESS",
      "started_at": "2026-05-20T18:14:00-03:00",
      "completed_at": null,
      "tasks_total": 12,
      "tasks_done": 3,
      "tasks_in_progress": 7,
      "tasks_blocked": 1,
      "active_agents": ["CODEX-1-LEAD", ...],
      "estimated_effort_hours": 6,
      "actual_effort_hours_so_far": 1.2,
      "owner_gate_required": false
    },
    ...
  ]
}
```

### Parsing logic per file

#### `CHECKIN_BOARD.md` parser

- Find table after "## Active Agents (right now)" header
- Parse markdown table rows into objects
- Find table after "## Phase Tracker" header
- Parse phase status

#### `ACTIVITY_LOG.md` parser

- Skip preamble until first `[YYYY-MM-DDTHH:MM:SS...]` timestamp line
- Each line: extract timestamp, operation, agent_id, fields
- Regex: `^\[([^\]]+)\]\s+(\w+)\s+\|\s+([\w-]+)\s+\|(.*)$`
- Fields after agent_id: split by `|`, each field is `key: value`

#### `FILE_LOCK_TABLE.md` parser

- Find table after "## Active Locks" header
- Parse rows; if status=LOCKED and acquired_at older than 20min → mark `is_stale: true`

#### `HANDOFF_LOG.md` parser

- Find entries starting with `[ISO_TIMESTAMP] HANDOFF | from: X | to: Y`
- Parse multi-line YAML-like content into structured object

### Server response codes

| Code | Meaning |
|---|---|
| 200 | OK |
| 304 | Not modified (with `If-None-Match` ETag) |
| 400 | Bad request (e.g., invalid `since` param) |
| 404 | Not found (unknown prompt ID) |
| 500 | Server error (file read failure) |
| 503 | Service unavailable (governance dir missing) |

### Caching

- ETag based on file mtime + size for governance files
- Browser respects ETag for 304 responses
- Server caches parsed output for 2 seconds (fast subsequent polls)

### Logging

stdout format:

```
[2026-05-20T18:35:42-03:00] GET /api/cockpit/snapshot 200 87ms
[2026-05-20T18:35:47-03:00] GET /api/activity-log?since=...&limit=50 200 23ms
```

---

## 8. Frontend Specification — `cockpit.js`

### Module structure

```javascript
// cockpit.js
const Cockpit = (() => {
  // Configuration
  const config = { refreshMs: 5000, apiBase: '/api', ... };

  // State
  const state = { agents: [], activity: [], phases: [], lastUpdate: null };

  // Polling loop
  function startPolling() { setInterval(refresh, config.refreshMs); }

  // Data fetching
  async function fetchSnapshot() { return fetch(`${config.apiBase}/cockpit/snapshot`).then(r => r.json()); }

  // Render functions (per view)
  const views = {
    dashboard: renderDashboard,
    agents: renderAgentRoster,
    activity: renderActivityFeed,
    phases: renderPhaseTracker,
    handoffs: renderHandoffMap,
    prompts: renderPromptsLibrary,
  };

  // Navigation
  function navigateTo(viewName) { /* hide all, show one */ }

  // Lifecycle
  function init() {
    bindEvents();
    bindHashNavigation();
    startPolling();
    refresh();
  }

  return { init };
})();

document.addEventListener('DOMContentLoaded', Cockpit.init);
```

### Key events

- `window.hashchange` → switch view
- `polling tick` → fetch snapshot → diff → update DOM
- `agent card click` → open detail
- `filter change` → re-render filtered subset
- `export click` → download JSON

### DOM update strategy

- Use targeted DOM updates (`element.textContent = ...`) for KPI numbers (no full re-render)
- Use innerHTML replacement for activity feed (rebuild list each poll, lightweight)
- Use diffing for agent cards (only update changed cards, animate transitions)

### Reuse from `viewer.js`

Functions to reuse as-is:
- Markdown rendering pipeline (marked + DOMPurify + highlight.js)
- Theme toggle
- Search
- Generic helpers

New additions go in `cockpit.js`. Do NOT modify `viewer.js`.

---

## 9. HTML Structure — `index.html`

Replace existing nav and main content while preserving:
- Top bar structure
- Sidebar shell
- Theme toggle
- Indra branding

New sidebar nav:

```html
<nav class="app-sidebar">
  <div class="sidebar-project">
    <div class="sidebar-project-label">Active Milestone</div>
    <div class="sidebar-project-name">M2 — Card-First Hybrid</div>
    <div class="sidebar-project-bar">
      <div class="sidebar-project-bar-fill" style="width: 12%"></div>
    </div>
  </div>
  <div class="sidebar-nav">
    <a class="nav-item active" data-view="dashboard">📊 Cockpit Overview</a>
    <a class="nav-item" data-view="agents">👥 Agent Roster (13)</a>
    <a class="nav-item" data-view="activity">📡 Live Activity</a>
    <a class="nav-item" data-view="phases">🗺️ Phase Tracker</a>
    <a class="nav-item" data-view="handoffs">🔗 Handoff Map</a>
    <a class="nav-item" data-view="prompts">📝 Prompts Library</a>
    <a class="nav-item" data-view="legacy">📄 MD Viewer (legacy)</a>
  </div>
  <div class="sidebar-footer">...</div>
</nav>
```

Each `<main>` view section gets its own div with `id="view<Name>"` and class `app-content`.

Top bar additions:
- Polling indicator (1px progress bar at very top of page)
- "Refresh" button
- "Export snapshot" button
- Last update timestamp

---

## 10. Test Plan

### Unit tests (`Web_MD_Viewer/tests/`)

| Test file | Coverage |
|---|---|
| `test_cockpit_parsers.js` | CHECKIN_BOARD parser, ACTIVITY_LOG parser, FILE_LOCK parser, HANDOFF parser — sample inputs → expected JSON |
| `test_cockpit_renderers.js` | renderDashboard / renderAgentRoster / etc. with mock data — no DOM errors, expected elements present |
| `test_cockpit_state.js` | State diff logic, polling backoff on errors |

Use plain Node.js test runner (no npm test framework needed): `node --test`.

### Integration tests

| Test file | Coverage |
|---|---|
| `test_server_endpoints.js` | Spin up server, hit each endpoint, verify response shape |
| `test_server_path_traversal.js` | Try malicious prompt ID like `../../etc/passwd` — must 404 |
| `test_server_health.js` | `/api/health` returns 200 with expected fields |

### E2E (manual smoke)

Owner runbook (15 min):
1. Start server: `node cockpit-server.js`
2. Open browser at `http://localhost:7777`
3. Verify all 6 views render without errors
4. Check polling indicator animates
5. Manually edit a governance file → verify change appears in cockpit within 5s
6. Click on agent card → verify detail view
7. Filter activity feed → verify subset
8. Export snapshot → verify JSON file
9. Stop server → verify connection lost banner appears
10. Restart server → verify reconnect

### Accessibility audit

- Run axe-core via browser bookmarklet
- Tab through entire UI — every interactive element reachable
- Screen reader test: VoiceOver or NVDA — activity feed announces new entries

### Performance baseline

- Measure with Chrome DevTools Performance tab:
  - Initial load <800ms
  - First poll <150ms total
  - 100-entry activity feed render <50ms
- Memory snapshot after 1h running: <100MB

---

## 11. Deployment Specification

### File deliverables

```
D:\VMs\Projetos\STT_Project_Management\Web_MD_Viewer\
├── index.html                 (TRANSFORMED — cockpit primary)
├── index_legacy_backup.html   (NEW — backup of original index.html)
├── styles.css                 (PRESERVED — base design)
├── viewer.css                 (PRESERVED — markdown styles)
├── viewer.js                  (PRESERVED — markdown engine)
├── cockpit.css                (NEW — additive cockpit styles)
├── cockpit.js                 (NEW — orchestrator)
├── cockpit-server.js          (NEW — Node backend)
├── cockpit-config.json        (NEW — server config)
├── package.json               (NEW — npm scripts metadata)
├── README.md                  (NEW — quickstart)
└── tests/
    ├── test_cockpit_parsers.js
    ├── test_cockpit_renderers.js
    ├── test_cockpit_state.js
    ├── test_server_endpoints.js
    ├── test_server_path_traversal.js
    └── test_server_health.js
```

### `package.json`

```json
{
  "name": "pmo-cockpit",
  "version": "1.0.0",
  "description": "PMO Cockpit — real-time M2 monitoring",
  "main": "cockpit-server.js",
  "scripts": {
    "start": "node cockpit-server.js",
    "test": "node --test tests/",
    "open": "node cockpit-server.js & start http://localhost:7777"
  },
  "engines": { "node": ">=18.0.0" }
}
```

### `README.md` quickstart

```markdown
# PMO Cockpit

Real-time monitoring dashboard for the M2 multi-agent execution.

## Quickstart

\`\`\`bash
cd Web_MD_Viewer
node cockpit-server.js
\`\`\`

Open http://localhost:7777

## Configuration

Edit `cockpit-config.json`:
\`\`\`json
{
  "port": 7777,
  "host": "127.0.0.1",
  "polling_default_ms": 5000,
  "activity_log_default_limit": 50
}
\`\`\`

## Development

\`\`\`bash
node --test tests/
\`\`\`

## Architecture

See `.planning/cockpit/SPECIFICATION.md`
```

### Launch sequence

1. Owner runs `node cockpit-server.js` once
2. Server logs:
   ```
   [2026-05-20T18:35:00-03:00] PMO Cockpit Server v1.0.0
   [2026-05-20T18:35:00-03:00] Listening on http://127.0.0.1:7777
   [2026-05-20T18:35:00-03:00] Watching governance: .../M2_card_first_revision_v2/governance/
   [2026-05-20T18:35:00-03:00] Ready.
   ```
3. Browser opens automatically (if `npm run open` used) or owner navigates manually
4. Cockpit polls every 5s, shows live state

### Rollback

If cockpit breaks the existing MD viewer:
1. Owner restores `index_legacy_backup.html` → renames back to `index.html`
2. Cockpit server can run independently or stay down
3. Original MD viewer functionality preserved 100%

---

## 12. Acceptance Criteria

### Hard gates (all must PASS for v1 release)

- [ ] All 6 views render without console errors
- [ ] Polling refreshes every 5s with smooth animation
- [ ] Server handles all 10 endpoints with correct schemas
- [ ] All 13 agent cards display correctly
- [ ] Activity feed shows newest entries first
- [ ] Phase tracker reflects current state
- [ ] Filters work on activity and agent views
- [ ] Path traversal attempts return 404 not 500
- [ ] Server runs without npm dependencies (pure Node 18+)
- [ ] Existing MD viewer accessible at `#legacy` navigation item
- [ ] Original `viewer.js` not modified
- [ ] Theme toggle preserved and working
- [ ] WCAG 2.1 AA contrast on all text
- [ ] Keyboard navigation reaches all interactive elements
- [ ] No console warnings on Chrome 110+, Firefox 110+
- [ ] Initial load <800ms (localhost)
- [ ] Test suite passes: `node --test tests/`

### Visual review checklist (Owner approves)

- [ ] Indra Intelligence brand intact (logo, colors, typography)
- [ ] Premium feel (no jank, no layout shifts)
- [ ] Information hierarchy clear (eye flows top→bottom, left→right)
- [ ] Status badges immediately readable
- [ ] Heartbeat indicators clearly distinguish alive/stale/dead
- [ ] Activity feed easy to scan (timestamp alignment, color coding)
- [ ] Agent grid responsive (3-4 columns on desktop, 1-2 on smaller)

### Functional gates

- [ ] Owner can identify any DEAD agent within 10s of opening
- [ ] Owner can drill from KPI → Agent → Prompt in <3 clicks
- [ ] Activity feed updates within 5s of file change
- [ ] No stale data shown when files have just been written
- [ ] Filters reduce result set immediately

---

## 13. Future Enhancements (v2+, out of scope for v1)

- WebSocket-based push updates (replace polling)
- Multi-milestone support (currently hard-coded to M2)
- Authentication for remote access
- Mobile-responsive layout
- Notification webhooks (Teams/Slack on DEAD agent)
- Historical analytics (project trend over multiple projects)
- Export to PDF for executive reports
- Force-directed graph layout for handoff map
- Search indexing (Elasticsearch-style)
- Persistent state in browser localStorage

---

## 14. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Governance files change schema during M2 | Server tolerant of missing fields; graceful "—" display |
| Activity log grows huge (>10MB) | Server returns last 200 by default; "Load more" for older |
| Browser cache stale | ETag-based caching; manual refresh button |
| Server port 7777 taken | Configurable in `cockpit-config.json`; error message guides Owner |
| File system permissions | Server uses Owner credentials (no privilege escalation needed) |
| Long-running server memory leak | Periodic cache eviction (every 5min) |
| Agent writes malformed timestamp | Parser regex-validates; entries with bad format flagged in stderr but rendered as raw |

---

## 15. Sign-off

| Role | Name | Status |
|---|---|---|
| Architect | Opus 4.7 | Spec locked 2026-05-20 18:33 BRT |
| Build owner | Gemini Flash 3.5 | Pending dispatch |
| Owner | Manoel Benicio | Approved spec 2026-05-20 18:33 BRT |

---

*Specification version: 1.0 — locked 2026-05-20 18:33 BRT.*
