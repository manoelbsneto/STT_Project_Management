# PM0_PA_Card_ResumoExecutivoPortfolio Live vs Local

Last updated: 2026-05-22 15:32:32 -03:00 | Codex #2 B1 | PAC live-vs-local tenant drift evidence

## Scope and Raw Evidence

- Workflow ID: `8333bd91-a250-f111-bec7-000d3abc5cc6`
- Local export: `Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333bd91-a250-f111-bec7-000d3abc5cc6/workflow.json`
- Live workflow row and `clientdata`: `PAC_OUTPUTS/pac_fetch_pm0_card_workflow_clientdata.txt`
- Extracted live `clientdata`: `PAC_OUTPUTS/PM0_PA_Card_ResumoExecutivoPortfolio_8333bd91-a250-f111-bec7-000d3abc5cc6_live_clientdata.json`
- Field-level diff: `PAC_OUTPUTS/PM0_PA_Card_ResumoExecutivoPortfolio_8333bd91-a250-f111-bec7-000d3abc5cc6_field_diff.json`
- Binding evidence: `PAC_OUTPUTS/pac_fetch_pm0_card_botcomponent_workflow_bindings.txt` and `PAC_OUTPUTS/pac_fetch_pm0_card_action_botcomponents.txt`
- Connection evidence: `PAC_OUTPUTS/pac_connection_list.txt` and `PAC_OUTPUTS/pac_fetch_pmo_connectionreferences.txt`
- Run evidence: `PAC_OUTPUTS/pac_fetch_pm0_card_flowruns_by_workflow.txt`

## Live Tenant State

| Evidence item | PAC result |
|---|---|
| Workflow state/status | `Activado` / `Activado` |
| Workflow category/type | `Flujo moderno` / `Definicion` |
| Workflow modified | `15/05/2026 22:31` |
| Workflow version | `97.687.619` |
| Action component binding | Active `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` row binds to this workflow ID |
| Action component modified | `22/05/2026 9:45` |
| Last successful run | `fd0ab159-78bf-2242-ea65-a14527caf0e9`, run name `08584221514256618071831062970cU14`, start `22/05/2026 10:10`, end `22/05/2026 10:11`, status `Succeeded` |
| Last failed run | No failed row for this workflow returned by the approved filtered PAC `flowrun` FetchXML |

PAC also returned an earlier successful portfolio run at `16/05/2026 0:35`.

## Connection and Adaptive Card Evidence

Live `clientdata` uses embedded SharePoint reference `pmo_cat_DataverseIndexerSharePoint`. PAC returned that connection-reference row as `Activa`, owned by `Manoel Benicio De Souza Filho`, with SharePoint connection `44f187cde7f54f208cf22bac4e533816`. `pac connection list` shows that connection as `Connected`.

Adaptive Card binding is not present in this live flow definition. The live actions read SharePoint list items and return the Skills response; no `PostCardToConversation` operation appears in the extracted live JSON. The Copilot action binding itself is active and points to this workflow ID.

## Live vs Local Comparison

| Metric | Result |
|---|---|
| Local SHA256 | `B5BCD30982CF43769356394C5C4BF3DC14D1BA6FA58D23BBCE4FCA65E1930050` |
| Live extracted `clientdata` SHA256 | `519DB115949428505C208E2A54E3A19D871864B9DB69031EAC0C1CEB191D73B3` |
| Local flattened leaf fields | `46` |
| Live flattened leaf fields | `46` |
| Field-level drift count | `0` |

The byte hashes differ because the local export is formatted while the PAC `clientdata` extraction is compact raw JSON. The field-level comparison found zero changed, missing, or added leaf fields.

## Drift Verdict

No definition drift detected for this workflow at the field level.
