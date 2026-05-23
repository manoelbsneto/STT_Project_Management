# A1 Workflow Audit Table

## Scope And Criteria

Audited workflow bodies:

| Flow | Workflow file |
|---|---|
| `AtualizarStatus` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarStatus-1721e0a3-a250-f111-bec7-000d3abc5cc6/workflow.json` |
| `AtualizarTarefa` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarTarefa-7c6300c2-a250-f111-bec7-000d3abc5cc6/workflow.json` |
| `ResumoExecutivoPortfolio` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333bd91-a250-f111-bec7-000d3abc5cc6/workflow.json` |
| `CriarTarefa` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_CriarTarefa-7f662db7-a250-f111-bec7-000d3abc5cc6/workflow.json` |
| `ListarTarefas` | `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json` |

Prompt classification criteria used:

| Classification | Criterion |
|---|---|
| `STUB` | No SharePoint or Planner action at all. |
| `PARTIAL` | SharePoint or Planner actions exist but the response body does not reflect their output. |
| `REAL` | Full pipeline including dynamic response body. |

## Consolidated Findings

| Flow | Required trigger inputs | SP or Planner actions | Response body evidence | SP or Planner data in response | Card posting analysis | Classification |
|---|---|---|---|---|---|---|
| `AtualizarStatus` | `routeKey` at `workflow.json:51-53` | None; Teams only at `workflow.json:59-80` | Fixed result at `workflow.json:94-96` | `false` | Teams Adaptive Card post is present and static at `workflow.json:63-68` | `STUB` |
| `AtualizarTarefa` | `action` at `workflow.json:75-77` | SharePoint `GetItem` and `PatchItem`; Planner `UpdateTask_V2` at `workflow.json:83-105`, `workflow.json:115-145`, `workflow.json:174-193` | Fixed result at `workflow.json:159-161` | `false` | No card post action in `workflow.json:82-194` | `PARTIAL` |
| `ResumoExecutivoPortfolio` | None; empty required array at `workflow.json:32-36` | SharePoint `GetItems` at `workflow.json:41-60` and `workflow.json:89-112` | Fixed result at `workflow.json:74-76` | `false` | No card post action in `workflow.json:40-113` | `PARTIAL` |
| `CriarTarefa` | `projectId`, `action` at `workflow.json:87-90` | Planner `CreateTask_V3`; SharePoint `PostItem` at `workflow.json:96-119` and `workflow.json:125-155` | Fixed result at `workflow.json:169-171` | `false` | No card post action in `workflow.json:95-184` | `PARTIAL` |
| `ListarTarefas` | `action`, `projectId` at `workflow.json:56-59` | SharePoint `GetItems`; Planner `ListTasks_V3` at `workflow.json:65-87` and `workflow.json:137-157` | Fixed result at `workflow.json:101-103` | `false` | No card post action in `workflow.json:64-158` | `PARTIAL` |

## Counts

| Classification | Count |
|---|---:|
| `STUB` | 1 |
| `PARTIAL` | 4 |
| `REAL` | 0 |

## Response Contract Citation

Microsoft Learn says an agent flow must have the `When an agent calls the flow` trigger and a `Respond to the agent` response action, and that when response actions appear on multiple branches they must expose the same outputs. It also documents outputs as fields added on `Respond to the agent`, with Copilot Studio flow parameters limited to Number, String, and Boolean. For these exported `Request` triggers with `kind: Skills`, the per-flow audits check the exported response action shape at `type: Response`, `kind: Skills`, `inputs.body`, and `inputs.schema`.

- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent`
- Citation URL: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output`
- Accessed: `2026-05-22 15:23:47 -03:00`
