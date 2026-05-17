# Full Delivery Plan: PMO Assistant Adaptive Cards + Planner Architecture

Date: 2026-05-14  
Status: Proposed delivery plan; no tenant changes executed by this document  
Priority: P0 release-blocking scope = executive visibility, card-first task management, robust visual/clickable Adaptive Cards  
STT decision: moved to Phase 4 continuous improvement after the full non-STT solution is working

Active coordination file:

```text
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
```

All agents must update that check-in board every 5 minutes while actively working and before/after every file edit.

Mandatory read-before-start protocols:

```text
.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
```

SEV-0 rule for this delivery: CI may be ignored only when explicitly owner-excluded. Every other quality gate is mandatory; missing, failed, stale, unverified, or artifact-mismatched evidence keeps the release decision at `NO-SHIP`.

## 1. Executive Summary

The delivery objective is to restore useful PMO visibility quickly while moving the product to the approved TO-BE architecture:

```text
Copilot Studio = executive/router interface
Power Automate = deterministic controller
Adaptive Cards in Teams = primary operational UI
SharePoint = PMO system of record
Planner = task execution destination
```

The director's immediate problem is that project updates are not visible or reliable enough. Therefore, the delivery plan must not start with the deepest technical refactor. It must first deliver an executive visibility slice that works even before the full Planner/card task architecture is complete.

Priority clarification from owner:

The following three capabilities are all **Priority Zero / release-blocking** for the full non-STT solution:

1. Functional executive visibility.
2. Card-first task management.
3. Robust and consistent Adaptive Card visual design with clickable action options.

They are delivered in sequence because of dependencies, but they are not optional and should not be treated as later enhancements.

## 2. Guiding Decisions

1. Do not throw away existing work.
2. Do not use Copilot chat to render long operational data.
3. Use Copilot for short curated executive answers and routing.
4. Use Teams Adaptive Cards for details, updates, confirmations, and click actions.
5. Keep SharePoint as source of record.
6. Integrate Planner as execution layer after the visibility/update flow is stable.
7. Preserve multiline and single-box input as core features.
8. Move STT to Phase 4 because the director needs visibility before voice innovation.

## 3. Reuse Matrix

| Existing Asset | Reuse Decision | Notes |
|---|---|---|
| SharePoint lists | Reuse | They remain the authoritative PMO data model. |
| ProjectID/TaskID/DecisionID model | Reuse | Required for card actions, Planner mapping, audit, and support. |
| Existing Power Automate validation logic | Reuse/refactor | Move business validation into card/controller flows. |
| Existing Copilot topics | Reuse as routers | Stop using them as data renderers. |
| Existing Adaptive Card templates | Reuse as base | Extend with visual consistency, actions, and versioning. |
| v3.15 runtime evidence | Reuse | Becomes RCA evidence and baseline for regression. |
| `ListarTarefas`/`CriarTarefa` v3.16 mitigation drafts | Reuse selectively | Useful for Track A containment and status-code pattern. |
| Planner Standard connector decision | Reuse | Still valid and aligned with no-premium/no-Graph constraints. |
| Multiline/single-box parsing work | Reuse | Keep as non-STT input mode with review/confirmation. |
| Speech-to-text concept | Preserve | Implement later in Phase 4 after full non-STT solution works. |

## 4. Delivery Tracks

### Track A - Immediate XPIA Containment

Purpose: stop current `ContentFiltered/openAIIndirectAttack` blocker as fast as possible.

Scope:

- `ListarTarefas`: remove risky action path or make it no-SharePoint/no-payload.
- `CriarTarefa`: return status codes only.
- Copilot displays static messages only.
- Validate moderation/orchestration settings but do not rely on them.

Estimate: 0.5 to 1.5 days.

Decision:

Track A can ship as a containment release if it passes, but it is not the final architecture.

### Track B - Full TO-BE Architecture

Purpose: deliver the approved operating model.

Scope:

- executive visibility;
- PM update cards;
- task list cards;
- task create/update with Planner;
- robust adaptive cards;
- multiline/single-box input;
- governed click actions;
- QA/evidence/rollback.

Estimate:

- 6 to 9 working days with focused parallel team;
- 10 to 15 working days with one primary implementer and limited owner availability.

## 5. Phase Plan

### Phase 0 - Governance and Readiness

Goal: lock the plan, avoid uncontrolled tenant changes, and prepare IDs/permissions.

Estimate:

- 0.5 to 1 day with parallel docs/readiness.

Activities:

1. Update project control documents:
   - AS-IS;
   - TO-BE;
   - Change Request;
   - ADR;
   - RCA cross-reference;
   - PRD revision notes;
   - Agent/project contract update;
   - release gate checklist.
2. Confirm Teams routing:
   - PM direct chat or PM channel;
   - Board Status channel;
   - PMO operations channel.
3. Confirm Planner mapping:
   - plan per project vs central PMO plan;
   - bucket IDs;
   - owner/member permissions.
4. Confirm no-premium/no-direct-Graph constraints remain active.

Deliverables:

- approved plan;
- Teams/Planner routing matrix;
- updated governance docs;
- implementation backlog.

Exit gate:

- owner approves Track A + Track B sequencing.

### Phase 1 - P0 Executive Visibility ASAP

Goal: give the director a reliable way to see current project status quickly.

Priority: P0 / release-blocking.

Estimate:

- 1 to 2 days.

Why this is first:

The director does not need every task-management feature first. He needs a reliable executive view now.

Scope:

1. Create or harden executive summary flow:
   - reads SharePoint `Projetos`;
   - reads latest `Status Diario`;
   - reads active risks/blockers;
   - optionally reads Planner metrics if already synced;
   - produces bounded summary.
2. Copilot executive response:
   - short chat response only;
   - no long list;
   - no raw SharePoint/Planner JSON.
3. Teams Adaptive Card:
   - Board summary card;
   - RAG counts;
   - projects without update;
   - red/yellow projects;
   - top blockers;
   - action buttons.
4. SharePoint/Teams tab:
   - direct executive portfolio view remains fallback.

Required card actions:

- View red projects.
- View projects without update.
- Request PM update.
- Open project detail card.
- Send decision request, if needed.

Expected director experience:

```text
Director asks Copilot: "status dos projetos dos meus PMs"
Copilot answers: "Carteira: 24 projetos ativos, 15 verdes, 4 amarelos, 1 vermelho, 4 sem update. Enviei o card executivo no Teams."
Teams card shows details and click actions.
```

Deliverables:

- `ResumoExecutivoPortfolio` card;
- executive summary flow;
- Copilot static/curated response path;
- QA evidence for director scenario.

Exit gate:

- director can see portfolio status in Teams card and get short Copilot summary without `ContentFiltered`.

### Phase 2 - P0 PM Update Flow: Adaptive Card + Multiline Single Box

Goal: make PM status updates reliable and fast through Teams/Copilot without STT dependency.

Priority: P0 / release-blocking because executive visibility depends on PM status updates being current.

Estimate:

- 1.5 to 2.5 days.

Scope:

1. Daily or on-demand check-in card.
2. Single-box multiline update mode:

```text
Projeto: Alpha
RAG: Amarelo
Percentual: 45
Resumo: fornecedor atrasou entrega de ambiente
Risco: atraso no teste integrado
Bloqueio: aguardando acesso
Proxima acao: alinhar com infraestrutura amanha
```

3. Structured card mode:
   - RAG choice;
   - percent number;
   - resumo multiline;
   - risco multiline;
   - bloqueio multiline;
   - próxima ação multiline.
4. Review-before-write:
   - system parses single box;
   - presents review card;
   - PM confirms;
   - only then writes SharePoint.
5. Writes:
   - `Status Diario`;
   - update `Projetos.StatusRAG`;
   - update `Projetos.Percentual`;
   - update `Projetos.UltimaAtualizacao`.

Robustness rules:

- no direct write from free text;
- missing fields highlighted;
- unknown project blocked;
- invalid RAG blocked;
- percent outside 0-100 blocked;
- confirmation required.

Deliverables:

- `AtualizarStatusCard`;
- `AtualizarStatusSingleBoxReviewCard`;
- flow controller for parse/review/write;
- Copilot route with static acknowledgement.

Exit gate:

- PM can update status via Teams card and via Copilot-triggered card.
- Director summary reflects update.

### Phase 3 - P0 Task Management with Planner

Goal: complete task lifecycle with SharePoint + Planner while keeping Copilot out of long payloads.

Priority: P0 / release-blocking for the full non-STT solution.

Estimate:

- 2.5 to 4 days.

Scope:

1. `ListarTarefas` card-first:
   - project task list in Teams card;
   - no long task list in Copilot;
   - bounded rows and pagination if needed.
2. `CriarTarefa` card:
   - project;
   - title;
   - responsible;
   - due date;
   - priority;
   - estimated hours;
   - Planner bucket.
3. `AtualizarTarefa` card:
   - status;
   - hours;
   - responsible;
   - due date;
   - priority.
4. Planner integration:
   - create task when project has valid Planner mapping;
   - update Planner task when `PlannerTaskId` exists;
   - store sync status in SharePoint.
5. Fallback:
   - if Planner fails, SharePoint audit remains;
   - `PlannerSyncStatus=Erro`;
   - PMO receives alert.

Required click actions:

- Create task.
- Update selected task.
- Mark done.
- Move to in progress.
- Request update from responsible.
- Open project card.
- Open Planner task if link policy allows.

Deliverables:

- `ListarTarefasProjetoCard`;
- `CriarTarefaCard`;
- `AtualizarTarefaCard`;
- Planner mapping flow actions;
- status-code-only Copilot topic paths.

Exit gate:

- active task list appears in Teams card;
- task create writes SharePoint and Planner;
- task update syncs SharePoint and Planner;
- no Copilot content filter on known repro.

### Phase 4 - Continuous Improvement: Speech-to-Text

Goal: deliver the disruptive voice feature after the core solution is stable.

Estimate:

- 2 to 4 days for first controlled version after Phase 3;
- longer if tenant-native voice capabilities require additional configuration or licensing validation.

Scope:

1. Voice or recorded text input from Copilot/Teams where available.
2. Transcription becomes text, not direct write.
3. Parser extracts:
   - project;
   - RAG;
   - percent;
   - summary;
   - risk;
   - blocker;
   - next action.
4. Review card appears prefilled.
5. PM confirms before write.

Hard rule:

```text
STT never writes directly.
STT always creates a review card first.
```

Exit gate:

- voice update creates correct review card;
- no direct write from raw transcript;
- SharePoint status updates only after confirmation.

### Phase 5 - P0 Hardening, QA, and Release

Goal: convert delivery into a controlled release with evidence.

Priority: P0 / release-blocking.

Estimate:

- 1 to 2 days.

QA matrix:

- executive query;
- portfolio card;
- PM update via structured card;
- PM update via single-box multiline;
- task list card;
- create task with Planner;
- update task with Planner;
- invalid project;
- invalid UPN;
- invalid date;
- duplicate task/project;
- no content filter;
- Teams desktop/web rendering;
- card size under limit;
- SharePoint/Planner evidence.

Deliverables:

- release readiness checklist;
- screenshots;
- Power Automate run IDs/URLs;
- SharePoint item evidence;
- Planner task evidence;
- rollback plan;
- owner go/no-go.

## 6. P0 Visual and Interaction Standards for Adaptive Cards

Priority: P0 / release-blocking. Robust visual consistency and clickable options are part of the core release, not polish.

All cards must follow a consistent PMO visual system:

1. Header:
   - PMO Assistant title;
   - project or portfolio context;
   - RAG indicator where relevant.
2. Body:
   - compact facts first;
   - details below;
   - avoid long paragraphs;
   - no raw JSON or raw URLs.
3. Actions:
   - primary action first;
   - destructive actions visually separated;
   - confirmation required for writes.
4. Data:
   - include `cardVersion`;
   - include `operationId`;
   - include `projectId`;
   - include `source=AdaptiveCard`.
5. Card size:
   - target under 20 KB;
   - hard guardrail under 27 KB.
6. Clickability:
   - buttons for common actions;
   - links only when policy allows;
   - IDs shown where useful, but not as Copilot chat output.

## 7. Agentic Delivery Plan

This project can be run as an agentic delivery plan, but only with strict ownership boundaries.

Approved staffing for the next execution cycle:

| Role | Suggested Owner | Responsibility |
|---|---|---|
| Delivery Lead / Architect | Codex lead | Architecture, integration decisions, gate control, final review. |
| Principal Deploy Engineer | Gemini 3.1 Pro Preview | Power Automate card/controller flows and Teams routing. |
| Codex Sub-Agent 1 | Documentation / Governance | PRD, AS-IS/TO-BE, CR, ADR, RCA linkage, contract updates. |
| Codex Sub-Agent 2 | SharePoint / Planner Readiness | Schema checks, Planner IDs, bucket mappings, read-only validation. |
| Codex Sub-Agent 3 | QA / Evidence | Test scripts, evidence matrix, screenshots checklist, release gates. |

Note: Copilot Studio topic integration remains under `CODEX-LEAD` unless the owner assigns another deploy engineer. This reduces conflicts because only one external principal engineer is currently allocated.

Parallel workstreams:

| Workstream | Can Run In Parallel? | Notes |
|---|---:|---|
| Governance docs | Yes | No tenant dependency. |
| Teams/Planner inventory | Yes | Readiness only; no writes without owner approval. |
| Card JSON design | Yes | Can be built locally. |
| Flow implementation | Partially | Needs connection/routing decisions. |
| Copilot topic updates | Partially | Should wait for flow contracts. |
| QA evidence | Yes, after each slice | Evidence agent can prepare matrix first. |

Important coordination rule:

Do not allow multiple agents to edit the same solution package or same topic/flow file at the same time. Assign disjoint write scopes.

## 8. Compressed Delivery Estimate with Additional Engineers

Assuming two additional principal deploy engineers and three Codex sub-agents:

| Phase | Calendar Estimate |
|---|---:|
| Phase 0 | 0.5 day |
| Phase 1 - P0 executive visibility | 1 day |
| Phase 2 - P0 PM update cards + multiline single box | 1 to 1.5 days |
| Phase 3 - P0 task management/card-first + Planner | 2 to 3 days |
| Phase 5 hardening | 1 day |

Total for full non-STT solution:

```text
Best case: 4.5 to 5 days
Realistic: 5 to 7 days
Risk-adjusted: 7 to 9 days
```

STT Phase 4:

```text
Add 2 to 4 days after the full non-STT solution is stable.
```

## 9. Critical Path

The fastest path to reduce director frustration:

```text
Phase 0 readiness
-> Phase 1 P0 executive visibility card
-> Phase 2 P0 PM status update cards
-> Director can see updates
-> Phase 3 P0 task/Planner management
-> Phase 5 release hardening
-> Phase 4 STT continuous improvement
```

This means we do not wait for full Planner create/update before giving the director visibility.

Release interpretation:

- The director can start validating visibility after Phase 1 and Phase 2.
- The full non-STT release is not complete until Phase 3 task management/card-first and the P0 card visual/click-action standards are also validated.
- STT remains outside the P0 release gate and moves to continuous improvement.

## 10. Go / No-Go Gates

### Gate 1 - Director Visibility

Go if:

- director receives portfolio summary card;
- Copilot gives short summary;
- no `ContentFiltered`;
- at least one PM update appears in director view.

### Gate 2 - PM Update Reliability

Go if:

- structured card update works;
- single-box multiline update works;
- review-before-write works;
- SharePoint status is updated correctly.

### Gate 3 - Task + Planner

Go if:

- task list card works;
- create task writes SharePoint and Planner;
- update task syncs SharePoint and Planner;
- Planner failure is handled without corrupting SharePoint.

### Gate 4 - Release

Go if:

- all P0/P1 tests pass;
- evidence pack complete;
- rollback plan available;
- owner approves publish/import/deploy steps.

## 11. Recommendation

Proceed with the full non-STT solution using the agentic delivery model.

Do not wait for STT before restoring executive visibility.

Do not start with Planner task management before the director summary and PM update loop are working.

Recommended immediate sequence:

1. Approve this plan.
2. Assign agents by workstream.
3. Complete governance docs and readiness inventory.
4. Build executive visibility first.
5. Build PM update cards with multiline/single-box support.
6. Build task + Planner card flows.
7. Harden and release.
8. Start STT continuous improvement.
