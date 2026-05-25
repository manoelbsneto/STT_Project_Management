# A5_CMD-10 — AtualizarStatus

## Metadata

- test_id: A5_CMD-10
- section: A in-scope ship-gate
- executor: <<TODO_BACKFILL: executor_name (depends on: T4_execution)>>
- date_brt: <<TODO_BACKFILL: date_brt (depends on: T4_execution)>>
- build_under_test: 3.16
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

## Chat input

<!-- INPUT BEGIN -->
atualizar status: projeto=QA Robust 20260513 F, status=Amarelo, resumo=Smoke 3.15 multilinha, percentual=45, risco=Nenhum, bloqueio=Nenhum, proxima acao=Revisar
sim
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
<<TODO_BACKFILL: bot_response_transcript (depends on: T4_execution)>>
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: <<TODO_BACKFILL: run_url_or_id (depends on: T4_execution)>>

## SharePoint side effect

- expected: One `Status Diario` row created with structured fields populated.
- actual: <<TODO_BACKFILL: actual_sp_side_effect (depends on: T4_execution)>>
- pnp_output_path: <<TODO_BACKFILL: pnp_output_path (depends on: T4_execution)>>

PnP read-back command:
```powershell
Get-PnPListItem -List "Status Diario" -PageSize 100 -Fields "ID","StatusID","ProjectID","RAG","Resumo","Percentual","Risco","Bloqueio","ProximaAcao","Deleted","Created" |
  Where-Object { $_["ProjectID"] -eq "PRJ-274E5ACC" -and $_["Resumo"] -like "*Smoke 3.15 multilinha*" } |
  Sort-Object { $_["Created"] } -Descending |
  Select-Object -First 3 Id,@{n="StatusID";e={$_["StatusID"]}},@{n="RAG";e={$_["RAG"]}},@{n="Resumo";e={$_["Resumo"]}},@{n="Percentual";e={$_["Percentual"]}},@{n="Deleted";e={$_["Deleted"]}}
```

## XPIA marker observation

- cf_observed: <<TODO_BACKFILL: cf_observed (depends on: T4_execution)>>
- oai_observed: <<TODO_BACKFILL: oai_observed (depends on: T4_execution)>>
- rai_observed: <<TODO_BACKFILL: rai_observed (depends on: T4_execution)>>
- eb_observed: <<TODO_BACKFILL: eb_observed (depends on: T4_execution)>>

## Screenshot

- path: .planning/comms/aq09_smoke_runbook_20260520/screenshots/A5_CMD-10_chat.png

## Outcome

- result: <<TODO_BACKFILL: result (depends on: T4_execution)>>
- justification: <<TODO_BACKFILL: justification (depends on: T4_execution)>>
