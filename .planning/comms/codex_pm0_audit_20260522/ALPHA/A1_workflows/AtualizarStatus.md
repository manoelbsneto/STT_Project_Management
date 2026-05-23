# A1 Workflow Audit: AtualizarStatus

## Scope

- Workflow file: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarStatus-1721e0a3-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Trigger evidence: `workflow.json:30-56`
- Action evidence: `workflow.json:58-109`

## Trigger Input Schema

Trigger schema path: `$.properties.definition.triggers.manual.inputs.schema`

| Name | Type | Required | Verbatim JSON path | Evidence |
|---|---|---|---|---|
| `action` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.action` | `workflow.json:38-41`; required list is `workflow.json:51-53` |
| `status` | `string` | false | `$.properties.definition.triggers.manual.inputs.schema.properties.status` | `workflow.json:42-45`; required list is `workflow.json:51-53` |
| `routeKey` | `string` | true | `$.properties.definition.triggers.manual.inputs.schema.properties.routeKey` | `workflow.json:46-49`; required list is `workflow.json:51-53` |

## Action Chain

Execution order follows each action `runAfter` dependency.

| Order | Action | Type | `connectionName` | `operationId` | Evidence |
|---|---|---|---|---|---|
| 1 | `Post_Status_Card` | `OpenApiConnection` | `shared_teams` | `PostCardToConversation` | `workflow.json:59-80` |
| 2 | `Respond_Success` | `Response` | n/a | n/a | `workflow.json:81-108` |

## SP And Planner Filters Or Parameters

No SharePoint or Planner action exists in this workflow body. The only connector action is the Teams action at `workflow.json:59-80`.

## Response Body

Response body path: `$.properties.definition.actions.Respond_Success.inputs.body`

Verbatim body at `workflow.json:94-96`:

```json
"body": {
  "result": "Status update card posted successfully."
}
```

## SP Or Planner Data Flow Into Response

Result: `false`.

Evidence:

- The action chain contains only Teams `Post_Status_Card` and `Respond_Success`; there is no SharePoint or Planner connector action at `workflow.json:58-109`.
- The response body is the fixed literal string at `workflow.json:94-96`.

## Adaptive Card Posting Analysis

The workflow does post an Adaptive Card through Teams. Its content is static, not derived from trigger input or prior action output. The card JSON is a literal `body/messageBody` string at `workflow.json:63-68`:

```json
"parameters": {
  "poster": "Flow bot",
  "body/messageBody": "{\u0022type\u0022:\u0022AdaptiveCard\u0022,\u0022version\u0022:\u00221.5\u0022,\u0022body\u0022:[{\u0022type\u0022:\u0022TextBlock\u0022,\u0022text\u0022:\u0022Status update requested\u0022,\u0022wrap\u0022:true}]}",
  "body/recipient/channelId": "19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2",
  "location": "Channel",
  "body/recipient/groupId": "96c5b0c4-46cc-46cd-8695-50451db74994"
}
```

## Official Microsoft Learn Response Contract

Microsoft Learn says an agent flow must have the `When an agent calls the flow` trigger and a `Respond to the agent` response action, and that when response actions appear on multiple branches they must expose the same outputs. It also documents outputs as fields added on `Respond to the agent`, with Copilot Studio flow parameters limited to Number, String, and Boolean. For this exported `Request` trigger with `kind: Skills`, this audit checks the exported response action shape at `type: Response`, `kind: Skills`, `inputs.body`, and `inputs.schema`.

- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent`
- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output`
- Accessed: `2026-05-22 15:23:47 -03:00`

## Classification

Classification: `STUB`.

Prompt criteria applied:

- `STUB` means no SharePoint or Planner action at all.
- This workflow has no SharePoint or Planner action at `workflow.json:58-109`.
- The Teams card is static and the response body is a fixed literal at `workflow.json:94-96`.
