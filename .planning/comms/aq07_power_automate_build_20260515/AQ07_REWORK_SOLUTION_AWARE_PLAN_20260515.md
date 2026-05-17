# AQ-07 Rework: Solution-Aware Copilot-Bindable Flows

## 1. Rework Plan
The safest documented path to make ProcessSimple flows Copilot-bindable is to convert them into solution-aware cloud flows using the PowerApps Administration module, then bind them using a solution import. 
According to `deploy/MASTER_RUNBOOK/MASTER_RUNBOOK.md` and `deploy/CS_G4_Complete.ps1`, the process is:
1. Run `Set-FlowAsSolutionAware -EnvironmentName <EnvId> -FlowName <FlowId> -SolutionId <SolutionId>` for each `PM0_PA_*` flow. This creates the Dataverse `workflowEntityId`.
2. Query `Get-Flow` to capture the newly assigned `workflowEntityId` for each flow.
3. Dynamically generate a Dataverse solution package (ZIP) containing:
   - `botcomponent` definitions for each Copilot action/topic.
   - `botcomponent_workflowset.xml` mapping the bot component schema name to the new `workflowEntityId`.
   - `solution.xml` and `customizations.xml`.
4. Import the package using `pac solution import --publish-changes` to register the Dataverse actions and link them to the flows.

## 2. Updated Implementation Script
The implementation script has been provided at `.planning/comms/aq07_power_automate_build_20260515/Invoke-AQ07SolutionAwareBinding.ps1`. This script safely follows the above path, performing the conversion, building the solution ZIP safely using `System.IO.Compression.ZipFile`, and calling `pac solution import`.

## 3. Evidence Matrix

| Flow Display Name | ProcessSimple Flow ID | Required Dataverse WorkflowEntityId | Status |
| --- | --- | --- | --- |
| PM0_PA_Card_ResumoExecutivoPortfolio | b4df90ec-a721-44cf-adbd-a5ced1d7f9f7 | TBD | REQUIRED |
| PM0_PA_Card_AtualizarStatus | b7678a81-df01-4070-b6db-3c0dbcc7f924 | TBD | REQUIRED |
| PM0_PA_Card_ListarTarefas | c9e44878-77ed-4b17-9b6f-0bab008a0587 | TBD | REQUIRED |
| PM0_PA_Card_CriarTarefa | 76146280-a6c2-4068-8a3f-3310e3e9210f | TBD | REQUIRED |
| PM0_PA_Card_AtualizarTarefa | 36142fd3-9f83-4d4f-81e2-748ded919a92 | TBD | REQUIRED |
| PM0_PA_OpsFailureHandling | 2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441 | TBD | REQUIRED |

## 4. Rollback Plan
If `Set-FlowAsSolutionAware` or the solution import fails:
1. Do not proceed to Copilot publish. 
2. The flows will remain standard ProcessSimple flows.
3. If the solution import partially succeeds but bindings are wrong, revert by deploying the previous valid solution `PMO_G4_Completion` (or similar previous export) using `pac solution import` to restore the older bindings to `PMO_PA_*` flows.
4. Flows themselves are not deleted by the solution removal; they can be disabled manually or via `Disable-Flow`.

## 5. AQ-08 Handoff Note
**AQ-08 Copilot publish CANNOT resume yet.** 
The owner must first approve and execute the `Invoke-AQ07SolutionAwareBinding.ps1` script to perform the tenant writes (Flow conversion and PAC Solution Import). Once the evidence matrix above is populated with actual `WorkflowEntityId`s and the PAC import succeeds, AQ-08 can proceed to update and publish.