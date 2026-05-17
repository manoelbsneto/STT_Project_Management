# Route and Output Contract

Date: 2026-05-14
Scope: AQ-05 local planning only
Release decision: NO-SHIP

## Route Keys

| Route key | Purpose | Target currently approved for P0 | Notes |
|---|---|---|---|
| `board.status` | Executive portfolio card | `Projetos_Transformacao_Digital` route | Use owner-approved group/channel IDs only after tenant implementation approval |
| `pmo.ops` | Operational alerts and sanitized failures | Same official channel for P0 | No raw connector errors |
| `pm.status.updates` | PM status review/update card | `QA_Projetos` route | Fallback to official channel only if approved during pilot |
| `task.card.route` | Task list/create/update cards | Direct chat to `mbenicios@minsait.com` | Temporary P0 route |

## Copilot Output Rules

Copilot responses must be:

- static;
- bounded;
- ASCII-only;
- free of raw SharePoint rows;
- free of raw Planner rows;
- free of connector exception payloads;
- free of Planner task IDs and bucket IDs.

## Approved Static Copilot Responses

| Flow | Success response | Failure response |
|---|---|---|
| `PMO_PA_Card_ResumoExecutivoPortfolio` | `Portfolio summary requested. Review the card sent in Teams.` | `Unable to read the data right now.` |
| `PMO_PA_Card_AtualizarStatus` | `Status update received. Review the card sent in Teams.` | `Unable to prepare the status update right now.` |
| `PMO_PA_Card_ListarTarefas` | `Task list request received. Review the card sent in Teams.` | `Unable to list tasks right now.` |
| `PMO_PA_Card_CriarTarefa` | N/A card-submit flow | N/A card-submit flow |
| `PMO_PA_Card_AtualizarTarefa` | N/A card-submit flow | N/A card-submit flow |

## Teams Card Output Rules

Teams cards may include:

- project names;
- bounded project/task summaries;
- RAG/status labels;
- percent complete;
- due date;
- friendly Planner sync label.

Teams cards must not include:

- raw SharePoint JSON;
- raw Planner JSON;
- raw connector errors;
- `PlannerTaskId`;
- `PlannerBucketId`;
- stack traces;
- long unbounded multiline fields.
