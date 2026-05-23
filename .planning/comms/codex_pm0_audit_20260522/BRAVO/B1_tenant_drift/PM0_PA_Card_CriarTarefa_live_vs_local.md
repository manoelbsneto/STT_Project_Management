# PM0_PA_Card_CriarTarefa Live vs Local

Last updated: 2026-05-22 15:32:32 -03:00 | Codex #2 B1 | PAC live-vs-local tenant drift evidence

## Scope and Raw Evidence

- Workflow ID: `7f662db7-a250-f111-bec7-000d3abc5cc6`
- Local export: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_CriarTarefa-7f662db7-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Live workflow row and `clientdata`: `PAC_OUTPUTS/pac_fetch_pm0_card_workflow_clientdata.txt`
- Extracted live `clientdata`: `PAC_OUTPUTS/PM0_PA_Card_CriarTarefa_7f662db7-a250-f111-bec7-000d3abc5cc6_live_clientdata.json`
- Field-level diff: `PAC_OUTPUTS/PM0_PA_Card_CriarTarefa_7f662db7-a250-f111-bec7-000d3abc5cc6_field_diff.json`
- Binding evidence: `PAC_OUTPUTS/pac_fetch_pm0_card_botcomponent_workflow_bindings.txt` and `PAC_OUTPUTS/pac_fetch_pm0_card_action_botcomponents.txt`
- Connection evidence: `PAC_OUTPUTS/pac_connection_list.txt` and `PAC_OUTPUTS/pac_fetch_pmo_connectionreferences.txt`
- Run evidence: `PAC_OUTPUTS/pac_fetch_pm0_card_flowruns_by_workflow.txt`

## Live Tenant State

| Evidence item | PAC result |
|---|---|
| Workflow state/status | `Activado` / `Activado` |
| Workflow category/type | `Flujo moderno` / `Definicion` |
| Workflow modified | `15/05/2026 19:10` |
| Workflow version | `97.676.842` |
| Action component binding | Active `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` row binds to this workflow ID |
| Action component modified | `22/05/2026 8:56` |
| Last successful run | No row for this workflow returned by the approved filtered PAC `flowrun` FetchXML |
| Last failed run | No row for this workflow returned by the approved filtered PAC `flowrun` FetchXML |

## Connection and Adaptive Card Evidence

Live `clientdata` uses SharePoint reference `cat_DataverseIndexerSharePoint` and Planner reference `pmo_sharedplanner_87b5f`. PAC returned both connection-reference rows as `Activa`, owned by `Manoel Benicio De Souza Filho`, with connections `44f187cde7f54f208cf22bac4e533816` and `6b763b98729c4d99a7a8df4033d381af`. `pac connection list` shows both connections as `Connected`.

Adaptive Card binding is not present in this live flow definition. The live actions create Planner and SharePoint items and then return the Skills response; no `PostCardToConversation` operation appears in the extracted live JSON. The Copilot action binding itself is active and points to this workflow ID.

## Live vs Local Comparison

| Metric | Result |
|---|---|
| Local SHA256 | `9FF2FED6704E93F24357BEC49322D9CCCC33F13A7F6BA6C923898498C9B9682F` |
| Live extracted `clientdata` SHA256 | `DAE5B72E01E0046907A53E6276E423E4D98FA08B67B6CD3E367080E593A89306` |
| Local flattened leaf fields | `91` |
| Live flattened leaf fields | `91` |
| Field-level drift count | `0` |

The byte hashes differ because the local export is formatted while the PAC `clientdata` extraction is compact raw JSON. The field-level comparison found zero changed, missing, or added leaf fields.

## Drift Verdict

No definition drift detected for this workflow at the field level.
