# Pending Tests And Features - Priority Board

Date: 2026-05-13
Source status: `NO-SHIP`
Environment: `ColOfertasBrasilPro`
Bot: `Assistente PMO V2`
Latest referenced local package: `Solution/PMO_v11_Tarefas_3_4_STOPSHIP_FIX.zip`

This board consolidates the active homologation queue, release blockers, Adaptive Card evidence gaps, Planner evidence gaps, and pending project features. It is intended to be copied into Microsoft Planner buckets or rendered as Adaptive Cards.

## Priority Order

| Priority | ID | Type | Title | Owner | ETA | Depends On | Done When |
|---:|---|---|---|---|---:|---|---|
| 1 | ACT-003 | Feature/Fix | Patch `AtualizarTarefa` skip semantics for `nao`, `nao`, `n`, blank, and `0` where applicable | Codex | 2h | Local source package/edit scope | `CMD-13A` no longer sends invalid values to SharePoint and returns controlled output |
| 2 | ACT-003-T | Test | Add local regression for `AtualizarTarefa` skip semantics | Codex | 45m | ACT-003 | Local test fails before fix and passes after fix |
| 3 | CMD-13A | Runtime Test | Retest `AtualizarTarefa` with optional fields skipped | Manoel + Codex | 20m | ACT-003, import/publish | Bot preserves existing responsible, due date, priority, and hours; no `FlowActionBadGateway` |
| 4 | CMD-12-H | Runtime Test | Verify deleted task `13` is hidden from active `ListarTarefas` | Manoel | 10m | Existing runtime item `13` | `listar tarefas QA Robust 20260513 F` returns no deleted task |
| 5 | SP-AUDIT | Runtime Test | Verify SharePoint soft-delete audit fields for task `13` | Codex/Owner read-only | 15m | CMD-14 pass | Item exists with `Deleted=true`, reason, timestamp, and deleted-by UPN |
| 6 | CMD-09 | Runtime Test | Retest invalid UPN validation for `PedirDecisao` | Manoel | 15m | Published 3.4 or later | Bot rejects `UPN ?` before flow call; no internal server error |
| 7 | CMD-08 | Runtime Test | Retest valid `PedirDecisao` path | Manoel | 15m | CMD-09 | Decision row created with `StatusDecisao=Pendente` and card posted |
| 8 | CMD-15 | Runtime Test | Recheck `consultar portfolio` totals | Manoel | 10m | Task CRUD verification | Bot totals match active, non-deleted SharePoint records |
| 9 | CMD-10 | Feature/Test | Fix or formally accept reduced criteria for `AtualizarStatus` multiline extraction | Product owner + Codex | 2h fix / 30m decision | Product decision | `Risco`, `Bloqueio`, `ProximaAcao`, and `Percentual` populate when provided, or limitation is accepted |
| 10 | LOCAL-FULL | Test | Run full local static regression suite | Codex | 45m | ACT-003 and any parser fix | All relevant `tests/Test-*.ps1` gates pass against the candidate package/source |
| 11 | CARD-01 | Adaptive Card Test | Validate `PMO_PA_RegistrarDecisaoBoard` approve/reject/defer card actions | Owner + Codex | 30m | CMD-08 decision row/card | `StatusDecisao`, `Resposta`, `Justificativa`, `DataResposta`, `ResponseSource`, and `CardVersion` update |
| 12 | CARD-02 | Adaptive Card Test | Validate `PMO_PA_CheckInOnDemand` submit path | Owner + Codex | 25m | Active project | `Status Diario` row created and `Projetos` updated |
| 13 | CARD-03 | Decision/Feature | Decide canonical check-in flow: keep stopped `ProcessarRespostaCheckIn` or replace with `CheckInOnDemand` | Product owner | 30m | Flow inventory review | Runbook/PRD names one canonical flow and release checklist stops referencing the retired path |
| 14 | CARD-04 | Adaptive Card Test | Validate scheduled `PMO_PA_EnviarCheckInDiario` send and submit | Owner + Codex | 35m | CARD-03 | Scheduled card arrives and response writes SharePoint |
| 15 | CARD-05 | Adaptive Card Test | Validate `PMO_PA_AlertaProjetoVermelho` E2E | Owner + Codex | 30m | Controlled test project | Status change to `Vermelho` posts a single accurate Teams alert |
| 16 | CARD-06 | Adaptive Card Test | Validate `PMO_PA_EscalarRiscoCritico` E2E | Owner + Codex | 25m | Active project | Critical risk posts escalation; non-critical risk does not |
| 17 | CARD-07 | Adaptive Card Test | Capture `PMO_PA_ResumoDiarioBoard` run evidence | Owner + Codex | 20m | Current SharePoint data | Daily card renders totals that match SharePoint |
| 18 | CARD-08 | Adaptive Card Test | Capture `PMO_PA_ResumoSemanal` run evidence | Owner + Codex | 20m | Current SharePoint data | Weekly card renders and data matches SharePoint |
| 19 | PLN-01 | Planner Test | Validate `PMO_PA_SyncPlannerStats_Standard` with a pilot Planner Basic plan | Owner + Codex | 45m | Valid `PlannerGroupId` and `PlannerPlanId` | Flow uses Planner Standard `List tasks` and updates task metrics in `Projetos` |
| 20 | GAP-C1 | Admin Decision | Resolve ghost Copilot components by cleanup or risk acceptance | Admin/Product owner | 30m | Discovery report | Old components are deleted by owner or formally accepted as non-release risk |
| 21 | REQ-14 | Feature Validation | Final regression for `CriarProjeto` contract | Manoel + Codex | 25m | Candidate package imported/published | Creates only `Projetos`, generates `ProjectID`, duplicate guard works, confirmation required |
| 22 | REQ-15 | Feature Validation | Final regression for `CriarTarefa` contract | Manoel + Codex | 25m | Active project | Creates only `Tarefas`, links active/non-deleted project, no write to `Projetos` |
| 23 | REQ-16 | Feature Validation | Final regression for `Gerar_Multiplos_Projetos` preview/batch contract | Manoel + Codex | 40m | Candidate package imported/published | Adaptive Card preview before write, multiline/STT fallback, max 10 projects/tasks, per-row result |

## Immediate Runtime Command Queue

| Order | ID | Input | Expected Result |
|---:|---|---|---|
| 1 | CMD-12-H | `listar tarefas QA Robust 20260513 F` | Deleted task `13` no longer appears in active task list |
| 2 | SP-AUDIT | Read-only SharePoint query for item `13` in `Tarefas` | `Deleted=true`, deletion reason, timestamp, and deleted-by UPN present |
| 3 | CMD-09 | `pedir decisao: projeto=QA Robust 20260513 F, descricao=Validar publish regex 3.4 negativo, impacto=Alto, prazo=30/06/2026, aprovador=UPN ?` | Controlled invalid-UPN response; no flow internal server error |
| 4 | CMD-08 | `pedir decisao: projeto=QA Robust 20260513 F, descricao=Aprovar status choice 3.4 pos-import, impacto=Alto, prazo=30/06/2026, aprovador=mbenicios@minsait.com` then `sim` | Decision row created with `StatusDecisao=Pendente` |
| 5 | CMD-15 | `consultar portfolio` | Totals match active non-deleted SharePoint records |
| 6 | CMD-13A | `atualizar tarefa` using skip answers for optional fields | Existing values preserved; no raw gateway error |
| 7 | CMD-10 | Multiline `atualizar status` command with structured fields | Structured fields extracted or accepted limitation documented |

## Pending Project Features

| Feature ID | Priority | Status | ETA | Notes |
|---|---:|---|---:|---|
| BLK-AT-001 | P0 | Required fix | 2h | Normalize skip semantics in `AtualizarTarefa` topic/flow before release |
| GAP-AS-001 | P1 | Fix or product decision | 2h / 30m | `AtualizarStatus` multiline keeps summary but not all structured fields |
| GAP-PD-001 | P1 | Runtime retest | 15m | Invalid UPN path must fail safely before flow call |
| GAP-CARD-001 | P2 | Evidence gap | 3h total | Adaptive Cards CARD-01 through CARD-08 need current-cycle proof |
| GAP-PLN-001 | P2 | Evidence gap | 45m | Planner sync needs pilot IDs and green run evidence |
| GAP-C1 | P2/Admin | Decision pending | 30m | Ghost bot inventory cleanup or risk acceptance |
| REQ-14 | P0 validation | Runtime regression pending | 25m | `CriarProjeto` contract is a release-critical feature validation |
| REQ-15 | P0 validation | Runtime regression pending | 25m | `CriarTarefa` contract is a release-critical feature validation |
| REQ-16 | P0 validation | Runtime regression pending | 40m | Batch creation preview/card behavior remains release-critical |

## Planner Buckets

Use these buckets if creating the tasks in Microsoft Planner:

| Bucket | Task IDs |
|---|---|
| P0 Blockers | ACT-003, ACT-003-T, CMD-13A |
| Runtime Smoke | CMD-12-H, SP-AUDIT, CMD-09, CMD-08, CMD-15, CMD-10 |
| Local Regression | LOCAL-FULL |
| Adaptive Cards | CARD-01, CARD-02, CARD-03, CARD-04, CARD-05, CARD-06, CARD-07, CARD-08 |
| Planner Sync | PLN-01 |
| Release/Admin Decisions | GAP-C1, REQ-14, REQ-15, REQ-16 |

## Source Files

- `.planning/comms/PMO_360_STATUS_20260513.md`
- `.planning/stop_ship/CADERNO_HOMOLOGACAO_20260513.md`
- `.planning/stop_ship/TEST_STRATEGY.md`
- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/stop_ship/RELEASE_READINESS_CHECKLIST.md`
