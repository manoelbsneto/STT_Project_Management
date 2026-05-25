# A4_CMD-13A — AtualizarTarefa

## Metadata

- test_id: A4_CMD-13A
- section: A in-scope ship-gate
- executor: <<TODO_BACKFILL: executor_name (depends on: T4_execution)>>
- date_brt: <<TODO_BACKFILL: date_brt (depends on: T4_execution)>>
- build_under_test: 3.16
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

## Chat input

<!-- INPUT BEGIN -->
atualizar tarefa
15, em andamento, 2, nao, nao, nao, sim
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
<<TODO_BACKFILL: bot_response_transcript (depends on: T4_execution)>>
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: <<TODO_BACKFILL: run_url_or_id (depends on: T4_execution)>>

## SharePoint side effect

- expected: Task `15` preserves `Responsavel`, `DataFim`, and `Prioridade`; updates status/hours only as intended.
- actual: <<TODO_BACKFILL: actual_sp_side_effect (depends on: T4_execution)>>
- pnp_output_path: <<TODO_BACKFILL: pnp_output_path (depends on: T4_execution)>>

PnP read-back command:
```powershell
Get-PnPListItem -List "Tarefas" -Id 15 -Fields "ID","Title","ProjectID","Status","Responsavel","DataFim","Prioridade","HorasRealizadas","Deleted" |
  Select-Object Id,@{n="Title";e={$_["Title"]}},@{n="Status";e={$_["Status"]}},@{n="Responsavel";e={$_["Responsavel"]}},@{n="DataFim";e={$_["DataFim"]}},@{n="Prioridade";e={$_["Prioridade"]}},@{n="HorasRealizadas";e={$_["HorasRealizadas"]}},@{n="Deleted";e={$_["Deleted"]}}
```

## XPIA marker observation

- cf_observed: <<TODO_BACKFILL: cf_observed (depends on: T4_execution)>>
- oai_observed: <<TODO_BACKFILL: oai_observed (depends on: T4_execution)>>
- rai_observed: <<TODO_BACKFILL: rai_observed (depends on: T4_execution)>>
- eb_observed: <<TODO_BACKFILL: eb_observed (depends on: T4_execution)>>

## Screenshot

- path: .planning/comms/aq09_smoke_runbook_20260520/screenshots/A4_CMD-13A_chat.png

## Outcome

- result: <<TODO_BACKFILL: result (depends on: T4_execution)>>
- justification: <<TODO_BACKFILL: justification (depends on: T4_execution)>>
