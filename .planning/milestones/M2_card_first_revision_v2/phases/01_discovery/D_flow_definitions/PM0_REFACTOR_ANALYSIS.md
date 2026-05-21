# PM0 Refactor Analysis - Track D Batch 3

Agent: CODEX-2-SUB-B
Date: 2026-05-20
Scope: D.13-D.18 PM0 flow definitions extracted from current Dataverse workflow `clientdata`, cross-checked with AQ-07 evidence captured on 2026-05-15.

## Tenant Verification

- Current tenant read route: `pac org fetch --xmlFile` against `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`).
- Direct `pac org fetch --xml` failed with `System.Xml.XmlException`; saved FetchXML was used read-only.
- Current action/trigger/output graph matches AQ-07 evidence for all six flows when runtime authentication representation is ignored.
- Modified timestamps remain in the AQ-07 build window: five flows show `15/05/2026 19:10`; `PM0_PA_Card_ResumoExecutivoPortfolio` shows `15/05/2026 22:31` in PAC and `2026-05-16T01:31:39Z` via `Get-Flow`, equivalent to `2026-05-15T22:31:39-03:00`.
- `Get-FlowRun` returned two successful runs for `PM0_PA_Card_ResumoExecutivoPortfolio` and zero runs for the other five flows in the last 30 days; per-flow run-history JSON files include the retrieval window and counts.

## Dual-Entry / Action Adherence

| Flow | Entry model now | Teams card post | SP write | Planner write | Static return | Refactor estimate |
|---|---|---:|---:|---:|---:|---|
| D.13 `PM0_PA_Card_AtualizarStatus` | single Skills trigger; no explicit preview/submit entry property | True | False | False | True | LARGE (6h+) |
| D.14 `PM0_PA_Card_AtualizarTarefa` | single Skills trigger; no explicit preview/submit entry property | False | True | True | True | MEDIUM (3-4h) |
| D.15 `PM0_PA_Card_CriarTarefa` | single Skills trigger; no explicit preview/submit entry property | False | True | True | True | MEDIUM (3-4h) |
| D.16 `PM0_PA_Card_ListarTarefas` | single Skills trigger; no explicit preview/submit entry property | False | False | False | True | MEDIUM (3-4h) |
| D.17 `PM0_PA_Card_ResumoExecutivoPortfolio` | single Skills trigger; no explicit preview/submit entry property | False | False | False | True | MEDIUM (3-4h) |
| D.18 `PM0_PA_OpsFailureHandling` | single Skills trigger; no explicit preview/submit entry property | False | False | False | True | MEDIUM (3-4h) |

## Per-Flow Notes

### D.13 `PM0_PA_Card_AtualizarStatus`

- Current actions: `Post_Status_Card`, `Respond_Success`.
- Connections used: `shared_teams`.
- Trigger required fields: `routeKey`.
- AQ-07 graph match: `True`; current hash `c0f943d3de1e3f06ed6d3806b5e55c7bf7e6aa24931e3ad56ce56fc856b729f0`.
- Refactor estimate: **LARGE (6h+)** - Hoje apenas posta card placeholder em canal e retorna string; falta branch submit e gravacao SharePoint/Planner conforme operacao final.

### D.14 `PM0_PA_Card_AtualizarTarefa`

- Current actions: `Update_Planner_Task`, `Determine_Bucket_and_Percent`, `Update_SharePoint_Item`, `Respond_Success`, `Get_SharePoint_Item`.
- Connections used: `shared_sharepointonline`, `shared_planner`.
- Trigger required fields: `action`.
- AQ-07 graph match: `True`; current hash `f2d10781acf310f6fc6d013ad0e5127cc90acfd5cc8ad1d2284e35608a332f3c`.
- Refactor estimate: **MEDIUM (3-4h)** - Ja possui caminho submit com SharePoint + Planner, mas precisa branch collect/card, dual-entry e BLK-AT-001 skip semantics.

### D.15 `PM0_PA_Card_CriarTarefa`

- Current actions: `Create_Planner_Task`, `Determine_Bucket_and_Status`, `Create_SharePoint_Item`, `Respond_Success`.
- Connections used: `shared_sharepointonline`, `shared_planner`.
- Trigger required fields: `projectId`, `action`.
- AQ-07 graph match: `True`; current hash `0f373da0fe8f61f317a5261a4c9130ccf0ada065e98d20bb6eef20a97b40ff6f`.
- Refactor estimate: **MEDIUM (3-4h)** - Ja cria Planner + SharePoint; precisa confirmacao card-first, branch collect/submit e completar campos de tarefa.

### D.16 `PM0_PA_Card_ListarTarefas`

- Current actions: `List_Planner_Tasks`, `Respond_Success`, `Normalize_Tasks`, `Get_Tarefas`.
- Connections used: `shared_sharepointonline`, `shared_planner`.
- Trigger required fields: `projectId`, `action`.
- AQ-07 graph match: `True`; current hash `d72f96351cbd0347a92b4517f9207b9f4b683fc31cf8312feb40f426e5e02130`.
- Refactor estimate: **MEDIUM (3-4h)** - Ja le SharePoint/Planner, mas descarta dados no retorno; precisa montar card/result payload util.

### D.17 `PM0_PA_Card_ResumoExecutivoPortfolio`

- Current actions: `Get_Projetos`, `Respond_Success`, `Get_Tarefas`.
- Connections used: `shared_sharepointonline`.
- Trigger required fields: (none).
- AQ-07 graph match: `True`; current hash `983dcd6838d1f0eda81c80894d3bbeb213c7457ebb5358e856f3198a4b095179`.
- Refactor estimate: **MEDIUM (3-4h)** - Ja le Projetos/Tarefas, mas retorna string estatica; precisa agregacao executiva e card de resumo.

### D.18 `PM0_PA_OpsFailureHandling`

- Current actions: `Sanitize_Error`, `Respond_Success`.
- Connections used: (none).
- Trigger required fields: `source`, `code`.
- AQ-07 graph match: `True`; current hash `e18081dbeb628f6bb1a0499f39e997ce85fc5b08ef891d38f8c9c36f8c61a475`.
- Refactor estimate: **MEDIUM (3-4h)** - Sanitizacao existe, porem falta card de erro padronizado, roteamento e contrato de erro reutilizavel.

## Required M2 Refactor Themes

- Add explicit dual-entry contract for write flows: `entry=collect`/preview card and `entry=submit`/write after card click.
- Replace static `result` strings with data-bearing payloads and/or Teams Adaptive Card posts for read/result/error flows.
- Keep existing SharePoint/Planner action graph where it is already valid, but wrap it behind submit-only branches.
- Implement `BLK-AT-001` in `PM0_PA_Card_AtualizarTarefa`: `nao`, `n`, blank, and `0` preserve existing values and display `(mantido)` in confirmation card.
