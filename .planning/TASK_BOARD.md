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

## Completed Claims

| Task ID | Scope | Owner | Status | Completed At | Evidence |
|---|---|---|---|---|---|
| CODEX-W1-AUDIT | Programmatic Wave 1 evidence and test audit | Codex | DONE | 2026-05-07 17:20 BRT | `tests/Test-CriarTarefaContract.ps1` PASS; `tests/Test-CriarTarefaFlowDefinition.ps1` PASS; release-blocking failures recorded in `EVIDENCE_LOG.md`. |
| CODEX-STOPSHIP-ARTIFACTS | Refresh stop-ship artifacts for 16 GAP registry | Codex | DONE | 2026-05-07 17:20 BRT | Updated `.planning/stop_ship/EXEC_SUMMARY.md`, `MASTER_CHECKLIST.md`, `RISK_REGISTER.md`, `TEST_STRATEGY.md`, `RELEASE_READINESS_CHECKLIST.md`, `ISSUE_RCA_PACK.md`, `EVIDENCE_LOG.md`. |
| CODEX-BROWSER-HANDOFF | Prepare Opus browser checklist requests | Codex | DONE | 2026-05-07 17:20 BRT | `.planning/comms/CODEX_BROWSER_REQUESTS_20260507.md`. |
| CODEX-FULL-PROGRAMMATIC-W1-W5 | Full approved programmatic execution for GAP-A1, B1-B7, C1, C5 | Codex | DONE | 2026-05-07 20:25 BRT | Added flow scripts/tests, YAML local template updates, ghost discovery, operations manual, current status table, evidence updates, and Opus browser handoff. Programmatic deployment attempt timed out; see `.planning/comms/CODEX_PROGRAMMATIC_DEPLOY_ATTEMPT_20260507.md`. |
