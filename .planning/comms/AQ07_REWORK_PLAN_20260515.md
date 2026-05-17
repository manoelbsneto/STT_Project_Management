# AQ-07 Rework Plan: Solution-Aware Copilot-Bindable Flows

Date: 2026-05-15
Status: READY FOR OWNER APPROVAL
Scope: AQ-07 ProcessSimple flow binding correction

## 1. Context and Problem

The AQ-07 flows were provisioned successfully via the ProcessSimple REST API, generating cloud flows with `FlowName` GUIDs. However, Copilot Studio action binding requires Dataverse `WorkflowEntityId` identifiers in `botcomponent_workflowset.xml`. By default, flows created via ProcessSimple are not immediately tracked in Dataverse (they lack a `WorkflowEntityId`) until they are associated with a Dataverse Solution.

## 2. Safest Documented Path

The project's master runbook and prior implementations (e.g., `deploy/CS_G4_Complete.ps1`) demonstrate the approved method for resolving this:
Use the `Set-FlowAsSolutionAware` cmdlet from the `Microsoft.PowerApps.Administration.PowerShell` module. This cmdlet injects the existing ProcessSimple cloud flow into the Dataverse Default Solution (`fd140aaf-4df4-11dd-bd17-0019b9312238`), forcing the platform to generate the required `WorkflowEntityId` without destroying or recreating the flow.

## 3. Implementation Script

A new script has been created: `deploy/PA_AQ07_MakeSolutionAware.ps1`.
This script connects via the approved absolute module paths, iterates over the six AQ-07 `PM0_PA_*` flows, calls `Set-FlowAsSolutionAware`, and polls `Get-Flow` until the `WorkflowEntityId` is visible. It then outputs the results to a JSON evidence file in `.planning/comms/`.

## 4. Evidence Matrix (Pre-Execution)

| Flow Display Name | ProcessSimple Flow ID | Required Dataverse WorkflowEntityId | Status |
| --- | --- | --- | --- |
| PM0_PA_Card_ResumoExecutivoPortfolio | b4df90ec-a721-44cf-adbd-a5ced1d7f9f7 | TBD (pending execution) | REQUIRED |
| PM0_PA_Card_AtualizarStatus | b7678a81-df01-4070-b6db-3c0dbcc7f924 | TBD (pending execution) | REQUIRED |
| PM0_PA_Card_ListarTarefas | c9e44878-77ed-4b17-9b6f-0bab008a0587 | TBD (pending execution) | REQUIRED |
| PM0_PA_Card_CriarTarefa | 76146280-a6c2-4068-8a3f-3310e3e9210f | TBD (pending execution) | REQUIRED |
| PM0_PA_Card_AtualizarTarefa | 36142fd3-9f83-4d4f-81e2-748ded919a92 | TBD (pending execution) | REQUIRED |
| PM0_PA_OpsFailureHandling | 2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441 | TBD (pending execution) | REQUIRED |

## 5. Rollback Plan

If `Set-FlowAsSolutionAware` fails or creates unintended side effects, the script is non-destructive to the Flow definitions themselves. 
**Rollback steps:**
1. Do not proceed to AQ-08 Copilot publish.
2. Revert to the prior state by deleting the AQ-07 flows (`Remove-Flow`) and re-running the original AQ-07 POST script to recreate them cleanly without solution awareness, reverting to the unbindable state.

## 6. AQ-08 Handoff Note

**AQ-08 Copilot Publish CANNOT RESUME YET.** It is currently blocked pending the owner's execution of this rework plan. Once `PA_AQ07_MakeSolutionAware.ps1` runs and the `WorkflowEntityId` values are confirmed non-null, AQ-08 can update the `botcomponent_workflowset.xml` to point to these new Dataverse IDs and proceed with the `pac copilot publish` gate.
