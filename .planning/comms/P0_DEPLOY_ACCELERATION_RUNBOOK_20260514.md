# P0 Deploy Acceleration Runbook: Adaptive Cards + Planner

Date: 2026-05-14
Owner: CODEX-LEAD
Status: ACTIVE - acceleration path
Scope: local preparation first; tenant execution only after owner approval

## 1. Objective

Accelerate delivery of the non-STT P0 solution:

1. executive visibility functional;
2. PM status updates via Adaptive Cards;
3. task management card-first;
4. Planner integration prepared with safe fallback;
5. no raw SharePoint/Planner output returned to Copilot;
6. no `openAIIndirectAttack` / `ContentFiltered` on known repro.

## 2. Active Decisions

| Area | Decision |
|---|---|
| Executive route | `board.status` -> `Projetos_Tranformação_Digital` |
| PMO ops route | `pmo.ops` -> `Projetos_Tranformação_Digital` for P0 |
| PM status route | `pm.status.updates` -> `QA_Projetos` |
| Task card route | `task.card.route` -> direct chat `mbenicios@minsait.com` |
| Planner links | Suppressed for P0 |
| Planner buckets | Preserve existing buckets; do not add/delete without owner approval |
| Gemini | May act at any moment after CODEX notifies owner and owner authorizes |
| Access | Master docs/runbooks only; no `m365` discovery |

## 3. Parallel Workstream Now Running

| Workstream | Owner | Output | Status |
|---|---|---|---|
| Flow design correction and deploy runbook | CODEX-LEAD | This file and reviewed Gemini design | In progress |
| Governance/doc closure | CODEX-DOCS | ADR/PRD/project-control updates | In progress |
| Adaptive Card JSON templates | CODEX-CARDS | `deploy/cards/*.json` P0 templates | In progress |
| QA runtime smoke plan | CODEX-QA | executable smoke command/evidence doc | In progress |
| Power Automate implementation design | GEMINI-PA | flow blueprint/checklist | Rework required before tenant implementation |

## 3.1 SEV-0 Quality Gate Rule

Acceleration does not relax release gates.

CI may be ignored only because it is owner-excluded for this mission. All other gates remain mandatory with no exception.

Before ship/import/publish/runtime release, the decision remains `NO-SHIP` unless every non-CI gate is green and tied to the current artifact.

## 4. Fastest Safe Execution Path

### Step A - Local Artifacts

No tenant approval needed.

| ID | Task | Owner | Target Time |
|---|---|---|---:|
| A1 | Finalize card JSON templates | CODEX-CARDS | 45-60 min |
| A2 | Finalize runtime smoke commands | CODEX-QA | 30-45 min |
| A3 | Close ADR/decision docs | CODEX-DOCS | 30-45 min |
| A4 | Convert Gemini blueprint into implementation checklist | CODEX-LEAD | 30 min |
| A5 | Static card checks: JSON parse, size, required metadata | CODEX-LEAD + QA | 15-30 min |
| A6 | Rework Power Automate implementation checklist to SEV-0 actionable detail | GEMINI-PA | 30-60 min |

### Step B - Owner Approval Gate 1

Ask owner approval for read-only tenant/runtime discovery only.

Required read-only actions:

| ID | Action | Access Path | Mutation |
|---|---|---|---|
| B1 | Validate Planner plan context for `-1kBj1PLv0qQM-R4PwkqbpcABv_P` | Master runbook / approved remote path | No |
| B2 | Discover Planner bucket IDs using Planner Standard connector or approved runbook path | Master runbook / approved remote path | No |
| B3 | Validate Teams route availability for `QA_Projetos` and direct chat target | Master runbook / runtime test after owner approval | No or controlled test post only if approved |

### Step C - Owner Approval Gate 2

Ask owner approval for tenant schema/runtime changes.

Required write actions:

| ID | Action | Why Needed |
|---|---|---|
| C1 | Add Planner mapping fields to `Tarefas` | Required for durable Planner create/update sync |
| C2 | Import/update Power Automate flows | Required for card-first runtime |
| C3 | Import/update Copilot topics | Required to keep Copilot as static router |
| C4 | Publish bot | Required for runtime validation |

### Step D - Runtime Proof

Run only after owner import/publish approval.

| Gate | Must Prove |
|---|---|
| Director visibility | Card appears in Board route, Copilot remains bounded/static |
| PM status update | Card posts to `QA_Projetos`, review-before-write works |
| Task cards | Cards arrive in direct chat to `mbenicios@minsait.com` |
| Planner | Create/update sync works when IDs are present; if Planner fails, SharePoint audit remains |
| XPIA regression | Known list/update repro does not trigger `ContentFiltered` |

## 5. Immediate CODEX-LEAD Recommendation

Do not wait for full Planner write readiness before proving executive visibility.

Deliver in this order:

1. Executive visibility card and flow first.
2. PM status update card second.
3. Task list/create/update cards third with Planner sync conditional.
4. Planner bucket ID discovery and schema update as the controlled bridge to full Planner write proof.

This avoids blocking the angry director scenario on Planner details that are only needed for task sync.

## 6. Hard Stop Rules

Stop before tenant execution if:

- card JSON is invalid;
- card payload exceeds 27 KB;
- card actions lack `operationId`, `cardVersion`, `source`, `action`, and route key;
- flow design returns raw SharePoint/Planner rows to Copilot;
- any agent proposes `m365` discovery;
- owner approval is missing for write actions.

## 7. Next Approval To Request

After local artifacts complete, CODEX-LEAD should request:

```text
Approval for read-only Planner and route validation using the project master runbooks only. No m365. No writes.
```

After read-only validation succeeds, CODEX-LEAD should request:

```text
Approval for P0 tenant execution: add Tarefas Planner mapping fields, import/update flows/topics, publish bot, and run runtime smoke tests.
```
