# Pre-Step A SHA Reconciliation Evidence

| Field | Value |
|---|---|
| Timestamp BRT | 2026-05-22 22:58:57 BRT |
| Agent | Codex #2 Bravo |
| Result | PASS |
| Description | Verified corrected SHA reconciliation state before Gate 4 preflight tenant access. |
| Source command line | `scripts/Invoke-Gate4PreStepAReconciliation.ps1` |
| PNG evidence | `.planning\comms\codex_pm0_remediation_20260522\CODEX2\PREFLIGHT\00a_sha_reconciliation_20260523_015857.png` |
| Text output | `.planning\comms\codex_pm0_remediation_20260522\CODEX2\PREFLIGHT\00a_sha_reconciliation_20260523_015857.txt` |

## Dispatch Table

| Entry | Target file | State | Action this run |
|---|---|---|---|
| U1 | `.planning/CURRENT_BASELINE.md` | ALREADY_APPLIED | Skip |
| U2 | `.planning/STATE.md` | ALREADY_APPLIED | Skip |
| U3 | `.planning/START_HERE_CURRENT_STATUS.md` | ALREADY_APPLIED | Skip |
| U4 | `.planning/stop_ship/MASTER_CHECKLIST.md` | ALREADY_APPLIED | Skip |
| U5 | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_EN.md` | ALREADY_APPLIED | Skip |
| U6 | `.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_PT_BR.md` | ALREADY_APPLIED | Skip |
| A1 | `.planning/AGENT_CHECKIN_REGISTRY.md` | ALREADY_APPLIED | Skip |

## Verification Results

| Check | Result | Detail |
|---|---|---|
| V1 | PASS | New SHA present in all six UPDATE files. |
| V2 | PASS | PM0-REMED-PACKAGE-CORRECTED appears exactly once. |
| V3 | PASS | All entries were already applied, so no target-file delta was produced in this run. |
| V4 | PASS | All LEAVE files retain the old SHA forensic anchor. |

## LEAVE Files Checked

- `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md`
- `.planning/comms/codex_pm0_remediation_20260522/MESSAGE_TO_CODEX_1_UPDATED_OPINION_20260522.md`
- `.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173428_Codex1_package_consistency_strict.md`
- `.planning/comms/codex_pm0_remediation_20260522/EXPORT_RECONCILIATION_20260522_1712.md`
- `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/PREFLIGHT_HALT_20260522_220116.md`
- `.planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md`
- `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/PACKAGE_STATUS.md`

## Expected Delta

- None

## Actual New Delta Paths

- None

## Doc Debt Flagged, Not Fixed

The English and Portuguese 3.16 release notes still contain a --publish-changes example. Section 6.5 explicitly defers that correction; Gate 4A remains import-only.