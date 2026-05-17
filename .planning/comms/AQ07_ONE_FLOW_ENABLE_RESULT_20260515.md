# AQ-07 One-Flow Enable Result

Date: 2026-05-15
Executor: CODEX-LEAD
Task: AQ-07 one-flow remediation for `PM0_PA_Card_ResumoExecutivoPortfolio`
Release decision: NO-SHIP

## Verdict

STATUS: BLOCKED_WITH_REASON

The approved one-flow `Enable-Flow` remediation was attempted for only:

```text
PM0_PA_Card_ResumoExecutivoPortfolio
ProcessSimple Flow ID: b4df90ec-a721-44cf-adbd-a5ced1d7f9f7
Dataverse WorkflowEntityId: 8333bd91-a250-f111-bec7-000d3abc5cc6
```

It did not succeed. Power Platform returned:

```text
StatusCode: 400 Bad Request
Code: 0x80060467
Message: A connector was imported, however the related connection references need connections created and then any dependent flows can be started.
```

## Current State

Read-only `Get-Flow` evidence after the enable attempt:

| Field | Value |
| --- | --- |
| DisplayName | `PM0_PA_Card_ResumoExecutivoPortfolio` |
| FlowName | `b4df90ec-a721-44cf-adbd-a5ced1d7f9f7` |
| Enabled | `false` |
| State | `Stopped` |
| WorkflowEntityId | `8333bd91-a250-f111-bec7-000d3abc5cc6` |

Read-only PAC workflow evidence after the enable attempt:

```text
PM0_PA_Card_ResumoExecutivoPortfolio
workflowid: 8333bd91-a250-f111-bec7-000d3abc5cc6
statecode/statuscode: Borrador / Borrador
```

The other five `PM0_PA_*` workflow rows remain `Activado`.

## Evidence Files

```text
.planning/comms/aq07_power_automate_build_20260515/one_flow_enable_20260515_1840/enable_flow_output.txt
.planning/comms/aq07_power_automate_build_20260515/one_flow_enable_20260515_1840/get_flow_resumo_after_enable_attempt.json
.planning/comms/aq07_power_automate_build_20260515/one_flow_enable_20260515_1840/pac_fetch_workflows_after_enable_attempt.txt
.planning/comms/aq07_power_automate_build_20260515/one_flow_enable_20260515_1840/pac_fetch_botcomponent_workflows_after_enable_attempt.txt
```

## Scope Statement

Executed:

- one `Enable-Flow` attempt for `b4df90ec-a721-44cf-adbd-a5ced1d7f9f7`;
- read-only `Get-Flow` evidence;
- read-only PAC FetchXML workflow and binding evidence.

Not executed:

- no Copilot publish;
- no AQ-09 runtime smoke;
- no SharePoint schema write;
- no Planner write;
- no Teams post;
- no unrelated flow change;
- no solution import;
- no Microsoft 365 CLI;
- no direct Graph;
- no HTTP Premium;
- no client credentials, app registrations, or service principals;
- no final SHIP.

## Technical Interpretation

The remaining AQ-07 blocker is no longer just a simple stopped-state issue. The flow cannot be started because the imported solution-aware workflow has unresolved or unmapped connection references.

AQ-08 publish remains blocked until `PM0_PA_Card_ResumoExecutivoPortfolio` can be started and read-only evidence confirms all six `PM0_PA_*` workflows are `Activado` and bound.

## Recommended Next Action

Run a read-only connection-reference diagnosis for the imported AQ-07 binding solution and the stopped workflow, then choose a remediation path:

1. map/create the missing connection reference in Power Platform UI / solution import settings; or
2. patch the solution package to use existing connection reference logical names and re-import under explicit owner approval; or
3. manually open the flow in Power Automate, repair the connection reference, save, and turn on, then capture evidence.

## Owner Approval Needed

Yes. A new explicit approval is required before any connection reference mapping, solution re-import, manual portal save, or other tenant mutation.

