# PM0_PA_Card_ResumoExecutivoPortfolio Action Contract Audit

## Verdict

`PM0_PA_Card_ResumoExecutivoPortfolio` has no top-level `inputs:` block in the exported `TaskDialog` action. The matching local workflow trigger has no trigger properties and an empty `required` array, so this action does not omit a required workflow trigger field.

## Local Evidence

| Artifact | Evidence |
|---|---|
| Action | `Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_ResumoExecutivoPortfolio.mcs.yml:1-15` |
| Workflow | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333bd91-a250-f111-bec7-000d3abc5cc6/workflow.json:27-39` |
| Workflow response output | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333bd91-a250-f111-bec7-000d3abc5cc6/workflow.json:61-87` |

## Verbatim Action YAML

```yaml
mcs.metadata:
  componentName: PM0_PA_Card_ResumoExecutivoPortfolio
kind: TaskDialog
outputs:
  - propertyName: result

action:
  kind: InvokeFlowTaskAction
  flowId: 8333bd91-a250-f111-bec7-000d3abc5cc6
  connectionProperties:
    $kind: ConnectionProperties
    diagnostics:
    mode: Invoker

outputMode: All
```

## Action Contract Check

| Check | Status | Evidence |
|---|---|---|
| `kind: TaskDialog` present | PASS | Action lines 1-3 |
| `action.kind: InvokeFlowTaskAction` present | PASS | Action lines 7-9 |
| `action.flowId` matches workflow folder ID | PASS | Action line 9 and workflow path |
| Output declaration for workflow response property `result` | PASS | Action lines 4-5 and workflow lines 74-85 |
| Top-level `inputs:` block | MISSING | Action lines 1-15 contain no `inputs:` block |
| Required workflow trigger input mapping | PASS FOR REQUIRED FIELDS | Workflow lines 33-36 define no properties and no required fields |

## Workflow Trigger Schema Derived Locally

The matching `kind: Skills` request trigger defines an object schema with no body properties and no required fields under `properties.definition.triggers.manual.inputs.schema`.

| Trigger body field | Type | Required | Workflow evidence |
|---|---|---|---|
| None | N/A | N/A | Workflow lines 31-36 |

## Required Trigger Fields Not Declared By Action

None. The workflow trigger `required` array is empty at workflow line 35.

## Microsoft Learn Validation

Official Microsoft Learn states that agent flow inputs are added on the "When an agent calls the flow" trigger, outputs are added on the "Respond to the agent" action, and the flow input parameter is then set on the action node that calls the flow. This workflow trigger does not define an input parameter to map, while the workflow response defines `result` and the action declares that same output property.  
URL: https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output  
Accessed: `2026-05-22 15:24:16 -03:00`

Microsoft Learn shows a Copilot Studio tool definition using `dialog.kind: TaskDialog`, an `action.kind`, and input and response schema metadata for a task action. That page is evidence for the TaskDialog tool shape and input/output schema concept. The Microsoft Learn pages located for this audit do not publish a dedicated exported `.mcs.yml` schema reference for `InvokeFlowTaskAction` fields such as local `ManualTaskInput.propertyName` and `value`; those field names are therefore treated here as local export evidence, not as an uncited Microsoft schema claim.  
URL: https://learn.microsoft.com/en-ie/microsoft-copilot-studio/authoring-send-event-activities  
Accessed: `2026-05-22 15:24:16 -03:00`

