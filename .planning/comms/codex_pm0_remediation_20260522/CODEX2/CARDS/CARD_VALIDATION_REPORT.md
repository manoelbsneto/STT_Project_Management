Last updated: 2026-05-22 16:50:19 BRT | Codex sub-2C | PM0 Adaptive Card JSON validation and size measurement completed

# PM0 Card Validation Report

## Scope

Validated deploy card JSON files relevant to PM0 flows using local structural checks:

- JSON parse succeeds
- `type` is `AdaptiveCard`
- `version` is present and not greater than `1.5`
- card body exists
- UTF-8 size is less than the project guardrail of 27 KB
- no non-ASCII characters

Microsoft Learn citation source: `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md`, Entry 09.

Relevant Learn URLs accessed by B2 at `2026-05-22T15:26:11-03:00 BRT`:

- https://learn.microsoft.com/en-us/microsoft-copilot-studio/adaptive-cards-overview
- https://learn.microsoft.com/en-us/connectors/teams/
- https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-format

## Results

| Card | Status | Size bytes | Version | Non-ASCII |
|---|---:|---:|---:|---:|
| `deploy/cards/AtualizarStatusCard.json` | `PASS_LOCAL_STRUCTURAL` | 2811 | 1.4 | 0 |
| `deploy/cards/AtualizarTarefaCard.json` | `PASS_LOCAL_STRUCTURAL` | 3679 | 1.4 | 0 |
| `deploy/cards/CriarTarefaCard.json` | `PASS_LOCAL_STRUCTURAL` | 3342 | 1.4 | 0 |
| `deploy/cards/ListarTarefasProjetoCard.json` | `PASS_LOCAL_STRUCTURAL` | 3463 | 1.4 | 0 |
| `deploy/cards/ResumoExecutivoPortfolio.json` | `PASS_LOCAL_STRUCTURAL` | 3676 | 1.4 | 0 |

All existing PM0 card files are below 27 KB and at or below Teams/Copilot Adaptive Cards 1.5.

## Missing v3.16-Named Card Files

The mission spec referenced these new v3.16 files, but they are not currently present in `deploy/cards/`:

| Expected file | Status |
|---|---|
| `deploy/cards/AtualizarStatusCard_v316.json` | `MISSING` |
| `deploy/cards/ListarTarefasCard_v316.json` | `MISSING` |
| `deploy/cards/ResumoExecutivoPortfolioCard_v316.json` | `MISSING` |

This does not fail the existing card JSON files, but it is a packaging/readiness gap if the 3.16 package is expected to include these exact filenames.

## Evidence

| Evidence | Path |
|---|---|
| Structured card validation JSON | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/CARDS/card_validation_results.json` |
| Rendered CLI output | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/CARDS/card_validation_results.png` |
| Text output | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/CARDS/evidence/` |

## Limitations

This was a local structural validation. It did not perform live Adaptive Cards Designer rendering or Teams runtime rendering because this subtask did not include browser/UI execution.
