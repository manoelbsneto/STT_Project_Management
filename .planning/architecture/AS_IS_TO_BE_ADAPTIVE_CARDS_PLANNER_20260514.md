# AS-IS / TO-BE Architecture Control: Adaptive Cards + Planner P0

Date: 2026-05-14  
Owner: CODEX-DOCS  
Status: Draft for CODEX-LEAD review  
Scope: P0 executive visibility, PM update loop, task management, Adaptive Cards, Planner integration  
Tenant changes: None executed by this document

## 1. Control Purpose

This document records the controlled architecture update for the PMO Intelligent Hub Adaptive Cards + Planner P0 delivery.

It consolidates the approved direction from:

- `.planning/architecture/AGENTIC_TASK_PLAN_ADAPTIVE_CARDS_PLANNER_20260514.md`
- `.planning/architecture/FULL_DELIVERY_PLAN_ADAPTIVE_CARDS_PLANNER_20260514.md`
- `.planning/architecture/ADAPTIVE_CARDS_PLANNER_ARCHITECTURE_20260514.md`
- `.planning/architecture/ADAPTIVE_CARDS_PLANNER_MACRO_PLAN_20260514.md`
- `.planning/architecture/XPIA_EXTERNAL_SOURCE_REVIEW_20260514.md`
- `.planning/AGENT_CONTRACT.md`

The control objective is to move operational PMO interactions away from long Copilot chat rendering and into deterministic Power Automate + Teams Adaptive Card flows while preserving SharePoint as the PMO system of record and adding Planner as the execution layer.

## 2. Executive Architecture Decision

Approved TO-BE direction:

```text
Copilot Studio = executive/router interface
Power Automate = deterministic controller
Teams Adaptive Cards = primary operational UI
SharePoint = PMO system of record
Planner = task execution destination
```

The architecture does not discard the current investment. It reuses SharePoint lists, Power Automate validation logic, existing Copilot topics as routers, existing card templates where fit for purpose, the ProjectID/TaskID/DecisionID model, Planner connector direction, and current QA/RCA evidence.

## 3. AS-IS Architecture

### 3.1 Runtime Pattern

```text
User asks Copilot
Copilot identifies topic
Copilot calls Power Automate action
Flow queries or writes SharePoint
Flow returns result, context, ID, list, or status to Copilot
Copilot renders or post-processes response in chat
Responsible AI / XPIA layer may block after action success
```

### 3.2 AS-IS Component Responsibilities

| Component | Current responsibility | Issue |
|---|---|---|
| Copilot Studio | Intent detection, topic orchestration, conversational rendering, sometimes operational result handling | Too much operational data remains in the LLM/chat path. |
| Power Automate | SharePoint reads/writes, validation, response composition | Some flows still return operational payloads or dynamic details to Copilot. |
| SharePoint | PMO source of record for projects, status, risks, decisions, tasks | Correct system of record and retained. |
| Teams Adaptive Cards | Used for some governance/status interactions | Not yet the primary task and executive operational UI. |
| Planner | Intended execution layer and sync target | Mapping/readiness not confirmed for P0 delivery. |

### 3.3 AS-IS Release Blockers

| Blocker | Evidence / context | Impact |
|---|---|---|
| `ContentFiltered` / `openAIIndirectAttack` after successful actions | Known repro around `listar tarefas do projeto QA Robust 20260513 F`; external source review supports risk in grounded/tool data path | Users see false failure and trust is reduced. |
| Copilot chat used for operational data display | Existing task and portfolio patterns can send dynamic result context through Copilot | Increases moderation surface and response fragility. |
| Dynamic IDs and structured result text returned in chat | `CriarTarefa` and similar paths may expose operational identifiers as dynamic chat output | Adds unnecessary payload surface to Copilot. |
| Planner readiness not yet confirmed | Plan IDs, bucket IDs, route, and permissions need inventory | Blocks reliable create/update/sync implementation. |
| Card task management incomplete | Existing card templates are not the full task list/create/update set | Prevents card-first operational workflow. |

### 3.4 AS-IS Assets to Preserve

| Asset | Preserve? | Control note |
|---|---:|---|
| SharePoint PMO lists | Yes | Remain authoritative records for PMO metadata, status, risks, decisions, and task audit. |
| ProjectID / TaskID / DecisionID | Yes | Required for traceability, card actions, Planner mapping, and evidence. |
| Existing Power Automate validation logic | Yes | Refactor into card/controller flows rather than discard. |
| Existing Copilot topics and trigger phrases | Partial | Reuse as thin routers; remove long operational rendering. |
| Existing Adaptive Card templates | Yes | Reuse base visual and governance patterns where compatible with P0 standard. |
| Planner Standard connector decision | Yes | Aligns with no-premium/no-direct-Graph constraint. |
| Multiline/single-box parsing | Yes | Preserve as non-STT input mode with review-before-write. |
| STT concept | Later | Move to continuous improvement and always route through review card before write. |

## 4. TO-BE Architecture

### 4.1 Target Runtime Pattern

```text
User asks Copilot or starts from Teams
Copilot routes intent and collects minimum context only
Power Automate validates and controls the process
Power Automate posts or updates Teams Adaptive Card
User reviews, clicks, or submits structured card input
Power Automate writes SharePoint and Planner as needed
Copilot receives only static acknowledgement, tiny status code, or no operational payload
```

### 4.2 TO-BE Component Responsibilities

| Component | Target responsibility | Control rule |
|---|---|---|
| Copilot Studio | Intent router and short executive interface | No raw SharePoint/Planner rows, no long task lists, no dynamic operational payload rendering. |
| Power Automate | Deterministic controller for validation, card composition, writes, sync, and error handling | Owns business rules and never relies on Copilot to interpret operational payloads. |
| Teams Adaptive Cards | Primary operational UI for details, forms, confirmations, click actions, and error states | Cards include version/action metadata and remain under size guardrails. |
| SharePoint | System of record and audit source | SharePoint write happens first for task audit unless a later approved design changes this. |
| Planner | Execution/task destination | Planner create/update/sync occurs when valid mapping and permissions exist. |

### 4.3 Target Logical Architecture

```text
Actors
  - Director / Board
  - PM
  - PMO

Entry points
  - Copilot short command
  - Teams Adaptive Card action
  - Scheduled Power Automate flow

Controller
  - Power Automate card/controller flows
  - Validation, routing, correlation, retries, status codes

Operational UI
  - Teams Adaptive Cards
  - Portfolio summary
  - PM update cards
  - Task list/create/update cards
  - Confirmation and error cards

Records and execution
  - SharePoint lists for PMO record/audit
  - Planner plans/tasks for execution
```

## 5. P0 Capability Mapping

| Capability | AS-IS | TO-BE | P0 control |
|---|---|---|---|
| Executive visibility | Copilot/flows may render operational data directly or rely on dashboard fallback | Copilot gives short curated summary; Teams card carries portfolio detail and actions | P0 release-blocking. |
| PM status update | Existing check-in/status logic exists, but free text paths need governed confirmation | Structured card and single-box parser both use review-before-write | P0 release-blocking because director view depends on current updates. |
| Task list | Copilot/action path can trigger XPIA after successful operation | `ListarTarefas` sends bounded Teams card; Copilot only acknowledges | P0 proof gate for known repro. |
| Task create | Dynamic chat output and SharePoint-first flow patterns exist | Card-first create with validation, confirmation, SharePoint write, optional Planner create | P0 release-blocking for full non-STT solution. |
| Task update | Existing update path is not fully card-first | Card action drives SharePoint update and Planner sync when mapped | P0 release-blocking for full non-STT solution. |
| Planner sync | Intended in contract but readiness/mapping not confirmed | Plan/bucket mapping inventory and sync status fields govern create/update/reporting | Required before Planner write paths. |
| Visual/click-action standard | Existing cards are inconsistent and not complete for task management | Common P0 card standard, metadata, action semantics, size guards | P0 release-blocking. |

## 6. Data and Payload Control Rules

1. Copilot must not receive full SharePoint item JSON, Planner task JSON, raw card response payloads, or long operational result sets.
2. Copilot responses for operational commands must be static, bounded, or status-code driven.
3. Adaptive Cards must include `cardVersion`, `operationId`, `source=AdaptiveCard`, and relevant entity IDs such as `projectId` or `taskId`.
4. Card payload target size is under 20 KB; hard guardrail is under 27 KB.
5. Free-form and multiline inputs are treated as data, parsed by Power Automate, and written only after review card confirmation.
6. Planner failure must not corrupt SharePoint audit. SharePoint records must capture sync state such as `PlannerSyncStatus=Erro` where applicable.
7. External/public content, raw URLs, HTML, script-like text, and connector payloads must not be concatenated into Copilot responses.

## 7. Target Flow Families

| Flow family | Purpose | Copilot output rule |
|---|---|---|
| Executive summary | Reads SharePoint status/risk/update data and posts portfolio card | Short curated summary only. |
| PM update | Sends structured or single-box review card; writes status after confirmation | Static acknowledgement only. |
| Task list | Reads SharePoint and optional Planner status; posts bounded task list card | Static acknowledgement only. |
| Task create | Posts create card, validates, confirms, writes SharePoint, then Planner if mapped | Static acknowledgement only. |
| Task update | Starts from card action or router topic; updates SharePoint and Planner if mapped | Static acknowledgement only. |
| Planner sync | Scheduled metrics sync from Planner to SharePoint | No Copilot rendering. |
| Error/fallback | Posts actionable card with validation failure or sync issue | No raw technical payload in Copilot. |

## 8. Implementation Sequence Control

| Phase | Gate | Architecture control condition |
|---|---|---|
| Phase 0 | Governance and readiness | AS-IS/TO-BE, Change Request, ADR, routing inventory, Planner inventory ready for review. |
| Phase 1 | Executive visibility | Director sees portfolio summary card; Copilot gives short summary; no `ContentFiltered`. |
| Phase 2 | PM update | Structured and single-box update paths both require review-before-write and update SharePoint. |
| Phase 3 | Task + Planner | List/create/update cards work; Planner create/update syncs when mapped; failure path is logged. |
| Phase 4 | STT continuous improvement | Voice/transcript never writes directly; transcript becomes reviewed card input only. |
| Phase 5 | Release hardening | QA evidence, rollback, card size/render checks, owner go/no-go complete. |

## 9. Dependencies and Open Inputs

| Dependency | Owner | Required for |
|---|---|---|
| Teams routing strategy and IDs | Owner / CODEX-QA readiness | Posting executive, PM, and task cards. |
| Planner plan and bucket mapping | Owner / CODEX-QA readiness | Planner create/update/sync. |
| Planner permission confirmation | Owner | Assignment and task write success. |
| Owner approval for tenant import/publish/deploy/write | Owner | Any runtime or tenant-side execution. |
| Card visual/action standard | CODEX-CARDS / CODEX-LEAD | Consistent P0 card implementation. |
| Flow controller design | GEMINI-PA / CODEX-LEAD | Deterministic card/controller behavior. |
| Runtime evidence | Owner / CODEX-QA / CODEX-LEAD | Release gate approval. |

## 10. Risks and Controls

| Risk | Control |
|---|---|
| XPIA still triggers after moving operational output to cards | Stop expansion and isolate whether the Copilot action call itself is triggering moderation. |
| Teams card routing fails | Validate routing inventory before broad card implementation. |
| Planner mapping incomplete | Keep SharePoint as source of record and mark Planner sync pending/error. |
| Long card payloads exceed Teams limits | Enforce bounded rows, pagination, and 20 KB target / 27 KB hard guardrail. |
| Free-text parser writes incorrect status | Require review-before-write for parsed or transcribed input. |
| Parallel agents overwrite files | Enforce check-in board and write-scope boundaries. |

## 11. Non-Goals for This Control

- No tenant import, publish, deploy, Power Automate save, SharePoint write, Planner write, or Copilot Studio UI edit.
- No edits to solution packages, flow definitions, topic files, card JSON, or tests.
- No STT implementation in P0. STT remains continuous improvement after the non-STT release is stable.
- No replacement of SharePoint as the PMO system of record.
- No direct Microsoft Graph implementation unless separately approved later.

## 12. Architecture Acceptance Criteria

The AS-IS / TO-BE update is acceptable when:

- CODEX-LEAD can trace P0 implementation work to the target component responsibilities in this document.
- P0 flow/card/topic work avoids returning operational data payloads to Copilot.
- Teams Adaptive Cards are explicitly established as the operational UI for detailed data and user actions.
- SharePoint remains the audit/system-of-record layer.
- Planner integration is gated by readiness inventory and sync/error status handling.
- Owner approval remains required for all tenant writes and publishes.

## 13. Review and Handoff

Review owner: CODEX-LEAD  
Downstream consumers: GEMINI-PA, CODEX-CARDS, CODEX-QA, owner  
Next governance artifact: formal Change Request for card-first + Planner P0
