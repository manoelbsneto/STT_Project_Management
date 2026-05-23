# PM0_PA_Card_AtualizarStatus Live vs Local

Last updated: 2026-05-22 15:32:32 -03:00 | Codex #2 B1 | PAC live-vs-local tenant drift evidence

## Scope and Raw Evidence

- Workflow ID: `1721e0a3-a250-f111-bec7-000d3abc5cc6`
- Local export: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_AtualizarStatus-1721e0a3-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Live workflow row and `clientdata`: `PAC_OUTPUTS/pac_fetch_pm0_card_workflow_clientdata.txt`
- Extracted live `clientdata`: `PAC_OUTPUTS/PM0_PA_Card_AtualizarStatus_1721e0a3-a250-f111-bec7-000d3abc5cc6_live_clientdata.json`
- Field-level diff: `PAC_OUTPUTS/PM0_PA_Card_AtualizarStatus_1721e0a3-a250-f111-bec7-000d3abc5cc6_field_diff.json`
- Binding evidence: `PAC_OUTPUTS/pac_fetch_pm0_card_botcomponent_workflow_bindings.txt` and `PAC_OUTPUTS/pac_fetch_pm0_card_action_botcomponents.txt`
- Connection evidence: `PAC_OUTPUTS/pac_connection_list.txt` and `PAC_OUTPUTS/pac_fetch_pmo_connectionreferences.txt`
- Run evidence: `PAC_OUTPUTS/pac_fetch_pm0_card_flowruns_by_workflow.txt`

## Live Tenant State

| Evidence item | PAC result |
|---|---|
| Workflow state/status | `Activado` / `Activado` |
| Workflow category/type | `Flujo moderno` / `Definicion` |
| Workflow modified | `15/05/2026 19:10` |
| Workflow version | `97.676.626` |
| Action component binding | Active `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` row binds to this workflow ID |
| Action component modified | `22/05/2026 8:56` |
| Last successful run | No row for this workflow returned by the approved filtered PAC `flowrun` FetchXML |
| Last failed run | No row for this workflow returned by the approved filtered PAC `flowrun` FetchXML |

The approved `flowrun` FetchXML query covered all five PM0 card workflow IDs. It returned rows only for `PM0_PA_Card_ListarTarefas` and `PM0_PA_Card_ResumoExecutivoPortfolio`, so this report does not infer a run timestamp for `AtualizarStatus`.

## Connection and Adaptive Card Evidence

Live `clientdata` uses the Teams Standard connection reference `cat_sharedteams_1ef7e`. The Dataverse connection-reference row is `Activa`, owned by `Manoel Benicio De Souza Filho`, and points to connection `shared-teams-1440d346-f1dd-44ea-912f-3787038ac333`. `pac connection list` shows that connection as `Connected`.

Adaptive Card binding is applicable. The live workflow action `Post_Status_Card` uses Teams operation `PostCardToConversation` and embeds an Adaptive Card payload with `"version":"1.5"` before the `Respond_Success` Skills response. The Copilot action component is active and its `InvokeFlowTaskAction.flowId` is the same workflow ID above.

## Live vs Local Comparison

| Metric | Result |
|---|---|
| Local SHA256 | `763D9EA3DB12E40B485CAC46E154705044E950DDBF655929955C770F81A4DDB8` |
| Live extracted `clientdata` SHA256 | `E4A63936E600FECEB3663B13AE105F7C195CF5A60ADC92F3ADF51BF53D20CDB2` |
| Local flattened leaf fields | `50` |
| Live flattened leaf fields | `50` |
| Field-level drift count | `0` |

The byte hashes differ because the local export is a formatted `workflow.json` file and the PAC row exposes compact raw `workflow.clientdata`. The structural field-level comparison found zero changed, missing, or added leaf fields.

## Drift Verdict

No definition drift detected for this workflow at the field level.
