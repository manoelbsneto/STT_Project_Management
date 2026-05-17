# Component Removal Checklist - 2026-05-13 19:55 BRT

Agent: Codex
Status: ACTION REQUIRED BY OWNER IN POWER PLATFORM UI
Scope: PMO v1.1 - Task Management Topics, solution id `717abee5-98e8-45e7-8ce9-264b83b7faa5`

## Rule

Use **Remove from this solution** for the components below.

Do not use physical **Delete from environment** unless the owner explicitly decides to permanently retire the component outside this solution. The current release goal is to clean solution membership/export, not destroy reusable environment objects.

## Remove - Cloud Flows

| Priority | Display name | Type in UI | Workflow/flow id | Exact URL identifier | Reason |
|---|---|---|---|---|---|
| P0 | `PMO_PA_CheckInOnDemand` | `Fluxo Da Nuvem` | `f5aab85e-ff46-f111-bec7-7ced8d955c6c` | `solutions/717abee5-98e8-45e7-8ce9-264b83b7faa5/flows/f5aab85e-ff46-f111-bec7-7ced8d955c6c` | Legacy adaptive-card/check-in flow; dependency risk from `cat_sharedteams_1ef7e`; not in clean 3.8 core package. |
| P0 | `PMO_PA_EscalarRiscoCritico` | `Fluxo Da Nuvem` | `e5381002-0547-f111-bec7-000d3abc5cc6` | `solutions/717abee5-98e8-45e7-8ce9-264b83b7faa5/flows/e5381002-0547-f111-bec7-000d3abc5cc6` | Legacy adaptive-card flow; dependency risk from `cat_sharedteams_1ef7e` and `cat_CopilotStudioKitOutlook`; not in clean 3.8 core package. |
| P0 | `PMO_PA_RegistrarDecisaoBoard` | `Fluxo Da Nuvem` | `b308fe0b-0547-f111-bec7-7ced8d955c6c` | `solutions/717abee5-98e8-45e7-8ce9-264b83b7faa5/flows/b308fe0b-0547-f111-bec7-7ced8d955c6c` | Legacy adaptive-card flow; dependency risk from `cat_sharedteams_1ef7e`; not in clean 3.8 core package. |
| P0 | `PMO_PA_Gerar_Multiplos_Projetos` | `Fluxo Da Nuvem` | `0a5d2a42-24c0-4d5e-9f6d-000000000241` | `solutions/717abee5-98e8-45e7-8ce9-264b83b7faa5/flows/0a5d2a42-24c0-4d5e-9f6d-000000000241` | Orphan workflow. The approved batch feature is preview-only/no-write, so this flow must not ship. |

## Remove - Agent Topic/Action Rows

These may appear in the solution UI as type `Tópico`, even though they represent bot action components connected to the legacy flows.

| Priority | Display name in UI | Type in UI | Schema/component identifier | Reason |
|---|---|---|---|---|
| P0 | `PMO_PA_CheckInOnDemand` | `Tópico` | `pmo_AssistentePMO_V2.action.PMO_PA_CheckInOnDemand` | Companion bot action for removed legacy cloud flow. Remove the duplicate topic row shown above the flow row. |
| P0 | `PMO_PA_EscalarRiscoCritico` | `Tópico` | `pmo_AssistentePMO_V2.action.PMO_PA_EscalarRiscoCritico` | Companion bot action for removed legacy cloud flow. |
| P0 | `PMO_PA_RegistrarDecisaoBoard` | `Tópico` | `pmo_AssistentePMO_V2.action.PMO_PA_RegistrarDecisaoBoard` | Companion bot action for removed legacy cloud flow. |

## Remove - Connection Reference

| Priority | Name | Type in UI | Reason |
|---|---|---|---|
| P0 | `gstf_sharepoint` | `Referência de conexão` | Attempt removal from this solution only if Power Platform offers a non-destructive remove action. Do not delete from environment. On 2026-05-13, physical deletion was blocked by 11 published dependent processes, so it must be left in place unless a later export proves it is still inside this PMO solution package as a blocker. |

## Current Owner Action Result - 2026-05-13

The owner reported successful removal of the full P0 component list except `gstf_sharepoint`.

`gstf_sharepoint` physical deletion is blocked by 11 published dependent processes:

```text
04_21_2026_GF_QA_VT_Consulta_Saldo_QA
Cópia de - GF_QA_VT_Consulta_Saldo
Criar-SolicitacaoFerias
Duplicated_GF_QA_VT_Consulta_Saldo_04_21_20...
GF_QA_Cancelar-SolicitacaoFerias
GF_QA_Criar-SolicitacaoFerias
GF_QA_Reagendar-SolicitacaoFerias
GF_QA_Report-FeriasProximas
GF_QA_VT_Consulta_Saldo
Http -> Obter itens
VT_Fluxo_Submissao
```

Decision: do not delete `gstf_sharepoint` from the environment. Export the solution after the other removals and validate whether `gstf_sharepoint` remains in the PMO package. If it remains only as a global/environment dependency and not as a PMO package blocker, it is not a release blocker.

## Keep - Do Not Remove

| Display name / identifier | Type | Id | Reason |
|---|---|---|---|
| `PMO_PA_CriarTarefa` | Cloud flow | `0a5d2a41-24c0-4d5e-9f6d-000000000241` | Core create-task flow. |
| `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` | Agent action/topic | n/a | Core create-task bot action. |
| `pmo_AssistentePMO_V2.topic.CriarTarefa` | Topic | n/a | Core topic. Do not delete the topic. |
| `PMO_PA_CriarProjeto` | Cloud flow | `3104124d-364a-f111-bec7-7ced8d955c6c` | Core create-project flow. |
| `PMO_PA_AtualizarTarefa` | Cloud flow | `98408d55-3748-f111-bec7-000d3abc5cc6` | Core update-task flow with skip fix. |
| `PMO_PA_ListarTarefas` | Cloud flow | `9544f14b-3748-f111-bec7-6045bdf42cae` | Core list-tasks flow. |
| `PMO_PA_ConsultarPortfolio` | Cloud flow | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | Core portfolio query flow. |
| `PMO_PA_ConsultarProjeto` | Cloud flow | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | Core project query flow. |
| `PMO_PA_RegistrarRiscoBot` | Cloud flow | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | Core risk registration flow. |
| `PMO_PA_RegistrarBloqueioBot` | Cloud flow | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | Core blocker registration flow. |
| `PMO_PA_PedirDecisaoBot` | Cloud flow | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | Core decision request flow. |
| `PMO_PA_ExcluirProjeto` | Cloud flow | `16fbe313-2edc-406e-ad7f-d08cee0edc43` | Core delete-project flow. |
| `PMO_PA_ExcluirTarefa` | Cloud flow | `70b39334-5926-4fb1-bd22-f10bd99f0f6d` | Core delete-task flow. |
| `PMO_PA_AtualizarStatus` | Cloud flow | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | Core status update flow. |
| `pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos` | Topic | n/a | Keep the topic only. It is preview-only/no-write. Remove only the cloud flow named `PMO_PA_Gerar_Multiplos_Projetos`. |

## Special Check - Stale Workflow Association

Known stale association from the failed export:

`pmo_AssistentePMO_V2.topic.CriarTarefa -> workflowid 3104124d-364a-f111-bec7-7ced8d955c6c`

Do not delete `pmo_AssistentePMO_V2.topic.CriarTarefa`.
Do not delete workflow `3104124d-364a-f111-bec7-7ced8d955c6c`, because that is the kept `PMO_PA_CriarProjeto` flow.

If the UI exposes an association/workflowset row, remove only the incorrect association. If not visible, export after the removals above and Codex will re-scan the zip for the stale association.

## Verification After Removal

1. Export the solution again.
2. Provide the new zip path.
3. Codex will run the stop-ship scan. Expected result: no remaining matches for:

```text
MissingDependency
cat_CopilotStudioKitOutlook
cat_sharedteams_1ef7e
gstf_sharepoint
PMO_PA_CheckInOnDemand
PMO_PA_EscalarRiscoCritico
PMO_PA_RegistrarDecisaoBoard
PMO_PA_Gerar_Multiplos_Projetos
pmo_AssistentePMO_V2.topic.CriarTarefa -> workflowid 3104124d-364a-f111-bec7-7ced8d955c6c
```
