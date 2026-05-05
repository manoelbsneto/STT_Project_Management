# Release Readiness Checklist

Decision: SHIP GO/GREEN

| Gate | Status | Evidence |
|---|---:|---|
| Critical issues reproduced | Green | ISSUE-001 reproduced by known-bad extract regression: `test_known_bad_125833.json`. |
| Fixes implemented | Green | Routing/action contract, flow response contract, and repo drift fixed. |
| Automated tests green | Green | Regression harness passes fresh live extract and repo template. |
| Security high/critical findings | Not applicable | Routing/action YAML hotfix; no app code dependency/security surface changed. |
| Performance regression | Not applicable | Routing/config hotfix has no measurable runtime performance path in repo; channel latency not measured. |
| Backward compatibility | Green | Action contract now requires `result`; live flow success/error responses both return `result`. |
| Rollback plan documented | Done | See below. |
| RCA completed | Green | RCA package updated with closure evidence. |

Rollback plan:
1. Use latest known package evidence before contract fix if rollback is required.
2. Re-import previous Copilot solution package from `.planning/comms/` only after selecting the exact timestamp and validating it with `tests/Test-CriarTarefaContract.ps1 -ExpectFailure` or an explicit rollback acceptance.
3. Run `pac copilot extract-template` after rollback and archive evidence.
4. Run `pac copilot list` and extract-template regression test.

Blocking items: none for this release gate.

Scoped exception:
- Manual Teams/channel transcript was not captured. The accepted substitute evidence is `pac copilot list` Published/Active/Provisioned, fresh `extract-template`, raw Dataverse `pac org fetch`, and live `Get-Flow` contract proof.
