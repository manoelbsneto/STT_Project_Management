# AQ-09 Evidence Stub Pre-Population

`tests/Build-Aq09EvidenceFromArtifacts.ps1` fills deterministic AQ-09 V2 evidence fields after the Owner chat smoke and Track G SharePoint side-effect harness have both run.

## Owner Order

1. Run the AQ-09 smoke chat session from `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`.
2. Run `tests/Test-Aq09SharePointSideEffects.ps1` for the same UTC smoke window.
3. Run this prepopulation script against the Track G `aq09_sp_side_effects_report.json`.
4. Paste each bot response into the empty `TRANSCRIPT` fence, review XPIA observations, screenshots, and outcomes.
5. Run the V2 validator `tests/Test-Aq09SmokeEvidence.ps1`.
6. Run the AQ-08 drift monitor `tests/Test-Aq08PublishDriftMonitor.ps1` for the post-publish T+5min, T+1h, and T+6h reverify cadence.

## Invocation

```powershell
.\tests\Build-Aq09EvidenceFromArtifacts.ps1 `
    -SmokeStartUtc "2026-05-21T18:00:00Z" `
    -SmokeEndUtc "2026-05-21T20:00:00Z" `
    -SpSideEffectsReport ".planning\comms\aq09_smoke_runbook_20260520\sp_side_effects\<run>\aq09_sp_side_effects_report.json" `
    -EvidenceDir ".planning\comms\aq09_smoke_runbook_20260520\evidence" `
    -Executor "Manoel Benicio"
```

The default run first probes `pac connection list`, inventories accessible flows with the local Power Apps PowerShell `Get-Flow` cmdlet, and searches `Get-FlowRun` history for mapped AQ-09 flows in the smoke window. Pass `-EnvironmentName <environment-guid-or-url>` if the active Power Platform environment is not already the smoke environment. A run ID is written when one is found; otherwise the stub receives `N/A` plus a `prepop:run_lookup` comment.

Use `-SkipFlowRunLookup` for offline/sample generation. That mode still prepopulates the Track G-backed fields and records that run-history lookup was skipped.

## Populated Fields

The script populates placeholder fields only:

- `executor` and current BRT `date_brt`; it verifies the fixed V2 build, bot, and environment values already present in stubs.
- Canonical chat-input lines from the AQ-09 runbook.
- `run_url_or_id` from readable flow history when found, otherwise `N/A`.
- SharePoint `expected`, `actual`, and `pnp_output_path` fields from the runbook mapping and Track G JSON report.

Track G reports `tests.A1_CMD-12-H` through `tests.A5_CMD-10`. Section B stubs receive explicit `N/A - Track G side-effect report has no ... observation` text because the current Track G report has no structured B-test observations.

The script intentionally does not alter transcript fences, XPIA marker judgement fields, screenshot placeholders, or outcome placeholders. Those remain Owner review work.

## Safety And Manifest

A virgin V2 stub gets this exact comment at the bottom of its metadata block. Metadata placeholders are filled during that virgin-stub initialization; reruns auto-fill only the below-marker placeholder fields.

```markdown
<!-- prepop:auto -->
```

That marker arms later prepopulation attempts. Removing or editing it locks the stub and records `missing_or_modified_prepop_marker` in the manifest. Even with the marker intact, non-placeholder field content is skipped rather than overwritten, so a rerun is idempotent around Owner edits.

Each run writes `<EvidenceDir>/.prepop_manifest.json` with per-stub updated fields and skipped-field reasons.

## Validation

Before transcript paste, V2 validation is expected to throw `FAIL_AQ09_INCOMPLETE` because all `TRANSCRIPT` fences remain empty:

```powershell
.\tests\Test-Aq09SmokeEvidence.ps1 `
    -EvidenceDir ".planning\comms\aq09_smoke_runbook_20260520\evidence" `
    -ReportPath ".planning\comms\aq09_smoke_runbook_20260520\sp_side_effects\<run>\aq09_prepop_validation.json"
```

The transcript-empty report should show A1-A5 as `FAIL_MISSING_TRANSCRIPT`, not missing evidence.

## Sample

`sample_populated_stubs/` is generated from the Track G dry-run report at `.planning/comms/aq09_sp_side_effects_harness_20260521/sample_outputs/aq09_sp_side_effects_report.json` with flow lookup skipped.
