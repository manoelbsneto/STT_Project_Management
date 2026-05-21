# Inventory — Per-Flow Routing vs ADR-M2-001 (Track E.2)

**Agent:** OPUS-2
**Date:** 2026-05-20
**Source artifacts:** `phases/01_discovery/D_flow_definitions/definition_PM0_PA_Card_*.json` + `definition_PM0_PA_OpsFailureHandling.json` (extracted by CODEX-2-SUB-B in Track D batch 3)
**Method:** Static parse of each flow's Logic Apps `definition.json` for hard-coded `groupId` / `channelId` / `recipient` parameters, cross-referenced with ADR-M2-001 routing matrix.

---

## Scope

6 active PM0_PA_* flows in `ColOfertasBrasilPro`:

| # | Flow | Workflow ID | State | Last Modified | AQ-07 graph match |
|---:|---|---|---|---|---|
| 1 | `PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` | Activado | 15/05/2026 19:10 | ✅ |
| 2 | `PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` | Activado | 15/05/2026 19:10 | ✅ |
| 3 | `PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` | Activado | 15/05/2026 19:10 | ✅ |
| 4 | `PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` | Activado | 15/05/2026 19:10 | ✅ |
| 5 | `PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` | Activado | 15/05/2026 22:31 | ✅ |
| 6 | `PM0_PA_OpsFailureHandling` | `9531fbc7-a250-f111-bec7-000d3abc5cc6` | Activado | 15/05/2026 19:10 | ✅ |

---

## Per-Flow Routing Matrix

### 1. `PM0_PA_Card_AtualizarStatus` — operation: AtualizarStatus (write, RAG status)

**Current routing** (from `definition_PM0_PA_Card_AtualizarStatus.json`):

| Action | Type | Hard-coded targets |
|---|---|---|
| `Post_Status_Card` | Teams `PostCardToConversation` | `body/recipient/groupId: 96c5b0c4-46cc-46cd-8695-50451db74994`, `body/recipient/channelId: 19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2`, `location: Channel` |
| `Respond_Success` | Skills `Response` | static result string `"Status update card posted successfully."` |

**ADR-M2-001 expected** for AtualizarStatus:
- DM (`task.card.route`): Confirm + Result → owner UPN
- `pm.status.updates` channel: Result
- `board.status` channel: Result (only if RAG=Vermelho — conditional)
- → 3 separate posts on confirm + 2 posts on result (DM + pm.status.updates), conditional 3rd

**Comparison vs ADR:**

| Route key | Expected | Actual | Match? |
|---|---|---|---|
| `task.card.route` (DM to mbenicios) | required (Confirm + Result cards) | NOT IMPLEMENTED | ❌ DRIFT — P1 |
| `board.status` (channel `4c8fe...`) | conditional (RAG=Vermelho only) | UNCONDITIONALLY POSTS placeholder card | ⚠️ DRIFT — P2 (conditional logic missing; current always posts) |
| `pm.status.updates` (channel `10900a...`) | required on every status change | NOT IMPLEMENTED | ❌ DRIFT — P1 |
| Dual-entry (action=preview vs submit) | required (REQ-M2-07) | trigger schema has `action` field but flow has no branch logic; always posts | ❌ DRIFT — P0 |
| Card content | richly populated AdaptiveCard | placeholder static `"Status update requested"` (~125 chars) | ❌ DRIFT — P0 (card body is a stub) |

**Severity assessment:** Significant drift. Current flow is an AQ-07 scaffold, not the M2 hybrid implementation. Refactor estimate (per Track D Batch 3 PM0_REFACTOR_ANALYSIS.md): **LARGE (6h+)**.

---

### 2. `PM0_PA_Card_AtualizarTarefa` — operation: AtualizarTarefa (write, task fields)

**Current routing** (from `definition_PM0_PA_Card_AtualizarTarefa.json`):

| Action | Type | Hard-coded targets |
|---|---|---|
| `Get_SharePoint_Item` | SharePoint `GetItem` | `dataset: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`, `table: Tarefas` |
| `Determine_Bucket_and_Percent` | Compose | maps Status → bucket+percent (matches REQ-M2-10) |
| `Update_Planner_Task` | Planner `UpdateTask_V2` | uses `body.PlannerTaskId` from SP (no static IDs) |
| `Update_SharePoint_Item` | SharePoint `PatchItem` | same dataset/table |
| `Respond_Success` | Skills `Response` | static result string `"Task updated successfully."` |

**ADR-M2-001 expected** for AtualizarTarefa:
- DM (`task.card.route`): Confirm + Result → owner
- `pm.status.updates` channel: Result (PM sees status change)

**Comparison vs ADR:**

| Route key | Expected | Actual | Match? |
|---|---|---|---|
| `task.card.route` (DM) | Confirm + Result | NOT IMPLEMENTED — flow does not post anything to Teams | ❌ DRIFT — P0 |
| `pm.status.updates` (channel `10900a...`) | Result on submit | NOT IMPLEMENTED | ❌ DRIFT — P1 |
| Dual-entry | required | trigger has `action` field (required) but no preview/submit branching | ❌ DRIFT — P0 |
| BLK-AT-001 skip semantics | `nao/n/blank/0` preserve existing values + display `(mantido)` (REQ-M2-11) | NOT IMPLEMENTED | ❌ DRIFT — P0 |
| SharePoint write | required | ✅ implemented | ✅ |
| Planner sync | required (Plan `-1kBj1PLv0qQM-R4PwkqbpcABv_P`) | ✅ implemented (uses Get → Update flow with hard-coded bucket map) | ✅ |
| Card payload | confirmation card + result card | NO CARD POSTED — static string only | ❌ DRIFT — P0 |

**Severity:** Card-first routing absent. Backend (SP+Planner) ready. Refactor: **MEDIUM (3-4h)**.

---

### 3. `PM0_PA_Card_CriarTarefa` — operation: CriarTarefa (write, new task)

**Current routing** (from `definition_PM0_PA_Card_CriarTarefa.json`):

| Action | Type | Hard-coded targets |
|---|---|---|
| `Determine_Bucket_and_Status` | Compose | bucket map (matches REQ-M2-10) |
| `Create_Planner_Task` | Planner `CreateTask_V3` | `body/groupId: 96c5b0c4-46cc-46cd-8695-50451db74994`, `body/planId: -1kBj1PLv0qQM-R4PwkqbpcABv_P` |
| `Create_SharePoint_Item` | SharePoint `PostItem` | dataset `Grp_T_DN_Transformacao_Digital`, table `Tarefas` |
| `Respond_Success` | Skills `Response` | static `"Task created successfully."` |

**ADR-M2-001 expected** for CriarTarefa:
- DM (`task.card.route`): Confirm + Result → owner
- `pm.status.updates` channel: Result (PM sees new task assignment)

**Comparison vs ADR:**

| Route key | Expected | Actual | Match? |
|---|---|---|---|
| `task.card.route` (DM) | Confirm + Result | NOT IMPLEMENTED | ❌ DRIFT — P0 |
| `pm.status.updates` channel | Result | NOT IMPLEMENTED | ❌ DRIFT — P1 |
| Dual-entry | required (REQ-M2-07) | NO branch logic | ❌ DRIFT — P0 |
| Idempotency via `operationId` | required (REQ-M2-07) | trigger has no `operationId`; would create duplicates on re-submit | ❌ DRIFT — P0 |
| SP write + Planner write | required | ✅ both implemented; bucket+plan hard-coded per REQ-M2-10 | ✅ |
| Group ID in Planner action | `96c5b0c4-...` (REQ-M2-10) | ✅ matches | ✅ |

**Severity:** Backend pipeline correct. Card-first orchestration entirely missing. Refactor: **MEDIUM (3-4h)**.

---

### 4. `PM0_PA_Card_ListarTarefas` — operation: ListarTarefas (read)

**Current routing** (from `definition_PM0_PA_Card_ListarTarefas.json`):

| Action | Type | Hard-coded targets |
|---|---|---|
| `Get_Tarefas` | SharePoint `GetItems` | dataset `Grp_T_DN_Transformacao_Digital`, table `Tarefas`, `$filter: ProjectID eq '...'` |
| `List_Planner_Tasks` | Planner `ListTasks_V3` | `id: -1kBj1PLv0qQM-R4PwkqbpcABv_P`, `groupId: 96c5b0c4-46cc-46cd-8695-50451db74994` |
| `Normalize_Tasks` | Select | shapes the SP items |
| `Respond_Success` | Skills `Response` | static `"Tasks retrieved successfully."` — **discards** the normalized data |

**ADR-M2-001 expected** for ListarTarefas (read):
- DM (`task.card.route`): Result card

**Comparison vs ADR:**

| Aspect | Expected | Actual | Match? |
|---|---|---|---|
| `task.card.route` DM with result card | required | NOT IMPLEMENTED — discards normalized data, returns static string | ❌ DRIFT — P0 |
| Card body | rich list of up to 10 tasks with inline actions | NONE | ❌ DRIFT — P0 |
| SP read + Planner read | required | ✅ implemented | ✅ |
| Group ID + Plan ID | `96c5b0c4-...` + `-1kBj1PLv0qQM-...` | ✅ matches | ✅ |

**Severity:** Backend reads work. Returned payload is meaningless to a card-first UX. Refactor: **MEDIUM (3-4h)**.

---

### 5. `PM0_PA_Card_ResumoExecutivoPortfolio` — operation: ConsultarPortfolio / Executive summary (read)

**Current routing** (from `definition_PM0_PA_Card_ResumoExecutivoPortfolio.json`):

| Action | Type | Hard-coded targets |
|---|---|---|
| `Get_Projetos` | SharePoint `GetItems` | dataset `Grp_T_DN_Transformacao_Digital`, table `Projetos`, `$top: 100` |
| `Get_Tarefas` | SharePoint `GetItems` | same dataset, table `Tarefas`, `$top: 100` |
| `Respond_Success` | Skills `Response` | static `"Executive portfolio retrieved successfully."` |

**ADR-M2-001 expected** for ConsultarPortfolio:
- DM (`task.card.route`): Result card
- `board.status` channel: Result (only if requester=executive role — conditional)

**Comparison vs ADR:**

| Aspect | Expected | Actual | Match? |
|---|---|---|---|
| `task.card.route` DM with KPI grid | required | NOT IMPLEMENTED | ❌ DRIFT — P0 |
| Conditional `board.status` post (executive role) | conditional | NOT IMPLEMENTED | ❌ DRIFT — P1 |
| KPI aggregation logic | RAG counts, recent updates, etc. | NOT IMPLEMENTED — raw items returned but unused | ❌ DRIFT — P0 |
| SP reads | required | ✅ Projetos + Tarefas read | ✅ |

**Severity:** Reads work, aggregation + cards missing. Refactor: **MEDIUM (3-4h)**.

---

### 6. `PM0_PA_OpsFailureHandling` — operation: universal error handler

**Current routing** (from `definition_PM0_PA_OpsFailureHandling.json`):

| Action | Type | Hard-coded targets |
|---|---|---|
| `Sanitize_Error` | Compose | truncates `details` to 500 chars |
| `Respond_Success` | Skills `Response` | static `"Operation failed securely."` |

**ADR-M2-001 expected** for OpsFailureHandling:
- DM (`task.card.route`): error card to affected user
- `pmo.ops` channel: error card for PMO ops team

**Comparison vs ADR:**

| Aspect | Expected | Actual | Match? |
|---|---|---|---|
| DM error card | required | NOT IMPLEMENTED | ❌ DRIFT — P0 |
| `pmo.ops` channel error card | required | NOT IMPLEMENTED | ❌ DRIFT — P1 |
| Sanitization (no stack traces) | required (REQ-M2-04) | ✅ truncate to 500 chars (basic) | ⚠️ partial — needs stronger redaction |
| Correlation ID in card | required (REQ-M2-04) | NOT IMPLEMENTED — `triggerBody().code` exists but is not echoed | ❌ DRIFT — P1 |

**Severity:** Sanitization stub exists; routing/card absent. Refactor: **MEDIUM (3-4h)**.

---

## Cross-Flow Summary Matrix

| Flow | Teams card post action present? | Group ID hard-coded | Channel ID hard-coded | DM target hard-coded | Dual-entry | ADR-M2-001 fully matches? |
|---|---|---|---|---|---|---|
| PM0_PA_Card_AtualizarStatus | ✅ (1) | ✅ `96c5b0c4-...` | ✅ `19:4c8fe80b...` (board.status) | ❌ | ❌ | ❌ |
| PM0_PA_Card_AtualizarTarefa | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| PM0_PA_Card_CriarTarefa | ❌ | ✅ `96c5b0c4-...` (Planner only) | ❌ | ❌ | ❌ | ❌ |
| PM0_PA_Card_ListarTarefas | ❌ | ✅ `96c5b0c4-...` (Planner only) | ❌ | ❌ | ❌ | ❌ |
| PM0_PA_Card_ResumoExecutivoPortfolio | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| PM0_PA_OpsFailureHandling | ❌ | ❌ | ❌ | ❌ | n/a | ❌ |

**Hard-coded routing IDs found across all 6 active PM0 flows:**
- Group `96c5b0c4-46cc-46cd-8695-50451db74994` (Projetos_Tranformação_Digital): 3 flows
- Channel `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` (Projetos_Tranformação_Digital): 1 flow (`AtualizarStatus`)
- Channel `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` (QA_Projetos): **0 flows** ← matches Track E.1 finding
- DM/Office365Users target (`mbenicios@minsait.com`): **0 flows** ← matches Track E.1 finding
- Plan `-1kBj1PLv0qQM-R4PwkqbpcABv_P`: 2 flows (CriarTarefa, ListarTarefas)
- Bucket IDs (REQ-M2-10): 6 hard-codings each in `AtualizarTarefa` and `CriarTarefa` Compose actions ✅

---

## Discrepancy Severity Roll-up

| Severity | Count | Description |
|---|---:|---|
| **P0** | 14 issues | Card-first orchestration (DM cards, dual-entry, idempotency, card body, BLK-AT-001) entirely missing in 6 of 6 PM0 flows. These are the M2 P0 requirements that must be built in Phase 4 |
| **P1** | 6 issues | Channel-broadcast routing (`pm.status.updates`, `pmo.ops`, conditional `board.status`) entirely missing |
| **P2** | 1 issue | `PM0_PA_Card_AtualizarStatus` always posts placeholder card unconditionally; needs conditional logic per ADR (RAG=Vermelho only for `board.status`) |

**Aggregate PM0 build state vs M2 target:** these are AQ-07 scaffolds with backend SP/Planner pipelines already wired but NO card-first UX. None are M2-ready. Total Phase 4 refactor estimate (per Track D analysis): **22-26 hours** to bring all 6 to M2 spec, plus **+7 new flows** to be created from scratch in M2 Phase 4 (`ConsultarProjeto`, `CriarProjeto`, `ExcluirProjeto`, `ExcluirTarefa`, `PedirDecisao`, `RegistrarBloqueio`, `RegistrarRisco`).

This is consistent with REQ-M2-17: "Refactor 5 + Create 7 + reusable Ops handler = 13 PM0 flows".

---

## Phase 2 Architecture Spec — Recommendations to OPUS-LEAD

1. **Lock the routing matrix** in ADR-M2-001 verbatim — already done, no change needed. This Track E inventory simply confirms the matrix is *aspirational* relative to current PM0 state.
2. **Add design-time activation step** to M2 Phase 4: every PM0 flow's first save must pass design-time channel/group resolution. This catches QA_Projetos channel ID issues automatically.
3. **Adopt a `Determine_Routing` Compose action** at the start of each flow, hard-coding the ADR matrix (per ADR-M2-001 implementation note) rather than scattering channelId / groupId across multiple actions.
4. **`task.card.route` resolution strategy**: ADR uses `mbenicios@minsait.com` for the owner DM. Phase 4 PM0 flows should use the Office365Users connector first (`Get user profile`) → then Teams `PostMessageToUser` rather than hard-coding the UPN twice.
5. **Idempotency contract**: REQ-M2-07 mandates `operationId` (guid) on every trigger. Current 6 PM0 triggers have NO `operationId` field. Phase 2 spec should explicitly require it.

---

## Activity log entries

| Timestamp | Action |
|---|---|
| 2026-05-20T20:13:30-03:00 | OPUS-2 CHECK-IN, locked E_routing_inventory/ + F_topic_yamls/ |
| 2026-05-20T20:14:30-03:00 | Track F complete — 16 YAMLs + INVENTORY_TOPIC_YAMLS.md |
| 2026-05-20T20:18:30-03:00 | Track E.1 complete — channel_validation.json + INVENTORY_CHANNELS.md |
| 2026-05-20T20:22:00-03:00 | Track E.2 complete — INVENTORY_ROUTING_PER_FLOW.md (this file) |

---

*OPUS-2 — 2026-05-20T20:22:00-03:00*
