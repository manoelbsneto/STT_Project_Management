# PMO_v11_Tarefas_1_1_0_2_SESSION20_PATCHED

Date: 2026-05-10
Source ZIP: `Solution/PMO_v11_Tarefas_1_1_0_2.zip`
Patched ZIP: `Solution/PMO_v11_Tarefas_1_1_0_2_SESSION20_PATCHED.zip`

## Purpose

Importable solution package for Session 20 P0 gap closure.

## Changes

- Replaced V2 topic data for:
  - `pmo_AssistentePMO_V2.topic.RegistrarRisco`
  - `pmo_AssistentePMO_V2.topic.RegistrarBloqueio`
  - `pmo_AssistentePMO_V2.topic.PedirDecisao`
  - `pmo_AssistentePMO_V2.topic.ConsultarProjeto`
  - `pmo_AssistentePMO_V2.topic.ConsultarPortfolio`
  - `pmo_AssistentePMO_V2.topic.AtualizarStatus`
- Replaced V2 fallback topic:
  - `pmo_AssistentePMO_V2.topic.LowConfidence`
- Corrected system-topic trigger placement:
  - `pmo_AssistentePMO_V2.topic.Greeting` -> `OnConversationStart`
  - `pmo_AssistentePMO_V2.topic.SeHouverErro` -> `OnError`
- Updated six workflow JSON files to return `message` instead of `result`, matching `CriarTarefa` validated output binding pattern.
- Added topic-workflow links in `Assets/botcomponent_workflowset.xml` for the six Session 20 topics.

## Validation Evidence

- ZIP was re-extracted successfully to `.planning/comms/solution_patch_zip_verify_20260510_2039`.
- Required root files exist: `[Content_Types].xml`, `solution.xml`, `customizations.xml`.
- Six target workflows:
  - contain `"message":`
  - do not contain `"result":`
  - do not contain `shared_http`, `shared_webcontents`, or `shared_graph`
- Target topic data:
  - contains no `BooleanPrebuiltEntity`
  - contains no `REPLACE_WITH_ACTUAL_FLOW_ID`
  - contains no `template-content`
  - contains no non-ASCII operational text

## Hashes

- Original SHA256: `55918215DA139315AFA5115B4378CFFA6DC392A3270FF94D4A006A5097C029BF`
- Patched SHA256: `14B247AC62AB3AE2652AD15899E1B6A5092584C954EC485049459635CFD90497`

## Rollback

Import the original ZIP `Solution/PMO_v11_Tarefas_1_1_0_2.zip` if rollback is required.

## Import Gate

After manual import in Power Platform UI, run Copilot Studio Topic checker and smoke test:

- `consultar portfolio`
- `consultar projeto: projeto=<nome>`
- `registrar risco: projeto=<nome>, descricao=<texto>, severidade=Alta`
- `registrar bloqueio: projeto=<nome>, descricao=<texto>, impacto=Alto`
- `solicitar decisao: projeto=<nome>, descricao=<texto>, impacto=Alto`
- `atualizar status: projeto=<nome>, status=Verde, resumo=<texto>`
