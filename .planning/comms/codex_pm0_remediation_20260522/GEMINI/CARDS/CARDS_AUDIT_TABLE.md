# PM0 Release 3.16 Adaptive Cards Audit Summary

Last updated: 2026-05-22 20:04:15 BRT | Gemini sub-1 | Completed premium 3.16 card designs audit.

This document consolidates static verification results for the five Adaptive Cards in scope for PM0 release 3.16.

| Card Filename | Path | Schema | Size (Bytes) | Size Gate (< 27KB) | ASCII Safe | Render Status | Dynamic Data Bindings |
|---|---|---|---|---|---|---|---|
| `AtualizarStatusCard_v316.json` | `deploy/cards/` | 1.5 | ~1,600 | PASS | YES | PASS | `projectTitle`, `projectId`, `rag`, `percentual`, `resumo`, `risco`, `bloqueio`, `proximaAcao`, `statusItemId` |
| `AtualizarTarefaCard.json` | `deploy/cards/` | 1.5 | ~3,800 | PASS | YES | PASS | `projectName`, `projectId`, `taskId`, `plannerSyncStatus`, `operationId`, `taskTitle`, `taskStatus`, `responsibleUpn`, `dueDate`, `priority`, `actualHours` |
| `CriarTarefaCard.json` | `deploy/cards/` | 1.5 | ~3,500 | PASS | YES | PASS | `projectName`, `projectId`, `plannerMappingStatus`, `operationId` (inputs: `taskTitle`, `taskDescription`, `responsibleUpn`, `dueDate`, `priority`, `plannerBucketName`, `estimatedHours`) |
| `ListarTarefasCard_v316.json` | `deploy/cards/` | 1.5 | ~1,700 | PASS | YES | PASS | `projectTitle`, `projectId`, `taskCount`, `taskLines` |
| `ResumoExecutivoPortfolioCard_v316.json` | `deploy/cards/` | 1.5 | ~1,800 | PASS | YES | PASS | `activeProjects`, `verde`, `amarelo`, `vermelho`, `openTasks` |

## Size Verification

All cards are significantly below the strict **27 KB** (27,648 bytes) buffer limit, minimizing incoming webhook and bot message transaction payloads in Teams.

## Encoding Verification

All application-facing strings, input fields, labels, placeholders, and error messages are written in plain, 100% standard ASCII characters. Accentuation and cedilla signs are excluded to prevent rendering failures or character corruption on mobile endpoints.

## Visual Design Improvements
- **Harmonious Accents**: Standardized on Microsoft Fluent accent colors (e.g. `Accent`, `Warning`, `Good`, `Attention`) to create premium, harmonized color systems rather than raw/plain defaults.
- **Grids and ColumnSets**: Replaced basic linear listings with two-column and three-column visual blocks for quick data ingestion (e.g. status metrics side-by-side).
- **Stylized Containers**: Titles and contexts are placed inside `emphasis`-styled containers with bleed-enabled layout structures to look like cohesive and polished, top-tier widgets inside Teams.
