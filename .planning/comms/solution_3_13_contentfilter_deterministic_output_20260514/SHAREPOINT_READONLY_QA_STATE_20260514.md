# SHAREPOINT READ-ONLY QA STATE - 2026-05-14

Agent: Codex
Timestamp BRT: 2026-05-14
Mode: Read-only SharePoint query

## Required Connection Path Used

The query followed the mandatory project runbook:

- Windows PowerShell 5.1 via `powershell.exe`
- Legacy module `SharePointPnPPowerShellOnline 3.29.2101.0`
- `Connect-PnPOnline -Url https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital -UseWebLogin`
- Query executed in the same PowerShell process as the login

Reference docs:

- `.planning/TENANT_COMMAND_RUNBOOK.md`
- `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`

## Confirmed Project

| Field | Value |
|---|---|
| List | `Projetos` |
| SharePoint item ID | `33` |
| NomeProjeto | `QA Robust 20260513 F` |
| ProjectID | `PRJ-274E5ACC` |
| Ativo | `True` |
| Deleted | `False` |
| StatusRAG | `Amarelo` |
| Percentual | `0` |
| TarefasTotal | `2` |
| TarefasConcluidas | `0` |
| TarefasAbertas | `2` |
| TarefasAtrasadas | `0` |

## Confirmed Tasks

| ID | Title | ProjectID | Status | Prioridade | Responsavel | DataFim Raw | HorasEstimadas | HorasRealizadas | Deleted |
|---:|---|---|---|---|---|---|---:|---:|---|
| 13 | `Validar status choice 3.4` | `PRJ-274E5ACC` | `Concluida` | `Alta` | `mbenicios@minsait.com` | `29/06/2026 22:00:00` | 2 | 18 | `True` |
| 14 | `QA Skip Opcional 20260513 1935` | `PRJ-274E5ACC` | `Em Andamento` | `Media` | `mbenicios@minsait.com` | `19/05/2026 22:00:00` | 19 | 128 | `False` |
| 15 | `QA Final Skip 20260513 2105` | `PRJ-274E5ACC` | `Em Andamento` | `Media` | `mbenicios@minsait.com` | `20/05/2026 22:00:00` | 8 | 2 | `False` |

## Runtime Command Inputs Derived From Query

Use task `15` for update regression because it is active, belongs to `PRJ-274E5ACC`, has controlled current values, and was already used in the latest QA cycle.

