# Evidence Log — ISSUE-AQ08-YAML-001 (Fixed topic YAML quality gates)

Status: All gates PASS for the 5 fixed topic YAML files as of 2026-05-20 22:45 BRT.
Source RCA: `.planning/stop_ship/ISSUE_RCA_AQ08_YAML_001_20260520.md`

## Reproduction (the failure mode I caused)

| Item | Evidence Type | Link / Path | Command | Output Snippet | Notes |
|------|---------------|-------------|---------|----------------|-------|
| Owner Copilot Studio screenshot | Image | Owner-attached in chat 2026-05-20 22:36 BRT | (UI) | `Error reading YAML content near line 25 position 6: UnexpectedToken, token: '' (StartSequence), expected: PropertyName or EndObject` | Owner did not save; tenant unchanged. |
| First-pass diff | Script | `scripts/Diff-CriarTarefaYaml.ps1` | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\Diff-CriarTarefaYaml.ps1` | `AS-IS:  CRLF=9 LF-only=0` / `FIXED:  CRLF=0 LF-only=9` | Identified line-ending mismatch as the root cause of the parser failure. |
| First-pass strict gates | Python script | `scripts/Test-Aq08FixedTopicYamls.py` | `python scripts\Test-Aq08FixedTopicYamls.py` | `[FAIL] G3 line endings match: AS-IS CRLF=160 LF=0 \| FIXED CRLF=0 LF=161` | All 5 files failed G3; AtualizarStatus and ConsultarPortfolio also failed G6 due to legacy strings in comments. |

## Resolution (rebuild via gated pipeline)

| Item | Evidence Type | Link / Path | Command | Output Snippet | Notes |
|------|---------------|-------------|---------|----------------|-------|
| Gated builder | Python script | `scripts/Build-Aq08FixedTopicYamls.py` | `python scripts\Build-Aq08FixedTopicYamls.py` | `OverallDecision: PASS` (exit 0) | Builds 5 files from AS-IS with the minimum change required. |
| QA evidence | Markdown | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/QA_EVIDENCE.md` | (read) | Per-file change table, byte sizes, gate results | Owner-readable summary of what each file changes. |
| ListarTarefas.yaml | Bytes | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/ListarTarefas.yaml` | `Get-Item ListarTarefas.yaml` | `Length: 2100` | 1 edit vs AS-IS (line 41 dialog reference). CRLF. |
| CriarTarefa.yaml | Bytes | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/CriarTarefa.yaml` | `Get-Item CriarTarefa.yaml` | `Length: 6894` | 1 edit vs AS-IS (line 149 dialog reference). CRLF. |
| AtualizarTarefa.yaml | Bytes | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/AtualizarTarefa.yaml` | `Get-Item AtualizarTarefa.yaml` | `Length: 15260` | 1 edit vs AS-IS (line 182 dialog reference). CRLF. |
| ConsultarPortfolio.yaml | Bytes | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/ConsultarPortfolio.yaml` | `Get-Item ConsultarPortfolio.yaml` | `Length: 1219` | 5 edits vs AS-IS (1 comment delete, 1 kind replace, 2 inserts, 1 flowId delete). CRLF. |
| AtualizarStatus.yaml | Bytes | `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/AtualizarStatus.yaml` | `Get-Item AtualizarStatus.yaml` | `Length: 8606` | 12 edits vs AS-IS (1 comment delete, 1 kind replace, 9-line input.binding block replaced with 2 lines, 1 flowId delete). CRLF. |
| Strict gate run output | Text | `D:\VMs\Projetos\STT_Project_Management\scripts\Build-Aq08FixedTopicYamls.py` (stdout shown in chat) | `python scripts\Build-Aq08FixedTopicYamls.py` | All G1..G8 PASS for all 5 files; OverallDecision: PASS | Reproducible. |

## Owner-side runtime evidence (NOT YET; pending)

| Item | Evidence Type | Link / Path | Command | Output Snippet | Notes |
|------|---------------|-------------|---------|----------------|-------|
| ListarTarefas Code-Editor save | Owner action | (Copilot Studio UI) | (UI Save) | TBD | Required before file 2/5 is delivered. |
| CriarTarefa Code-Editor save | Owner action | (Copilot Studio UI) | (UI Save) | TBD | Sequential. |
| AtualizarTarefa Code-Editor save | Owner action | (Copilot Studio UI) | (UI Save) | TBD | Sequential. |
| ConsultarPortfolio Code-Editor save | Owner action | (Copilot Studio UI) | (UI Save) | TBD | Sequential. |
| AtualizarStatus Code-Editor save | Owner action | (Copilot Studio UI) | (UI Save) | TBD | Sequential. |
| AQ-08 post-remediation reverify | PowerShell test | `tests/Test-Aq08PostRemediationReverify.ps1` | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Aq08PostRemediationReverify.ps1` | TBD (must return `OverallDecision: PASS` / exit 0) | Triggered by CODEX-PA after all 5 saves confirmed. |
