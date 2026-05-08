# Current Status Table

Date: 2026-05-07
Decision: NO-SHIP

## Summary Counts

| Category | Count | Meaning |
|---|---:|---|
| Pending browser/runtime | 9 | Needs Opus browser session for SEV-0/P0 flow binding, publish, chat, or SharePoint proof. |
| Open evidence-only | 3 | Needs Opus runtime evidence for P1 scheduled/e2e flows. |
| Pending Human/Admin | 1 | Needs explicit approval before destructive action. |
| Done local | 1 | Codex artifact complete; optional review remains. |
| Post-ship | 2 | Not required for current ship gate unless scope changes. |

## Issue Status

| GAP ID | Severity | Area | Current status | Owner now | Next step | Estimated duration |
|---|---|---|---|---|---|---|
| GAP-A1 | SEV-0 | V3 CriarTarefa flow real write | Programmatic prepared; runtime pending | Opus | Apply/verify V3 flow in Power Automate UI and capture success + duplicate runs | 1.0-1.5h |
| GAP-A2 | SEV-0 | CriarTarefa binding to V3 | Local template fixed; browser pending | Opus | Bind topic to V3, publish, run T-007 | 0.5-1.0h |
| GAP-B1 | P0 | ConsultarPortfolio real flow | Script/test done; runtime pending | Opus | Create/bind flow and test `como esta o portfolio` | 0.75-1.0h |
| GAP-B2 | P0 | ConsultarProjeto real flow | Script/test done; runtime pending | Opus | Create/bind flow and test one known project | 0.75-1.0h |
| GAP-B3 | P0 | RegistrarRisco write | Script/test done; runtime pending | Opus | Create/bind flow and verify SharePoint risk item | 0.75-1.0h |
| GAP-B4 | P0 | RegistrarBloqueio write | Script/test done; runtime pending | Opus | Create/bind flow and verify SharePoint block item | 0.75-1.0h |
| GAP-B5 | P0 | PedirDecisao write | Script/test done; runtime pending | Opus | Create/bind flow and verify board decision item | 0.75-1.0h |
| GAP-B6 | P0 | AtualizarStatus STT long text | Local template fixed; browser pending | Opus | Apply/publish topic and test one long dictation-style message | 0.5-0.75h |
| GAP-B7 | P0 | String confirmation | Local template fixed; runtime pending | Opus | Publish and test `sim/s/yes/confirmo` path | 0.25-0.5h |
| GAP-C1 | P1 | Ghost bot components | Discovery script done; live deletion pending | Human/Admin | Review discovery output, approve deletion or accept risk | 0.5h discovery + approval time |
| GAP-C2 | P1 | Recurrence flow evidence | Open | Opus | Capture scheduled run history screenshots/URLs | Wait for schedule |
| GAP-C3 | P1 | SyncPlannerStats real data | Open | Opus | Add pilot Planner IDs and run/capture flow | 0.5-1.0h |
| GAP-C4 | P1 | AlertaProjetoVermelho E2E | Open | Opus | Set test project red and capture Teams alert/run | 0.5-1.0h |
| GAP-C5 | P1 | Operations manual | Closed programmatically | Codex | Review `docs/MANUAL_OPERACIONAL_PMO.md` | 0.25h review |
| GAP-D1 | P2 | Marcos e Entregas list | Post-ship | Codex | Only execute if Project Owner promotes scope | TBD |
| GAP-D2 | P2 | Planner Metrics Snapshot list | Post-ship | Codex | Only execute if Project Owner promotes scope | TBD |

## Owner Split

| Owner | Items |
|---|---|
| Codex | Programmatic preparation is complete for A1, B1-B7, C1, C5; remaining Codex work is re-test after Opus evidence. |
| Opus | All browser creation/binding/publish/chat/screenshot tasks: A1, A2, B1-B7, C2-C4. |
| Human/Admin | Approval before any Dataverse ghost component deletion. |

## Remaining Ship Blockers

NO-SHIP remains because live browser/runtime evidence is missing for SEV-0/P0 gates and ghost cleanup approval is not complete.
