# Session 20 Import Analysis and V2 Patch

Date: 2026-05-10

## Inputs

- Imported solution report: `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import.xml`
- V2 imported solution report: `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (2).xml`
- Post-import export: `Solution/PMO_v11_Tarefas_POST_IMPORT_20260510_2053.zip`
- V2 patch package: `Solution/PMO_v11_Tarefas_1_1_0_2_SESSION20_PATCHED_V2.zip`
- V2 patch SHA256: `7C2F211978991B118D1DECAFAA9E602A910DC90E7E34C35D31A4BDDB980FABD9`
- V2 patch staging folder: `.planning/comms/solution_patch_PMO_v11_Tarefas_1_1_0_2_session20_v2_20260510_2125`
- V2 ZIP verification folder: `.planning/comms/solution_patch_v2_zip_verify_20260510_2145`
- Backup folder: `.planning/backups/session20_v2_20260510_2120`
- Source snapshot after V2 patch: `.planning/backups/session20_v2_20260510_2120/source_after_v2_patch_snapshot`

## Official Documentation Basis

- Copilot Studio code editor supports YAML topic editing and warns that syntax/punctuation errors can break conversation behavior:
  https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/topics-code-editor
- Power Fx `IsMatch`, `Match`, `MatchAll`, and `MatchOptions.IgnoreCase` are documented here:
  https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-ismatch
- Power Fx regular expression behavior and options are documented here:
  https://learn.microsoft.com/en-us/power-platform/power-fx/regular-expressions

## Import XML Analysis

Status from first import XML:

- Solution status: `Procesado`
- Version: `1.1.0.2`
- Start: `2026-05-10 11:44:48.532 UTC`
- Stop: `2026-05-10 11:47:57.917 UTC`
- Duration: `189.4s`
- Parsed CSV evidence: `.planning/comms/session20_import_components_parsed_20260510_2050.csv`

Findings:

- No Session 20 target component failed import in the XML.
- Rows with `0x80045042` were `Procesado` and stated that the original workflow definition was deactivated and replaced. This is an import replacement notice, not an import failure.
- Blank `Sin procesar` rows in the workbook have no component id, component name, or error text and were treated as trailing workbook rows, not component failures.
- Target flows processed and activated:
  - `PMO_PA_ConsultarPortfolio`
  - `PMO_PA_ConsultarProjeto`
  - `PMO_PA_RegistrarRiscoBot`
  - `PMO_PA_RegistrarBloqueioBot`
  - `PMO_PA_PedirDecisaoBot`
  - `PMO_PA_AtualizarStatus`

## V2 Import XML Analysis

Status from V2 import XML:

- Solution status: `Procesado`
- Version: `1.1.0.2`
- Package type: `No administrada`
- Duration: `180.5s`
- Start: `2026-05-11 01:08:10.713 UTC`
- Stop: `2026-05-11 01:11:11.165 UTC`
- Parsed CSV evidence: `.planning/comms/session20_import_components_parsed_20260510_2217.csv`

Findings:

- No component row failed import in the V2 XML.
- `52` component rows are `Procesado`.
- `9` `Sin procesar` rows are blank/trailing rows with no component id, component name, error code, or error text.
- `13` workflow rows contain `0x80045042` with status `Procesado` and the text `The original workflow definition has been deactivated and replaced.` This matches the Power Platform UI banner after import and is treated as an informational replacement warning, not a failed import.
- The six Session 20 target flows were processed and activated:
  - `PMO_PA_ConsultarPortfolio`: rows 26, 27, activation row 49
  - `PMO_PA_ConsultarProjeto`: rows 28, 29, activation row 50
  - `PMO_PA_RegistrarRiscoBot`: rows 30, 31, activation row 51
  - `PMO_PA_RegistrarBloqueioBot`: rows 32, 33, activation row 52
  - `PMO_PA_PedirDecisaoBot`: rows 34, 35, activation row 53
  - `PMO_PA_AtualizarStatus`: rows 36, 37, activation row 54

Evidence limitation:

- The XML import report does not record the ZIP filename or SHA256. Package-to-import linkage is therefore based on solution unique name `PMO_v11_Tarefas`, version `1.1.0.2`, package type `No administrada`, local ZIP timestamp/hash, and the matching workflow IDs/names in the import log.

## Post-Import Contract Issue

The post-import export proved a runtime contract mismatch:

- Target flow trigger schemas use named inputs such as `projectName`, `descricao`, `impacto`, `nomeProjeto`, `rag`, and `resumo`.
- The first patch had several topic `InvokeFlowAction` bindings using generic keys such as `text`, `text_1`, `text_2`, and `number`.
- The validated `CriarTarefa` topic uses generic keys only because its flow schema also uses generic keys. That pattern did not apply to the Session 20 flows.

This was a NO-SHIP issue until corrected.

## V2 Patch Changes

Topic binding fixes:

- `RegistrarRisco`: `projectName`, `descricao`, `severidade`, `impacto`
- `RegistrarBloqueio`: `projectName`, `descricao`, `impacto`
- `PedirDecisao`: `projectName`, `descricao`, `impacto`, `prazo`, `aprovador`
- `ConsultarProjeto`: `nomeProjeto`
- `AtualizarStatus`: `nomeProjeto`, `rag`, `resumo`, `percentual`, `risco`, `bloqueio`, `proximaAcao`
- `ConsultarPortfolio`: flow id aligned with imported workflow id
- `LowConfidence`: added `RegistrarBloqueio` redirect using the same documented `OnUnknownIntent` and `BeginDialog` pattern already used by the fallback.
- `AtualizarTarefa` V2: replaced `BooleanPrebuiltEntity` confirmation with `StringPrebuiltEntity` plus the same `sim/s/yes/y/confirmo/ok` condition pattern.
- `AtualizarStatus` workflow: `Update_Projeto` now sends `Deleted=false` on the `PatchItem`, preserving the logical delete contract for SharePoint writes.
- `LowConfidence`: added conservative cold-start redirects for `AtualizarTarefa`, `ConsultarProjeto`, and `ListarTarefas`. Ambiguous phrase `status do projeto` remains routed to `AtualizarStatus`.

Flow fixes:

- Added `message` response schema to the six Session 20 flows, matching the validated `CriarTarefa` response shape.
- Added optional `impacto` trigger property to `RegistrarRisco` and mapped it to SharePoint `Impacto/Value`.

Source files updated:

- `deploy/copilot/RegistrarRisco_topic.yaml`
- `deploy/copilot/RegistrarBloqueio_topic.yaml`
- `deploy/copilot/PedirDecisao_topic.yaml`
- `deploy/copilot/ConsultarProjeto_topic.yaml`
- `deploy/copilot/ConsultarPortfolio_topic.yaml`
- `deploy/copilot/AtualizarStatus_topic.yaml`
- `deploy/copilot/Fallback_SmartRedirect.yaml`
- `deploy/PMO_FlowScript.Common.ps1`
- `deploy/PA_BotTopicFlows.Factory.ps1`

Rollback notes:

- Package rollback: use `.planning/backups/session20_v2_20260510_2120/PMO_v11_Tarefas_1_1_0_2_SESSION20_PATCHED.zip` for the previous Session 20 package.
- Source snapshot for the current V2 source state: `.planning/backups/session20_v2_20260510_2120/source_after_v2_patch_snapshot`.
- Cleanup of orphan/legacy flows is intentionally out of scope for this patch and should be performed only after the V2 import and runtime smoke tests pass.

## Validation Evidence

Command:

```powershell
Static contract validation over .planning\comms\solution_patch_PMO_v11_Tarefas_1_1_0_2_session20_v2_20260510_2125
```

Result:

```text
PASS: final ZIP contract validation green.
ZIP: Solution\PMO_v11_Tarefas_1_1_0_2_SESSION20_PATCHED_V2.zip
SHA256: 7C2F211978991B118D1DECAFAA9E602A910DC90E7E34C35D31A4BDDB980FABD9
```

Checks covered:

- JSON parse for target workflow definitions.
- Topic input bindings match target flow trigger schemas.
- No remaining generic `text`, `text_1`, `text_2`, or `number` bindings in Session 20 target topics.
- No `BooleanPrebuiltEntity` in `pmo_AssistentePMO_V2.topic.*` data.
- No `[- ]` regex character class.
- No `shared_http`, `shared_webcontents`, or `shared_graph` connector references.
- No `result` response output in target package.
- `message` response schema present for the six target flows.
- The final ZIP was extracted into `.planning/comms/solution_patch_v2_zip_verify_20260510_2145`; validation was run against that extracted ZIP content, not only against the staging folder.
- `AtualizarStatus` `PatchItem` includes `item/Deleted=false`.
- Fallback includes routes for `RegistrarBloqueio`, `AtualizarTarefa`, `ConsultarProjeto`, and `ListarTarefas`.

Residual scope note:

- The package still contains legacy `pmo_AssistentePMO_Clean.topic.*` components with `BooleanPrebuiltEntity` and older workflows with `result` outputs. Those components were not changed in V2 because the active Session 20 scope is `pmo_AssistentePMO_V2`. If the `Clean` schema is still active anywhere, it needs a separate low-blast-radius cleanup package.
- `solution.xml` still declares pre-existing missing dependencies for `cat_*` connection references from legacy components. This package is intended for the same environment where the prior import already succeeded and those dependencies were resolvable. Do not treat this ZIP as autonomous for a clean environment until those legacy dependencies are cleaned up or supplied.

## Release Decision

Current decision: NO-SHIP until Topic Checker is green, the bot is published, and runtime smoke tests pass in Copilot Studio.

CI gate is waived by user instruction. Runtime Copilot/Power Automate execution is not waived.

Required runtime smoke tests after importing V2:

- `criar tarefa: titulo=Teste Smoke, responsavel=Manoel Benicio, prazo=2026/05/31, horas=1, prioridade=Alta`
- `registrar risco: projeto=<nome>, descricao=Teste risco, severidade=Alta, impacto=Alto`
- `registrar bloqueio: projeto=<nome>, descricao=Teste bloqueio, impacto=Alto`
- `solicitar decisao: projeto=<nome>, descricao=Teste decisao, impacto=Alto, prazo=31/05/2026, aprovador=<upn>`
- `consultar projeto: projeto=<nome>`
- `consultar portfolio`
- `atualizar status: projeto=<nome>, status=Verde, resumo=Teste status, percentual=10`

## 2026-05-11 V2 Runtime Evidence and 1.8 Parser Fix

Active target:

- `Assistente PMO V2`
- Do not use `Assistente PMO Clean` as the release target.

Runtime evidence captured before the 1.8 fix:

- `CriarTarefa`: PASS. Created `Projetos` item `Teste Smoke Final V5` with `Prioridade=Alta`, `Ativo=True`, `Deleted=False`.
- `ConsultarProjeto`: PASS. Returned real SharePoint data for `Teste Smoke Final V5`.
- `ConsultarPortfolio`: PASS. Returned real SharePoint aggregate counts.
- `AtualizarStatus`: WRITE SUCCEEDED, but parser defect found. The command used `status=Amarelo`, but confirmation showed `RAG: projeto=Teste Smoke Final V5`.

Root cause:

- `AtualizarStatus` used `status\s*[:=]`, which matched the command prefix `atualizar status:` and captured `projeto=...`.

Prepared fix:

- Package: `Solution/PMO_v11_Tarefas_1_8_ATUALIZAR_STATUS_RAG_FIX.zip`
- SHA256: `58276EF084576971035D83B74CF243570FAAD0BD6B036E4DB7ACEF6EDBB17CAF`
- Version: `1.8`
- Staging folder: `.planning/comms/solution_1_8_atualizar_status_rag_fix_20260511/unpacked`
- Verification folder: `.planning/comms/solution_1_8_atualizar_status_rag_fix_20260511/verify_unpacked`

1.8 `parse_rag` expression:

```yaml
value: =If(IsMatch(Topic.RawInput, "rag\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "rag\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.RawInput, "status\s*=\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "status\s*=\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank()))
```

Validation:

- Package unpack verification confirms version `1.8`.
- Package unpack verification confirms the new `parse_rag` expression.
- Search found no `BooleanPrebuiltEntity`, old Clean bot references, or deleted duplicate flow IDs in the checked package scope.

Next required runtime test after importing 1.8:

```text
atualizar status: projeto=Teste Smoke Final V5, rag=Amarelo, resumo=Smoke test de atualizacao de status fix RAG, percentual=35, risco=Nenhum, bloqueio=Nenhum, proxima acao=Validar RAG
```

Expected:

- Confirmation shows `RAG: Amarelo`.
- `Status Diario` latest item has `RAG=Amarelo`, `Percentual=35`, `Deleted=false`.
- `Projetos` item `Teste Smoke Final V5` has `StatusRAG=Amarelo`, `Percentual=35`.

## 2026-05-10 Clean Runtime Follow-Up

CriarTarefa status:

- Runtime test `Teste Smoke Session20C` created a SharePoint `Projetos` item with `Prioridade=Alta`.
- The earlier priority defect was traced to `PMO_PA_CriarTarefa_V3` hard-coding `item/Prioridade/Value` as `Media`.
- The flow package was patched to use `@outputs('Map_Prioridade')`.
- Static validator `tests/Test-CriarTarefaFlowDefinition.ps1` passes against the post-import exported workflow package with `failedCheckCount=0`.

Premium/preview feature audit:

- The cleaned package `.planning/comms/remove_premium_features_20260510_233000/PMO_v11_Tarefas_REMOVE_PREMIUM_FEATURES.zip` was packed and imported successfully.
- Import log: `.planning/comms/remove_premium_features_20260510_233000/import_remove_premium_features.log`.
- Local cleaned package has no matches for `WorkIQ`, `shared_a365`, `mcp_`, `GPT5Chat`, `Premium`, or `premium`.
- Post-import export still reintroduced existing unmanaged WorkIQ rows from Dataverse, which proves that omitting unmanaged components from a solution ZIP does not delete components already present in the environment.

Dataverse rows still present after clean ZIP import:

| Type | Schema / logical name | ID |
|---|---|---|
| botcomponent | `pmo_AssistentePMO_Clean.topic.WorkIQCopilotPreview` | `23b9e2c9-c27b-4b36-abb2-66ca3b4b141c` |
| botcomponent | `pmo_AssistentePMO_Clean.topic.WorkIQUserPreview` | `4056148e-1c3b-4e1d-9b2f-f45175857eee` |
| botcomponent | `pmo_AssistentePMO_V2.action.WorkIQCopilotPreview` | `b699c70a-8aa4-4441-b659-059efe08bcd0` |
| botcomponent | `pmo_AssistentePMO_V2.action.WorkIQUserPreview` | `9280311c-9590-49cc-9e2c-46c84a037fe6` |
| connectionreference | `pmo_AssistentePMO_V2.connectionreference.pmo_AssistentePMO_Clean.shared_a365copilotchatmcp.shareda36` | `69818553-a667-4c16-b7ec-4698fe2af1c5` |
| connectionreference | `pmo_AssistentePMO_V2.connectionreference.pmo_AssistentePMO_Clean.shared_a365memcp.shareda365memcped1` | `79a8e76b-7707-4cd4-948c-c82560e8d882` |
| connectionreference | `pmo_AssistentePMO_Clean.shared_a365copilotchatmcp.shared-a365copilotch-d537869b-626c-44ad-9a71-72d0c94e57fd` | `fbb77fdb-2d5c-45cd-a908-b6f93c758bd8` |
| connectionreference | `pmo_AssistentePMO_Clean.shared_a365memcp.shared-a365memcp-ed1136ed-9b76-4d64-b7fa-16bab035d714` | `3e8967dc-209f-4b06-8a45-64afa0b85f66` |

Relationship rows still present:

| botcomponent_connectionreferenceid | botcomponentid | connectionreferenceid |
|---|---|---|
| `7ca27f6c-154a-f111-bec7-000d3abc5cc6` | `b699c70a-8aa4-4441-b659-059efe08bcd0` | `69818553-a667-4c16-b7ec-4698fe2af1c5` |
| `54aecf01-3449-f111-bec7-7ced8d955c6c` | `4056148e-1c3b-4e1d-9b2f-f45175857eee` | `3e8967dc-209f-4b06-8a45-64afa0b85f66` |
| `52068b72-154a-f111-bec7-000d3abc5cc6` | `9280311c-9590-49cc-9e2c-46c84a037fe6` | `79a8e76b-7707-4cd4-948c-c82560e8d882` |
| `52aecf01-3449-f111-bec7-7ced8d955c6c` | `23b9e2c9-c27b-4b36-abb2-66ca3b4b141c` | `fbb77fdb-2d5c-45cd-a908-b6f93c758bd8` |

Current blocker:

- `pac copilot publish` failed for `Assistente PMO Clean` after the flow/topic fixes.
- The likely blocker is the same premium warning shown by Copilot Studio: WorkIQ/MCP and `GPT5Chat` were present before the clean package import.
- The clean package fixed `GPT5Chat` to `GPT41`, but unmanaged WorkIQ/MCP rows still require explicit deletion/removal from Dataverse or UI.
- Dataverse delete attempts through the available MCP/PowerShell paths timed out; no row was deleted.

Next safe action:

1. Delete/remove the four WorkIQ botcomponents listed above from the environment or solution UI.
2. Delete/remove the four A365/MCP connection references listed above.
3. Export `PMO_v11_Tarefas` again.
4. Verify no matches for `WorkIQ`, `shared_a365`, `mcp_`, or `GPT5Chat`.
5. Publish `Assistente PMO Clean`.
6. Re-test `registrar risco`, `consultar projeto`, and the remaining write/read flows.
