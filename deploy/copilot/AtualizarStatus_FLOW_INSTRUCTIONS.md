# AtualizarStatus flow instructions

Flow display name: `PMO_PA_AtualizarStatus`

Purpose: validate a project, create one `Status Diario` item, and update the corresponding `Projetos` item.

Official Microsoft references:
- SharePoint connector is Standard and supports list actions: https://learn.microsoft.com/en-us/connectors/sharepointonline/
- SharePoint and Power Automate overview: https://learn.microsoft.com/en-us/power-automate/sharepoint-overview
- OData filter syntax reference: https://learn.microsoft.com/en-us/sharepoint/dev/sp-add-ins/use-odata-query-operations-in-sharepoint-rest-requests

## Trigger

1. Create an instant cloud flow from Copilot Studio / Power Automate Classic Designer.
2. Trigger: `Run a flow from Copilot`.
3. Add inputs in this exact order:
   - Text: `NomeProjeto`
   - Text: `RAG`
   - Text: `Resumo`
   - Number: `Percentual`
   - Text: `Risco`
   - Text: `Bloqueio`
   - Text: `ProximaAcao`

These map to the topic YAML bindings:

```text
text   = NomeProjeto
text_1 = RAG
text_2 = Resumo
number = Percentual
text_3 = Risco
text_4 = Bloqueio
text_5 = ProximaAcao
```

## Actions

1. Add `Initialize variable`
   - Name: `varStatusID`
   - Type: String
   - Value expression:

```text
concat('STU-', formatDateTime(utcNow(), 'yyyyMMddHHmmss'))
```

2. Add SharePoint `Get items`
   - Action name: `Get_Projeto`
   - Site Address: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
   - List Name: `Projetos`
   - Top Count: `1`
   - Filter Query:

```text
NomeProjeto eq '<NomeProjeto>' and Ativo eq 1 and Deleted ne true
```

3. Add `Condition`
   - Left side expression:

```text
length(body('Get_Projeto')?['value'])
```

   - Operator: is greater than
   - Right side: `0`

4. In the `Yes` branch, add SharePoint `Create item`
   - List Name: `Status Diario`
   - Field mapping:

```text
Title          = variables('varStatusID')
StatusID       = variables('varStatusID')
ProjectID      = ProjectID from first item returned by Get_Projeto
DataRegistro   = utcNow()
PM             = PM from first item returned by Get_Projeto, if exposed by designer
RAG            = RAG input
Resumo         = Resumo input
Risco          = Risco input
Bloqueio       = Bloqueio input
ProximaAcao    = ProximaAcao input
Percentual     = Percentual input
OrigemEntrada  = CopilotStudio
Deleted        = false
```

5. In the `Yes` branch, add SharePoint `Update item`
   - List Name: `Projetos`
   - Id: item `ID` from first item returned by `Get_Projeto`
   - Preserve required existing fields:

```text
Title          = existing Title if visible
ProjectID      = existing ProjectID
NomeProjeto    = existing NomeProjeto
PM             = existing PM
StatusRAG      = RAG input
Percentual     = Percentual input
UltimaAtualizacao = utcNow()
Ativo          = existing Ativo
Deleted        = existing Deleted
```

Do not blank required columns in `Update item`; map existing values back when the designer requires them.

6. In the `Yes` branch, add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value:

```text
Status @{variables('varStatusID')} registrado para o projeto @{triggerBody()?['text']}.
```

7. In the `No` branch, add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value:

```text
Projeto nao encontrado ou inativo. Nenhum status foi registrado.
```

## Required checks before publish

- The flow uses only SharePoint Standard connector actions.
- `Create item` sets `Deleted=false`.
- All reads filter `Deleted ne true`.
- `Update item` preserves required existing columns.
- The response output property is exactly `message`.
- Copy the flow id from the flow URL and replace `REPLACE_WITH_ACTUAL_FLOW_ID` in `AtualizarStatus_topic.yaml`.
