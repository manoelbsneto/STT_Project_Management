# Release Readiness Checklist — AQ-08 Topic YAML Delivery (Owner-paste leg)

**Mission:** Deliver the 5 in-scope topic YAML files to the Owner so the AQ-08 Copilot Studio remediation can proceed.
**Issue:** `ISSUE-AQ08-YAML-001` — initial delivery failed in Copilot Studio due to LF-only line endings; rebuilt via gated pipeline.
**Last update:** 2026-05-20 22:46 BRT.

## SHIP / NO-SHIP per layer

| Layer | Decision | Rationale |
|---|---|---|
| Local artifact (5 fixed YAML files) | **SHIP** | All 8 quality gates PASS. Builder is deterministic and reproducible. |
| Owner-side Copilot Studio paste/save | **READY for execution, sequential, file 1/5** | First file is `ListarTarefas`. No further file is shown until prior save is confirmed. |
| AQ-08 routing change in live tenant | **NO-SHIP** | Reverify against live `botcomponent.data` has not yet been re-run. |
| 3.15 publish | **NO-SHIP** | Owner cannot publish until reverify PASSES post-remediation. |
| AQ-09 runtime smoke | **NO-SHIP** | Cannot start until 3.15 is published. |
| XPIA-01 validation | **NO-SHIP** | Cannot start until AQ-09 evidence is captured. |
| AQ-10 final SHIP | **NO-SHIP** | Cannot decide until AQ-09 + XPIA-01 evidence exists. |

## Gate list (this delivery only — five YAML files)

| Gate | Status | Link / Evidence |
|---|---|---|
| All critical issues reproduced + fixed + proven by automated tests | DONE | `scripts/Build-Aq08FixedTopicYamls.py` exit 0; `.planning/stop_ship/EVIDENCE_LOG_AQ08_YAML_001_20260520.md` |
| All tests green in CI | OWNER-EXCLUDED for this mission per project rule | `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md` (CI Owner-exclusion) — local gates run instead |
| Zero high/critical security findings | DONE | No credentials, secrets, or PII in any fixed YAML; substring scan PASS |
| No performance regression beyond agreed threshold | N/A at YAML layer | Action call swap; no runtime hot path change. New flows activated under AQ-07 with Owner-confirmed runtime evidence. |
| Backward compatibility validated | DONE | ADR `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md`; only in-scope topics modified |
| Rollback plan documented and tested | DONE | `.planning/comms/rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md` (target package: `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip`, SHA256 `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`) |
| RCA package completed for each incident-class issue | DONE | `.planning/stop_ship/ISSUE_RCA_AQ08_YAML_001_20260520.md` |

## Quality gates per file (G1..G8)

| File | G1 | G2 | G3 | G4 | G5 | G6 | G7 | G8 | Verdict |
|---|---|---|---|---|---|---|---|---|---|
| ListarTarefas.yaml | PASS | PASS | PASS | PASS | PASS (1 edit) | PASS | PASS | PASS | SHIP |
| CriarTarefa.yaml | PASS | PASS | PASS | PASS | PASS (1 edit) | PASS | PASS | PASS | SHIP |
| AtualizarTarefa.yaml | PASS | PASS | PASS | PASS | PASS (1 edit) | PASS | PASS | PASS | SHIP |
| ConsultarPortfolio.yaml | PASS | PASS | PASS | PASS | PASS (5 edits) | PASS | PASS | PASS | SHIP |
| AtualizarStatus.yaml | PASS | PASS | PASS | PASS | PASS (12 edits) | PASS | PASS | PASS | SHIP |

OverallDecision (artifact layer): **PASS**.

## Rollback plan for this delivery

1. If pasting any file produces a YAML error in Copilot Studio Code Editor: do not save. Discard the editor changes. Tenant remains on AS-IS state.
2. Report the exact error message back to CODEX-PA. The builder is deterministic; rerun `python scripts\Build-Aq08FixedTopicYamls.py`, attach the new gate output, and only retry once the additional defect is in the gate set.
3. If a topic was already saved with a defective YAML (not expected, since Code Editor blocks save on parse error): revert that topic by pasting the AS-IS extract from `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/F_topic_yamls/<Topic>.yaml` and saving. This restores the pre-remediation state. The bot remains routable (legacy `PMO_PA_*` path) until reverify-and-publish is properly completed.
4. Tenant-level rollback (after publish) follows `.planning/comms/rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md`.

## Owner-side execution order (sequential, blocking)

1. Open `Assistente PMO V2` in Copilot Studio (env `ColOfertasBrasilPro`).
2. Open topic `ListarTarefas` → Code Editor → paste from `D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq08_topic_routing_verification_20260520\post_remediation_reverify\fixed_topic_yamls\ListarTarefas.yaml` → Save.
3. Confirm save success in chat.
4. CODEX-PA delivers file 2/5 (`CriarTarefa`) only after step 3 confirmation.
5. Repeat for `CriarTarefa`, `AtualizarTarefa`, `ConsultarPortfolio`, `AtualizarStatus`.
6. Do NOT publish the bot yet.
7. CODEX-PA runs `tests/Test-Aq08PostRemediationReverify.ps1` against live Dataverse (read-only).
8. If `OverallDecision: PASS`, Owner publishes the bot.
9. AQ-09 smoke and XPIA-01 evidence validation follow.
