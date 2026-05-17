# LOCAL GATES - 2026-05-14

Agent: Codex
Package: `Solution/PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip`
SHA256: `D1752B089424ACA6C571374B8897AD12F8A8304DF228A17C8C591BD1EEF1CDAF`

## Result

Local gates: PASS
Release decision: NO-SHIP pending import, publish, and fresh runtime evidence

## Commands Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-AtualizarTarefaSkipSemantics.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-SolutionZipP0Contracts.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-SolutionZipP24Contracts.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip" -ExpectedVersion "3.11"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath ".planning\comms\solution_3_11_atualizartarefa_response_date_fix_20260514\unpacked"
Get-FileHash -Algorithm SHA256 "Solution\PMO_v11_Tarefas_3_11_ATUALIZARTAREFA_RESPONSE_DATE_FIX.zip"
```

## Outputs

| Gate | Result |
|---|---|
| AtualizarTarefa skip/date regression | PASS |
| P0 ZIP contracts | PASS |
| P24 ZIP contracts version 3.11 | PASS |
| Stop-ship source audit | PASS |
| Package SHA256 | `D1752B089424ACA6C571374B8897AD12F8A8304DF228A17C8C591BD1EEF1CDAF` |

## Changes

- `PMO_PA_AtualizarTarefa` normalizes `DataFim` from `dd/MM/yyyy` to `yyyy-MM-dd`.
- `PMO_PA_AtualizarTarefa` response displays persisted `Update_Tarefa` values.
- `AtualizarTarefa` topic final message no longer echoes raw topic variables.
- Local package no longer includes stale `gstf_sharepoint` connection reference.

