# Solution 2.5 - CriarTarefa Brazilian Date Contract

Date: 2026-05-12

Scope: local-only package preparation. No import, publish, deploy, portal change, SharePoint write, or production runtime mutation was performed by Codex.

## Package

- Path: `Solution/PMO_v11_Tarefas_2_5_CRIARTAREFA_BR_DATE_FIX.zip`
- SHA256: `CD5D1308FA7B1F5CE3A42D33B12DA4E645A33703C97FF443581F5E2A23205A63`
- Size: `75596` bytes
- Solution version: `2.5`

## Fixes

- `CriarTarefa` now treats `dd/MM/aaaa` as the user-facing required date format.
- `CriarTarefa` converts valid `dd/MM/aaaa` to `yyyy-MM-dd` internally before writing SharePoint `Tarefas.DataFim`.
- `CriarTarefa` rejects raw ISO/US pass-through dates with controlled business response:
  `Prazo invalido. Use formato brasileiro dd/MM/aaaa, ex: 30/06/2026. Codigo: INVALID_BR_DATE.`
- `CriarTarefa` title parser now prioritizes `titulo=` / `titulo:` and no longer treats the command prefix `criar tarefa:` as the task title.

## Local Gates

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy\Build-Solution24LocalPackage.ps1
```

Result: built `D:\VMs\Projetos\STT_Project_Management\Solution\PMO_v11_Tarefas_2_5_CRIARTAREFA_BR_DATE_FIX.zip`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarTarefaCreatesTarefas.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_5_CRIARTAREFA_BR_DATE_FIX.zip
```

Result: `passed=true`, `failedCheckCount=0`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP24Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_5_CRIARTAREFA_BR_DATE_FIX.zip
```

Result: `passed=true`, `failedCheckCount=0`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP0Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_5_CRIARTAREFA_BR_DATE_FIX.zip
```

Result: `passed=true`, `failedCheckCount=0`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-ExcluirSoftDeleteCapability.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_5_CRIARTAREFA_BR_DATE_FIX.zip
```

Result: `passed=true`, `failedCheckCount=0`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .\.planning\comms\solution_2_5_criartarefa_br_date_20260512\unpacked
```

Result: `passed=true`, `failedCheckCount=0`.

```powershell
git diff --check -- deploy/Build-Solution24LocalPackage.ps1 tests/Test-CriarTarefaCreatesTarefas.ps1 tests/Test-SolutionZipP24Contracts.ps1
```

Result: no whitespace errors.

```powershell
Get-FileHash -Algorithm SHA256 .\Solution\PMO_v11_Tarefas_2_5_CRIARTAREFA_BR_DATE_FIX.zip
```

Result: `CD5D1308FA7B1F5CE3A42D33B12DA4E645A33703C97FF443581F5E2A23205A63`.

## Runtime Status

NO-SHIP for runtime until owner manually imports/publishes version 2.5 and completes Copilot Studio validation.
