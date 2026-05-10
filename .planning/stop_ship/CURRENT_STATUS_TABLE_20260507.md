# Current Status Table

Date: 2026-05-10
Decision: CONDITIONAL SHIP — SEV-0 resolved, P0 runtime validation in progress

## Summary Counts

| Category | Count | Meaning |
|---|---:|---|
| DONE — Validated in production | 7 | Deployed, tested live, and confirmed working. |
| Pending browser/runtime | 5 | Needs browser session for P0 flow write validation or STT proof. |
| Open evidence-only | 3 | Needs runtime evidence for P1 scheduled/e2e flows. |
| Pending Human/Admin | 1 | Needs explicit approval before destructive action. |
| Post-ship | 2 | Not required for current ship gate unless scope changes. |

## Issue Status

| GAP ID | Severity | Area | Current status | Owner now | Next step | Estimated duration |
|---|---|---|---|---|---|---|
| GAP-A1 | SEV-0 | V3 CriarTarefa flow real write | **DONE** — Flow rebuilt via Classic Designer, tested with success + duplicate detection | — | Closed | — |
| GAP-A2 | SEV-0 | CriarTarefa binding to V3 | **DONE** — Topic bound, output binding fixed, published, T-007 PASS | — | Closed | — |
| COLD-START | SEV-0 | 1st message fails NLU | **DONE** — Greeting warm-up + Fallback SmartRedirect deployed, 7/7 tests PASS | — | Closed | — |
| GAP-B1 | P0 | ConsultarPortfolio real flow | **PARTIAL** — Topic redirect works, flow responds but may be returning template text, not live SP query results | User/Opus | Validate flow returns real Verde/Amarelo/Vermelho counts from SP | 0.5h |
| GAP-B2 | P0 | ConsultarProjeto real flow | **PENDING** — Topic exists but flow write validation not done | User/Opus | Test `consultar projeto [nome]` and verify SP lookup | 0.5h |
| GAP-B3 | P0 | RegistrarRisco write | **PENDING** — Topic redirect works but SP write not validated | User/Opus | Test full flow: `registrar risco` → fill fields → verify SP item | 0.75h |
| GAP-B4 | P0 | RegistrarBloqueio write | **PENDING** — Same as B3 | User/Opus | Test full flow end-to-end | 0.75h |
| GAP-B5 | P0 | PedirDecisao write | **PENDING** — Topic redirect works but SP write not validated | User/Opus | Test full flow: `solicitar decisao` → fill fields → verify SP item | 0.75h |
| GAP-B6 | P0 | AtualizarStatus STT long text | **PARTIAL** — Topic responds to redirect, asks "Qual projeto?" | User/Opus | Test with long-text STT input | 0.5h |
| GAP-B7 | P0 | String confirmation | **DONE** — CriarTarefa confirmed with `sim` successfully | — | Closed | — |
| GAP-C1 | P1 | Ghost bot components | Pending admin | Human/Admin | Review discovery output, approve deletion or accept risk | 0.5h |
| GAP-C2 | P1 | Recurrence flow evidence | Open | Opus | Capture scheduled run history screenshots/URLs | Wait for schedule |
| GAP-C3 | P1 | SyncPlannerStats real data | Open | Opus | Add pilot Planner IDs and run/capture flow | 0.5-1.0h |
| GAP-C4 | P1 | AlertaProjetoVermelho E2E | Open | Opus | Set test project red and capture Teams alert/run | 0.5-1.0h |
| GAP-C5 | P1 | Operations manual | **DONE** | — | Closed | — |
| GAP-D1 | P2 | Marcos e Entregas list | Post-ship | Codex | Only execute if Project Owner promotes scope | TBD |
| GAP-D2 | P2 | Planner Metrics Snapshot list | Post-ship | Codex | Only execute if Project Owner promotes scope | TBD |

## Owner Split

| Owner | Items |
|---|---|
| Resolved | GAP-A1, GAP-A2, COLD-START, GAP-B7, GAP-C5 — all validated with live runtime evidence. |
| User/Opus | Browser E2E validation for GAP-B1 through B6: test each topic, confirm SP writes, capture evidence. |
| Human/Admin | GAP-C1: Approval before Dataverse ghost component deletion. |

## Remaining Ship Blockers

CONDITIONAL SHIP — SEV-0 items are resolved. Remaining P0 items (B1-B6) require live E2E validation of SharePoint read/write through the bot topics. P1 items (C1-C4) are quality gates, not hard blockers.
