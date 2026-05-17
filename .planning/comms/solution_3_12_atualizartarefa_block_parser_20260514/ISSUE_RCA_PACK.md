# ISSUE RCA PACK - 2026-05-14

Agent: Codex
Decision: NO-SHIP until runtime proof passes after import/publish

## ISSUE-001 - AtualizarTarefa displays raw skip values

Severity: Critical

Impact: Copilot showed `Responsavel: nao Prazo: nao Prioridade: nao` even though SharePoint preserved the correct persisted values. This creates false evidence and can mislead PMO operators.

Timeline:

| Time | Event |
|---|---|
| 2026-05-13 | Owner runtime test created task ID 15 in project `PRJ-274E5ACC` |
| 2026-05-13 | Skip update run `08584228880469441067904651966CU12` succeeded |
| 2026-05-13 | Runtime evidence showed SharePoint values preserved, but chat display showed raw `nao` |
| 2026-05-14 | Local package 3.11 patched and static tests passed |

Root cause:

- Topic `pmo_AssistentePMO_V2.topic.AtualizarTarefa` final message echoed `Topic.Responsavel`, `Topic.DataFim`, and `Topic.Prioridade`.
- Flow `Respond_Success` also used user inputs instead of the persisted `Update_Tarefa` output for some display fields.

Corrective actions:

| Action | Evidence |
|---|---|
| Topic final message changed to only `{Topic.message}` | `.planning/comms/solution_3_11_atualizartarefa_response_date_fix_20260514/unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data:112` |
| Flow response uses `body('Update_Tarefa')` for persisted display values | `.planning/comms/solution_3_11_atualizartarefa_response_date_fix_20260514/unpacked/Workflows/PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json:341` |
| Regression test added | `tests/Test-AtualizarTarefaSkipSemantics.ps1` |

Prevent recurrence:

- Static gate now fails if final topic message reintroduces raw skip-field echo.
- Static gate now fails if response does not use persisted `Update_Tarefa` output for responsavel, prazo, and prioridade.

Runtime proof still required:

- After import/publish, update task 15 using skip values and verify bot displays `mbenicios@minsait.com`, `2026-05-21`, and `Media`, not `nao`.

## ISSUE-002 - AtualizarTarefa rejects Brazilian date input

Severity: Critical

Impact: User entered `21/05/2026`; flow failed before completing update because SharePoint `DataFim` expected a date-compatible string.

Timeline:

| Time | Event |
|---|---|
| 2026-05-13 | Runtime run `08584228891053733219995694617CU20` failed |
| 2026-05-13 | Error showed `item/DataFim` received `"21/05/2026\n"` |
| 2026-05-14 | Local package 3.11 patched and static tests passed |

Root cause:

- `Update_Tarefa` passed non-skip `triggerBody()?['text_2']` directly to `item/DataFim`.
- The expression did not trim trailing newline and did not convert `dd/MM/yyyy` to `yyyy-MM-dd`.

Corrective actions:

| Action | Evidence |
|---|---|
| `item/DataFim` now trims input and converts `dd/MM/yyyy` to ISO `yyyy-MM-dd` | `.planning/comms/solution_3_11_atualizartarefa_response_date_fix_20260514/unpacked/Workflows/PMO_PA_AtualizarTarefa-98408D55-3748-F111-BEC7-000D3ABC5CC6.json:127` |
| Regression test added | `tests/Test-AtualizarTarefaSkipSemantics.ps1` |

Prevent recurrence:

- Static gate now checks for trim plus substring/concat normalization logic on `DataFim`.

Runtime proof still required:

- After import/publish, update task 15 with prazo `21/05/2026` and verify the flow succeeds and output shows `Prazo: 2026-05-21`.

