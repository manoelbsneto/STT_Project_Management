# AQ-05 Local Artifact Validation

Date: 2026-05-15
Scope: `.planning/comms/p0_flow_artifacts_20260514`
Release decision: NO-SHIP
Tenant execution: None

## Checks Run

| Check | Result | Evidence |
|---|---|---|
| JSON parse | PASS | `flow_pseudocode_definitions.json` parsed with `ConvertFrom-Json` |
| Flow count | PASS | Parsed artifact contains 5 P0 flows |
| Importability warning | PASS | Artifact type is `local-pseudocode-not-importable` |
| Tenant execution flag | PASS | `tenantExecutionAuthorized` is `false` |
| ASCII scan | PASS | `Select-String '[^\\x00-\\x7F]'` returned no matches |
| Route keys | PASS | `board.status`, `pmo.ops`, `pm.status.updates`, and `task.card.route` are present |
| P0 card references | PASS | All six P0 card templates are referenced in `flow_pseudocode_definitions.json` |
| Planner sync fields | PASS | `PlannerTaskId`, `PlannerBucketId`, `PlannerSyncStatus`, `PlannerLastSyncAt`, and `PlannerSyncError` are present |
| AQ-04 Planner constants | PASS | Owner-provided `groupId`, `planId`, and six bucket IDs are present as local planning constants |
| NO-SHIP status | PASS | Artifact set keeps release decision `NO-SHIP` |

## Remaining Gates

AQ-05 is local-only and does not satisfy tenant/runtime gates.

Still pending:

- AQ-06 refresh after Gemini final local package review;
- AQ-07 owner-approved flow save/import;
- AQ-08 owner-approved Copilot publish/update;
- AQ-09 runtime smoke and XPIA regression evidence;
- AQ-10 final release decision.

Completed inputs now reflected locally:

- AQ-02 read-only `Tarefas` schema evidence found the required Planner sync fields missing.
- AQ-03 owner-approved schema write created the required Planner sync fields; evidence at `.planning/comms/AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md`.
- AQ-04 owner-provided Planner evidence is accepted for local mapping constants only.

No tenant writes were performed.
