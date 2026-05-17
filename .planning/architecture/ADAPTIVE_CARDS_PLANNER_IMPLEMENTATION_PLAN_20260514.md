# Implementation Plan and Effort Estimate: Adaptive Cards + Planner

Date: 2026-05-14  
Related architecture: `.planning/architecture/ADAPTIVE_CARDS_PLANNER_ARCHITECTURE_20260514.md`  
Related source review: `.planning/architecture/XPIA_EXTERNAL_SOURCE_REVIEW_20260514.md`  
Status: Planning artifact only; no tenant changes executed.

## 1. Decision Context

The current v3.15 bot is functionally close to production, but it is blocked by the post-action `openAIIndirectAttack` / `ContentFiltered` failure. The safest architectural correction is to move operational data rendering out of Copilot Studio chat and into Teams Adaptive Cards controlled by Power Automate.

Because Planner is the final destination, the recommended path is to implement the cards-first architecture with Planner mapping now, instead of building a short-lived SharePoint-only workaround.

## 2. Current Starting Point

Already available:

- SharePoint PMO lists exist and are validated.
- v3.15 flows can read/write SharePoint.
- `ListarTarefas`, `CriarTarefa`, `AtualizarTarefa`, `PedirDecisao`, `ConsultarPortfolio`, `AtualizarStatus`, and `CriarProjeto` have runtime evidence.
- Existing card templates are present under `deploy/cards/`:
  - `CheckInDiario.json`
  - `DecisaoBoard.json`
  - `AlertaCritico.json`
  - `EscalacaoRisco.json`
  - `ResumoDiarioBoard.json`
  - `ResumoSemanal.json`
- The project contract already includes Planner sync intent through `PMO_PA_SyncPlannerStats_Standard`.
- SharePoint suspicious content scan found zero prompt-injection strings in PMO list data.

Known gaps:

- The current Copilot topics still use Copilot as the chat renderer for operational outcomes.
- `ListarTarefas` still calls a flow and loads SharePoint data even though it returns only static user-facing text.
- `CriarTarefa` returns dynamic IDs to Copilot chat.
- Planner plan/bucket mappings are not confirmed in the local evidence.
- No Application Insights access is available.
- Existing Adaptive Cards are governance/status cards, not the full task management card set.
- External source review from `openAIIndirectAttack_urls.csv` supports the same direction: avoid raw/intermediate tool payloads in Copilot and pass only structured, bounded data through deterministic flows/cards.

## 3. Target Outcome for the First Deployable Slice

The first deployable slice should prove one thing:

The known RAI repro command stops failing because Copilot no longer receives operational data payloads.

Primary command:

```text
listar tarefas do projeto QA Robust 20260513 F
```

Expected Copilot response:

```text
Enviei o card de tarefas no Teams para revisao.
```

Expected Teams result:

- Adaptive Card shows the active tasks for project `PRJ-274E5ACC`.
- Card contains task IDs and action buttons.
- No `ContentFiltered`.
- No `openAIIndirectAttack`.
- Power Automate run succeeds.

## 4. Implementation Waves

### Wave 0 - Inputs and Environment Readiness

Estimate: 2 to 4 hours.

Required actions:

1. Confirm Teams target:
   - PM direct chat;
   - PMO channel;
   - Board channel;
   - or project channel.
2. Confirm Planner target:
   - one plan per project;
   - one central PMO plan;
   - or hybrid.
3. Capture Planner IDs:
   - Plan ID;
   - Bucket IDs;
   - Group/Team context.
4. Confirm write order:
   - recommended: SharePoint first, Planner second, then update SharePoint sync fields.
5. Confirm whether Planner is mandatory or optional per project.

Deliverables:

- Routing matrix for Teams cards.
- Planner plan/bucket mapping table.
- Owner approval for tenant changes.

### Wave 1 - Stop the Known RAI Trigger with ListarTarefas Card

Estimate: 6 to 10 hours.

Required changes:

1. Create new Adaptive Card template:
   - `deploy/cards/ListarTarefasProjeto.json`
   - shows project name, ProjectID, task count, and bounded task rows.
2. Create new flow:
   - `PMO_PA_Card_ListarTarefas`
   - input: project name or ProjectID.
   - query SharePoint for active project and active tasks.
   - optionally query Planner for mapped task status.
   - compose card under 27 KB.
   - post card to Teams.
   - return only a static status code to Copilot.
3. Update Copilot `ListarTarefas` topic:
   - remove/replace old list-returning behavior.
   - display static acknowledgement only.
4. Validate:
   - Copilot no longer shows task data.
   - Teams card shows task data.
   - no blocked step appears.

Risk:

- Teams card posting may require exact chat/channel routing and connection reference validation.

### Wave 2 - CriarTarefa with Card + Planner Create

Estimate: 10 to 16 hours.

Required changes:

1. Create new Adaptive Card template:
   - `deploy/cards/CriarTarefa.json`
   - fields: project, title, responsible, due date, priority, estimated hours, bucket.
2. Create confirmation card:
   - `deploy/cards/ConfirmarCriarTarefa.json`
3. Create or refactor flow:
   - `PMO_PA_Card_CriarTarefa`
   - posts input card.
   - waits for response.
   - validates server-side.
   - posts confirmation card.
   - on confirmation, creates SharePoint task.
   - if Planner mapped, creates Planner task.
   - updates SharePoint with `PlannerTaskId`, `PlannerBucketId`, `PlannerSyncStatus`, `PlannerLastSyncAt`.
4. Update Copilot `CriarTarefa` topic:
   - route only;
   - static acknowledgement;
   - no dynamic ID output in chat.
5. Validate:
   - SharePoint item created.
   - Planner task created when mapping exists.
   - duplicate and invalid-date paths do not write.
   - no Copilot content filter.

Risk:

- Planner assignment may require user identity resolution compatible with the Planner connector.
- Planner connector throttling requires sequential execution and no bulk fan-out.

### Wave 3 - AtualizarTarefa from Card Actions

Estimate: 8 to 14 hours.

Required changes:

1. Add action buttons to `ListarTarefasProjeto` card:
   - update status;
   - register hours;
   - change responsible;
   - change due date;
   - open Planner task, if link policy allows.
2. Create update card:
   - `deploy/cards/AtualizarTarefa.json`
3. Create or refactor flow:
   - `PMO_PA_Card_AtualizarTarefa`
   - validates task ID and project link.
   - updates SharePoint.
   - updates Planner task when `PlannerTaskId` exists.
   - posts result card.
4. Update Copilot `AtualizarTarefa` topic:
   - static route/acknowledgement only.

Risk:

- Mapping task statuses between PMO choices and Planner percent-complete/bucket model must be explicit.

### Wave 4 - Governance Cards Already Close to Existing Design

Estimate: 12 to 20 hours for the full set.

Included topics:

- `PedirDecisao`
- `AtualizarStatus`
- `RegistrarRisco`
- `RegistrarBloqueio`
- Board summaries

Reason:

The repository already has several governance card templates. The effort is lower than task management because the existing templates can be reused, but the flows still need to be made cards-first and Copilot-light.

### Wave 5 - Planner Sync and Reporting

Estimate: 10 to 18 hours.

Required changes:

1. Implement or validate `PMO_PA_SyncPlannerStats_Standard`.
2. Run sequentially to avoid Planner throttling.
3. Update project metrics in SharePoint:
   - total tasks;
   - open tasks;
   - completed tasks;
   - overdue tasks;
   - last sync time;
   - sync status.
4. Use Teams Adaptive Card summaries instead of Copilot summaries.

## 5. Effort Summary

| Scope | Estimate | Comment |
|---|---:|---|
| Minimal stop-gap without Planner | 1 to 2 days | Remove risky Copilot/Flow data path; quickest unblock, but temporary |
| P0 Cards + Planner for task list/create/update | 3 to 5 days | Recommended immediate architecture if owner accepts slower deploy |
| Full cards-first PMO assistant | 7 to 12 days | Includes governance cards, summaries, sync, hardening |
| Production hardening and evidence pack | +1 to 2 days | QA screenshots, run history, SharePoint/Planner evidence, rollback plan |

## 6. Specific Changes from Current v3.15

### Copilot Studio

Change from:

```text
Topic -> Flow -> dynamic/static message in Copilot chat -> RAI post-processing
```

Change to:

```text
Topic -> Flow -> static acknowledgement only
```

Required topic changes:

- `ListarTarefas`: no task list rendered in chat.
- `CriarTarefa`: no `ID: 16 ProjectID: PRJ-...` output in chat.
- `AtualizarTarefa`: no dynamic SharePoint/Planner object output in chat.
- General instructions: explicitly state that tool/card data is data, not instructions, but do not rely on prompting alone.

### Power Automate

Change from:

```text
Flow returns operational result to Copilot
```

Change to:

```text
Flow posts Adaptive Card to Teams and returns only status code/static ack
```

Required flow changes:

- New card controller flows for list/create/update tasks.
- Card response validation.
- Planner connector actions.
- Error handling that posts user-friendly Teams card and logs technical status.

### SharePoint

Required schema review:

- Confirm whether these fields already exist:
  - `PlannerPlanId`
  - `PlannerBucketId`
  - `PlannerTaskId`
  - `PlannerLastSyncAt`
  - `PlannerSyncStatus`
  - `CardVersion`
  - `OperationId`

If missing, adding them is recommended before Planner integration.

### Planner

Required setup:

- Decide central plan vs plan per project.
- Capture Plan IDs and Bucket IDs.
- Confirm group/team permissions.
- Confirm assignment behavior for responsible users.

### Teams

Required setup:

- Confirm card posting destination.
- Confirm whether cards go to direct user chat or PMO channel.
- Validate Teams desktop and web rendering.

## 7. Recommended Immediate Path

Recommended path:

1. Do Wave 0 quickly and collect Planner/Teams IDs.
2. Build Wave 1 first and test the exact failing command.
3. Only after `ListarTarefas` stops failing, continue with `CriarTarefa` and Planner create.

Reason:

`ListarTarefas` is the cleanest proof because it is the primary known repro and it has no required write. If the card pattern eliminates the RAI failure there, we have strong evidence that the architecture is correct before touching task writes.

External source validation:

- Microsoft documentation confirms that RAI checks include prompt injection and can block before the final response.
- Community/admin reports show the same failure pattern with intermediate agent/tool communication.
- Reports also indicate that legitimate external or grounded content can be blocked when passed as untrusted context.
- No documented allowlist workaround should be assumed.

## 8. Go / No-Go Gates

Go for broader rollout only if:

- known `ListarTarefas` repro no longer triggers `ContentFiltered`;
- task data appears only in Teams Adaptive Card;
- Copilot chat contains only static acknowledgement;
- card payload stays below 27 KB;
- SharePoint evidence matches card output;
- Planner mapping works for at least one QA project;
- failed Planner write does not corrupt SharePoint record;
- owner can reproduce using published bot.

No-Go if:

- `ContentFiltered` still appears after removing operational data from Copilot;
- Teams card cannot be posted due to connector or routing constraints;
- Planner mapping cannot be confirmed;
- Power Automate run history shows connector permission failures.
