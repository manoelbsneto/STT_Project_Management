# B5_PedirDecisao — PedirDecisao InvalidUPN

## Metadata

- test_id: B5_PedirDecisao
- section: B legacy debt evidence
- executor: Manoel Benicio
- date_brt: 2026-05-21T14:25:52-03:00
- build_under_test: 3.15
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

<!-- prepop:auto -->

## Chat input

<!-- INPUT BEGIN -->
pedir decisao: projeto=QA Robust 20260513 F, descricao=Validar publish regex 3.4 negativo, impacto=Alto, prazo=30/06/2026, aprovador=UPN ?
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: N/A
<!-- prepop:run_lookup flow run lookup skipped by -SkipFlowRunLookup -->

## SharePoint side effect

- expected: No row created in Decisoes do Board for the invalid UPN path.
- actual: N/A - Track G side-effect report has no tests.B5_PedirDecisao observation.
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
