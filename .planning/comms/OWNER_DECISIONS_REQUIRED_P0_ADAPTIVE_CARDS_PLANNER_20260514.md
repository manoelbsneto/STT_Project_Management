# Owner Decisions Required: P0 Adaptive Cards + Planner

Date: 2026-05-14  
Owner: Project owner  
Prepared by: CODEX-LEAD  
Status: Owner decisions captured; Planner bucket IDs still require approved read-only discovery via master runbook

## 1. Why This Is Needed

The first sub-agent wave is complete. Governance docs, visual standards, and readiness inventories are ready.

Before a deploy engineer builds Power Automate flows, we need to avoid hard-coding wrong Teams routes or Planner IDs.

No tenant changes have been executed.

## 2. Decisions Required

### Decision 1 - Executive / Board Card Route

Question:

Should the P0 executive portfolio card be posted in the existing official channel?

Known local route:

| Field | Value |
|---|---|
| Team/Group ID | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| Channel ID | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` |
| Channel name | `Projetos_Tranformação_Digital` |

Recommended P0 answer:

```text
YES - use Projetos_Tranformação_Digital as board.status for P0.
```

Owner answer:

```text
board.status = APPROVED
route = Projetos_Tranformação_Digital
groupId = 96c5b0c4-46cc-46cd-8695-50451db74994
channelId = 19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2
```

### Decision 2 - PMO Operations Route

Question:

Where should operational alerts go, such as Planner sync failures or PM update failures?

Options:

1. Use the same official channel for P0.
2. Provide separate PMO operations channel ID.
3. Defer PMO ops alerts and log only in SharePoint/flow run history for first proof.

Recommended P0 answer:

```text
Use the same official channel for controlled P0, then split later.
```

Owner answer:

```text
pmo.ops = APPROVED
route = Projetos_Tranformação_Digital for P0
groupId = 96c5b0c4-46cc-46cd-8695-50451db74994
channelId = 19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2
```

### Decision 3 - PM Update Card Route

Question:

How should PMs receive update cards?

Options:

1. Direct chat to PM UPN from `Projetos.PM`.
2. Official Teams channel.
3. Project-specific channel, if project channels exist.

Recommended P0 answer:

```text
Direct chat to PM UPN for PM update/review cards. If direct chat fails in tenant, fallback to official channel for pilot.
```

Owner answer:

```text
pm.status.updates = QA_Projetos
pm.status.groupId = 96c5b0c4-46cc-46cd-8695-50451db74994
pm.status.channelId = 19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2
fallback = Projetos_Tranformação_Digital only if QA_Projetos route fails during pilot validation
```

### Decision 4 - Project Task Card Route

Question:

Where should task list/create/update cards appear?

Options:

1. Direct chat to requester/PM.
2. Project-specific channel.
3. Official PMO channel for pilot only.

Recommended P0 answer:

```text
Direct chat to requester/PM for P0. Project channel mapping can come later.
```

Owner answer:

```text
task.card.route = direct chat
task.card.targetUpn = mbenicios@minsait.com
task.card.note = temporary P0 requester/PM direct chat route
```

### Decision 5 - Planner Pilot Project

Question:

Which project should be the Planner integration pilot?

Recommended pilot:

```text
QA Robust 20260513 F
ProjectID: PRJ-274E5ACC
SharePoint item ID: 33
```

Owner answer:

```text
planner.pilot.project = any existing project is acceptable for test execution
default.local.candidate = QA Robust 20260513 F / PRJ-274E5ACC / SharePoint item 33
```

### Decision 6 - Planner IDs

Required values for pilot:

```text
PlannerGroupId =
PlannerPlanId =
PlannerPlanName =
LinkPlanner =
```

If these are not available now, we can still design flows with route keys and placeholders, but cannot complete runtime Planner write tests.

### Decision 7 - Planner Bucket Mapping

Required for deterministic create/update:

```text
Pendente bucket name = Pendente
Pendente bucket id = pending approved read-only discovery

Em Andamento bucket name = Em andamento
Em Andamento bucket id = pending approved read-only discovery

Concluida bucket name = Concluido
Concluida bucket id = pending approved read-only discovery

Cancelada bucket name = Cancelado
Cancelada bucket id = pending approved read-only discovery
```

Recommended optional later:

```text
Bloqueada bucket name = no new bucket authorized for P0
Bloqueada bucket id = N/A
```

Owner update 2026-05-14:

```text
planner.bucket.discovery = READ-ONLY AUTHORIZED
observed bucket names from Teams screenshot = Concluido; Piloto e Implantacao (truncated in screenshot); Em andamento; Testes; Cancelado; Pendente
owner confirmation = use exactly these existing buckets for P0; do not add or delete buckets now. CODEX-LEAD must request approval first if a later technical reason requires adding/removing buckets.
bucket IDs = pending read-only discovery
access path = must follow project master docs/runbooks only; Microsoft 365 CLI / m365 is not approved for this discovery
```

### Decision 8 - Task-Level Planner Mapping Storage

Issue:

Local evidence confirms Planner mapping fields on `Projetos`, but not on `Tarefas`.

Missing for durable task create/update:

- `PlannerTaskId`
- `PlannerBucketId`
- task-level `PlannerSyncStatus`
- task-level `PlannerLastSyncAt`

Recommended P0 decision:

```text
Approve adding task-level Planner mapping fields to Tarefas in implementation planning, but do not execute schema changes until owner explicitly approves tenant writes.
```

Owner answer:

```text
task.planner.mapping.storage = APPROVED for future execution via runbook. Add task-level fields to Tarefas: PlannerTaskId, PlannerBucketId, PlannerSyncStatus, PlannerLastSyncAt, PlannerSyncError. No immediate schema change authorized in this turn.
owner reconfirmation = APPROVED; owner noted this approval had already been answered before.
```

## 3. Recommendation

Recommended answers for fastest P0:

```text
board.status = Projetos_Tranformação_Digital
pmo.ops = Projetos_Tranformação_Digital for P0
pm.status.updates = QA_Projetos
task.card.route = direct chat to mbenicios@minsait.com for P0
planner.pilot.project = any existing project acceptable; default candidate QA Robust 20260513 F / PRJ-274E5ACC
task.planner.mapping.storage = add fields to Tarefas, pending owner-approved tenant schema change
```

## 4. Gemini Start Decision

Gemini can start flow design in two modes:

| Mode | Safe Now? | Notes |
|---|---:|---|
| Design with route keys/placeholders only | Yes | No hard-coded final IDs. Useful now. |
| Implement final flow definitions with actual Teams/Planner IDs | No | Needs owner decisions above. |

Recommended:

Start Gemini only for route-key based design after owner confirms that placeholder-based design is acceptable.

Owner update 2026-05-14:

```text
gemini.activation = allowed whenever needed, but CODEX-LEAD must notify owner first so owner can authorize/start Gemini.
current Gemini mode = local/programmatic design only; no tenant execution.
owner reconfirmation = Gemini may act at any moment under owner authorization.
```
