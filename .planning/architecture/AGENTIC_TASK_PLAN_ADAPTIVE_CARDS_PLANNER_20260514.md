# Agentic Task Plan: Adaptive Cards + Planner P0 Delivery

Date: 2026-05-14  
Status: Planning only; no tenant changes executed  
Primary objective: deliver P0 executive visibility, card-first task management, robust clickable Adaptive Cards, and Planner integration without breaking existing work  
STT: excluded from P0 and moved to continuous improvement

## 1. Parallel Execution Answer

Yes, this work can be executed with multiple parallel agents, but only if each agent has a strict write scope and a single integration owner controls the final package.

Approved working model for this delivery:

```text
Codex Lead = integration owner and gatekeeper
Gemini 3.1 Pro Preview = Power Automate principal deploy engineer
Codex Sub-Agent 1 = Governance/docs only
Codex Sub-Agent 2 = Adaptive Card JSON, visual system, click actions
Codex Sub-Agent 3 = QA/evidence/test scripts and read-only readiness
```

Important rule:

No two agents should edit the same solution package, same topic file, same flow file, or same card JSON at the same time.

Owner-controlled startup rule:

`CODEX-LEAD` must notify the owner before any agent task begins. The owner will start the corresponding IDE/session. No agent is considered active until it has written a STARTED/CLAIMED update in `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`.

Mandatory point of coordination:

```text
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
```

All active agents must update the check-in board every 5 minutes while actively working, and also at task start, before edits, after edits, when blocked, when handing off, and at completion.

Mandatory access protocol:

```text
.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
```

All tenant/remote discovery and execution must follow the project master docs and runbooks. Microsoft 365 CLI / `m365` is not approved for this project discovery path. Planner bucket discovery must use the approved master-doc/remote process, with the planned command/access route posted in the check-in board before execution.

Mandatory SEV-0 quality gate protocol:

```text
.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
```

Every agent must read the SEV-0 protocol before starting any task. CI may be ignored only when explicitly owner-excluded. Every other quality gate is mandatory; if any non-CI gate is missing, failed, stale, unverified, or not tied to the current artifact, the release decision is `NO-SHIP`.

## 2. Priority Order

P0 delivery priority:

1. Executive visibility working for director.
2. PM update loop working through cards and multiline/single-box input.
3. Task management card-first.
4. Planner create/update/sync integration.
5. Robust Adaptive Card visual system and click actions across P0 flows.
6. QA, evidence, rollback, release readiness.

STT is Phase 4 continuous improvement after the non-STT P0 solution is stable.

## 3. Recommended Agent Roster

| Role | Suggested Owner | Can Run in Parallel? | Write Scope |
|---|---|---:|---|
| Delivery Lead / Integration Owner | `CODEX-LEAD` | Coordinates all | Final integration docs, final package review, gate decisions |
| Principal Deploy Engineer | `GEMINI-PA` / Gemini 3.1 Pro Preview | Yes | Power Automate flow implementation/design only |
| Sub-Agent 1 | `CODEX-DOCS` | Yes | `.planning`, `PRD`, `docs` documentation only |
| Sub-Agent 2 | `CODEX-CARDS` | Yes | `deploy/cards/*.json`, card visual standards only |
| Sub-Agent 3 | `CODEX-QA` | Yes | `tests/*`, `.planning/comms/*evidence*`, QA matrices, read-only readiness reports |

## 4. Task Plan by Priority

### Phase 0 - Governance and Readiness

| ID | Priority | Task | Estimate | Owner | Parallel? | Dependencies | Write Scope | Output |
|---|---:|---|---:|---|---:|---|---|---|
| P0-00 | 0 | Freeze current state and confirm no tenant changes before approval | 0.5h | Codex Lead | No | None | `.planning/architecture`, `.planning/stop_ship` | Written baseline note |
| P0-01 | 0 | Create AS-IS / TO-BE architecture update | 2h | Docs Agent | Yes | P0-00 | `.planning/architecture/*AS_IS_TO_BE*` | Architecture control doc |
| P0-02 | 0 | Create formal Change Request for card-first + Planner P0 | 1.5h | Docs Agent | Yes | P0-00 | `.planning/architecture/*CHANGE_REQUEST*` | CR document |
| P0-03 | 0 | Create ADR for Copilot-as-router / Cards-as-operational-UI | 1.5h | Docs Agent | Yes | P0-01 | `.planning/architecture/*ADR*` | ADR document |
| P0-04 | 0 | Update PRD revision notes and project contract references | 3h | Docs Agent | Yes | P0-01, P0-02 | `PRD/*.md`, `.planning/AGENT_CONTRACT.md` | PRD/contract reflect new P0 |
| P0-05 | 0 | Build Teams routing inventory: Board channel, PM routing, PMO ops channel | 2h | SharePoint/Planner Readiness Agent | Yes | P0-00 | `.planning/comms/*routing*` | Routing matrix |
| P0-06 | 0 | Build Planner readiness inventory: Plan IDs, bucket IDs, permission assumptions | 3h | SharePoint/Planner Readiness Agent | Yes | P0-00 | `.planning/comms/*planner*` | Planner mapping matrix |
| P0-07 | 0 | Confirm local card visual standard and naming conventions | 1h | Codex Lead + Cards Agent | Yes | P0-00 | `.planning/architecture`, `deploy/cards` | Card design standard |

Phase 0 estimate:

- Sequential: 1.5 to 2 days.
- With 3-4 agents: 0.5 to 1 day.

### Phase 1 - P0 Executive Visibility

| ID | Priority | Task | Estimate | Owner | Parallel? | Dependencies | Write Scope | Output |
|---|---:|---|---:|---|---:|---|---|---|
| P1-01 | 0 | Define executive summary data contract | 1.5h | Codex Lead | Yes | P0-01 | `.planning/architecture/*contract*` | Fields, limits, response rules |
| P1-02 | 0 | Design `ResumoExecutivoPortfolio` Adaptive Card JSON | 3h | Cards Agent | Yes | P1-01, P0-07 | `deploy/cards/ResumoExecutivoPortfolio.json` | Card template |
| P1-03 | 0 | Define executive click actions: red projects, no update, request PM update, project detail | 2h | Cards Agent + Codex Lead | Yes | P1-01 | `deploy/cards/ResumoExecutivoPortfolio.json` | Action schema |
| P1-04 | 0 | Build/modify Power Automate executive summary flow design | 4-6h | Principal Deploy Engineer 1 | Yes | P1-01, P0-05 | flow definition files only | Flow design/package draft |
| P1-05 | 0 | Update Copilot executive query topic to short curated response only | 3-4h | Principal Deploy Engineer 2 | Yes | P1-01 | topic/YAML files only | Static/curated response path |
| P1-06 | 0 | Create tests for director scenario | 2h | QA Agent | Yes | P1-01 | `tests/*`, `.planning/comms/*` | QA script/checklist |
| P1-07 | 0 | Integrate flow + topic + card locally and run static gates | 3h | Codex Lead | No | P1-02..P1-06 | integration package only | Gate report |
| P1-08 | 0 | Owner import/publish/runtime validation | 1-2h | Owner + Codex Lead | No | P1-07 | tenant UI only by owner | Evidence screenshots |

Phase 1 estimate:

- Sequential: 2 to 3 days.
- With parallel agents: 1 to 1.5 days plus owner validation.

### Phase 2 - P0 PM Update Cards + Multiline / Single Box

| ID | Priority | Task | Estimate | Owner | Parallel? | Dependencies | Write Scope | Output |
|---|---:|---|---:|---|---:|---|---|---|
| P2-01 | 0 | Define PM update data contract: RAG, percent, resumo, risco, bloqueio, proxima acao | 1h | Codex Lead | Yes | P0-01 | `.planning/architecture/*contract*` | Update schema |
| P2-02 | 0 | Design structured `AtualizarStatusCard` | 3h | Cards Agent | Yes | P2-01 | `deploy/cards/AtualizarStatusCard.json` | Structured card |
| P2-03 | 0 | Design `AtualizarStatusSingleBoxReviewCard` | 3h | Cards Agent | Yes | P2-01 | `deploy/cards/AtualizarStatusSingleBoxReviewCard.json` | Review card |
| P2-04 | 0 | Implement single-box multiline parser rules in flow design | 5-7h | Principal Deploy Engineer 1 | Yes | P2-01 | flow definition files only | Parser + validation |
| P2-05 | 0 | Implement review-before-write controller flow | 5-7h | Principal Deploy Engineer 1 | Partially | P2-02, P2-03, P2-04 | flow definition files only | Review/write flow |
| P2-06 | 0 | Update Copilot `AtualizarStatus` topic as router only | 3h | Principal Deploy Engineer 2 | Yes | P2-01 | topic/YAML files only | Static ack + card trigger |
| P2-07 | 0 | Add QA cases for structured card and single-box multiline | 3h | QA Agent | Yes | P2-01 | `tests/*`, `.planning/comms/*` | QA matrix |
| P2-08 | 0 | Integrate Phase 2 and validate local gates | 3h | Codex Lead | No | P2-02..P2-07 | integration package only | Gate report |
| P2-09 | 0 | Owner runtime validation: PM update appears in director visibility | 1-2h | Owner + Codex Lead | No | P2-08 | tenant UI only by owner | Evidence |

Phase 2 estimate:

- Sequential: 2 to 3 days.
- With parallel agents: 1 to 1.5 days plus owner validation.

### Phase 3 - P0 Task Management Card-First + Planner

| ID | Priority | Task | Estimate | Owner | Parallel? | Dependencies | Write Scope | Output |
|---|---:|---|---:|---|---:|---|---|---|
| P3-01 | 0 | Define task card data contract and pagination limits | 1.5h | Codex Lead | Yes | P0-06 | `.planning/architecture/*contract*` | Task schema |
| P3-02 | 0 | Design `ListarTarefasProjetoCard` with click actions | 4h | Cards Agent | Yes | P3-01 | `deploy/cards/ListarTarefasProjetoCard.json` | List card |
| P3-03 | 0 | Design `CriarTarefaCard` | 3h | Cards Agent | Yes | P3-01 | `deploy/cards/CriarTarefaCard.json` | Create card |
| P3-04 | 0 | Design `AtualizarTarefaCard` | 3h | Cards Agent | Yes | P3-01 | `deploy/cards/AtualizarTarefaCard.json` | Update card |
| P3-05 | 0 | Implement task list flow: SharePoint query + optional Planner status + card post | 6-8h | Principal Deploy Engineer 1 | Yes | P3-01, P3-02 | flow definition files only | List tasks controller |
| P3-06 | 0 | Implement create task flow: SharePoint first, Planner second, sync fields | 8-12h | Principal Deploy Engineer 1 | Partially | P0-06, P3-03 | flow definition files only | Create controller |
| P3-07 | 0 | Implement update task flow: SharePoint update + Planner update if mapped | 8-12h | Principal Deploy Engineer 1 | Partially | P0-06, P3-04 | flow definition files only | Update controller |
| P3-08 | 0 | Update Copilot `ListarTarefas`, `CriarTarefa`, `AtualizarTarefa` as routers/static ack | 6-8h | Principal Deploy Engineer 2 | Yes | P3-01 | topic/YAML files only | Topic routing |
| P3-09 | 0 | Add QA tests: list/create/update, invalid project, invalid UPN, invalid date, Planner failure | 5h | QA Agent | Yes | P3-01 | `tests/*`, `.planning/comms/*` | QA matrix |
| P3-10 | 0 | Integrate Phase 3 and run local gates | 4-6h | Codex Lead | No | P3-02..P3-09 | integration package only | Gate report |
| P3-11 | 0 | Owner runtime validation: known XPIA repro, create task, update task, Planner evidence | 2-4h | Owner + Codex Lead | No | P3-10 | tenant UI only by owner | Evidence |

Phase 3 estimate:

- Sequential: 4 to 6 days.
- With parallel agents: 2 to 3 days plus owner validation.

### Phase 4 - P0 Visual Robustness and Click Actions Hardening

This phase overlaps with Phases 1-3 but has a separate release gate because the owner confirmed robust visuals and click actions are P0, not polish.

| ID | Priority | Task | Estimate | Owner | Parallel? | Dependencies | Write Scope | Output |
|---|---:|---|---:|---|---:|---|---|---|
| P4-01 | 0 | Define card visual design rules: headers, RAG markers, facts, actions, error states | 2h | Cards Agent + Codex Lead | Yes | P0-07 | `.planning/architecture/*visual*` | Visual standard |
| P4-02 | 0 | Validate all cards under 27 KB and target under 20 KB | 2h | QA Agent | Yes | cards available | `tests/*`, evidence only | Size report |
| P4-03 | 0 | Validate click-action schema consistency across all P0 cards | 3h | Cards Agent | Yes | P1/P2/P3 cards | `deploy/cards/*.json` | Action consistency |
| P4-04 | 0 | Validate Teams desktop/web rendering checklist | 2-4h | QA Agent + Owner | No for runtime | P1/P2/P3 integration | evidence only | Render evidence |
| P4-05 | 0 | Add fallback/error cards for validation failures | 4h | Cards Agent + Flow Engineer | Partially | flow contracts | card + flow files | Error UX |

Phase 4 estimate:

- Sequential: 1 to 2 days.
- With parallel agents: 0.5 to 1 day, plus runtime screenshots.

### Phase 5 - Release Hardening and Evidence

| ID | Priority | Task | Estimate | Owner | Parallel? | Dependencies | Write Scope | Output |
|---|---:|---|---:|---|---:|---|---|---|
| P5-01 | 0 | Build final release checklist | 1h | QA Agent | Yes | P1-P4 | `.planning/stop_ship`, `.planning/comms` | Checklist |
| P5-02 | 0 | Build rollback plan | 1.5h | Codex Lead | Yes | P3 integration | `.planning/architecture`, `.planning/stop_ship` | Rollback doc |
| P5-03 | 0 | Run local static gates | 2-4h | Codex Lead | No | integrated package | tests/evidence | Gate report |
| P5-04 | 0 | Owner import/publish | 1-2h | Owner | No | P5-03 | tenant UI | Import/publish evidence |
| P5-05 | 0 | Runtime QA full pass | 3-5h | Owner + QA Agent + Codex Lead | No | P5-04 | evidence only | Evidence pack |
| P5-06 | 0 | Go/no-go decision | 0.5h | Owner + Codex Lead | No | P5-05 | `.planning/stop_ship` | Release decision |

Phase 5 estimate:

- Sequential: 1 to 2 days.
- With parallel preparation: 0.5 to 1 day plus owner runtime execution.

## 5. Total Estimate

### With One Primary Implementer

| Scope | Estimate |
|---|---:|
| Phase 0 | 1.5 to 2 days |
| Phase 1 | 2 to 3 days |
| Phase 2 | 2 to 3 days |
| Phase 3 | 4 to 6 days |
| Phase 4 | 1 to 2 days |
| Phase 5 | 1 to 2 days |
| Total | 11.5 to 18 days |

### With 3 Codex Sub-Agents + 1 Gemini Principal Deploy Engineer

| Scope | Estimate |
|---|---:|
| Phase 0 | 0.5 to 1 day |
| Phase 1 | 1 to 1.5 days |
| Phase 2 | 1 to 1.5 days |
| Phase 3 | 2 to 3 days |
| Phase 4 | 0.5 to 1 day |
| Phase 5 | 0.5 to 1 day |
| Total best case | 6 to 7 days |
| Total realistic | 7 to 9 days |
| Total risk-adjusted | 9 to 11 days |

## 6. Parallel Safety Rules

These rules are mandatory if multiple agents work in parallel.

1. One integration owner only.
2. One agent per write scope.
3. No parallel edits to the same file or same solution package.
4. Flow engineer owns flow definitions only.
5. Copilot engineer owns topic/YAML only.
6. Cards engineer owns card JSON only.
7. QA agent owns tests/evidence only.
8. Docs agent owns governance docs only.
9. All agents must report changed files.
10. Integration owner reviews diffs before packaging.
11. No tenant import/publish/write by agents unless owner explicitly approves.
12. Runtime validation remains owner-led with Codex support.

## 7. Recommended Parallel Assignment

### Day 0 / Half-Day Start

| Agent | Work |
|---|---|
| Codex Lead | Freeze baseline, final architecture gates, assign scopes |
| Docs Agent | AS-IS/TO-BE, CR, ADR, PRD/contract updates |
| Readiness Agent | Teams routing + Planner mapping inventory |
| Cards Agent | Visual standard + executive card skeleton |
| QA Agent | QA matrix and evidence templates |

### Day 1

| Agent | Work |
|---|---|
| Flow Engineer | Executive summary flow |
| Copilot Engineer | Executive query topic static response |
| Cards Agent | Executive card + PM update card |
| QA Agent | Director visibility tests |
| Codex Lead | Integration and gate review |

### Day 2

| Agent | Work |
|---|---|
| Flow Engineer | PM update controller + single-box parser |
| Copilot Engineer | AtualizarStatus router |
| Cards Agent | Review card + error/fallback cards |
| QA Agent | PM update tests |
| Owner | Runtime validation for director + PM update |

### Days 3-5

| Agent | Work |
|---|---|
| Flow Engineer | Task list/create/update + Planner mapping |
| Copilot Engineer | Task topic routers |
| Cards Agent | Task cards + click actions |
| QA Agent | Task/Planner test matrix |
| Codex Lead | Integration and package gates |

### Days 6-8

| Agent | Work |
|---|---|
| All | Hardening, evidence, runtime tests, release go/no-go |

## 8. Agentic Plan Recommendation

Use multiple agents, but do not let them all modify the same implementation artifacts.

Approved for this delivery:

- 1 principal deploy engineer:
  - Gemini 3.1 Pro Preview for Power Automate.
- 3 Codex sub-agents:
  - docs/governance;
  - cards/visual system;
  - QA/evidence.
- Codex Lead retains Copilot Studio topic integration unless owner assigns another engineer.

This setup should speed delivery without breaking code if the write scopes above are enforced.
