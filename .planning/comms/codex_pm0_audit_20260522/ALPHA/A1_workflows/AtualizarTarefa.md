# A1 Workflow Audit: AtualizarTarefa

## Scope

- Workflow file: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarTarefa-7c6300c2-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Trigger evidence: `workflow.json:42-80`
- Action evidence: `workflow.json:82-194`

## Trigger Input Schema

Trigger schema path: `$.properties.definition.triggers.manual.inputs.schema`

| Name | Type | Required | Verbatim JSON path | Evidence |
|---|---|---|---|---|
| `action` | `string` | true | `$.properties.definition.triggers.manual.inputs.schema.properties.action` | `workflow.json:50-53`; required list is `workflow.json:75-77` |
| `spItemId` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.spItemId` | `workflow.json:54-57`; required list is `workflow.json:75-77` |
| `taskId` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.taskId` | `workflow.json:58-61`; required list is `workflow.json:75-77` |
| `status` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.status` | `workflow.json:62-65`; required list is `workflow.json:75-77` |
| `taskStatus` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.taskStatus` | `workflow.json:66-69`; required list is `workflow.json:75-77` |
| `comments` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.comments` | `workflow.json:70-73`; required list is `workflow.json:75-77` |

## Action Chain

Execution order follows each action `runAfter` dependency.

| Order | Action | Type | `connectionName` | `operationId` | Evidence |
|---|---|---|---|---|---|
| 1 | `Get_SharePoint_Item` | `OpenApiConnection` | `shared_sharepointonline` | `GetItem` | `workflow.json:174-193` |
| 2 | `Determine_Bucket_and_Percent` | `Compose` | n/a | n/a | `workflow.json:106-114` |
| 3 | `Update_Planner_Task` | `OpenApiConnection` | `shared_planner` | `UpdateTask_V2` | `workflow.json:83-105` |
| 4 | `Update_SharePoint_Item` | `OpenApiConnection` | `shared_sharepointonline` | `PatchItem` | `workflow.json:115-145` |
| 5 | `Respond_Success` | `Response` | n/a | n/a | `workflow.json:146-173` |

## SP And Planner Filters Or Parameters

`Get_SharePoint_Item` SharePoint parameters at `workflow.json:178-181`:

```json
"parameters": {
  "table": "Tarefas",
  "id": "@coalesce(triggerBody()?[\u0027spItemId\u0027],triggerBody()?[\u0027taskId\u0027])",
  "dataset": "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
}
```

`Update_Planner_Task` Planner parameters at `workflow.json:91-94`:

```json
"parameters": {
  "id": "@body(\u0027Get_SharePoint_Item\u0027)?[\u0027PlannerTaskId\u0027]",
  "body/percentComplete": "@outputs(\u0027Determine_Bucket_and_Percent\u0027)?[\u0027percentComplete\u0027]"
}
```

`Update_SharePoint_Item` SharePoint parameters at `workflow.json:123-134`:

```json
"parameters": {
  "dataset": "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
  "item/Status/Value": "@coalesce(triggerBody()?[\u0027status\u0027],triggerBody()?[\u0027taskStatus\u0027])",
  "item/Title": "@body(\u0027Get_SharePoint_Item\u0027)?[\u0027Title\u0027]",
  "id": "@coalesce(triggerBody()?[\u0027spItemId\u0027],triggerBody()?[\u0027taskId\u0027])",
  "item/PlannerSyncStatus/Value": "OK",
  "table": "Tarefas",
  "item/ProjectID": "@body(\u0027Get_SharePoint_Item\u0027)?[\u0027ProjectID\u0027]",
  "item/PlannerBucketId": "@outputs(\u0027Determine_Bucket_and_Percent\u0027)?[\u0027bucketId\u0027]",
  "item/PlannerLastSyncAt": "@utcNow()",
  "item/PlannerSyncError": ""
}
```

## Response Body

Response body path: `$.properties.definition.actions.Respond_Success.inputs.body`

Verbatim body at `workflow.json:159-161`:

```json
"body": {
  "result": "Task updated successfully."
}
```

## SP Or Planner Data Flow Into Response

Result: `false`.

Evidence:

- SharePoint and Planner action output expressions are used in connector parameters at `workflow.json:91-94` and `workflow.json:123-134`.
- The response body at `workflow.json:159-161` contains only the fixed literal string and does not reference `body(...)`, `outputs(...)`, or connector action data.

## Adaptive Card Posting Analysis

No Teams card post action or other Adaptive Card posting action exists in `workflow.json:82-194`. Dynamic versus static card content is therefore not applicable for this workflow body.

## Official Microsoft Learn Response Contract

Microsoft Learn says an agent flow must have the `When an agent calls the flow` trigger and a `Respond to the agent` response action, and that when response actions appear on multiple branches they must expose the same outputs. It also documents outputs as fields added on `Respond to the agent`, with Copilot Studio flow parameters limited to Number, String, and Boolean. For this exported `Request` trigger with `kind: Skills`, this audit checks the exported response action shape at `type: Response`, `kind: Skills`, `inputs.body`, and `inputs.schema`.

- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent`
- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output`
- Accessed: `2026-05-22 15:23:47 -03:00`

## Classification

Classification: `PARTIAL`.

Prompt criteria applied:

- `PARTIAL` means SharePoint or Planner actions exist but the response body does not reflect their output.
- SharePoint and Planner connector actions exist at `workflow.json:83-105`, `workflow.json:115-145`, and `workflow.json:174-193`.
- The response body is the fixed literal at `workflow.json:159-161`, so the returned result is not a dynamic connector-backed response.
