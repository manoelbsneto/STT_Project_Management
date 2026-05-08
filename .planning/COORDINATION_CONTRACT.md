# Coordination Contract — Opus / Codex Non-Conflict Agreement

> **Date:** 2026-05-07 16:58 BRT
> **Approved by:** Project Owner
> **Purpose:** Prevent Opus and Codex from working on the same files/tasks simultaneously

---

## Ownership Boundaries

### Codex Owns (Programmatic)
- `deploy/` — flow scripts, PowerShell, JSON definitions
- `tests/` — all test scripts and validation gates
- `.planning/stop_ship/` — evidence log, checklist, exec summary
- `.planning/comms/` — evidence JSON artifacts
- SharePoint schema validation scripts
- Dataverse ghost component discovery scripts
- Flow definition generation and expression validation

### Opus Owns (Browser + Architecture)
- `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md` — master plan (read-only for Codex)
- `.planning/COORDINATION_CONTRACT.md` — this file
- `.planning/BROWSER_CHECKLIST.md` — browser task queue (Opus creates, executes)
- `deploy/copilot/AssistentePMO.template.yaml` — YAML template (Codex may propose edits; Opus approves)
- All Copilot Studio UI actions (publish, bind, test)
- All Power Automate UI actions (flow creation when UI-required)
- Screenshot evidence capture
- Implementation plan artifacts

### Human/Admin Owns
- Dataverse destructive cleanup (delete ghost rows) — requires explicit written approval
- Tenant permission escalation
- Final ship/no-ship decision

---

## Check-In Protocol

Before starting work, each agent must:

1. **Read this contract** to confirm ownership
2. **Check the task board** (`.planning/TASK_BOARD.md`) for current assignments
3. **Claim a task** by writing `[CLAIMED by <agent>] <timestamp>` before starting
4. **Mark complete** with `[DONE by <agent>] <timestamp>` when finished

### Conflict Resolution Rules

| Scenario | Resolution |
|----------|-----------|
| Both agents need the same file | Codex proposes changes → Opus reviews and applies |
| Codex needs browser action | Codex writes request to `BROWSER_CHECKLIST.md` → Opus executes |
| Opus needs programmatic work | Opus writes request to `CODEX_TASK_QUEUE.md` → Codex executes |
| Disagreement on approach | Human decides |

---

## File Lock Table

| File/Directory | Lock Owner | Status |
|----------------|-----------|--------|
| `deploy/PA_CriarTarefa_Flow.ps1` | Codex | Available |
| `deploy/copilot/AssistentePMO.template.yaml` | Opus | Available |
| `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md` | Opus | Available |
| `tests/*` | Codex | Available |
| `.planning/stop_ship/*` | Codex | Available |
| `.planning/COORDINATION_CONTRACT.md` | Opus | **LOCKED** |
| `.planning/BROWSER_CHECKLIST.md` | Opus | Not yet created |

---

## Current Wave Status

| Wave | Owner | Status |
|------|-------|--------|
| Wave 1 — CriarTarefa V3 | Codex (script) + Opus (UI bind/publish/test) | 🔵 Ready to start |
| Wave 2 — Read Topics | Codex (flow blueprints) + Opus (UI create/bind) | ⚪ Blocked by Wave 1 |
| Wave 3 — Write Topics | Codex (flow blueprints) + Opus (UI create/bind) | ⚪ Blocked by Wave 2 |
| Wave 4 — STT Fix | Codex (YAML update) + Opus (UI apply/publish) | ⚪ Blocked by Wave 3 |
| Wave 5 — Cleanup/Evidence | Codex (scripts) + Opus (browser evidence) + Human (Dataverse delete) | ⚪ Blocked by Wave 4 |
| Wave 6 — Enhancements | Codex | ⚪ Post-ship |

---

*No agent starts a wave without the previous wave being marked DONE and approved by Project Owner.*
