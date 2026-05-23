# Executive Summary - PM0 Card-First Incident

Last updated: 2026-05-22 15:32 BRT | Codex #1 | One-page owner summary written.

## Incident

On 2026-05-22 at 14:42 BRT, the first evidenced AQ-09 `ListarTarefas` runtime smoke failed because the PM0 flow returned the static caller result `Tasks retrieved successfully.` and the bot did not return PMO task data. Prior AQ-07/AQ-08/hotfix audit passes proved structural routing and artifact preservation, not the end-to-end caller-visible behavior.

## Root Cause

PM0 card-first release confidence was granted without a functional runtime gate while the audited PM0 topic/action/flow contracts still contained missing input propagation and non-dynamic response bodies.

## Defect Count

| Severity | Count |
|---|---:|
| SEV-0 | 4 |
| HIGH | 3 |
| MEDIUM | 1 |

## Recommendation

Choose `HYBRID`: contain the broken PM0 path immediately with an owner-approved rollback or disable action, then remediate PM0 locally and re-ship only after contract and runtime gates pass.  
Alpha found `1 STUB`, `4 PARTIAL`, `0 REAL` PM0 workflows in scope; Bravo read-only evidence shows the audited live PM0 workflow definitions align semantically with local evidence and the owner already observed a live A1 failure.

## Time Estimate

- Immediate owner decision and containment: 15-60 minutes after approval/operator readiness.
- PM0 remediation and verification: current project estimate 20-30 hours until implementation re-estimates from exact field/card contract work.

## Owner Decisions Required

1. Select `ROLLBACK`, `FIX-AND-SHIP`, or `HYBRID`.
2. Authorize any exact tenant write needed for containment in the active thread.
3. Decide whether write-path PM0 flows stay in the next release scope or are deferred.
4. Approve the revised functional DoD: no DONE/PUBLISH from structural routing evidence alone.

## Risk If No Decision

The live PM0 card-first lane remains stop-ship with known runtime failure evidence, broken or incomplete input propagation on four required paths, and status language that must not imply functional readiness from AQ-08 structural PASS alone.

