# CODEX-PA Track B Anomaly Remediation v2 — CriarTarefa Re-Paste + ConsultarPortfolio Builder Fix

Date BRT: 2026-05-21T10:30:00-03:00
Owner: Manoel Benicio
Author: Opus 4.7
Target: CODEX-PA
Supersedes: relevant scope of `.planning/comms/CODEX_PA_P0_W2_TRACK_B_ANOMALY_REMEDIATION_20260521.md` (extends, does not invalidate)
Severity: SEV-0

## Two Distinct Issues to Fix in This Cycle

### Issue 1 — CriarTarefa routing regressed (untouched topic)
Run1 (10:17 BRT): CriarTarefa shows `hasExpectedActionReferenceInTopic: false`, `legacyHitsInTopic: []`. Owner did not re-paste CriarTarefa during the cache-cleanup remediation. Same "neither" state pattern as the prior three-topic anomaly. Strongly suggests Copilot Studio session-wide stale-draft propagation across topics during the cache-cleanup re-paste flow.

### Issue 2 — ConsultarPortfolio silent runtime bug (binding/variable mismatch)
Saved `botcomponent.data` for ConsultarPortfolio at 13:19 UTC shows Copilot Studio auto-corrected the action output binding key from `message` to `result`, and the variable name from `Topic.ConsultarPortfolioResult` to `Topic.result`. The downstream `SendActivity` still references `{Topic.ConsultarPortfolioResult}` and will return empty at runtime. The routing verifier passes because the action reference is intact, but runtime is broken.

Root cause of Issue 2: `scripts/Build-Aq08FixedTopicYamls.py` produced a ConsultarPortfolio YAML whose binding key (`message`) does not match the new flow's actual output schema (`result`). The legacy flow returned `message`; the new `PM0_PA_Card_ResumoExecutivoPortfolio` flow returns `result`.

## Scope of Work (CODEX-PA)

### A. Snapshot all five topics now (read-only)

Capture full `botcomponent.data` text for all five in-scope topics from current live tenant state, to:
`.planning/comms/aq08_topic_routing_verification_20260520/anomaly_20260521_0457/topic_data_full_5/`.

This includes the two topics not previously snapshotted (AtualizarStatus, CriarTarefa). We need full state of all five before any further change.

### B. AtualizarStatus content integrity check

AtualizarStatus is the other structural-conversion topic in this batch. Diff its current `botcomponent.data` against `fixed_topic_yamls/AtualizarStatus.yaml`. Specifically check:

1. Action component reference present (already known PASS per routing verifier).
2. Action `output.binding` key matches the flow's actual output schema.
3. Any `SendActivity` referencing the bound variable uses the same variable name as the binding right-hand side.

If items 2 and 3 are inconsistent in saved data, AtualizarStatus also has the silent runtime bug. Add to `ANOMALY_DIAGNOSIS.md`.

### C. Fix the builder for ConsultarPortfolio (and AtualizarStatus if §B finds a bug)

Modify `scripts/Build-Aq08FixedTopicYamls.py` so the generated ConsultarPortfolio.yaml uses:

```yaml
output:
  binding:
    result: Topic.ConsultarPortfolioResult
```

Rationale: binding key `result` matches the new flow's actual output schema (Copilot Studio will not auto-correct it). Variable name `Topic.ConsultarPortfolioResult` matches the existing `SendActivity` reference. End-to-end consistent.

If §B identified a binding/variable mismatch in AtualizarStatus, apply the analogous fix to that topic in the builder.

Re-run the gated builder. All eight gates (G1-G8) MUST pass for the new ConsultarPortfolio.yaml (and AtualizarStatus.yaml if changed). Capture per-file gate evidence under:
`.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/QA_EVIDENCE_v2.md`.

If any gate fails, STOP. Do not proceed to §D.

### D. Owner re-paste batch (one cycle, owner-driven)

Owner will, in this exact order:

1. Hard browser cache + cookie cleanup for the Copilot Studio domain (same procedure that worked at the previous remediation).
2. Open Copilot Studio in a fresh tab. Confirm signed in to ColOfertasBrasilPro.
3. Paste-and-save these YAMLs in this order, one at a time. After each save, hard-refresh the tab (Ctrl+F5), reopen the topic's Code Editor, confirm the YAML still contains the expected `PM0_PA_Card_*` action reference and the expected `output.binding.<key>: Topic.<var>` pair, then move to the next.
   - `D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq08_topic_routing_verification_20260520\post_remediation_reverify\fixed_topic_yamls\CriarTarefa.yaml` (regression fix)
   - `D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq08_topic_routing_verification_20260520\post_remediation_reverify\fixed_topic_yamls\ConsultarPortfolio.yaml` (binding fix, new builder version from §C)
   - `D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq08_topic_routing_verification_20260520\post_remediation_reverify\fixed_topic_yamls\AtualizarStatus.yaml` (only if §B found a bug)
4. Reply in this thread when all required pastes are complete and post-refresh persistence confirmed for each.

CODEX-PA does NOT proceed to §E until Owner signal.

### E. Reverify pair (post-Owner-signal)

1. Run `tests/Test-Aq08PostRemediationReverify.ps1`. Capture under `post_remediation_reverify/post_owner_edits_20260521_repaste_run3/`. Required: PASS / exit 0 for all five.
2. Snapshot all five `botcomponent.data` again. Diff each against the latest fixed_topic_yamls (post-§C). For ConsultarPortfolio and AtualizarStatus, additionally assert that `output.binding.<key>: Topic.<var>` pair is preserved exactly (no Copilot Studio auto-correction this time) and that any `SendActivity` referencing `{Topic.<var>}` uses the same `<var>`.
3. Sleep 120 seconds.
4. Run reverifier again. Capture under `post_owner_edits_20260521_repaste_run4/`. Required: identical PASS, no per-topic content drift between run3 and run4 for any topic.
5. Snapshot all five again, diff run3-snapshot vs run4-snapshot. Any per-topic drift = BLOCK.

### F. Update ANOMALY_DIAGNOSIS.md

Append a new section "Issue 2 — ConsultarPortfolio binding/variable mismatch" with root cause, builder fix description, gate evidence pointer, and the post-fix verification result. Update the Decision section: "publish acceptable" only if §E run3 and run4 both PASS, content stable, AND ConsultarPortfolio + AtualizarStatus binding/variable pair correct.

### G. Resume corrective dispatch sections B-F (only after §F "publish acceptable")

Same as the prior remediation dispatch §E. Audit-trail SUMMARY.md update, registry P0-W2-4/P0-W2-5 DONE, Step 3a, Owner publish, Step 3b post-publish verify with +5 min / +1 h / +6 h drift recheck.

## Hard Prohibitions (unchanged)

No tenant writes outside Owner's manual paste-and-save. No PAC import/publish. No git commit/push. No `Solution/*.zip` modifications. No edits to other agents' registry rows.

## Acceptance Gate

Resume only when:
- §A: all 5 snapshots captured.
- §B: AtualizarStatus content checked, results recorded.
- §C: builder updated, all 8 gates PASS for regenerated YAMLs.
- §D: Owner signal received with persistence confirmed.
- §E run3 PASS for all 5, content correct (binding/variable consistent), 120s gap.
- §E run4 identical PASS, zero drift between run3 and run4 snapshots.
- §F diagnosis updated with "publish acceptable".

End of dispatch.
