Last updated: 2026-05-22 16:50:19 BRT | Codex sub-2C | AQ-09 smoke prep read-only PnP preflight attempted and blocked by missing active auth context

# Phase 1 Smoke Prep Report

## Scope

Agent: Codex sub-2C

Mission: PM0-FIXES-20260522-CODEX2

Write scope honored: `CODEX2/SMOKE_PREP/**` only for this report and generated evidence.

No tenant writes were performed.

## AQ-09 Shared Preconditions Read

Source: `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`

| Field | Value |
|---|---|
| SharePoint site | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital` |
| Active project name | `QA Robust 20260513 F` |
| Active ProjectID | `PRJ-274E5ACC` |
| Active project SharePoint item | `33` |
| Known active task for update | `15` |
| Known deleted task for audit | `13` |

## PnP Read-Only Preflight

Result: `BLOCKED_AUTH_OR_MODULE`

The required legacy module is installed, but there is no active PnP SharePoint context in a Windows PowerShell 5.1 process. The project runbook requires `Connect-PnPOnline -UseWebLogin` and the read commands to run in the same process. This subtask was instructed to run PnP only if existing auth/module allowed it without workaround; therefore no SharePoint reads were executed.

Evidence:

| Evidence | Path |
|---|---|
| Context check output | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/SMOKE_PREP/evidence/20260522_164923_CodexSub2C_pnp_context_check_clean.txt` |
| Rendered CLI output | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/SMOKE_PREP/preflight_data_check.png` |
| Structured preflight status | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/SMOKE_PREP/preflight_data_check.json` |
| Status Diario schema status | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/SMOKE_PREP/status_diario_schema.json` |

## Planned Read-Only Checks Not Executed

These remain pending for an owner-authenticated Windows PowerShell 5.1 session:

```powershell
Get-PnPListItem -List Projetos -Id 33 -Fields ID,Title,ProjectID,Ativo,Deleted
Get-PnPListItem -List Tarefas -Id 15 -Fields ID,Title,ProjectID,Status,Responsavel,DataFim,Prioridade,Deleted
Get-PnPListItem -List Tarefas -Id 13 -Fields ID,Title,Deleted,DeletedAt,DeletedReason,DeletedByUPN
Get-PnPField -List "Status Diario" | Where-Object { $_.InternalName -in @('ProjectID','RAG','Resumo','Percentual','Risco','Bloqueio','ProximaAcao','Deleted','Created','Title') }
```

## Blocker

AQ-09 test data readiness and `Status Diario` schema readiness are not confirmed by tenant evidence in this subtask. They must be re-run in the same Windows PowerShell 5.1 process after `Connect-PnPOnline -UseWebLogin`.
