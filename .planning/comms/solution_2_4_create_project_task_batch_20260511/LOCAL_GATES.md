# PMO 2.4 - Local Gate Evidence

Date: 2026-05-11
Scope: local package preparation only. No import, publish, deploy, production write, or runtime portal change was performed.

## Package

- Local package: `Solution/PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip`
- Unpacked evidence: `.planning/comms/solution_2_4_create_project_task_batch_20260511/unpacked`
- SharePoint read-only schema evidence: `.planning/comms/sharepoint_schema_2_4_20260511/schema_projetos_tarefas.json`

## SharePoint Read-Only Connection Note

Schema evidence was collected using read-only PnP commands (`Get-PnPList`, `Get-PnPField`, `Get-PnPListItem`). The local scripts can use `Connect-PnPOnline -UseWebLogin` in an assisted desktop session, but this is not a reliable headless authentication method. If a cached token is not available, PnP can open an interactive login/MFA prompt and block execution until the owner acts.

Operational rule: agents may run read-only SharePoint checks when the session is already authenticated, but must not perform imports, publishes, deployments, list writes, flow writes, or production changes. If interactive login is required, execution returns to the owner.

## Expected Local Gates

Run from repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP24Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP0Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-ExcluirSoftDeleteCapability.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .\.planning\comms\solution_2_4_create_project_task_batch_20260511\unpacked
git diff --check -- deploy/Build-Solution24LocalPackage.ps1 deploy/Get-SharePointSchemaReadOnly.ps1 tests/Test-CriarProjetoFlowDefinition.ps1 tests/Test-CriarTarefaCreatesTarefas.ps1 tests/Test-GerarMultiplosProjetosDefinition.ps1 tests/Test-SolutionZipP24Contracts.ps1 tests/Test-PMOFlowStopShipAudit.ps1 docs/SCHEMA_SHAREPOINT_PMO.md .planning/SKILLS_MAP.md .planning/phases/02.4-correcao-de-contrato-criarprojeto-criartarefa-gerar-multiplos-projetos .planning/comms/solution_2_4_create_project_task_batch_20260511/LOCAL_GATES.md
```

Runtime validation remains owner-controlled after manual import/publish.

## Result

Executed on 2026-05-11 from repository root:

- `Test-SolutionZipP24Contracts.ps1`: PASS, 0 failed checks.
- `Test-SolutionZipP0Contracts.ps1`: PASS, 0 failed checks.
- `Test-ExcluirSoftDeleteCapability.ps1`: PASS, 0 failed checks.
- `Test-PMOFlowStopShipAudit.ps1`: PASS, 0 failed checks.
- `git diff --check`: PASS with only an LF/CRLF normalization warning on `tests/Test-PMOFlowStopShipAudit.ps1`.

This evidence covers static package contracts only. Runtime behavior in Copilot Studio, Power Automate, Teams, and SharePoint must be validated after the owner performs the manual import/publish.

## Import Failure RCA - 2026-05-12

Owner-provided import log:

- `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (10).xml`
- Error: `Workflow import: Xaml file is missing from import zip file: FileName: /Workflows/PMO_PA_AtualizarStatus-C11A165B-C64C-F111-BEC7-7CED8D9559C1.json`
- Start time in log: `05/12/2026 01:58:21.705 UTC`
- Progress in log: `17.78`

Root cause:

- The first 2.4 ZIP was built with Windows path separators in ZIP entry names, for example `Workflows\PMO_PA_AtualizarStatus-...json`.
- `customizations.xml` references workflow JSON files with manifest paths like `/Workflows/PMO_PA_AtualizarStatus-...json`.
- Dataverse import resolved the manifest path and could not find a matching ZIP entry.

Correction:

- `deploy/Build-Solution24LocalPackage.ps1` now writes ZIP entries directly with `/` path separators.
- `tests/Test-SolutionZipP24Contracts.ps1` now blocks any ZIP entry containing `\`.
- `tests/Test-SolutionZipP24Contracts.ps1` now verifies every `<JsonFileName>/...` in `customizations.xml` exists as an exact ZIP entry without the leading `/`.

Microsoft references used:

- Microsoft Learn - SolutionPackager tool: solution packager/pac solution pack is the official solution package tooling and requires a valid extracted solution folder layout. Link: `https://learn.microsoft.com/en-us/power-platform/alm/solution-packager-tool`
- Microsoft Learn - Import solutions: Power Platform imports compressed `.zip` or `.cab` solution files and the downloaded XML log is the official failure evidence. Link: `https://learn.microsoft.com/en-us/power-apps/maker/data-platform/import-update-export-solutions`

PAC check:

- `pac solution pack` was tested against the current raw extracted ZIP folder.
- Result: not applicable to this folder layout because PAC expected `Other/Customizations.xml`.
- The package was therefore rebuilt from the raw exported solution layout with explicit ZIP entry normalization and manifest-path gates.

Corrected package:

- Path: `Solution/PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip`
- SHA256: `0FACF178209722BAE98401418A46C5D36A36B62B57E95373EB8B242EE4D8BA38`

Post-fix gates:

- `Test-SolutionZipP24Contracts.ps1`: PASS, including `Zip entries use Dataverse path separators`, `Zip contains AtualizarStatus workflow at manifest path`, and `All workflow JsonFileName manifest paths exist in ZIP`.
- `Test-SolutionZipP0Contracts.ps1`: PASS.
- `Test-ExcluirSoftDeleteCapability.ps1`: PASS.
- `Test-PMOFlowStopShipAudit.ps1`: PASS.
- `git diff --check`: PASS.

## Import Failure RCA - 2026-05-12 - Flow clientdata BOM

Owner-provided import log:

- `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (11).xml`
- Error: `Error while importing workflow {0a5d2a41-24c0-4d5e-9f6d-000000000241} type ModernFlow name PMO_PA_CriarTarefa: Flow clientdata is in invalid format. Details: "Unexpected character encountered while parsing value: [U+FEFF]. Path '', line 0, position 0."`
- Start time in log: `05/12/2026 02:17:50.256 UTC`
- Progress in log: `47.83`

Root cause:

- The local package builder used `Set-Content -Encoding UTF8` for newly generated workflow JSON files.
- On Windows PowerShell 5.1, that encoding writes UTF-8 with BOM.
- Byte evidence before correction showed the generated `PMO_PA_CriarTarefa` workflow started with `EF BB BF 7B`.
- Dataverse workflow import parsed the flow clientdata from byte zero and rejected the BOM before the opening `{`.

Correction:

- `deploy/Build-Solution24LocalPackage.ps1` now writes generated text files with `[System.Text.UTF8Encoding]::new($false)` semantics via `System.IO.File.WriteAllText`.
- Generated workflow JSON and bot topic data now start directly with payload content, not a BOM.
- `tests/Test-SolutionZipP24Contracts.ps1` now blocks UTF-8 BOM in `Workflows/*.json` and `botcomponents/*/data`.

Post-fix byte evidence:

- `PMO_PA_CriarTarefa-0A5D2A41-24C0-4D5E-9F6D-000000000241.json`: first bytes `7B 0D 0A 20 20 20 20 22`, `HasBom=False`.
- `PMO_PA_Gerar_Multiplos_Projetos-0A5D2A42-24C0-4D5E-9F6D-000000000241.json`: first bytes `7B 0D 0A 20 20 20 20 22`, `HasBom=False`.

Updated corrected package:

- Path: `Solution/PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip`
- SHA256: `0FACF178209722BAE98401418A46C5D36A36B62B57E95373EB8B242EE4D8BA38`

Post-BOM-fix gates:

- `Test-SolutionZipP24Contracts.ps1`: PASS, including `No UTF-8 BOM in workflow/clientdata files`.
- `Test-SolutionZipP0Contracts.ps1`: PASS.
- `Test-ExcluirSoftDeleteCapability.ps1`: PASS.
- `Test-PMOFlowStopShipAudit.ps1`: PASS.
- `git diff --check -- deploy/Build-Solution24LocalPackage.ps1 tests/Test-SolutionZipP24Contracts.ps1`: PASS.

Release decision:

- Local package readiness: PASS.
- Owner manual import: PASS. Evidence: `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (12).xml`, solution status `Procesado`, version `2.4`.
- Production ship readiness: NO-SHIP until the owner completes publish confirmation and runtime validation.
