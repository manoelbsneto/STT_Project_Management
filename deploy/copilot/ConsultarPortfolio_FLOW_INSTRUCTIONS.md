# ConsultarPortfolio flow instructions

Flow display name: `PMO_PA_ConsultarPortfolio`

Purpose: read project counts from SharePoint and return a real portfolio summary.

Official Microsoft references:
- SharePoint connector is Standard and supports list actions: https://learn.microsoft.com/en-us/connectors/sharepointonline/
- SharePoint and Power Automate overview: https://learn.microsoft.com/en-us/power-automate/sharepoint-overview
- Expressions in Power Automate conditions: https://learn.microsoft.com/en-us/power-automate/use-expressions-in-conditions

## Trigger

1. Create an instant cloud flow from Copilot Studio / Power Automate Classic Designer.
2. Trigger: `Run a flow from Copilot`.
3. Do not add inputs.

## Actions

Create four SharePoint `Get items` actions against list `Projetos`.

1. `Get_Projetos_Verde`
   - Site Address: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
   - List Name: `Projetos`
   - Filter Query:

```text
Ativo eq 1 and StatusRAG eq 'Verde' and Deleted ne true
```

2. `Get_Projetos_Amarelo`
   - Filter Query:

```text
Ativo eq 1 and StatusRAG eq 'Amarelo' and Deleted ne true
```

3. `Get_Projetos_Vermelho`
   - Filter Query:

```text
Ativo eq 1 and StatusRAG eq 'Vermelho' and Deleted ne true
```

4. `Get_Projetos_Total`
   - Filter Query:

```text
Ativo eq 1 and Deleted ne true
```

5. Add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value:

```text
Portfolio PMO:
Verde: @{length(body('Get_Projetos_Verde')?['value'])} projetos
Amarelo: @{length(body('Get_Projetos_Amarelo')?['value'])} projetos
Vermelho: @{length(body('Get_Projetos_Vermelho')?['value'])} projetos
Total: @{length(body('Get_Projetos_Total')?['value'])} projetos ativos
```

## Required checks before publish

- The flow uses only SharePoint Standard connector actions.
- All reads filter `Deleted ne true`.
- Counts use `length(body('<action>')?['value'])`.
- The response output property is exactly `message`.
- Copy the flow id from the flow URL and replace `REPLACE_WITH_ACTUAL_FLOW_ID` in `ConsultarPortfolio_topic.yaml`.
