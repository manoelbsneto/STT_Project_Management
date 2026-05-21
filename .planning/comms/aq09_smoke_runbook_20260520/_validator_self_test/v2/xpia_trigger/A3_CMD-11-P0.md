# A3_CMD-11-P0 — CriarTarefa Positive

## Metadata

- test_id: A3_CMD-11-P0
- section: A in-scope ship-gate
- executor: CODEX-QA synthetic fixture
- date_brt: 2026-05-21T01:20:00-03:00
- build_under_test: 3.15
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

## Chat input

<!-- INPUT BEGIN -->
criar tarefa: projeto=QA Robust 20260513 F, titulo=QA CriarTarefa Smoke 315 20260520, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Media
sim
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
Tarefa criada com sucesso. ID 101.
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: synthetic-run-A3

## SharePoint side effect

- expected: One Tarefas row created.
- actual: Synthetic row ID 101 with Deleted false.
- pnp_output_path: N/A

## XPIA marker observation

- cf_observed: no
- oai_observed: no
- rai_observed: no
- eb_observed: no

## Screenshot

- path: .planning/comms/aq09_smoke_runbook_20260520/screenshots/A3_CMD-11-P0_chat.png

## Outcome

- result: PASS
- justification: Synthetic clean transcript in mixed trigger fixture.
