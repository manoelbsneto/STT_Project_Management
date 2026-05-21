# CODEX-PA Track B Corrective Dispatch — Skip Steps 1-2, Execute Step 3

Date BRT: 2026-05-21T04:53:00-03:00
Owner: Manoel Benicio
Author: Opus 4.7
Target: CODEX-PA
Supersedes (in part): `.planning/comms/CODEX_PA_P0_W2_TRACK_B_DISPATCH_20260521.md` Steps 1 and 2

## Why This Corrective Exists

The original dispatch expected a sequenced flow: Step 1 pre-flight (BLOCK), Owner signal, Step 2 post-remediation reverify (PASS), Owner publish, Step 3 brackets. Owner had already pasted and saved the five fixed topic YAML files (per `EXEC_SUMMARY_AQ08_YAML_001_20260520.md` AQ08-YAML-001 sequence) before the pre-flight ran.

Result: Step 1 returned PASS / exit 0 instead of expected BLOCK / exit 1. CODEX-PA correctly halted per the dispatch contract.

Owner has now confirmed in thread: all five YAML files were pasted into Copilot Studio Code Editor and saved by Owner. This is functionally `P0-W2-4` complete. The pre-flight PASS report at `preflight_p0_w2_4/aq08_post_remediation_reverify_report.json` (generated 2026-05-21T01:34:35-03:00) functionally satisfies `P0-W2-5` because it ran against the post-remediation tenant state.

This corrective accepts that state, refreshes the verification, and proceeds to Step 3.

## Mandatory References (already read)

| Reference | Purpose |
|---|---|
| `.planning/comms/CODEX_PA_P0_W2_TRACK_B_DISPATCH_20260521.md` | Original dispatch. Steps 3a/3b semantics still apply. |
| `.planning/comms/aq08_topic_routing_verification_20260520/preflight_p0_w2_4/` | Today's PASS evidence (post-remediation, pre-publish). |
| `.planning/stop_ship/EXEC_SUMMARY_AQ08_YAML_001_20260520.md` | AQ08-YAML-001 sequence and per-file gate evidence. |
| `.planning/comms/rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md` | Rollback target reference. |
| `.planning/AGENT_CHECKIN_REGISTRY.md` | Update rows `P0-W2-4`, `P0-W2-5`, `P0-W2-6` per below. |

## Scope of Work (CODEX-PA)

### A. Confirmation reverify (mandatory, ~2 min)

The original pre-flight ran at 01:34 BRT, ~3 hours ago. Capture a fresh confirmation snapshot now to rule out tenant drift before publish.

1. Re-run `pac env who`. Save under `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/post_owner_edits_20260521_0453/pac_env_who.txt`.
2. Re-run `tests/Test-Aq08PostRemediationReverify.ps1`. Save stdout/stderr/exit/report JSON under the same `post_owner_edits_20260521_0453/` directory.
3. Expected: `OverallDecision: PASS`, exit 0, identical per-topic outcome to the 01:34 pre-flight.
4. If anything but PASS, STOP and report. Do not promote evidence and do not start Step B.

### B. Audit-trail promotion (mandatory)

1. In `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/post_owner_edits_20260521_0453/`, write a short `SUMMARY.md` with:
   - One-line statement: "Owner pasted and saved all five fixed topic YAMLs in Copilot Studio Code Editor between 2026-05-20 22:46 BRT (gated YAMLs ready) and 2026-05-21 01:34 BRT (pre-flight PASS observed)."
   - Pointer to yesterday's `BLOCK` baseline (`test_reverify_pre_remediation_BLOCK_expected.txt`, 2026-05-20T16:38:43-03:00).
   - Pointer to today's pre-flight PASS report (`preflight_p0_w2_4/aq08_post_remediation_reverify_report.json`).
   - Pointer to today's confirmation reverify (just captured in Step A).
   - Five-topic before/after table built from the two report JSONs (topic name, yesterday `hasExpectedActionReferenceInTopic` and `legacyHitsInTopic`, today same fields).
2. Do NOT delete or alter the yesterday-experimental files already under `post_remediation_reverify/`.

### C. Registry update

Update three rows in `.planning/AGENT_CHECKIN_REGISTRY.md`:

- `P0-W2-4`: status `DONE | Owner | 2026-05-21T01:34:00-03:00 | <evidence-path>`. Evidence path = `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/post_owner_edits_20260521_0453/SUMMARY.md`.
- `P0-W2-5`: status `DONE | CODEX-PA | <fresh-reverify-timestamp> | <evidence-path>`. Same evidence path.
- Add Activity Log entries for each.

Do NOT edit any other agent's existing rows.

### D. Step 3a — Pre-publish ready (per original dispatch §Step 3, trigger 3a)

Run unchanged from the original dispatch. Recompute SHA256 on the rollback target zip, append a dated appendix line to `ROLLBACK_PROCEDURE.md`, post the `Pre-publish READY` reply template.

### E. Owner publish (P0-W2-6)

Owner runs `pac solution import` for 3.15 + Copilot publish, then replies in thread with publish complete + run URLs. CODEX-PA waits.

### F. Step 3b — Post-publish verify (per original dispatch §Step 3, trigger 3b)

Run unchanged from the original dispatch. `pac env who`, `pac solution list`, `pac copilot list`, FetchXML for the five topics, re-run `Test-Aq08PostRemediationReverify.ps1`, confirm 3.15 visible in solution list, capture all under `post_publish_verify/`. Update `P0-W2-6` row. Post `Post-publish PASS` or `Post-publish BLOCK` reply template.

## Hard Prohibitions (unchanged from original dispatch)

No tenant writes, no `pac solution import/publish`, no Copilot Studio UI changes, no SharePoint/Planner/Power Automate writes, no git commit/push, no modification of `Solution/*.zip` files, no edits to `deploy/copilot/*.yaml`, no edits to `.planning/STATE.md`, no edits to `.planning/stop_ship/MASTER_CHECKLIST.md`, no edits to other agents' registry rows.

## Dependencies and Conflicts

- Track A (validator V2) is APPROVED. Sign-off at `.planning/comms/CODEX_P0_W2_7_PREP_FIX_VERIFY_OPUS47_20260521.md`. No collision.
- CODEX-QA is idle on the AQ-09 side until Owner runs P0-W2-7 smoke after publish.
- This corrective writes only under `aq08_topic_routing_verification_20260520/post_remediation_reverify/post_owner_edits_20260521_0453/`, `post_publish_verify/`, `rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md` (append only), and the registry rows listed above.

## Acceptance Gate

Track B closed when registry shows:
- `P0-W2-4` DONE.
- `P0-W2-5` DONE with confirmation reverify PASS evidence.
- `P0-W2-6` DONE with `post_publish_verify/` PASS evidence and 3.15 visible in `pac solution list`.

End of corrective dispatch.
