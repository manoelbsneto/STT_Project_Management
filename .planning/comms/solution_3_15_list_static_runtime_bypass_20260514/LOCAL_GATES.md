# Solution 3.15 Local Gates

Agent: Codex
Timestamp BRT: 2026-05-14 14:35
Decision: CODE-READY / NO FINAL SHIP UNTIL IMPORT, PUBLISH, AND LIVE RUNTIME PROOF
CI gate: Owner-excluded for this mission only

## Package

```text
Package: Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip
SHA256: 0A68BB03F9C79440EA9AA09F7E5EE067681FCBDE0241F51F4C27BEB8EA61A9A6
Version: 3.15
```

## Root Fix

3.14 still allowed `ListarTarefas` dynamic SharePoint data to reach Copilot Studio post-processing, causing `ContentFiltered` / `openAIIndirectAttack` after the command succeeded.

3.15 changes the bot-visible contract:

- `ListarTarefas` flow returns a static `result` only.
- `ListarTarefas` topic sends static text and does not echo `{Topic.tarefas}`.
- `AtualizarTarefa` success and project-not-found flow responses expose only `result`.
- `AtualizarTarefa` confirmation and final topic messages no longer echo raw user/task fields.

## Gates

| Gate | Command | Result |
|---|---|---|
| Build package | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-Solution315ListStaticRuntimeBypass.ps1` | PASS |
| AtualizarTarefa skip/static response | `powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-AtualizarTarefaSkipSemantics.ps1 -PackagePath Solution\PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` | PASS |
| ListarTarefas content-safe contract | `powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-ListarTarefasContentSafeContract.ps1 -PackagePath Solution\PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` | PASS |
| StopShip source audit | `powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .planning\comms\solution_3_15_list_static_runtime_bypass_20260514\unpacked` | PASS |
| Power Fx regex safety | `powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-CopilotPowerFxRegexSafety.ps1 -PackagePath Solution\PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` | PASS |
| P0 package contracts | `powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-SolutionZipP0Contracts.ps1 -PackagePath Solution\PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` | PASS |
| P24 package contracts | `powershell -NoProfile -ExecutionPolicy Bypass -File tests/Test-SolutionZipP24Contracts.ps1 -PackagePath Solution\PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip -ExpectedVersion 3.15` | PASS |
| SharePoint read-only runtime snapshot | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .planning\comms\solution_3_15_list_static_runtime_bypass_20260514\Get-SharePointReadonlySnapshot.ps1` | PASS |

## Read-Only Runtime Snapshot

```text
Project: QA Robust 20260513 F
Project item ID: 33
ProjectID: PRJ-274E5ACC
Active task IDs: 14, 15
Task 14: Status Em Andamento, Prioridade Media, DataFim 2026-05-19, Horas 128/19
Task 15: Status Em Andamento, Prioridade Media, DataFim 2026-05-20, Horas 2/8
Evidence: .planning/comms/solution_3_15_list_static_runtime_bypass_20260514/sharepoint_readonly_runtime_snapshot_20260514.json
```

## Remaining Gate

Live Copilot Studio runtime proof is still required after owner import and publish.
