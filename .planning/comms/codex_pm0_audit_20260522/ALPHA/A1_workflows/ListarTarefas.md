# A1 Workflow Audit: ListarTarefas

## Scope

- Workflow file: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Trigger evidence: `workflow.json:36-62`
- Action evidence: `workflow.json:64-158`

## Trigger Input Schema

Trigger schema path: `$.properties.definition.triggers.manual.inputs.schema`

| Name | Type | Required | Verbatim JSON path | Evidence |
|---|---|---|---|---|
| `action` | `string` | true | `$.properties.definition.triggers.manual.inputs.schema.properties.action` | `workflow.json:47-50`; required list is `workflow.json:56-59` |
| `projectId` | `string` | true | `$.properties.definition.triggers.manual.inputs.schema.properties.projectId` | `workflow.json:51-54`; required list is `workflow.json:56-59` |

## Action Chain

Execution order follows each action `runAfter` dependency.

| Order | Action | Type | `connectionName` | `operationId` | Evidence |
|---|---|---|---|---|---|
| 1 | `Get_Tarefas` | `OpenApiConnection` | `shared_sharepointonline` | `GetItems` | `workflow.json:137-157` |
| 2 | `List_Planner_Tasks` | `OpenApiConnection` | `shared_planner` | `ListTasks_V3` | `workflow.json:65-87` |
| 3 | `Normalize_Tasks` | `Select` | n/a | n/a | `workflow.json:116-136` |
| 4 | `Respond_Success` | `Response` | n/a | n/a | `workflow.json:88-115` |

## SP And Planner Filters Or Parameters

`Get_Tarefas` SharePoint parameters at `workflow.json:149-153`:

```json
"parameters": {
  "dataset": "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
  "table": "Tarefas",
  "$filter": "ProjectID eq \u0027@{replace(triggerBody()?[\u0027projectId\u0027],\u0027\u0027\u0027\u0027,\u0027\u0027\u0027\u0027\u0027\u0027)}\u0027",
  "$top": 100
}
```

`List_Planner_Tasks` Planner parameters at `workflow.json:81-84`:

```json
"parameters": {
  "groupId": "96c5b0c4-46cc-46cd-8695-50451db74994",
  "id": "-1kBj1PLv0qQM-R4PwkqbpcABv_P"
}
```

## Response Body

Response body path: `$.properties.definition.actions.Respond_Success.inputs.body`

Verbatim body at `workflow.json:101-103`:

```json
"body": {
  "result": "Tasks retrieved successfully."
}
```

## SP Or Planner Data Flow Into Response

Result: `false`.

Evidence:

- SharePoint task data is projected by `Normalize_Tasks` from `body('Get_Tarefas')?['value']` at `workflow.json:125-135`.
- `Respond_Success` runs after `Normalize_Tasks` at `workflow.json:88-93`, but its body remains the fixed literal at `workflow.json:101-103` and does not reference `Normalize_Tasks`, `Get_Tarefas`, `List_Planner_Tasks`, `body(...)`, or `outputs(...)`.

## Adaptive Card Posting Analysis

No Teams card post action or other Adaptive Card posting action exists in `workflow.json:64-158`. Dynamic versus static card content is therefore not applicable for this workflow body.

## Official Microsoft Learn Response Contract

Microsoft Learn says an agent flow must have the `When an agent calls the flow` trigger and a `Respond to the agent` response action, and that when response actions appear on multiple branches they must expose the same outputs. It also documents outputs as fields added on `Respond to the agent`, with Copilot Studio flow parameters limited to Number, String, and Boolean. For this exported `Request` trigger with `kind: Skills`, this audit checks the exported response action shape at `type: Response`, `kind: Skills`, `inputs.body`, and `inputs.schema`.

- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent`
- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output`
- Accessed: `2026-05-22 15:23:47 -03:00`

## Classification

Classification: `PARTIAL`.

Prompt criteria applied:

- `PARTIAL` means SharePoint or Planner actions exist but the response body does not reflect their output.
- SharePoint and Planner reads exist at `workflow.json:65-87` and `workflow.json:137-157`.
- SharePoint data is selected at `workflow.json:116-136`, but the response body is the fixed literal at `workflow.json:101-103`.
