# PM0_PA_Card_ListarTarefas Action Contract Audit

## Verdict

`PM0_PA_Card_ListarTarefas` has no top-level `inputs:` block in the exported `TaskDialog` action. The matching local workflow trigger requires both `action` and `projectId`, so this action contract does not declare mappings for two required trigger fields.

## Local Evidence

| Artifact | Evidence |
|---|---|
| Action | `Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_ListarTarefas.mcs.yml:1-15` |
| Workflow | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json:36-63` |
| Workflow response output | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json:88-114` |

## Verbatim Action YAML

```yaml
mcs.metadata:
  componentName: PM0_PA_Card_ListarTarefas
kind: TaskDialog
outputs:
  - propertyName: result

action:
  kind: InvokeFlowTaskAction
  flowId: e0e3c6b0-a250-f111-bec7-000d3abc5cc6
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
| Output declaration for workflow response property `result` | PASS | Action lines 4-5 and workflow lines 101-112 |
| Top-level `inputs:` block | MISSING | Action lines 1-15 contain no `inputs:` block |
| Required workflow trigger input mapping | FAIL | Workflow lines 56-59 require `action` and `projectId`; action declares no input mappings |

## Workflow Trigger Schema Derived Locally

The matching `kind: Skills` request trigger defines these body properties under `properties.definition.triggers.manual.inputs.schema`:

| Trigger body field | Type | Required | Workflow evidence |
|---|---|---|---|
| `action` | `string` | Yes | Workflow lines 46-50 and 56-59 |
| `projectId` | `string` | Yes | Workflow lines 51-54 and 56-59 |

## Required Trigger Fields Not Declared By Action

| Required trigger field | Action declaration | Evidence |
|---|---|---|
| `action` | Not declared | Required in workflow lines 46-50 and 56-59; no top-level `inputs:` in action lines 1-15 |
| `projectId` | Not declared | Required in workflow lines 51-54 and 56-59; no top-level `inputs:` in action lines 1-15 |

## Microsoft Learn Validation

Official Microsoft Learn states that agent flow inputs are added on the "When an agent calls the flow" trigger, outputs are added on the "Respond to the agent" action, and the flow input parameter is then set on the action node that calls the flow. The local workflow trigger has required `action` and `projectId` fields, while this exported action has no input declaration or property mapping for either field. Microsoft Learn also documents the Copilot Studio error condition where a flow parameter is missing in the "Call Flow" action. That supports classifying the absent required field declarations as contract defects.  
URL: https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output  
URL: https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/authoring/error-codes  
Accessed: `2026-05-22 15:24:16 -03:00`

Microsoft Learn shows a Copilot Studio tool definition using `dialog.kind: TaskDialog`, an `action.kind`, and input and response schema metadata for a task action. That page is evidence for the TaskDialog tool shape and input/output schema concept. The Microsoft Learn pages located for this audit do not publish a dedicated exported `.mcs.yml` schema reference for `InvokeFlowTaskAction` fields such as local `ManualTaskInput.propertyName` and `value`; those field names are therefore treated here as local export evidence, not as an uncited Microsoft schema claim.  
URL: https://learn.microsoft.com/en-ie/microsoft-copilot-studio/authoring-send-event-activities  
Accessed: `2026-05-22 15:24:16 -03:00`

