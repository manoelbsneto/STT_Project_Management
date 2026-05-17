# Change Request: Card-First Adaptive Cards + Planner P0

CR ID: CR-PMO-20260514-CARD-FIRST-PLANNER-P0  
Date raised: 2026-05-14  
Raised by: CODEX-DOCS  
Requested decision owner: CODEX-LEAD / Owner  
Status: Draft for review  
Tenant changes executed: None

## 1. Change Summary

Approve the P0 architecture change from Copilot-rendered operational data to a card-first operating model:

```text
Copilot Studio routes intent and returns short static acknowledgements.
Power Automate controls validation, writes, card posting, and sync.
Teams Adaptive Cards carry operational details, forms, confirmations, and click actions.
SharePoint remains the PMO system of record.
Planner becomes the task execution destination when mapping and permissions are confirmed.
```

This Change Request covers the non-STT P0 delivery: executive visibility, PM update loop, task list/create/update, robust clickable Adaptive Cards, and Planner create/update/sync integration.

## 2. Business Need

The director needs reliable portfolio visibility and PM updates now. The current runtime can complete operations but still show blocked or failed steps to users because operational data and connector/tool context remain in the Copilot chat path.

The product must reduce false failure signals, improve executive visibility, and support task execution in Planner without discarding the existing SharePoint PMO investment.

## 3. Problem Statement

Observed runtime issue:

```text
Power Automate / SharePoint operation succeeds
Copilot Studio later reports ContentFiltered / openAIIndirectAttack
User sees a false failure or blocked step
```

Known repro context:

```text
listar tarefas do projeto QA Robust 20260513 F
```

Root-cause position for this CR:

- A specific malicious SharePoint row has not been proven.
- The safer architectural assumption is that the data/tool/orchestration path is too exposed to Copilot Responsible AI / XPIA moderation.
- Operational data should be displayed and acted on through deterministic Teams Adaptive Cards, not long Copilot chat responses.

## 4. Proposed Change

### 4.1 Change From

```text
User -> Copilot topic -> Power Automate -> SharePoint/Planner result -> Copilot chat rendering
```

### 4.2 Change To

```text
User -> Copilot topic or Teams card
Copilot -> thin router / static acknowledgement
Power Automate -> deterministic controller
Teams Adaptive Card -> operational UI
SharePoint -> PMO record
Planner -> execution task layer
```

### 4.3 Required Design Rules

1. Copilot must not render raw task lists, SharePoint rows, Planner task data, flow payloads, or raw card response payloads.
2. Copilot topics must return short static acknowledgements or bounded executive summaries only.
3. Power Automate must own server-side validation, write order, error handling, card composition, and sync state.
4. Adaptive Cards must be used for operational details, click actions, forms, confirmations, and error states.
5. Free-form, multiline, and future STT inputs must go through review-before-write.
6. SharePoint remains the source of record and audit layer.
7. Planner write/sync is allowed only when plan/bucket mapping and permissions are confirmed.

## 5. Scope

### 5.1 In Scope for P0

| Area | In-scope change |
|---|---|
| Executive visibility | Short Copilot summary plus Teams executive portfolio card. |
| PM update loop | Structured update card and single-box multiline review card. |
| Task list | Card-first bounded task list, no long Copilot-rendered list. |
| Task create | Card-driven create with validation and confirmation. |
| Task update | Card-driven update from selected task or router topic. |
| Planner | Create/update/sync through Standard connector after readiness confirmation. |
| Adaptive Cards | Consistent visual/action standard, metadata, size guardrails, click actions. |
| QA and evidence | Director scenario, PM update, task list/create/update, Planner failure, no ContentFiltered repro. |

### 5.2 Out of Scope for This CR

- Tenant imports, publishes, Power Automate saves, SharePoint writes, Planner writes, and Copilot Studio UI edits without explicit owner approval.
- Direct Microsoft Graph implementation.
- Replacing SharePoint as PMO system of record.
- STT implementation inside the P0 release gate.
- Broad PRD rewrite beyond follow-up revision notes.
- Any edit to solution packages, card JSON, flow definitions, Copilot topic files, or tests by CODEX-DOCS.

## 6. Affected Components

| Component | Impact |
|---|---|
| Copilot Studio topics | Reframe as routers/static acknowledgement paths. |
| Power Automate flows | Add/refactor controller flows for executive summary, PM update, task list, create, update, and Planner sync. |
| Teams Adaptive Cards | Add or harden executive, PM update, task list/create/update, confirmation, and error cards. |
| SharePoint lists | Continue as system of record; may require field readiness checks for Planner sync metadata. |
| Planner | Becomes execution destination when mapped. |
| QA/evidence | Add runtime evidence for no XPIA, card rendering, SharePoint audit, and Planner sync. |
| Governance docs | AS-IS/TO-BE, CR, ADR, PRD revision notes, release gates. |

## 7. Benefits

| Benefit | Description |
|---|---|
| Lower XPIA exposure | Operational payloads are not returned to Copilot for rendering or summarization. |
| Better director experience | Director gets short summary and a detailed actionable Teams card. |
| Better PM experience | PMs can submit structured updates and task changes through cards. |
| Stronger audit | SharePoint remains authoritative and captures status/sync outcomes. |
| Planner alignment | Planner becomes the execution layer without losing PMO governance fields. |
| Reuse of existing work | Existing lists, IDs, validation, topics, and card templates remain useful. |

## 8. Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| XPIA persists even with card-first output | P0 architecture assumption challenged | Prove with `ListarTarefas` first; stop rollout if known repro still fails. |
| Teams routing not ready | Cards cannot be delivered reliably | CODEX-QA readiness inventory before runtime implementation. |
| Planner plan/bucket IDs incomplete | Planner writes blocked or partial | Gate Planner create/update behind mapping inventory and allow SharePoint-only audit path. |
| Planner connector permission issue | Task create/update fails in execution layer | Validate owner/connection permissions before owner-approved tenant change. |
| Card payload too large | Teams rendering failure | Enforce target under 20 KB and hard guardrail under 27 KB; paginate task list. |
| User enters ambiguous free text | Wrong status/task update | Review-before-write and validation error cards. |
| Parallel delivery conflict | File overwrite or inconsistent artifacts | Mandatory check-in board and isolated write scopes. |

## 9. Implementation Plan

| Phase | Deliverable | Gate |
|---|---|---|
| Phase 0 | Governance docs, readiness inventories, card visual standard | Owner/CODEX-LEAD approve Track A/Track B sequencing. |
| Phase 1 | Executive summary card and short Copilot summary | Director sees current portfolio card; no `ContentFiltered`. |
| Phase 2 | PM status update structured card and single-box review card | Status writes only after confirmation and appears in director view. |
| Phase 3 | Task list/create/update cards with Planner mapping | SharePoint and Planner sync paths pass; known repro no longer fails. |
| Phase 4 | STT continuous improvement after non-STT stability | Transcript creates review card only; no direct write. |
| Phase 5 | QA, evidence, rollback, go/no-go | Evidence pack complete and owner approves release. |

## 10. Acceptance Criteria

This CR can be accepted for implementation when:

- The owner and CODEX-LEAD approve card-first + Planner P0 as the controlled direction.
- No tenant changes are executed before explicit owner approval.
- Teams routing and Planner readiness inventories are prepared before implementation dependencies are consumed.
- `ListarTarefas` is used as the first XPIA proof gate.
- Copilot topics for P0 operations return static acknowledgements or short bounded summaries only.
- Adaptive Cards are the required operational UI for detailed task/status interactions.
- SharePoint remains the source of record and Planner sync status is tracked.
- QA evidence includes the known XPIA repro, Teams rendering, card size, SharePoint audit, and Planner success/failure paths.

## 11. Rollback / Backout Position

Because this CR is a governance approval and no tenant changes are executed by this document, document rollback is simply CR rejection or supersession.

For later implementation waves, rollback must be wave-based:

| Wave | Backout approach |
|---|---|
| Copilot router change | Restore previous topic path from solution/package backup if owner-approved publish fails. |
| Power Automate card controller | Disable new controller flow and re-enable previous approved flow if needed. |
| Adaptive Card template | Revert to prior card version or fallback/error card. |
| Planner integration | Keep SharePoint audit record; mark Planner sync error/pending; disable Planner write branch. |
| Release package | Use CODEX-LEAD rollback plan and owner-controlled import/publish process. |

No rollback action may be executed by CODEX-DOCS.

## 12. Approval Record

| Role | Decision | Name / agent | Date | Notes |
|---|---|---|---|---|
| Owner | Pending | TBD | TBD | Required before tenant changes. |
| CODEX-LEAD | Pending | CODEX-LEAD | TBD | Required before implementation handoff. |
| Governance/docs | Drafted | CODEX-DOCS | 2026-05-14 | P0-02 deliverable. |
| Cards | Pending review | CODEX-CARDS | TBD | Must align visual/action standard. |
| Flow implementation | Pending review | GEMINI-PA | TBD | Must align controller rules. |
| QA/evidence | Pending review | CODEX-QA | TBD | Must align readiness and gate evidence. |

## 13. Final CR Recommendation

Recommend approval to proceed with the card-first + Planner P0 architecture under controlled gates.

The immediate implementation proof should remain `ListarTarefas` because it is the cleanest known repro and does not require a write. Broader task create/update and Planner integration should proceed only after readiness inputs and owner-approved tenant execution steps are available.
