# A3 Topic Contract Audit - CriarTarefa

## Scope And Sources

- Topic source: `Local_Repo/Assistente PMO V2/topics/CriarTarefa.mcs.yml`
- Matching PM0 workflow trigger source: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_CriarTarefa-7f662db7-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Local workflow trigger evidence: the Skills request schema declares `dueDate`, `action`, `taskTitle`, `projectId`, `endDate`, `startDate`, `bucket`, `title`, and `plannerBucketName`; `projectId` and `action` are required at workflow lines 42-93.
- Local workflow body evidence: the current body reads title aliases for Planner and SharePoint create at workflow lines 96-118 and 125-154, and writes `projectId` into the SharePoint item at workflow line 139.

## Pre-Call Topic And Global Variables

The PM0 `BeginDialog` call starts at topic line 169. These `Topic.*` and `Global.*` variables are set before that action call.

| Variable | Set before call | Evidence |
|---|---|---|
| `Topic.RawInput` | Captured from current activity text | topic lines 20-23 |
| `Topic.NomeProjeto` | Parsed from raw input, then asked if blank | topic lines 25-28 and 55-65 |
| `Topic.Titulo` | Parsed from raw input, then asked if blank | topic lines 30-33 and 67-77 |
| `Topic.Responsavel` | Parsed from raw input, then asked if blank | topic lines 35-38 and 79-89 |
| `Topic.Prazo` | Parsed from raw input, then asked if blank | topic lines 40-43 and 91-101 |
| `Topic.Horas` | Parsed from raw input, then asked if blank | topic lines 45-48 and 103-113 |
| `Topic.Prioridade` | Parsed from raw input, then asked if blank | topic lines 50-53 and 115-125 |
| `Topic.ConfirmacaoTexto` | Confirmation question answer | topic lines 127-131 |
| `Global.PMO_Criar_NomeProjeto` | `=Topic.NomeProjeto` | topic lines 139-142 |
| `Global.PMO_Criar_Titulo` | `=Topic.Titulo` | topic lines 144-147 |
| `Global.PMO_Criar_Responsavel` | `=Topic.Responsavel` | topic lines 149-152 |
| `Global.PMO_Criar_Prazo` | `=Topic.Prazo` | topic lines 154-157 |
| `Global.PMO_Criar_Horas` | `=Topic.Horas` | topic lines 159-162 |
| `Global.PMO_Criar_Prioridade` | `=Topic.Prioridade` | topic lines 164-167 |

`Topic.Result` is bound as PM0 output at topic lines 173-175, so it is not a pre-call variable.

## Verbatim PM0 BeginDialog Block

Source: topic lines 169-175.

```yaml
            - kind: BeginDialog
              id: call_criar_tarefa
              input: {}
              dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa
              output:
                binding:
                  result: Topic.Result
```

## Exact Current Input

The current PM0 call input is exactly:

```yaml
input: {}
```

Evidence: topic line 171.

## Workflow Trigger Contract And Mapping

The matching local workflow schema exposes these fields:

| Trigger field | JSON schema type | Required | Workflow evidence | Topic value available before call |
|---|---|---|---|---|
| `dueDate` | `string` | No | workflow lines 50-53 | `Topic.Prazo` |
| `action` | `string` | Yes | workflow lines 54-57 and 87-90 | No direct variable; AQ-07 FI-04 action is `create` |
| `taskTitle` | `string` | No | workflow lines 58-61 | `Topic.Titulo` |
| `projectId` | `string` | Yes | workflow lines 62-65 and 87-90 | Only `Topic.NomeProjeto` is available |
| `endDate` | `string` | No | workflow lines 66-69 | `Topic.Prazo` |
| `startDate` | `string` | No | workflow lines 70-73 | None |
| `bucket` | `string` | No | workflow lines 74-77 | None with bucket semantics |
| `title` | `string` | No | workflow lines 78-81 | `Topic.Titulo` |
| `plannerBucketName` | `string` | No | workflow lines 82-85 | None with bucket semantics |

The minimum Power Fx `BeginDialog` binding that satisfies the local required fields and supplies the title value read by the workflow body is:

```yaml
input:
  binding:
    action: ="create"
    projectId: =Topic.NomeProjeto
    title: =Topic.Titulo
    endDate: =Topic.Prazo
```

This is a schema-level mapping, not proof that `Topic.NomeProjeto` is a valid `ProjectID`. The topic asks for "nome ou codigo do projeto" at topic line 64, while the workflow writes `triggerBody()?['projectId']` directly to `Tarefas.ProjectID` at workflow line 139. The topic has no pre-call resolved `Topic.ProjectID` variable.

The topic also collects `Responsavel`, `Horas`, and `Prioridade`, but those values have no corresponding fields in this PM0 trigger schema.

## Finding

`CriarTarefa` has a PM0 topic-to-workflow contract break at the action call. Topic lines 139-167 copy collected values into globals, then topic line 171 passes an empty input object to a workflow trigger whose local schema requires `projectId` and `action`.

## Microsoft Learn Citation

- Official page: Microsoft Learn, "Configure zero prompt experience for Copilot in Dynamics 365 Sales (preview)"
- URL: `https://learn.microsoft.com/en-us/dynamics365/sales/zero-prompt-experience`
- Accessed: `2026-05-22 15:23:02 -03:00`
- Citation use: the sample YAML at page lines 131-160 shows a `BeginDialog` action using `input:` with nested `binding:` entries before `dialog:` and `output:`. This supports the `BeginDialog input.binding` syntax only; PM0 field names and requirements above come from the local workflow JSON.
