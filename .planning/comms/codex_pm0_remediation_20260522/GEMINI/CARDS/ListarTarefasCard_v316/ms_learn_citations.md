# Microsoft Learn Citations — Adaptive Card Schema 1.5

Last updated: 2026-05-22 20:08:00 BRT | Gemini sub-1 | Documented schema citations for ListarTarefasCard_v316.

The design of `ListarTarefasCard_v316` strictly follows Microsoft official documentation for Adaptive Cards Schema 1.5:

1. **TextBlock Text Wrapping and Styling**
   - **Source:** [Adaptive Cards TextBlock Element](https://learn.microsoft.com/en-us/adaptive-cards/authoring-cards/card-schema#textblock)
   - **Access Timestamp:** 2026-05-22 20:08:00 BRT
   - **Details:** TextBlocks use `"wrap": true` and appropriate visual weights (`"weight": "Bolder"`, `"size": "Medium"`) to display project information and a clean monospace listing of tasks without overflow.

2. **Dynamic Binding Arrays**
   - **Source:** [Adaptive Cards Templating SDK](https://learn.microsoft.com/en-us/adaptive-cards/templating/)
   - **Access Timestamp:** 2026-05-22 20:08:00 BRT
   - **Details:** Declares standard placeholders like `${taskCount}` and `${taskLines}` to receive dynamically computed lists of project tasks on execution.
