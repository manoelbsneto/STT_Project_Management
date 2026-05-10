# Test Data Creation Freeze Record

> **Timestamp:** 2026-05-10T10:38:00-03:00
> **Recorded by:** Opus 4.6
> **Authority:** Project Owner decision in `TEST_DATA_CLEANUP_DECISION_20260510.md`

## Freeze Order

Effective immediately, **NO ad-hoc test data** may be created in:

| System | Lists/Tables Affected |
|--------|----------------------|
| SharePoint | Projetos, Tarefas, Status Diario, Riscos e Bloqueios, Decisoes do Board |
| Teams channel | Projetos_Transformacao_Digital |
| Dataverse | botcomponent (no new test bots) |
| Power Automate | No manual test runs except through official QA matrix |

## Rules During Freeze

1. All testers (Opus, Codex, Human) informed — **NO new test records** outside the official QA plan.
2. Any test after this timestamp MUST use official QA IDs from `PROD_DATA_CLEANUP_AND_QA_PLAN_20260510.md`.
3. Test data created before this timestamp is classified as trash/test per `TEST_DATA_CLEANUP_DECISION_20260510.md`.
4. Freeze remains active until official QA baseline is validated (CLN-04 task completion).

## Notification Log

| Agent | Notified At | Method |
|-------|------------|--------|
| Opus 4.6 | 2026-05-10T10:38:00-03:00 | Self (creator) |
| Codex 5.5 | 2026-05-10T10:38:00-03:00 | Via AGENT_CHECKIN_REGISTRY.md |
| Human/Admin | 2026-05-10T10:38:00-03:00 | Via this document in repository |
