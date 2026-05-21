# Topic Remediation 2026-05-20 — TO-BE Patched Versions

This folder receives the **patched** YAML produced by Opus 4.7 with the binding changed from `PMO_PA_*` (legacy) to `PM0_PA_Card_*` (new).

Files expected:
- `AtualizarStatus.to_be.yaml`
- `AtualizarTarefa.to_be.yaml`
- `ConsultarPortfolio.to_be.yaml`
- `CriarTarefa.to_be.yaml`
- `ListarTarefas.to_be.yaml`

Owner copies the content of each `.to_be.yaml` and pastes it into the Copilot Studio Code Editor of the corresponding topic, then clicks **Save** (do not Publish yet).

Reference: `.planning/architecture/ADR_AQ08_HYBRID_CARD_FIRST_MIGRATION_20260520.md` §2.1
