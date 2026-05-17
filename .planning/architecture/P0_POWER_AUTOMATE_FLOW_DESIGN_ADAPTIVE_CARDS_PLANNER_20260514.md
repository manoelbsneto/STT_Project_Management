# P0 Power Automate Flow Design: Adaptive Cards + Planner

Date: 2026-05-14  
Owner: GEMINI-PA  
Status: CODEX-LEAD REVIEWED / NEEDS LOCAL IMPLEMENTATION ARTIFACTS  
Scope: Local programmatic flow design using route keys and placeholders. No tenant changes executed.

## 1. Overview

This document defines the architectural design for the 5 core P0 Power Automate flows required for the card-first, non-STT implementation. All flows use Adaptive Cards as the primary UI, keeping Copilot's response payload small and bounded.

### Common Flow Design Rules
- **Triggers**: Most are triggered by Copilot Studio (HTTP/Skill or native integration). Card action routes are triggered by Teams HTTP submissions.
- **Routing**: Use owner-approved route keys. Do not hard-code IDs inside cards; resolve route keys in flow configuration.
- **Data Source**: SharePoint is the system of record. Planner is downstream.
- **Copilot Output**: Return only static text (e.g., "Enviei o card no Teams"). Do not return raw JSON or long lists.
- **Correlation**: Generate an `operationId` (guid) at the start of each flow run for tracking.
- **Access Protocol**: Any tenant/runtime discovery must follow `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`. Do not use Microsoft 365 CLI / `m365` for discovery.

### Owner-Approved P0 Route Keys

| Route Key | Target | Notes |
|---|---|---|
| `board.status` | Teams channel `Projetos_Tranformação_Digital` | Executive portfolio and Board cards. |
| `pmo.ops` | Teams channel `Projetos_Tranformação_Digital` | Operational alerts and Planner sync errors for P0. |
| `pm.status.updates` | Teams channel `QA_Projetos` | PM status update cards and review-before-write for P0. |
| `task.card.route` | Direct chat `mbenicios@minsait.com` | Task list/create/update cards for P0. |

---

## 2. PMO_PA_Card_ResumoExecutivoPortfolio

**Objective**: Provide an executive summary of the portfolio via Teams Adaptive Card.
**Trigger**: Copilot Studio (intent: portfolio status).

**Actions**:
1. **Initialize**: Generate `operationId`.
2. **Read SharePoint Data**:
   - `Get items` from `Projetos` where `Ativo eq 1 and Deleted eq 0`.
   - `Get items` from `Riscos e Bloqueios` where `StatusRisco ne 'Resolvido'`.
   - `Get items` from `Decisoes do Board` where `StatusDecisao eq 'Pendente'`.
3. **Data Processing**:
   - Calculate `totalActiveProjects`, `greenCount`, `yellowCount`, `redCount`.
   - Identify projects without recent updates.
4. **Card Rendering**:
   - Compose JSON payload based on `ResumoExecutivoPortfolio.json` schema.
   - Include `operationId` and `source=AdaptiveCard`.
5. **Route/Post**:
   - Post Adaptive Card to Teams using route key: `board.status`.
6. **Copilot Response**:
   - Return static text to Copilot: "Carteira analisada. Enviei o card executivo no Teams para acompanhamento."

---

## 3. PMO_PA_Card_AtualizarStatus

**Objective**: Safe status update flow with review-before-write validation.
**Trigger**: Copilot Studio or Adaptive Card Submit action.

**Actions**:
1. **Branch A (Triggered from Copilot with free text/single box)**:
   - Parse multiline input (Project Name, RAG, % Complete, Summary, Risk, Blocker).
   - Resolve Project against `Projetos` list.
   - Post `AtualizarStatusSingleBoxReviewCard` to route `pm.status.updates` (`QA_Projetos`) for P0.
   - Return static ack to Copilot.
2. **Branch B (Triggered by Card Submit - confirmStatusUpdate)**:
   - Validate payload fields (RAG valid, % between 0-100).
   - Write to `Status Diario`.
   - Update `Projetos` (`StatusRAG`, `Percentual`, `UltimaAtualizacao`).
   - If a risk or blocker is provided, create items in `Riscos e Bloqueios`.
   - Update card in Teams to show success confirmation.

---

## 4. PMO_PA_Card_ListarTarefas

**Objective**: Display active tasks for a specific project.
**Trigger**: Copilot Studio.

**Actions**:
1. **Resolve Project**: Search `Projetos` by name. If not found, return short error to Copilot.
2. **Read Tasks**: `Get items` from `Tarefas` where `ProjectID eq '{Id}' and Status ne 'Concluida' and Deleted eq 0`.
3. **Pagination/Bounding**: Limit to top 10 rows.
4. **Card Rendering**:
   - Compose `ListarTarefasProjetoCard.json`.
   - Include action buttons for "Edit Task", "Mark Done".
5. **Route/Post**:
   - Post card to `task.card.route` (direct chat to `mbenicios@minsait.com`) for P0.
6. **Copilot Response**:
   - Return static text: "Encontrei as tarefas. Enviei a lista em formato de card no seu Teams."

---

## 5. PMO_PA_Card_CriarTarefa

**Objective**: Create task in SharePoint and conditionally sync to Planner.
**Trigger**: Adaptive Card Submit (`submitCreateTask`).

**Actions**:
1. **SharePoint First**:
   - Validate input (due date format, valid UPN for assignees).
   - Create item in `Tarefas` (Status: Pendente).
2. **Planner Check**:
   - Check if `Projetos` has `PlannerGroupId` and `PlannerPlanId`.
   - **If Yes**:
     - Attempt Planner "Create a task" (Standard Connector).
     - Bucket assignment (see strategy below).
     - Update `Tarefas` item with `PlannerTaskId`, `PlannerBucketId`, and `PlannerSyncStatus = 'OK'`.
   - **If Planner Fails**:
     - Catch error.
     - Update `Tarefas` item with `PlannerSyncStatus = 'Erro'`.
     - Alert PMO via `pmo.ops` route.
3. **User Feedback**: Update Teams card to reflect success or partial success (SP only).

---

## 6. PMO_PA_Card_AtualizarTarefa

**Objective**: Update task details and sync state.
**Trigger**: Adaptive Card Submit (`submitUpdateTask`).

**Actions**:
1. **SharePoint Update**:
   - Update `Tarefas` item (Status, Due Date, Assignee, Hours).
2. **Planner Sync**:
   - Check if `PlannerTaskId` exists on the SharePoint item.
   - **If Yes**:
     - Attempt Planner "Update a task" and/or "Update task details".
     - If status changed to `Concluida`, update Planner progress to 100%.
     - Handle errors by updating `PlannerSyncStatus = 'Erro'` in SP.
3. **User Feedback**: Update card in Teams to confirm changes.

---

## 7. Planner Bucket Discovery Strategy

Because we are barred from using Premium, direct Graph API connectors, and Microsoft 365 CLI / `m365` discovery for this project, and bucket IDs are not currently known/mapped in the project schema, we will use the following discovery pattern:

**Discovery Flow (Run Once / On-Demand):**
1. Trigger: Manual or PMO invocation.
2. Inputs: `PlannerGroupId` and `PlannerPlanId`.
3. Action: Planner Standard Connector -> "List buckets".
4. Output: Render the array of bucket Names and IDs to a Teams card sent to `pmo.ops`.
5. The PMO team can then take these IDs and store them in the `Projetos` configuration or standard lookup list.
6. This discovery must be read-only and must be executed only after owner approval using the project master runbook.

**Inline Mapping (Fallback inside CreateTask):**
If a specific bucket mapping isn't provided:
1. `List buckets` for the plan.
2. Filter array for bucket name matching 'Pendente' or 'To Do'.
3. Extract the first matched ID and use it for task creation.

---

## 8. Remaining Blockers for Runtime Execution
- **Planner bucket IDs**: Bucket names are owner-confirmed, but IDs still need read-only discovery through the master runbook. Do not use `m365`.
- **Planner plan validation**: Owner provided a Planner URL and plan ID candidate `-1kBj1PLv0qQM-R4PwkqbpcABv_P`; final validation still required through approved runbook/runtime evidence.
- **Schema**: `Tarefas` list lacks Planner mapping fields (`PlannerTaskId`, `PlannerSyncStatus`, etc.). Owner approved the schema direction, but actual tenant schema update still requires explicit execution approval.
- **Runtime evidence**: Direct chat route for task cards and QA_Projetos route for PM update cards must be validated after implementation.

## 9. CODEX-LEAD Review Notes

The design is accepted as a local flow blueprint after route correction. It is not yet a deployable artifact because the actual flow definition JSON, connection references, card templates, and schema update script are still required.

Fastest implementation order:

1. Build Adaptive Card JSON templates.
2. Build flow definitions with route-key resolution and static Copilot outputs.
3. Add SharePoint `Tarefas` Planner mapping fields through owner-approved runbook.
4. Run read-only Planner bucket discovery through approved master access path.
5. Import/update flows only after owner approval.
6. Publish bot only after owner approval.
7. Capture runtime evidence with the P0 smoke commands.
