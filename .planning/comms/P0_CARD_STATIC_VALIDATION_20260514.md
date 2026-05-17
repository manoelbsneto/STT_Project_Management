# P0 Card Static Validation

Date: 2026-05-14
Owner: CODEX-LEAD
Scope: local validation only; no tenant access

## Result

PASS for the first local card skeleton validation.

## Checks

| Card | Bytes | Under 20 KB | Adaptive Card Version | ASCII Only | Submit Actions | Missing Required Metadata |
|---|---:|---:|---|---:|---:|---|
| `deploy/cards/ResumoExecutivoPortfolio.json` | 3676 | Yes | 1.4 | Yes | 5 | None |
| `deploy/cards/AtualizarStatusCard.json` | 2811 | Yes | 1.4 | Yes | 2 | None |
| `deploy/cards/AtualizarStatusSingleBoxReviewCard.json` | 3230 | Yes | 1.4 | Yes | 3 | None |
| `deploy/cards/ListarTarefasProjetoCard.json` | 3463 | Yes | 1.4 | Yes | 5 | None |
| `deploy/cards/CriarTarefaCard.json` | 3105 | Yes | 1.4 | Yes | 2 | None |
| `deploy/cards/AtualizarTarefaCard.json` | 3758 | Yes | 1.4 | Yes | 3 | None |

## Required Action Metadata

Every `Action.Submit.data` was checked for:

- `action`
- `routeKey`
- `operationId`
- `cardVersion`
- `source`

No missing metadata was found.

## Command Summary

Validation was run locally with PowerShell:

```powershell
ConvertFrom-Json -Depth 100
ASCII character scan
file size check
recursive Action.Submit metadata scan
```

## Notes

- This validation proves local JSON shape and metadata only.
- Teams rendering still requires runtime evidence.
- Flow binding still requires implementation and owner-approved tenant execution.
