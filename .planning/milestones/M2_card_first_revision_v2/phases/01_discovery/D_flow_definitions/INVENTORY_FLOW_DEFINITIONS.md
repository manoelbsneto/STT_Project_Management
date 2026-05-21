# Inventory - Power Automate Flow Definitions

**Agent:** CODEX-2-LEAD
**Generated:** 2026-05-20T20:10:30-03:00
**Scope:** Track D, 18 Power Automate flows (12 legacy PMO_PA_* + 6 PM0_PA_*)
**Tenant:** ColOfertasBrasilPro (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)

## Summary

- Flow definition files: 18/18
- Trigger schema files: 18/18
- Output schema files: 18/18
- Per-flow run history files: 18/18
- Aggregate run history: `flow_run_history_30d.json`
- PM0 refactor analysis: `PM0_REFACTOR_ANALYSIS.md`

## Master Matrix

| # | Flow | Workflow ID | Type | State | Modified | Trigger | Required inputs | Actions | Connections | Responses | Runs 30d | OK | Fail |
|---|---|---|---|---|---|---|---|---:|---|---|---:|---:|---:|
| D.1 | `PMO_PA_AtualizarStatus` | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | legacy | Activado | 14/05/2026 15:04 | manual / Request / Skills | nomeProjeto, rag, resumo | 6 | shared_sharepointonline | Response_OK, Response_Error_Create, Response_Error_Update, Response_Project_Not_Found | 27 | 4 | 23 |
| D.2 | `PMO_PA_AtualizarTarefa` | `98408d55-3748-f111-bec7-000d3abc5cc6` | legacy | Activado | 14/05/2026 15:03 | manual / Request / Skills | number | 12 | shared_sharepointonline | Response_Project_Not_Found, Respond_Success | 33 | 23 | 10 |
| D.3 | `PMO_PA_ConsultarPortfolio` | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | legacy | Activado | 14/05/2026 15:03 | manual / Request / Skills | - | 10 | shared_sharepointonline | Response_OK | 13 | 13 | 0 |
| D.4 | `PMO_PA_ConsultarProjeto` | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | legacy | Activado | 14/05/2026 15:03 | manual / Request / Skills | nomeProjeto | 3 | shared_sharepointonline | Response_OK, Response_Project_Not_Found | 13 | 13 | 0 |
| D.5 | `PMO_PA_CriarProjeto` | `3104124d-364a-f111-bec7-7ced8d955c6c` | legacy | Activado | 14/05/2026 15:04 | manual / Request / Skills | text_2, text_1, text_4, text, text_3, number | 8 | shared_sharepointonline | Valores_retornados_para_o_Power_Virtual_Agents | 44 | 38 | 6 |
| D.6 | `PMO_PA_CriarTarefa` | `0a5d2a41-24c0-4d5e-9f6d-000000000241` | legacy | Activado | 14/05/2026 15:04 | manual / Request / Skills | text_2, text_1, text_4, text, text_3, number | 9 | shared_sharepointonline | Valores_retornados_para_o_Power_Virtual_Agents | 12 | 12 | 0 |
| D.7 | `PMO_PA_ExcluirProjeto` | `16fbe313-2edc-406e-ad7f-d08cee0edc43` | legacy | Activado | 14/05/2026 15:04 | manual | text, text_1 | 5 | shared_sharepointonline | - | 1 | 1 | 0 |
| D.8 | `PMO_PA_ExcluirTarefa` | `70b39334-5926-4fb1-bd22-f10bd99f0f6d` | legacy | Activado | 14/05/2026 15:04 | manual | number, text, text_2 | 5 | shared_sharepointonline | - | 11 | 10 | 1 |
| D.9 | `PMO_PA_ListarTarefas` | `9544f14b-3748-f111-bec7-6045bdf42cae` | legacy | Activado | 14/05/2026 15:03 | manual | - | 3 | shared_sharepointonline | - | 44 | 44 | 0 |
| D.10 | `PMO_PA_PedirDecisaoBot` | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | legacy | Activado | 14/05/2026 15:04 | manual | projectName, descricao, impacto, prazo, aprovador | 7 | shared_sharepointonline | - | 4 | 3 | 1 |
| D.11 | `PMO_PA_RegistrarBloqueioBot` | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | legacy | Activado | 14/05/2026 15:03 | manual | projectName, descricao, impacto | 6 | shared_sharepointonline | - | 2 | 2 | 0 |
| D.12 | `PMO_PA_RegistrarRiscoBot` | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | legacy | Activado | 14/05/2026 15:03 | manual | projectName, descricao, severidade | 5 | shared_sharepointonline | - | 2 | 2 | 0 |
| D.13 | `PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` | new | Activado | 15/05/2026 19:10 | object | - | 0 | - | - | 0 | 0 | 0 |
| D.14 | `PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` | new | Activado | 15/05/2026 19:10 | object | - | 0 | - | - | 0 | 0 | 0 |
| D.15 | `PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` | new | Activado | 15/05/2026 19:10 | object | - | 0 | - | - | 0 | 0 | 0 |
| D.16 | `PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` | new | Activado | 15/05/2026 19:10 | object | - | 0 | - | - | 0 | 0 | 0 |
| D.17 | `PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` | new | Activado | 15/05/2026 22:31 | object | - | 0 | - | - | 2 | 2 | 0 |
| D.18 | `PM0_PA_OpsFailureHandling` | `9531fbc7-a250-f111-bec7-000d3abc5cc6` | new | Activado | 15/05/2026 19:10 | object | - | 0 | - | - | 0 | 0 | 0 |

## Deliverable Files

| # | Definition | Trigger schema | Output schema | Run history |
|---|---|---|---|---|
| D.1 | `definition_PMO_PA_AtualizarStatus.json` | `triggerSchema_PMO_PA_AtualizarStatus.json` | `outputSchema_PMO_PA_AtualizarStatus.json` | `flow_run_history_30d_PMO_PA_AtualizarStatus.json` |
| D.2 | `definition_PMO_PA_AtualizarTarefa.json` | `triggerSchema_PMO_PA_AtualizarTarefa.json` | `outputSchema_PMO_PA_AtualizarTarefa.json` | `flow_run_history_30d_PMO_PA_AtualizarTarefa.json` |
| D.3 | `definition_PMO_PA_ConsultarPortfolio.json` | `triggerSchema_PMO_PA_ConsultarPortfolio.json` | `outputSchema_PMO_PA_ConsultarPortfolio.json` | `flow_run_history_30d_PMO_PA_ConsultarPortfolio.json` |
| D.4 | `definition_PMO_PA_ConsultarProjeto.json` | `triggerSchema_PMO_PA_ConsultarProjeto.json` | `outputSchema_PMO_PA_ConsultarProjeto.json` | `flow_run_history_30d_PMO_PA_ConsultarProjeto.json` |
| D.5 | `definition_PMO_PA_CriarProjeto.json` | `triggerSchema_PMO_PA_CriarProjeto.json` | `outputSchema_PMO_PA_CriarProjeto.json` | `flow_run_history_30d_PMO_PA_CriarProjeto.json` |
| D.6 | `definition_PMO_PA_CriarTarefa.json` | `triggerSchema_PMO_PA_CriarTarefa.json` | `outputSchema_PMO_PA_CriarTarefa.json` | `flow_run_history_30d_PMO_PA_CriarTarefa.json` |
| D.7 | `definition_PMO_PA_ExcluirProjeto.json` | `triggerSchema_PMO_PA_ExcluirProjeto.json` | `outputSchema_PMO_PA_ExcluirProjeto.json` | `flow_run_history_30d_PMO_PA_ExcluirProjeto.json` |
| D.8 | `definition_PMO_PA_ExcluirTarefa.json` | `triggerSchema_PMO_PA_ExcluirTarefa.json` | `outputSchema_PMO_PA_ExcluirTarefa.json` | `flow_run_history_30d_PMO_PA_ExcluirTarefa.json` |
| D.9 | `definition_PMO_PA_ListarTarefas.json` | `triggerSchema_PMO_PA_ListarTarefas.json` | `outputSchema_PMO_PA_ListarTarefas.json` | `flow_run_history_30d_PMO_PA_ListarTarefas.json` |
| D.10 | `definition_PMO_PA_PedirDecisaoBot.json` | `triggerSchema_PMO_PA_PedirDecisaoBot.json` | `outputSchema_PMO_PA_PedirDecisaoBot.json` | `flow_run_history_30d_PMO_PA_PedirDecisaoBot.json` |
| D.11 | `definition_PMO_PA_RegistrarBloqueioBot.json` | `triggerSchema_PMO_PA_RegistrarBloqueioBot.json` | `outputSchema_PMO_PA_RegistrarBloqueioBot.json` | `flow_run_history_30d_PMO_PA_RegistrarBloqueioBot.json` |
| D.12 | `definition_PMO_PA_RegistrarRiscoBot.json` | `triggerSchema_PMO_PA_RegistrarRiscoBot.json` | `outputSchema_PMO_PA_RegistrarRiscoBot.json` | `flow_run_history_30d_PMO_PA_RegistrarRiscoBot.json` |
| D.13 | `definition_PM0_PA_Card_AtualizarStatus.json` | `triggerSchema_PM0_PA_Card_AtualizarStatus.json` | `outputSchema_PM0_PA_Card_AtualizarStatus.json` | `flow_run_history_30d_PM0_PA_Card_AtualizarStatus.json` |
| D.14 | `definition_PM0_PA_Card_AtualizarTarefa.json` | `triggerSchema_PM0_PA_Card_AtualizarTarefa.json` | `outputSchema_PM0_PA_Card_AtualizarTarefa.json` | `flow_run_history_30d_PM0_PA_Card_AtualizarTarefa.json` |
| D.15 | `definition_PM0_PA_Card_CriarTarefa.json` | `triggerSchema_PM0_PA_Card_CriarTarefa.json` | `outputSchema_PM0_PA_Card_CriarTarefa.json` | `flow_run_history_30d_PM0_PA_Card_CriarTarefa.json` |
| D.16 | `definition_PM0_PA_Card_ListarTarefas.json` | `triggerSchema_PM0_PA_Card_ListarTarefas.json` | `outputSchema_PM0_PA_Card_ListarTarefas.json` | `flow_run_history_30d_PM0_PA_Card_ListarTarefas.json` |
| D.17 | `definition_PM0_PA_Card_ResumoExecutivoPortfolio.json` | `triggerSchema_PM0_PA_Card_ResumoExecutivoPortfolio.json` | `outputSchema_PM0_PA_Card_ResumoExecutivoPortfolio.json` | `flow_run_history_30d_PM0_PA_Card_ResumoExecutivoPortfolio.json` |
| D.18 | `definition_PM0_PA_OpsFailureHandling.json` | `triggerSchema_PM0_PA_OpsFailureHandling.json` | `outputSchema_PM0_PA_OpsFailureHandling.json` | `flow_run_history_30d_PM0_PA_OpsFailureHandling.json` |

## Notes

- `pac org fetch --xml` raised `System.Xml.XmlException`; extraction used read-only `pac org fetch --xmlFile` instead.
- `workflow.outputparameters` is not available on the Dataverse `workflow` entity in this tenant; output schemas were extracted from Response actions inside `clientdata.properties.definition.actions`.
- Run histories were captured with `Get-FlowRun` using workflow GUIDs and summarized without signed content links.
- CODEX-2-SUB-C Track G is separate from Track D and is blocked on CODEX-1-SUB-B B.3; this does not block the flow definition inventory.
