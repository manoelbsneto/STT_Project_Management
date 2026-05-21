# CODEX-PA Track B Anomaly Remediation — Three Topics Reverted, Re-Paste Required

Date BRT: 2026-05-21T05:14:00-03:00
Owner: Manoel Benicio
Author: Opus 4.7
Target: CODEX-PA
Supersedes Sections B-F of: `.planning/comms/CODEX_PA_P0_W2_TRACK_B_CORRECTIVE_DISPATCH_20260521.md` (until verifier returns PASS twice)
Severity: SEV-0 stop-ship anomaly

## What Happened

Three reverify reports captured today/yesterday on the same five in-scope topics:

| Topic | 2026-05-20 16:38 | 2026-05-21 01:34 | 2026-05-21 04:57 |
|---|---|---|---|
| AtualizarStatus | BLOCK (legacy present) | PASS | PASS |
| AtualizarTarefa | BLOCK (legacy present) | PASS | **BLOCK (no ref at all)** |
| ConsultarPortfolio | BLOCK (legacy present) | PASS | **BLOCK (no ref at all)** |
| CriarTarefa | BLOCK (legacy present) | PASS | PASS |
| ListarTarefas | BLOCK (already empty) | PASS | **BLOCK (no ref at all)** |

Three topics drifted from PASS to BLOCK between 01:34 and 04:57 BRT. Owner attests no UI activity in that window. CODEX-PA and CODEX-QA attest no tenant writes. Verifier output shows the BLOCKED topics now contain neither legacy nor new action references — a "neither" state, not a revert. Hypothesis: Copilot Studio Code Editor save persistence issue OR background draft-cleanup overwrite. Root cause investigation deferred until after remediation.

Owner has been instructed to re-paste the three affected YAMLs and verify each save persists.

## Scope of Work (CODEX-PA)

### A. Wait for Owner re-paste signal

Do nothing until Owner posts in this thread that all three of the following have been re-pasted into Copilot Studio Code Editor and saved, with browser-refresh post-save persistence check completed:

- `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/ListarTarefas.yaml`
- `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/AtualizarTarefa.yaml`
- `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/ConsultarPortfolio.yaml`

### B. First reverify (after Owner signal)

1. Re-run `tests/Test-Aq08PostRemediationReverify.ps1`. Capture stdout/stderr/exit/report JSON under `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/post_owner_edits_20260521_repaste_run1/`.
2. Required result: `OverallDecision: PASS`, exit 0, all five topics PASS with both `legacyHitsInTopic: []` and `hasExpectedActionReferenceInTopic: true`.
3. If any topic is BLOCK, stop and report. Owner re-pastes again. Do not start Step C.

### C. Second reverify (stability check, 2 minutes after Step B)

1. Sleep at least 120 seconds after Step B completes. This catches any Copilot Studio background draft-cleanup that wiped state previously.
2. Re-run `tests/Test-Aq08PostRemediationReverify.ps1`. Capture under `post_owner_edits_20260521_repaste_run2/`.
3. Required result: identical PASS as Step B, byte-equivalent topic shape per topic. Also diff `botcomponent.data` for each topic between Step B and Step C; if any topic's relevant action component reference disappeared between runs, treat as BLOCK and report.
4. If both runs PASS and topic content is stable across the 2-minute gap, proceed to Step D.

### D. Anomaly diagnostic snapshot (mandatory regardless of B/C outcome)

1. Capture `botcomponent.data` raw text for the three previously-affected topics (`AtualizarTarefa`, `ConsultarPortfolio`, `ListarTarefas`) under `.planning/comms/aq08_topic_routing_verification_20260520/anomaly_20260521_0457/topic_data_after_repaste/`.
2. Compare against the three corresponding fixed YAMLs (`fixed_topic_yamls/*.yaml`). Save diff outputs.
3. Write `ANOMALY_DIAGNOSIS.md` in the `anomaly_20260521_0457/` directory with:
   - Timeline of the four reverify runs (yesterday BLOCK, today 01:34 PASS, today 04:57 BLOCK, today repaste run1 + run2).
   - Per-topic before/after table.
   - Hypothesis ranking based on observed evidence (Copilot Studio Code Editor save issue, background draft cleanup, parse-and-strip behavior).
   - Recommended monitoring after publish: re-run reverify at +5 min, +1 h, +6 h post-publish to detect any further drift.
   - Recommendation on whether 3.15 publish is safe given anomaly history.

### E. Resume corrective dispatch sections B-F

Only after Step C PASS twice with 2-minute stability AND `ANOMALY_DIAGNOSIS.md` recommends "publish acceptable":
- Section B (audit-trail SUMMARY.md) of corrective dispatch — UPDATE to reference both pre-repaste anomaly and post-repaste stability evidence.
- Section C (registry update) — proceed with `P0-W2-4` DONE and `P0-W2-5` DONE referencing the post-repaste run2 evidence as authoritative.
- Section D (Step 3a pre-publish ready) — proceed.
- Section E (Owner publish) — Owner action.
- Section F (Step 3b post-publish verify) — proceed AND add a +5 min, +1 h, +6 h post-publish drift recheck per Step D recommendation. Capture all under `post_publish_verify/drift_monitoring_20260521/`.

### F. If Step D recommends "publish NOT acceptable"

Report immediately. Do NOT proceed to Section D of the corrective dispatch. Owner decides whether to:
- Continue investigation of Copilot Studio save behavior.
- Roll back to the pre-repaste tenant state (no action needed; nothing was published).
- Defer 3.15 release pending a deeper RCA.

## Hard Prohibitions (unchanged)

No tenant writes, no `pac solution import/publish`, no Copilot Studio UI changes, no SharePoint/Planner/Power Automate writes, no git commit/push, no `Solution/*.zip` modifications, no edits to `deploy/copilot/*.yaml`, no edits to `.planning/STATE.md`, `.planning/stop_ship/MASTER_CHECKLIST.md`, or other agents' registry rows.

## Acceptance Gate for This Remediation

Cleared to resume corrective dispatch Section B onward when:
1. Step B reverify: all five topics PASS.
2. Step C reverify: identical PASS 2 minutes later, no per-topic content drift.
3. Step D `ANOMALY_DIAGNOSIS.md` recommendation: "publish acceptable" with post-publish drift monitoring plan.

End of dispatch.
