# CODEX Review: Gemini AQ-07 Exact Planner Inputs Rework

Date: 2026-05-15
Reviewer: CODEX-LEAD
Reviewed scope:

- `.planning/comms/aq07_power_automate_build_20260515/`
- `.planning/comms/GEMINI_AQ07_REWORK_PROMPT_EXACT_PLANNER_INPUTS_20260515.md`
- AQ-03 post-write SharePoint schema evidence

Tenant execution during review: none
Release decision: NO-SHIP

## 1. Verdict

Status: BLOCKED_REWORK_REQUIRED

Gemini fixed the previous route-key blockers and most Planner input ambiguity. However, AQ-07 is still not ready for owner approval because FI-04 would create a SharePoint `Tarefas` item without required fields.

Do not request AQ-07 owner approval from this package yet.

## 2. Passing Checks

| Check | Result |
|---|---|
| Required files exist | PASS |
| `PACKAGE_MANIFEST.json` parses | PASS |
| Manifest route keys are approved values only | PASS |
| CSV route keys are approved values only | PASS |
| Operational files no longer contain invalid route keys | PASS |
| FI-03 uses `ProjectID` as SharePoint correlation field | PASS |
| AQ-03 schema confirms `ProjectID` exists on `Tarefas` | PASS |
| FI-04 has exact Planner create inputs: `groupId`, `planId`, `bucketId`, `title`, optional dates | PASS |
| FI-04 has default bucket rule to `Pendente` | PASS |
| FI-05 has explicit status-to-bucket and `percentComplete` mapping | PASS |
| No prior ambiguous Planner placeholders remain | PASS |

## 3. Blocking Finding

| ID | Severity | Finding | Evidence | Required correction |
|---|---|---|---|---|
| AQ07-BLOCK-10 | BLOCK | FI-04 `Create SharePoint Item` omits required `Tarefas` fields. | AQ-03 post-write schema confirms `Title`, `ProjectID`, and `Status` are required. `flows/FI-04_PM0_PA_Card_CriarTarefa.md` action 3 only sets `PlannerTaskId=NewPlannerTaskId`. | Update FI-04 create item inputs to include at minimum `Title`, `ProjectID`, `Status`, `PlannerTaskId`, `PlannerBucketId`, `PlannerSyncStatus`, and `PlannerLastSyncAt`. |

## 4. Required Rework

Gemini must update only:

```text
.planning/comms/aq07_power_automate_build_20260515/
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
```

Required corrections:

1. In `flows/FI-04_PM0_PA_Card_CriarTarefa.md`, update action `Create SharePoint Item`.
2. The action must include exact inputs:
   - `Title=triggerBody()?['title']`
   - `ProjectID=triggerBody()?['projectId']`
   - `Status='Pendente'` or the mapped status from the selected bucket
   - `PlannerTaskId=<Planner Create Task output id>`
   - `PlannerBucketId=DetermineBucket_Output`
   - `PlannerSyncStatus='OK'`
   - `PlannerLastSyncAt=utcNow()`
   - `PlannerSyncError=''`
3. Update `SharePoint Behavior` write order and required fields.
4. Update `FIELD_MAPPING.md`, `AQ07_ACCEPTANCE_MATRIX.md`, and `VALIDATION.md` to include required SharePoint create fields.
5. Final validation must confirm FI-04 populates all required SharePoint fields before status `READY_FOR_CODEX_REVIEW`.

## 5. Execution Statement

No tenant writes were performed.
No Planner writes were performed.
No Power Automate flow saves/imports were performed.
No Copilot publishes were performed.
No Teams production posts were performed.

```text
NO-SHIP
```

