# Solution 2.6 Batch Preview Safe - Local Gates

Date: 2026-05-12

## Package

- File: `Solution/PMO_v11_Tarefas_2_6_BATCH_PREVIEW_SAFE.zip`
- SHA256: `2646BA6302541241103483DD6768895A85CAF2E35DE8A53D38DE250B1B68EDC3`
- Size: `74603` bytes
- Import/publish/deploy: not performed by Codex.

## Purpose

Version 2.6 is a safety mitigation for `Gerar_Multiplos_Projetos`.
Local inspection of version 2.5 showed the confirmed batch path could write raw input lines into `Projetos` and create default tasks without per-line validation. In 2.6, the batch workflow is explicitly preview/no-write until the Adaptive Card and per-line parser are hardened.

## Local Commands

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy\Build-Solution24LocalPackage.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-GerarMultiplosProjetosDefinition.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_6_BATCH_PREVIEW_SAFE.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP24Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_6_BATCH_PREVIEW_SAFE.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarTarefaCreatesTarefas.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_6_BATCH_PREVIEW_SAFE.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP0Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_6_BATCH_PREVIEW_SAFE.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-ExcluirSoftDeleteCapability.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_6_BATCH_PREVIEW_SAFE.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .\.planning\comms\solution_2_6_batch_preview_safe_20260512\unpacked
```

## Result

All listed local gates passed with `failedCheckCount=0`.

## Release Note

This package is safer than 2.5 for batch testing because it blocks batch writes. It does not yet satisfy the full PRD requirement for batch project/task creation. The next implementation step is the full Adaptive Card/per-line parser flow for `Nome_ProjetoN` and `TarefaN`, followed by controlled import and runtime tests by the project owner.
