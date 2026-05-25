# T0 Fan-out Dispatch — PM0 3.16 Ship (15-actor parallel)

| Field | Value |
|---|---|
| Trigger | Owner "go" 2026-05-23 16:15 BRT |
| Authorization | `.planning/comms/codex_pm0_remediation_20260522/DECISION_RESPONSES/AGENT_DECISION_RESPONSES_PM0_CONTAINMENT_20260523.md` Sections 9–10 |
| Coordinator | Kiro (default agent) |
| Standing auth scope | Owner + any Codex authorized for Gate 4A (import) + Gate 4B (publish). Gate 4C (AQ07 cleanup) requires explicit per-step Owner approval. |
| Cap override | 15-actor parallel deployment authorized for this mission only |
| Decision audit | Sections 9–11 of `AGENT_DECISION_RESPONSES_PM0_CONTAINMENT_20260523.md` |
| Active package | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` SHA256 `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB` |
| Environment | `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) |
| Bot | `Assistente PMO V2` |
| Critical-path blocker | Dataverse 403 on Step 03 of `scripts/Run-Gate4-Preflight.ps1` (`PREFLIGHT_HALT_20260523_022727.md`). Β-Lead owns unblock. |

---

## Standing instructions for ALL leads

1. Read first: `.planning/GOLDEN_RULES.md`, `.planning/CURRENT_BASELINE.md`, `.planning/AGENT_CHECKIN_REGISTRY.md`, this dispatch file, **the canonical progress board `T0_PROGRESS_BOARD.md` in this same folder**, and your decision-of-record sections in `AGENT_DECISION_RESPONSES_PM0_CONTAINMENT_20260523.md`.

2. **MANDATORY 3-ELEMENT CHECK-IN RULE — every check-in must contain all of:**
   - **Agent name** (full label, e.g. `Codex #2 Sub 2A`)
   - **Full timestamp** (`YYYY-MM-DD HH:MM:SS BRT`)
   - **Screenshot path** (full repo-relative `.png` path under your track's evidence root)
   
   Check-ins missing any of the three are invalid and will be reverted by Kiro on sight. The actor must re-post with the missing element(s) before continuing.

3. **Update the progress board `T0_PROGRESS_BOARD.md` every 5 min while active and on every state transition (start/complete/blocked).** Update only your own row in the actor table; append to "Recent events feed" with the 3-element triplet; update "Last refreshed" line; flip "T0 success criteria" rows when you close them. Do not touch other actors' rows.

4. Also post a check-in to `.planning/AGENT_CHECKIN_REGISTRY.md` on the same cadence with the same 3-element triplet.

5. Capture every evidence artifact as triplet: `.txt` log + `.json` structured + `.png` screenshot under your track's evidence folder. Filename pattern: `<UTC>_<AgentLabel>_<artifact_name>.<ext>`. The `.png` is what you reference in the mandatory check-in screenshot element. Publish the path to the progress board "Evidence path" + "Screenshot path" columns.

6. No tenant write outside the standing auth scope. Gate 4C cleanup requires Owner per-step approval.

7. Stop and ping Kiro (and flip your row to 🔴 with blocker text + screenshot on the progress board) if any sub-agent reports FAIL on a task that blocks downstream tracks.

8. ASCII-only in any shipped customer-facing text per `.planning/CURRENT_BASELINE.md`.

**The Owner reads `T0_PROGRESS_BOARD.md` as their single source of truth on mission progress. A claim of "task done" without a screenshot has zero evidentiary value. The triplet (agent name + full timestamp + screenshot) is non-negotiable for SEV-0 SHIP discipline.**

---

## Track Α — Gate ASK + Peer Review (Codex #1 + 3 subs)

**Lead:** Codex #1
**Subs:** 1A, 1B, 1C
**Evidence root:** `.planning/comms/codex_pm0_remediation_20260522/CODEX1/T0_DISPATCH/`

### Mission
Pre-draft the three Gate ASK templates so they are ready the instant Β-Lead clears the Dataverse 403. Run an independent local-static-gate cross-check on the 3.16 package as defense-in-depth.

### Sub-agent breakdown
- **Sub 1A — Gate 4A import ASK:** Draft `T0_GATE4A_IMPORT_ASK_DRAFT.md` filled with: package path, SHA256 `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`, environment ID, target solution name `PMO_v11_Tarefas`, expected version `3.16.0.0`, pre-import SHA verification command, post-import SHA verification command (mandatory evidence per Decision 3). Owner backup paths placeholder TBD.
- **Sub 1B — Gate 4B publish ASK:** Draft `T0_GATE4B_PUBLISH_ASK_DRAFT.md` with: bot identifier `Assistente PMO V2`, environment, expected publish UTC label slot, validation command `pac copilot list` expected output `Published / Active / Provisioned`, drift monitor T+5min and T+1h start commands.
- **Sub 1C — Gate 4C AQ07 cleanup ASK:** Draft `T0_GATE4C_AQ07_CLEANUP_ASK_DRAFT.md` (waits on Γ Opus 4.6 dependency map) with: list of components to remove, dependency graph reference, post-cleanup re-verification commands for AQ-09 A1–A5, explicit Owner approval requirement.

### Lead deliverables
- Peer-review each ASK draft as it lands (verdict: PASS/FAIL with specific findings).
- Independently rerun the 8 local static gates on the 3.16 package: `Test-SolutionXmlSchemaValidity`, `PM0 placeholder scan`, `Test-Pm0WorkflowResponseSemantics`, `Test-Pm0TopicActionFlowContract`, `Test-PMOFlowStopShipAudit`, `Test-SolutionZipP0Contracts`, `Test-SolutionZipP24Contracts`, `Test-CopilotRoutingInstructions`, `Test-CopilotPowerFxRegexSafety`. Capture exit codes and triplets.
- Final deliverable: `T0_TRACK_ALPHA_REPORT.md` with peer-review verdicts and static-gate cross-check exit codes.

### Stop conditions
- Any local static gate exits non-zero on the 3.16 package → halt, ping Kiro.
- Any ASK draft missing a mandatory field → return to sub-agent.

---

## Track Β — Preflight + Tenant Write (Codex #2 + 3 subs)

**Lead:** Codex #2
**Subs:** 2A, 2B, 2C
**Evidence root:** `.planning/comms/codex_pm0_remediation_20260522/CODEX2/T0_DISPATCH/`

### Mission
Resolve Dataverse 403 on `solutioncomponent` GET, rerun `scripts/Run-Gate4-Preflight.ps1` from Step 03 to completion, and stand by to execute Gate 4A and 4B under standing authorization once ASKs are signed.

### Sub-agent breakdown
- **Sub 2A — 403 unblock:** Try in order, capture evidence per attempt:
  1. Verify current AZ CLI identity: `az account show` and confirm UPN.
  2. Inspect Dataverse role assignments for that UPN via `pac admin list-active-users` or equivalent read-only PAC discovery.
  3. If role missing, attempt to assign `System Customizer` or `Solution Reader` role via Power Platform admin API (only if user has admin rights — read-only verify first).
  4. If user lacks admin rights, halt and produce `T0_DATAVERSE_403_OWNER_REQUEST.md` with exact role + scope to request.
- **Sub 2B — Recovery readiness:** Standby for Owner to share the manual export paths. When received, validate each file with: SHA256, `pac solution check`, schema validity test. Cache as `T0_RECOVERY_BACKUP_INVENTORY.md`. Until paths arrive, validate `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` SHA `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691` as historical fallback only (not the primary recovery path per Decision 2).
- **Sub 2C — SHA compare tooling + post-publish runbook:** Build `T0_SHA_COMPARE.ps1` that: (1) takes pre-import expected SHA, (2) takes post-import target solution name, (3) runs `pac solution export`, (4) computes SHA256 of exported ZIP, (5) emits PASS/FAIL with both SHAs side by side. Also draft `T0_POST_PUBLISH_RUNBOOK.md` listing the exact `pac copilot list` and drift monitor commands to run between Gate 4B and AQ-09.

### Lead deliverables
- Once Sub 2A clears 403: rerun `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Run-Gate4-Preflight.ps1` from the repo root, allowing it to resume from Step 03.
- Capture full evidence triplets per step.
- Generate `T0_PREFLIGHT_RERUN_MANIFEST.md` and ping Α-Lead for peer review.
- Once Α-Lead peer-reviews and Owner approves Gate 4A via standing auth: execute `pac solution import` of the 3.16 package; capture pre/post inventory.
- Execute SHA read-back via Sub 2C tool; if divergent, halt and trigger recovery per Decision 2.
- Once Gate 4A success evidence published: execute Gate 4B publish; capture publish UTC label.

### Stop conditions
- 403 cannot be resolved by any 2A path within 60 min → halt, escalate via Owner request file.
- Post-import SHA divergence → halt, request Owner recovery paths, do NOT proceed to 4B.
- Any tenant-write command fails non-deterministically twice → halt, full RCA before retry.

---

## Track Γ — Architecture + Risk (Opus 4.6 solo)

**Agent:** Opus 4.6
**Subs:** 0 (solo deep-thinker role)
**Evidence root:** `.planning/comms/codex_pm0_remediation_20260522/OPUS46/T0_DISPATCH/`

### Mission
Read-only deep audit of the AQ07 dependency tree to enable a safe Gate 4C cleanup ASK; sanity-check each gate transition; serve as the final SHIP/NO-SHIP arbiter after AQ-09 Section A passes.

### Deliverables
- `T0_AQ07_DEPENDENCY_TREE_AUDIT.md` — full read-only inventory of: components in `PMO_AQ07_CopilotBinding` solution, ownership/binding to `PMO_v11_Tarefas`, runtime references from PM0 topics/actions/workflows, identification of any dual-ownership or duplicate-component anti-patterns. Cite MS Learn `Organize your solutions`.
- `T0_GATE_TRANSITION_SANITY_PROTOCOL.md` — for each gate (4A→4B, 4B→AQ-09, AQ-09→4C): the minimum evidence Opus must see before signing off as the architectural reviewer.
- Standby for AQ-09 Section A: cross-validate each test (A1–A5) against expected behavior from the merged RCA at `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md`.

### Stop conditions
- AQ07 dependency tree shows any component dual-owned with `PMO_v11_Tarefas` PM0 entries → halt, write a recommendation that delays 4C until further investigation.

---

## Track Δ — Cards + Docs (Gemini Flash #1 + 2 subs)

**Lead:** Gemini Flash #1
**Subs:** G1A, G1B
**Evidence root:** `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_DELTA/`

### Mission
Re-validate the 5 v316 Adaptive Cards against the current package; align release notes with the corrected SHA; produce a customer-facing monitoring runbook that the PMO PMs can execute post-publish.

### Sub-agent breakdown
- **Sub G1A — Card re-validation:** For each of the 5 v316 cards under `.planning/comms/codex_pm0_remediation_20260522/GEMINI/CARDS/*_v316/`: re-confirm size <27KB per `.planning/STATE.md` decision 7; re-render in card designer; verify schema; confirm sample data renders without errors; confirm ASCII-only in user-visible text. Output `T0_CARDS_REVALIDATION_REPORT.md` with one row per card.
- **Sub G1B — Release notes alignment:** Re-verify `RELEASE_NOTES_3_16_PT_BR.md` and `RELEASE_NOTES_3_16_EN.md` cite SHA `3327BD0F...EE7B` (corrected) and not the failed candidate `4280EC92...DD15`. Remove any `--publish-changes` example per the doc-debt note in `00a_sha_reconciliation_20260523_015857.md`. Output `T0_RELEASE_NOTES_ALIGNMENT_DIFF.md`.

### Lead deliverables
- Update `MONITORING_RUNBOOK_3_16.md` with current 3.16 thresholds, escalation matrix unchanged, and reference to drift monitor schedule (T+5min / T+1h / T+6h).
- Final deliverable: `T0_TRACK_DELTA_REPORT.md` with sub-agent verdicts + monitoring runbook handoff path.

### Stop conditions
- Any card exceeds 27KB → halt, surface to Α-Lead for ASK adjustment.
- Any release-notes file still references the old SHA → halt, fix before fanout completes.

---

## Track Ε — Evidence + Comms (Gemini Flash #2 + 2 subs)

**Lead:** Gemini Flash #2
**Subs:** G2A, G2B
**Evidence root:** `.planning/comms/codex_pm0_remediation_20260522/GEMINI/T0_DISPATCH_EPSILON/`

### Mission
Stage the post-publish AQ-09 evidence collection infrastructure; pre-fill A1–A5 evidence stubs; draft executive comms in PASS/FAIL forks so the right one ships instantly when the smoke result is known.

### Sub-agent breakdown
- **Sub G2A — Drift monitor staging:** Pre-build the T+5min / T+1h / T+6h drift monitor command sequence in `T0_DRIFT_MONITOR_COMMANDS.ps1`. Validate against `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`. Stage output paths under `.planning/comms/codex_pm0_remediation_20260522/drift_monitoring_post_3_16_<UTC>/`.
- **Sub G2B — A1–A5 evidence stubs:** Pre-fill 5 evidence files under `.planning/comms/aq09_smoke_runbook_20260520/evidence/post_3_16_<UTC>/`: A1_CMD-12-H, A2_CMD-15, A3_CMD-11-P0, A4_CMD-13A, A5_CMD-10. Each stub includes: exact chat input, expected bot output, expected SP side-effect, XPIA acceptance criterion, screenshot target path, PnP read-back command, PASS/FAIL placeholder. Use `EVIDENCE_TEMPLATE.md` format.

### Lead deliverables
- Draft `T0_COMMS_PASS_DRAFT.md`: executive email + Teams post + FAQ for SHIP-success outcome (citing publish UTC label, AQ-09 evidence triplet folder, drift monitor PASS).
- Draft `T0_COMMS_FAIL_DRAFT.md`: executive email + Teams post + FAQ for AQ-09 FAIL → recovery scenario (citing recovery backup, RCA folder, next steps).
- Final deliverable: `T0_TRACK_EPSILON_REPORT.md` with stub paths, drift command path, and both comms drafts ready to land.

### Stop conditions
- Any A1–A5 stub missing a required field → halt, fix before declaring T0 complete.

---

## T0 success criteria (all five tracks must clear before T1 fires)

| # | Criterion | Owner |
|---|---|---|
| 1 | Α-Lead peer-review report PASS for 4A and 4B ASK drafts (4C draft can stay PENDING dependency map) | Codex #1 |
| 2 | Α-Lead independent static-gate cross-check on 3.16 package PASS (8/8 gates exit 0) | Codex #1 |
| 3 | Β-Sub 2A: Dataverse 403 resolved with evidence (or escalation file produced) | Codex #2 |
| 4 | Β-Lead: Run-Gate4-Preflight.ps1 reaches the end without further halts | Codex #2 |
| 5 | Β-Sub 2C: SHA compare tool tested and ready | Codex #2 |
| 6 | Γ: AQ07 dependency tree audit complete | Opus 4.6 |
| 7 | Δ: Cards re-validated, release notes aligned, monitoring runbook updated | Gemini Flash #1 |
| 8 | Ε: Drift monitor command staged, A1–A5 stubs pre-filled, comms PASS/FAIL drafts ready | Gemini Flash #2 |

When all 8 criteria are PASS, Kiro signs the T1→T2 transition and prompts the Owner for the Gate 4A approval (which under standing auth means: confirm SHA `3327BD0F...EE7B` is what gets imported, confirm environment is `ColOfertasBrasilPro`, then Codex #2 executes the import).

---

## Reference doc index for all tracks

- `.planning/GOLDEN_RULES.md`
- `.planning/CURRENT_BASELINE.md`
- `.planning/STATE.md`
- `.planning/START_HERE_CURRENT_STATUS.md`
- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md`
- `.planning/comms/codex_pm0_remediation_20260522/EVIDENCE_LOG.md`
- `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/PREFLIGHT_HALT_20260523_022727.md`
- `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/PACKAGE_STATUS.md`
- `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/evidence/20260522_180600_Codex2_package_consistency_strict.md`
- `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`
- `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md`
