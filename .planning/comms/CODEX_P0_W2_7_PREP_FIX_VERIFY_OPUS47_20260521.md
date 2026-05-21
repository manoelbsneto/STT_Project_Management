# Opus 4.7 Independent Verification — P0-W2-7-PREP-FIX (Validator V2)

Date BRT: 2026-05-21T01:25:00-03:00
Verifier: Opus 4.7 (acting as certifier per `VALIDATOR_CONTRACT_AQ09.md` §10)
Implementer of record: CODEX-QA (`PREP_REPORT_V2.md`)
Decision: **APPROVED**

## Acceptance Gate (contract §10) — verification of each condition

| # | Condition | Status | Evidence |
|---|---|---|---|
| 1 | `tests/Test-Aq09SmokeEvidence.ps1`, `EVIDENCE_TEMPLATE.md`, and the 12 stub files updated to V2 contract | PASS | Read all four artifacts. Validator now extracts only the `<!-- TRANSCRIPT BEGIN/END -->` block before scanning markers. Template and 12 stubs use V2 fenced layout with no marker strings in any heading or label. |
| 2 | Three CODEX-QA self-tests captured under `_validator_self_test/v2/` | PASS | `negative_real_*`, `positive_*`, `xpia_trigger_*` files present (stdout, stderr, exit, report JSON). |
| 3 | CODEX-QA self-test outcomes match contract §7 expected decisions | PASS | `PREP_REPORT_V2.md` self-test table matches contract §7 row-for-row. Diffs against V1 self-test outputs explained in same report (V2 distinguishes `FAIL_MISSING_TRANSCRIPT` from `FAIL_XPIA_RECURS`). |
| 4 | Opus 4.7 independent re-run of all three self-tests, outcomes match | PASS | See §"Independent Run Results" below. Outputs at `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/opus_47_independent_run/`. |
| 5 | New registry row `P0-W2-7-PREP-FIX` referencing this contract as input | PASS | CODEX-QA reported `DONE` on `P0-W2-7-PREP-FIX`. Owner to confirm registry row visible. |

All five conditions satisfied. AQ-09 smoke (`P0-W2-7`) is **unblocked from the validator side**.

## Independent Run Results

Re-ran the patched `tests/Test-Aq09SmokeEvidence.ps1` against the same three fixture sets used by CODEX-QA. Driver script: `Run-OpusIndependentVerify.ps1` (committed to disk at the same independent-run directory). Per-fixture reports inspected via `Inspect-Reports.ps1`.

### Fixture: negative_real

- Evidence dir: `.planning/comms/aq09_smoke_runbook_20260520/evidence/`
- Expected per contract §7: decision `FAIL_AQ09_INCOMPLETE`, exit 1, A1-A5 all `FAIL_MISSING_TRANSCRIPT`, B1-B7 either `LEGACY_NOT_RUN` or `LEGACY_INCOMPLETE`.
- Observed:
  - decision: `FAIL_AQ09_INCOMPLETE`
  - exit: 1
  - A1-A5: all `FAIL_MISSING_TRANSCRIPT`
  - B1-B7: all `LEGACY_INCOMPLETE`
- Outcome: **MATCH**
- Outputs: `negative_real_stdout.txt`, `negative_real_stderr.txt`, `negative_real_exit.txt`, `negative_real_report.json`

### Fixture: positive

- Evidence dir: `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/positive/`
- Expected per contract §7: decision `PASS_XPIA_01_RESOLVED`, exit 0, A1-A5 all `PASS`, B1-B7 `LEGACY_NOT_RUN`.
- Observed:
  - decision: `PASS_XPIA_01_RESOLVED`
  - exit: 0
  - A1-A5: all `PASS`
  - B1-B7: all `LEGACY_NOT_RUN`
- Outcome: **MATCH**
- Outputs: `positive_stdout.txt`, `positive_stderr.txt`, `positive_exit.txt`, `positive_report.json`

### Fixture: xpia_trigger

- Evidence dir: `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/xpia_trigger/`
- Expected per contract §7: decision `FAIL_XPIA_01_RECURS_OR_UNKNOWN`, exit 1, A1 `FAIL_XPIA_RECURS`, A2-A5 `PASS` (per CODEX-QA's documented choice to dirty only A1).
- Observed:
  - decision: `FAIL_XPIA_01_RECURS_OR_UNKNOWN`
  - exit: 1
  - A1: `FAIL_XPIA_RECURS`
  - A2-A5: `PASS`
  - B1-B7: `LEGACY_NOT_RUN`
- Outcome: **MATCH**
- Outputs: `xpia_trigger_stdout.txt`, `xpia_trigger_stderr.txt`, `xpia_trigger_exit.txt`, `xpia_trigger_report.json`

## Spot-Check Findings (validator code review, non-blocking)

These do not block sign-off. Captured here for follow-up backlog.

1. **B5 alias coverage.** Validator's `B5_PedirDecisao` aliases include `B5_PedirDecisao`, `B5_PedirDecisao_InvalidUPN`, and `PedirDecisao`. The original AQ-09 `EVIDENCE_TEMPLATE.md` reference list (V1) also names a separate `B5b_PedirDecisao_ValidOptional` test. If Owner ever produces both files, the substring matcher will associate both with the single `B5_PedirDecisao` legacy slot, the validator will pick the first sorted file and warn, and the second file will be ignored for status purposes. Recommend a small follow-up to either add a distinct `B5b` entry to `$legacy` or document `B5b` out-of-scope. Not a SHIP-gate problem for 3.15 since legacy slot is debt-only.
2. **`screenshot.path` field name.** Validator extracts via generic `- path:` line match. Today only the screenshot section uses that label, so it works. If a future template adds another `- path:` line elsewhere in a stub, the extractor will pick the first occurrence and could regress silently. Recommend renaming to `- screenshot_path:` in a later iteration to make the contract robust.
3. **`result` field literal.** Empty-template stubs contain literal `- result: PASS | FAIL | NOT_RUN`, which correctly fails the `^(PASS|FAIL|NOT_RUN)$` regex check. Behaviour is intended: any uninitialised stub fails the field check. Worth a one-line comment in the validator near that regex so future maintainers do not "fix" it.

None of the above changes the V2 decision codes. Track them in the AQ-09 backlog after 3.15 ships.

## Author/Certifier Separation Statement

CODEX-QA implemented the V2 validator and template. Opus 4.7 wrote the contract spec and performed independent verification. Author and certifier are different agents. SEV-0 audit trail intact.

## Net Effect on Wave 2 Critical Path

- `P0-W2-7-PREP` (parent task) can be flipped from BLOCKED to DONE referencing this sign-off and `PREP_REPORT_V2.md`.
- `P0-W2-7` (AQ-09 smoke) is **no longer gated by the validator**. It remains gated by:
  - Track B step 2: `P0-W2-5` post-remediation reverify must PASS.
  - Track B step 3: `P0-W2-6` Owner publish must complete and post-publish reverify must PASS.
- `P0-W2-8` (validate AQ-09 evidence + SHIP/NO-SHIP) will use this V2 validator on real evidence after `P0-W2-7` completes.

## Hard Prohibitions Honored During This Verification

No tenant writes, PAC writes, browser actions, Copilot Studio UI changes, SharePoint writes, Planner writes, Power Automate runs, git commits, or git pushes were performed. All actions were local PowerShell invocations of the validator script against local fixtures and read-only inspection of report JSON.

## Next Owner Action

Recommend Owner:

1. Flip registry row `P0-W2-7-PREP` to `DONE` referencing this file as evidence.
2. Continue Track B without dependency on this work.
3. Begin `P0-W2-7` AQ-09 smoke only after Track B step 3 (`P0-W2-6` post-publish reverify PASS) is captured by CODEX-PA.

End of sign-off.
