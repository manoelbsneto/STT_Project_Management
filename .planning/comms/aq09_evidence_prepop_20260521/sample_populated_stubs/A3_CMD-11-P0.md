# A3_CMD-11-P0 — CriarTarefa

## Metadata

- test_id: A3_CMD-11-P0
- section: A in-scope ship-gate
- executor: Manoel Benicio
- date_brt: 2026-05-21T14:25:52-03:00
- build_under_test: 3.15
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

<!-- prepop:auto -->

## Chat input

<!-- INPUT BEGIN -->
criar tarefa: projeto=QA Robust 20260513 F, titulo=QA CriarTarefa Smoke 315 20260520, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Media
sim
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: N/A
<!-- prepop:run_lookup flow run lookup skipped by -SkipFlowRunLookup -->

## SharePoint side effect

- expected: One new Tarefas row with ProjectID=PRJ-274E5ACC, Deleted=false, title marker QA CriarTarefa Smoke 315 20260520.
- actual: Track G tests.A3_CMD-11-P0 status=NO_DATA; details=No CriarTarefa smoke row matched in the supplied window.
- pnp_output_path: .planning\comms\aq09_sp_side_effects_harness_20260521\sample_outputs\aq09_sp_side_effects_report.json

## XPIA marker observation

- cf_observed: yes | no
- oai_observed: yes | no
- rai_observed: yes | no
- eb_observed: yes | no

## Screenshot

- path: <relative path under .planning/comms/aq09_smoke_runbook_20260520/screenshots/...>

## Outcome

- result: PASS | FAIL | NOT_RUN
- justification: <one line>
