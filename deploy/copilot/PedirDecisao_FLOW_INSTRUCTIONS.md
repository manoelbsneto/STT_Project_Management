# PedirDecisao flow instructions

Flow display name: `PMO_PA_PedirDecisaoBot`

Purpose: validate a project and create one item in SharePoint list `Decisoes do Board`.

Official Microsoft references:
- SharePoint connector is Standard and supports list actions: https://learn.microsoft.com/en-us/connectors/sharepointonline/
- SharePoint and Power Automate overview: https://learn.microsoft.com/en-us/power-automate/sharepoint-overview
- OData filter syntax reference: https://learn.microsoft.com/en-us/sharepoint/dev/sp-add-ins/use-odata-query-operations-in-sharepoint-rest-requests

## Trigger

1. Create an instant cloud flow from Copilot Studio / Power Automate Classic Designer.
2. Trigger: `Run a flow from Copilot`.
3. Add text inputs in this exact order:
   - `ProjectID`
   - `Descricao`
   - `Impacto`
   - `Prazo`

These map to the topic YAML bindings:

```text
text   = ProjectID
text_1 = Descricao
text_2 = Impacto
text_3 = Prazo
```

## Required precheck for this list

`Decisoes do Board` has required User fields `Solicitante` and `Aprovador`. Before publishing this flow, verify in Classic Designer that SharePoint `Create item` exposes these User fields and accepts the PM / approver values from dynamic content. If the tenant connector cannot populate required User fields, SharePoint will reject the write. In that case, make `Aprovador` non-required or set a SharePoint default before enabling this flow.

## Actions

1. Add `Initialize variable`
   - Name: `varDecisionID`
   - Type: String
   - Value expression:

```text
concat('DEC-', formatDateTime(utcNow(), 'yyyyMMddHHmmss'))
```

2. Add SharePoint `Get items`
   - Site Address: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
   - List Name: `Projetos`
   - Top Count: `1`
   - Filter Query:

```text
ProjectID eq '<ProjectID>' and Ativo eq 1 and Deleted ne true
```

3. Add `Condition`
   - Left side expression:

```text
length(body('Get_items')?['value'])
```

   - Operator: is greater than
   - Right side: `0`

4. In the `Yes` branch, add SharePoint `Create item`
   - Site Address: same site
   - List Name: `Decisoes do Board`
   - Field mapping:

```text
Title          = variables('varDecisionID')
DecisionID     = variables('varDecisionID')
ProjectID      = ProjectID input
Descricao      = Descricao input
Solicitante    = PM from the first item returned by Get items
Aprovador      = configured approver user or a required-field default
ApproverUPN    = configured approver UPN if used
StatusDecisao  = Pendente
Impacto        = Impacto input
Prazo          = Prazo input, only when provided
Deleted        = false
```

5. In the `Yes` branch, add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value:

```text
Decisao @{variables('varDecisionID')} registrada para o projeto @{triggerBody()?['text']}.
```

6. In the `No` branch, add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value:

```text
Projeto nao encontrado ou inativo. Nenhuma decisao foi registrada.
```

## Required checks before publish

- The flow uses only SharePoint Standard connector actions.
- `Create item` sets `Deleted=false`.
- `Get items` filters `Deleted ne true`.
- Required User fields are actually populated in a test run.
- The response output property is exactly `message`.
- Copy the flow id from the flow URL and replace `REPLACE_WITH_ACTUAL_FLOW_ID` in `PedirDecisao_topic.yaml`.
