# Test Strategy — AQ-08 Fixed Topic YAML Builder

**Owning issue:** ISSUE-AQ08-YAML-001
**Status:** All gates green for the 5 fixed topic YAML files as of 2026-05-20 22:45 BRT.
**Reproducible by:** `python scripts\Build-Aq08FixedTopicYamls.py` (must exit 0).

## 1. Test layers

| Layer | What it covers | Tooling | Where |
|---|---|---|---|
| Unit | Single-file validation: non-empty, no BOM, line endings, strict YAML parse, top-level key set | Python 3.14 + PyYAML 6.0.3 | `scripts/Build-Aq08FixedTopicYamls.py` (gates G1..G4, G7) |
| Contract | Byte-level fidelity vs AS-IS extract from live Dataverse | `difflib.SequenceMatcher` (true edit distance) | `scripts/Build-Aq08FixedTopicYamls.py` (gate G5) |
| Contract | Substring scan for legacy `PMO_PA_*` and legacy flow GUIDs | str.find / str.count | `scripts/Build-Aq08FixedTopicYamls.py` (gate G6) |
| Contract | New action component appears exactly once | str.count | `scripts/Build-Aq08FixedTopicYamls.py` (gate G8) |
| Integration | Pasted YAML loads in Copilot Studio Code Editor without parser error | Owner action | Copilot Studio UI |
| Integration | Live tenant routing reflects the new action component | PAC FetchXML + PowerShell | `tests/Test-Aq08PostRemediationReverify.ps1` |

## 2. Coverage goals and current levels

| Topic | AS-IS bytes | FIXED bytes | Edit lines vs AS-IS | Gate set passed |
|---|---:|---:|---:|---|
| AtualizarStatus.yaml | 8874 | 8606 | 12 | G1..G8 PASS |
| AtualizarTarefa.yaml | 15255 | 15260 | 1 | G1..G8 PASS |
| ConsultarPortfolio.yaml | 1295 | 1219 | 5 | G1..G8 PASS |
| CriarTarefa.yaml | 6889 | 6894 | 1 | G1..G8 PASS |
| ListarTarefas.yaml | 2095 | 2100 | 1 | G1..G8 PASS |

The gate set is exhaustive at the artifact level: every byte of every output file is either equal to AS-IS or is part of the documented minimal change. There is no "untested code path" at the YAML level; the entire file is tested.

## 3. Regression suite mapping (issue → tests)

| Issue | Test | Pre-fix expected | Post-fix expected |
|---|---|---|---|
| ISSUE-AQ08-YAML-001 (line endings) | G3 line endings match AS-IS | FAIL on first delivery | PASS on rebuilt artifact |
| ISSUE-AQ08-YAML-001 (legacy strings in comments) | G6 no legacy substring | FAIL for AtualizarStatus, ConsultarPortfolio on first delivery | PASS on rebuilt artifact (legacy comments stripped) |
| ISSUE-AQ08-YAML-001 (over-edit risk) | G5 minimal edit distance | (not measured first time; would have FAILED with 32+ edits on AtualizarStatus) | PASS (12 edits AtualizarStatus, ≤5 elsewhere) |
| Future regression: any topic YAML re-write breaks tenant parser | G4 strict YAML parse | FAIL | PASS |

## 4. Negative tests (proof the gates actually catch the failure)

| Test | Method | Result |
|---|---|---|
| G3 catches LF-only output | First-pass `scripts/Test-Aq08FixedTopicYamls.py` against the LF-only files I shipped initially | All 5 files reported `[FAIL] G3 line endings match`. PASS — the gate fires on the failure. |
| G6 catches legacy substring in comment | Same first-pass run | AtualizarStatus and ConsultarPortfolio reported `[FAIL] G6 no legacy action ref anywhere (incl. comments)`. PASS — the gate fires on the failure. |
| G5 catches accidental over-edit | Intermediate builder run before line-ending fix | AtualizarStatus reported 32 diff lines (over the 30-line bound) and was rejected. PASS — the gate fires. |
| G5 false-positive due to line-shift drift | Intermediate run | The naïve line-by-line diff reported 167 diffs for AtualizarStatus when the true change was 12 edits. The gate was upgraded to `difflib.SequenceMatcher` opcodes; the false positive disappeared. PASS — the gate is now sound. |

## 5. Owner-runtime tests (not yet run)

| Step | Test | Expected | When |
|---|---|---|---|
| Step 1 | Owner pastes ListarTarefas.yaml into Copilot Studio Code Editor and saves | No YAML error, save succeeds | Now (file 1/5) |
| Step 2..5 | Same for CriarTarefa, AtualizarTarefa, ConsultarPortfolio, AtualizarStatus | Same | Sequential, after each prior save |
| Step 6 | `tests/Test-Aq08PostRemediationReverify.ps1` against live tenant | OverallDecision: PASS, exit code 0 | After all 5 saves |
| Step 7 | Owner publishes `Assistente PMO V2` | Successful publish | After Step 6 PASS |
| Step 8 | AQ-09 smoke runbook | All 5 in-scope topics PASS, no ContentFiltered/openAIIndirectAttack | After Step 7 |
| Step 9 | XPIA-01 evidence validator | OverallDecision: PASS | After Step 8 |
| Step 10 | AQ-10 final SHIP/NO-SHIP | SHIP if all above PASS | After Step 9 |

## 6. Load / performance / security checks

- **Load/performance:** N/A at the YAML artifact layer. Topic YAML changes do not change runtime hot paths or computation profile; only the action component reference. Performance impact is bounded by the new `PM0_PA_Card_*` flow runtime, which was activated and validated under AQ-07.
- **Security:** No credentials, secrets, connection strings, or PII appear in any of the 5 fixed YAML files. Substring scans confirm no leak of internal IDs beyond the documented minimal change.
- **Backward compatibility:** Per ADR `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md`, only the 5 in-scope topics are modified. The 7 legacy topics remain unchanged in scope, schema, and runtime path. Rollback path documented at `.planning/comms/rollback_evidence_pre_3_15_20260520/ROLLBACK_PROCEDURE.md`.
