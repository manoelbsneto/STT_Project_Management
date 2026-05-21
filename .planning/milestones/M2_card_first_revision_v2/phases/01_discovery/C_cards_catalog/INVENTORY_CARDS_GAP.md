# C.3 Gap Analysis vs M2 Requirements

## Overview
This document contains the gap analysis for M2 target cards based on requirements REQ-M2-02, REQ-M2-03, REQ-M2-04, and ADR-M2-001 variants.

### Base Cards

| Card name | Existing | Path | Action |
|---|---|---|---|
| CriarProjetoConfirmCard | NO | — | NEW |
| ExcluirProjetoConfirmCard | NO | — | NEW |
| CriarTarefaConfirmCard | YES (partial) | `deploy/cards/CriarTarefaCard.json` | REFACTOR |
| AtualizarTarefaConfirmCard | YES | `deploy/cards/AtualizarTarefaCard.json` | REFACTOR |
| ExcluirTarefaConfirmCard | NO | — | NEW |
| AtualizarStatusConfirmCard | YES | `deploy/cards/AtualizarStatusSingleBoxReviewCard.json` | REFACTOR |
| RegistrarRiscoConfirmCard | NO | — | NEW |
| RegistrarBloqueioConfirmCard | NO | — | NEW |
| PedirDecisaoConfirmCard | NO | — | NEW |
| ConsultarPortfolioCard | NO | — | NEW |
| ConsultarProjetoCard | NO | — | NEW |
| ListarTarefasCard | YES | `deploy/cards/ListarTarefasProjetoCard.json` | REFACTOR |
| ResumoExecutivoPortfolio | YES | `deploy/cards/ResumoExecutivoPortfolio.json` | REFACTOR |
| OpsFailureCard | NO | — | NEW |

### Broadcast Cards (ADR-M2-001)

| Card name | Existing | Path | Action |
|---|---|---|---|
| CriarProjetoBroadcastCard | NO | — | NEW |
| ExcluirProjetoBroadcastCard | NO | — | NEW |
| CriarTarefaBroadcastCard | NO | — | NEW |
| AtualizarTarefaBroadcastCard | NO | — | NEW |
| ExcluirTarefaBroadcastCard | NO | — | NEW |
| AtualizarStatusBroadcastCard | NO | — | NEW |
| RegistrarRiscoBroadcastCard | YES | `deploy/cards/EscalacaoRisco.json` | REFACTOR |
| RegistrarBloqueioBroadcastCard | NO | — | NEW |
| PedirDecisaoApproverCard | YES | `deploy/cards/DecisaoBoard.json` | REFACTOR |
