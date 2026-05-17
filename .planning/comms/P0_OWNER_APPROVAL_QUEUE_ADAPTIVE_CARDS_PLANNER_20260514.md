# P0 Owner Approval Queue: Adaptive Cards + Planner

Date: 2026-05-14
Owner: Project owner
Prepared by: CODEX-LEAD
Status: LOCAL PLANNING ONLY
Release decision: NO-SHIP
Tenant execution: None

## 1. Purpose

This queue converts the accepted local planning baseline into explicit approval gates before any tenant action.

Source baseline:

- `.planning/comms/P0_FLOW_IMPLEMENTATION_CHECKLIST_20260514.md`
- `.planning/comms/CODEX_REVIEW_GEMINI_P0_FLOW_IMPLEMENTATION_REWORK_20260514.md`
- `.planning/comms/OWNER_DECISIONS_REQUIRED_P0_ADAPTIVE_CARDS_PLANNER_20260514.md`
- `.planning/architecture/PLANNER_TASK_MAPPING_SCHEMA_DECISION_20260514.md`
- `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`
- `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`

No approval in this document is implied. Each item below requires explicit owner approval in the current thread before execution.

## 2. Non-Negotiable Gate Rule

CI may be ignored only when owner-excluded.

Every other quality gate is mandatory. If any non-CI gate is missing, failed, stale, unverified, or not tied to the current artifact, the release decision remains:

```text
NO-SHIP
```

## 3. Approval Queue

| Queue ID | Action | Type | Current status | Required owner approval | Output evidence |
|---|---|---|---|---|---|
| AQ-01 | Confirm local P0 implementation baseline | Local planning | READY | Owner accepts Gemini checklist as implementation planning baseline, not deploy approval | This document plus CODEX review |
| AQ-02 | Reconcile live SharePoint `Tarefas` schema read-only | Tenant read-only | DONE_READONLY | Owner approved read-only schema check; evidence at `.planning/comms/AQ02_SHAREPOINT_TAREFAS_SCHEMA_READONLY_20260515.md` | Field inventory artifact |
| AQ-03 | Add Planner mapping fields to `Tarefas` | Tenant write | DONE_TENANT_WRITE | Owner approved AQ-03 in current thread; all five Planner mapping fields created; evidence at `.planning/comms/AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md` | Before/after field evidence |
| AQ-04 | Discover Planner plan and bucket IDs | Tenant read-only | DONE_OWNER_EVIDENCE | Owner provided Power Automate Planner Standard connector evidence; see `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md` | Planner ID inventory artifact |
| AQ-05 | Build local Power Automate flow artifacts | Local implementation | DONE_LOCAL | Owner approved local-only execution; artifacts created under `.planning/comms/p0_flow_artifacts_20260514` | Local files plus validation note |
| AQ-06 | Static validate local flow/card/package artifacts | Local validation | DONE_LOCAL_REFRESHED | Owner approved local-only validation; refreshed report created at `.planning/comms/AQ06_LOCAL_STATIC_VALIDATION_REVIEW_20260515.md`; Card-to-Flow contract fix recorded at `.planning/comms/P0_CARD_FLOW_ACTION_CONTRACT_FIX_20260515.md` | Static gate report plus contract fix report |
| AQ-07 | Save/import Power Automate flows | Tenant write | READY_FOR_OWNER_APPROVAL_REQUEST | Gemini AQ-07 portal-build package passed CODEX local review; see `.planning/comms/CODEX_REVIEW_GEMINI_AQ07_FINAL_PASS_20260515.md`. Requires explicit owner approval before any Power Automate tenant action. | Import/save evidence, flow IDs |
| AQ-08 | Publish/update Copilot routing topics | Tenant write | BLOCKED | Approve exact topic/publish action and rollback plan | Publish evidence |
| AQ-09 | Runtime smoke test in Teams/Copilot | Tenant runtime | BLOCKED | Approve smoke test script and target pilot data | Screenshots, run IDs, SharePoint/Planner evidence |
| AQ-10 | Final SHIP/NO-SHIP decision | Release decision | BLOCKED | Owner reviews all non-CI gates tied to current artifact | Release readiness checklist |

## 4. Exact Approval Texts To Request Later

### AQ-02: SharePoint Schema Read-Only Check

Request text:

```text
Approve CODEX-LEAD to run a read-only SharePoint schema check for the `Tarefas` list using the approved master runbook path only. No schema writes, no item writes, no Planner writes, no flow saves, no imports, and no publishes are authorized.
```

Required pre-command check-in:

- master docs read;
- exact command/access route;
- read-only classification;
- output artifact path.

### AQ-03: SharePoint Schema Write

Request text:

```text
Approve CODEX-LEAD to add these fields to SharePoint list `Tarefas`, using idempotent read-before-write logic and the approved SharePoint runbook only: PlannerTaskId, PlannerBucketId, PlannerSyncStatus, PlannerLastSyncAt, PlannerSyncError. No Planner writes, flow saves, imports, or publishes are authorized by this approval.
```

Field plan:

| Display Name | Internal Name | Type | Required | Choices |
|---|---|---|---:|---|
| Planner Task ID | `PlannerTaskId` | Single line text | No | N/A |
| Planner Bucket ID | `PlannerBucketId` | Single line text | No | N/A |
| Planner Sync Status | `PlannerSyncStatus` | Choice | No | `Pendente`, `OK`, `Erro`, `Ignorado` |
| Planner Last Sync At | `PlannerLastSyncAt` | Date and time | No | N/A |
| Planner Sync Error | `PlannerSyncError` | Multiple lines text | No | N/A |

### AQ-04: Planner Read-Only Discovery

Request text:

```text
Approve CODEX-LEAD to perform read-only Planner discovery for the P0 pilot through the approved master runbook/access path only. Microsoft 365 CLI / m365 is forbidden. No Planner task creation, update, bucket creation, bucket deletion, SharePoint writes, flow saves, imports, or publishes are authorized.
```

Required values:

- `PlannerGroupId`
- `PlannerPlanId`
- `PlannerPlanName`
- existing bucket IDs for existing buckets only

Owner-approved existing bucket names from screenshot:

- `Concluido`
- `Piloto e Implantacao` or exact full tenant name from discovery
- `Em andamento`
- `Testes`
- `Cancelado`
- `Pendente`

Do not add or delete buckets for P0.

### AQ-05: Local Flow Implementation Artifacts

Request text:

```text
Approve CODEX-LEAD or assigned implementer to create local Power Automate flow definition/pseudocode artifacts from `.planning/comms/P0_FLOW_IMPLEMENTATION_CHECKLIST_20260514.md`. Local files only. No tenant flow save, import, publish, SharePoint write, Planner write, or Teams production post is authorized.
```

Expected local outputs:

- one implementation artifact per P0 flow or a structured local package folder;
- static Copilot output contract;
- route key map;
- schema dependency map;
- Planner conditional behavior map;
- rollback notes.

## 5. Flow Implementation Split

| Work item | Flow | Route key | Card template | Tenant dependency |
|---|---|---|---|---|
| FI-01 | `PMO_PA_Card_ResumoExecutivoPortfolio` | `board.status` | `ResumoExecutivoPortfolio.json` | SharePoint read, Teams post |
| FI-02 | `PMO_PA_Card_AtualizarStatus` | `pm.status.updates` | `AtualizarStatusSingleBoxReviewCard.json`, `AtualizarStatusCard.json` | SharePoint write, Teams post |
| FI-03 | `PMO_PA_Card_ListarTarefas` | `task.card.route` | `ListarTarefasProjetoCard.json` | SharePoint read, Teams direct chat |
| FI-04 | `PMO_PA_Card_CriarTarefa` | `task.card.route` | `CriarTarefaCard.json` | SharePoint write, Planner create |
| FI-05 | `PMO_PA_Card_AtualizarTarefa` | `task.card.route` | `AtualizarTarefaCard.json` | SharePoint write, Planner update |
| FI-06 | Ops failure handling | `pmo.ops` | static alert card or Teams message | Teams post, sanitized errors |

## 6. Mandatory Gates Before Runtime Ship

| Gate | Current state | Required before SHIP |
|---|---|---|
| Card static validation | PASS local | Keep tied to final card files |
| Route decisions | PASS local | Runtime route evidence |
| SharePoint schema | PASS AQ-03 | AQ-02 read-only proof plus AQ-03 approved schema write evidence are complete |
| Planner IDs | PASS OWNER EVIDENCE | Owner-provided Power Automate Planner Standard connector evidence tied to `groupId`, `planId`, bucket IDs, and current task IDs |
| Flow static output | PASS LOCAL WITH RUNTIME PENDING | Actual flow artifact inspection refreshed locally; keep no raw SP/Planner output to Copilot and prove it again after final importable artifacts |
| Package/import | PENDING | Owner-approved import/save evidence |
| Copilot publish | PENDING | Owner-approved publish evidence |
| Runtime smoke | PENDING | Teams/Copilot screenshots, run IDs, SP/Planner before-after evidence |
| XPIA regression | PENDING | Known repro shows no `ContentFiltered` / `openAIIndirectAttack` |
| Rollback | PENDING | Specific rollback steps for schema, flows, topics, and route posts |

## 7. Current Recommendation

Proceed in this order:

1. Wait for Gemini's final local Power Automate package/rework output.
2. Review final local package against AQ-06/AQ-04/AQ-03 evidence.
3. Request AQ-07 owner approval for exact Power Automate save/import path.
4. Continue AQ-08 through AQ-09 only after AQ-07 evidence and rollback detail are complete.
5. Re-run AQ-04 read-only discovery later only if the Planner plan or buckets change before runtime validation.

## 8. Current Release Status

```text
NO-SHIP
```

Reason:

- AQ-03 schema write evidence is complete;
- Planner bucket IDs are owner-provided via Power Automate Planner Standard connector evidence, but runtime write evidence is still missing;
- local flow/card static validation is complete, but final importable artifact validation is still pending;
- no owner-approved import/publish;
- no runtime smoke evidence;
- no XPIA regression evidence;
- rollback detail is not complete enough for tenant execution.

No tenant writes were performed while creating this queue.
