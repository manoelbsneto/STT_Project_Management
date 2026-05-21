# P0-W2-7-PREP-FIX Report

Timestamp BRT: 2026-05-21T01:20:32-03:00  
Executor: CODEX-QA  
Scope: Local-only remediation of AQ-09 evidence validator/template contract for Assistente PMO V2 / ColOfertasBrasilPro. No tenant, PAC, browser, SharePoint, Power Automate, publish, git commit, or git push actions were performed.

## Contract Reference

Authoritative contract: `.planning/comms/aq09_smoke_runbook_20260520/VALIDATOR_CONTRACT_AQ09.md`  
SHA256: `513524DE37BB499BCDC140235F35687233450A0D22B5A15EBF02DDB7A312126E`

## Changes Implemented

| Area | Change |
|---|---|
| Validator | `tests/Test-Aq09SmokeEvidence.ps1` now extracts only the `<!-- TRANSCRIPT BEGIN -->` / `<!-- TRANSCRIPT END -->` block before scanning for marker strings. |
| Validator | Added `FAIL_MISSING_TRANSCRIPT`, `FAIL_MISSING_REQUIRED_FIELD`, `LEGACY_INCOMPLETE`, and top-level `FAIL_AQ09_INCOMPLETE`. |
| Validator | Added required-field validation for metadata, chat input, transcript, run ID, PnP output path, marker observation booleans, screenshot path, and result. |
| Validator | Reads evidence files as UTF-8 so contract headings using `—` parse correctly under Windows PowerShell 5.1. |
| Template | Rewrote `EVIDENCE_TEMPLATE.md` to V2 fenced layout from the contract. |
| Evidence stubs | Rewrote all 12 real evidence stubs under `evidence/` with empty transcript fences for Owner AQ-09 capture. |
| Self-tests | Added V2 fixtures and captured stdout/stderr/exit/report JSON under `_validator_self_test/v2/`. |

## Stub Inventory After V2 Rewrite

| Filename | Section | Present | Byte size |
|---|---|---:|---:|
| A1_CMD-12-H.md | A in-scope ship-gate | yes | 935 |
| A2_CMD-15.md | A in-scope ship-gate | yes | 936 |
| A3_CMD-11-P0.md | A in-scope ship-gate | yes | 935 |
| A4_CMD-13A.md | A in-scope ship-gate | yes | 935 |
| A5_CMD-10.md | A in-scope ship-gate | yes | 933 |
| B1_ConsultarProjeto.md | B legacy debt evidence | yes | 956 |
| B2_CriarProjeto.md | B legacy debt evidence | yes | 944 |
| B3_ExcluirProjeto.md | B legacy debt evidence | yes | 950 |
| B4_ExcluirTarefa.md | B legacy debt evidence | yes | 947 |
| B5_PedirDecisao_InvalidUPN.md | B legacy debt evidence | yes | 955 |
| B6_RegistrarBloqueio.md | B legacy debt evidence | yes | 959 |
| B7_RegistrarRisco.md | B legacy debt evidence | yes | 950 |

## Before / After Stub Snippet

Before V2, the required stub label embedded literal scan targets:

```markdown
XPIA markers observed (yes/no for each: ContentFiltered, openAIIndirectAttack, "Responsible AI restrictions", "Etapa Bloqueada")
```

After V2, marker names are not present in labels and only the transcript fence is scanned:

```markdown
## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
<!-- TRANSCRIPT END -->

## XPIA marker observation

- cf_observed: yes | no
- oai_observed: yes | no
- rai_observed: yes | no
- eb_observed: yes | no
```

## Self-Test Results

| Fixture | Evidence path | Expected decision | Actual decision | Exit | Result |
|---|---|---|---|---:|---|
| Negative-real | `.planning/comms/aq09_smoke_runbook_20260520/evidence` | `FAIL_AQ09_INCOMPLETE` | `FAIL_AQ09_INCOMPLETE` | 1 | PASS |
| Positive | `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/positive` | `PASS_XPIA_01_RESOLVED` | `PASS_XPIA_01_RESOLVED` | 0 | PASS |
| XPIA-trigger | `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/xpia_trigger` | `FAIL_XPIA_01_RECURS_OR_UNKNOWN` | `FAIL_XPIA_01_RECURS_OR_UNKNOWN` | 1 | PASS |

### Negative-real Details

Outputs:

- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/negative_real_stdout.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/negative_real_stderr.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/negative_real_exit.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/negative_real_report.json`

Per-test in-scope statuses: A1-A5 all `FAIL_MISSING_TRANSCRIPT`. Legacy B1-B7 all `LEGACY_INCOMPLETE`.

### Positive Details

Outputs:

- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/positive_stdout.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/positive_stderr.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/positive_exit.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/positive_report.json`

Per-test in-scope statuses: A1-A5 all `PASS`. Legacy B1-B7 all `LEGACY_NOT_RUN`.

### XPIA-trigger Details

Outputs:

- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/xpia_trigger_stdout.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/xpia_trigger_stderr.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/xpia_trigger_exit.txt`
- `.planning/comms/aq09_smoke_runbook_20260520/_validator_self_test/v2/xpia_trigger_report.json`

Per-test in-scope statuses: A1 `FAIL_XPIA_RECURS`; A2-A5 `PASS`. Legacy B1-B7 all `LEGACY_NOT_RUN`.

## V1 to V2 Delta

V1 failed empty stubs as `FAIL_XPIA_RECURS` because the stub labels contained the exact marker strings and the validator scanned the whole file. V2 fails empty real stubs as `FAIL_MISSING_TRANSCRIPT`, with marker booleans false, because only Owner-authored transcript content between fences is scanned.

## Readiness for Opus 4.7 Sign-off

`tests/Test-Aq09SmokeEvidence.ps1`, `EVIDENCE_TEMPLATE.md`, and the 12 real evidence stubs have been updated to the V2 contract. All three CODEX-QA self-tests are captured under `_validator_self_test/v2/` and match contract section 7 expected decisions. This is ready for Opus 4.7 independent verification and sign-off.

## Risks / Notes

- Screenshot file existence is warning-only in V2 per contract section 9; synthetic fixtures therefore pass with screenshot path warnings.
- V1 self-test outputs were left in place as historical evidence.
- No changes were made to `.planning/STATE.md`, `.planning/stop_ship/MASTER_CHECKLIST.md`, fixed YAML topic files, production solution zips, or tenant/runtime resources.
