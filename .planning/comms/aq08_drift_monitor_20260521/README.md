# AQ-08 Publish Drift Monitor

`tests/Test-Aq08PublishDriftMonitor.ps1` wraps the existing AQ-08 post-remediation reverifier after the Owner publishes build 3.15. It schedules three read-only checks from the monitor invocation time: T+5min, T+1h, and T+6h. `-PublishUtc` labels the evidence and rejects a publish time already more than six hours old; it does not move the scheduling baseline.

## Owner Flow

Run from the repository root immediately after publish:

```powershell
.\tests\Test-Aq08PublishDriftMonitor.ps1 `
    -PublishUtc "2026-05-21T18:30:00Z" `
    -OutputDir ".planning\comms\aq08_topic_routing_verification_20260520\post_publish_verify\drift_monitoring_20260521_1830Z"
```

Keep that PowerShell process alive until the T+6h pass finishes. Backgrounding the process is acceptable, but if the terminal, Codespace, session, or host process closes, monitoring stops and the remaining evidence is not produced.

The live path delegates to `Test-Aq08PostRemediationReverify.ps1` and keeps its PAC behavior read-only. Do not add PAC or PnP mutation commands to this flow. The monitor does not use PnP.

## Outputs

Each pass folder (`T+5min`, `T+1h`, `T+6h`) contains the reverifier evidence, a `summary.md`, and `topic_data/*.botcomponent.data.txt` for all five in-scope topics. The per-pass summary records PASS/BLOCK topic statuses and SHA256 fingerprints calculated from the captured `botcomponent.data` strings.

The output root ends with `DRIFT_DECISION.md`:

- `SHIP`: all three passes PASS and all five topic fingerprints stay stable.
- `HOLD`: no drift/regression is detected, but all passes are not PASS.
- `ROLLBACK`: any in-scope topic fingerprint changes between passes or a PASS pass regresses to BLOCK.

The script exits `0` only for `SHIP`; `HOLD` and `ROLLBACK` exit `1`.

## Offline Dry Run

Use the fixture-backed dry run to exercise all three passes immediately without PAC access or the scheduled waits:

```powershell
$publishUtc = [DateTimeOffset]::UtcNow.ToString("o")
.\tests\Test-Aq08PublishDriftMonitor.ps1 `
    -DryRun `
    -PublishUtc $publishUtc `
    -OutputDir ".planning\comms\aq08_drift_monitor_20260521\dry_run_local"
```

`-DryRun` uses the captured immediate pass under `tests/fixtures/aq08_drift_monitor/` as snapshot input. It replays that one captured PASS inventory for T+5min, T+1h, and T+6h, so the expected dry-run recommendation is `SHIP`.
