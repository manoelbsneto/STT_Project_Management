# AQ-08 Publish Drift Pass T+5min Fixture

- fixture_kind: captured immediate dry-run pass
- mode: DryRunExistingSnapshots
- decision: PASS

This pass fixture is consumed by `Test-Aq08PublishDriftMonitor.ps1 -DryRun`.
The monitor replays its captured topic and workflow inventories three times without
waiting for the live T+5min, T+1h, or T+6h schedule.
