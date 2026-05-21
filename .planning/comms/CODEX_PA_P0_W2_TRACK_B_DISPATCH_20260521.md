# CODEX-PA Track B Dispatch — Routing Reverify and Publish Gating

Date BRT: 2026-05-21T01:23:00-03:00
Owner: Manoel Benicio
Author of dispatch: Opus 4.7
Target executor: CODEX-PA
Environment: ColOfertasBrasilPro
Bot: Assistente PMO V2
Release state: NO-SHIP. AQ-08 awaiting Owner topic remediation, then read-only reverify, then Owner publish.

## Mandatory References (read before claiming)

| Reference | Purpose |
|---|---|
| `.planning/comms/CODEX_P0_CLOSEOUT_HANDOFF_20260520.md` | Defines the five in-scope topic redirects and legacy debt scope. |
| `.planning/comms/CODEX_WAVE2_HARDENING_HANDOFF_20260520.md` | Confirms `Test-Aq08PostRemediationReverify.ps1` is the canonical AQ-08 verifier. |
| `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` | Architectural decision and expected routing config. |
| `.planning/comms/aq08_topic_routing_verification_20260520/expected_pm0_routing_post_remediation.json` | Expected post-remediation routing snapshot. |
| `.planning/comms/rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md` | Rollback target if publish goes wrong. |
| `.planning/AGENT_CHECKIN_REGISTRY.md` | Registry. Use existing rows `P0-W2-4`, `P0-W2-5`, `P0-W2-6`. Do not create new rows. |
| `.planning/GOLDEN_RULES.md` and `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md` | Standing rules. |

## Track Summary

Track A (validator V2) is being independently verified by Opus 4.7 in parallel to this Track B work. Track A only gates `P0-W2-7` smoke and `P0-W2-8` certification, not the steps in this dispatch. Proceed with Track B independently.

Track B sequence and ownership:

| Step | Task ID | Owner of action | CODEX-PA responsibility |
|---|---|---|---|
| 1 | P0-W2-4 | Owner (Copilot Studio UI) | Pre-flight read-only check that Owner edits have NOT yet been applied; wait for Owner signal that UI changes are done. |
| 2 | P0-W2-5 | CODEX-PA | Run `Test-Aq08PostRemediationReverify.ps1` read-only. Capture full evidence. Report PASS or BLOCK. |
| 3 | P0-W2-6 | Owner (PAC publish) | Pre-publish baseline snapshot, then post-publish read-only verification after Owner confirms publish complete. |

CODEX-PA is the orchestrator and read-only verifier across all three steps. CODEX-PA does NOT touch Copilot Studio UI, does NOT execute `pac solution import` or any PAC publish command, does NOT write to SharePoint, Planner, Power Automate, or Dataverse.

## Step 1 — P0-W2-4 Pre-Flight (CODEX-PA, run NOW)

Goal: capture a baseline that confirms Owner edits have NOT yet been applied so the post-edit reverify has a clean control point.

Actions (all read-only):

1. `pac env who` and capture stdout, stderr, exit to `.planning/comms/aq08_topic_routing_verification_20260520/preflight_p0_w2_4/pac_env_who.txt`.
2. PAC FetchXML query for the five in-scope topic `botcomponent` rows. Save raw XML response under the same `preflight_p0_w2_4/` directory, one file per topic, named `<TopicName>_pre_owner_edits.xml`.
3. PAC FetchXML query for `botcomponent_workflow` rows for the same five topics. Save under `preflight_p0_w2_4/botcomponent_workflow_pre_owner_edits.xml`.
4. Run `tests/Test-Aq08PostRemediationReverify.ps1` once now against the current pre-edit state. Capture stdout, stderr, exit, and report JSON under `preflight_p0_w2_4/reverify_pre_owner_edits_*.txt`. Expected result: `BLOCK` and exit 1, identical to the historical evidence in `.planning/comms/aq08_topic_routing_verification_20260520/test_reverify_pre_remediation_*`.
5. If result is anything other than `BLOCK`/exit 1, STOP and report immediately. Do not proceed.

Update `P0-W2-4` row in registry only to add a sub-evidence link to `preflight_p0_w2_4/`. Do not change its `READY_OWNER_UI` status — that is Owner's to flip.

## Step 2 — P0-W2-5 Post-Remediation Reverify (CODEX-PA, run AFTER Owner signals P0-W2-4 done)

Trigger: Owner posts a message in this thread saying the five Copilot Studio topic redirects are saved (Owner does NOT publish yet). Do not start before that signal.

Actions (all read-only):

1. Re-run `pac env who` and the same FetchXML queries from Step 1. Capture under `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/`.
2. Run `tests/Test-Aq08PostRemediationReverify.ps1`. Capture stdout, stderr, exit, and report JSON under `post_remediation_reverify/reverify_post_owner_edits_*`.
3. Expected PASS criteria (must all hold):
   - `OverallDecision: PASS`
   - Exit code: `0`
   - Each of the five topics references its corresponding `pmo_AssistentePMO_V2.action.PM0_PA_Card_*` action, and no longer references its legacy `PMO_PA_*` action/flow route.
   - All six AQ-07 `PM0_PA_*` action components remain active and bound (per closeout handoff §"Re-Validation Checklist" item 5).
4. Claim `P0-W2-5` in the registry: status `IN_PROGRESS | CODEX-PA | <timestamp>` at start, then either `DONE | CODEX-PA | <timestamp> | <evidence_path>` on PASS or `BLOCKED | CODEX-PA | <timestamp> | <reason>` otherwise.
5. On PASS, post the result in the registry Activity Log and reply with the `Step 2 PASS` template below.
6. On BLOCK, capture which topic/route mismatched and reply with the `Step 2 BLOCK` template below. Do not start Step 3.

`Step 2 PASS` reply template:

```
TASK: P0-W2-5
DECISION: PASS
OVERALL: pac reverify PASS / exit 0
EVIDENCE_DIR: .planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/
NEXT: Owner may proceed with P0-W2-6 publish. Pre-publish baseline already captured under rollback_evidence_pre_3_15_20260520/. CODEX-PA will run post-publish verify after Owner signals publish complete.
RISK_NOTES: <any soft warnings even on PASS>
```

`Step 2 BLOCK` reply template:

```
TASK: P0-W2-5
DECISION: BLOCK
FAILED_TOPICS: <list>
EXPECTED: <expected route>
OBSERVED: <observed route>
EVIDENCE_DIR: .planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/
NEXT: Owner re-applies missing edits in Copilot Studio UI; CODEX-PA reruns Step 2.
```

## Step 3 — P0-W2-6 Publish Bracketing (CODEX-PA, gates Owner publish)

Trigger 3a (pre-publish): immediately after Step 2 returns PASS.

Actions:

1. Confirm rollback evidence under `.planning/comms/rollback_evidence_pre_3_15_20260520/` is still current. Re-list the directory and SHA256 the rollback target zip. Append confirmation to `rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md` as a dated appendix line. Do NOT modify earlier content.
2. Reply with the `Pre-publish READY` template:

```
TASK: P0-W2-6
PHASE: PRE-PUBLISH-READY
ROLLBACK_TARGET: Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip
ROLLBACK_TARGET_SHA256: <recomputed>
EVIDENCE_DIR: .planning/comms/rollback_evidence_pre_3_15_20260520/
OWNER_NEXT_STEP: Run pac solution import for 3.15 followed by Copilot Studio publish, then reply in thread with publish complete + run URLs.
```

Trigger 3b (post-publish): Owner replies in thread that import + publish are complete.

Actions (all read-only):

1. `pac env who`, `pac solution list`, `pac copilot list`. Capture stdout/stderr/exit under `.planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/`.
2. PAC FetchXML for the five in-scope topic `botcomponent` rows AND `botcomponent_workflow` rows. Save under `post_publish_verify/`.
3. Re-run `tests/Test-Aq08PostRemediationReverify.ps1`. Save outputs under `post_publish_verify/reverify_post_publish_*`. Expected: `PASS` / exit 0 (same as Step 2).
4. Confirm 3.15 solution version is present in `pac solution list` and matches expected manifest. If not present or version mismatched, BLOCK.
5. Update `P0-W2-6` registry row to `DONE | CODEX-PA | <timestamp> | <evidence_path>` on success or `BLOCKED` with reason on failure.
6. Reply with the `Post-publish PASS` or `Post-publish BLOCK` template.

`Post-publish PASS` reply template:

```
TASK: P0-W2-6
PHASE: POST-PUBLISH
DECISION: PASS
SOLUTION_VERSION: 3.15
PAC_REVERIFY: PASS / exit 0
EVIDENCE_DIR: .planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/
NEXT: Track B complete. P0-W2-7 smoke can begin once Opus 4.7 has signed off Track A validator V2. Opus 4.7 will post sign-off in CODEX_P0_W2_7_PREP_FIX_VERIFY_OPUS47_20260521.md.
```

`Post-publish BLOCK` reply template:

```
TASK: P0-W2-6
PHASE: POST-PUBLISH
DECISION: BLOCK
ROOT_CAUSE: <missing version | route regression | missing component | other>
ROLLBACK_RECOMMENDED: yes/no
ROLLBACK_TARGET: Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip
EVIDENCE_DIR: .planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/
NEXT: Owner reviews evidence and decides rollback vs. corrective republish.
```

## Hard Prohibitions for CODEX-PA in Track B

- No tenant writes of any kind. Read-only PAC FetchXML and PowerShell test invocations only.
- No `pac solution import`, `pac solution publish`, `pac copilot publish`, or any PAC write subcommand.
- No SharePoint, Planner, Power Automate, or Dataverse writes.
- No Copilot Studio UI interaction.
- No git commit or git push.
- No modification of `Solution/*.zip` files.
- No edits to fixed YAML topic files under `deploy/copilot/`.
- No edits to `.planning/STATE.md`, `.planning/stop_ship/MASTER_CHECKLIST.md`, or other agents' registry rows.
- Do not start Step 2 before Owner signals P0-W2-4 done. Do not start Step 3b before Owner signals publish complete.

## Conflict Coordination

CODEX-QA may still be finalising the V2 self-test outputs under `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/`. CODEX-PA writes only under `.planning/comms/aq08_topic_routing_verification_20260520/` and `.planning/comms/rollback_evidence_pre_3_15_20260520/`. No overlap.

Opus 4.7 may write under `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/opus_47_independent_run/` and `.planning/comms/CODEX_P0_W2_7_PREP_FIX_VERIFY_OPUS47_20260521.md`. No overlap with CODEX-PA paths.

## Acceptance Gate Summary

Track B is complete when:

1. `P0-W2-5` row in registry shows `DONE | CODEX-PA | ... | post_remediation_reverify/` with PAC reverify PASS captured.
2. `P0-W2-6` row in registry shows `DONE | CODEX-PA | ... | post_publish_verify/` with post-publish reverify PASS and 3.15 visible in solution list.
3. Owner has confirmed publish in thread.

Once Track A sign-off (Opus 4.7) is also posted, Owner can begin `P0-W2-7` AQ-09 smoke.

End of dispatch.
