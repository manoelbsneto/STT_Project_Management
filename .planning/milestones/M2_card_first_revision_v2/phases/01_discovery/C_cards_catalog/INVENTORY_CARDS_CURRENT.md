# M2 Cards Catalog - Master Inventory

## Overview
This document serves as the master inventory for the M2 Adaptive Cards catalog. It merges the analysis of existing cards from `deploy/cards/` with the target requirements for the M2 milestone.

## Statistics
- **Total Existing Cards Discovered**: 12
- **Total M2 Target Cards**: 23
- **Total New Cards to Build**: 16
- **Total Existing Cards to Refactor**: 7
- **Total Cards to Deprecate**: 5

## Action Plan

### Cards to Build (NEW)
1. CriarProjetoConfirmCard
2. ExcluirProjetoConfirmCard
3. ExcluirTarefaConfirmCard
4. RegistrarRiscoConfirmCard
5. RegistrarBloqueioConfirmCard
6. PedirDecisaoConfirmCard
7. ConsultarPortfolioCard
8. ConsultarProjetoCard
9. OpsFailureCard
10. CriarProjetoBroadcastCard
11. ExcluirProjetoBroadcastCard
12. CriarTarefaBroadcastCard
13. AtualizarTarefaBroadcastCard
14. ExcluirTarefaBroadcastCard
15. AtualizarStatusBroadcastCard
16. RegistrarBloqueioBroadcastCard

### Cards to Update (REFACTOR)
1. CriarTarefaConfirmCard (`deploy/cards/CriarTarefaCard.json`)
2. AtualizarTarefaConfirmCard (`deploy/cards/AtualizarTarefaCard.json`)
3. AtualizarStatusConfirmCard (`deploy/cards/AtualizarStatusSingleBoxReviewCard.json`)
4. ListarTarefasCard (`deploy/cards/ListarTarefasProjetoCard.json`)
5. ResumoExecutivoPortfolio (`deploy/cards/ResumoExecutivoPortfolio.json`)
6. RegistrarRiscoBroadcastCard (`deploy/cards/EscalacaoRisco.json`)
7. PedirDecisaoApproverCard (`deploy/cards/DecisaoBoard.json`)

### Cards to Deprecate
These existing cards do not map directly to an M2 requirement or have been superseded by new target patterns.
1. AlertaCritico (`deploy/cards/AlertaCritico.json`)
2. CheckInDiario (`deploy/cards/CheckInDiario.json`)
3. ResumoDiarioBoard (`deploy/cards/ResumoDiarioBoard.json`)
4. ResumoSemanal (`deploy/cards/ResumoSemanal.json`)
5. AtualizarStatusCard (`deploy/cards/AtualizarStatusCard.json` - Replaced by single box review card/broadcast pattern)
