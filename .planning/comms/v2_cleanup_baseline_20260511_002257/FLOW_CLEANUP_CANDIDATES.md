# V2 Flow Cleanup Candidate Report

Date: 2026-05-11 00:25:18 -03:00
Baseline export: `.planning/comms/v2_cleanup_baseline_20260511_002257/PMO_v11_Tarefas_V2_CLEANUP_BASELINE.zip`
Baseline SHA256: `54411AF19BED9A21FDE4B1471AB55D5FA5548D05C5C095DD6AC366683CE0C178`

## KEEP - Do Not Delete

| Workflow | WorkflowId | Bound components |
|---|---|---|
| `PMO_PA_AtualizarStatus` | `c11a165b-c64c-f111-bec7-7ced8d9559c1` | `pmo_AssistentePMO_V2.topic.AtualizarStatus` |
| `PMO_PA_AtualizarTarefa` | `98408d55-3748-f111-bec7-000d3abc5cc6` | `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` |
| `PMO_PA_CheckInOnDemand` | `f5aab85e-ff46-f111-bec7-7ced8d955c6c` | `pmo_AssistentePMO_V2.action.PMO_PA_CheckInOnDemand` |
| `PMO_PA_ConsultarPortfolio` | `39cf292d-c64c-f111-bec7-7ced8d955c6c` | `pmo_AssistentePMO_V2.topic.ConsultarPortfolio` |
| `PMO_PA_ConsultarProjeto` | `4a33b53e-c64c-f111-bec7-000d3abc5cc6` | `pmo_AssistentePMO_V2.topic.ConsultarProjeto` |
| `PMO_PA_CriarTarefa_V3` | `3104124d-364a-f111-bec7-7ced8d955c6c` | `pmo_AssistentePMO_V2.topic.CriarTarefa` |
| `PMO_PA_EscalarRiscoCritico` | `e5381002-0547-f111-bec7-000d3abc5cc6` | `pmo_AssistentePMO_V2.action.PMO_PA_EscalarRiscoCritico` |
| `PMO_PA_ListarTarefas` | `9544f14b-3748-f111-bec7-6045bdf42cae` | `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` |
| `PMO_PA_PedirDecisaoBot` | `feb79d54-c64c-f111-bec7-7ced8d955c6c` | `pmo_AssistentePMO_V2.topic.PedirDecisao` |
| `PMO_PA_RegistrarBloqueioBot` | `3ec37952-c64c-f111-bec7-000d3abc5cc6` | `pmo_AssistentePMO_V2.topic.RegistrarBloqueio` |
| `PMO_PA_RegistrarDecisaoBoard` | `b308fe0b-0547-f111-bec7-7ced8d955c6c` | `pmo_AssistentePMO_V2.action.PMO_PA_RegistrarDecisaoBoard` |
| `PMO_PA_RegistrarRiscoBot` | `ee732d46-c64c-f111-bec7-7ced8d955c6c` | `pmo_AssistentePMO_V2.topic.RegistrarRisco` |

## DELETE CANDIDATES - Unbound In V2 Baseline

| Workflow | WorkflowId | Rationale |
|---|---|---|
| `Clean_PMO_PA_CriarTarefa` | `42d9abd1-8849-f111-bec7-7ced8d955c6c` | No V2 binding and no solution botcomponent binding in `botcomponent_workflowset.xml`. |
| `PMO_PA_AtualizarStatus` | `d2645ec7-c84c-f111-bec7-000d3abc5cc6` | No V2 binding and no solution botcomponent binding in `botcomponent_workflowset.xml`. |
| `PMO_PA_ConsultarPortfolio` | `e4c43bb3-c84c-f111-bec7-7ced8d955c6c` | No V2 binding and no solution botcomponent binding in `botcomponent_workflowset.xml`. |
| `PMO_PA_ConsultarProjeto` | `f9c43bb3-c84c-f111-bec7-7ced8d955c6c` | No V2 binding and no solution botcomponent binding in `botcomponent_workflowset.xml`. |
| `PMO_PA_PedirDecisaoBot` | `81917ec0-c84c-f111-bec7-000d3abc5cc6` | No V2 binding and no solution botcomponent binding in `botcomponent_workflowset.xml`. |
| `PMO_PA_RegistrarBloqueioBot` | `68917ec0-c84c-f111-bec7-000d3abc5cc6` | No V2 binding and no solution botcomponent binding in `botcomponent_workflowset.xml`. |
| `PMO_PA_RegistrarRiscoBot` | `e14ca9b9-c84c-f111-bec7-7ced8d955c6c` | No V2 binding and no solution botcomponent binding in `botcomponent_workflowset.xml`. |

## UI Deletion Rule

Delete only in Power Automate > Solution > Fluxos da nuvem. If the UI shows duplicate names, open the flow and compare the workflow id in the URL/details before deleting.
