# Agent 1 Static Audit Findings - 2026-05-11

Scope:
- Command: `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .planning\comms\solution_1_10_project_lookup_normalize_20260511\unpacked`
- Result: failed 3 checks.

## Failed Checks

1. `Solution text is ASCII-only`
2. `Solution text has no mojibake`
3. `Bot workflow bindings use only Clean action components`

All workflow JSON parse, workflow ASCII, and workflow mojibake checks passed.

## Root Cause

The v1.10 unpacked solution still contains non-ASCII bot authoring text in two bot component `data` files. Under Windows PowerShell 5.1, the UTF-8/no-BOM export is read as ANSI, so those UTF-8 bytes render as mojibake and match the audit's `0x00F0|0x00C3|0x00E2|0x00C2|0xFFFD` pattern.

The workflow binding warning is separate: `Assets\botcomponent_workflowset.xml` contains direct workflow bindings for `pmo_AssistentePMO_V2.topic.*`, including `topic.CriarTarefa`. The audit explicitly requires only `pmo_AssistentePMO_Clean.*` action component bindings and rejects any direct `topic.CriarTarefa` binding.

## Exact Files / Lines / Patterns

### ASCII / Mojibake

File: `.planning\comms\solution_1_10_project_lookup_normalize_20260511\unpacked\botcomponents\pmo_AssistentePMO_V2.gpt.default\data`

- Line 11:
  - UTF-8 text: `6. Formate respostas com emojis para status: 🟢 Verde, 🟡 Amarelo, 🔴 Vermelho.`
  - Windows PowerShell 5.1 view: `6. Formate respostas com emojis para status: ðŸŸ¢ Verde, ðŸŸ¡ Amarelo, ðŸ”´ Vermelho.`
  - Triggered patterns: non-ASCII emoji bytes; mojibake pattern via `0x00F0`.

File: `.planning\comms\solution_1_10_project_lookup_normalize_20260511\unpacked\botcomponents\pmo_AssistentePMO_V2.topic.CriarTarefa\data`

- Line 26:
  - UTF-8 text: `- criar tarefa título`
  - Windows PowerShell 5.1 view: `- criar tarefa tÃ­tulo`
  - Triggered patterns: non-ASCII `í`; mojibake pattern via `0x00C3`.
- Line 28:
  - UTF-8 text: `- criar tarefa responsável`
  - Windows PowerShell 5.1 view: `- criar tarefa responsÃ¡vel`
  - Triggered patterns: non-ASCII `á`; mojibake pattern via `0x00C3`.

### Bot Workflow Binding

File: `.planning\comms\solution_1_10_project_lookup_normalize_20260511\unpacked\Assets\botcomponent_workflowset.xml`

- Line 26:
  - `<botcomponent_workflow botcomponentid.schemaname="pmo_AssistentePMO_V2.topic.CriarTarefa" workflowid.workflowid="3104124d-364a-f111-bec7-7ced8d955c6c">`
  - Triggered patterns: `pmo_AssistentePMO(?!_Clean)\.` and `\.topic\.CriarTarefa`.

Related direct topic bindings in the same file:
- Line 17: `pmo_AssistentePMO_V2.topic.AtualizarStatus`
- Line 20: `pmo_AssistentePMO_V2.topic.ConsultarPortfolio`
- Line 23: `pmo_AssistentePMO_V2.topic.ConsultarProjeto`
- Line 29: `pmo_AssistentePMO_V2.topic.PedirDecisao`
- Line 32: `pmo_AssistentePMO_V2.topic.RegistrarBloqueio`
- Line 35: `pmo_AssistentePMO_V2.topic.RegistrarRisco`

## Safety Assessment

ASCII text fix: safe and isolated if performed in the bot source/template or Copilot Studio content, then re-exported. Replace line 11 emoji instruction with ASCII status words only, and remove accented trigger variants from CriarTarefa or replace them with ASCII equivalents. Estimated fix time: 10-20 minutes plus re-export/audit.

Workflow binding fix: not safe to patch blindly in the unpacked export without confirming the intended runtime binding model. The current topic calls V3 directly in `.topic.CriarTarefa\data` lines 180-195, and `botcomponent_workflowset.xml` binds that topic to workflow `3104124d-364a-f111-bec7-7ced8d955c6c`. The audit expects a Clean action indirection model instead. Estimated fix time: 30-60 minutes if the intended model is already known; 1-2 hours if it requires Copilot Studio UI rebinding and publish validation.

## Recommended Action

1. Fix ASCII at source and re-export:
   - `gpt.default\data` line 11: replace emoji instruction with ASCII-only wording.
   - `topic.CriarTarefa\data` lines 26 and 28: remove or ASCII-normalize accented trigger queries.
2. Resolve the binding policy decision before editing export XML:
   - If Clean action indirection remains the required stop-ship model, rebind `CriarTarefa` through a Clean action component and regenerate `botcomponent_workflowset.xml`.
   - If direct V2 topic-to-flow binding is now intentional for v1.10, update `tests\Test-PMOFlowStopShipAudit.ps1` because the current assertion is stale and will keep failing valid exports.
3. Re-run the exact audit command above after re-export.
