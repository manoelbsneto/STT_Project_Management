# PMO 2.4 Pre-Import Compare - Current Unmanaged 1.18 vs Candidate 2.4

Date: 2026-05-11
Scope: local static comparison only. No import, publish, deploy, production write, schema change, or runtime portal change was performed.

## Inputs

- Current UI export, unmanaged: `C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_1_18_unmanaged.zip`
- Current SHA256: `14F175B401C25E2584EFB31AD5872B8C22E746F79E78D08F402C5C8CF010D220`
- Candidate package: `Solution/PMO_v11_Tarefas_2_4_CREATE_PROJECT_TASK_BATCH_FIX.zip`
- Candidate SHA256: `0FACF178209722BAE98401418A46C5D36A36B62B57E95373EB8B242EE4D8BA38`

## Solution Metadata

- Same solution unique name: `PMO_v11_Tarefas`
- Same publisher unique name: `DefaultPublishercolofertasbrasilpro`
- Current version: `1.18`
- Candidate version: `2.4`
- Current managed flag: `0`
- Candidate managed flag: `0`

## Package Shape

- Current entries: 60
- Candidate entries: 66
- Current workflow files: 14
- Candidate workflow files: 16
- Current botcomponent entries: 40
- Candidate botcomponent entries: 44
- Entity/schema entries in both packages: 0
- ZIP entries with Windows backslash separators in both packages: 0

## Component Diff

Expected files only in candidate:

- `botcomponents/pmo_AssistentePMO_V2.topic.CriarProjeto/botcomponent.xml`
- `botcomponents/pmo_AssistentePMO_V2.topic.CriarProjeto/data`
- `botcomponents/pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos/botcomponent.xml`
- `botcomponents/pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos/data`
- `Workflows/PMO_PA_CriarProjeto-3104124D-364A-F111-BEC7-7CED8D955C6C.json`
- `Workflows/PMO_PA_CriarTarefa-0A5D2A41-24C0-4D5E-9F6D-000000000241.json`
- `Workflows/PMO_PA_Gerar_Multiplos_Projetos-0A5D2A42-24C0-4D5E-9F6D-000000000241.json`

Expected file only in current:

- `Workflows/PMO_PA_CriarTarefa_V3-3104124D-364A-F111-BEC7-7CED8D955C6C.json`

Interpretation:

- Workflow ID `3104124d-364a-f111-bec7-7ced8d955c6c` is intentionally renamed from `PMO_PA_CriarTarefa_V3` to `PMO_PA_CriarProjeto`.
- Candidate adds two new root workflow components: `PMO_PA_CriarTarefa` and `PMO_PA_Gerar_Multiplos_Projetos`.
- Candidate adds two new topic components: `CriarProjeto` and `Gerar_Multiplos_Projetos`.

## Unchanged Existing Runtime Components

The 13 shared workflow JSON definitions, excluding the intentionally renamed `CriarTarefa_V3` file, are canonically identical between current 1.18 and candidate 2.4:

- `PMO_PA_AtualizarStatus`
- `PMO_PA_AtualizarTarefa`
- `PMO_PA_CheckInOnDemand`
- `PMO_PA_ConsultarPortfolio`
- `PMO_PA_ConsultarProjeto`
- `PMO_PA_EscalarRiscoCritico`
- `PMO_PA_ExcluirProjeto`
- `PMO_PA_ExcluirTarefa`
- `PMO_PA_ListarTarefas`
- `PMO_PA_PedirDecisaoBot`
- `PMO_PA_RegistrarBloqueioBot`
- `PMO_PA_RegistrarDecisaoBoard`
- `PMO_PA_RegistrarRiscoBot`

Shared topic data checked:

- `ExcluirTarefa`: unchanged.
- `ExcluirProjeto`: unchanged.
- `ListarTarefas`: unchanged.
- `ConsultarPortfolio`: unchanged.
- `CriarTarefa`: changed as expected to route task creation to the new `PMO_PA_CriarTarefa` flow instead of project creation.

## Schema / Connector Risk

- No Dataverse entity/table files are present in either package.
- No package markers for SharePoint schema mutation were found: no `CreateList`, `DeleteList`, `CreateField`, `DeleteField`, `UpdateField`, `Add-PnPField`, `Set-PnPField`, or `Remove-PnPField`.
- Candidate operation IDs remain within the existing connector surface: `GetItem`, `GetItems`, `GetOnNewItems`, `PatchItem`, `PostCardAndWaitForResponse`, `PostCardToConversation`, `PostItem`, `SendEmailV2`.
- Candidate adds SharePoint target list ID `36d78ca1-1f60-4dd3-a4d5-5c94b89969e9`, verified as `Tarefas` in the read-only schema evidence.

## Gates Re-Run After Compare

- `Test-SolutionZipP24Contracts.ps1`: PASS, 0 failed checks.
- `Test-SolutionZipP24Contracts.ps1` post-import-failure hardening: PASS, including `No UTF-8 BOM in workflow/clientdata files`.
- `Test-SolutionZipP0Contracts.ps1`: PASS, 0 failed checks.
- `Test-ExcluirSoftDeleteCapability.ps1`: PASS, 0 failed checks.
- `Test-PMOFlowStopShipAudit.ps1`: PASS, 0 failed checks.
- `git diff --check`: PASS.

## Verdict

Static pre-import compare is PASS for schema safety and expected component scope.

Owner-controlled manual import succeeded after the UTF-8 BOM package fix.

Import evidence:

- Log: `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (12).xml`
- Log SHA256: `45548CB1A60CBA1243DE4469B86E32C89492CA61A8C7994754BFCCA43F0D9ACC`
- Solution status: `Procesado`
- Imported version: `2.4`
- Package type: `No administrada`
- Duration: `161.8s`
- Start: `05/12/2026 03:33:44.077 UTC`
- Stop: `05/12/2026 03:36:25.834 UTC`

New/updated flow activation rows were processed for:

- `PMO_PA_CriarProjeto`
- `PMO_PA_CriarTarefa`
- `PMO_PA_Gerar_Multiplos_Projetos`

The workflow rows with code `0x80045042` are processed replacement notices (`The original workflow definition has been deactivated and replaced.`), not blocking import failures.

Runtime validation is still required after manual publish/availability refresh before any ship-ready claim.
