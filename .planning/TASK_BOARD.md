# TASK BOARD

Status: Active
Created: 2026-05-07 17:06 BRT
Purpose: Coordination board required by `.planning/COORDINATION_CONTRACT.md`.

## Active Claims

| Task ID | Scope | Owner | Status | Claimed At | Files / Directories |
|---|---|---|---|---|---|
| CODEX-W1-AUDIT | Programmatic Wave 1 evidence and test audit | Codex | DONE | 2026-05-07 17:06 BRT | `deploy/PA_CriarTarefa_Flow.ps1`, `tests/*`, `.planning/stop_ship/*` |
| CODEX-STOPSHIP-ARTIFACTS | Refresh stop-ship artifacts for 16 GAP registry | Codex | DONE | 2026-05-07 17:06 BRT | `.planning/stop_ship/*`, `.planning/comms/*` |
| CODEX-BROWSER-HANDOFF | Prepare Opus browser checklist requests, if missing | Codex proposes, Opus owns execution | DONE | 2026-05-07 17:06 BRT | `.planning/comms/*`; Opus owns `.planning/BROWSER_CHECKLIST.md` |
| CODEX-FULL-PROGRAMMATIC-W1-W5 | Full approved programmatic execution for GAP-A1, B1-B7, C1, C5 | Codex | DONE | 2026-05-07 19:59 BRT | `deploy/*`, `tests/*`, `docs/*`, `.planning/stop_ship/*`, `.planning/comms/*`, `deploy/copilot/AssistentePMO.template.yaml` |
| CODEX-P24-EXEC | Local package 2.4 and tests for CriarProjeto/CriarTarefa/Gerar_Multiplos_Projetos | Codex | TODO | — | `Solution/*2_4*`, `tests/Test-*P24*`, `.planning/comms/solution_2_4_*`; no import/publish without owner approval |
| P0-AGENTIC-CHECKIN | Create P0 Adaptive Cards + Planner agentic coordination system | Codex Lead | READY_FOR_REVIEW | 2026-05-14 20:00 BRT | `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/comms/AGENTIC_DISPATCH_PROMPTS_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/architecture/AGENTIC_TASK_PLAN_ADAPTIVE_CARDS_PLANNER_20260514.md`, `.planning/AGENT_CONTRACT.md`, `.planning/START_HERE_CURRENT_STATUS.md` |

## Completed Claims

| Task ID | Scope | Owner | Status | Completed At | Evidence |
|---|---|---|---|---|---|
| CODEX-W1-AUDIT | Programmatic Wave 1 evidence and test audit | Codex | DONE | 2026-05-07 17:20 BRT | `tests/Test-CriarTarefaContract.ps1` PASS; `tests/Test-CriarTarefaFlowDefinition.ps1` PASS; release-blocking failures recorded in `EVIDENCE_LOG.md`. |
| CODEX-STOPSHIP-ARTIFACTS | Refresh stop-ship artifacts for 16 GAP registry | Codex | DONE | 2026-05-07 17:20 BRT | Updated `.planning/stop_ship/EXEC_SUMMARY.md`, `MASTER_CHECKLIST.md`, `RISK_REGISTER.md`, `TEST_STRATEGY.md`, `RELEASE_READINESS_CHECKLIST.md`, `ISSUE_RCA_PACK.md`, `EVIDENCE_LOG.md`. |
| CODEX-BROWSER-HANDOFF | Prepare Opus browser checklist requests | Codex | DONE | 2026-05-07 17:20 BRT | `.planning/comms/CODEX_BROWSER_REQUESTS_20260507.md`. |
| CODEX-FULL-PROGRAMMATIC-W1-W5 | Full approved programmatic execution for GAP-A1, B1-B7, C1, C5 | Codex | DONE | 2026-05-07 20:25 BRT | Added flow scripts/tests, YAML local template updates, ghost discovery, operations manual, current status table, evidence updates, and Opus browser handoff. Programmatic deployment attempt timed out; see `.planning/comms/CODEX_PROGRAMMATIC_DEPLOY_ATTEMPT_20260507.md`. |
| CODEX-P24-PLAN | Phase 2.4 planning for CriarProjeto/CriarTarefa/Gerar_Multiplos_Projetos | Codex | DONE | 2026-05-11 22:15 BRT | PRD/manual/requirements/roadmap/GSD phase docs updated. No PROD changes. |
