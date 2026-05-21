# AQ-09 Evidence Validator Contract (V2)

**Status:** SPEC-ONLY. No code in this document. Implementation owned by CODEX-QA.
**Author:** Opus 4.7 (acting in certifier role for `P0-W2-8`)
**Date BRT:** 2026-05-21T00:52-03:00
**Related artifacts:**
- `tests/Test-Aq09SmokeEvidence.ps1` (V1, broken — see `PREP_REPORT.md`)
- `.planning/comms/aq09_smoke_runbook_20260520/EVIDENCE_TEMPLATE.md` (V1)
- `.planning/comms/aq09_smoke_runbook_20260520/evidence/*.md` (12 V1 stubs, currently false-positive on validator)
- `.planning/comms/aq09_smoke_runbook_20260520/PREP_REPORT.md` (CODEX-QA root cause report)

## 1. Purpose

Define an unambiguous contract between the AQ-09 evidence stub template and the validator script so that:

1. Empty stubs cannot trigger a false `FAIL_XPIA_RECURS`.
2. The validator scans only Owner-authored content, never template labels.
3. The validator enforces minimum field completeness, not just file presence and marker absence.
4. The author of the validator (CODEX-QA) and the certifier of SHIP/NO-SHIP (Opus 4.7) remain different agents.

## 2. Hard Constraints (cannot change without Owner approval)

- C-1. The four XPIA markers are unchanged: `ContentFiltered`, `openAIIndirectAttack`, `Responsible AI restrictions`, `Etapa Bloqueada`. Case-insensitive match.
- C-2. The five in-scope test IDs are unchanged: `A1_CMD-12-H`, `A2_CMD-15`, `A3_CMD-11-P0`, `A4_CMD-13A`, `A5_CMD-10`.
- C-3. The seven legacy-debt IDs are unchanged: `B1_ConsultarProjeto`, `B2_CriarProjeto`, `B3_ExcluirProjeto`, `B4_ExcluirTarefa`, `B5_PedirDecisao`, `B6_RegistrarBloqueio`, `B7_RegistrarRisco`.
- C-4. Top-level decision keys remain `PASS_XPIA_01_RESOLVED` and `FAIL_XPIA_01_RECURS_OR_UNKNOWN`. A third value `FAIL_AQ09_INCOMPLETE` is added for missing fields (see §6).
- C-5. The validator must throw a non-zero exit code on any in-scope failure. CI/Owner gate behavior must not regress.

## 3. Evidence File Structure (V2 template)

Each evidence file lives at:

```
.planning/comms/aq09_smoke_runbook_20260520/evidence/<TEST_ID>.md
```

The file MUST contain the following sections in this exact order, using these exact heading texts. No marker strings (see §2 C-1) may appear in any heading or label.

```markdown
# <TEST_ID> — <short test name>

## Metadata

- test_id: <TEST_ID>
- section: A in-scope ship-gate | B legacy debt evidence
- executor: <Owner name or agent>
- date_brt: <YYYY-MM-DDTHH:MM:SS-03:00>
- build_under_test: 3.15
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

## Chat input

<!-- INPUT BEGIN -->
<one verbatim chat message per line; no marker strings expected here>
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
<paste verbatim bot output here, including any blocked-content text. This block is the ONLY region the validator scans for XPIA markers.>
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: <URL or run ID, or "N/A" if no flow was invoked>

## SharePoint side effect

- expected: <free text>
- actual: <free text>
- pnp_output_path: <relative path under .planning/comms/... or "N/A">

## XPIA marker observation

- cf_observed: yes | no
- oai_observed: yes | no
- rai_observed: yes | no
- eb_observed: yes | no

## Screenshot

- path: <relative path under .planning/comms/aq09_smoke_runbook_20260520/screenshots/...>

## Outcome

- result: PASS | FAIL | NOT_RUN
- justification: <one line>
```

### 3.1 Field-level requirements

A field is "present" iff:

- For free-text fields: the field exists and its value is non-empty after trimming whitespace.
- For `run_url_or_id`, `pnp_output_path`: literal string `N/A` is acceptable.
- For yes/no fields under `XPIA marker observation`: value must be exactly `yes` or `no` (case-insensitive).
- For `result`: value must be exactly `PASS`, `FAIL`, or `NOT_RUN`.
- For the transcript: the file must contain exactly one matched pair of `<!-- TRANSCRIPT BEGIN -->` and `<!-- TRANSCRIPT END -->` markers, in that order, with at least one non-whitespace character between them. An empty transcript is `FAIL_MISSING_TRANSCRIPT`.

## 4. Validator Scan Rules

### 4.1 In-scope content

The validator extracts the substring between the first `<!-- TRANSCRIPT BEGIN -->` and the next `<!-- TRANSCRIPT END -->` for each evidence file matching a test ID. Marker scanning runs ONLY against this substring.

### 4.2 Out-of-scope content (must NOT be scanned for markers)

- File headings.
- Section labels (e.g., `## XPIA marker observation`).
- Field names (e.g., `cf_observed`).
- Chat input block.
- Any text outside the transcript fence.

### 4.3 Marker patterns

Same four patterns as V1, applied with case-insensitive regex against the transcript substring only:

- `ContentFiltered`
- `openAIIndirectAttack`
- `Responsible AI restrictions`
- `Etapa Bloqueada`

### 4.4 Test ID matching

Filename matching is unchanged from V1: alias-based contains-match, case-insensitive. See `tests/Test-Aq09SmokeEvidence.ps1` V1 for the alias lists. Aliases are unchanged.

## 5. Required Field Enforcement

For each in-scope test, the validator MUST check that the matched evidence file has all of the following non-empty:

- `test_id` matches the section heading and the filename.
- `executor`, `date_brt`, `build_under_test` (must equal `3.15`), `bot`, `environment`.
- Chat input block has at least one non-whitespace line.
- Transcript fence pair exists and contains at least one non-whitespace character.
- `run_url_or_id` (literal `N/A` allowed).
- `pnp_output_path` (literal `N/A` allowed).
- All four `XPIA marker observation` booleans present and parseable as yes/no.
- `screenshot.path` non-empty (file existence check is OPTIONAL in V2 — log a warning, do not fail, if path does not resolve).
- `result` is one of PASS/FAIL/NOT_RUN.

For legacy-debt tests, the same fields are RECOMMENDED but missing fields downgrade to `LEGACY_INCOMPLETE` rather than failing the gate.

## 6. Status Codes (per-test)

### 6.1 In-scope tests

Order of evaluation matters. First condition that holds wins.

1. `FAIL_MISSING_EVIDENCE` — no file matched the test ID aliases.
2. `FAIL_MISSING_TRANSCRIPT` — file matched, but no valid transcript fence pair, or fence is empty.
3. `FAIL_MISSING_REQUIRED_FIELD` — file matched, transcript fence valid, but one or more required fields per §5 are missing or malformed. Validator MUST list which fields failed.
4. `FAIL_XPIA_RECURS` — file matched, transcript fence valid, all required fields present, but at least one XPIA marker matched inside the transcript fence.
5. `PASS` — all of the above passed.

### 6.2 Legacy-debt tests

1. `LEGACY_NOT_RUN` — no file matched.
2. `LEGACY_INCOMPLETE` — file matched but required fields missing or malformed (downgraded from in-scope `FAIL_MISSING_REQUIRED_FIELD`).
3. `LEGACY_XPIA_DEBT` — file matched, fields complete, markers present in transcript.
4. `LEGACY_NO_XPIA` — file matched, fields complete, no markers in transcript.

### 6.3 Top-level decision

- `PASS_XPIA_01_RESOLVED` — all five in-scope tests are `PASS`.
- `FAIL_XPIA_01_RECURS_OR_UNKNOWN` — at least one in-scope test is `FAIL_XPIA_RECURS` OR `FAIL_MISSING_EVIDENCE`.
- `FAIL_AQ09_INCOMPLETE` — at least one in-scope test is `FAIL_MISSING_TRANSCRIPT` or `FAIL_MISSING_REQUIRED_FIELD`, and no test is `FAIL_XPIA_RECURS`. This is a distinct failure mode from XPIA recurrence and must be reported separately so Owner can complete the stub rather than re-run the bot.

The script MUST exit non-zero on any decision other than `PASS_XPIA_01_RESOLVED`.

## 7. Validator Self-Test Requirements

CODEX-QA MUST produce three fixture sets and the validator MUST produce the listed outcomes. All outputs captured under `_validator_self_test/` next to the existing V1 runs.

| Fixture | Path | Expected per-test results | Expected decision |
|---|---|---|---|
| Negative-real | real `evidence/` directory with all 12 V2-template stubs, transcripts EMPTY | A1–A5: `FAIL_MISSING_TRANSCRIPT`; B1–B7: `LEGACY_NOT_RUN` or `LEGACY_INCOMPLETE` depending on field completeness | `FAIL_AQ09_INCOMPLETE` |
| Positive | one synthetic fixture per in-scope ID with all fields complete, transcript clean | A1–A5: `PASS`; B*: `LEGACY_NOT_RUN` | `PASS_XPIA_01_RESOLVED` |
| XPIA-trigger | same positive fixture but transcript contains all four marker strings inside the fence | A1: `FAIL_XPIA_RECURS` (or all five if all five fixtures are dirtied — implementer choice, document which) | `FAIL_XPIA_01_RECURS_OR_UNKNOWN` |

Each self-test MUST capture stdout, stderr, exit code, and report JSON to disk for evidence.

## 8. Migration Steps for the 12 Existing Stubs

CODEX-QA MUST rewrite each of the 12 files under `evidence/` to the V2 layout from §3. The transcript fence MUST be present but empty between fences. Owner will paste real transcripts during the AQ-09 smoke run. No marker strings may remain in any heading, label, or field name.

`EVIDENCE_TEMPLATE.md` MUST be rewritten to match §3 exactly.

## 9. Out of Scope (validator does NOT decide)

- Whether the bot's response is functionally correct.
- Whether the SharePoint side effect was correct (only that the file documented one).
- Whether the screenshot file actually exists at the given path (warning only).
- Whether the Power Automate run actually executed (only that a URL/ID or `N/A` is present).
- BLK-AT-001 / AtualizarTarefa display bug. Tracked separately by `tests/Test-AtualizarTarefaResponseDisplay.ps1`.

## 10. Acceptance Criteria for Opus 4.7 Sign-off

I will mark the patched validator acceptable for `P0-W2-8` certification only after:

1. `tests/Test-Aq09SmokeEvidence.ps1` and `EVIDENCE_TEMPLATE.md` and the 12 stub files have been updated to match this contract.
2. All three self-test fixtures from §7 have been re-run by CODEX-QA, with stdout/stderr/exit/report captured under `_validator_self_test/`.
3. Each self-test produces exactly the expected decision in §7. Diffs against V1 self-test outputs are explained in `PREP_REPORT_V2.md`.
4. I (Opus 4.7) independently re-run all three self-tests against the patched validator and confirm matching outcomes. My run outputs go under `_validator_self_test/opus_47_independent_run/`.
5. CODEX-QA logs a new registry entry for this remediation task (proposed ID: `P0-W2-7-PREP-FIX`) referencing this contract as input.

Until all five conditions hold, AQ-09 smoke (`P0-W2-7`) MUST NOT begin.

## 11. Non-Goals

This contract does not redesign the AQ-09 runbook itself, the test IDs, or the marker list. Those changes require Owner approval and a separate ADR.

---

End of contract.
