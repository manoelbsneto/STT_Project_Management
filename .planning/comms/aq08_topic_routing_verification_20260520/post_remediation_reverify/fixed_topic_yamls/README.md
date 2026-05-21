# AQ-08 Fixed Topic YAMLs — Owner Copy/Paste Pack

**Date:** 2026-05-20
**Author:** CODEX-PA (assistant)
**Purpose:** Provide ready-to-paste, fully-corrected topic YAML files for the 5 in-scope AQ-08 topics. Owner pastes each whole file into the Copilot Studio Code Editor for the matching topic in `Assistente PMO V2` (env `ColOfertasBrasilPro`).

## Files in this folder

| Topic | File | Lines | Action call (after fix) | Verified line |
|---|---|---:|---|---|
| AtualizarStatus | `AtualizarStatus.yaml` | 160 | `BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | 144 |
| AtualizarTarefa | `AtualizarTarefa.yaml` | 192 | `BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | 182 |
| ConsultarPortfolio | `ConsultarPortfolio.yaml` | 41 | `BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | 30 |
| CriarTarefa | `CriarTarefa.yaml` | 161 | `BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | 149 |
| ListarTarefas | `ListarTarefas.yaml` | 47 | `BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | 41 |

## Diff summary vs as-is

For each topic the only behavioural change is the action-call block. All parsing, prompts, condition groups, and global variable handling are byte-preserved from the AS-IS extract at `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/F_topic_yamls/`.

| Topic | AS-IS pattern | Fixed pattern | Reason |
|---|---|---|---|
| AtualizarStatus | `kind: InvokeFlowAction` with hard-coded `flowId: c11a165b-c64c-f111-bec7-7ced8d9559c1` and explicit `input.binding` | `kind: BeginDialog` with `dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus`, `input: {}`, `output.binding.result -> Topic.AtualizarStatusResult` | Switch from direct flow invocation to bot action component (AQ-07 binding). Globals already set above; new action component reads them via the binding contract. |
| AtualizarTarefa | `BeginDialog` → `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` | `BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | One-line dialog reference swap. |
| ConsultarPortfolio | `kind: InvokeFlowAction` with `flowId: 39cf292d-c64c-f111-bec7-7ced8d955c6c` | `kind: BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | Direct flow call replaced with action component per ADR semantic merge. No-input topic; only output bound to `Topic.ConsultarPortfolioResult`. |
| CriarTarefa | `BeginDialog` → `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` | `BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | One-line dialog reference swap. |
| ListarTarefas | `BeginDialog` → `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` | `BeginDialog` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | One-line dialog reference swap. |

## Owner workflow

1. Open Copilot Studio for `Assistente PMO V2` in env `ColOfertasBrasilPro`.
2. For each of the 5 topics:
   - Open the topic.
   - Switch to **Code Editor** view.
   - Select-all and replace the contents with the matching file from this folder.
   - Save the topic.
3. **Do not publish yet.** Notify CODEX-PA.
4. CODEX-PA runs `tests\Test-Aq08PostRemediationReverify.ps1` (read-only). Expected result: `OverallDecision: PASS` and exit code `0`.
5. If PASS, Owner publishes `Assistente PMO V2`.

## Risk acknowledgement (read before pasting AtualizarStatus or ConsultarPortfolio)

For **AtualizarStatus** and **ConsultarPortfolio**, the change is structural (`InvokeFlowAction` → `BeginDialog`) because the new card flows are registered as bot action components rather than directly invoked flows. The AQ-07 binding evidence (`AQ07_FINAL_BINDING_ACTIVE_VERIFICATION_20260515.md`) confirms all six action components are registered and active.

If Copilot Studio's Code Editor reports a binding-contract mismatch when saving (e.g., the new action component requires an explicit `input.binding`), open the action component first (Solution `PMO_AQ07_CopilotBinding` → topic of same name) to inspect its declared input/output schema, and adjust the `input: {}` block in the topic to mirror it. The `output.binding.result -> Topic.<Var>` mapping is the standard pattern used by the other three topics already on `BeginDialog` and is the most likely correct shape.

If Owner saves successfully, no further action is needed; if a save error occurs, capture the error message and route it back to CODEX-PA before retrying.

## Audit references

| Doc | Path |
|---|---|
| AQ-08 routing verification report | `.planning/comms/aq08_topic_routing_verification_20260520/AQ08_TOPIC_ROUTING_VERIFICATION.md` |
| Expected post-remediation routing (machine-readable) | `.planning/comms/aq08_topic_routing_verification_20260520/expected_pm0_routing_post_remediation.json` |
| AS-IS extracts (for diff reference only — DO NOT paste) | `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/F_topic_yamls/` |
| AQ-07 binding active verification | `.planning/comms/AQ07_FINAL_BINDING_ACTIVE_VERIFICATION_20260515.md` |
| ADR — Hybrid card-first migration | `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` |
| Closeout handoff | `.planning/comms/CODEX_P0_CLOSEOUT_HANDOFF_20260520.md` |
| Wave 2 hardening handoff | `.planning/comms/CODEX_WAVE2_HARDENING_HANDOFF_20260520.md` |
