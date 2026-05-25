# A2_CMD-15 — ConsultarPortfolio

## Metadata

- test_id: A2_CMD-15
- section: A in-scope ship-gate
- executor: <<TODO_BACKFILL: executor_name (depends on: T4_execution)>>
- date_brt: <<TODO_BACKFILL: date_brt (depends on: T4_execution)>>
- build_under_test: 3.16
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

## Chat input

<!-- INPUT BEGIN -->
consultar portfolio
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
<<TODO_BACKFILL: bot_response_transcript (depends on: T4_execution)>>
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: <<TODO_BACKFILL: run_url_or_id (depends on: T4_execution)>>

## SharePoint side effect

- expected: None
- actual: <<TODO_BACKFILL: actual_sp_side_effect (depends on: T4_execution)>>
- pnp_output_path: <<TODO_BACKFILL: pnp_output_path (depends on: T4_execution)>>

PnP read-back command:
```powershell
Get-PnPListItem -List "Projetos" -PageSize 100 -Fields "ID","Title","ProjectID","StatusRAG","Ativo","Deleted","UltimaAtualizacao" |
  Where-Object { $_["Ativo"] -eq $true -and $_["Deleted"] -ne $true } |
  Group-Object {
    $rag = $_["StatusRAG"]
    if ($rag -and $rag.PSObject.Properties.Name -contains "LookupValue") { $rag.LookupValue } else { [string]$rag }
  } |
  Select-Object Name,Count
```

## XPIA marker observation

- cf_observed: <<TODO_BACKFILL: cf_observed (depends on: T4_execution)>>
- oai_observed: <<TODO_BACKFILL: oai_observed (depends on: T4_execution)>>
- rai_observed: <<TODO_BACKFILL: rai_observed (depends on: T4_execution)>>
- eb_observed: <<TODO_BACKFILL: eb_observed (depends on: T4_execution)>>

## Screenshot

- path: .planning/comms/aq09_smoke_runbook_20260520/screenshots/A2_CMD-15_chat.png

## Outcome

- result: <<TODO_BACKFILL: result (depends on: T4_execution)>>
- justification: <<TODO_BACKFILL: justification (depends on: T4_execution)>>
