# AQ-07 Planner Update Contract Owner Evidence - Partial

Date: 2026-05-15
Evidence source: owner-provided Power Automate run output
Reviewed by: CODEX-LEAD
Task scope: AQ-07 Planner update/bucket movement contract discovery
Release decision: NO-SHIP

## Verdict

PARTIAL_UPDATE_EVIDENCE_ONLY

The owner proved that a manual flow can call:

```text
CreateTask_V3 -> Compose -> UpdateTask_V2 -> GetTask_V2 -> Compose
```

The run succeeded, and `UpdateTask_V2` returned HTTP 200. However, the supplied output does not yet prove that the task moved buckets or changed `percentComplete`.

## Evidence Captured

### Create Task

```text
operationId: CreateTask_V3
statusCode: 201
request-id: 26d7fc06-4008-4333-be32-242267d3c465
taskId: 6ts5egbg5EW2AeEUI8oTb5cAHLp-
title: AQ07-CONTRACT-DELETE-ME-20260515
planId: -1kBj1PLv0qQM-R4PwkqbpcABv_P
```

### Update Task

```text
operationId: UpdateTask_V2
statusCode: 200
request-id: 51d30cc6-5ac2-49d1-9310-16545a71e334
taskId: 6ts5egbg5EW2AeEUI8oTb5cAHLp-
```

### Get Task

```text
operationId: GetTask_V2
statusCode: 200
taskId: 6ts5egbg5EW2AeEUI8oTb5cAHLp-
percentComplete shown in supplied output: 0
bucketId shown in supplied output: not present
```

## Issue

Expected after update:

```text
bucketId: 7QYPufh54kum7MP4KUzzAZcAL6Ik
percentComplete: 75
```

Observed in supplied output:

```text
percentComplete: 0
bucketId: not shown
```

This may mean one of three things:

1. The update action inputs did not include the bucket/percent fields.
2. The field names in `UpdateTask_V2` differ from the expected labels.
3. `GetTask_V2` output does not expose `bucketId`, so verification must use `ListTasks_V3`.

## Required Next Evidence

Capture either:

1. Raw inputs for `Atualizar uma tarefa`, showing the task id, bucket id, and percent complete fields actually sent.
2. A `ListTasks_V3` result for task `6ts5egbg5EW2AeEUI8oTb5cAHLp-`, showing:

```text
bucketId = 7QYPufh54kum7MP4KUzzAZcAL6Ik
percentComplete = 75
```

## 2026-05-15 ListTasks Verification

Owner provided a `ListTasks_V3` verification run:

```text
operationId: ListTasks_V3
statusCode: 200
request-id: fb7ced3f-8501-4deb-a12d-924d52fa6084
@odata.count: 16
```

The row for task `6ts5egbg5EW2AeEUI8oTb5cAHLp-` shows:

```text
id: 6ts5egbg5EW2AeEUI8oTb5cAHLp-
title: AQ07-CONTRACT-DELETE-ME-20260515
percentComplete: 0
bucketId: not present
```

This confirms the previous `UpdateTask_V2` run did not prove bucket movement or percent update.

Current conclusion:

```text
CreateTask_V3: PASS
UpdateTask_V2 field mutation: NOT PROVEN
Bucket placement: NOT PROVEN
```

## 2026-05-15 Owner Clarification

Owner clarified:

```text
I did not move from one bucket to another.
```

Therefore, later `ListTasks_V3` rows showing some test tasks with `percentComplete` values `50` or `100` are progress-only evidence. They are not bucket movement evidence.

Updated conclusion:

```text
CreateTask_V3 minimal create: PASS
UpdateTask_V2 progress mutation: PARTIAL PASS when the progress field is explicitly configured
UpdateTask_V2 bucket movement: NOT TESTED / NOT PROVEN
Created-task bucket placement: NOT PROVEN
```

## Tenant Actions During This Review

CODEX performed no tenant actions.

The owner-created Planner test task exists and should be cleaned up manually or through a separately approved cleanup step after evidence capture.
