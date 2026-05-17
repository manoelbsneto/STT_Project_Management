# Adaptive Cards + Planner Architecture for PMO Assistant

Date: 2026-05-14  
Status: Proposed for immediate implementation planning  
Scope: Copilot Studio, Power Automate, Microsoft Teams Adaptive Cards, SharePoint PMO lists, Microsoft Planner

## 1. Executive Summary

The recommended architecture is a cards-first architecture:

```text
User -> Copilot Studio thin router -> Power Automate controller
     -> Teams Adaptive Card interaction
     -> SharePoint PMO system of record
     -> Planner task execution layer
```

The key change is not just "use Adaptive Cards". The key change is to stop returning large SharePoint, Planner, or Flow payloads into Copilot Studio chat where the LLM and Responsible AI layer can reinterpret tool output as instructions.

Adaptive Cards reduce the openAIIndirectAttack risk only when they are used as deterministic UI and structured input/output. If a Flow still returns a large JSON object or long dynamic text to Copilot Studio, the risk remains.

## 2. Current Problem to Solve

Observed runtime pattern in release 3.15:

1. User sends a normal PMO command in Copilot Studio.
2. Topic/action runs successfully.
3. Power Automate and/or SharePoint operation succeeds.
4. Copilot Studio later appends a blocked step:
   - `Etapa Bloqueada`
   - `openAIIndirectAttack`
   - `ContentFiltered`
5. User sees a false failure after a successful operation.

This was reproduced especially with:

```text
listar tarefas do projeto QA Robust 20260513 F
```

The SharePoint suspicious-content scan did not find prompt-injection strings in the current PMO lists. This lowers the likelihood that a specific SharePoint row is malicious and raises the likelihood that the trigger is the Copilot/Flow runtime path: tool call, returned data shape, orchestration, or post-action processing.

## 3. Architecture Principle

Copilot Studio should not be the renderer for operational data.

Copilot Studio should:

- route intent;
- collect the minimum command context;
- trigger a Power Automate controller;
- return only static, bounded acknowledgements;
- never receive full SharePoint or Planner result sets;
- never summarize raw tool output.

Power Automate should:

- own all business validation;
- query SharePoint and Planner;
- compose Adaptive Cards;
- post cards to Teams;
- wait for card responses where needed;
- write SharePoint and Planner records;
- maintain audit/correlation state.

Teams Adaptive Cards should:

- display structured, bounded operational data;
- collect typed inputs using fields, choices, buttons, and confirmation actions;
- avoid long free-text output and raw JSON;
- include `cardVersion`, `operationId`, `projectId`, and action metadata.

SharePoint should:

- remain the PMO system of record;
- keep audit fields and logical delete;
- store Planner mapping fields such as `PlannerPlanId`, `PlannerBucketId`, `PlannerTaskId`, `PlannerLastSyncAt`, and `PlannerSyncStatus` where applicable.

Planner should:

- become the execution/task destination for operational tasks;
- be synchronized from controlled Power Automate flows;
- not be queried by Copilot Studio directly.

## 4. Proposed Runtime Model

### 4.1 Conversational Entry

User says:

```text
listar tarefas do projeto QA Robust 20260513 F
```

Copilot Studio does not call a list-returning Flow that sends data back to chat. Instead:

1. Topic resolves only the project name or ProjectID.
2. Topic calls `PMO_PA_Card_ListarTarefas`.
3. Flow queries SharePoint and Planner.
4. Flow posts a Teams Adaptive Card to the requester or PMO channel.
5. Copilot returns only:

```text
Enviei o card de tarefas no Teams para revisao.
```

No task list, no raw JSON, no SharePoint links, no Planner payload returns to Copilot.

### 4.2 Card-Based Write

User says:

```text
criar tarefa
```

Recommended flow:

1. Copilot routes to `CriarTarefa`.
2. Copilot starts `PMO_PA_Card_CriarTarefa`.
3. Flow posts an Adaptive Card with fields:
   - projeto;
   - titulo;
   - responsavel;
   - prazo;
   - prioridade;
   - horas;
   - bucket Planner, if applicable.
4. User submits the card.
5. Flow validates server-side:
   - project exists;
   - project active;
   - user allowed;
   - UPN valid;
   - date valid;
   - priority allowed;
   - duplicate task check.
6. Flow posts a confirmation card.
7. On confirmation, Flow writes:
   - SharePoint `Tarefas`;
   - Planner task, when `PlannerPlanId` exists;
   - SharePoint fields updated with `PlannerTaskId` and sync status.
8. Flow posts result card.
9. Copilot receives no long result.

## 5. Planner Destination Design

Planner can be integrated immediately if the target uses basic Microsoft Planner plans supported by the Power Automate Planner connector.

Planner should not replace SharePoint as the PMO system of record at once. Recommended source-of-truth split:

| Domain | System of record | Reason |
|---|---|---|
| PMO metadata | SharePoint `Projetos` | Existing schema, RAG, PMO audit, dashboard fields |
| PMO task metadata | SharePoint `Tarefas` | Existing IDs, logical delete, PMO-specific fields |
| Execution task | Planner task | Native task board, assignments, due dates, progress |
| Status/history | SharePoint `Status Diario` | PMO timeline and reporting |
| Decisions | SharePoint `Decisoes do Board` | Approval trace and governance |

Recommended mapping:

| SharePoint field | Planner field |
|---|---|
| `ProjectID` | Plan mapping stored in `Projetos.PlannerPlanId` |
| `Title` / task title | Planner task title |
| `Responsavel` | Planner assignments |
| `DataFim` | Planner due date |
| `Status` | Planner percent complete or local mapping |
| `Prioridade` | Planner priority, if available in connector action; otherwise SharePoint-only |
| `HorasEstimadas`, `HorasRealizadas` | SharePoint-only unless mapped to details/notes |
| `PlannerTaskId` | Planner task id returned after create |
| `PlannerBucketId` | Planner bucket used for the task |

## 6. Flow Set for Immediate Architecture

### P0 - Stop the Current RAI Trigger

1. `PMO_PA_Card_ListarTarefas`
   - Trigger: Copilot or manual Teams command.
   - Input: project name or ProjectID.
   - Query: SharePoint `Projetos`, `Tarefas`; Planner only if mapped.
   - Output: Teams Adaptive Card only.
   - Copilot return: static acknowledgement only.

2. `PMO_PA_Card_CriarTarefa`
   - Trigger: Copilot.
   - Output: Teams Adaptive Card with input fields.
   - Write: SharePoint first, Planner second, then update SharePoint with Planner IDs.
   - Copilot return: static acknowledgement only.

3. `PMO_PA_Card_AtualizarTarefa`
   - Trigger: card action from task list card or Copilot.
   - Input: task ID, status, hours, responsible, due date, priority.
   - Write: SharePoint update; Planner update if mapped.
   - Copilot return: none or static acknowledgement.

### P1 - Governance Cards

4. `PMO_PA_Card_PedirDecisao`
   - Uses existing `Decisoes do Board`.
   - Card to approver.
   - Response updates decision row.

5. `PMO_PA_Card_AtualizarStatus`
   - Check-in card for RAG, summary, risk, blocker, next action, percent.
   - Updates `Status Diario` and `Projetos`.

### P2 - Scheduled Operations

6. `PMO_PA_SyncPlannerStats_Standard`
   - Already appears in the project contract.
   - Runs sequentially to avoid Planner throttling.
   - Updates SharePoint metrics only.

7. `PMO_PA_Card_ResumoDiarioBoard`
   - Posts board summary to Teams, not Copilot chat.

## 7. Data Contract Rules

Every Adaptive Card payload must follow these rules:

- Include `cardVersion`.
- Include `operationId`.
- Include `projectId` when project-scoped.
- Include only required fields.
- Use choices for enums.
- Use dates in ISO internally and `dd/MM/yyyy` only for display.
- Do not include raw SharePoint item JSON.
- Do not include raw Planner task JSON.
- Do not include hidden prompts, comments, HTML, script tags, or URLs unless explicitly required.
- Use IDs rather than links when possible.
- Keep card body under the project guardrail of 27 KB.

## 8. Prompt-Injection Risk Position

Adaptive Cards are native Microsoft UI artifacts, but they do not automatically eliminate prompt-injection risk.

They reduce the risk when:

- data is displayed as UI, not passed to the LLM;
- `Action.Submit` data is parsed by Power Automate, not interpreted by a model;
- user-entered text is stored/displayed as data only;
- Copilot receives only static status messages;
- large result sets are paginated or linked through Teams/SharePoint UI instead of summarized by Copilot.

Risk remains if:

- card inputs are sent back to Copilot for summarization;
- Power Automate returns full JSON to Copilot;
- Planner descriptions or SharePoint fields are concatenated into a Copilot response;
- one agent calls another and passes raw card/result payloads;
- card text includes arbitrary external content and is later used as prompt context.

## 9. Immediate Deployment Decision

Recommended decision:

Proceed with an immediate P0 implementation, but do not try to convert every topic at once.

Immediate target:

1. Replace `ListarTarefas` conversational output with Teams Adaptive Card output.
2. Add Planner mapping to task create/update only when the project has a known `PlannerPlanId`.
3. Keep SharePoint as source of record.
4. Keep Copilot response static.
5. Validate that `openAIIndirectAttack` stops on the known repro command before expanding.

This is slower than a local workaround, but it attacks the real architecture problem.

## 10. Required Owner Inputs Before Tenant Deployment

The following values are required to deploy a working Planner/Card path:

- Target Team ID or Teams channel/chat routing policy.
- PMO Board channel ID, if cards are posted to a channel.
- User routing rule for PM cards: direct chat, PMO channel, or project channel.
- Planner Plan ID per active project, or a rule to create/use a default PMO plan.
- Planner Bucket ID mapping:
  - Backlog / Pendente;
  - Em Andamento;
  - Concluida;
  - Bloqueada, if used.
- Confirmation whether Planner task creation should happen for all tasks or only selected projects.
- Confirmation whether SharePoint write happens before Planner write or only after Planner success.

Recommended default:

SharePoint write first, Planner write second, then update SharePoint with Planner sync status. This avoids losing PMO audit if Planner fails.

## 11. Quality Gates

Minimum gates for P0:

1. Known repro command no longer returns `ContentFiltered`.
2. Copilot topic returns only static acknowledgement.
3. Teams card renders in desktop and web.
4. Card payload is under 27 KB.
5. SharePoint validation confirms no duplicate write.
6. Planner task is created only when project has valid plan mapping.
7. Planner failure records `PlannerSyncStatus=Erro` without rolling back SharePoint audit.
8. No raw SharePoint/Planner JSON appears in Copilot chat.
9. Power Automate run history shows success.
10. User can update a task from card action without calling Copilot summarization.

## 12. Recommended Test Commands After Deployment

Primary RAI repro:

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected Copilot response:

```text
Enviei o card de tarefas no Teams para revisao.
```

Expected Teams result:

- Adaptive Card lists active tasks 14, 15, and 16 for project `PRJ-274E5ACC`.
- Card includes update actions.
- No `openAIIndirectAttack`.

Create task with Planner:

```text
criar tarefa
```

Expected:

- Copilot opens or triggers task input card.
- User submits project, title, responsible, due date, priority, hours.
- Flow creates SharePoint task.
- If project has Planner mapping, Flow creates Planner task and stores `PlannerTaskId`.
- Result is shown in Teams card, not as long Copilot text.

Update task:

```text
atualizar tarefa
```

Expected:

- Card prompts for task ID and changed fields.
- Flow updates SharePoint and Planner when mapped.
- Copilot static acknowledgement only.

## 13. Official References Used

- Microsoft Power Automate Adaptive Cards documentation: https://learn.microsoft.com/en-us/power-automate/create-adaptive-cards
- Microsoft Planner connector reference: https://learn.microsoft.com/en-us/connectors/planner/
- Microsoft Graph Planner API overview: https://learn.microsoft.com/en-us/graph/api/resources/planner-overview
- Microsoft Teams Adaptive Cards platform documentation: https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-reference
- Adaptive Cards schema explorer: https://adaptivecards.io/explorer/

