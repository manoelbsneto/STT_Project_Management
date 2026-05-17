# AQ-08 Copilot Publish Checklist

Date: 2026-05-15
Status: BLOCKED_BY_BINDING_DISCOVERY

## Prerequisites
- [x] AQ-07 Power Automate programmatic save completed by CODEX-LEAD.
- [x] AQ-07 Flow IDs and Environment URL captured.
- [x] Owner approval for AQ-08 explicitly granted.

Owner approval received in current thread:

```text
Approved, AQ-08 Copilot Studio update/publish for the P0 Adaptive Cards + Planner routing topics after AQ-07 flow save/import evidence is complete. Capture publish evidence, topic/action binding evidence, and rollback evidence. This approval does not authorize additional flow imports, SharePoint schema writes, Planner writes outside approved runtime behavior, or final SHIP.
```

Execution constraint: `.planning/comms/P0_REMAINING_GATES_EXECUTION_RUNBOOK_20260515.md` states no AQ-08 package-specific Copilot publish command is defined in required local files. Read-only live binding discovery is allowed before any publish/update path is selected.

Read-only discovery result: BLOCK. Current AQ-07 `PM0_PA_*` flows exist in ProcessSimple and are enabled, but they do not expose Dataverse `workflowEntityId` values. Existing Copilot Studio action bindings use `botcomponent_workflow.workflowid` Dataverse workflow rows. Therefore the current AQ-07 flow artifacts cannot be safely rebound to Copilot through the existing documented `botcomponent_workflowset.xml` pattern.

## Topic/Action Bindings to Update
| Route Key | Flow Display Name | Target Flow ID | Status |
| --- | --- | --- | --- |
| `board.status` | PM0_PA_Card_ResumoExecutivoPortfolio | `b4df90ec-a721-44cf-adbd-a5ced1d7f9f7` | BLOCKED_NO_WORKFLOW_ENTITY_ID |
| `pm.status.updates` | PM0_PA_Card_AtualizarStatus | `b7678a81-df01-4070-b6db-3c0dbcc7f924` | BLOCKED_NO_WORKFLOW_ENTITY_ID |
| `task.card.route` | PM0_PA_Card_ListarTarefas | `c9e44878-77ed-4b17-9b6f-0bab008a0587` | BLOCKED_NO_WORKFLOW_ENTITY_ID |
| `task.card.route` | PM0_PA_Card_CriarTarefa | `76146280-a6c2-4068-8a3f-3310e3e9210f` | BLOCKED_NO_WORKFLOW_ENTITY_ID |
| `task.card.route` | PM0_PA_Card_AtualizarTarefa | `36142fd3-9f83-4d4f-81e2-748ded919a92` | BLOCKED_NO_WORKFLOW_ENTITY_ID |
| `pmo.ops` | PM0_PA_OpsFailureHandling | `2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441` | BLOCKED_NO_WORKFLOW_ENTITY_ID |

## Validation
- [ ] Publish proof: Screenshot or portal record showing publish success.
- [ ] Binding proof: Topics/actions route to the current P0 flows, not stale flow IDs.
- [ ] Output proof: Copilot responses are short acknowledgements and do not contain raw SharePoint/Planner rows.
- [ ] Rollback: Prior published version/export or documented revert path.

## Read-Only Evidence Captured

| Evidence | Path |
| --- | --- |
| PAC environment confirmation | `.planning/comms/aq08_copilot_publish_20260515/pac_env_who.txt` |
| Current Copilot bot components | `.planning/comms/aq08_copilot_publish_20260515/pac_fetch_botcomponents.txt` |
| Current Copilot action/topic bindings | `.planning/comms/aq08_copilot_publish_20260515/pac_fetch_botcomponent_workflows.txt` |
| AQ-07 ProcessSimple flow inventory | `.planning/comms/aq08_copilot_publish_20260515/get_flow_pm0_inventory.json` |
| AQ-07 Ops actual flow ID inventory | `.planning/comms/aq08_copilot_publish_20260515/get_flow_ops_actual_inventory.json` |
