# CODEX P0-W2-7-PREP-FIX Handoff — Validator V2 Remediation

Date BRT: 2026-05-21T01:04:00-03:00
Owner: Manoel Benicio
Author of this handoff: Opus 4.7 (acting in certifier role for `P0-W2-8`)
Target executor: CODEX-QA
Environment: ColOfertasBrasilPro
Bot: Assistente PMO V2
Release state: NO-SHIP. Validator V1 is BROKEN per CODEX-QA `PREP_REPORT.md`. AQ-09 smoke (`P0-W2-7`) MUST NOT begin until V2 self-tests pass and Opus 4.7 independently re-verifies.

## Mandatory References (read before claiming)

| Reference | Purpose |
|---|---|
| `.planning/comms/aq09_smoke_runbook_20260520/VALIDATOR_CONTRACT_AQ09.md` | Authoritative spec for V2. Implement against this. |
| `.planning/comms/aq09_smoke_runbook_20260520/PREP_REPORT.md` | Root-cause analysis from V1 self-tests. |
| `.planning/GOLDEN_RULES.md` | Standing rules. |
| `.planning/CURRENT_BASELINE.md` | Current build under test. |
| `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md` | SEV-0 protocol. |
| `.planning/AGENT_CHECKIN_REGISTRY.md` | Registry. Claim a new task entry as described below. |

## Why This Handoff Exists

V1 of `tests/Test-Aq09SmokeEvidence.ps1` scans the entire evidence file for the four XPIA marker strings. The V1 stub template embeds those exact strings as section labels. As a result, every empty stub returns `FAIL_XPIA_RECURS` before Owner pastes any transcript. CODEX-QA correctly classified this as `BROKEN-VALIDATOR` and stopped.

Opus 4.7 confirmed the diagnosis end-to-end and produced a contract spec (V2) that:

1. Wraps bot-response transcripts in fence markers so the validator scans only Owner-authored content.
2. Removes literal marker strings from all template labels and headings.
3. Adds `FAIL_MISSING_TRANSCRIPT` and `FAIL_MISSING_REQUIRED_FIELD` per-test statuses so "incomplete stub" is not conflated with "bot leaked XPIA."
4. Adds a top-level decision `FAIL_AQ09_INCOMPLETE` for the same reason.
5. Preserves all existing in-scope IDs, legacy IDs, marker strings, and decision keys to keep audit continuity.

Author/certifier separation is preserved: CODEX-QA implements, Opus 4.7 reviews and re-runs self-tests independently before sign-off.

## Scope of Work (CODEX-QA)

### Mandatory deliverables

1. Patch `tests/Test-Aq09SmokeEvidence.ps1` to V2 per the contract sections §3, §4, §5, §6.
2. Rewrite `.planning/comms/aq09_smoke_runbook_20260520/EVIDENCE_TEMPLATE.md` to match contract §3 exactly. No marker strings in any heading or label.
3. Rewrite the 12 V1 stub files under `.planning/comms/aq09_smoke_runbook_20260520/evidence/` to V2 layout with empty transcript fences. Owner pastes transcripts during AQ-09 smoke.
4. Produce three self-test fixtures and capture their outputs per contract §7:
   - Negative-real (real `evidence/` directory, empty transcripts) → expected decision `FAIL_AQ09_INCOMPLETE`.
   - Positive (synthetic, all fields complete, transcripts clean) → expected decision `PASS_XPIA_01_RESOLVED`.
   - XPIA-trigger (synthetic, transcripts contain all four markers inside the fence) → expected decision `FAIL_XPIA_01_RECURS_OR_UNKNOWN`.
   Capture stdout, stderr, exit code, and report JSON for each under `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/`.
5. Author `.planning/comms/aq09_smoke_runbook_20260520/PREP_REPORT_V2.md` summarising changes, diff highlights, and the three self-test outcomes. Include before/after snippet of one stub.
6. Do NOT modify:
   - `.planning/AGENT_CHECKIN_REGISTRY.md` outside your own task row.
   - `.planning/STATE.md`.
   - `.planning/stop_ship/MASTER_CHECKLIST.md`.
   - Fixed YAML topic files under `deploy/copilot/`.
   - Any production solution zip under `Solution/`.
   - The V1 self-test outputs already captured (leave them as historical evidence).

### Hard prohibitions

- No tenant writes, imports, publishes, Copilot Studio UI changes, SharePoint writes, Planner writes, Power Automate runs, browser actions, or PAC writes.
- No git commit or git push.
- No changes to marker strings, in-scope IDs, legacy IDs, or top-level decision keys (see contract §2 hard constraints).
- No deletion or rename of V1 self-test artifacts.

## Registry Claim

Add a new row to `.planning/AGENT_CHECKIN_REGISTRY.md` directly under the current `P0-W2-7-PREP` row, using these values:

```
| P0-W2-7-PREP-FIX | P0-W2 | AQ-09 | Implement Validator V2 per VALIDATOR_CONTRACT_AQ09.md and rerun self-tests | CODEX-QA | P0-W2-7-PREP | IN_PROGRESS | CODEX-QA | <claim_timestamp> | — | `.planning/comms/aq09_smoke_runbook_20260520/PREP_REPORT_V2.md` | 60min |
```

Add an Activity Log entry for the claim. Update status and timestamps on completion or block.

## Acceptance Gate (Opus 4.7)

I will verify in this exact sequence before recommending unblock of `P0-W2-7-PREP`:

1. Read `PREP_REPORT_V2.md` and confirm contract §10 conditions 1-3 are satisfied.
2. Independently re-run all three self-tests against the patched validator. My outputs go under `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/opus_47_independent_run/`.
3. Compare my decision codes against contract §7 expected outcomes. Any mismatch returns the task to CODEX-QA with the diff as evidence.
4. If all three match, post a sign-off note in `.planning/comms/CODEX_P0_W2_7_PREP_FIX_VERIFY_OPUS47_20260521.md` and only then recommend Owner unblock `P0-W2-7-PREP` and proceed with downstream Wave 2 tasks (`P0-W2-4` Owner UI is already independent and not blocked).

## Out of Scope for This Handoff

- AQ-09 smoke runbook content. The runbook itself is unchanged.
- Test ID set or marker list. Hard constraints in contract §2.
- BLK-AT-001 / AtualizarTarefa display bug. Tracked separately by `tests/Test-AtualizarTarefaResponseDisplay.ps1`.
- Any decision about SHIP/NO-SHIP for 3.15. That gate is `P0-W2-8` and depends on AQ-08 reverify (`P0-W2-5`), publish (`P0-W2-6`), and AQ-09 smoke (`P0-W2-7`) — none of which run before this remediation lands.

## Quick Acknowledgement Format Expected from CODEX-QA

When you claim:

```
TASK: P0-W2-7-PREP-FIX
STATUS: IN_PROGRESS
CLAIMED_AT: <ISO-8601 BRT>
CONTRACT_READ: VALIDATOR_CONTRACT_AQ09.md@<sha-or-mtime>
PLANNED_DELIVERABLES: validator_v2_patch, template_v2, 12_stub_v2_rewrites, 3_self_tests, prep_report_v2
```

When you complete or block, mirror the format used by the original `P0-W2-7-PREP` check-in.

End of handoff.
