# AQ-08 Fixed Topic YAMLs — QA Evidence

**Date:** 2026-05-20
**Author:** CODEX-PA (assistant)
**Build script:** `scripts/Build-Aq08FixedTopicYamls.py`
**Output folder:** `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/`

## Why this exists

The first delivery of fixed YAML files (chat-paste flow) failed in Copilot Studio with `Error reading YAML content near line 25 position 6: UnexpectedToken, token: '' (StartSequence), expected: PropertyName or EndObject` because the files were written with LF-only line endings while the live tenant uses CRLF, and Copilot Studio's strict YAML parser is sensitive to that on long Power Fx expressions.

This rebuild pipelines every file through 8 quality gates **before** writing the final artifact. Files that fail any gate are not written.

## Quality gates

| Gate | Description |
|---|---|
| G1 | File is non-empty. |
| G2 | UTF-8 without BOM (matches the tenant baseline). |
| G3 | Line endings match the AS-IS file (CRLF on Windows tenants). |
| G4 | YAML parses with strict PyYAML 6.0.3 — no syntax errors. |
| G5 | Edit distance vs AS-IS is bounded (1 line for simple swaps, ≤30 for structural conversions), measured by `difflib.SequenceMatcher` (true edit distance, not line-index drift). |
| G6 | Fixed file contains the new `PM0_PA_Card_*` action component **and no legacy** `PMO_PA_*` action component or legacy flow GUID anywhere — including comments. |
| G7 | Top-level YAML keys preserved (e.g. `kind`, `beginDialog`, `inputType`, `outputType`). |
| G8 | New action component reference appears exactly once. |

## Results

| Topic | Build mode | Edits vs AS-IS | All gates |
|---|---|---:|---|
| AtualizarStatus | InvokeFlowAction → BeginDialog | 12 | PASS |
| AtualizarTarefa | BeginDialog dialog swap | 1 | PASS |
| ConsultarPortfolio | InvokeFlowAction → BeginDialog | 5 | PASS |
| CriarTarefa | BeginDialog dialog swap | 1 | PASS |
| ListarTarefas | BeginDialog dialog swap | 1 | PASS |

## Per-file change description

### AtualizarStatus.yaml (12 edits across 4 ops)
- delete line 2 (legacy comment)
- replace line 139 (`kind: InvokeFlowAction` → `kind: BeginDialog`)
- replace lines 141..149 (legacy `input.binding{...}` block → `input: {}` + `dialog:` reference)
- delete line 153 (legacy `flowId: c11a165b-c64c-f111-bec7-7ced8d9559c1`)
- net byte size: 8606 (was 8874)

### AtualizarTarefa.yaml (1 edit)
- line 182: `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa`
- net byte size: 15260 (was 15255)

### ConsultarPortfolio.yaml (5 edits across 4 ops)
- delete line 2 (legacy comment)
- replace line 27 (`kind: InvokeFlowAction` → `kind: BeginDialog`)
- insert lines 28..29 (`input: {}` + `dialog:` reference)
- delete line 32 (legacy `flowId: 39cf292d-c64c-f111-bec7-7ced8d955c6c`)
- net byte size: 1219 (was 1295)

### CriarTarefa.yaml (1 edit)
- line 149: `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa`
- net byte size: 6894 (was 6889)

### ListarTarefas.yaml (1 edit)
- line 41: `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` → `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas`
- net byte size: 2100 (was 2095)

## Reproduce / re-run

```powershell
cd D:\VMs\Projetos\STT_Project_Management
python scripts\Build-Aq08FixedTopicYamls.py
```

Exit code 0 = OverallDecision PASS. Exit code 1 = at least one file failed a gate (do not deliver).

## What this evidence is for

The Owner can refer to this document and the build log to confirm that:
1. The exact change applied to each topic is documented.
2. Each file passed YAML parsing with a real parser before delivery.
3. No legacy `PMO_PA_*` references survive anywhere in the file (the AQ-08 reverify substring check will return zero hits).
4. The changes are the **minimum** required to switch routing from `PMO_PA_*` to `PM0_PA_Card_*`.

After Owner pastes each file into Copilot Studio and saves, CODEX-PA runs `tests/Test-Aq08PostRemediationReverify.ps1` against live Dataverse to confirm the same routing change is reflected in `botcomponent.data` for the topic.
