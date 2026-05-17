# AQ-08 Read-Only Copilot Binding Discovery

Date: 2026-05-15
Status: BLOCKED_BY_BINDING_DISCOVERY
Tenant mutation: None

Owner approval for AQ-08 update/publish exists in the current thread, but this discovery step is read-only.

## Scope

- Confirm live Power Automate workflow rows for the six AQ-07 flows.
- Confirm live Copilot bot components/actions/topics for `pmo_AssistentePMO_V2`.
- Confirm current `botcomponent_workflow` action/topic-to-flow bindings.
- Do not import solutions, save flows, publish Copilot, write SharePoint, write Planner, post Teams messages, run runtime smoke, or make SHIP.

## Flow IDs From AQ-07

| Flow Display Name | AQ-07 Flow ID |
| --- | --- |
| PM0_PA_Card_ResumoExecutivoPortfolio | b4df90ec-a721-44cf-adbd-a5ced1d7f9f7 |
| PM0_PA_Card_AtualizarStatus | b7678a81-df01-4070-b6db-3c0dbcc7f924 |
| PM0_PA_Card_ListarTarefas | c9e44878-77ed-4b17-9b6f-0bab008a0587 |
| PM0_PA_Card_CriarTarefa | 76146280-a6c2-4068-8a3f-3310e3e9210f |
| PM0_PA_Card_AtualizarTarefa | 36142fd3-9f83-4d4f-81e2-748ded919a92 |
| PM0_PA_OpsFailureHandling | 2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441 |

## Read-Only Findings

1. PAC is authenticated to environment `ColOfertasBrasilPro` / `e2d10003-4d8e-e007-9d63-76d5fe89ef56`.
2. Current Copilot components exist for `pmo_AssistentePMO_V2` topics/actions including `ConsultarPortfolio`, `AtualizarStatus`, `ListarTarefas`, `CriarTarefa`, and `AtualizarTarefa`.
3. Current Copilot `botcomponent_workflow` rows still bind those components to older `PMO_PA_*` workflow rows:
   - `pmo_AssistentePMO_V2.topic.ConsultarPortfolio` -> `PMO_PA_ConsultarPortfolio`
   - `pmo_AssistentePMO_V2.topic.AtualizarStatus` -> `PMO_PA_AtualizarStatus`
   - `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` -> `PMO_PA_ListarTarefas`
   - `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` -> `PMO_PA_CriarTarefa`
   - `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` -> `PMO_PA_AtualizarTarefa`
4. The six AQ-07 `PM0_PA_*` ProcessSimple flows are enabled, but `Get-Flow` returned `WorkflowEntityId = null` for each checked flow.
5. `PM0_PA_OpsFailureHandling` was created with actual flow ID `2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441`; the requested POST ID `6e9f75cb-77fb-4cc7-a0bd-07e96fbd1c6f` is not the usable flow ID.

## Decision

AQ-08 cannot be published safely against the current AQ-07 artifacts. Existing Copilot binding mechanics require Dataverse workflow entity IDs, and the current AQ-07 ProcessSimple-created flows do not expose them. Do not run `pac copilot publish` yet; publishing now would publish stale bindings to older `PMO_PA_*` actions.

## Next Required Work

Rework AQ-07 flow deployment into solution-aware / Copilot-bindable cloud flows, or create a documented AQ-08 action-registration path that produces Dataverse workflow rows and action bindings before publish.
