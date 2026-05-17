# CODEX Review: Gemini AQ-07 Build Package

Date: 2026-05-15
Reviewer: CODEX-LEAD
Reviewed scope:

- `.planning/comms/aq07_power_automate_build_20260515/`
- `.planning/comms/GEMINI_AQ07_CORRECTIVE_PROMPT_20260515.md`
- `.planning/comms/AGENT_TASK_IO_CONTRACT_PROTOCOL_20260515.md`

Tenant execution during review: none
Release decision: NO-SHIP

## 1. Verdict

Status: BLOCKED_REWORK_REQUIRED

Gemini delivered the required file set and selected `PORTAL_BUILD_RUNBOOK`. The package is structurally present, but it fails the AQ-07 contract because required route keys are wrong in multiple files and at least one flow has an action/operation mismatch.

Do not request AQ-07 owner approval from this package.

## 2. Passing Checks

| Check | Result |
|---|---|
| Required folder exists | PASS |
| All required files exist | PASS |
| `PACKAGE_MANIFEST.json` parses | PASS |
| `CARD_ACTION_BINDING_MATRIX.csv` has required columns | PASS |
| Required flow section headings exist | PASS |
| No forbidden placeholder terms found | PASS |
| No non-ASCII characters found | PASS |
| Gemini check-in handoff present | PASS |

## 3. Blocking Findings

| ID | Severity | Finding | Evidence | Required correction |
|---|---|---|---|---|
| AQ07-BLOCK-01 | BLOCK | Route keys for task flows are not the approved P0 route key. | `PACKAGE_MANIFEST.json` uses `task.list`, `task.create`, and `task.update`; `CARD_ACTION_BINDING_MATRIX.csv` uses the same; flow files FI-03/FI-04/FI-05 repeat those values. | Replace all task route keys with exact approved route key `task.card.route`. Dispatch must be based on `routeKey + action`, not custom route keys per action. |
| AQ07-BLOCK-02 | BLOCK | Ops failure route key is not the approved P0 route key. | `PACKAGE_MANIFEST.json`, `CARD_ACTION_BINDING_MATRIX.csv`, and FI-06 use `ops.failure`. | Replace with exact approved route key `pmo.ops`. |
| AQ07-BLOCK-03 | BLOCK | FI-03 is internally inconsistent: manifest says Planner `ListTasks_V3`, but the flow build file actions use SharePoint `GetItems` and `Return Tasks`. | `PACKAGE_MANIFEST.json` lists `plannerOperations: ["ListTasks_V3"]`; `flows/FI-03_PM0_PA_Card_ListarTarefas.md` action 1 says connector `SharePoint`, operationId `GetItems`. | Define the intended behavior explicitly. If FI-03 lists Planner tasks, action sequence must include Planner `ListTasks_V3` with `groupId` and `planId`, then normalization. If it lists SharePoint `Tarefas`, remove Planner operation claim and explain why. |
| AQ07-BLOCK-04 | BLOCK | Acceptance matrix says route keys PASS even though four route keys violate the approved contract. | `AQ07_ACCEPTANCE_MATRIX.md` says `each flow has route key | PASS`, but it did not validate allowed route key values. | Update acceptance criteria to check exact allowed values: `board.status`, `pmo.ops`, `pm.status.updates`, `task.card.route`. |
| AQ07-BLOCK-05 | BLOCK | Quality gate AQ-07 is marked `READY`, but the package has unresolved contract failures. | `QUALITY_GATES.md` marks `AQ-07 build/import` as `READY`. | Change AQ-07 to `BLOCKED_REWORK_REQUIRED` until route/action contract and FI-03 operation mismatch are fixed and revalidated. |

## 4. Required Rework Scope

Gemini must update only:

```text
.planning/comms/aq07_power_automate_build_20260515/
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
```

Required fixes:

1. Replace route keys:
   - `task.list` -> `task.card.route`
   - `task.create` -> `task.card.route`
   - `task.update` -> `task.card.route`
   - `ops.failure` -> `pmo.ops`
2. Keep action-specific behavior in the `action` field only.
3. Fix FI-03 action sequence to match its declared behavior.
4. Update manifest, CSV matrix, all affected flow files, acceptance matrix, quality gates, and validation file.
5. Re-run local validation.
6. Final status must be `READY_FOR_CODEX_REVIEW` only after all blocking findings are resolved.

## 5. Execution Statement

No tenant writes were performed.
No Planner writes were performed.
No Power Automate flow saves/imports were performed.
No Copilot publishes were performed.
No Teams production posts were performed.

```text
NO-SHIP
```

