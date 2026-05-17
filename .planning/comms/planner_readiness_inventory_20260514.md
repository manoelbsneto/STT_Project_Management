# Planner Readiness Inventory - Adaptive Cards + Planner P0

Date: 2026-05-14  
Owner: CODEX-QA  
Status: Refreshed 2026-05-15 for AQ-04 owner-provided Planner ID evidence  
Scope: Read-only local documentation/evidence. No Planner writes, no SharePoint writes, no flow saves.

Release decision remains `NO-SHIP`. AQ-04 owner-provided Planner IDs are accepted only as Power Automate Planner Standard connector read-only discovery evidence; they do not authorize Planner writes, SharePoint writes, flow saves/imports, Copilot publish/update, Teams production posts, or SHIP.

## 1. Readiness Summary

| Area | Current Readiness | Evidence Basis | Release Impact |
|---|---|---|---|
| Standard-only Planner approach | Confirmed as architecture decision | `PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md` | Use Planner Standard connector; no Graph/direct HTTP/Premium. |
| Planner sync flow exists | Confirmed locally | `.planning/comms/adaptive_cards_flow_inventory_20260513/flow_inventory.json` | Existing flow can inform P0 sync/readiness, but runtime proof is still open. |
| `Projetos` has Planner mapping fields | Confirmed locally | `.planning/comms/sharepoint_schema_xml_20260513/Projetos/fields_summary.csv` | Supports plan-level sync and executive metrics. |
| Pilot plan/group IDs | PASS OWNER EVIDENCE for AQ-04 read-only discovery | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`; Power Automate Planner connector `statusCode 200` evidence | Supports local mapping baseline only; runtime/write gates remain blocked. |
| Bucket names | Confirmed by owner from current Planner board screenshot | Owner confirmed existing bucket set on 2026-05-14 | Use existing buckets only for P0; do not add/delete buckets without separate approval. |
| Bucket IDs | PASS OWNER EVIDENCE for AQ-04 read-only discovery | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`; `ListBuckets_V3` returned `statusCode 200` and 6 buckets | Deterministic mapping baseline is available; does not authorize Planner writes. |
| `Tarefas` has Planner task mapping fields | Not confirmed; local schema gap | `Tarefas/fields_summary.csv` has no `PlannerTaskId`, `PlannerBucketId`, or task sync status fields | Blocks durable Planner create/update evidence unless schema is extended or mapping is stored elsewhere. |

## 2. Architecture Constraints

| Constraint | Required P0 Position | Source |
|---|---|---|
| No Microsoft Graph direct | Do not use Graph REST or HTTP with Entra ID for P0 flows | Adjusted PRD v1.3 |
| No Premium connectors | Use only standard connectors | Adjusted PRD v1.3 |
| Planner product | Planner Basic only | Adjusted PRD v1.3 |
| Planner connector | Power Automate Planner Standard connector | Adjusted PRD v1.3 |
| SharePoint source of record | SharePoint write first, Planner write second, then update sync status | Adaptive Cards + Planner architecture |
| Copilot output | No raw SharePoint or Planner JSON in chat | Adaptive Cards + Planner architecture and XPIA RCA |

## 3. Existing Planner Flow Inventory

| Flow | Flow ID | State | Last Local Evidence | Readiness |
|---|---|---|---|---|
| `PMO_PA_SyncPlannerStats_Standard` | `3eb1be49-a9ff-48ca-888d-847ca7ae8b04` | `Started` in local inventory | `.planning/comms/adaptive_cards_flow_inventory_20260513/flow_inventory.json` | Structurally present; runtime proof still pending. |

Open evidence gap: `PLN-01` no longer lacks AQ-04 plan IDs, but still requires owner-approved runtime execution, a green sync flow run, updated metrics in `Projetos`, and error recording if the run fails.

## 4. SharePoint Planner Fields

### 4.1 `Projetos` fields confirmed locally

| Field | Type | Required | Purpose |
|---|---|---:|---|
| `PlannerGroupId` | Text | No | Microsoft 365 group backing the Planner plan. |
| `PlannerPlanId` | Text | No | Planner plan ID used for sync/create/update. |
| `LinkPlanner` | URL | No | Optional approved Planner link for card/open actions. |
| `TarefasTotal` | Number | No | Planner metric. |
| `TarefasAbertas` | Number | No | Planner metric. |
| `TarefasConcluidas` | Number | No | Planner metric. |
| `TarefasAtrasadas` | Number | No | Planner metric. |
| `PlannerLastSyncAt` | DateTime | No | Last Planner sync timestamp. |
| `PlannerSyncStatus` | Choice: `OK`, `Erro`, `Pendente` | No | Sync health. |

### 4.2 `Tarefas` local schema gap

Local `Tarefas` schema currently shows task operational fields such as `ProjectID`, `Responsavel`, `DataInicio`, `DataFim`, `HorasEstimadas`, `HorasRealizadas`, `Status`, `Prioridade`, and soft-delete fields. It does not show these Planner create/update mapping fields:

| Needed Field | Purpose | Current Local Status | Impact |
|---|---|---|---|
| `PlannerTaskId` | Store Planner task ID returned after create | Not found in local schema | Needed to update the same Planner task later. |
| `PlannerBucketId` | Store bucket used for task | Not found in local schema | Needed for bucket-aware updates and audit. |
| `PlannerSyncStatus` or task-level equivalent | Store task sync result | Not found in local schema | Needed to distinguish SharePoint success from Planner failure. |
| `PlannerLastSyncAt` or task-level equivalent | Store task sync timestamp | Not found in local schema | Needed for operational evidence and retries. |

Recommendation for P3 contract owner: either add task-level Planner mapping fields to `Tarefas`, or explicitly document an alternate storage location before implementing Planner create/update.

## 5. Required Planner Mapping Template

| ProjectID | Project Name | SharePoint Item ID | PlannerGroupId | PlannerPlanId | Planner Plan Name | LinkPlanner | Mapping Status | Owner Confirmed | Evidence |
|---|---|---:|---|---|---|---|---|---|---|
| `PRJ-274E5ACC` | `QA Robust 20260513 F` | `33` | `96c5b0c4-46cc-46cd-8695-50451db74994` | `-1kBj1PLv0qQM-R4PwkqbpcABv_P` | `Desenvolvimento de Software` | Planner links suppressed for P0 | Default local candidate mapped to AQ-04 owner evidence | PASS OWNER EVIDENCE for AQ-04 | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` |
| `PRJ-001` | `Mobile App Corporativo` | `1` | Pending | Pending | Pending | Pending | Active sample project; IDs missing in local snapshot | No | `active_projects_latest.csv` |
| `PRJ-002` | `Migracao Cloud Azure` | `2` | Pending | Pending | Pending | Pending | Active sample project; IDs missing in local snapshot | No | `active_projects_latest.csv` |
| `PRJ-003` | `Portal do Colaborador` | `3` | Pending | Pending | Pending | Pending | Red sample project; IDs missing in local snapshot | No | `active_projects_latest.csv` |
| `PRJ-004` | `Data Lake Analytics` | `4` | Pending | Pending | Pending | Pending | Active sample project; IDs missing in local snapshot | No | `active_projects_latest.csv` |
| `PRJ-005` | `Automacao RPA Financeiro` | `5` | Pending | Pending | Pending | Pending | Active sample project; IDs missing in local snapshot | No | `active_projects_latest.csv` |

## 6. Bucket Mapping Template

| Local Task Status | Planner Bucket Name | PlannerBucketId | Planner Percent Complete | Required for P0 | Owner Confirmed | Evidence |
|---|---|---|---:|---|---|---|
| `Pendente` | Pendente | `HmzyGOgC4k6uOPm_cwG3zZcAGiAG` | `0` | Yes | PASS OWNER EVIDENCE for AQ-04 | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` |
| `Em Andamento` | Em andamento | `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG` | Connector-supported in-progress convention | Yes | PASS OWNER EVIDENCE for AQ-04 | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` |
| `Concluida` | Concluido | `F2WYUsnXeEue5qlwQuu3GJcAN1Ns` | `100` | Yes | PASS OWNER EVIDENCE for AQ-04 | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` |
| `Cancelada` | Cancelado | `90TcFTFup0CjiHIdzY4gG5cALWKL` | Implementation decision | Yes for cancel path | PASS OWNER EVIDENCE for AQ-04 | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` |
| `Teste` / validation route | Testes | `7QYPufh54kum7MP4KUzzAZcAL6Ik` | Implementation decision | Optional | PASS OWNER EVIDENCE for AQ-04 | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` |
| `Piloto` / deployment route | Piloto e Implantacao | `4YAXH7iU9E-6jZE2P1DbG5cAMAzH` | Implementation decision | Optional | PASS OWNER EVIDENCE for AQ-04 | `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` |
| `Bloqueada` | No bucket authorized for P0 | N/A | N/A | No | Do not add for P0 | Owner asked to preserve existing buckets unless CODEX requests approval later |

Note: local `Tarefas.Status` choices are treated as ASCII-safe app-facing values for P0: `Pendente`, `Em Andamento`, `Concluida`, and `Cancelada`. `Bloqueada` is mentioned in architecture but is not present in the local `Tarefas` schema choices, and no new Planner bucket is authorized for P0.

## 7. Planner Action Readiness

| P0 Capability | Required Inputs | Current Local Readiness | Blocking Gap |
|---|---|---|---|
| Sync Planner metrics | `PlannerGroupId`, `PlannerPlanId`, Planner Standard connection, active project mapping | Flow exists; `Projetos` fields exist; AQ-04 plan IDs accepted as owner evidence | Green runtime sync evidence missing. |
| Create Planner task | Project mapping, bucket ID, title, assignee/UPN, due date, status mapping | Architecture defined; AQ-04 plan/bucket IDs accepted as owner evidence | Planner write authorization and task-level `PlannerTaskId` storage missing. |
| Update Planner task | Existing `PlannerTaskId`, status mapping, due date/assignee fields | Architecture defined; no local implementation proof | `PlannerTaskId` not present in local `Tarefas` schema. |
| Planner failure handling | SharePoint write first, task/project sync status fields, PMO alert route | Project-level sync status exists | Task-level sync status and PMO ops route not confirmed. |
| Open Planner task link | `LinkPlanner` or task URL policy | Project-level `LinkPlanner` field exists | Link policy and task-link storage not confirmed. |

## 8. QA Evidence Required for Planner Gate

| Evidence ID | Evidence | Required For | Status |
|---|---|---|---|
| `PLN-E01` | Owner-confirmed PlannerGroupId and PlannerPlanId for pilot project | Sync/create/update | PASS OWNER EVIDENCE for AQ-04 via `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`; runtime/write gates still pending |
| `PLN-E02` | Owner-confirmed bucket names and bucket IDs | Create/update | PASS OWNER EVIDENCE for AQ-04 via `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`; runtime/write gates still pending |
| `PLN-E03` | Power Automate run ID/URL for `PMO_PA_SyncPlannerStats_Standard` green run | Sync | Missing |
| `PLN-E04` | SharePoint `Projetos` before/after metrics | Sync | Missing |
| `PLN-E05` | Planner task create evidence for controlled task | Create | Missing |
| `PLN-E06` | SharePoint `Tarefas` stores Planner task mapping | Create/update | Blocked by schema/storage decision |
| `PLN-E07` | Planner update evidence for the same task | Update | Missing |
| `PLN-E08` | Planner failure path records status without losing SharePoint audit | Failure handling | Missing |

## 9. Handoff Notes

- GEMINI-PA should use AQ-04 owner evidence as the canonical read-only plan/bucket mapping baseline, not assumptions.
- Existing buckets must be preserved for P0. Do not add or delete Planner buckets without explicit owner approval.
- P3 task create/update design should treat Planner write as conditional on valid project mapping.
- CODEX-LEAD/P3-01 should decide task-level Planner mapping storage before implementation.
- Owner/runtime validation is still required before `PLN-01` can move from evidence gap to runtime pass.
- Remaining stop-ship approvals are AQ-03, AQ-07, AQ-08, AQ-09, and AQ-10. Current release decision: `NO-SHIP`.
