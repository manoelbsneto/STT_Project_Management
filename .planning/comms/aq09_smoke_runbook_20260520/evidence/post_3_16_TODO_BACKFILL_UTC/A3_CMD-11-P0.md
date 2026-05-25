# A3_CMD-11-P0 — CriarTarefa

## Metadata

- test_id: A3_CMD-11-P0
- section: A in-scope ship-gate
- executor: <<TODO_BACKFILL: executor_name (depends on: T4_execution)>>
- date_brt: <<TODO_BACKFILL: date_brt (depends on: T4_execution)>>
- build_under_test: 3.16
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

## Chat input

<!-- INPUT BEGIN -->
criar tarefa: projeto=QA Robust 20260513 F, titulo=QA CriarTarefa Smoke 315 20260520, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Media
sim
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
<<TODO_BACKFILL: bot_response_transcript (depends on: T4_execution)>>
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: <<TODO_BACKFILL: run_url_or_id (depends on: T4_execution)>>

## SharePoint side effect

- expected: One new `Tarefas` row with `ProjectID=PRJ-274E5ACC`, `Deleted=false`, title marker `QA CriarTarefa Smoke 315 20260520`
- actual: <<TODO_BACKFILL: actual_sp_side_effect (depends on: T4_execution)>>
- pnp_output_path: <<TODO_BACKFILL: pnp_output_path (depends on: T4_execution)>>

PnP read-back command:
```powershell
Get-PnPListItem -List "Tarefas" -PageSize 100 -Fields "ID","Title","ProjectID","Status","Responsavel","DataFim","Prioridade","HorasEstimadas","Deleted" |
  Where-Object { $_["Title"] -eq "QA CriarTarefa Smoke 315 20260520" } |
  Select-Object Id,@{n="Title";e={$_["Title"]}},@{n="ProjectID";e={$_["ProjectID"]}},@{n="Status";e={$_["Status"]}},@{n="Deleted";e={$_["Deleted"]}}
```

## XPIA marker observation

- cf_observed: <<TODO_BACKFILL: cf_observed (depends on: T4_execution)>>
- oai_observed: <<TODO_BACKFILL: oai_observed (depends on: T4_execution)>>
- rai_observed: <<TODO_BACKFILL: rai_observed (depends on: T4_execution)>>
- eb_observed: <<TODO_BACKFILL: eb_observed (depends on: T4_execution)>>

## Screenshot

- path: .planning/comms/aq09_smoke_runbook_20260520/screenshots/A3_CMD-11-P0_chat.png

## Outcome

- result: <<TODO_BACKFILL: result (depends on: T4_execution)>>
- justification: <<TODO_BACKFILL: justification (depends on: T4_execution)>>
