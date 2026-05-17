# AQ-02 SharePoint Tarefas Schema Read-Only Evidence

Date: 2026-05-15
Owner approval: AQ-02 approved in current thread
Executed by: CODEX-LEAD
Access type: Tenant read-only
Release decision: NO-SHIP

## 1. Command Executed

Runbook path:

- `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
- `.planning/TENANT_COMMAND_RUNBOOK.md`
- `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`

Command:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\deploy\Get-SharePointListXmlReadOnly.ps1 -SiteUrl "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital" -ListNames "Tarefas" -OutputDir ".planning\comms\sharepoint_schema_tarefas_aq02_20260515"
```

No schema writes, item writes, Planner reads/writes, flow saves, imports, publishes, or Teams production posts were authorized or performed.

## 2. Evidence Output

Output folder:

```text
.planning/comms/sharepoint_schema_tarefas_aq02_20260515/
```

Key files:

| File | Purpose |
|---|---|
| `.planning/comms/sharepoint_schema_tarefas_aq02_20260515/inventory.json` | List inventory |
| `.planning/comms/sharepoint_schema_tarefas_aq02_20260515/inventory.csv` | List inventory CSV |
| `.planning/comms/sharepoint_schema_tarefas_aq02_20260515/Tarefas/fields_summary.json` | Field inventory |
| `.planning/comms/sharepoint_schema_tarefas_aq02_20260515/Tarefas/fields_summary.csv` | Field inventory CSV |
| `.planning/comms/sharepoint_schema_tarefas_aq02_20260515/Tarefas/list_schema.xml` | Raw list schema XML |
| `.planning/comms/sharepoint_schema_tarefas_aq02_20260515/Tarefas/fields/` | Raw field XML files |
| `.planning/comms/sharepoint_schema_tarefas_aq02_20260515/Tarefas/views/` | Raw view XML files |

Read-only command result:

```text
List: Tarefas
ListId: 36d78ca1-1f60-4dd3-a4d5-5c94b89969e9
ItemCount: 16
```

## 3. Required Planner Fields Check

| Required field | Exists in Tarefas | Result |
|---|---:|---|
| `PlannerTaskId` | No | MISSING |
| `PlannerBucketId` | No | MISSING |
| `PlannerSyncStatus` | No | MISSING |
| `PlannerLastSyncAt` | No | MISSING |
| `PlannerSyncError` | No | MISSING |

## 4. Existing Relevant Tarefas Fields

The list already contains these relevant fields:

| Title | Internal name | Type | Required |
|---|---|---|---:|
| `Title` / localized title | `Title` | Text | Yes |
| `ProjectID` | `ProjectID` | Text | Yes |
| `Responsavel` | `Responsavel` | Text | No |
| `DataInicio` | `DataInicio` | DateTime | No |
| `DataFim` | `DataFim` | DateTime | No |
| `HorasEstimadas` | `HorasEstimadas` | Number | No |
| `HorasRealizadas` | `HorasRealizadas` | Number | No |
| `Status` | `Status` | Choice | Yes |
| `Prioridade` | `Prioridade` | Choice | No |
| `Deleted` | `Deleted` | Boolean | No |
| `DeletedAt` | `DeletedAt` | DateTime | No |
| `DeletedReason` | `DeletedReason` | Text | No |
| `DeletedByUPN` | `DeletedByUPN` | Text | No |

## 5. Decision Impact

AQ-02 is complete.

Because all five Planner mapping fields are missing, AQ-03 is now the next schema-related approval gate if the owner wants Planner create/update sync to be durable on `Tarefas`.

AQ-03 must remain a separate explicit tenant-write approval. AQ-02 did not authorize any schema write.

## 6. Current Release Status

```text
NO-SHIP
```

Reason:

- Planner mapping fields are missing from `Tarefas`.
- Planner plan/bucket IDs are still pending AQ-04 read-only discovery.
- No flow save/import/publish/runtime evidence exists for the current P0 artifact.

No tenant writes were performed.

