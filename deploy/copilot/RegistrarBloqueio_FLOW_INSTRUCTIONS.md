# RegistrarBloqueio flow instructions

Flow display name: `PMO_PA_RegistrarBloqueioBot`

Purpose: validate a project and create one item in SharePoint list `Riscos e Bloqueios` with `Tipo` fixed as `Bloqueio`.

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
   - `Severidade`
   - `Impacto`

These map to the topic YAML bindings:

```text
text   = ProjectID
text_1 = Descricao
text_2 = Severidade
text_3 = Impacto
```

## Actions

1. Add `Initialize variable`
   - Name: `varRiskID`
   - Type: String
   - Value expression:

```text
concat('BLK-', formatDateTime(utcNow(), 'yyyyMMddHHmmss'))
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
   - List Name: `Riscos e Bloqueios`
   - Field mapping:

```text
Title          = variables('varRiskID')
RiskID         = variables('varRiskID')
ProjectID      = ProjectID input
Tipo Value     = Bloqueio
Severidade     = Severidade input
Descricao      = Descricao input
Impacto        = Impacto input
DataCriacao    = utcNow()
StatusRisco    = Aberto
Deleted        = false
```

5. In the `Yes` branch, add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value:

```text
Bloqueio @{variables('varRiskID')} registrado para o projeto @{triggerBody()?['text']}.
```

6. In the `No` branch, add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value:

```text
Projeto nao encontrado ou inativo. Nenhum bloqueio foi registrado.
```

## Required checks before publish

- The flow uses only SharePoint Standard connector actions.
- `Create item` sets `Deleted=false`.
- `Get items` filters `Deleted ne true`.
- The response output property is exactly `message`.
- Copy the flow id from the flow URL and replace `REPLACE_WITH_ACTUAL_FLOW_ID` in `RegistrarBloqueio_topic.yaml`.
