# A1 Workflow Audit: CriarTarefa

## Scope

- Workflow file: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_CriarTarefa-7f662db7-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Trigger evidence: `workflow.json:42-93`
- Action evidence: `workflow.json:95-184`

## Trigger Input Schema

Trigger schema path: `$.properties.definition.triggers.manual.inputs.schema`

| Name | Type | Required | Verbatim JSON path | Evidence |
|---|---|---|---|---|
| `dueDate` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.dueDate` | `workflow.json:50-53`; required list is `workflow.json:87-90` |
| `action` | `string` | true | `$.properties.definition.triggers.manual.inputs.schema.properties.action` | `workflow.json:54-57`; required list is `workflow.json:87-90` |
| `taskTitle` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.taskTitle` | `workflow.json:58-61`; required list is `workflow.json:87-90` |
| `projectId` | `string` | true | `$.properties.definition.triggers.manual.inputs.schema.properties.projectId` | `workflow.json:62-65`; required list is `workflow.json:87-90` |
| `endDate` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.endDate` | `workflow.json:66-69`; required list is `workflow.json:87-90` |
| `startDate` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.startDate` | `workflow.json:70-73`; required list is `workflow.json:87-90` |
| `bucket` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.bucket` | `workflow.json:74-77`; required list is `workflow.json:87-90` |
| `title` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.title` | `workflow.json:78-81`; required list is `workflow.json:87-90` |
| `plannerBucketName` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.plannerBucketName` | `workflow.json:82-85`; required list is `workflow.json:87-90` |

## Action Chain

Execution order follows each action `runAfter` dependency.

| Order | Action | Type | `connectionName` | `operationId` | Evidence |
|---|---|---|---|---|---|
| 1 | `Determine_Bucket_and_Status` | `Compose` | n/a | n/a | `workflow.json:120-124` |
| 2 | `Create_Planner_Task` | `OpenApiConnection` | `shared_planner` | `CreateTask_V3` | `workflow.json:96-119` |
| 3 | `Create_SharePoint_Item` | `OpenApiConnection` | `shared_sharepointonline` | `PostItem` | `workflow.json:125-155` |
| 4 | `Respond_Success` | `Response` | n/a | n/a | `workflow.json:156-183` |

## SP And Planner Filters Or Parameters

`Create_Planner_Task` Planner parameters at `workflow.json:104-107`:

```json
"parameters": {
  "body/groupId": "96c5b0c4-46cc-46cd-8695-50451db74994",
  "body/planId": "-1kBj1PLv0qQM-R4PwkqbpcABv_P",
  "body/title": "@coalesce(triggerBody()?[\u0027title\u0027],triggerBody()?[\u0027taskTitle\u0027])"
}
```

`Create_SharePoint_Item` SharePoint parameters at `workflow.json:133-143`:

```json
"parameters": {
  "dataset": "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
  "item/PlannerLastSyncAt": "@utcNow()",
  "item/Title": "@coalesce(triggerBody()?[\u0027title\u0027],triggerBody()?[\u0027taskTitle\u0027])",
  "item/PlannerSyncStatus/Value": "OK",
  "table": "Tarefas",
  "item/ProjectID": "@triggerBody()?[\u0027projectId\u0027]",
  "item/PlannerBucketId": "@outputs(\u0027Determine_Bucket_and_Status\u0027)?[\u0027bucketId\u0027]",
  "item/PlannerTaskId": "@body(\u0027Create_Planner_Task\u0027)?[\u0027id\u0027]",
  "item/Status/Value": "@outputs(\u0027Determine_Bucket_and_Status\u0027)?[\u0027status\u0027]",
  "item/PlannerSyncError": ""
}
```

## Response Body

Response body path: `$.properties.definition.actions.Respond_Success.inputs.body`

Verbatim body at `workflow.json:169-171`:

```json
"body": {
  "result": "Task created successfully."
}
```

## SP Or Planner Data Flow Into Response

Result: `false`.

Evidence:

- Planner output is written into SharePoint in `item/PlannerTaskId` at `workflow.json:141`, and Compose output is written into SharePoint at `workflow.json:140` and `workflow.json:142`.
- The response body at `workflow.json:169-171` contains only the fixed literal string and does not reference `Create_Planner_Task`, `Create_SharePoint_Item`, `body(...)`, or `outputs(...)`.

## Adaptive Card Posting Analysis

No Teams card post action or other Adaptive Card posting action exists in `workflow.json:95-184`. Dynamic versus static card content is therefore not applicable for this workflow body.

## Official Microsoft Learn Response Contract

Microsoft Learn says an agent flow must have the `When an agent calls the flow` trigger and a `Respond to the agent` response action, and that when response actions appear on multiple branches they must expose the same outputs. It also documents outputs as fields added on `Respond to the agent`, with Copilot Studio flow parameters limited to Number, String, and Boolean. For this exported `Request` trigger with `kind: Skills`, this audit checks the exported response action shape at `type: Response`, `kind: Skills`, `inputs.body`, and `inputs.schema`.

- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent`
- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output`
- Accessed: `2026-05-22 15:23:47 -03:00`

## Classification

Classification: `PARTIAL`.

Prompt criteria applied:

- `PARTIAL` means SharePoint or Planner actions exist but the response body does not reflect their output.
- Planner and SharePoint create actions exist at `workflow.json:96-119` and `workflow.json:125-155`.
- The response body is the fixed literal at `workflow.json:169-171`, so the returned result does not expose the created Planner or SharePoint record.
