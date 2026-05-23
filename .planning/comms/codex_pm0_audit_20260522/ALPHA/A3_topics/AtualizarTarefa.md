# A3 Topic Contract Audit - AtualizarTarefa

## Scope And Sources

- Topic source: `Local_Repo/Assistente PMO V2/topics/AtualizarTarefa.mcs.yml`
- Matching PM0 workflow trigger source: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarTarefa-7c6300c2-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Local workflow trigger evidence: the Skills request schema declares `action`, `spItemId`, `taskId`, `status`, `taskStatus`, and `comments`; only `action` is required at workflow lines 42-80.
- Local workflow body evidence: the body reads `spItemId` or `taskId` for SharePoint item lookup and update at workflow lines 174-192 and 115-144, and reads `status` or `taskStatus` at workflow lines 106-113 and 123-133.

## Pre-Call Topic And Global Variables

The PM0 `BeginDialog` call starts at topic line 208. These `Topic.*` and `Global.*` variables are set before that action call.

| Variable | Set before call | Evidence |
|---|---|---|
| `Topic.RawInput` | Captured from current activity text | topic lines 19-22 |
| `Topic.WorkingInput` | Seeded from raw input and later replaced with prompted payload | topic lines 24-27 and 48-51 |
| `Topic.TaskID` | Parsed from working input, parsed again after prompted payload, then asked if still blank | topic lines 29-32, 53-56, and 88-98 |
| `Topic.UpdatePayload` | Question answer when no task ID is initially parsed | topic lines 34-56 |
| `Topic.Status` | Parsed from working input, then asked if blank | topic lines 58-61 and 100-110 |
| `Topic.HorasRealizadas` | Parsed from working input, then asked if blank | topic lines 63-66 and 112-122 |
| `Topic.Responsavel` | Parsed from working input, then asked if blank | topic lines 68-71 and 124-134 |
| `Topic.DataFim` | Parsed from working input, then asked if blank | topic lines 73-76 and 136-146 |
| `Topic.Prioridade` | Parsed from working input, then asked if blank | topic lines 78-81 and 148-158 |
| `Topic.Confirmar` | Parsed from working input, then asked if blank | topic lines 83-86 and 160-170 |
| `Global.PMO_Atualizar_TaskID` | `=Topic.TaskID` | topic lines 178-181 |
| `Global.PMO_Atualizar_Status` | `=Topic.Status` | topic lines 183-186 |
| `Global.PMO_Atualizar_HorasRealizadas` | `=Topic.HorasRealizadas` | topic lines 188-191 |
| `Global.PMO_Atualizar_Responsavel` | `=Topic.Responsavel` | topic lines 193-196 |
| `Global.PMO_Atualizar_DataFim` | `=Topic.DataFim` | topic lines 198-201 |
| `Global.PMO_Atualizar_Prioridade` | `=Topic.Prioridade` | topic lines 203-206 |

`Topic.message` is bound as PM0 output at topic lines 212-214, so it is not a pre-call variable.

## Verbatim PM0 BeginDialog Block

Source: topic lines 208-214.

```yaml
            - kind: BeginDialog
              id: call_atualizar_tarefa
              input: {}
              dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa
              output:
                binding:
                  result: Topic.message
```

## Exact Current Input

The current PM0 call input is exactly:

```yaml
input: {}
```

Evidence: topic line 210.

## Workflow Trigger Contract And Mapping

The matching local workflow schema exposes these fields:

| Trigger field | JSON schema type | Required | Workflow evidence | Topic value available before call |
|---|---|---|---|---|
| `action` | `string` | Yes | workflow lines 50-53 and 75-77 | No direct variable; AQ-07 FI-05 action is `update` |
| `spItemId` | `string` | No | workflow lines 54-57 | `Topic.TaskID` and `Global.PMO_Atualizar_TaskID` |
| `taskId` | `string` | No | workflow lines 58-61 | `Topic.TaskID` and `Global.PMO_Atualizar_TaskID` |
| `status` | `string` | No | workflow lines 62-65 | `Topic.Status` and `Global.PMO_Atualizar_Status` |
| `taskStatus` | `string` | No | workflow lines 66-69 | `Topic.Status` and `Global.PMO_Atualizar_Status` |
| `comments` | `string` | No | workflow lines 70-73 | None |

The minimum Power Fx `BeginDialog` binding that satisfies the trigger requirement and supplies the values this workflow body actually reads is:

```yaml
input:
  binding:
    action: ="update"
    spItemId: =Text(Topic.TaskID)
    status: =Topic.Status
```

The trigger schema also exposes alias fields `taskId` and `taskStatus`; the workflow body uses `coalesce` with those aliases. Mapping `spItemId` and `status` is the canonical local choice above because those field names are present in the trigger schema and map directly to the topic's task ID and status.

## Finding

`AtualizarTarefa` has a PM0 topic-to-workflow contract break at the action call. Topic lines 178-206 preserve task ID and status in globals, then topic line 210 passes no inputs to a workflow trigger whose local schema requires `action` and whose body reads an item ID and status from trigger inputs.

## Microsoft Learn Citation

- Official page: Microsoft Learn, "Configure zero prompt experience for Copilot in Dynamics 365 Sales (preview)"
- URL: `https://learn.microsoft.com/en-us/dynamics365/sales/zero-prompt-experience`
- Accessed: `2026-05-22 15:23:02 -03:00`
- Citation use: the sample YAML at page lines 131-160 shows a `BeginDialog` action using `input:` with nested `binding:` entries before `dialog:` and `output:`. This supports the `BeginDialog input.binding` syntax only; PM0 field names and requirements above come from the local workflow JSON.
