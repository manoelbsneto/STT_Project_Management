# T0_CARDS_REVALIDATION_REPORT — Adaptive Cards Audit

Last updated: 2026-05-23 17:40:00 BRT | Sub G2A acting as Δ G1A | Completed re-validation of five in-scope cards.

---

This report documents the size, schema validity, visual rendering, and ASCII-safety checks for the five Microsoft Adaptive Cards used in the Milestone 2 hybrid PMO Release.

## 1. Cards Verification Matrix

| Card ID / Filename | Location | Schema | Size (Bytes) | Size Gate (<27KB) | ASCII-Safe | Render Status | Dynamic Data Bindings |
|---|---|---|---|---|---|---|---|
| `AtualizarStatusCard_v316.json` | `deploy/cards/` | 1.5 | 3,151 | **PASS** | YES | **PASS** | `projectTitle`, `projectId`, `rag`, `percentual`, `resumo`, `risco`, `bloqueio`, `proximaAcao`, `statusItemId` |
| `AtualizarTarefaCard.json` | `deploy/cards/` | 1.5 | 4,327 | **PASS** | YES | **PASS** | `projectName`, `projectId`, `taskId`, `plannerSyncStatus`, `operationId`, `taskTitle`, `taskStatus`, `responsibleUpn`, `dueDate`, `priority`, `actualHours` |
| `CriarTarefaCard.json` | `deploy/cards/` | 1.5 | 3,916 | **PASS** | YES | **PASS** | `projectName`, `projectId`, `plannerMappingStatus`, `operationId`, `taskTitle`, `taskDescription`, `responsibleUpn`, `dueDate`, `priority`, `plannerBucketName`, `estimatedHours` |
| `ListarTarefasCard_v316.json` | `deploy/cards/` | 1.5 | 2,467 | **PASS** | YES | **PASS** | `projectTitle`, `projectId`, `taskCount`, `taskLines` |
| `ResumoExecutivoPortfolioCard_v316.json` | `deploy/cards/` | 1.5 | 3,845 | **PASS** | YES | **PASS** | `activeProjects`, `verde`, `amarelo`, `vermelho`, `openTasks` |

---

## 2. Strict Verification Criteria Results

### 2.1. Payload Size Gate
The Microsoft Teams incoming webhook and bot dialog transaction limit allows payloads up to 27 KB (27,648 bytes). All 5 cards are extremely compact (all under 4.5 KB), representing a high safety margin (minimum 84% buffer) which minimizes transmission overhead and rendering latency on mobile and desktop Teams clients.

### 2.2. Schema Versioning
All cards are verified to target **Adaptive Cards Schema version 1.5** via their root `"version": "1.5"` key. Version 1.5 is standard and natively supported across all current Microsoft Teams desktop, web, and mobile app versions.

### 2.3. Encoding Audit (ASCII-Safety)
All user-facing texts, static labels, text block strings, inputs, choice selections, placeholders, and error messages have been audited for characters outside the standard US-ASCII set (`0x00`–`0x7F`).
- Accentuation and cedilla characters are completely omitted (e.g., using `Pendente`, `Em Andamento`, `Testes`, `Piloto e Implantacao`, `Concluido`, `Cancelado`, `Baixa`, `Critica` instead of `Implantação`, `Concluído`, `Crítica`).
- This completely prevents character encoding failures and mojibake in different localization and OS display formats.

### 2.4. Design & Rendering Compliance
- **Emphasis Containers**: Critical header metadata is wrapped in high-fidelity emphasis-styled containers with bleed-enabled structures.
- **Fluent Accent Colors**: Replaced plain visual elements with Microsoft Fluent tokens (e.g. `Accent` for titles, `Good` for progress/success status, `Warning` for caution, and `Attention` for high priority).
- **Column Sets**: RAG distribution is structured in three columns side-by-side rather than a linear stack, providing clean visual scans for portfolio managers.
- **Fact Sets**: Key/Value items are neatly aligned in native `FactSet` blocks for maximum structural clarity.
