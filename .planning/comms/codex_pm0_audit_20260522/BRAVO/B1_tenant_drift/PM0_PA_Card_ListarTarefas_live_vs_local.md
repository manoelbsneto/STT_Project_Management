# PM0_PA_Card_ListarTarefas Live vs Local

Last updated: 2026-05-22 15:32:32 -03:00 | Codex #2 B1 | PAC live-vs-local tenant drift evidence

## Scope and Raw Evidence

- Workflow ID: `e0e3c6b0-a250-f111-bec7-000d3abc5cc6`
- Local export: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Live workflow row and `clientdata`: `PAC_OUTPUTS/pac_fetch_pm0_card_workflow_clientdata.txt`
- Extracted live `clientdata`: `PAC_OUTPUTS/PM0_PA_Card_ListarTarefas_e0e3c6b0-a250-f111-bec7-000d3abc5cc6_live_clientdata.json`
- Field-level diff: `PAC_OUTPUTS/PM0_PA_Card_ListarTarefas_e0e3c6b0-a250-f111-bec7-000d3abc5cc6_field_diff.json`
- Binding evidence: `PAC_OUTPUTS/pac_fetch_pm0_card_botcomponent_workflow_bindings.txt` and `PAC_OUTPUTS/pac_fetch_pm0_card_action_botcomponents.txt`
- Connection evidence: `PAC_OUTPUTS/pac_connection_list.txt` and `PAC_OUTPUTS/pac_fetch_pmo_connectionreferences.txt`
- Run evidence: `PAC_OUTPUTS/pac_fetch_pm0_card_flowruns_by_workflow.txt`

## Live Tenant State

| Evidence item | PAC result |
|---|---|
| Workflow state/status | `Activado` / `Activado` |
| Workflow category/type | `Flujo moderno` / `Definicion` |
| Workflow modified | `22/05/2026 8:41` |
| Workflow version | `97.726.305` |
| Action component binding | Active `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` row binds to this workflow ID |
| Action component modified | `22/05/2026 8:56` |
| Last successful run | `1c53e508-2708-98c8-0a96-6d3f351a9ccc`, run name `08584221351351744406145642069CU05`, start `22/05/2026 14:42`, end `22/05/2026 14:42`, status `Succeeded` |
| Last failed run | No failed row for this workflow returned by the approved filtered PAC `flowrun` FetchXML |

PAC returned four additional successful ListarTarefas rows in the same raw flow-run file. The newest row aligns with the AQ-09 A1 run window described in the dispatch, but this B1 report asserts only the PAC row fields above.

## Connection and Adaptive Card Evidence

Live `clientdata` uses SharePoint reference `cat_DataverseIndexerSharePoint` and Planner reference `pmo_sharedplanner_87b5f`. PAC returned both connection-reference rows as `Activa`, owned by `Manoel Benicio De Souza Filho`, with connections `44f187cde7f54f208cf22bac4e533816` and `6b763b98729c4d99a7a8df4033d381af`. `pac connection list` shows both connections as `Connected`.

Adaptive Card binding is not present in this live flow definition. The live actions read SharePoint tasks, list Planner tasks, normalize rows, and return the Skills response; no `PostCardToConversation` operation appears in the extracted live JSON. The Copilot action binding itself is active and points to this workflow ID.

## Live vs Local Comparison

| Metric | Result |
|---|---|
| Local SHA256 | `7C9F42DE0D8E606A417EAC04541E71841A2B4B5D9FF46C99E76CB4EF6BD3ADEE` |
| Live extracted `clientdata` SHA256 | `F9FE29928609CFB00C92D0FA1206651C646992FF1A08FC48260E62C2952D5EE0` |
| Local flattened leaf fields | `64` |
| Live flattened leaf fields | `64` |
| Field-level drift count | `0` |

The byte hashes differ because the local export is formatted while the PAC `clientdata` extraction is compact raw JSON. The field-level comparison found zero changed, missing, or added leaf fields. The matching live and local definition includes the `Respond_Success.inputs.body.result` value `Tasks retrieved successfully.`.

## Drift Verdict

No definition drift detected for this workflow at the field level. The known hardcoded response is present in both live and local definitions, so it is not a tenant drift finding.
