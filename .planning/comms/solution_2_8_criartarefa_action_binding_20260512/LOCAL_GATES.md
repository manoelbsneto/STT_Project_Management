# Solution 2.8 Local Gates - CriarTarefa Action Binding Fix

Date: 2026-05-12

Status: LOCAL PASS / PRODUCTION NO-SHIP

Package:
- `Solution/PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip`
- SHA256: `4B0F2B5597BA1DFD18479A1D213A8DFC1D5D8BEB5B9060F933751CD2B69E90BC`

## Scope

Fixes the Copilot Studio publish blocker reported for topic `CriarTarefa`:

`CloudFlow with id '0a5d2a41-24c0-4d5e-9f6d-000000000241' not found`

The fix is intentionally narrow:
- Added bot action component `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`.
- Changed topic `CriarTarefa` from direct `InvokeFlowAction` to action-component `BeginDialog`.
- Preserved the existing workflow `PMO_PA_CriarTarefa` and input contract: `text`, `text_1`, `text_2`, `text_3`, `number`, `text_4`.
- Preserved Brazilian date validation and `Tarefas` write contract from version 2.5.
- Preserved `Gerar_Multiplos_Projetos` preview/no-write mitigation from version 2.7.

No import, publish, deploy, or SharePoint write was executed by Codex.

## Gates

| Gate | Command | Result |
|---|---|---|
| Build package | `powershell -NoProfile -ExecutionPolicy Bypass -File .\deploy\Build-Solution24LocalPackage.ps1` | PASS |
| CriarTarefa publish binding | `powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarTarefaPublishBinding.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` | PASS |
| CriarTarefa Tarefas contract | `powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-CriarTarefaCreatesTarefas.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` | PASS |
| Batch preview/no-write | `powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-GerarMultiplosProjetosDefinition.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` | PASS |
| P24 ZIP/import contract | `powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP24Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` | PASS |
| P0 project/task contracts | `powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-SolutionZipP0Contracts.ps1 -PackagePath .\Solution\PMO_v11_Tarefas_2_8_CRIARTAREFA_ACTION_BINDING_FIX.zip` | PASS |
| Excluir soft-delete capability | `powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-ExcluirSoftDeleteCapability.ps1 -SolutionSourcePath .\.planning\comms\solution_2_8_criartarefa_action_binding_20260512\unpacked` | PASS |
| PMO stop-ship flow audit | `powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .\.planning\comms\solution_2_8_criartarefa_action_binding_20260512\unpacked` | PASS |

## Release Decision

NO-SHIP until the owner manually imports version 2.8, publishes the bot in Copilot Studio, and confirms the publish diagnostic for `CriarTarefa` is gone.

After owner import/publish, runtime smoke tests required:
1. `criar tarefa: projeto=Projeto Smoke Delete Parcial 2.3, titulo=Teste runtime 2.8 binding`
2. Respond one field per turn: `mbenicios@minsait.com`, `30/06/2026`, `1`, `baixa`, `sim`
3. `listar tarefas do projeto Projeto Smoke Delete Parcial 2.3`
4. `excluir tarefa projeto Projeto Smoke Delete Parcial 2.3 tarefa <ID_RETORNADO> motivo teste controlado runtime 2.8 binding`
5. Read-only SharePoint verification that the task row remains with `Deleted=True`.
