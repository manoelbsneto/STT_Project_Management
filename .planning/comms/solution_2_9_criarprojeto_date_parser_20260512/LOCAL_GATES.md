# PMO v2.9 Local Gates - CriarProjeto Date/Parser Fix

Date: 2026-05-12
Operator: Codex local package preparation only
Import/publish status: NOT performed by Codex

## Decision

NO-SHIP until owner manually imports, publishes the bot if required by Copilot Studio, and completes runtime validation in Copilot Studio plus SharePoint read-only verification.

Local package gates are GREEN.

## Package

- Package: `Solution/PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip`
- SHA256: `5C3B9BD079B281C136AA1ECCE8C3E920A93AE3BE135D8E0F9968F7EBBFC9CED3`
- Unpacked source: `.planning/comms/solution_2_9_criarprojeto_date_parser_20260512/unpacked`
- Build script: `deploy/Build-Solution24LocalPackage.ps1`

## Scope Included

- `CriarProjeto` now parses inline and multiline project names before asking.
- `CriarProjeto` accepts inline `PM`, `Prazo`, and `Prioridade`.
- `CriarProjeto` rejects non-Brazilian dates such as `2026-06-30` with `INVALID_BR_DATE`.
- `CriarProjeto` requires `dd/MM/aaaa` user input and normalizes internally for SharePoint.
- `CriarProjeto` uses a bot action wrapper for `PMO_PA_CriarProjeto` instead of direct topic-to-cloud-flow invocation.
- Prior fixes remain included: `CriarTarefa` creates in `Tarefas`, uses BR date validation, publish-safe action binding, `ListarTarefas` accepts project name, `ExcluirTarefa` soft-deletes by active project/task ID, `Gerar_Multiplos_Projetos` stays preview/no-write.

## Local Gate Results

| Gate | Command | Result |
|---|---|---|
| CriarProjeto flow contract | `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarProjetoFlowDefinition.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip` | PASS, 0 failed |
| CriarProjeto parser | `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarProjetoTopicParser.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip` | PASS, 0 failed |
| CriarProjeto publish binding | `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarProjetoPublishBinding.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip` | PASS, 0 failed |
| Package contracts | `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-SolutionZipP24Contracts.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip` | PASS, 0 failed |
| Stop-ship static audit | `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .planning\comms\solution_2_9_criarprojeto_date_parser_20260512\unpacked` | PASS, 0 failed |
| CriarTarefa regression | `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarTarefaCreatesTarefas.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip` | PASS, 0 failed |
| CriarTarefa publish binding regression | `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarTarefaPublishBinding.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip` | PASS, 0 failed |
| Gerar_Multiplos_Projetos preview/no-write regression | `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-GerarMultiplosProjetosDefinition.ps1 -PackagePath Solution\PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip` | PASS, 0 failed |

## Evidence Notes

- `CriarProjeto` direct cloud-flow invocation was replaced by `pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto`.
- The package contains no workflow BOM, no Premium/Graph/HTTP connector markers, no physical SharePoint delete operation, and no invoker runtime source per local gates.
- No SharePoint schema or provisioning change is part of this package.
- `Gerar_Multiplos_Projetos` intentionally remains preview/no-write until Adaptive Card parser and batch writes pass a separate hardened gate.

## Official Reference Basis

- Power Automate and Azure Logic Apps expression functions reference: https://learn.microsoft.com/en-us/azure/logic-apps/expression-functions-reference
- Local project skill applied: `skills/super/SKILL_POWER_AUTOMATE_EXPRESSIONS.md`

## Required Runtime Validation After Manual Import

1. Import `Solution/PMO_v11_Tarefas_2_9_CRIARPROJETO_DATE_PARSER_FIX.zip`.
2. Publish the bot manually if Copilot Studio reports unpublished changes or topic/action changes are not reflected in Test.
3. Run Copilot Studio tests:
   - `criar projeto: NomeProjeto=Teste Data BR Projeto 2.9, PM=mbenicios@minsait.com, Prazo=30/06/2026, Prioridade=Alta`
   - `criar projeto: NomeProjeto=Teste Data ISO Deve Falhar 2.9, PM=mbenicios@minsait.com, Prazo=2026-06-30, Prioridade=Alta`
   - `criar projeto: Teste Parser Tail 2.9`
   - `listar projetos ativos`
   - `criar tarefa: projeto=Teste Data BR Projeto 2.9, titulo=Smoke task 2.9`
   - `listar tarefas do projeto Teste Data BR Projeto 2.9`
   - `excluir tarefa projeto Teste Data BR Projeto 2.9 tarefa <ID_RETORNADO> motivo teste controlado runtime 2.9`
4. Confirm via SharePoint read-only that created rows match expected project/task status and that deleted task is logical delete only.
