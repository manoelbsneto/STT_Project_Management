# Agentic Check-In Board: Adaptive Cards + Planner P0 Delivery

Created: 2026-05-14  
Status: ACTIVE  
Purpose: single point of coordination for Codex Lead, 3 Codex sub-agents, and Gemini 3.1 Pro Preview during the P0 Adaptive Cards + Planner delivery.

## 1. Mandatory Rule

Every active agent must update this document:

1. When starting work.
2. Before editing files.
3. After editing files.
4. Every 5 minutes while actively working.
5. Immediately when blocked.
6. Immediately when a task is ready for another agent.
7. At completion.

No agent may wait until the end of a task to report status.

## 1.1 Mandatory Read-Before-Start Protocols

Every active agent must read and follow these before starting any task:

```text
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
```

SEV-0 stop-ship rule: CI may be ignored only when owner-excluded. Every other quality gate is mandatory. If any non-CI gate is missing, failed, stale, unverified, or not tied to the current artifact, the release decision is `NO-SHIP`.

## 2. Current Roster

| Agent ID | Owner / Model | Role | Write Scope | Tenant Access |
|---|---|---|---|---|
| `CODEX-LEAD` | Codex | Integration owner, gatekeeper, package/release coordinator | Integration docs, final reviews, task assignment, gates | No tenant writes without owner approval |
| `GEMINI-PA` | Gemini 3.1 Pro Preview | Principal Deploy Engineer for Power Automate | Flow design/definitions only | No import/publish/write without owner approval |
| `CODEX-DOCS` | Codex Sub-Agent 1 | Governance, PRD, contract, AS-IS/TO-BE, change request | `.planning`, `PRD`, `docs` docs only | No tenant access |
| `CODEX-CARDS` | Codex Sub-Agent 2 | Adaptive Card JSON, visual system, click actions | `deploy/cards/*.json`, card docs only | No tenant access |
| `CODEX-QA` | Codex Sub-Agent 3 | QA matrix, test scripts, evidence, release gates | `tests/*`, `.planning/comms/*evidence*`, QA docs only | Read-only evidence support |

## 3. Non-Negotiable Coordination Rules

1. No two agents may edit the same file at the same time.
2. No two agents may edit the same Copilot topic at the same time.
3. No two agents may edit the same Power Automate flow definition at the same time.
4. No two agents may edit the same Adaptive Card JSON at the same time.
5. Every file edit must be announced before it starts.
6. Every file edit must be reported after it completes.
7. All agents must list changed files in every completion update.
8. Only `CODEX-LEAD` integrates final package-level changes.
9. Tenant import, publish, deploy, Power Automate save, SharePoint write, and Planner write require explicit owner approval.
10. If an agent misses a 5-minute check-in while active, the task is considered at risk and must be re-confirmed before downstream work depends on it.
11. All non-CI quality gates are mandatory before ship. CI can be ignored only under explicit owner exclusion. Missing or failed non-CI evidence means `NO-SHIP`.

## 4. Status Legend

| Status | Meaning |
|---|---|
| `READY` | Task is ready to start. |
| `CLAIMED` | Agent has claimed the task but has not started edits. |
| `IN_PROGRESS` | Agent is actively working. |
| `WAITING` | Agent is waiting for dependency or owner input. |
| `BLOCKED` | Agent cannot proceed. |
| `READY_FOR_REVIEW` | Task complete enough for CODEX-LEAD review. |
| `DONE` | Reviewed and accepted. |
| `REWORK` | Needs correction. |

## 5. Active Task Board

| Task ID | Priority | Task | Owner | Status | Dependency | Claimed At | Last Check-In | Files / Scope | Next Handoff |
|---|---:|---|---|---|---|---|---|---|---|
| P0-00 | 0 | Freeze current state and create agentic coordination docs | CODEX-LEAD | READY_FOR_REVIEW | None | 2026-05-14 | 2026-05-14 20:10 | `.planning/comms`, `.planning/architecture`, `.planning/AGENT_CONTRACT.md`, `.planning/START_HERE_CURRENT_STATUS.md`, `.planning/TASK_BOARD.md` | Handoff to all agents |
| P0-01 | 0 | AS-IS / TO-BE architecture update | CODEX-DOCS | READY | P0-00 | - | - | `.planning/architecture/*AS_IS_TO_BE*` | CODEX-LEAD review |
| P0-02 | 0 | Formal Change Request | CODEX-DOCS | READY | P0-00 | - | - | `.planning/architecture/*CHANGE_REQUEST*` | CODEX-LEAD review |
| P0-03 | 0 | ADR for Copilot-as-router and Cards-as-operational-UI | CODEX-DOCS | READY | P0-01 | - | - | `.planning/architecture/*ADR*` | CODEX-LEAD review |
| P0-04 | 0 | PRD and contract revision notes | CODEX-DOCS | READY | P0-01, P0-02 | - | - | `PRD/*.md`, `.planning/AGENT_CONTRACT.md` | CODEX-LEAD review |
| P0-05 | 0 | Teams routing inventory | CODEX-QA | READY | P0-00 | - | - | `.planning/comms/*routing*` | GEMINI-PA / CODEX-CARDS |
| P0-06 | 0 | Planner readiness inventory | CODEX-QA | READY | P0-00 | - | - | `.planning/comms/*planner*` | GEMINI-PA |
| P0-07 | 0 | Card visual standard and naming conventions | CODEX-CARDS | READY | P0-00 | - | - | `.planning/architecture/*visual*`, `deploy/cards` | CODEX-LEAD review |
| P1-01 | 0 | Executive summary data contract | CODEX-LEAD | READY | P0-01 | - | - | `.planning/architecture/*contract*` | GEMINI-PA, CODEX-CARDS, CODEX-QA |
| P1-02 | 0 | Executive portfolio Adaptive Card | CODEX-CARDS | READY | P1-01, P0-07 | - | - | `deploy/cards/ResumoExecutivoPortfolio.json` | CODEX-LEAD review |
| P1-04 | 0 | Executive summary Power Automate flow design | GEMINI-PA | READY | P1-01, P0-05 | - | - | Flow definition/design files only | CODEX-LEAD integration |
| P1-06 | 0 | Director visibility QA checklist | CODEX-QA | READY | P1-01 | - | - | `tests/*`, `.planning/comms/*evidence*` | Owner runtime validation |

## 6. Required Check-In Format

Every update must use this format:

```markdown
### 2026-05-14 HH:MM BRT — AGENT-ID — STATUS
- **Task ID:** P0-00
- **Current action:** What the agent is doing now.
- **Progress since last check-in:** Concrete progress, not generic status.
- **Files being edited:** List exact paths, or `None`.
- **Files changed:** List exact paths, or `None`.
- **Risks / blockers:** State blockers or `None`.
- **Next 5 minutes:** What will happen next.
- **Handoff / dependency:** Who can start what, or `None`.
```

## 7. Check-In Log

### 2026-05-14 20:00 BRT — CODEX-LEAD — IN_PROGRESS
- **Task ID:** P0-00
- **Current action:** Creating the mandatory agentic check-in board and updating project coordination documents.
- **Progress since last check-in:** Established roster for 1 Codex Lead, 3 Codex sub-agents, and 1 Gemini 3.1 Pro Preview deploy engineer.
- **Files being edited:** `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`
- **Files changed:** `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`
- **Risks / blockers:** None.
- **Next 5 minutes:** Update agentic plan and project coordination docs to point to this check-in board.
- **Handoff / dependency:** None yet.

### 2026-05-14 20:05 BRT — CODEX-LEAD — IN_PROGRESS
- **Task ID:** P0-00
- **Current action:** Updating project control documents and creating dispatch prompts for parallel agents.
- **Progress since last check-in:** Updated `AGENT_CONTRACT`, `START_HERE_CURRENT_STATUS`, `TASK_BOARD`, `AGENTIC_TASK_PLAN`, and `FULL_DELIVERY_PLAN` to point to the mandatory check-in board.
- **Files being edited:** `.planning/comms/AGENTIC_DISPATCH_PROMPTS_ADAPTIVE_CARDS_PLANNER_20260514.md`
- **Files changed:** `.planning/AGENT_CONTRACT.md`, `.planning/START_HERE_CURRENT_STATUS.md`, `.planning/TASK_BOARD.md`, `.planning/architecture/AGENTIC_TASK_PLAN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/architecture/FULL_DELIVERY_PLAN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`
- **Risks / blockers:** None.
- **Next 5 minutes:** Complete dispatch prompts and mark P0-00 ready for review.
- **Handoff / dependency:** Parallel agents can start only after reading the check-in board and claiming their task.

### 2026-05-14 20:10 BRT — CODEX-LEAD — READY_FOR_REVIEW
- **Task ID:** P0-00
- **Current action:** Closing coordination setup and handing off to parallel agents.
- **Progress since last check-in:** Created dispatch prompts for `GEMINI-PA`, `CODEX-DOCS`, `CODEX-CARDS`, and `CODEX-QA`. Confirmed project docs now reference the mandatory check-in board.
- **Files being edited:** None.
- **Files changed:** `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/comms/AGENTIC_DISPATCH_PROMPTS_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/architecture/AGENTIC_TASK_PLAN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/architecture/FULL_DELIVERY_PLAN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/AGENT_CONTRACT.md`, `.planning/START_HERE_CURRENT_STATUS.md`, `.planning/TASK_BOARD.md`
- **Risks / blockers:** None.
- **Next 5 minutes:** Await owner/agent pickup. Next agents must claim tasks in this check-in board before editing.
- **Handoff / dependency:** `CODEX-DOCS` can start P0-01/P0-02. `CODEX-CARDS` can start P0-07. `CODEX-QA` can start P0-05/P0-06. `GEMINI-PA` can review Phase 1/2 flow contracts but should wait for P1-01 before writing flow definitions.
