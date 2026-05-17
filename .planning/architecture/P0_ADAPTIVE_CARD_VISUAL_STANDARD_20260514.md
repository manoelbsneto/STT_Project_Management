# P0 Adaptive Card Visual Standard and Naming Conventions

Date: 2026-05-14  
Owner: CODEX-CARDS  
Status: READY_FOR_REVIEW  
Scope: P0 Adaptive Cards for PMO Intelligent Hub, Teams delivery, Power Automate controllers, and Planner-linked task actions.  
No tenant changes executed.

## 1. Purpose

This standard confirms the local visual and interaction rules for P0 Adaptive Cards before implementation cards are changed or created.

P0 cards must support:

1. Executive visibility.
2. PM status update and review-before-write.
3. Task list/create/update with Planner sync metadata.
4. Consistent clickable actions routed to deterministic Power Automate controllers.
5. Teams desktop/web compatibility with bounded payload size.

## 2. Current Local Baseline

Existing templates under `deploy/cards/`:

| File | Current role | Approx. size |
|---|---|---:|
| `AlertaCritico.json` | Critical project alert | 1.4 KB |
| `CheckInDiario.json` | PM daily check-in form | 2.3 KB |
| `DecisaoBoard.json` | Board decision approval | 2.1 KB |
| `EscalacaoRisco.json` | Critical risk escalation | 1.7 KB |
| `ResumoDiarioBoard.json` | Daily portfolio summary | 2.8 KB |
| `ResumoSemanal.json` | Weekly portfolio summary | 2.1 KB |

Observed local conventions to preserve:

- Adaptive Card schema `http://adaptivecards.io/schemas/adaptive-card.json`.
- Adaptive Card `version` set to `1.4`.
- Compact header using `Container` or `ColumnSet`.
- Fact-heavy summary using `FactSet`.
- RAG colors using `Good`, `Warning`, and `Attention`.
- Write operations use `Action.Submit`; navigation uses `Action.OpenUrl`.
- Inputs use lower camel case IDs such as `statusRAG`, `resumo`, `percentual`, `risco`, `bloqueio`, `proximaAcao`.

Observed gaps that P0 must close:

- `operationId` is not yet consistently present in action metadata.
- `source=AdaptiveCard` is required by the architecture but not consistently encoded.
- Existing action payloads use mixed identity fields (`ProjectID`, `DecisionID`, `RiskID`) in data placeholders. P0 action data must normalize submitted field names to lower camel case.
- Existing visual labels include leading decorative blanks or missing glyph positions. P0 cards must use ASCII-safe labels and rely on color/style rather than decorative emoji.

## 3. Card Naming Standard

### 3.1 File Names

Use PascalCase JSON file names with domain-first wording:

```text
<VerbOrSummary><Entity><OptionalContext>Card.json
```

Examples:

- `AtualizarStatusCard.json`
- `AtualizarStatusSingleBoxReviewCard.json`
- `ListarTarefasProjetoCard.json`
- `CriarTarefaCard.json`
- `AtualizarTarefaCard.json`

Exception:

- `ResumoExecutivoPortfolio.json` is the canonical Phase 1 filename from the delivery plan. Do not append `Card` unless CODEX-LEAD revises the plan.

Do not rename existing legacy cards during P0-07. Existing names remain valid until CODEX-LEAD schedules an implementation cleanup.

### 3.2 Card IDs and Internal References

Use lower camel case for card/action/data identifiers:

| Purpose | Standard |
|---|---|
| Card family ID | `resumoExecutivoPortfolio`, `atualizarStatus`, `listarTarefasProjeto` |
| Input IDs | `statusRAG`, `percentual`, `resumo`, `risco`, `bloqueio`, `proximaAcao` |
| Entity IDs in action data | `projectId`, `taskId`, `decisionId`, `riskId`, `plannerTaskId` |
| Runtime correlation | `operationId` |
| Source marker | `source` with value `AdaptiveCard` |

Placeholders may keep upstream names when required by current flow outputs, but submitted `Action.Submit.data` keys must use the normalized lower camel case names.

## 4. Visual Standard

### 4.1 Header

Every P0 card starts with a compact header:

- First line: `PMO Assistant - <context>`.
- Second line: project/portfolio/date context, subtle text.
- Use `Container.style = emphasis` for normal cards.
- Use `Container.style = attention` for critical/error/escalation cards.
- Use `TextBlock.size = Medium` for the title; avoid hero-scale text.
- Use `wrap = true` on all variable text.

RAG indicator rules:

| RAG | Text | Adaptive color |
|---|---|---|
| Green | `Verde` | `Good` |
| Yellow | `Amarelo` | `Warning` |
| Red | `Vermelho` | `Attention` |
| Unknown/missing | `Sem status` | default/subtle |

### 4.2 Body

Order body content by operational priority:

1. Summary facts and counts.
2. Required action or decision context.
3. Detail lists.
4. Inputs.
5. Audit/correlation reference if useful.

Use `FactSet` for compact facts. Use `ColumnSet` only for small count blocks and keep it to 4 columns or fewer on cards expected to render on narrow Teams surfaces.

Avoid:

- raw JSON;
- raw SharePoint/Planner payloads;
- long URL text;
- unbounded copied list text;
- decorative emoji or symbols that may render inconsistently in Teams;
- long paragraphs where facts or short bullets would work.

### 4.3 Inputs

Structured PM update cards:

- `statusRAG`: required `Input.ChoiceSet`.
- `percentual`: `Input.Number`, `min = 0`, `max = 100`.
- `resumo`: required multiline `Input.Text`.
- `risco`: optional multiline `Input.Text`.
- `bloqueio`: optional multiline `Input.Text`.
- `proximaAcao`: multiline `Input.Text`.

Single-box review cards:

- Never write directly from parsed text.
- Show parsed fields as facts or prefilled inputs.
- Highlight missing/invalid fields before confirmation.
- Require a confirmation `Action.Submit` before any SharePoint or Planner write.

Task cards:

- Required create fields: project, title, responsible, due date, priority, bucket or bucket mapping.
- Required update fields: task ID, status, responsible, due date, priority, hours/progress where applicable.
- Use IDs and display names together when the ID is needed for support.

## 5. Action Standard

### 5.1 Required Action Metadata

Every `Action.Submit` in P0 cards must include:

```json
{
  "action": "<stableActionName>",
  "operationId": "${OperationID}",
  "cardVersion": "1.0",
  "source": "AdaptiveCard"
}
```

Project-scoped actions must also include:

```json
{
  "projectId": "${ProjectID}"
}
```

Entity-scoped actions must include the relevant ID:

```json
{
  "taskId": "${TaskID}",
  "decisionId": "${DecisionID}",
  "riskId": "${RiskID}",
  "plannerTaskId": "${PlannerTaskID}"
}
```

`operationId` is required for correlation, idempotency, and support. It should be generated by the controller before rendering the card and logged by downstream flow actions.

### 5.2 Action Names

Use stable lower camel case action values:

| Card family | Action values |
|---|---|
| Executive portfolio | `viewRedProjects`, `viewProjectsWithoutUpdate`, `requestPmUpdate`, `openProjectDetail`, `sendDecisionRequest` |
| PM update | `submitStatusUpdate`, `parseSingleBoxUpdate`, `confirmStatusUpdate`, `cancelStatusUpdate` |
| Task list | `listProjectTasks`, `createTaskFromProject`, `editTask`, `markTaskInProgress`, `markTaskDone`, `requestTaskUpdate` |
| Task create/update | `submitCreateTask`, `submitUpdateTask`, `cancelTaskEdit` |
| Decision | `approveDecision`, `rejectDecision`, `deferDecision` |
| Risk/blocker | `acknowledgeRisk`, `openRiskDetail`, `requestMitigationUpdate` |

Do not overload one `action` value for multiple controller paths. Flow branching should be deterministic from `action` plus entity IDs.

### 5.3 Action Layout

- Put the main safe action first.
- Put navigation actions after submit/confirm actions.
- Use `style = positive` only for clear confirmations.
- Use `style = destructive` only for reject/cancel/delete semantics.
- Destructive or write actions require either explicit confirmation or a review card.
- Keep visible actions to 5 or fewer per card. Use follow-up/detail cards for deeper operations.

### 5.4 OpenUrl Rules

`Action.OpenUrl` is allowed only for navigation:

- SharePoint hub/list/item links.
- Planner task links if tenant policy allows.
- Teams/channel links if routing inventory approves them.

`Action.OpenUrl` must not be used to imply a write operation. Do not expose raw long URLs in body text.

## 6. P0 Card Families

### 6.1 Executive Portfolio

Canonical file:

```text
deploy/cards/ResumoExecutivoPortfolio.json
```

Required content:

- Active project total.
- RAG counts.
- Projects without recent update.
- Red/yellow project summary.
- Top blockers/risks.
- Reference date/time.

Required actions:

- `viewRedProjects`
- `viewProjectsWithoutUpdate`
- `requestPmUpdate`
- `openProjectDetail`
- `sendDecisionRequest` when available

### 6.2 PM Status Update

Canonical files:

```text
deploy/cards/AtualizarStatusCard.json
deploy/cards/AtualizarStatusSingleBoxReviewCard.json
```

Required behavior:

- Structured update card accepts validated fields.
- Single-box parser output always routes to review.
- Final write only after `confirmStatusUpdate`.

### 6.3 Task Management and Planner

Canonical files:

```text
deploy/cards/ListarTarefasProjetoCard.json
deploy/cards/CriarTarefaCard.json
deploy/cards/AtualizarTarefaCard.json
```

Required behavior:

- Task list card shows bounded rows, default maximum 10 tasks per card.
- Create/update cards submit SharePoint-first metadata.
- Planner sync result is represented by status metadata, not hidden.
- Planner failure must not hide the SharePoint write outcome.

## 7. Size and Compatibility Guardrails

### 7.1 Adaptive Card Version

Use Adaptive Card `version = 1.4` for P0 unless CODEX-LEAD approves a version change after Teams compatibility validation.

### 7.2 Payload Size

P0 guardrails:

- Target: under 20 KB per rendered card payload.
- Hard guardrail: under 27 KB per rendered card payload.
- Current local templates are 1.4-2.8 KB and should remain lightweight after P0 expansion.

If a card would exceed target size:

1. Reduce rendered rows.
2. Replace long detail text with summary plus detail action.
3. Split into follow-up cards.
4. Keep Copilot chat response short and avoid moving payload back into Copilot.

### 7.3 List Limits

Recommended maximums per rendered card:

| Content | Maximum |
|---|---:|
| Task rows | 10 |
| Red projects | 5 |
| Yellow projects | 5 |
| Projects without update | 5 |
| Blockers/risks | 3 |
| Decision items | 5 |
| Visible actions | 5 |
| Columns in count strip | 4 |

### 7.4 Text Rendering

- Set `wrap = true` on variable text.
- Keep field labels short.
- Avoid markdown-heavy headings inside body text; prefer separate bold `TextBlock`s.
- Avoid tables built from fixed-width text.
- Do not rely on emoji, icon fonts, or remote images for semantic meaning.
- Remote images are optional decoration only; cards must remain understandable if the image does not load.

### 7.5 Teams Compatibility

Cards must render acceptably in Teams desktop and Teams web:

- No horizontal scrolling caused by wide columns.
- No more than 4 equal metric columns.
- Inputs must have labels.
- Required fields must use `isRequired` where supported.
- Date values should be ISO or localized display strings generated by the controller, not parsed from body text by the card.

## 8. Validation Checklist for New P0 Cards

Before CODEX-LEAD integration review, each P0 card must pass:

- JSON parses cleanly.
- `$schema`, `type`, and `version` are present.
- Card version is `1.4`.
- Rendered payload target under 20 KB and hard guardrail under 27 KB.
- Every `Action.Submit.data` includes `action`, `operationId`, `cardVersion`, and `source`.
- Project-scoped actions include `projectId`.
- Entity actions include the relevant entity ID.
- Action names match this document.
- No raw JSON, raw URLs, or unbounded list payload appears in card body.
- Write actions require submit/review/confirmation flow.
- Variable text uses `wrap = true`.
- Labels and action titles are ASCII-safe.

## 9. Dependencies and Blockers

Dependencies:

- P1-01 executive summary data contract must define final field names and row limits for `ResumoExecutivoPortfolio`.
- P2-01 PM update data contract must confirm parser/review fields.
- P3-01 task data contract and P0-06 Planner readiness inventory must confirm Planner plan/bucket/link metadata.
- Teams routing inventory P0-05 must confirm where cards are posted and which OpenUrl actions are permitted.

Current blockers:

- None for P0-07 standard approval.

Implementation note:

- This document intentionally does not edit `deploy/cards/*.json`. Future card implementation tasks should update the templates to match the metadata and naming standards above.
