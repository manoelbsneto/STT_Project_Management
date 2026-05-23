# AQ-09 SharePoint Side-Effects Harness

Read-only PowerShell harness for AQ-09 post-smoke SharePoint verification.

## Script

`tests/Test-Aq09SharePointSideEffects.ps1`

The script uses the project-standard Windows PowerShell 5.1 + `SharePointPnPPowerShellOnline` path and only runs read commands:

- `Connect-PnPOnline`
- `Get-PnPWeb`
- `Get-PnPListItem`

It fails the local static guard if executable PnP write commands are introduced.

## Owner Invocation After AQ-09 Smoke

Run from the repo root in Windows PowerShell 5.1:

```powershell
.\tests\Test-Aq09SharePointSideEffects.ps1 `
  -SmokeStartUtc "2026-05-21T18:00:00Z" `
  -SmokeEndUtc   "2026-05-21T20:00:00Z" `
  -OutputDir     ".planning\comms\aq09_smoke_runbook_20260520\sp_side_effects\20260521-1800" `
  -ProjectScope  "QA Robust 20260513 F"
```

Copy the generated report path into the `pnp_output_path` field for each AQ-09 evidence stub:

`<OutputDir>\aq09_sp_side_effects_report.json`

## Output Contract

The main report contains:

- `smokeWindow`: UTC and BRT display values.
- `projectScope`: expected project name.
- `lists`: raw in-window rows for all five SharePoint lists.
- `tests`: A1 through A5 side-effect verdicts.
- `decision`: `PASS_ALL`, `MIXED`, or `FAIL_ALL`.

Per-list raw files are saved beside the report:

- `Projetos_rows_in_window.json`
- `Tarefas_rows_in_window.json`
- `StatusDiario_rows_in_window.json`
- `RiscosBloqueios_rows_in_window.json`
- `DecisoesBoard_rows_in_window.json`

## Dry-Run Sample

Sample output was generated with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Aq09SharePointSideEffects.ps1 `
  -SmokeStartUtc "2026-05-21T00:00:00Z" `
  -SmokeEndUtc "2026-05-21T11:00:00Z" `
  -OutputDir ".planning\comms\aq09_sp_side_effects_harness_20260521\sample_outputs" `
  -ProjectScope "QA Robust 20260513 F"
```

Dry-run result against current SharePoint state:

| Test | Status |
|---|---|
| A1_CMD-12-H | PASS |
| A2_CMD-15 | PASS |
| A3_CMD-11-P0 | NO_DATA |
| A4_CMD-13A | NO_DATA |
| A5_CMD-10 | NO_DATA |

`NO_DATA` is expected for smoke write checks before the AQ-09 chat run has been executed.
