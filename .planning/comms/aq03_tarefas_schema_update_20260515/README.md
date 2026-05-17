# AQ-03 Tarefas Planner Schema Update Package

Date: 2026-05-15
Owner: CODEX-LEAD
Status: READY FOR OWNER APPROVAL
Tenant execution: Not performed
Release decision: NO-SHIP

## 1. Purpose

Prepare the controlled SharePoint schema update needed for durable Planner task create/update sync on `Tarefas`.

AQ-02 confirmed these fields are missing from the live `Tarefas` list:

- `PlannerTaskId`
- `PlannerBucketId`
- `PlannerSyncStatus`
- `PlannerLastSyncAt`
- `PlannerSyncError`

AQ-04 now provides owner-accepted Planner ID evidence, so the remaining schema blocker is AQ-03 execution.

## 2. Field Plan

| Display Name | Internal Name | Type | Required | Choices / Default |
|---|---|---|---:|---|
| Planner Task ID | `PlannerTaskId` | Text | No | Indexed |
| Planner Bucket ID | `PlannerBucketId` | Text | No | Indexed |
| Planner Sync Status | `PlannerSyncStatus` | Choice | No | `Pendente`, `OK`, `Erro`, `Ignorado`; default `Pendente`; indexed |
| Planner Last Sync At | `PlannerLastSyncAt` | DateTime | No | No default |
| Planner Sync Error | `PlannerSyncError` | Note | No | Sanitized support text only |

## 3. Execution Approval Required

This package does not authorize tenant writes.

Required owner approval text before execution:

```text
Approve CODEX-LEAD to execute AQ-03 and add the Planner mapping fields to SharePoint list Tarefas using .planning/comms/aq03_tarefas_schema_update_20260515/Add-TarefasPlannerFields.ps1 with -ConfirmTenantWrite. No Planner writes, flow saves, imports, publishes, or Teams production posts are authorized.
```

## 4. Exact Command After Approval

Use Windows PowerShell 5.1 and legacy PnP in one process.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass
```

Then:

```powershell
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
$env:PNPLEGACYMESSAGE = "false"
Set-Location "D:\VMs\Projetos\STT_Project_Management"
Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin
.\.planning\comms\aq03_tarefas_schema_update_20260515\Add-TarefasPlannerFields.ps1 -SiteUrl $siteUrl -SkipConnection -ConfirmTenantWrite
```

## 5. Evidence Outputs

The script writes:

```text
.planning/comms/aq03_tarefas_schema_update_20260515/evidence/aq03_tarefas_planner_fields_write_summary.json
.planning/comms/aq03_tarefas_schema_update_20260515/evidence/aq03_tarefas_planner_fields_verify.csv
```

Recommended post-write independent read-only evidence:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\deploy\Get-SharePointListXmlReadOnly.ps1 -SiteUrl "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital" -ListNames "Tarefas" -OutputDir ".planning\comms\sharepoint_schema_tarefas_aq03_after_20260515"
```

## 6. Rollback Position

Default rollback is non-destructive:

- stop depending flows;
- ignore the new fields;
- keep field data for audit.

Removing SharePoint fields is destructive because it deletes field data. Field removal requires a separate explicit owner approval and a dependency check. Do not remove fields as part of AQ-03 rollback by default.

## 7. Current Gate Status

| Gate | Status |
|---|---|
| AQ-02 read-only schema proof | DONE |
| AQ-04 Planner ID evidence | DONE OWNER EVIDENCE |
| AQ-03 schema write | READY FOR OWNER APPROVAL |
| AQ-07 flow save/import | BLOCKED |
| AQ-08 Copilot publish | BLOCKED |
| AQ-09 runtime smoke / XPIA | BLOCKED |
| AQ-10 SHIP decision | BLOCKED |

No tenant writes were performed while preparing this package.
