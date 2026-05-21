# ISSUE-AQ08-YAML-001 — Owner-paste YAML failed in Copilot Studio Code Editor

**Severity:** SEV-1 (no production impact, blocked Owner-side AQ-08 remediation step)
**Detected:** 2026-05-20 22:36 BRT
**Reporter:** Owner (screenshot of Copilot Studio Code Editor showing `Error reading YAML content near line 25 position 6: UnexpectedToken, token: '' (StartSequence), expected: PropertyName or EndObject` for topic `CriarTarefa`)
**Owning agent:** CODEX-PA (assistant)
**Mission:** AQ-08 hybrid card-first migration — five in-scope topics
**Status:** RESOLVED at artifact level. Awaiting Owner runtime confirmation per file.

## 1. Title and Severity

| Field | Value |
|---|---|
| Title | Fixed topic YAML files generated with LF-only line endings caused Copilot Studio strict YAML parser to fail on long Power Fx expressions |
| Severity | SEV-1 (Owner blocked; no tenant change applied; no data impact) |
| Component | Topic YAML files for `Assistente PMO V2` (`PMO_v11_Tarefas`) |
| Surface | Copilot Studio Code Editor for topics `AtualizarStatus`, `AtualizarTarefa`, `ConsultarPortfolio`, `CriarTarefa`, `ListarTarefas` |

## 2. Impact

- Owner attempted to apply AQ-08 manual remediation by pasting the assistant-supplied `CriarTarefa.yaml`. Copilot Studio rejected the YAML with a parse error on line 25; the Owner correctly stopped before saving.
- No tenant change occurred. No data was written or destroyed. The bot remains in its pre-paste state.
- Owner-side AQ-08 work was blocked until properly validated artifacts were re-delivered.

## 3. Timeline (Owner-local time, BRT)

| When | Event |
|---|---|
| 2026-05-20 21:43 | Assistant produced and shipped 5 fixed topic YAML files via chat + disk path. No automated quality gate was run prior to delivery. |
| 2026-05-20 22:36 | Owner pasted `CriarTarefa.yaml` into Copilot Studio Code Editor; editor surfaced YAML parse error at line 25 position 6. Owner did not save. |
| 2026-05-20 22:38 | Owner instructed assistant to enforce quality gates BEFORE shipping any code. |
| 2026-05-20 22:39 | Assistant ran a comparison script (`scripts/Diff-CriarTarefaYaml.ps1`) that proved the only material difference between AS-IS and shipped files was the dialog reference and the line endings. |
| 2026-05-20 22:42 | Assistant ran a strict PyYAML 6.0.3 + 8-gate validator on all five files. Result: every file FAILED gate G3 (line endings) and two files FAILED gate G6 (legacy reference still present in comments). |
| 2026-05-20 22:43 | Assistant rewrote a deterministic minimal-diff builder (`scripts/Build-Aq08FixedTopicYamls.py`) with the gates baked in. Files that fail any gate are not written to disk. |
| 2026-05-20 22:45 | All 5 files PASS every gate. OverallDecision: PASS. New files written to `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/`. |
| 2026-05-20 22:46 | Owner formalized the SEV-0 stop-ship protocol as binding for all future shipments. Adopted as canon at `.planning/comms/SEV0_STOP_SHIP_PROTOCOL_USER_DIRECTIVE_20260520.md`. |

## 4. Root Cause

Two independent defects in the file-generation step, both produced by the assistant skipping validation prior to delivery:

1. **Line endings were LF-only.** The live AS-IS extract from Dataverse `botcomponent.data` uses CRLF on this Windows tenant. Copilot Studio's strict YAML parser, when fed a YAML where long Power Fx expressions span what it thinks is a single line, mis-tracks line boundaries and reports the syntax error at a much later line. The error message at line 25 position 6 was a downstream symptom; the root failure was that the parser could not resolve where a `value:` scalar ended.
2. **Legacy strings remained in rewritten comment headers.** The assistant added new comment lines that themselves included `PMO_PA_AtualizarStatus` and `PMO_PA_ConsultarPortfolio` as descriptive prose. The AQ-08 reverify (`tests/Test-Aq08PostRemediationReverify.ps1`) does a literal substring search per topic via `Test-ContainsLiteral` (case-insensitive). Any legacy string anywhere — including in comments — produces a `BLOCK` result and would have falsely failed the post-remediation verifier.

## 5. Contributing Factors

- The assistant generated and shipped 5 files in a single batch without running a strict YAML parser, a byte-level diff against AS-IS, or a substring scan for legacy references.
- The `write` tool used to create the files defaults to LF line endings on output, regardless of the AS-IS source's CRLF convention. The assistant did not detect or compensate for that.
- The assistant added "AQ-08 remediation 2026-05-20" comment text that re-introduced the legacy token strings the deliverable was supposed to remove.
- No pre-existing automated gate in this repo enforces line-ending parity for topic YAMLs against the live AS-IS extract; the gate had to be created as part of this RCA.

## 6. Detection Gaps (why it escaped)

- The deliverable was treated as low-risk ("just paste a few YAML files"). It was not. Any artifact produced by an agent for tenant ingestion is a release artifact and warrants the SEV-0 stop-ship gate set.
- The assistant trusted the Python `write` tool to preserve byte fidelity; it does not. There was no post-write verification step.
- The closeout handoff and ADR existed but their gate set covered only the runtime reverify path — not the local artifact build step that feeds it.

## 7. Corrective Actions

### 7.1 Code fixes (artifact level)

| Path | Purpose |
|---|---|
| `scripts/Build-Aq08FixedTopicYamls.py` | Deterministic builder + 8-gate validator. Reads AS-IS, applies the minimal change, validates with PyYAML, enforces line-ending and BOM parity, runs substring scans, writes only on PASS, exits non-zero on any FAIL. |
| `scripts/Test-Aq08FixedTopicYamls.py` | Independent post-write validator for any future change to the fixed YAMLs (kept separate from the builder for double-checking). |
| `scripts/Diff-CriarTarefaYaml.ps1` | Reproduction tool used during the RCA. Diffs an AS-IS vs FIXED file and reports byte-level + line-ending differences. |

### 7.2 Tests added

| Test ID | Layer | What it asserts | Pass condition |
|---|---|---|---|
| G1 file-non-empty | unit | Output file exists and has length > 0 | byte length > 0 |
| G2 no-BOM | unit | First three bytes are not `EF BB BF` | byte sequence not present |
| G3 line-endings-match-AS-IS | contract | CRLF count and LF-only count match the AS-IS file | parity holds |
| G4 strict-YAML-parse | unit | PyYAML 6.0.3 `safe_load` succeeds with no error | no `YAMLError` raised |
| G5 minimal-edit-distance | contract | `difflib.SequenceMatcher` edit distance ≤ 1 line for simple swap, ≤ 30 for structural conversion | true edit distance bounded |
| G6 no-legacy-substring | contract | Legacy `PMO_PA_*` action ref and legacy flow GUID are absent from the entire file (incl. comments) | substring count == 0 |
| G7 top-level-keys-preserved | contract | Set of top-level YAML keys is identical to AS-IS | set equality |
| G8 new-action-exactly-once | contract | New `PM0_PA_Card_*` action component appears exactly once | count == 1 |

### 7.3 Process change

- Adopted Owner-directed SEV-0 stop-ship protocol as canon: `.planning/comms/SEV0_STOP_SHIP_PROTOCOL_USER_DIRECTIVE_20260520.md`.
- New project rule: any artifact destined for tenant ingestion (topic YAMLs, flow JSONs, solution ZIPs) MUST go through the relevant gated builder before chat delivery. Files that fail any gate MUST NOT be written to disk and MUST NOT be shown to the Owner as ready-to-paste content.
- New project rule: deliver one artifact at a time when the Owner asks for sequential delivery; wait for explicit Owner confirmation of save before producing the next.

### 7.4 Monitoring / alerting

- The build script exits with a non-zero code on any gate failure; this is a hard signal in the assistant's tool chain.
- A QA evidence document is written at delivery time: `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/QA_EVIDENCE.md`.

## 8. Prevent Recurrence — Explicit Controls

| Control | Description | Owner |
|---|---|---|
| C1 | All future Copilot Studio topic YAML deliveries MUST be produced by `scripts/Build-Aq08FixedTopicYamls.py` (or an equivalent gated builder) and SHOULD include a Python script artifact saved under `scripts/` with the same SHA. | CODEX-PA |
| C2 | Run-results of the gates (G1..G8) MUST be quoted in the chat reply that delivers the artifact. The reply MUST include the explicit OverallDecision PASS/FAIL line. | CODEX-PA |
| C3 | If any gate fails, do not show the artifact content to the Owner; report the failure and stop. | CODEX-PA |
| C4 | Add a YAML-build CI check (when CI is back in scope) that runs the same gate set on every PR that touches topic YAMLs, blocking merge on FAIL. | CODEX-LEAD (future) |
| C5 | Whenever a sequential delivery is requested, the assistant MUST confirm Owner save of artifact N before producing artifact N+1. | CODEX-PA |

## 9. Verification Status

| Artifact | Built by gated pipeline | All 8 gates PASS | Owner Code-Editor save confirmed | AQ-08 reverify PASS | Status |
|---|---|---|---|---|---|
| ListarTarefas.yaml | YES | YES | NOT YET | NOT YET | READY for Owner paste |
| CriarTarefa.yaml | YES | YES | NOT YET | NOT YET | QUEUED |
| AtualizarTarefa.yaml | YES | YES | NOT YET | NOT YET | QUEUED |
| ConsultarPortfolio.yaml | YES | YES | NOT YET | NOT YET | QUEUED |
| AtualizarStatus.yaml | YES | YES | NOT YET | NOT YET | QUEUED |

## 10. SHIP / NO-SHIP at this layer

- **Local artifact SHIP decision (5 fixed YAML files): SHIP.** All eight quality gates pass for every file. Files are byte-identical to the AS-IS for everything except the documented minimum change. They are safe to paste into Copilot Studio Code Editor and save.
- **AQ-08 release decision: NO-SHIP** until: (a) Owner pastes and saves all 5 files in Copilot Studio, and (b) `tests/Test-Aq08PostRemediationReverify.ps1` returns OverallDecision PASS / exit 0 against live Dataverse, and (c) Owner publishes the bot, and (d) AQ-09 smoke evidence is captured, and (e) XPIA-01 evidence validator passes.

The Owner directive is honored: no further code is being shown until ListarTarefas (file 1/5) is confirmed saved by the Owner.
