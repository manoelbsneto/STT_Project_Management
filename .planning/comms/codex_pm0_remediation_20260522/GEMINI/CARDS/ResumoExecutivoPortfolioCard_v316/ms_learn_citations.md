# Microsoft Learn Citations — Adaptive Card Schema 1.5

Last updated: 2026-05-22 20:08:00 BRT | Gemini sub-1 | Documented schema citations for ResumoExecutivoPortfolioCard_v316.

The design of `ResumoExecutivoPortfolioCard_v316` strictly follows Microsoft official documentation for Adaptive Cards Schema 1.5:

1. **Fluent Color Emphases & Borders**
   - **Source:** [Adaptive Cards Container Styling](https://learn.microsoft.com/en-us/adaptive-cards/authoring-cards/card-schema#container)
   - **Access Timestamp:** 2026-05-22 20:08:00 BRT
   - **Details:** Declares `"style": "emphasis"` and `"bleed": true` on layout blocks to create high-contrast margins and visual highlights.

2. **Dynamic Data FactSets**
   - **Source:** [Adaptive Cards FactSet Element](https://learn.microsoft.com/en-us/adaptive-cards/authoring-cards/card-schema#factset)
   - **Access Timestamp:** 2026-05-22 20:08:00 BRT
   - **Details:** Leverages high-density dynamic binding FactSets for portfolio stats (`activeProjects`, `verde`, `amarelo`, `vermelho`, `openTasks`) that automatically render a modern grid of RAG indicator values.
