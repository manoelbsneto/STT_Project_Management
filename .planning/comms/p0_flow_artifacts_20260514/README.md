# P0 Local Power Automate Flow Artifacts

Date: 2026-05-14
Owner: CODEX-LEAD
Scope: AQ-05 local implementation planning only
Release decision: NO-SHIP
Tenant execution: None

## Purpose

This folder contains local pseudocode artifacts for the Adaptive Cards + Planner P0 Power Automate workstream.

These files are not importable Power Automate definitions. They are implementation planning artifacts to support later local build, static validation, and owner approval sequencing.

## Source Inputs

- `.planning/comms/P0_FLOW_IMPLEMENTATION_CHECKLIST_20260514.md`
- `.planning/comms/P0_OWNER_APPROVAL_QUEUE_ADAPTIVE_CARDS_PLANNER_20260514.md`
- `.planning/comms/CODEX_REVIEW_GEMINI_P0_FLOW_IMPLEMENTATION_REWORK_20260514.md`
- `.planning/comms/AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md`
- `deploy/cards/ResumoExecutivoPortfolio.json`
- `deploy/cards/AtualizarStatusCard.json`
- `deploy/cards/AtualizarStatusSingleBoxReviewCard.json`
- `deploy/cards/ListarTarefasProjetoCard.json`
- `deploy/cards/CriarTarefaCard.json`
- `deploy/cards/AtualizarTarefaCard.json`

## Files

| File | Purpose |
|---|---|
| `flow_pseudocode_definitions.json` | Structured local pseudocode for the five P0 flows |
| `route_and_output_contract.md` | Route keys and bounded Copilot output rules |
| `schema_dependencies.md` | SharePoint and Planner schema dependencies |
| `rollback_and_gate_plan.md` | Rollback notes and required gates before tenant execution |
| `VALIDATION.md` | Local validation result for this artifact set |

## Execution Control

No tenant flow save, import, publish, SharePoint write, Planner write, or Teams production post is authorized by these artifacts.

AQ-04 Planner IDs are accepted as owner-provided local planning constants only. They do not authorize runtime Planner writes or flow deployment.

Any future runtime action must follow:

1. `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`
2. `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`
3. explicit owner approval in the current thread
