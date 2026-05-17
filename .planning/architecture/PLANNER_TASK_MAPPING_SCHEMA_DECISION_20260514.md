# Planner Task Mapping Schema Decision for `Tarefas`

Date: 2026-05-14  
Status: Approved for future execution via owner-approved runbook; no SharePoint schema change executed in this turn  
Owner decision reference: `DEC-08` in `.planning/comms/OWNER_DECISIONS_REQUIRED_P0_ADAPTIVE_CARDS_PLANNER_20260514.md`

## 1. Decision

For the P0 Adaptive Cards + Planner architecture, task-level Planner mapping should be stored directly in the SharePoint `Tarefas` list.

Recommended fields:

| Display Name | Internal Name | Type | Required | Purpose |
|---|---|---|---:|---|
| Planner Task ID | `PlannerTaskId` | Single line text | No | Stores Planner task ID returned after create. |
| Planner Bucket ID | `PlannerBucketId` | Single line text | No | Stores bucket used for the current Planner task state. |
| Planner Sync Status | `PlannerSyncStatus` | Choice | No | `Pendente`, `OK`, `Erro`, `Ignorado` |
| Planner Last Sync At | `PlannerLastSyncAt` | Date and time | No | Last successful or attempted task-level sync. |
| Planner Sync Error | `PlannerSyncError` | Multiple lines text | No | Sanitized error message for support; not shown in Copilot chat. |

Optional later field:

| Display Name | Internal Name | Type | Required | Purpose |
|---|---|---|---:|---|
| Planner Task Link | `PlannerTaskLink` | Hyperlink or text | No | Suppressed in P0 cards because `DEC-09` says no Planner links for now. |

## 2. Rationale

Planner create/update requires durable correlation between:

```text
SharePoint Tarefas item <-> Planner task
```

Without `PlannerTaskId`, update flows cannot reliably update the same Planner task later.

Without task-level sync status, the system cannot distinguish:

- SharePoint task created, Planner skipped;
- SharePoint task created, Planner create failed;
- SharePoint task created, Planner create succeeded;
- SharePoint update succeeded, Planner update failed.

Because SharePoint remains the PMO source of record, the recommended write order is:

```text
1. Validate card input.
2. Write/update SharePoint Tarefas.
3. If Planner mapping exists, create/update Planner task.
4. Update Tarefas with PlannerTaskId / PlannerBucketId / sync status.
5. If Planner fails, keep SharePoint audit and record PlannerSyncStatus=Erro.
```

## 3. P0 Flow Behavior

### Create Task

If project has valid `PlannerGroupId`, `PlannerPlanId`, and bucket mapping:

```text
Create SharePoint Tarefas item
Create Planner task
Update Tarefas with PlannerTaskId, PlannerBucketId, PlannerSyncStatus=OK, PlannerLastSyncAt
```

If Planner mapping is missing:

```text
Create SharePoint Tarefas item
Set PlannerSyncStatus=Ignorado or Pendente
Do not fail the business operation
```

If Planner create fails:

```text
Keep SharePoint Tarefas item
Set PlannerSyncStatus=Erro
Set PlannerSyncError to sanitized short error
Notify PMO ops route if available
```

### Update Task

If `PlannerTaskId` exists:

```text
Update SharePoint Tarefas item
Update Planner task
Update PlannerSyncStatus and PlannerLastSyncAt
```

If `PlannerTaskId` does not exist:

```text
Update SharePoint Tarefas item
Set PlannerSyncStatus=Pendente or Ignorado
Do not attempt Planner update
```

## 4. Copilot and Adaptive Card Rules

- Copilot must not display `PlannerTaskId`, `PlannerBucketId`, or raw Planner errors.
- Teams cards may show a friendly sync label:
  - `Planner: sincronizado`
  - `Planner: pendente`
  - `Planner: erro de sincronizacao`
- Planner links are suppressed in P0 per owner decision `DEC-09`.
- Technical sync errors belong in SharePoint support fields and Power Automate run history, not in Copilot chat.

## 5. Implementation Control

This document approves the schema direction and future execution path.

It does not authorize:

- immediate SharePoint schema changes in this turn;
- Power Automate saves;
- solution import/export;
- Copilot publish;
- Planner writes.

Any actual SharePoint schema update must still be executed through the established tenant runbook, with an explicit implementation command/approval at that time.

## 6. Dependencies

Before implementation:

- Owner must approve actual tenant schema update timing.
- Planner bucket IDs must be discovered through the project master-doc/runbook access path only. Microsoft 365 CLI / `m365` is not approved for this discovery.
- Power Automate design must handle missing fields if schema is not yet deployed.
