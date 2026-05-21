# BLK-AT-001-DISPLAY Patch Spec

Date: 2026-05-20  
Executor: CODEX-PA  
Mode: Spec only. No topic/flow patch applied.  
Target: `AtualizarTarefa` user-visible display after update

## Source Inspected

Current 3.15 source inspected:

```text
.planning/comms/solution_3_15_list_static_runtime_bypass_20260514/unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data
```

Active package:

```text
Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip
SHA256 0A68BB03F9C79440EA9AA09F7E5EE067681FCBDE0241F51F4C27BEB8EA61A9A6
```

## Important Finding

The current 3.15 topic no longer echoes raw optional values in the final response. It sends a static success sentence. The historical defect remains relevant if Owner restores field-level confirmation/display: raw skip tokens such as `nao` must not be displayed to the user as field values.

This spec therefore replaces the current static `atualizar_done` response with a field-level display response that renders skip tokens as `(mantido)`.

## File Path And Line Range

File:

```text
.planning/comms/solution_3_15_list_static_runtime_bypass_20260514/unpacked/botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data
```

Line range in current 3.15 unpacked source:

```text
213-215
```

## Exact OLD Block

```yaml
            - kind: SendActivity
              id: atualizar_done
              activity: Tarefa atualizada com sucesso. Dados gravados no SharePoint. Use listar tarefas para conferir os IDs ativos.
```

## Exact NEW Block

Owner should replace only the `atualizar_done` `SendActivity` block with:

```yaml
            - kind: SendActivity
              id: atualizar_done
              activity: |-
                Tarefa atualizada com sucesso.
                Responsavel: {If(IsBlank(Topic.Responsavel) || Lower(Trim(Topic.Responsavel)) in ["n","no","nao","não"], "(mantido)", Topic.Responsavel)}
                Prazo: {If(IsBlank(Topic.DataFim) || Lower(Trim(Topic.DataFim)) in ["n","no","nao","não"], "(mantido)", Topic.DataFim)}
                Prioridade: {If(IsBlank(Topic.Prioridade) || Lower(Trim(Topic.Prioridade)) in ["n","no","nao","não"], "(mantido)", Topic.Prioridade)}
                Horas realizadas: {If(IsBlank(Text(Topic.HorasRealizadas)) || Text(Topic.HorasRealizadas) = "0" || Lower(Trim(Text(Topic.HorasRealizadas))) in ["n","no","nao","não"], "(mantido)", Text(Topic.HorasRealizadas))}
```

## Power Fx Expression Pattern

Use this expression pattern for text optional fields:

```powerfx
If(IsBlank(<value>) || Lower(Trim(<value>)) in ["n","no","nao","não"], "(mantido)", <value>)
```

Use this expression pattern for `Topic.HorasRealizadas`, because current skip semantics preserve existing hours when the input is `0`:

```powerfx
If(IsBlank(Text(Topic.HorasRealizadas)) || Text(Topic.HorasRealizadas) = "0" || Lower(Trim(Text(Topic.HorasRealizadas))) in ["n","no","nao","não"], "(mantido)", Text(Topic.HorasRealizadas))
```

## Manual UI Steps

1. Open Copilot Studio for `Assistente PMO V2`.
2. Open topic `AtualizarTarefa`.
3. Open code editor.
4. Find `id: atualizar_done`.
5. Replace the exact OLD block above with the exact NEW block.
6. Do not change flow logic in this patch.
7. Save the topic.
8. Export the solution after Owner completes all manual AQ-08 remediations.
9. Run `tests/Test-AtualizarTarefaResponseDisplay.ps1` against the exported package.

## Regression Criteria

PASS requires:

| Criterion | Expected |
|---|---|
| `atualizar_done` exists | Yes |
| Response is field-level display | Includes `Responsavel`, `Prazo`, `Prioridade`, and `Horas realizadas` |
| Raw direct echo removed | No line like `Responsavel: {Topic.Responsavel}` |
| Skip tokens display safely | `n`, `no`, `nao`, and `não` display as `(mantido)` |
| Hours skip display safely | `0` displays as `(mantido)` |
| Data write semantics unchanged | Flow still preserves existing SharePoint values for skip inputs |

## Regression Test

Test created:

```text
tests/Test-AtualizarTarefaResponseDisplay.ps1
```

Current 3.15 result:

```text
EXPECTED FAILURE
Evidence: .planning/comms/blk_at_001_display_patch_20260520/Test-AtualizarTarefaResponseDisplay_current_3_15_FAIL_expected.txt
Exit marker: .planning/comms/blk_at_001_display_patch_20260520/Test-AtualizarTarefaResponseDisplay_current_3_15_exit.txt
```

Reason for expected failure: current 3.15 has a static response and does not contain the field-level `(mantido)` display contract.

## Scope Boundary

This is a display-only topic patch spec. CODEX-PA did not apply it to source, did not save a Copilot topic, did not import a solution, did not publish the bot, and did not run any chat test.
