# P0 Card-to-Flow Action Contract Review

Date: 2026-05-15
Owner: CODEX
Scope: Local review only; no tenant access, no card edits, no flow edits
Release decision: NO-SHIP

## 1. Review Basis

Reviewed artifacts:

- `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`
- `.planning/comms/P0_CARD_STATIC_VALIDATION_20260514.md`
- `.planning/comms/p0_flow_artifacts_20260514/flow_pseudocode_definitions.json`
- `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`
- `deploy/cards/ResumoExecutivoPortfolio.json`
- `deploy/cards/AtualizarStatusCard.json`
- `deploy/cards/AtualizarStatusSingleBoxReviewCard.json`
- `deploy/cards/ListarTarefasProjetoCard.json`
- `deploy/cards/CriarTarefaCard.json`
- `deploy/cards/AtualizarTarefaCard.json`

This review compares Adaptive Card `Action.Submit.data` contracts and input IDs against the local flow pseudocode expectations. No tenant writes, Planner writes, SharePoint writes, Teams posts, flow saves, imports, or Copilot changes were performed.

## 2. BLOCK Findings

| ID | Area | Evidence | Impact | Required correction |
|---|---|---|---|---|
| BLOCK-01 | Status update action identity | `AtualizarStatusCard.json` submits `action=submitStatusUpdate`; `AtualizarStatusSingleBoxReviewCard.json` submits `action=confirmStatusUpdate`, `submitStatusUpdate`, and `cancelStatusUpdate`. Pseudocode for `PMO_PA_Card_AtualizarStatus` declares trigger operation IDs `statusUpdateRequested` and `confirmStatusUpdate`. | The first structured status submit has no matching pseudocode operation ID unless Gemini/PA explicitly maps `submitStatusUpdate` to `statusUpdateRequested`. This is ambiguous and fails the route/contract gate. | Gemini/PA should add an explicit branch for `submitStatusUpdate` or change the planned operation ID map so card action values are canonical. |
| BLOCK-02 | Status update field names | `AtualizarStatusCard.json` input IDs are `statusRAG`, `percentual`, `resumo`, `risco`, `bloqueio`, `proximaAcao`. Pseudocode trigger inputs are `projectId`, `projectName`, `rag`, `percent`, `summary`, `risk`, `blocker`. | The flow cannot consume the submit payload deterministically without a mapper. Field name drift can drop or misread PM status, percent, risk, and blocker values. | Gemini/PA should define a canonical mapping or align card input IDs to pseudocode inputs before import. |
| BLOCK-03 | Create task field names | `CriarTarefaCard.json` input IDs are `taskTitle`, `taskDescription`, `responsibleUpn`, `dueDate`, `priority`, `plannerBucketName`, `estimatedHours`; submit data includes `action=submitCreateTask` and `projectId`. Pseudocode expects `projectId`, `title`, `responsible`, `dueDate`, `priority`. | Required create-task values `title` and `responsible` are not present under the expected names. A flow built directly from pseudocode would fail validation or create incomplete rows. | Gemini/PA should map `taskTitle -> title` and `responsibleUpn -> responsible`, and decide whether `taskDescription`, `plannerBucketName`, and `estimatedHours` are supported or ignored. |
| BLOCK-04 | Update task field names | `AtualizarTarefaCard.json` input IDs are `taskStatus`, `actualHours`, `responsibleUpn`, `dueDate`, `priority`, `taskTitle`, `updateNotes`; submit data includes `taskId` and `plannerTaskId`. Pseudocode expects `taskId`, `status`, `hours`, `responsible`, `priority`, `dueDate`. | Required update-task values are submitted under different names. A direct flow implementation would not reliably update status, hours, or responsible. | Gemini/PA should map `taskStatus -> status`, `actualHours -> hours`, and `responsibleUpn -> responsible`, or align the card IDs. |
| BLOCK-05 | Task status value mismatch | `AtualizarTarefaCard.json` offers `Cancelada`. Pseudocode maps `Cancelado` to bucket `90TcFTFup0CjiHIdzY4gG5cALWKL` and does not define `Cancelada`. | Cancelled task updates can fail Planner bucket mapping or leave `PlannerSyncStatus` inconsistent. | Gemini/PA should normalize `Cancelada` to `Cancelado` or add `Cancelada` as an accepted status alias. |
| BLOCK-06 | List task quick actions lack pseudocode branches | `ListarTarefasProjetoCard.json` emits `createTaskFromProject`, `editTask`, `markTaskInProgress`, `markTaskDone`, and `requestTaskUpdate`. Local pseudocode defines `taskListRequested`, `submitCreateTask`, and `submitUpdateTask`, but does not define route branches for these list-card action values. | Quick actions can arrive at `task.card.route` without a deterministic flow branch. `markTaskDone` and `markTaskInProgress` are especially risky because they imply writes. | Gemini/PA should define explicit submit-action branches and write authorization behavior for each list-card action, or remove/defer unsupported quick actions before runtime. |

## 3. FLAG Findings

| ID | Area | Evidence | Risk | Required correction or owner decision |
|---|---|---|---|---|
| FLAG-01 | `operationId` ambiguity | All card submit data uses `operationId=${operationId}` as a runtime value. Pseudocode also uses `operationId` to name trigger operations such as `submitCreateTask`, `submitUpdateTask`, and `confirmStatusUpdate`. | The same field name appears to mean both correlation ID and operation selector depending on context. Implementers could route on the wrong field. | Treat card `action` as the route operation selector and `operationId` as correlation ID, or rename one side in the implementation notes. |
| FLAG-02 | Portfolio card action branches are not specified | `ResumoExecutivoPortfolio.json` emits `viewRedProjects`, `viewWithoutUpdate`, `requestPmUpdate`, `viewProjectDetails`, and `refreshPortfolio`. Pseudocode covers card generation for `portfolioSummaryRequested` but not submit branches for these actions. | The card is valid as a static summary, but follow-up buttons are under-specified. | Gemini/PA should define read-only detail/refresh behavior and ensure `requestPmUpdate` does not write without confirmation. |
| FLAG-03 | Planner task ID exposed in update card | `AtualizarTarefaCard.json` displays `Planner task: ${plannerTaskId}` and submits `plannerTaskId` in update and ops actions. Pseudocode for task listing says not to include `PlannerTaskId` or raw errors; update pseudocode uses `PlannerTaskId` internally after reading SharePoint. | Planner IDs are not full raw Planner rows, but exposing connector IDs in a user-facing card increases leakage risk and encourages trusting client-submitted Planner IDs. | Prefer server-side lookup by `taskId`; do not display `plannerTaskId`; ignore any client-submitted `plannerTaskId` unless verified against SharePoint. |
| FLAG-04 | Create task bucket choice exceeds pseudocode create behavior | `CriarTarefaCard.json` includes `plannerBucketName`; pseudocode create flow always resolves `Pendente` bucket for new tasks. | User-selected bucket may be silently ignored or may create an unreviewed Planner routing behavior. | Gemini/PA should either remove/defer bucket selection or document approved bucket mapping for create. |
| FLAG-05 | Card version metadata is consistent but separate from Adaptive Card schema version | All reviewed cards have Adaptive Card `version=1.4` and submit `cardVersion=1.0`. | This is acceptable if intentional, but runtime evidence should distinguish schema version from business contract version. | Keep `cardVersion=1.0` as business contract version and document that `version=1.4` is renderer schema version. |
| FLAG-06 | Client-submitted IDs must not be trusted | Cards submit `projectId`, `taskId`, and in one case `plannerTaskId`. Pseudocode resolves projects/tasks from SharePoint and owner-provided AQ-04 constants. | Submit payload IDs can be stale or tampered with. | Flow should resolve and validate `projectId` and `taskId` against SharePoint before any write; Planner task ID should come from SharePoint, not from card data. |

## 4. PASS Findings

| ID | Area | Evidence | Notes |
|---|---|---|---|
| PASS-01 | Required submit metadata exists | Prior static validation found every `Action.Submit.data` includes `action`, `routeKey`, `operationId`, `cardVersion`, and `source`; local card review confirms the same shape. | Metadata presence passes local static contract shape. |
| PASS-02 | Route keys align with planned route names | Cards use `board.status`, `pm.status.updates`, `task.card.route`, and `pmo.ops`, matching route keys named in flow pseudocode. | Route key vocabulary is consistent. Branch behavior still needs correction for unsupported `action` values. |
| PASS-03 | Core create/update submit action names exist | `CriarTarefaCard.json` uses `action=submitCreateTask`; `AtualizarTarefaCard.json` uses `action=submitUpdateTask`; both names exist in task flow pseudocode operation expectations. | The action identifiers pass; input field names do not. |
| PASS-04 | `projectId` is present where required | Status, task list, create task, update task, portfolio project-detail, and request-PM actions include `projectId` where relevant. | Flow must still validate against SharePoint before writes. |
| PASS-05 | `taskId` is present where required | Task list edit/update-style actions and update-task card submit/cancel/ops actions include `taskId`. | Flow must resolve `taskId` from SharePoint and never use task title as `taskId`, consistent with AQ-04. |
| PASS-06 | Raw row exposure is not inherent in the planned static Copilot responses | Pseudocode returns static Copilot responses and includes rules to avoid raw SharePoint/Planner rows. Card placeholders are summary-oriented, such as `taskRowsSummary`, `attentionProjectsSummary`, and `topBlockersSummary`. | This passes only if Gemini/PA composes bounded summaries and does not bind raw connector outputs directly into placeholders. |

## 5. Per-Card Contract Summary

| Card | Submit actions | Route keys | Contract result |
|---|---|---|---|
| `ResumoExecutivoPortfolio.json` | `viewRedProjects`, `viewWithoutUpdate`, `requestPmUpdate`, `viewProjectDetails`, `refreshPortfolio` | `board.status`, `pm.status.updates` | FLAG: valid metadata, but follow-up branches are not defined in pseudocode. |
| `AtualizarStatusCard.json` | `submitStatusUpdate`, `cancelStatusUpdate` | `pm.status.updates` | BLOCK: action and field names do not fully match status flow pseudocode. |
| `AtualizarStatusSingleBoxReviewCard.json` | `confirmStatusUpdate`, `submitStatusUpdate`, `cancelStatusUpdate` | `pm.status.updates` | BLOCK for edit action ambiguity; PASS for `confirmStatusUpdate` action presence, subject to field mapping. |
| `ListarTarefasProjetoCard.json` | `createTaskFromProject`, `editTask`, `markTaskInProgress`, `markTaskDone`, `requestTaskUpdate` | `task.card.route` | BLOCK: quick actions need explicit pseudocode branches before runtime. |
| `CriarTarefaCard.json` | `submitCreateTask`, `cancelTaskEdit` | `task.card.route` | BLOCK: action exists, but input names differ from pseudocode. |
| `AtualizarTarefaCard.json` | `submitUpdateTask`, `cancelTaskEdit`, `requestTaskUpdate` | `task.card.route`, `pmo.ops` | BLOCK: action exists, but input names/status value differ; FLAG for Planner ID exposure. |

## 6. Raw Data Exposure Assessment

The local pseudocode contains the correct security rule: do not return raw SharePoint or Planner rows to Copilot. The planned Copilot responses are static ASCII messages, which is safe if implemented exactly.

Remaining exposure risks are implementation-dependent:

- Do not bind SharePoint `Get items` arrays directly into `attentionProjectsSummary`, `projectsWithoutUpdateSummary`, `topBlockersSummary`, or `taskRowsSummary`.
- Do not include Planner connector result objects, raw `PlannerTaskId`, raw `PlannerSyncError`, or raw SharePoint item JSON in Copilot responses or Adaptive Card body text.
- Do not trust `plannerTaskId` submitted by `AtualizarTarefaCard.json`; resolve it server-side from SharePoint by `taskId`.
- Keep failure responses sanitized as specified in pseudocode and route detailed evidence only to `pmo.ops`.

## 7. Required Gemini/PA Corrections Before Runtime

1. Define a canonical dispatcher contract: route by `routeKey` plus `action`; use `operationId` only as a correlation ID unless explicitly renamed.
2. Align or map all status field names: `statusRAG`, `percentual`, `resumo`, `risco`, `bloqueio`, `proximaAcao`.
3. Align or map create-task fields: `taskTitle`, `responsibleUpn`, `taskDescription`, `plannerBucketName`, `estimatedHours`.
4. Align or map update-task fields: `taskStatus`, `actualHours`, `responsibleUpn`, `taskTitle`, `updateNotes`.
5. Add explicit branches for list-card quick actions or mark those actions unsupported for P0.
6. Normalize `Cancelada` versus `Cancelado`.
7. Remove or ignore client-submitted `plannerTaskId` and resolve Planner mapping from SharePoint.
8. Prove bounded summary composition before any Copilot or Teams runtime release.

## 8. Verdict

```text
NO-SHIP
```

The cards pass local metadata presence checks, but the submit payload contract is not yet deterministic against the local flow pseudocode. The blocking issues are contract alignment and route branch definition problems, not tenant runtime evidence problems. No Gemini-owned files were edited.
