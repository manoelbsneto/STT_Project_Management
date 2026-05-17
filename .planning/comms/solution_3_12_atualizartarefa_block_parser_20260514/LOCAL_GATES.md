# LOCAL GATES - SOLUTION 3.12

Agent: Codex
Timestamp BRT: 2026-05-14 09:53
Package: `Solution/PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip`
SHA256: `E2EA3C8D009C177230DF0E4BC9890E2CB5506CB9462E39C4B1A9BACC890C5DB3`

## Result

Local gates: PASS
Release decision: NO-SHIP until import, Copilot publish, and fresh runtime evidence pass
CI gate: EXCLUDED by owner instruction for this mission only

## Scope

3.12 fixes `AtualizarTarefa` so the topic accepts one pasted block in a single message, either multiline or comma separated.

Supported ordered payload:

```text
tarefa, status, horas, responsavel, prazo, prioridade, confirmar
```

Example:

```text
15
em andamento
2
mbenicios@minsait.com
21/05/2026
media
sim
```

## Changes

- `AtualizarTarefa` now captures `System.Activity.Text` and parses a single text block before falling back to individual prompts.
- `ask_update_payload` uses `StringPrebuiltEntity`, not `NumberPrebuiltEntity`, so pasted multiline blocks are accepted.
- Parser supports comma, semicolon, and newline separators.
- Parser validates date and priority token shapes to avoid shifting `media` into `DataFim` when the date is omitted.
- Missing fields still fall back to prompts.
- Existing flow/action IDs are retained:
  - `PMO_PA_AtualizarTarefa`: `98408d55-3748-f111-bec7-000d3abc5cc6`
  - Topic action binding: `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa`

## Commands Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-AtualizarTarefaBlockParser.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-AtualizarTarefaSkipSemantics.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotPowerFxRegexSafety.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-SolutionZipP0Contracts.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-SolutionZipP24Contracts.ps1 -PackagePath "Solution\PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip" -ExpectedVersion "3.12"
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath ".planning\comms\solution_3_12_atualizartarefa_block_parser_20260514\unpacked"
Get-FileHash -Algorithm SHA256 "Solution\PMO_v11_Tarefas_3_12_ATUALIZARTAREFA_BLOCK_PARSER_FIX.zip"
```

## Gate Results

| Gate | Result | Evidence |
|---|---|---|
| AtualizarTarefa block parser | PASS | Full multiline, full comma, and omitted-date block tested |
| AtualizarTarefa skip semantics | PASS | `0` and `nao` preserve existing optional values |
| Power Fx regex safety | PASS | No invalid regex character classes |
| P0 ZIP contracts | PASS | Core package contracts intact |
| P24 ZIP contracts | PASS | Version `3.12`, dependencies clean |
| Stop-ship source audit | PASS | Workflows parse, no unsupported connectors, no stale dependencies |
| Package hash | PASS | `E2EA3C8D009C177230DF0E4BC9890E2CB5506CB9462E39C4B1A9BACC890C5DB3` |

## Independent QA Review

Agent: Dewey
Timestamp BRT: 2026-05-14 09:50

Finding: A shortened block without due date could shift `media` into `DataFim`.

Status: FIXED before release package handoff.

Regression added:

```text
15, em andamento, 2, mbenicios@minsait.com, media, sim
```

Expected and now verified locally:

```text
DataFim: blank, so Copilot asks the due-date prompt
Prioridade: media
Confirmar: sim
```

## Remaining Release Blockers

| Blocker | Status | Owner |
|---|---|---|
| Import 3.12 package | PENDING | Owner |
| Publish `Assistente PMO V2` after import | PENDING | Owner |
| Runtime test multiline block in Copilot Studio | PENDING | Owner + Codex review |
| Runtime test comma block in Copilot Studio | PENDING | Owner + Codex review |
| Runtime confirm no `ContentFiltered` on `ListarTarefas` | PENDING | Owner + Codex review |

