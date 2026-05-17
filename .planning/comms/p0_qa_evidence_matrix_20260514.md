# P0 QA and Evidence Matrix - Adaptive Cards + Planner

Date: 2026-05-14  
Owner: CODEX-QA  
Status: Refreshed 2026-05-15 for AQ-04 owner-provided Planner ID evidence  
Scope: Evidence planning only. No tenant changes, imports, publishes, SharePoint writes, Planner writes, or Copilot Studio UI edits.

Release decision remains `NO-SHIP` until runtime gates are green. AQ-04 owner-provided Planner IDs are accepted only as read-only Power Automate evidence for planning; they do not authorize Planner writes, SharePoint writes, flow saves/imports, Copilot publish/update, Teams production posts, or SHIP.

## 0. Owner-Confirmed Runtime Configuration

| Decision Area | Confirmed P0 Value | Evidence / Control |
|---|---|---|
| Executive / Board route | `board.status` posts to `Projetos_Transformacao_Digital` route by confirmed IDs | Owner decisions 2026-05-14; `groupId=96c5b0c4-46cc-46cd-8695-50451db74994`; `channelId=19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` |
| PMO operations route | `pmo.ops` uses `Projetos_Transformacao_Digital` route by confirmed IDs for controlled P0 | Owner decisions 2026-05-14; same group/channel as `board.status` |
| PM status update route | `pm.status.updates` posts to `QA_Projetos` | Owner decisions 2026-05-14; `groupId=96c5b0c4-46cc-46cd-8695-50451db74994`; `channelId=19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` |
| Task card route | `task.card.route` direct chat to `mbenicios@minsait.com` | Owner decisions 2026-05-14; temporary P0 requester/PM route |
| Planner pilot project | Any existing project is acceptable; default local candidate `QA Robust 20260513 F / PRJ-274E5ACC / SharePoint item 33` | Owner decisions 2026-05-14 |
| Planner plan and bucket IDs | Use owner-provided Power Automate Planner Standard connector evidence for `groupId=96c5b0c4-46cc-46cd-8695-50451db74994`, `planId=-1kBj1PLv0qQM-R4PwkqbpcABv_P`, and existing buckets only: `Concluido`, `Piloto e Implantacao`, `Em andamento`, `Testes`, `Cancelado`, `Pendente` | PASS OWNER EVIDENCE for AQ-04 read-only discovery: `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`; no Planner write authorization |
| Task-level Planner schema | Future `Tarefas` fields approved: `PlannerTaskId`, `PlannerBucketId`, `PlannerSyncStatus`, `PlannerLastSyncAt`, `PlannerSyncError` | `.planning/architecture/PLANNER_TASK_MAPPING_SCHEMA_DECISION_20260514.md`; no schema write authorized in this turn |
| Planner links | Suppressed in P0 cards | Owner decisions and schema decision; do not expose Planner links until later approval |

## 1. Gate Summary

| Gate | Objective | Current Status | Primary Blockers |
|---|---|---|---|
| Gate 1 - Director visibility | Director receives short Copilot answer and portfolio Adaptive Card without `ContentFiltered` | Route ready; implementation/runtime pending | Executive card/flow not yet runtime-proved. Board route is owner-confirmed. |
| Gate 2 - PM update reliability | Structured and single-box review cards write status after confirmation | Route ready; implementation/runtime pending | PM status route is owner-confirmed as `QA_Projetos`; card/flow runtime proof pending. |
| Gate 3 - Task + Planner | Task list/create/update are card-first and Planner sync works when mapped | Partially ready; Planner runtime/write gates blocked | Task direct-chat route, schema direction, and AQ-04 Planner ID discovery are owner-confirmed; AQ-03 schema write, AQ-07 flow save/import, AQ-08 Copilot publish/update, AQ-09 runtime smoke/XPIA, and AQ-10 final release remain blocked/pending. |
| Gate 4 - Release | All P0 evidence, rollback, owner go/no-go complete | Not ready | Depends on Gates 1-3 plus runtime screenshots and run IDs. |

## 2. Evidence Source Rules

| Evidence Type | Accepted Evidence | Not Accepted |
|---|---|---|
| Local static evidence | File path, gate script output, schema snapshot, JSON size check, package hash | Uncited claims |
| Runtime Teams evidence | Screenshot, timestamp, channel/chat target, card name/version, submit result | Verbal-only pass |
| Power Automate evidence | Flow name, run ID/URL, start/end time, status, key input/output status codes | Raw connector payload pasted into Copilot |
| SharePoint evidence | Item ID, list, key fields before/after, read-only snapshot | Unbounded full list export in chat |
| Planner evidence | Plan ID, bucket ID, task ID, action run, before/after status | Graph/raw Planner JSON in Copilot |

## 3. Director Visibility Matrix

| Test ID | Scenario | Preconditions | Steps | Expected Result | Evidence Needed | Status |
|---|---|---|---|---|---|---|
| `DV-01` | Copilot executive query returns short acknowledgement | Bot published; executive flow/card route configured to `board.status` | Ask approved executive status phrase from smoke command doc | Copilot gives bounded summary/ack and does not list raw rows | Chat screenshot/transcript, no `ContentFiltered` | Route confirmed; pending runtime |
| `DV-02` | Executive portfolio card posts to Board route | `board.status` owner-confirmed by group/channel IDs for `Projetos_Transformacao_Digital` route | Trigger executive summary | Teams card appears in confirmed route | Teams screenshot with card version, route, timestamp | Route confirmed; pending runtime |
| `DV-03` | Portfolio counts match SharePoint | Active projects available | Compare card totals to SharePoint `Projetos` active/non-deleted rows | Totals and RAG counts match | SharePoint read-only snapshot and card screenshot | Pending |
| `DV-04` | Red projects action | At least one red project exists | Click red projects action | Card/drilldown shows bounded red-project list | Screenshot and action payload/run ID | Pending |
| `DV-05` | Projects without update action | Projects with stale/missing update exist | Click no-update action | Card shows bounded list, no raw JSON | Screenshot and flow run ID | Pending |
| `DV-06` | Request PM update action | `pm.status.updates` owner-confirmed as `QA_Projetos` | Click request-update for one project | PM update request appears in `QA_Projetos` or controlled route result is shown | Director card screenshot, `QA_Projetos` screenshot, run ID | Route confirmed; pending runtime |
| `DV-07` | XPIA regression | Known repro available | Run `listar tarefas do projeto QA Robust 20260513 F` after card-first implementation | No `ContentFiltered` / `openAIIndirectAttack`; Copilot remains static | Chat transcript and flow/card evidence | Pending |

## 4. PM Update Matrix

| Test ID | Scenario | Preconditions | Steps | Expected Result | Evidence Needed | Status |
|---|---|---|---|---|---|---|
| `PMU-01` | Structured status card submit | `pm.status.updates` route confirmed as `QA_Projetos`; active project exists | Submit RAG, percent, summary, risk, blocker, next action from smoke command doc | `Status Diario` row created and `Projetos` fields updated | `QA_Projetos` card screenshot, flow run ID, SharePoint before/after | Route confirmed; pending runtime |
| `PMU-02` | Single-box multiline parse | Review card implemented and routed to `QA_Projetos` | Submit multiline text block from smoke command doc | Review card displays parsed fields before write | Input text, `QA_Projetos` review card screenshot, parser run ID | Route confirmed; pending runtime |
| `PMU-03` | Review-before-write confirm | Parsed review card displayed | Confirm review card | SharePoint writes only after confirmation | Flow run ID and SharePoint item evidence | Pending |
| `PMU-04` | Invalid project blocked | No matching active project | Submit update for invalid project | Controlled validation error; no SharePoint write | Flow run evidence and no-write check | Pending |
| `PMU-05` | Invalid RAG blocked | Active project exists | Submit unsupported RAG | Controlled validation error; no SharePoint write | Card/flow evidence | Pending |
| `PMU-06` | Percent outside 0-100 blocked | Active project exists | Submit invalid percent | Controlled validation error; no SharePoint write | Card/flow evidence | Pending |

## 5. Task and Planner Matrix

| Test ID | Scenario | Preconditions | Steps | Expected Result | Evidence Needed | Status |
|---|---|---|---|---|---|---|
| `TPL-01` | Task list card | Active project with tasks exists; `task.card.route` owner-confirmed as direct chat to `mbenicios@minsait.com` | Trigger task list from smoke command doc | Teams direct-chat card lists bounded active tasks; Copilot static only | Chat screenshot, direct-chat card screenshot, flow run ID | Route confirmed; pending runtime |
| `TPL-02` | Create task in SharePoint only when no Planner mapping | Project without Planner IDs | Submit create task card | SharePoint task created; Planner skipped with controlled status | SharePoint item and flow run | Pending |
| `TPL-03` | Create task with Planner mapping | AQ-04 Planner IDs accepted as owner evidence; task-level schema deployed through owner-approved runbook; Planner write approval granted | Submit create task card | SharePoint task created first; Planner task created second; mapping stored | Flow run, SharePoint item, Planner task evidence | Blocked by AQ-03/AQ-07/AQ-08/AQ-09/AQ-10; AQ-04 PASS OWNER EVIDENCE only, no Planner write authorization |
| `TPL-04` | Update task with Planner mapping | Existing `PlannerTaskId` stored after schema deployment; Planner write approval granted | Submit update card | SharePoint and Planner update; sync status recorded | Flow run, SharePoint before/after, Planner before/after | Blocked by AQ-03/AQ-07/AQ-08/AQ-09/AQ-10; AQ-04 PASS OWNER EVIDENCE only, no Planner write authorization |
| `TPL-05` | Planner failure handling | Controlled Planner failure path | Submit create/update with invalid/blocked Planner target | SharePoint audit remains; sync status records error; PMO alerted | Flow run, SharePoint status, PMO alert route evidence | Pending |
| `TPL-06` | Invalid UPN blocked | Invalid responsible UPN | Submit create/update card | Controlled validation; no Planner write | Flow run and no-write evidence | Pending |
| `TPL-07` | Invalid date blocked | Invalid due date | Submit create/update card | Controlled validation; no SharePoint/Planner write | Flow run and no-write evidence | Pending |

## 6. Card Robustness Matrix

| Test ID | Scenario | Expected Result | Evidence Needed | Status |
|---|---|---|---|---|
| `CARD-P0-01` | Card JSON schema validation | Adaptive Card schema valid | Static validator output | Pending |
| `CARD-P0-02` | Card size guardrail | Under 27 KB hard limit, target under 20 KB | Size report per card | Pending |
| `CARD-P0-03` | Teams desktop render | No broken layout; actions visible | Screenshot | Pending |
| `CARD-P0-04` | Teams web render | No broken layout; actions visible | Screenshot | Pending |
| `CARD-P0-05` | Click action metadata | `operationId`, `cardVersion`, `source=AdaptiveCard`, IDs present | JSON/action payload inspection | Pending |
| `CARD-P0-06` | Error/fallback card | Validation failures show controlled card | Screenshot and run ID | Pending |

## 7. Release Evidence Checklist

| Evidence ID | Item | Owner | Status |
|---|---|---|---|
| `REL-E01` | Teams routing inventory completed and owner-confirmed | CODEX-QA + Owner | Complete for P0 route decisions; runtime evidence pending |
| `REL-E02` | Planner readiness inventory completed and owner-confirmed | CODEX-QA + Owner | PASS OWNER EVIDENCE for AQ-04 plan/bucket IDs via `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`; runtime/write evidence still pending |
| `REL-E03` | Executive card JSON reviewed | CODEX-CARDS / CODEX-LEAD | Pending |
| `REL-E04` | PM update cards reviewed | CODEX-CARDS / CODEX-LEAD | Pending |
| `REL-E05` | Task cards reviewed | CODEX-CARDS / CODEX-LEAD | Pending |
| `REL-E06` | Flow run IDs captured for all P0 paths | GEMINI-PA + Owner | Pending |
| `REL-E07` | SharePoint before/after snapshots captured | Owner + CODEX-QA | Pending |
| `REL-E08` | Planner task evidence captured | Owner + CODEX-QA | Pending |
| `REL-E09` | No `ContentFiltered` on known repro | Owner + CODEX-QA | Pending |
| `REL-E10` | Rollback plan available | CODEX-LEAD | Pending |
| `REL-E11` | Owner go/no-go recorded | Owner + CODEX-LEAD | Pending |

## 8. Current Blockers and Dependencies

| Blocker ID | Blocker | Needed From | Blocks |
|---|---|---|---|
| `QA-BLK-ROUTE-01` | Confirm Board/PMO/PM Teams routing policy and IDs | Owner | Resolved for P0: `board.status`, `pmo.ops`, `pm.status.updates`, and `task.card.route` are owner-confirmed; runtime proof still pending |
| `QA-BLK-PLN-01` | Confirm pilot PlannerGroupId and PlannerPlanId | Owner Power Automate evidence | Resolved for AQ-04 planning baseline: PASS OWNER EVIDENCE; does not authorize Planner writes |
| `QA-BLK-PLN-02` | Confirm Planner bucket IDs | Owner Power Automate evidence | Resolved for AQ-04 deterministic mapping baseline: PASS OWNER EVIDENCE; does not authorize Planner writes |
| `QA-BLK-PLN-03` | Decide task-level Planner mapping storage | CODEX-LEAD / P3 contract owner | Resolved as design decision: fields approved for future execution; actual SharePoint schema write remains separately gated |
| `QA-BLK-CARD-01` | P0 card JSON not complete yet | CODEX-CARDS | Card static/render tests |
| `QA-BLK-FLOW-01` | P0 card/controller flows not complete yet | GEMINI-PA | Runtime evidence |
| `QA-BLK-ACCESS-01` | Planner bucket ID discovery must use master runbook only; `m365` is forbidden | Owner-approved read-only discovery executor | Planner bucket ID evidence |

## 9. Immediate Next QA Actions

1. Use `.planning/comms/P0_RUNTIME_SMOKE_COMMANDS_ADAPTIVE_CARDS_PLANNER_20260514.md` as the owner runtime smoke queue after implementation/import/publish approval.
2. Capture screenshots for `board.status`, `QA_Projetos`, and direct chat to `mbenicios@minsait.com`.
3. Use AQ-04 owner-provided Planner IDs as the read-only mapping baseline; do not perform Planner writes from this evidence and do not use `m365`.
4. After cards exist, run static schema/size/action metadata checks.
5. After owner import/publish/runtime approval, capture runtime evidence in this matrix.

## 10. Remaining Stop-Ship Gates

| Approval Queue | Status | Release Impact |
|---|---|---|
| `AQ-03` | Pending/blocked | SharePoint `Tarefas` schema write evidence still required. |
| `AQ-07` | Pending/blocked | Flow save/import evidence still required. |
| `AQ-08` | Pending/blocked | Copilot publish/update evidence still required. |
| `AQ-09` | Pending/blocked | Runtime smoke and XPIA regression evidence still required. |
| `AQ-10` | Pending/blocked | Final owner go/no-go still required. |

Current release decision: `NO-SHIP`.
