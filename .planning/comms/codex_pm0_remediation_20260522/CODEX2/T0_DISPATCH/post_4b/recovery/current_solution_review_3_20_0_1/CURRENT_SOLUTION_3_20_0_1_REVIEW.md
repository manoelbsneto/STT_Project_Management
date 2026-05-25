# Current Solution Review - PMO_v11_Tarefas 3.20.0.1

- Source ZIP: C:/Users/dataops-lab/Downloads/PMO_v11_Tarefas_3_20_0_1.zip
- SHA256: ADD7FD64F23BFE6363265A0C642B9FFA3BEB8C00551AD65093284A2E6070D872
- Internal version: 3.20.0.1
- Workflows: 17
- Botcomponents: 27 (16 topics, 10 actions)
- Workflowset bindings: 15
- Connection references: 6

## Red Flags

- 3.20.0.1 package still includes legacy PMO_PA_* workflows/actions alongside PM0_PA_Card_* components.
- PM0_PA_OpsFailureHandling action points to flowId 9531fbc7-a250-f111-bec7-000d3abc5cc6, but that workflow is not present in the package.
- gstf_sharepoint connection reference is present but unused by workflow JSON.
- solution.xml still lists MissingDependency rows for cat_DataverseIndexerSharePoint and cat_sharedteams_1ef7e from CopilotStudioAccelerator.

## Action Components

| Action | Flow IDs | Called by topics | Workflowset | Classification | Reason |
|---|---|---|---|---|---|
| pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus | 1721e0a3-a250-f111-bec7-000d3abc5cc6 | pmo_AssistentePMO_V2.topic.AtualizarStatus | Yes | KEEP_REQUIRED | called by topic; bound in botcomponent_workflowset |
| pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa | 7c6300c2-a250-f111-bec7-000d3abc5cc6 | pmo_AssistentePMO_V2.topic.AtualizarTarefa | Yes | KEEP_REQUIRED | called by topic; bound in botcomponent_workflowset |
| pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa | 7f662db7-a250-f111-bec7-000d3abc5cc6 | pmo_AssistentePMO_V2.topic.CriarTarefa | Yes | KEEP_REQUIRED | called by topic; bound in botcomponent_workflowset |
| pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas | e0e3c6b0-a250-f111-bec7-000d3abc5cc6 | pmo_AssistentePMO_V2.topic.ListarTarefas | Yes | KEEP_REQUIRED | called by topic; bound in botcomponent_workflowset |
| pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio | 8333bd91-a250-f111-bec7-000d3abc5cc6 | pmo_AssistentePMO_V2.topic.ConsultarPortfolio | Yes | KEEP_REQUIRED | called by topic; bound in botcomponent_workflowset |
| pmo_AssistentePMO_V2.action.PM0_PA_OpsFailureHandling | 9531fbc7-a250-f111-bec7-000d3abc5cc6 | - | No | INVESTIGATE_FIRST | action not called by any topic and not in workflowset; action points to flowId not present as workflow JSON/root component |
| pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa | 98408d55-3748-f111-bec7-000d3abc5cc6 | - | Yes | KEEP_UNTIL_REBIND_OR_CONFIRM_UNUSED | bound in workflowset but no topic references it; bound in botcomponent_workflowset |
| pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto | 3104124d-364a-f111-bec7-7ced8d955c6c | pmo_AssistentePMO_V2.topic.CriarProjeto | Yes | KEEP_REQUIRED | called by topic; bound in botcomponent_workflowset |
| pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa | 0a5d2a41-24c0-4d5e-9f6d-000000000241 | - | Yes | KEEP_UNTIL_REBIND_OR_CONFIRM_UNUSED | bound in workflowset but no topic references it; bound in botcomponent_workflowset |
| pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas | 9544f14b-3748-f111-bec7-6045bdf42cae | - | Yes | KEEP_UNTIL_REBIND_OR_CONFIRM_UNUSED | bound in workflowset but no topic references it; bound in botcomponent_workflowset |

## Workflows

| Workflow | ID | Connection refs | Workflowset | Referenced by botcomponent flowId | Classification | Reason |
|---|---|---|---|---|---|---|
| PM0_PA_Card_AtualizarStatus | 1721e0a3-a250-f111-bec7-000d3abc5cc6 | cat_DataverseIndexerSharePoint, cat_sharedteams_1ef7e | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PM0_PA_Card_AtualizarTarefa | 7c6300c2-a250-f111-bec7-000d3abc5cc6 | cat_DataverseIndexerSharePoint, pmo_sharedplanner_87b5f | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PM0_PA_Card_CriarTarefa | 7f662db7-a250-f111-bec7-000d3abc5cc6 | cat_DataverseIndexerSharePoint, pmo_sharedplanner_87b5f | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PM0_PA_Card_ListarTarefas | e0e3c6b0-a250-f111-bec7-000d3abc5cc6 | cat_DataverseIndexerSharePoint, pmo_sharedplanner_87b5f | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PM0_PA_Card_ResumoExecutivoPortfolio | 8333bd91-a250-f111-bec7-000d3abc5cc6 | pmo_cat_DataverseIndexerSharePoint | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_AtualizarStatus | c11a165b-c64c-f111-bec7-7ced8d9559c1 | pmo_sharedsharepointonline_6e373 | No | No | DELETE_CANDIDATE | workflow not bound by workflowset and not referenced by botcomponent action/topic data; legacy workflow appears superseded and no package action/topic reference found |
| PMO_PA_AtualizarTarefa | 98408d55-3748-f111-bec7-000d3abc5cc6 | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_ConsultarPortfolio | 39cf292d-c64c-f111-bec7-7ced8d955c6c | pmo_sharedsharepointonline_6e373 | No | No | DELETE_CANDIDATE | workflow not bound by workflowset and not referenced by botcomponent action/topic data; legacy workflow appears superseded and no package action/topic reference found |
| PMO_PA_ConsultarProjeto | 4a33b53e-c64c-f111-bec7-000d3abc5cc6 | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_CriarProjeto | 3104124d-364a-f111-bec7-7ced8d955c6c | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_CriarTarefa | 0a5d2a41-24c0-4d5e-9f6d-000000000241 | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_ExcluirProjeto | 16fbe313-2edc-406e-ad7f-d08cee0edc43 | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_ExcluirTarefa | 70b39334-5926-4fb1-bd22-f10bd99f0f6d | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_ListarTarefas | 9544f14b-3748-f111-bec7-6045bdf42cae | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_PedirDecisaoBot | feb79d54-c64c-f111-bec7-7ced8d955c6c | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_RegistrarBloqueioBot | 3ec37952-c64c-f111-bec7-000d3abc5cc6 | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |
| PMO_PA_RegistrarRiscoBot | ee732d46-c64c-f111-bec7-7ced8d955c6c | pmo_sharedsharepointonline_6e373 | Yes | Yes | KEEP_REQUIRED | bound in workflowset; referenced by action/topic flowId |

## Connection References

| Logical name | Display | Connector | Classification | Reason |
|---|---|---|---|---|
| cat_DataverseIndexerSharePoint | SharePoint PMO Dataverse Indexer | /providers/Microsoft.PowerApps/apis/shared_sharepointonline | KEEP_REQUIRED | used by workflows: PM0_PA_Card_AtualizarStatus, PM0_PA_Card_AtualizarTarefa, PM0_PA_Card_CriarTarefa, PM0_PA_Card_ListarTarefas; listed as MissingDependency from CopilotStudioAccelerator |
| cat_sharedteams_1ef7e | Teams PMO | /providers/Microsoft.PowerApps/apis/shared_teams | KEEP_REQUIRED | used by workflows: PM0_PA_Card_AtualizarStatus; listed as MissingDependency from CopilotStudioAccelerator |
| gstf_sharepoint | sharepoint | /providers/Microsoft.PowerApps/apis/shared_sharepointonline | DELETE_CANDIDATE | no workflow JSON uses this connectionReferenceLogicalName |
| pmo_cat_DataverseIndexerSharePoint | SharePoint PMO Dataverse Indexer pmo | /providers/Microsoft.PowerApps/apis/shared_sharepointonline | KEEP_REQUIRED | used by workflows: PM0_PA_Card_ResumoExecutivoPortfolio |
| pmo_sharedplanner_87b5f | Planner PMO | /providers/Microsoft.PowerApps/apis/shared_planner | KEEP_REQUIRED | used by workflows: PM0_PA_Card_AtualizarTarefa, PM0_PA_Card_CriarTarefa, PM0_PA_Card_ListarTarefas |
| pmo_sharedsharepointonline_6e373 | SharePoint PMO_v11_Tarefas-6e373 | /providers/Microsoft.PowerApps/apis/shared_sharepointonline | KEEP_REQUIRED | used by workflows: PMO_PA_AtualizarStatus, PMO_PA_AtualizarTarefa, PMO_PA_ConsultarPortfolio, PMO_PA_ConsultarProjeto, PMO_PA_CriarProjeto, PMO_PA_CriarTarefa, PMO_PA_ExcluirProjeto, PMO_PA_ExcluirTarefa, PMO_PA_ListarTarefas, PMO_PA_PedirDecisaoBot, PMO_PA_RegistrarBloqueioBot, PMO_PA_RegistrarRiscoBot |

## Immediate Cleanup Guidance

Do not bulk-delete all disabled components. Topic/action/workflow pairs are expected to share similar names. Delete only after dependency confirmation. The first safe cleanup candidates from this package are: unused gstf_sharepoint connection reference, PM0_PA_OpsFailureHandling action with missing workflow, and legacy PMO_PA_AtualizarStatus / PMO_PA_ConsultarPortfolio workflows if tenant dependency checks confirm no external references.
