# A2_CMD-15 — ConsultarPortfolio Positive

## Metadata

- test_id: A2_CMD-15
- section: A in-scope ship-gate
- executor: CODEX-QA synthetic fixture
- date_brt: 2026-05-21T01:20:00-03:00
- build_under_test: 3.15
- bot: Assistente PMO V2
- environment: ColOfertasBrasilPro

## Chat input

<!-- INPUT BEGIN -->
consultar portfolio
<!-- INPUT END -->

## Bot response transcript

<!-- TRANSCRIPT BEGIN -->
Portfolio: 3 projetos ativos. Verde: 2. Amarelo: 1. Vermelho: 0.
<!-- TRANSCRIPT END -->

## Power Automate run

- run_url_or_id: N/A

## SharePoint side effect

- expected: No write side effect.
- actual: Synthetic portfolio counts returned.
- pnp_output_path: N/A

## XPIA marker observation

- cf_observed: no
- oai_observed: no
- rai_observed: no
- eb_observed: no

## Screenshot

- path: .planning/comms/aq09_smoke_runbook_20260520/screenshots/A2_CMD-15_chat.png

## Outcome

- result: PASS
- justification: Synthetic clean transcript in mixed trigger fixture.
