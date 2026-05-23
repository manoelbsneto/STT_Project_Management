# CODEX-QA Track H — Post-Publish Drift Monitoring + AQ-09 Evidence Stub Pre-Population Tooling

Date BRT: 2026-05-21T10:57:00-03:00
Owner: Manoel Benicio
Author: Opus 4.7
Target: CODEX-QA
Estimated: 90 min total (45 min Part 1 + 45 min Part 2), fully parallel
Severity: HIGH (defensive — productizes manual checks CODEX-PA will otherwise do by hand)

## Mandatory References

| Reference | Purpose |
|---|---|
| `tests/Test-Aq08PostRemediationReverify.ps1` | Existing topic routing verifier. Both parts reuse its core logic. |
| `.planning/comms/CODEX_PA_P0_W2_TRACK_B_ANOMALY_REMEDIATION_v2_20260521.md` §F | Defines the +5 min / +1 h / +6 h drift recheck cadence after publish. |
| `.planning/comms/aq08_flow_output_schemas_20260521/FLOW_OUTPUT_SCHEMA_AUDIT.md` | Authoritative flow output schema (`result` for all 5). Both parts reference this. |
| `.planning/comms/aq09_smoke_runbook_20260520/EVIDENCE_TEMPLATE.md` | V2 fenced layout. Part 2 must produce stub fields matching this. |
| `tests/Test-Aq09SmokeEvidence.ps1` (V2) | Validator. Part 2 stubs must satisfy V2 contract. |

## Mission

Build two scripts that productize manual work CODEX-PA and Owner will otherwise do by hand. Both are read-only PAC / PnP harnesses.

---

## Part 1 — Post-Publish Drift Monitoring (~45 min)

### Functional requirements

Build `tests/Test-Aq08PublishDriftMonitor.ps1`. Owner runs it ONCE after Owner publishes 3.15. The script schedules and executes three reverify passes at +5 min, +1 h, and +6 h relative to invocation, captures evidence per pass, diffs each pass against the previous, and produces a final SHIP/HOLD/ROLLBACK recommendation.

#### Inputs

```powershell
.\tests\Test-Aq08PublishDriftMonitor.ps1 `
    -PublishUtc "2026-05-21T18:30:00Z" `
    -OutputDir  ".planning\comms\aq08_topic_routing_verification_20260520\post_publish_verify\drift_monitoring_<timestamp>"
```

If `-PublishUtc` is in the past by more than 6 h, abort with error (we have already missed the window).

#### Behavior

1. At T+5 min from invocation: run `Test-Aq08PostRemediationReverify.ps1`. Save outputs under `<OutputDir>/T+5min/`.
2. At T+1 h: same, under `<OutputDir>/T+1h/`.
3. At T+6 h: same, under `<OutputDir>/T+6h/`.
4. After each pass, write a per-pass `summary.md` with: timestamp, decision (PASS/BLOCK), per-topic status, raw `botcomponent.data` fingerprint hash for each of the 5 topics.
5. After T+6 h: write `<OutputDir>/DRIFT_DECISION.md` with:
   - Cross-pass diff table: per-topic, did the fingerprint change between passes?
   - Final recommendation: `SHIP` (all 3 passes PASS, fingerprints stable) | `HOLD` (mixed PASS/BLOCK) | `ROLLBACK` (regression to BLOCK or fingerprint drift on any in-scope topic).
6. Exit code: 0 for SHIP, 1 for HOLD/ROLLBACK.

#### Hard requirements

- Read-only PAC. Same prohibitions as `Test-Aq08PostRemediationReverify.ps1`.
- The 5 min / 1 h / 6 h windows MUST be measured from script invocation, not from `-PublishUtc`. The `-PublishUtc` arg is for evidence labeling and missed-window detection only.
- The script can be backgrounded; if Owner closes the terminal, drift monitoring stops. Document this clearly in the README.
- Each pass captures full `botcomponent.data` text for the 5 in-scope topics. Fingerprint = SHA256 of the data string.

### Deliverables

1. `tests/Test-Aq08PublishDriftMonitor.ps1`.
2. Self-test fixtures under `tests/fixtures/aq08_drift_monitor/` — captured outputs for one immediate dry-run pass (no actual T+5/T+1h/T+6h waits — use `-DryRun` flag to run all three back-to-back).
3. `.planning/comms/aq08_drift_monitor_20260521/README.md` — usage, examples, recommended flow.

---

## Part 2 — AQ-09 Evidence Stub Pre-Population (~45 min)

### Functional requirements

Build `tests/Build-Aq09EvidenceFromArtifacts.ps1`. Owner runs it after the AQ-09 smoke chat session AND after Track G's `Test-Aq09SharePointSideEffects.ps1`. The script populates the 12 evidence stub files with everything the harness can fill in deterministically. Owner is then left with only the chat transcript paste step.

#### Inputs

```powershell
.\tests\Build-Aq09EvidenceFromArtifacts.ps1 `
    -SmokeStartUtc        "2026-05-21T18:00:00Z" `
    -SmokeEndUtc          "2026-05-21T20:00:00Z" `
    -SpSideEffectsReport  ".planning\comms\...\sp_side_effects\...\aq09_sp_side_effects_report.json" `
    -EvidenceDir          ".planning\comms\aq09_smoke_runbook_20260520\evidence" `
    -Executor             "Manoel Benicio"
```

#### Per-stub fields the script populates

For each of the 12 stubs (A1-A5, B1-B7):

- `## Metadata`: `executor`, `date_brt` (current BRT), `build_under_test: 3.15`, `bot: Assistente PMO V2`, `environment: ColOfertasBrasilPro`. Stub heading and `test_id` already correct from V2 layout.
- `## Chat input`: pre-fill the `INPUT BEGIN/END` fence with the canonical chat input from `EVIDENCE_TEMPLATE.md`'s reference list, one verbatim line per test.
- `## Bot response transcript`: leave the `TRANSCRIPT BEGIN/END` fence empty. Owner manually pastes verbatim bot output (one and only step left for Owner).
- `## Power Automate run`: `run_url_or_id`: try to look up the most recent run for the corresponding flow in the smoke window via `pac connection list` + flow history; if not found, leave as `N/A` with a comment.
- `## SharePoint side effect`: `expected: <from runbook reference>`, `actual: <copied from SpSideEffectsReport>`, `pnp_output_path: <SpSideEffectsReport path>`.
- `## XPIA marker observation`: leave defaults (`yes | no`) untouched. These are Owner judgement after reading transcript.
- `## Screenshot`: leave default placeholder. Owner attaches per the runbook.
- `## Outcome`: leave default. Owner sets after review.

#### Idempotency and safety

- The script MUST NOT overwrite a stub field that already contains non-default Owner content. Use a state-tracking comment line `<!-- prepop:auto -->` at the bottom of each metadata block; only fields below an unmodified prepop line are auto-filled. If the line is removed or modified by Owner, the script skips that field.
- Output JSON manifest: `<EvidenceDir>/.prepop_manifest.json` listing which stubs received which fields and which were skipped (with reasons).
- Must respect V2 fenced layout exactly. Run `tests/Test-Aq09SmokeEvidence.ps1` against the populated stubs as a self-check (expected: `FAIL_AQ09_INCOMPLETE` because transcripts still empty — but no `FAIL_MISSING_REQUIRED_FIELD` for fields the script did populate).

### Deliverables

1. `tests/Build-Aq09EvidenceFromArtifacts.ps1`.
2. `.planning/comms/aq09_evidence_prepop_20260521/README.md` — usage, examples, the order Owner runs scripts (smoke chat → Track G harness → this prepop → V2 validator).
3. Sample populated stubs in `.planning/comms/aq09_evidence_prepop_20260521/sample_populated_stubs/` against the dry-run inputs from Track G's sample outputs.

---

## Hard Prohibitions for Both Parts

No tenant writes. No `Set-PnPListItem`, `Add-PnPListItem`, `Remove-PnPListItem`. No PAC write subcommands. No Copilot Studio UI. No git commit. No modification of `tests/Test-Aq09SmokeEvidence.ps1` or any V2 self-test outputs. No edits to `AGENT_CHECKIN_REGISTRY.md` outside CODEX-QA's own row.

## Acceptance Gate

Both Parts complete when:
1. Both scripts exist and are runnable.
2. Self-test fixtures in tests/fixtures/ produce expected outputs.
3. READMEs explain Owner usage.
4. V2 evidence validator returns clean status against pre-populated stubs (only transcript missing).

## Conflict Coordination

CODEX-PA is currently in the middle of v2 anomaly remediation. CODEX-QA writes ONLY under:
- `tests/Test-Aq08PublishDriftMonitor.ps1` (new)
- `tests/Build-Aq09EvidenceFromArtifacts.ps1` (new)
- `tests/fixtures/aq08_drift_monitor/` (new)
- `.planning/comms/aq08_drift_monitor_20260521/` (new)
- `.planning/comms/aq09_evidence_prepop_20260521/` (new)

No collision with CODEX-PA's `Build-Aq08FixedTopicYamls.py` work or with Gemini-PA's Track G `tests/Test-Aq09SharePointSideEffects.ps1`.

End of dispatch.
