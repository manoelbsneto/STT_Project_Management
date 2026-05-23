# A3 Topic Contract Audit - ConsultarPortfolio

## Scope And Sources

- Topic source: `Local_Repo/Assistente PMO V2/topics/ConsultarPortfolio.mcs.yml`
- Matching PM0 workflow trigger source: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333bd91-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Local workflow trigger evidence: the Skills request schema declares an empty `properties` object and empty `required` array at workflow lines 27-39.

## Pre-Call Topic And Global Variables

The PM0 `BeginDialog` call starts at topic line 27. No `Topic.*` or `Global.*` variable is set before that call in this topic. The first variable binding is the PM0 output `Topic.ConsultarPortfolioResult` at topic lines 31-33.

## Verbatim PM0 BeginDialog Block

Source: topic lines 27-33.

```yaml
    - kind: BeginDialog
      id: invokeFlowAction_consultar_portfolio
      input: {}
      dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio
      output:
        binding:
          result: Topic.ConsultarPortfolioResult
```

## Exact Current Input

The current PM0 call input is exactly:

```yaml
input: {}
```

Evidence: topic line 29.

## Workflow Trigger Contract And Mapping

The matching local workflow trigger schema has no trigger fields.

| Trigger field | Required | Workflow evidence | Topic value available before call |
|---|---|---|---|
| None | None | workflow lines 32-36 | None |

No Power Fx field binding is required by the local PM0 workflow trigger schema. The schema-matching `BeginDialog` input is therefore the current shape:

```yaml
input: {}
```

## Finding

`ConsultarPortfolio` does not show a missing topic-to-trigger input mapping under the matching local workflow schema. The workflow trigger schema has no properties and no required fields at workflow lines 32-36, and the topic passes an empty input object at topic line 29.

## Microsoft Learn Citation

- Official page: Microsoft Learn, "Configure zero prompt experience for Copilot in Dynamics 365 Sales (preview)"
- URL: `https://learn.microsoft.com/en-us/dynamics365/sales/zero-prompt-experience`
- Accessed: `2026-05-22 15:23:02 -03:00`
- Citation use: the sample YAML at page lines 131-160 shows a `BeginDialog` action using `input:` with nested `binding:` entries before `dialog:` and `output:`. This supports the `BeginDialog input.binding` syntax only; PM0 field names and requirements above come from the local workflow JSON.
