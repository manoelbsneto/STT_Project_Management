# CODEX-QA Track H Cross-Validation

## Result

**PASS** - SA-1 passed its AQ-08 drift monitor fixture replay. SA-2 produced the expected AQ-09 incomplete-evidence validator failure, with no populated-sample surprise beyond intentionally empty transcript fences.

## Checks

| Signal | Command | Observed outcome | Cross-validation |
|---|---|---|---|
| SA-1 AQ-08 drift monitor dry-run self-test | `powershell.exe -NoProfile -File .\tests\Test-Aq08PublishDriftMonitor.ps1 -PublishUtc ((Get-Date).ToUniversalTime().ToString('o')) -DryRun -OutputDir (Join-Path $env:TEMP 'codex_track_h_sa1_drift_20260521')` | Exit `0`; mode `DryRunExistingSnapshots`; recommendation `SHIP`; T+5min, T+1h, and T+6h passes each reported `PASS`; `fingerprintDriftDetected=false`; `passToBlockRegressionDetected=false`. | PASS |
| SA-2 AQ-09 sample populated stubs | `powershell.exe -NoProfile -File .\tests\Test-Aq09SmokeEvidence.ps1 -EvidenceDir '.planning\comms\aq09_evidence_prepop_20260521\sample_populated_stubs' -ReportPath (Join-Path $env:TEMP 'codex_track_h_sa2_aq09_validation_20260521.json')` | Exit `1` with expected decision `FAIL_AQ09_INCOMPLETE`; in-scope A1-A5 each had evidence and reported `FAIL_MISSING_TRANSCRIPT` with only `transcript` missing; no in-scope `FAIL_MISSING_EVIDENCE` or `FAIL_MISSING_REQUIRED_FIELD` result appeared. Legacy B1-B7 also reported transcript-only `LEGACY_INCOMPLETE`. | PASS |

## Caveat

SA-1 is a dry-run replay of the captured AQ-08 fixture snapshots and does not prove live PAC post-publish stability. Validator artifacts were directed to temp paths outside the repository for this cross-validation.
