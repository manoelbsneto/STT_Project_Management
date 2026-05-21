# AQ-08-PRE Topic Routing Verification

Date: 2026-05-20  
Executor: CODEX-PA  
Environment: ColOfertasBrasilPro  
Bot: Assistente PMO V2  
Mode: Read-only PAC discovery plus source/data inspection  
Decision: CONDITIONAL BLOCK for AQ-08-PUBLISH after Opus 4.7 scope reinterpretation

## Evidence

| Artifact | Path |
|---|---|
| PAC environment confirmation | `.planning/comms/aq08_topic_routing_verification_20260520/pac_env_who.txt` |
| Live topic inventory with inline YAML/data | `.planning/comms/aq08_topic_routing_verification_20260520/botcomponent_topics_inventory.txt` |
| Live botcomponent_workflow inventory | `.planning/comms/aq08_topic_routing_verification_20260520/botcomponent_workflow_inventory.txt` |
| Live PMO_PA_/PM0_PA_ workflow inventory | `.planning/comms/aq08_topic_routing_verification_20260520/workflow_inventory.txt` |
| FetchXML: topics | `.planning/comms/aq08_topic_routing_verification_20260520/fetch_botcomponent_topics_inventory.xml` |
| FetchXML: botcomponent_workflow | `.planning/comms/aq08_topic_routing_verification_20260520/fetch_botcomponent_workflow_inventory.xml` |
| FetchXML: workflows | `.planning/comms/aq08_topic_routing_verification_20260520/fetch_workflow_inventory.xml` |

## Scope Update From Opus 4.7

After review, Opus 4.7 reinterpreted the AQ-08 release scope:

- In-scope P0 card-first migration covers only five topics: `AtualizarStatus`, `AtualizarTarefa`, `ConsultarPortfolio`, `CriarTarefa`, and `ListarTarefas`.
- Seven legacy topics remain intentionally out-of-scope for this release and are tracked as accepted debt: `ConsultarProjeto`, `CriarProjeto`, `ExcluirProjeto`, `ExcluirTarefa`, `PedirDecisao`, `RegistrarBloqueio`, and `RegistrarRisco`.

Under this scope, AQ-08-PUBLISH remains blocked only until the five in-scope P0 topics are manually remediated and re-verified read-only.

## Finding

AQ-08-PUBLISH is conditionally blocked. The live Dataverse inventory confirms the new `PM0_PA_*` action components and workflows exist and are active, but the five in-scope P0 topics still reference legacy `PMO_PA_*` action components or direct legacy `PMO_PA_*` workflow IDs.

## Diff Matrix

| Topic Name | Action Component Referenced | Workflow Bound | Status |
|---|---|---|---|
| AtualizarStatus | Direct `InvokeFlowAction` via `flowId: c11a165b-c64c-f111-bec7-7ced8d9559c1` | `PMO_PA_AtualizarStatus` | STALE |
| AtualizarTarefa | `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` | `PMO_PA_AtualizarTarefa` / `98408d55-3748-f111-bec7-000d3abc5cc6` | STALE |
| ConsultarPortfolio | Direct `InvokeFlowAction` via `flowId: 39cf292d-c64c-f111-bec7-7ced8d955c6c` | `PMO_PA_ConsultarPortfolio` | STALE |
| ConsultarProjeto | Direct `InvokeFlowAction` via `flowId: 4a33b53e-c64c-f111-bec7-000d3abc5cc6` | `PMO_PA_ConsultarProjeto` | STALE |
| CriarProjeto | `pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto` | `PMO_PA_CriarProjeto` / `3104124d-364a-f111-bec7-7ced8d955c6c` | STALE |
| CriarTarefa | `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` | `PMO_PA_CriarTarefa` / `0a5d2a41-24c0-4d5e-9f6d-000000000241` | STALE |
| ExcluirProjeto | Direct `InvokeFlowAction` via `flowId: 16fbe313-2edc-406e-ad7f-d08cee0edc43` | `PMO_PA_ExcluirProjeto` | STALE |
| ExcluirTarefa | Direct `InvokeFlowAction` via `flowId: 70b39334-5926-4fb1-bd22-f10bd99f0f6d` | `PMO_PA_ExcluirTarefa` | STALE |
| Gerar_Multiplos_Projetos | None; preview-only topic with no flow/action call | None | PASS |
| Greeting | None | None | PASS |
| ListarTarefas | `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` | `PMO_PA_ListarTarefas` / `9544f14b-3748-f111-bec7-6045bdf42cae` | STALE |
| LowConfidence | Routes to other topics only | Indirectly routes to stale topics listed above | STALE |
| PedirDecisao | Direct `InvokeFlowAction` via `flowId: feb79d54-c64c-f111-bec7-7ced8d955c6c` | `PMO_PA_PedirDecisaoBot` | STALE |
| RegistrarBloqueio | Direct `InvokeFlowAction` via `flowId: 3ec37952-c64c-f111-bec7-000d3abc5cc6` | `PMO_PA_RegistrarBloqueioBot` | STALE |
| RegistrarRisco | Direct `InvokeFlowAction` via `flowId: ee732d46-c64c-f111-bec7-7ced8d955c6c` | `PMO_PA_RegistrarRiscoBot` | STALE |
| SeHouverErro | None; error handler only | None | PASS |

## New PM0 Bindings Present But Not Routed By Topics

The live `botcomponent_workflow` inventory shows these active new action components:

| Action Component | Workflow |
|---|---|
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `PM0_PA_Card_ResumoExecutivoPortfolio` / `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `PM0_PA_Card_AtualizarStatus` / `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `PM0_PA_Card_ListarTarefas` / `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `PM0_PA_Card_CriarTarefa` / `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `PM0_PA_Card_AtualizarTarefa` / `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| `pmo_AssistentePMO_V2.action.PM0_PA_OpsFailureHandling` | `PM0_PA_OpsFailureHandling` / `9531fbc7-a250-f111-bec7-000d3abc5cc6` |

These rows prove AQ-07 activation/binding exists. They do not prove topic routing, because the topic YAML still calls legacy `PMO_PA_*` components or direct legacy workflow IDs.

## Required Manual Remediation

Owner must manually rebind the Copilot Studio topics in the UI before AQ-08-PUBLISH:

| Topic | Manual UI Change |
|---|---|
| AtualizarStatus | Replace the direct legacy `PMO_PA_AtualizarStatus` action call with `PM0_PA_Card_AtualizarStatus`. Map the existing topic inputs to the PM0 action input contract and map the returned `result`/message per AQ-07 contract. |
| AtualizarTarefa | Replace `BeginDialog dialog: pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` with `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa`. |
| ConsultarPortfolio | Replace the direct legacy `PMO_PA_ConsultarPortfolio` action call with `PM0_PA_Card_ResumoExecutivoPortfolio` if this is the intended executive portfolio route. |
| ConsultarProjeto | No `PM0_PA_Card_ConsultarProjeto` action exists in the AQ-07 evidence. Owner/Opus must either accept the legacy route as out of AQ-08 scope or create/bind a PM0 replacement before publish. |
| CriarProjeto | No `PM0_PA_Card_CriarProjeto` action exists in the AQ-07 evidence. Owner/Opus must either accept the legacy route as out of AQ-08 scope or create/bind a PM0 replacement before publish. |
| CriarTarefa | Replace `BeginDialog dialog: pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` with `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa`. |
| ExcluirProjeto | No `PM0_PA_Card_ExcluirProjeto` action exists in the AQ-07 evidence. Owner/Opus must either accept the legacy route as out of AQ-08 scope or create/bind a PM0 replacement before publish. |
| ExcluirTarefa | No `PM0_PA_Card_ExcluirTarefa` action exists in the AQ-07 evidence. Owner/Opus must either accept the legacy route as out of AQ-08 scope or create/bind a PM0 replacement before publish. |
| ListarTarefas | Replace `BeginDialog dialog: pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` with `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas`. |
| PedirDecisao | No `PM0_PA_Card_PedirDecisao` action exists in the AQ-07 evidence. Owner/Opus must either accept the legacy route as out of AQ-08 scope or create/bind a PM0 replacement before publish. |
| RegistrarBloqueio | No `PM0_PA_Card_RegistrarBloqueio` action exists in the AQ-07 evidence. Owner/Opus must either accept the legacy route as out of AQ-08 scope or create/bind a PM0 replacement before publish. |
| RegistrarRisco | No `PM0_PA_Card_RegistrarRisco` action exists in the AQ-07 evidence. Owner/Opus must either accept the legacy route as out of AQ-08 scope or create/bind a PM0 replacement before publish. |
| LowConfidence | After the direct topics are remediated, re-test LowConfidence routing because it delegates to the stale topics. |

## AQ-08-PUBLISH Gate Decision

CONDITIONAL BLOCK.

Do not publish `Assistente PMO V2` for AQ-08 while the five in-scope P0 topics still route to `PMO_PA_*` legacy actions/workflows. Publishing now would not prove the AQ-07 `PM0_PA_*` runtime path for the P0 card-first migration.

The seven out-of-scope legacy topics are now documented as accepted debt in `.planning/comms/CODEX_P0_CLOSEOUT_HANDOFF_20260520.md`.
