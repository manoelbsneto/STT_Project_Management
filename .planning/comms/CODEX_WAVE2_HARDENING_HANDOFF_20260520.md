# CODEX Wave 2 Hardening Handoff - 2026-05-20

Owner: Manoel Benicio  
Agent: CODEX-PA  
Environment: `ColOfertasBrasilPro`  
Bot: `Assistente PMO V2`  
Release state: `NO-SHIP` until Owner manual remediation plus AQ-08 post-remediation verifier PASS.

## Mandatory References Read

| Reference | Status |
|---|---|
| `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` | READ |
| `.planning/comms/CODEX_P0_CLOSEOUT_HANDOFF_20260520.md` | READ |

## PASS / BLOCK Matrix

| Task | Result | Evidence | Notes |
|---|---|---|---|
| W2-1 - Pre-publish rollback evidence capture | PASS | `.planning/comms/rollback_evidence_pre_3_15_20260520/` | Read-only PAC snapshots captured; rollback procedure written. |
| W2-2 - Post-remediation re-verification script | PASS | `tests/Test-Aq08PostRemediationReverify.ps1`; `.planning/comms/aq08_topic_routing_verification_20260520/expected_pm0_routing_post_remediation.json` | Smoke-run against pre-remediation state correctly returned `BLOCK` / exit code 1. |
| W2-3 - Governance doc sync | PASS | `.planning/START_HERE_CURRENT_STATUS.md`; `.planning/stop_ship/MASTER_CHECKLIST.md`; `.planning/stop_ship/RISK_REGISTER.md`; `.planning/AGENT_CHECKIN_REGISTRY.md` | Docs now reflect accepted ADR, five in-scope gates, seven accepted legacy debt items, and Wave 2 task flow. |

## Current Gate Decision

`STOP - DO NOT PUBLISH YET.`

Owner can proceed to AQ-08 publish only after:

1. Owner manually remediates these five in-scope Copilot Studio topics:

| Topic | Required action component |
|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` |
| `ConsultarPortfolio` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` |

2. CODEX-PA or Owner runs:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Aq08PostRemediationReverify.ps1
```

3. The script returns:

```text
OverallDecision: PASS
Exit code: 0
```

Any `BLOCK` result means the release remains `NO-SHIP`.

## Pre-Remediation Verification Result

The new verifier was intentionally run against the current pre-remediation tenant state. It returned `BLOCK`, which is the expected control result and proves the script detects stale routing.

Evidence:

```text
.planning/comms/aq08_topic_routing_verification_20260520/test_reverify_pre_remediation_BLOCK_expected.txt
.planning/comms/aq08_topic_routing_verification_20260520/test_reverify_pre_remediation_exit.txt
```

Exit marker:

```text
EXPECTED_BLOCK_EXIT=1
```

## Rollback Evidence

Pre-publish evidence and rollback procedure are ready:

```text
.planning/comms/rollback_evidence_pre_3_15_20260520/pac_env_who_pre_publish.txt
.planning/comms/rollback_evidence_pre_3_15_20260520/pac_solution_list_pre_publish.txt
.planning/comms/rollback_evidence_pre_3_15_20260520/pac_copilot_list_pre_publish.txt
.planning/comms/rollback_evidence_pre_3_15_20260520/botcomponent_workflow_pre_publish.txt
.planning/comms/rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md
```

Rollback target documented:

```text
Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip
SHA256 37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691
```

## Legacy Debt Register

The following topics are accepted out-of-scope legacy debt for 3.15. They do not determine the AQ-08/AQ-09 ship gate unless Owner changes scope.

| Topic | Severity | Treatment |
|---|---|---|
| `ConsultarProjeto` | P3 | Backlog evidence only. |
| `CriarProjeto` | P3 | Backlog evidence only. |
| `ExcluirProjeto` | P3 | Backlog evidence only. |
| `ExcluirTarefa` | P2 | Backlog evidence only. |
| `PedirDecisao` | P2 | Backlog evidence only. |
| `RegistrarBloqueio` | P2 | Backlog evidence only. |
| `RegistrarRisco` | P2 | Backlog evidence only. |

## Next Owner Actions

1. Apply the five Copilot Studio topic routing remediations.
2. Ask CODEX-PA to re-run `tests/Test-Aq08PostRemediationReverify.ps1`.
3. If and only if verifier returns PASS / exit code 0, proceed with Owner-controlled 3.15 import/publish.
4. Run AQ-09 smoke runbook and capture evidence.
5. Run XPIA evidence validator before final SHIP decision.

