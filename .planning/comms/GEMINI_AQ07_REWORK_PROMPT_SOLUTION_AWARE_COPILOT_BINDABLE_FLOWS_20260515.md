# Gemini AQ-07 Rework Prompt: Solution-Aware Copilot-Bindable Flows

Date: 2026-05-15
Prepared by: CODEX-LEAD
Purpose: unblock AQ-08 Copilot Studio topic/action binding and publish.

## Context

AQ-07 ProcessSimple programmatic save created/enabled the `PM0_PA_*` flows, but AQ-08 read-only discovery found they are not bindable through the existing Copilot Studio `botcomponent_workflow` pattern:

- `Get-Flow` returns `WorkflowEntityId = null` for the AQ-07 `PM0_PA_*` flows.
- Existing Copilot Studio bindings use Dataverse `botcomponent_workflow.workflowid` values, not ProcessSimple flow IDs.
- Current `pmo_AssistentePMO_V2` bindings still point to older `PMO_PA_*` workflows.
- Running `pac copilot publish` now would publish stale bindings.

Evidence:

```text
.planning/comms/aq08_copilot_publish_20260515/AQ08_READONLY_DISCOVERY.md
.planning/comms/aq08_copilot_publish_20260515/get_flow_pm0_inventory.json
.planning/comms/aq08_copilot_publish_20260515/get_flow_ops_actual_inventory.json
.planning/comms/aq08_copilot_publish_20260515/pac_fetch_botcomponent_workflows.txt
```

## Task ID

```text
AQ-07-REWORK-SOLUTION-AWARE-COPILOT-BINDABLE-FLOWS
```

## Goal

Produce a corrected AQ-07 deployment path where each AQ-07 flow is Copilot-bindable and has a Dataverse workflow entity ID suitable for `botcomponent_workflowset.xml` binding.

## Required Outputs

1. Rework plan explaining the safest documented path:
   - solution-aware cloud flows, or
   - documented Copilot action-registration path that creates Dataverse workflow rows.
2. Updated implementation script/package, if a documented safe programmatic path exists.
3. Evidence matrix mapping:

| Flow Display Name | ProcessSimple Flow ID | Required Dataverse WorkflowEntityId | Status |
| --- | --- | --- | --- |
| PM0_PA_Card_ResumoExecutivoPortfolio | b4df90ec-a721-44cf-adbd-a5ced1d7f9f7 | TBD | REQUIRED |
| PM0_PA_Card_AtualizarStatus | b7678a81-df01-4070-b6db-3c0dbcc7f924 | TBD | REQUIRED |
| PM0_PA_Card_ListarTarefas | c9e44878-77ed-4b17-9b6f-0bab008a0587 | TBD | REQUIRED |
| PM0_PA_Card_CriarTarefa | 76146280-a6c2-4068-8a3f-3310e3e9210f | TBD | REQUIRED |
| PM0_PA_Card_AtualizarTarefa | 36142fd3-9f83-4d4f-81e2-748ded919a92 | TBD | REQUIRED |
| PM0_PA_OpsFailureHandling | 2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441 | TBD | REQUIRED |

4. Rollback plan for the reworked AQ-07 deployment.
5. AQ-08 handoff note that says whether Copilot binding/publish can resume.

## Hard Constraints

- Do not run tenant writes unless the owner explicitly approves this rework execution in the current thread.
- Do not import additional flows unless explicitly approved.
- Do not publish Copilot.
- Do not write SharePoint schema.
- Do not write Planner outside approved runtime behavior.
- Do not run AQ-09 runtime smoke.
- Do not declare SHIP.
- Do not use Microsoft 365 CLI, direct Graph, HTTP Premium, client credentials, app registrations, or service principals.

## Required References

Read before planning:

```text
.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
.planning/comms/P0_REMAINING_GATES_EXECUTION_RUNBOOK_20260515.md
.planning/comms/aq08_copilot_publish_20260515/AQ08_READONLY_DISCOVERY.md
deploy/MASTER_RUNBOOK/MASTER_RUNBOOK.md
deploy/CS_G4_Complete.ps1
deploy/Build-Solution24LocalPackage.ps1
```

## Acceptance Criteria

AQ-07 rework is accepted only when:

- each target `PM0_PA_*` flow has a non-null Dataverse workflow entity ID, or a documented equivalent Copilot action binding identifier;
- a read-only binding inventory can map current AQ-07 flow/action targets to Copilot components;
- stale `PMO_PA_*` bindings are not claimed as AQ-07 success;
- AQ-08 can update/publish using documented package-specific evidence;
- rollback is documented before any tenant mutation.

## Handoff Back To CODEX-LEAD

Return:

```text
STATUS: READY_FOR_CODEX_REVIEW or BLOCKED_WITH_REASON
FILES CHANGED:
EVIDENCE:
RECOMMENDED NEXT ACTION:
OWNER APPROVAL NEEDED:
```
