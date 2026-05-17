# Project Skills Map

**Status:** Active for PMO 2.4 planning and execution.
**Scope:** Local skill files under `skills/`; no PROD action is authorized by this document.

## Mandatory Skills For Phase 2.4

| Skill | Path | Applies to | Required gate |
|---|---|---|---|
| Copilot Studio Agent Audit | `skills/super/SKILL_COPILOT_STUDIO_AGENT.md` | Copilot topics, trigger phrases, actions, inputs/outputs, fallback, runtime wording | Every topic must list trigger intent, action called, inputs passed, outputs consumed, failure risks, fix, and test scenario. |
| Power Automate Expression Troubleshooting | `skills/super/SKILL_POWER_AUTOMATE_EXPRESSIONS.md` | Cloud Flow expressions, Parse JSON, dates, null/empty/type handling | Every expression fix must identify runtime surface, root cause, corrected expression, edge cases, and validation method. |
| SharePoint Schema and Data Layer Audit | `skills/super/SKILL_SHAREPOINT_SCHEMA.md` | `Projetos`, `Tarefas`, filters, internal names, data types, permissions | Every SharePoint reference must name site/list/column/internal name/type/evidence and filter correctness. |
| Software UI/UX Design | `skills/data_expert_skills/software-ui-ux-design.md` | Adaptive Card form/review/confirmation UX | Cards must prevent errors before submit, show clear states, preserve accessibility, and use one primary action per view. |
| Senior UI/UX Designer - Executive Data Products | `skills/data_expert_skills/senior-uiux-data-products.md` | PMO review cards and executive summaries | Cards must be scannable, low cognitive load, status-aware, and use color plus text/icon where status matters. |

## Supporting Skill Families

| Folder | Role |
|---|---|
| `skills/super` | Project-critical Copilot Studio, Power Automate, and SharePoint audit rules. |
| `skills/data_expert_skills` | UX, dashboard, visualization, layout, accessibility, responsive design, and design-system guidance. |

## Phase 2.4 Application

- `CriarProjeto`: use Copilot skill for topic separation, Power Automate skill for flow expression safety, SharePoint skill for `Projetos` schema, and UX skills for card confirmation.
- `CriarTarefa`: use Copilot skill to ensure task phrases do not route to project creation, Power Automate skill for project lookup and response handling, SharePoint skill for `Tarefas` writes only.
- `Gerar_Multiplos_Projetos`: use Copilot skill for batch topic routing, Power Automate skill for array/loop/null/date safety, SharePoint skill for per-row duplicate checks, UX skills for Adaptive Card preview/confirmation.

## Non-Negotiable Mapping

- Adaptive Cards are the Plan A interface.
- Multiline/STT parsing is Plan B and must normalize to the same payload as cards.
- No write path can bypass confirmation.
- Local tests must fail if a planned skill gate is violated.
