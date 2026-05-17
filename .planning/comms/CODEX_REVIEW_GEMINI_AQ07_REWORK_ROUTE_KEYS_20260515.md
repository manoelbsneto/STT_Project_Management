# CODEX Review: Gemini AQ-07 Route-Key Rework

Date: 2026-05-15
Reviewer: CODEX-LEAD
Reviewed scope:

- `.planning/comms/aq07_power_automate_build_20260515/`
- `.planning/comms/GEMINI_AQ07_REWORK_PROMPT_ROUTE_KEYS_20260515.md`
- `.planning/comms/CODEX_REVIEW_GEMINI_AQ07_BUILD_PACKAGE_20260515.md`

Tenant execution during review: none
Release decision: NO-SHIP

## 1. Verdict

Status: BLOCKED_REWORK_REQUIRED

The targeted route-key rework passed. However, the full AQ-07 portal-build package is still not ready for owner approval because several Power Automate action inputs remain ambiguous or incomplete. A portal-build runbook must let the owner build without interpretation.

Do not request AQ-07 owner approval from this package yet.

## 2. Fixed From Previous Review

| Previous blocker | Result |
|---|---|
| `task.list`, `task.create`, `task.update` used as route keys | FIXED. Manifest, CSV, and FI-03/FI-04/FI-05 now use `task.card.route`. |
| `ops.failure` used as route key | FIXED. Manifest, CSV, and FI-06 now use `pmo.ops`. |
| FI-03 manifest declared `ListTasks_V3` while flow omitted it | PARTIAL FIX. FI-03 now includes Planner `ListTasks_V3` and normalization. |
| Acceptance matrix did not validate allowed route key values | FIXED. Acceptance matrix now checks exact allowed route keys. |

## 3. Checks Run

| Check | Result |
|---|---|
| Required files exist | PASS |
| `PACKAGE_MANIFEST.json` parses | PASS |
| Manifest route keys are approved values only | PASS |
| CSV route keys are approved values only | PASS |
| Operational files no longer contain invalid route key values | PASS |
| FI-03 contains `ListTasks_V3` | PASS |
| No non-ASCII content found in package | PASS |

Note: `VALIDATION.md` mentions old invalid route keys only as validation evidence that they were replaced. That is not treated as an operational blocker.

## 4. Remaining Blocking Findings

| ID | Severity | Finding | Evidence | Required correction |
|---|---|---|---|---|
| AQ07-BLOCK-06 | BLOCK | FI-04 Planner create action does not specify exact Planner inputs needed for portal build. | `flows/FI-04_PM0_PA_Card_CriarTarefa.md` action 1 says `input parameters: planId, title`; Planner behavior says `bucket IDs from AQ-04: target specific bucket`. | Specify exact create inputs: `groupId`, `planId`, `bucketId`, `title`, optional start/due fields, and exact bucket selection rule using AQ-04 bucket IDs. |
| AQ07-BLOCK-07 | BLOCK | FI-05 Planner update action uses ambiguous `details` payload and does not map status to bucket/percent fields. | `flows/FI-05_PM0_PA_Card_AtualizarTarefa.md` action 2 says `input parameters: taskId=TargetPlannerTaskId, details`; Planner behavior says `bucket IDs from AQ-04: use target bucket`. | Replace `details` with exact update fields. Define status-to-bucket/percentComplete mapping using AQ-04 bucket IDs and live SharePoint status choices. |
| AQ07-BLOCK-08 | BLOCK | FI-03 SharePoint filter is likely wrong or under-specified for project filtering. | `flows/FI-03_PM0_PA_Card_ListarTarefas.md` says `filter queries: Title eq projectId`. | Define the actual SharePoint internal field used for project correlation, or state that FI-03 uses Planner plan-wide task listing only and remove the invalid SharePoint title filter. |
| AQ07-BLOCK-09 | BLOCK | Package validation says `known gaps: None`, but the build steps still require interpretation. | `VALIDATION.md` final status is `READY_FOR_CODEX_REVIEW`; flow files still contain ambiguous Planner build inputs. | Update validation and acceptance only after FI-03/FI-04/FI-05 have exact portal-build input parameters. |

## 5. Required Rework

Gemini must update only:

```text
.planning/comms/aq07_power_automate_build_20260515/
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
```

Required outputs after rework:

1. FI-03 has a precise task source and precise project-correlation behavior.
2. FI-04 has exact Planner create parameters and exact bucket ID selection.
3. FI-05 has exact Planner update parameters and exact status-to-bucket/percent mapping.
4. `FIELD_MAPPING.md`, `PACKAGE_MANIFEST.json`, `CARD_ACTION_BINDING_MATRIX.csv`, `AQ07_ACCEPTANCE_MATRIX.md`, `QUALITY_GATES.md`, and `VALIDATION.md` reflect the precise rules.
5. No `target specific bucket`, `use target bucket`, or `details` placeholder remains in Planner action input sections.

## 6. Execution Statement

No tenant writes were performed.
No Planner writes were performed.
No Power Automate flow saves/imports were performed.
No Copilot publishes were performed.
No Teams production posts were performed.

```text
NO-SHIP
```

