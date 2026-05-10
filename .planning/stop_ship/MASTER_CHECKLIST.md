# MASTER CHECKLIST

Status: CONDITIONAL SHIP — SEV-0 resolved
Active plan: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md`
Last update: 2026-05-10 18:40 BRT (Session 19)

## Release Gates

| Gate | Status | Evidence / next evidence |
|---|---|---|
| All 8 PRD topics functional | PARTIAL — 3/8 validated live | CriarTarefa, ConsultarPortfolio (topic routing), AtualizarStatus (topic routing) validated. B2-B5 write flows need E2E proof. |
| STT / long-text support | PARTIAL | CriarTarefa parses long STT input correctly (tested Session 19). AtualizarStatus pending. |
| Confirm-before-action | DONE | CriarTarefa `sim` confirmation tested and working (Session 19). |
| V3 flow writes to `Projetos` | DONE | Flow rebuilt in Classic Designer. Test 1: project created. Test 2: duplicate detected. (Session 18). |
| CriarTarefa binds to V3 | DONE | Topic binding fixed, output binding removed, published and tested (Sessions 17-18). |
| Cold Start NLU mitigation | DONE | Greeting warm-up + Fallback SmartRedirect deployed. 7/7 tests PASS (Session 19). |
| All 10 PRD flows have runtime evidence | PARTIAL | CriarTarefa V3 has runtime evidence. Recurrence/e2e evidence gaps remain for GAP-C2 through GAP-C4. |
| Ghost components cleaned | PENDING ADMIN | `deploy/Discover-GhostBotComponents.ps1` created and tested; deletion requires Human/Admin approval. |
| Automated tests green | PARTIAL | New local tests pass; live export audit still fails on GPT data ASCII/mojibake. |
| Operations Manual delivered | DONE | `docs/MANUAL_OPERACIONAL_PMO.md` exists and passes `Test-OperationsManualArtifact.ps1`. |
| Zero SEV-0 open | **DONE** | All SEV-0 items (A1, A2, Cold Start) resolved with live runtime evidence. |
| Zero P0 open | PARTIAL | B7 resolved. B1, B2, B3, B4, B5, B6 need E2E SP write/read validation. |

## GAP Checklist

| GAP ID | Severity | Owner | Status | Evidence |
|---|---|---|---|---|
| GAP-A1 | SEV-0 | — | **DONE** | Flow rebuilt Session 18. Success run + duplicate detection PASS. |
| GAP-A2 | SEV-0 | — | **DONE** | Binding fixed Sessions 17-18. Topic published and tested. |
| COLD-START | SEV-0 | — | **DONE** | Greeting + Fallback deployed Session 19. 7/7 tests PASS. Commit `e2232ce`. |
| GAP-B1 | P0 | User/Opus | **PARTIAL** | Topic redirect works (Session 19). Flow may be returning template text. Need to verify real SP query. |
| GAP-B2 | P0 | User/Opus | Pending | Topic exists. Need E2E test with known project name. |
| GAP-B3 | P0 | User/Opus | Pending | Topic redirect works (Session 19). Need to complete full flow and verify SP `Riscos e Bloqueios` item. |
| GAP-B4 | P0 | User/Opus | Pending | Same pattern as B3. Need full flow test. |
| GAP-B5 | P0 | User/Opus | Pending | Topic redirect works (Session 19). Need to complete full flow and verify SP `Decisoes do Board` item. |
| GAP-B6 | P0 | User/Opus | **PARTIAL** | Topic redirect works, asks "Qual projeto?" Need to test long-text STT input. |
| GAP-B7 | P0 | — | **DONE** | `sim` confirmation tested and working in Session 19. |
| GAP-C1 | P1 | Human/Admin | Pending admin | Discovery script ready. Deletion requires approval. |
| GAP-C2 | P1 | Opus | Open | Recurrence flow evidence needed. |
| GAP-C3 | P1 | Opus | Open | SyncPlannerStats pilot evidence needed. |
| GAP-C4 | P1 | Opus | Open | AlertaProjetoVermelho E2E needed. |
| GAP-C5 | P1 | — | **DONE** | `docs/MANUAL_OPERACIONAL_PMO.md` delivered. |
| GAP-D1 | P2 | Codex | Post-ship | Not release-blocking. |
| GAP-D2 | P2 | Codex | Post-ship | Not release-blocking. |

## Current Test Commands

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarTarefaContract.ps1 -TemplatePath deploy\copilot\AssistentePMO.template.yaml
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarTarefaFlowDefinition.ps1 -Path deploy\PA_CriarTarefa_Flow.ps1 -AllowRuntimeRawAuthentication
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotStopShipGaps.ps1 -TemplatePath deploy\copilot\AssistentePMO.template.yaml
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-ConsultarPortfolioFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-ConsultarProjetoFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-RegistrarRiscoFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-RegistrarBloqueioFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PedirDecisaoFlowDefinition.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotGhostBotInventory.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-OperationsManualArtifact.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked
```
