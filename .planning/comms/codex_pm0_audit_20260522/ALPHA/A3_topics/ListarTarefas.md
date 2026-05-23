# A3 Topic Contract Audit - ListarTarefas

## Scope And Sources

- Topic source: `Local_Repo/Assistente PMO V2/topics/ListarTarefas.mcs.yml`
- Matching PM0 workflow trigger source: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Local workflow trigger evidence: the Skills request schema declares `action` and `projectId`, and both fields are required at workflow lines 36-63.
- Local workflow body evidence: SharePoint `Get_Tarefas` filters `ProjectID` from `triggerBody()?['projectId']` at workflow lines 137-156.

## Pre-Call Topic And Global Variables

The PM0 `BeginDialog` call starts at topic line 46. These `Topic.*` and `Global.*` variables are set before that action call.

| Variable | Set before call | Evidence |
|---|---|---|
| `Topic.RawInput` | Captured from current activity text | topic lines 19-22 |
| `Topic.NomeProjeto` | Parsed from raw input, then asked if blank | topic lines 24-27 and 29-39 |
| `Global.PMO_Listar_NomeProjeto` | `=Topic.NomeProjeto` | topic lines 41-44 |

`Topic.tarefas` is bound as PM0 output at topic lines 50-52, so it is not a pre-call variable.

## Verbatim PM0 BeginDialog Block

Source: topic lines 46-52.

```yaml
    - kind: BeginDialog
      id: call_listar_tarefas
      input: {}
      dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas
      output:
        binding:
          result: Topic.tarefas
```

## Exact Current Input

The current PM0 call input is exactly:

```yaml
input: {}
```

Evidence: topic line 48.

## Workflow Trigger Contract And Mapping

The matching local workflow schema exposes these fields:

| Trigger field | JSON schema type | Required | Workflow evidence | Topic value available before call |
|---|---|---|---|---|
| `action` | `string` | Yes | workflow lines 47-50 and 56-59 | No direct variable; AQ-07 FI-03 action is `list` |
| `projectId` | `string` | Yes | workflow lines 51-54 and 56-59 | Only `Topic.NomeProjeto` is available |

The minimum Power Fx `BeginDialog` binding that satisfies the local trigger schema is:

```yaml
input:
  binding:
    action: ="list"
    projectId: =Topic.NomeProjeto
```

This is a schema-level mapping, not proof that the topic resolves a project name into a `ProjectID`. The topic prompt accepts "nome ou codigo do projeto" at topic line 38, while the workflow filters SharePoint with `ProjectID` from the `projectId` trigger field at workflow line 152. The topic has no pre-call resolved `Topic.ProjectID` variable.

## Finding

`ListarTarefas` has a PM0 topic-to-workflow contract break at the action call. Topic line 44 stores the collected project text in a global, then topic line 48 passes no inputs to a workflow trigger whose local schema requires `action` and `projectId`.

## Microsoft Learn Citation

- Official page: Microsoft Learn, "Configure zero prompt experience for Copilot in Dynamics 365 Sales (preview)"
- URL: `https://learn.microsoft.com/en-us/dynamics365/sales/zero-prompt-experience`
- Accessed: `2026-05-22 15:23:02 -03:00`
- Citation use: the sample YAML at page lines 131-160 shows a `BeginDialog` action using `input:` with nested `binding:` entries before `dialog:` and `output:`. This supports the `BeginDialog input.binding` syntax only; PM0 field names and requirements above come from the local workflow JSON.
