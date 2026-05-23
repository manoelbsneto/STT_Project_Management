# AQ-08 Publish Drift Decision

- publish_utc: 2026-05-22T11:15:52.9307207+00:00
- invocation_utc: 2026-05-22T11:23:24.7897253+00:00
- mode: LivePacReadOnly
- recommendation: **ROLLBACK**
- fingerprint_drift_detected: True
- pass_to_block_regression_detected: True

## Passes

| Pass | Scheduled UTC | Observed UTC | Decision |
|---|---|---|---|
| T+5min | `2026-05-22T11:28:24.7897253+00:00` | `2026-05-22T11:28:45.9201720+00:00` | PASS |
| T+1h | `2026-05-22T12:23:24.7897253+00:00` | `2026-05-22T12:23:46.7160185+00:00` | PASS |
| T+6h | `2026-05-22T17:23:24.7897253+00:00` | `2026-05-22T17:23:46.8725050+00:00` | BLOCK |

## Cross-Pass Diff

| Topic | T+5min -> T+1h fingerprint changed | T+1h -> T+6h fingerprint changed |
|---|---|---|
| AtualizarStatus | NO | YES |
| AtualizarTarefa | NO | YES |
| ConsultarPortfolio | YES | YES |
| CriarTarefa | YES | YES |
| ListarTarefas | YES | YES |
