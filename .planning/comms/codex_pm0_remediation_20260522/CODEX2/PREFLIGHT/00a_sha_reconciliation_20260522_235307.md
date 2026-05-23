# Pre-Step A SHA Reconciliation Evidence

| Field | Value |
|---|---|
| Timestamp BRT | 2026-05-22 20:53:07 BRT |
| Agent | Codex #2 Bravo |
| Result | PASS |
| Description | Verified corrected SHA reconciliation state before Gate 4 preflight tenant access. |
| Source command line | PowerShell Pre-Step A verifier from .planning/comms/codex_pm0_remediation_20260522/PROMPT_FOR_CODEX_2_GATE4_PREFLIGHT.md Section 6.5 |
| PNG evidence | $pngPath |
| Text output | $resultTxt |

## Dispatch Table

| Entry | Target file | State | Action this run |
|---|---|---|---|
| U1 | $(@{Entry=U1; TargetFile=.planning/CURRENT_BASELINE.md; State=ALREADY_APPLIED; ActionThisRun=Skip}.TargetFile) | ALREADY_APPLIED | Skip |
| U2 | $(@{Entry=U2; TargetFile=.planning/STATE.md; State=ALREADY_APPLIED; ActionThisRun=Skip}.TargetFile) | ALREADY_APPLIED | Skip |
| U3 | $(@{Entry=U3; TargetFile=.planning/START_HERE_CURRENT_STATUS.md; State=ALREADY_APPLIED; ActionThisRun=Skip}.TargetFile) | ALREADY_APPLIED | Skip |
| U4 | $(@{Entry=U4; TargetFile=.planning/stop_ship/MASTER_CHECKLIST.md; State=ALREADY_APPLIED; ActionThisRun=Skip}.TargetFile) | ALREADY_APPLIED | Skip |
| U5 | $(@{Entry=U5; TargetFile=.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_EN.md; State=ALREADY_APPLIED; ActionThisRun=Skip}.TargetFile) | ALREADY_APPLIED | Skip |
| U6 | $(@{Entry=U6; TargetFile=.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_PT_BR.md; State=ALREADY_APPLIED; ActionThisRun=Skip}.TargetFile) | ALREADY_APPLIED | Skip |
| A1 | $(@{Entry=A1; TargetFile=.planning/AGENT_CHECKIN_REGISTRY.md; State=ALREADY_APPLIED; ActionThisRun=Skip}.TargetFile) | ALREADY_APPLIED | Skip |

## Verification Results

| Check | Result | Detail |
|---|---|---|
| V1 | PASS | New SHA present in all six UPDATE files. |
| V2 | PASS | PM0-REMED-PACKAGE-CORRECTED appears exactly once. |
| V3 | PASS | Delta is scoped to PENDING targets only; all entries were already applied so no target delta was required. |
| V4 | PASS | All LEAVE files retain the old SHA forensic anchor. |

## Supporting Files

- $preStatus
- $postStatus
- $leavePre
- $leavePost
- $resultTxt

## Expected Delta

- None

## Actual New Delta Paths

- None

## Doc Debt Flagged, Not Fixed

The English and Portuguese 3.16 release notes still contain a --publish-changes example. Section 6.5 explicitly defers that correction; Gate 4A remains import-only.
