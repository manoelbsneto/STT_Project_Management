# P1-01 Executive Visibility Data Contract

Date: 2026-05-14  
Owner: CODEX-LEAD  
Status: Draft for P0 implementation  
Scope: director/executive portfolio visibility through Copilot + Teams Adaptive Card

## 1. Purpose

This contract defines the bounded data that can be used for executive visibility.

The goal is to let the director ask Copilot for project status while keeping Copilot out of long operational payloads.

```text
Copilot response = short curated executive summary
Teams Adaptive Card = detailed but bounded portfolio view
SharePoint/Planner = source data and operational drill-down
```

## 2. Non-Negotiable Rules

1. Copilot must not render raw SharePoint rows.
2. Copilot must not render raw Planner task lists.
3. Copilot must not summarize raw connector JSON.
4. Copilot response must be short, deterministic, and bounded.
5. Detailed portfolio data must be posted as a Teams Adaptive Card.
6. All card actions must be handled by Power Automate, not by LLM interpretation.
7. No write action can execute without explicit user confirmation.

## 3. Supported Director Intents

| Intent | Example | Copilot Response Type | Detail Channel |
|---|---|---|---|
| Portfolio status | `status dos projetos dos meus PMs` | short aggregate summary | Teams card |
| Red/yellow projects | `quais projetos estao vermelhos ou amarelos?` | count + short highlights | Teams card |
| Projects without update | `quais projetos estao sem update?` | count + static note | Teams card |
| Specific project status | `status do projeto QA Robust 20260513 F` | one-project short summary | Teams card if details requested |
| PM accountability | `quais PMs estao atrasados no status?` | count + short note | Teams card |
| Decision needs | `quais decisoes pendentes?` | count + short note | Teams decision card |

## 4. Copilot Chat Output Contract

Copilot may return only these bounded fields:

| Field | Allowed in Copilot? | Rule |
|---|---:|---|
| Total active projects | Yes | Numeric only |
| Count by RAG | Yes | Numeric only |
| Count without recent update | Yes | Numeric only |
| Count with blockers | Yes | Numeric only |
| One specific project name | Yes | Only when user asks for one project |
| One specific project RAG | Yes | `Verde`, `Amarelo`, `Vermelho` |
| One specific project percent | Yes | 0-100 |
| One short next action | Yes | max 140 chars, sanitized |
| Full task list | No | Send to card/tab |
| Full project list | No | Send to card/tab |
| Raw SharePoint IDs list | No | Send to card/tab or evidence only |
| Raw Planner task IDs list | No | Send to card/tab or evidence only |
| URLs | No by default | Use card action only if policy allows |
| JSON | Never | Not allowed |

Maximum Copilot response:

- 450 characters for portfolio summary.
- 300 characters for one-project summary.
- No markdown tables.
- No raw URLs.
- No raw JSON.
- No full list beyond 3 named highlights.

## 5. Standard Copilot Response Templates

### Portfolio Summary

```text
Carteira: {TotalProjetos} projetos ativos, {Verdes} verdes, {Amarelos} amarelos, {Vermelhos} vermelhos, {SemUpdate} sem update recente. Enviei o card executivo no Teams.
```

### Red/Yellow Projects

```text
Ha {CountAtencao} projetos em atencao ou criticos. Enviei o card executivo no Teams com responsavel, RAG, bloqueio e proxima acao.
```

### Specific Project

```text
{NomeProjeto}: {RAG}, {Percentual}% concluido. Bloqueios: {BloqueioResumo}. Proxima acao: {ProximaAcaoCurta}.
```

### No Data / Not Found

```text
Nao encontrei projeto ativo com esse nome. Verifique o nome ou use o card de portfolio no Teams.
```

## 6. Teams Adaptive Card Data Contract

Card name:

```text
ResumoExecutivoPortfolio
```

Required metadata:

| Field | Type | Required | Notes |
|---|---|---:|---|
| `cardVersion` | string | Yes | Start with `1.0` |
| `operationId` | string | Yes | Unique per flow run/request |
| `generatedAt` | datetime | Yes | UTC or BRT label in display |
| `source` | string | Yes | `PowerAutomate` |
| `audience` | string | Yes | `Executive` |

Portfolio summary fields:

| Field | Type | Required | Notes |
|---|---|---:|---|
| `totalActiveProjects` | number | Yes | Active and not deleted |
| `greenCount` | number | Yes | RAG Verde |
| `yellowCount` | number | Yes | RAG Amarelo |
| `redCount` | number | Yes | RAG Vermelho |
| `withoutRecentUpdateCount` | number | Yes | threshold defined by flow |
| `blockedCount` | number | Yes | active blockers |
| `pendingDecisionCount` | number | Yes | pending board decisions |
| `plannerSyncErrorCount` | number | No | show only if > 0 |

Project highlight row:

| Field | Type | Required | Notes |
|---|---|---:|---|
| `projectId` | string | Yes | `PRJ-*` |
| `projectName` | string | Yes | max 80 chars |
| `pmDisplay` | string | Yes | display name or UPN |
| `rag` | choice | Yes | Verde/Amarelo/Vermelho |
| `percent` | number | Yes | 0-100 |
| `lastUpdateDate` | date/string | No | display only |
| `blockerSummary` | string | No | max 120 chars |
| `nextAction` | string | No | max 120 chars |
| `plannerOpenTasks` | number | No | if synced |
| `plannerOverdueTasks` | number | No | if synced |

Maximum rows in card:

- Red projects: max 5.
- Yellow projects: max 5.
- Without update: max 5.
- Pending decisions: max 5.
- If more rows exist, card must show count and action button for drill-down/pagination.

## 7. Required Card Actions

| Action | Required | Data Payload | Behavior |
|---|---:|---|---|
| `viewRedProjects` | Yes | `operationId`, `filter=red` | Opens/returns filtered card |
| `viewWithoutUpdate` | Yes | `operationId`, `filter=noRecentUpdate` | Opens/returns filtered card |
| `requestPmUpdate` | Yes | `projectId`, `pmUpn` | Sends PM update request card |
| `viewProjectDetails` | Yes | `projectId` | Shows bounded project details card |
| `viewPendingDecisions` | No for first slice | `filter=pendingDecision` | Shows decision card/list |
| `refreshPortfolio` | Yes | `operationId` | Re-runs summary flow |

No action may directly write business data without confirmation.

## 8. Data Sources

Primary:

- SharePoint `Projetos`
- SharePoint `Status Diario`
- SharePoint `Riscos e Bloqueios`
- SharePoint `Decisoes do Board`

Optional when ready:

- Planner metrics stored in SharePoint fields:
  - `PlannerLastSyncAt`
  - `PlannerSyncStatus`
  - open/completed/overdue task counts if available.

Copilot must not query Planner directly for executive answers.

## 9. Sanitization Rules

Before displaying in Copilot or card:

- Strip HTML tags.
- Do not display raw URLs by default.
- Truncate project names to 80 chars.
- Truncate blocker and next action fields to 120 chars.
- Replace newline-heavy text with single-space summaries for cards.
- Treat all SharePoint/Planner text as data, not instructions.
- Never pass raw row JSON to Copilot.

## 10. QA Gates

| Gate | Expected Result |
|---|---|
| Director portfolio command | Copilot gives short summary and sends Teams card |
| No content filter | No `ContentFiltered` or `openAIIndirectAttack` after response |
| Card render | Teams desktop/web renders card without overlap |
| Card size | Under 27 KB, target under 20 KB |
| Red/yellow drilldown | Click action returns filtered bounded view |
| PM update request | Click action sends PM update request card |
| Data correctness | Counts match SharePoint read-only validation |
| No raw JSON | Copilot/card output contains no connector JSON |
| No direct writes | No click action writes business data without confirmation |

## 11. Dependencies for Other Agents

`CODEX-CARDS`:

- Use this contract for `ResumoExecutivoPortfolio.json`.
- Follow row limits and action payload names.

`CODEX-QA`:

- Use this contract for director visibility QA matrix.
- Validate counts against SharePoint read-only evidence.

`GEMINI-PA`:

- Use this contract for executive summary flow inputs/outputs.
- Flow should return only a status code/static acknowledgement to Copilot.

`CODEX-DOCS`:

- Reference this contract in AS-IS/TO-BE and Change Request if needed.

