# LOCAL GATES - SOLUTION 3.13

Agent: Codex
Timestamp BRT: 2026-05-14 10:40
Package: `Solution/PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip`
SHA256: `B427F3CF64E7471F1C8BD29593888DC1A27F06389EF1FD614FE92684D94FF21E`

## Result

Local gates: PASS
Release decision: NO-SHIP until import, Copilot publish, and fresh runtime evidence pass
CI gate: EXCLUDED by owner instruction for this mission only

## Scope

3.13 fixes the runtime `ContentFiltered` / `openAIIndirectAttack` failure seen after `ListarTarefas` and `AtualizarTarefa` by making bot-visible outputs deterministic, plain text, and safe for Copilot Studio post-processing.

This does not disable Responsible AI controls. It removes the trigger pattern by avoiding free-text SharePoint fields, markdown, pipe-heavy rows, and literal escaped line breaks in the bot response.

## Changes

- `ListarTarefas` now returns a deterministic ProjectID summary plus operational task rows only.
- `ListarTarefas` bot output suppresses SharePoint task `Title` and `Responsavel` email values.
- `ListarTarefas` uses real line breaks through `decodeUriComponent('%0A')`, not literal `\n`.
- `ListarTarefas` removes pipe separators from bot-visible output.
- `AtualizarTarefa` success response suppresses task `Title` and `Responsavel` email values.
- `AtualizarTarefa` success response removes markdown markers and pipe separators.
- Existing flow/action IDs are retained:
  - `PMO_PA_ListarTarefas`: `9544f14b-3748-f111-bec7-6045bdf42cae`
  - `PMO_PA_AtualizarTarefa`: `98408d55-3748-f111-bec7-000d3abc5cc6`
  - Topic action binding: `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa`

## Commands Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-ListarTarefasContentSafeContract.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-AtualizarTarefaSkipSemantics.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-AtualizarTarefaBlockParser.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotPowerFxRegexSafety.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-SolutionZipP0Contracts.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-SolutionZipP24Contracts.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip" -ExpectedVersion "3.13"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath ".planning\comms\solution_3_13_contentfilter_deterministic_output_20260514\unpacked"
Get-FileHash -Algorithm SHA256 "Solution\PMO_v11_Tarefas_3_13_CONTENTFILTER_DETERMINISTIC_OUTPUT_FIX.zip"
```

## Gate Results

| Gate | Result | Evidence |
|---|---|---|
| ListarTarefas content-safe contract | PASS | Deterministic ProjectID output, real line breaks, no title/email, no pipes |
| AtualizarTarefa skip semantics | PASS | `0` and `nao` preserve existing optional values; success response is content-safe |
| AtualizarTarefa block parser | PASS | Multiline block, comma block, and omitted-date block tested |
| Power Fx regex safety | PASS | No invalid regex character classes |
| P0 ZIP contracts | PASS | Core package contracts intact |
| P24 ZIP contracts | PASS | Version `3.13`, dependencies clean |
| Stop-ship source audit | PASS | Workflows parse, ASCII-only, no stale dependencies, output safety checks pass |
| Package hash | PASS | `B427F3CF64E7471F1C8BD29593888DC1A27F06389EF1FD614FE92684D94FF21E` |

## Remaining Release Blockers

| Blocker | Status | Owner |
|---|---|---|
| Import 3.13 package | PENDING | Owner |
| Publish `Assistente PMO V2` after import | PENDING | Owner |
| Runtime test `ListarTarefas` returns no literal `\n` and no `ContentFiltered` | PENDING | Owner + Codex review |
| Runtime test `AtualizarTarefa` multiline block returns no `ContentFiltered` | PENDING | Owner + Codex review |
| Runtime test `AtualizarTarefa` comma block returns no `ContentFiltered` | PENDING | Owner + Codex review |
| Runtime test omitted-date parser does not shift `media` into due date | PENDING | Owner + Codex review |

