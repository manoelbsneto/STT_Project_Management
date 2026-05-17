# AQ-07 Planner CreateTask Contract Owner Evidence

Date: 2026-05-15
Evidence source: owner-provided Power Automate run output
Reviewed by: CODEX-LEAD
Task scope: AQ-07 Planner `CreateTask_V3` contract discovery
Release decision: NO-SHIP

## Verdict

`CreateTask_V3` is now proven for the tenant with body-scoped minimal parameters.

This resolves the previous uncertainty that `CreateTask_V3` itself was unusable. It does not yet fully prove FI-04 bucket placement because the successful call did not include `body/bucketId`.

## Successful Request Shape

```json
{
  "host": {
    "connectionReferenceName": "shared_planner",
    "operationId": "CreateTask_V3"
  },
  "parameters": {
    "body/groupId": "96c5b0c4-46cc-46cd-8695-50451db74994",
    "body/planId": "-1kBj1PLv0qQM-R4PwkqbpcABv_P",
    "body/title": "Teste_Criacao_Automatizacao_Task"
  }
}
```

## Successful Response Evidence

```text
statusCode: 201
request-id: 650b978e-7778-4ecf-91e4-6df0dbe3ba25
client-request-id: 650b978e-7778-4ecf-91e4-6df0dbe3ba25
environment-id: e2d10003-4d8e-e007-9d63-76d5fe89ef56
tenant-id: 7808e005-1489-4374-954b-d3b08f193920
created taskId: dlUTQ3oNgkWA0SMcoiZYm5cAHkSK
created title: Teste_Criacao_Automatizacao_Task
created percentComplete: 0
createdDateTime: 2026-05-15T18:11:19.6332649Z
```

## What This Proves

| Contract point | Result |
|---|---|
| Planner connector connection reference `shared_planner` works for write | PASS |
| `CreateTask_V3` operation is available | PASS |
| `body/groupId` is accepted | PASS |
| `body/planId` is accepted | PASS |
| `body/title` is accepted | PASS |
| Planner task creation succeeds in `ColOfertasBrasilPro` | PASS |

## What Remains Unproven

| Contract point | Status |
|---|---|
| `CreateTask_V3` accepts `body/bucketId` directly | UNPROVEN |
| Created task can be moved to target bucket via `UpdateTask_V3` | PENDING OWNER EVIDENCE |
| FI-04 can create and store a SharePoint item with matching `PlannerBucketId` and `Status` after Planner write | PENDING FINAL FLOW BUILD/RUN EVIDENCE |

## Recommended Next Test

Run one owner-controlled update test against the created task:

```text
taskId: dlUTQ3oNgkWA0SMcoiZYm5cAHkSK
target bucket: Testes
bucketId: 7QYPufh54kum7MP4KUzzAZcAL6Ik
percentComplete: 75
```

If `UpdateTask_V3` succeeds, the robust FI-04 implementation path should be:

```text
CreateTask_V3 with body/groupId, body/planId, body/title
then UpdateTask_V3 with taskId, bucketId, and percentComplete/status-derived values when target bucket is not default
then Create SharePoint Item with PlannerTaskId, PlannerBucketId, Status, and sync fields
```

This avoids depending on `CreateTask_V3` accepting `body/bucketId` directly.

## Tenant Actions During This Review

CODEX performed no tenant actions.

The owner-created Planner test task exists and should be cleaned up manually or through a separately approved cleanup step after evidence capture.

