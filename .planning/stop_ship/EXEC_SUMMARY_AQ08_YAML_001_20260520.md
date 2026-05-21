# EXEC SUMMARY — ISSUE-AQ08-YAML-001 Closeout (Owner-paste delivery)

**Date:** 2026-05-20
**Author:** CODEX-PA
**Mission:** Deliver 5 fixed topic YAML files for AQ-08 hybrid card-first migration; restore Owner-side ability to apply Copilot Studio remediation after first delivery failed.
**Status (artifact layer):** **SHIP** — all 8 quality gates PASS for all 5 files.
**Status (release):** **NO-SHIP** for 3.15 publish until: (a) Owner pastes/saves all 5 files, (b) reverify PASSES, (c) Owner publishes, (d) AQ-09 smoke + XPIA-01 PASS, (e) AQ-10 final sign-off.

## What changed

- Built deterministic, gated, minimal-diff YAML builder: `scripts/Build-Aq08FixedTopicYamls.py`.
- Re-emitted the 5 fixed topic YAML files with byte-level fidelity to the live AS-IS extracts, except for the documented minimum change required to swap the action call from legacy `PMO_PA_*` to `PM0_PA_Card_*`.
- Stripped legacy substrings from comment headers (so the AQ-08 reverify substring scan returns zero hits).
- Switched output line endings to CRLF (matching the live tenant), eliminating the original Copilot Studio parse error.
- Added 8 mandatory quality gates (G1..G8). Files that fail any gate are not written and not shown to the Owner.

## Top 5 risks and mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| Copilot Studio Code Editor still rejects a paste due to an unanticipated parser quirk | Medium | Sequential one-at-a-time delivery starts with smallest file (ListarTarefas, 1-line edit). If that paste fails, halt and diagnose before file 2/5. |
| New action component schema diverges from legacy at runtime (input/output binding shape) | Medium | The 3 simple-swap topics (AtualizarTarefa, CriarTarefa, ListarTarefas) reuse the existing `BeginDialog` shape that already works in tenant for similar topics. The 2 structural-conversion topics (AtualizarStatus, ConsultarPortfolio) follow the same `input: {}` + `output.binding.<key>: <var>` pattern as the working topics. AQ-09 smoke will catch any runtime schema mismatch before final SHIP. |
| Owner saves a topic but reverify still BLOCKS | Low | The reverify reads `botcomponent.data` directly from Dataverse via PAC FetchXML. If the Code Editor accepts and saves my YAML, the data field reflects the new action ref and the substring scan PASSes. We have explicitly tested the substring scan locally (G6) before delivery. |
| Sequential delivery pace slows Owner unduly | Low | Each file is small. Median paste-and-save is under 60 seconds. We accept the slowdown as the cost of stop-ship discipline. |
| Stop-ship process drift over time | Medium | Owner directive captured verbatim at `.planning/comms/SEV0_STOP_SHIP_PROTOCOL_USER_DIRECTIVE_20260520.md`. Future agents must produce the Section 6 deliverables before any code shipment. |

## Proof of safety

| Layer | Proof |
|---|---|
| YAML parses with strict parser | PyYAML 6.0.3 `safe_load` PASS for all 5 files |
| Edit distance bounded | `difflib.SequenceMatcher` opcodes: 1 / 1 / 1 / 5 / 12 edits |
| No legacy strings remain | Substring count == 0 for `PMO_PA_*` action ref and legacy flow GUID, on every file (incl. comments) |
| Line endings match tenant | CRLF count parity per file; LF-only count == 0 |
| Top-level YAML keys preserved | Set equality vs AS-IS for every file |
| Build is reproducible | `python scripts\Build-Aq08FixedTopicYamls.py` returns exit 0 deterministically |

## What is still risky

- All 5 files must be applied by the Owner inside Copilot Studio. That step is outside agent control.
- The reverify is read-only and depends on PAC FetchXML returning the saved topic data. PAC environment must be authenticated when the reverify is run.
- Owner publish, AQ-09 smoke, and XPIA-01 evidence are sequential downstream gates that the artifact-level SHIP does not override.

## Linked artifacts

| Doc | Path |
|---|---|
| Owner directive (binding protocol) | `.planning/comms/SEV0_STOP_SHIP_PROTOCOL_USER_DIRECTIVE_20260520.md` |
| RCA | `.planning/stop_ship/ISSUE_RCA_AQ08_YAML_001_20260520.md` |
| Evidence log | `.planning/stop_ship/EVIDENCE_LOG_AQ08_YAML_001_20260520.md` |
| Test strategy | `.planning/stop_ship/TEST_STRATEGY_AQ08_YAML_001_20260520.md` |
| Release readiness | `.planning/stop_ship/RELEASE_READINESS_AQ08_YAML_001_20260520.md` |
| QA evidence (per-file) | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/QA_EVIDENCE.md` |
| Gated builder | `scripts/Build-Aq08FixedTopicYamls.py` |
| Independent validator | `scripts/Test-Aq08FixedTopicYamls.py` |
| Reproduction tool | `scripts/Diff-CriarTarefaYaml.ps1` |

## SHIP/NO-SHIP statement (explicit)

- Artifact-layer (5 fixed topic YAML files): **SHIP**.
- AQ-08 routing change in live tenant: **NO-SHIP** until reverify PASSES.
- 3.15 publish: **NO-SHIP** until reverify PASSES + Owner approves.
- AQ-10 final release: **NO-SHIP** until full chain PASSES.

The next concrete step is Owner-side: paste `ListarTarefas.yaml` into Copilot Studio Code Editor, save, and confirm. No further file is shown until that confirmation arrives.
