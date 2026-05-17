# P0 Power Automate Flow Implementation Checklist (Reworked)

Date: 2026-05-15
Owner: GEMINI-PA
Status: READY_FOR_REVIEW
Release Decision: NO-SHIP (pending runtime evidence)

This document provides the definitive local implementation logic for the P0 Power Automate flows, incorporating validated Planner IDs (AQ-04) and identifying SharePoint schema dependencies (AQ-02/AQ-03).

## 1. Global Constraints & Rules

- **ASCII Only:** All app-facing Copilot output must be ASCII-only.
- **Static/Bounded Output:** Copilot responses must be static strings, not raw data dumps.
- **Route Keys:** Use only `board.status`, `pmo.ops`, `pm.status.updates`, `task.card.route`.
- **Planner Writes:** Marked as `BLOCKED_FOR_TENANT_WRITE` until AQ-07/AQ-09 owner approval and runtime evidence.
- **SharePoint Schema:** AQ-03 completed; Planner sync fields now exist in `Tarefas`.
- **No m365 CLI:** Access must follow master runbooks only.

## 2. Canonical Planner Configuration (AQ-04)

| Item | Value |
|---|---|
| Environment | `ColOfertasBrasilPro` |
| Tenant ID | `7808e005-1489-4374-954b-d3b08f193920` |
| Group ID | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| Plan ID | `-1kBj1PLv0qQM-R4PwkqbpcABv_P` |
| Connection | `shared_planner` |

**Bucket IDs:**
- Piloto e Implantacao: `4YAXH7iU9E-6jZE2P1DbG5cAMAzH`
- Testes: `7QYPufh54kum7MP4KUzzAZcAL6Ik`
- Cancelado: `90TcFTFup0CjiHIdzY4gG5cALWKL`
- Concluido: `F2WYUsnXeEue5qlwQuu3GJcAN1Ns`
- Em andamento: `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG`
- Pendente: `HmzyGOgC4k6uOPm_cwG3zZcAGiAG`

## 3. Flow Implementation Details

### 3.1 PMO_PA_Card_ResumoExecutivoPortfolio
- **Trigger:** Copilot Studio Intent.
- **Inputs:** None.
- **Logic:**
    1. Initialize `operationId` (guid), `greenCount`, `yellowCount`, `redCount`.
    2. SP `Get items` on `Projetos` (Filter: `Ativo eq 1 and Deleted eq 0`).
    3. SP `Get items` on `Riscos e Bloqueios` (Filter: `StatusRisco ne 'Resolvido'`).
    4. SP `Get items` on `Decisoes do Board` (Filter: `StatusDecisao eq 'Pendente'`).
    5. Aggregate RAG counts and top 5 project highlights.
    6. **Post Adaptive Card** to `board.status` using `ResumoExecutivoPortfolio.json`.
- **Copilot Response:** `Portfolio summary requested. Review the card sent in Teams.`
- **Route:** `board.status`
- **Failure Handling:** Return `Unable to read the data right now.` to Copilot; alert `pmo.ops`.

### 3.2 PMO_PA_Card_AtualizarStatus
- **Trigger:** Copilot Studio (Single Box) OR Card Submit.
- **Inputs:** `projectId`, `projectName`, `statusRAG`, `percentual`, `resumo`, `risco`, `bloqueio`, `proximaAcao`.
- **Input aliases:** `rag -> statusRAG`, `percent -> percentual`, `summary -> resumo`, `risk -> risco`, `blocker -> bloqueio`.
- **Dispatch:** Use `routeKey + action`. Treat `operationId` as correlation ID only.
- **Logic:**
    1. Resolve Project ID via SP `Get items` (Top 1).
    2. **Branch A (Copilot Trigger):** Post `AtualizarStatusSingleBoxReviewCard.json` to `pm.status.updates`.
    3. **Branch B (Card Submit - confirmStatusUpdate):**
        - SP `Create item` in `Status Diario`.
        - SP `Update item` in `Projetos`.
        - If Risk/Blocker provided: SP `Create item` in `Riscos e Bloqueios`.
        - Update Card to `AtualizarStatusCard.json` (Success confirmation).
- **Copilot Response:** `Status update received. Review the card sent in Teams.`
- **Route:** `pm.status.updates`
- **Failure Handling:** Update card with `Save failed. Review the data.`; log to `pmo.ops`.

### 3.3 PMO_PA_Card_ListarTarefas
- **Trigger:** Copilot Studio.
- **Inputs:** `ProjectName`.
- **Logic:**
    1. Resolve Project ID via SP `Get items`.
    2. SP `Get items` on `Tarefas` (Filter: project match plus open-task status filter, Top 10). Use live `Status` choice mapping from AQ-03 evidence before import.
    3. Handle list-card submit actions explicitly: `createTaskFromProject`, `editTask`, `markTaskInProgress`, `markTaskDone`, and `requestTaskUpdate`.
    3. **Post Adaptive Card** to `task.card.route` using `ListarTarefasProjetoCard.json`.
- **Copilot Response:** `Task list request received. Review the card sent in Teams.`
- **Route:** `task.card.route`
- **Failure Handling:** If project missing: `Project not found.`. Otherwise: `Unable to list tasks right now.`

### 3.4 PMO_PA_Card_CriarTarefa
- **Trigger:** Card Submit (`submitCreateTask`).
- **Inputs:** `projectId`, `taskTitle`, `taskDescription`, `responsibleUpn`, `dueDate`, `priority`, `plannerBucketName`, `estimatedHours`.
- **Input aliases:** `title -> taskTitle`, `responsible -> responsibleUpn`, `description -> taskDescription`, `bucketName -> plannerBucketName`, `hours -> estimatedHours`.
- **Dispatch:** Use `routeKey + action`. Treat `operationId` as correlation ID only.
- **Logic:**
    1. SP `Create item` in `Tarefas`.
    2. **Planner Path (BLOCKED_FOR_TENANT_WRITE):**
        - Verify `groupId`/`planId` constants.
        - Planner `Create a task` in `Pendente` bucket (`HmzyGOgC4k6uOPm_cwG3zZcAGiAG`).
        - SP `Update item` on `Tarefas` with `PlannerTaskId`, `PlannerBucketId`, `PlannerSyncStatus = 'OK'`.
    3. Update Card in Teams with result.
- **Copilot Response:** N/A.
- **Route:** `task.card.route`
- **Failure Handling:** Set `PlannerSyncStatus = 'Erro'`, log sanitized error to `PlannerSyncError`, alert `pmo.ops`.

### 3.5 PMO_PA_Card_AtualizarTarefa
- **Trigger:** Card Submit (`submitUpdateTask`).
- **Inputs:** `projectId`, `taskId`, `taskStatus`, `actualHours`, `responsibleUpn`, `dueDate`, `priority`, `taskTitle`, `updateNotes`.
- **Input aliases:** `status -> taskStatus`, `hours -> actualHours`, `responsible -> responsibleUpn`, `title -> taskTitle`, `notes -> updateNotes`.
- **Dispatch:** Use `routeKey + action`. Treat `operationId` as correlation ID only. Ignore any client-submitted Planner task ID and resolve it server-side from SharePoint by `taskId`.
- **Logic:**
    1. SP `Get item` on `Tarefas` to fetch `PlannerTaskId`.
    2. SP `Update item` in `Tarefas`.
    3. **Planner Path (BLOCKED_FOR_TENANT_WRITE):**
        - If `PlannerTaskId` missing: Search by Title (Planner `ListTasks_V3`, match Title, use ID).
        - Planner `Update task details`.
        - Map `status` to `bucketId` (using AQ-04 mapping).
        - If `taskStatus == 'Concluido'`, set Planner progress to 100%.
        - Map canonical card status values to live SharePoint `Status` choices before SharePoint update.
        - SP `Update item` on `Tarefas` with `PlannerSyncStatus = 'OK'`.
    4. Update Card in Teams with result.
- **Copilot Response:** N/A.
- **Route:** `task.card.route`
- **Failure Handling:** Set `PlannerSyncStatus = 'Erro'`, log sanitized error, alert `pmo.ops`.

## 4. SharePoint `Tarefas` Schema Status (AQ-03 Complete)

| Internal Name | Type | Logic |
|---|---|---|
| `PlannerTaskId` | Text | Store Planner Task ID. |
| `PlannerBucketId` | Text | Store Planner Bucket ID. |
| `PlannerSyncStatus` | Choice | `OK`, `Erro`, `Pendente`, `Ignorado`. |
| `PlannerLastSyncAt` | DateTime | Last sync timestamp. |
| `PlannerSyncError` | Multi-line Text | Sanitized error message. |

## 5. SEV-0 Gate Mapping

| Gate | Status | Evidence/Path |
|---|---|---|
| Static Card Validation | PASS | `.planning/comms/P0_CARD_STATIC_VALIDATION_20260514.md` |
| Flow Artifact Review | READY_FOR_REVIEW | Current document and JSON artifacts. |
| SharePoint AQ-03 Schema | PASS | AQ-03 executed; evidence at `.planning/comms/AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md`. |
| Planner Read Evidence | PASS | AQ-04 owner validation. |
| Planner Write Runtime | PENDING | Blocked on tenant execution. |
| Teams Route Evidence | PENDING | Blocked on runtime smoke. |
| Copilot ASCII Check | PASS | All outputs verified as ASCII. |
| No ContentFiltered | PENDING | Blocked on runtime validation. |

**Final Decision: NO-SHIP**
Reason: Pending final importable flow package, owner-approved save/import, Copilot publish, runtime smoke, Planner write evidence, and XPIA/no ContentFiltered evidence.
