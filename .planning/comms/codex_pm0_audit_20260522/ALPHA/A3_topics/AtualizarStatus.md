# A3 Topic Contract Audit - AtualizarStatus

## Scope And Sources

- Topic source: `Local_Repo/Assistente PMO V2/topics/AtualizarStatus.mcs.yml`
- Matching PM0 workflow trigger source: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarStatus-1721e0a3-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Local workflow trigger evidence: the Skills request schema declares `action`, `status`, and `routeKey`; `routeKey` is required at workflow lines 30-55.
- AQ-07 route/action evidence for the suggested constants: `.planning/comms/aq07_power_automate_build_20260515/CARD_ACTION_BINDING_MATRIX.csv:3` records FI-02 as route key `pm.status.updates` and action `update`.

## Pre-Call Topic And Global Variables

The PM0 `BeginDialog` call starts at topic line 158. These `Topic.*` and `Global.*` variables are set before that action call.

| Variable | Set before call | Evidence |
|---|---|---|
| `Topic.RawInput` | Captured from current activity text | topic lines 26-29 |
| `Topic.Projeto` | Parsed from raw input, then asked if blank | topic lines 31-34 and 66-76 |
| `Topic.RAG` | Parsed from raw input, then asked if blank | topic lines 36-39 and 78-88 |
| `Topic.Resumo` | Parsed from raw input, then asked if blank | topic lines 41-44 and 90-100 |
| `Topic.Percentual` | Parsed from raw input | topic lines 46-49 |
| `Topic.Risco` | Parsed from raw input | topic lines 51-54 |
| `Topic.Bloqueio` | Parsed from raw input | topic lines 56-59 |
| `Topic.ProximaAcao` | Parsed from raw input | topic lines 61-64 |
| `Topic.ConfirmacaoTexto` | Confirmation question answer | topic lines 102-115 |
| `Global.PMO_Status_Projeto` | `=Topic.Projeto` | topic lines 123-126 |
| `Global.PMO_Status_RAG` | `=Topic.RAG` | topic lines 128-131 |
| `Global.PMO_Status_Resumo` | `=Topic.Resumo` | topic lines 133-136 |
| `Global.PMO_Status_Percentual` | `=Topic.Percentual` | topic lines 138-141 |
| `Global.PMO_Status_Risco` | `=Topic.Risco` | topic lines 143-146 |
| `Global.PMO_Status_Bloqueio` | `=Topic.Bloqueio` | topic lines 148-151 |
| `Global.PMO_Status_ProximaAcao` | `=Topic.ProximaAcao` | topic lines 153-156 |

`Topic.AtualizarStatusResult` is bound as PM0 output at topic lines 162-164, so it is not a pre-call variable.

## Verbatim PM0 BeginDialog Block

Source: topic lines 158-164.

```yaml
            - kind: BeginDialog
              id: invokeFlowAction_atualizar_status
              input: {}
              dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus
              output:
                binding:
                  result: Topic.AtualizarStatusResult
```

## Exact Current Input

The current PM0 call input is exactly:

```yaml
input: {}
```

Evidence: topic line 160.

## Workflow Trigger Contract And Mapping

The matching workflow trigger schema is local evidence, not A1 output. It declares:

| Trigger field | JSON schema type | Required | Workflow evidence | Topic value available before call |
|---|---|---|---|---|
| `action` | `string` | No | workflow lines 38-41 | No direct variable; AQ-07 FI-02 action is `update` |
| `status` | `string` | No | workflow lines 42-45 | `Topic.RAG` and `Global.PMO_Status_RAG` |
| `routeKey` | `string` | Yes | workflow lines 46-53 | No direct variable; AQ-07 FI-02 route key is `pm.status.updates` |

The minimum Power Fx `BeginDialog` binding that matches the local trigger schema and satisfies its required field is:

```yaml
input:
  binding:
    action: ="update"
    status: =Topic.RAG
    routeKey: ="pm.status.updates"
```

The topic currently collects project, summary, percentage, risk, block, and next-action values, but none of those field names exist in this PM0 trigger schema. The empty input omits the required `routeKey` and also does not pass the optional `status` value that the topic already has.

## Finding

`AtualizarStatus` has a PM0 topic-to-workflow contract break at the action call. Topic lines 123-156 copy collected data into globals, then topic line 160 passes an empty input object to a workflow whose local trigger schema requires `routeKey` at workflow lines 51-53.

## Microsoft Learn Citation

- Official page: Microsoft Learn, "Configure zero prompt experience for Copilot in Dynamics 365 Sales (preview)"
- URL: `https://learn.microsoft.com/en-us/dynamics365/sales/zero-prompt-experience`
- Accessed: `2026-05-22 15:23:02 -03:00`
- Citation use: the sample YAML at page lines 131-160 shows a `BeginDialog` action using `input:` with nested `binding:` entries before `dialog:` and `output:`. This supports the `BeginDialog input.binding` syntax only; PM0 field names and requirements above come from the local workflow JSON.
