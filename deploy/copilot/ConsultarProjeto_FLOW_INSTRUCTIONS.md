# ConsultarProjeto flow instructions

Flow display name: `PMO_PA_ConsultarProjeto`

Purpose: read one project from SharePoint and return project details plus open risk count.

Official Microsoft references:
- SharePoint connector is Standard and supports list actions: https://learn.microsoft.com/en-us/connectors/sharepointonline/
- SharePoint and Power Automate overview: https://learn.microsoft.com/en-us/power-automate/sharepoint-overview
- OData filter syntax reference: https://learn.microsoft.com/en-us/sharepoint/dev/sp-add-ins/use-odata-query-operations-in-sharepoint-rest-requests

## Trigger

1. Create an instant cloud flow from Copilot Studio / Power Automate Classic Designer.
2. Trigger: `Run a flow from Copilot`.
3. Add one text input:
   - `NomeProjeto`

This maps to the topic YAML binding:

```text
text = NomeProjeto
```

## Actions

1. Add SharePoint `Get items`
   - Action name: `Get_Projeto`
   - Site Address: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
   - List Name: `Projetos`
   - Top Count: `1`
   - Filter Query, conservative exact-match version:

```text
NomeProjeto eq '<NomeProjeto>' and Ativo eq 1 and Deleted ne true
```

Use exact match first. Although SharePoint REST documents OData query operations, exact `eq` filters are the safest option in the Power Automate SharePoint `Get items` designer.

2. Add `Condition`
   - Left side expression:

```text
length(body('Get_Projeto')?['value'])
```

   - Operator: is greater than
   - Right side: `0`

3. In the `Yes` branch, add SharePoint `Get items`
   - Action name: `Get_Riscos_Abertos`
   - List Name: `Riscos e Bloqueios`
   - Filter Query:

```text
ProjectID eq '<ProjectID from Get_Projeto first item>' and Tipo eq 'Risco' and StatusRisco eq 'Aberto' and Deleted ne true
```

4. In the `Yes` branch, add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value format:

```text
Projeto: <NomeProjeto>
ProjectID: <ProjectID>
PM: <PM>
RAG: <StatusRAG>
Percentual: <Percentual>
Data alvo: <DataAlvo>
Prioridade: <Prioridade>
Ultima atualizacao: <UltimaAtualizacao>
Riscos abertos: <length(body('Get_Riscos_Abertos')?['value'])>
```

5. In the `No` branch, add `Respond to Copilot`
   - Output name: `message`
   - Output type: Text
   - Value:

```text
Projeto nao encontrado.
```

## Optional exact ProjectID fallback

If users often provide `PRJ-001` instead of the project name, add a second `Get items` branch with:

```text
ProjectID eq '<NomeProjeto>' and Ativo eq 1 and Deleted ne true
```

Keep this as an explicit second lookup instead of mixing complex filters until the designer validates it.

## Required checks before publish

- The flow uses only SharePoint Standard connector actions.
- All reads filter `Deleted ne true`.
- The response output property is exactly `message`.
- Copy the flow id from the flow URL and replace `REPLACE_WITH_ACTUAL_FLOW_ID` in `ConsultarProjeto_topic.yaml`.
