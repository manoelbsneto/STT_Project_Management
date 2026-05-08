# RELEASE READINESS CHECKLIST

Decision: NO-SHIP.

Codex programmatic preparation is substantially complete, but runtime/browser evidence remains mandatory for ship.

## Gates

| Gate | Status | Required proof to mark green |
|---|---|---|
| GAP-A1 V3 real SharePoint write | PENDING RUNTIME | V3 success run URL, duplicate run URL, and SharePoint `Projetos` item proof. |
| GAP-A2 CriarTarefa bound to V3 | PENDING RUNTIME | Copilot Studio UI binding proof, published bot proof, T-007 chat proof. |
| GAP-B1 ConsultarPortfolio real | PENDING RUNTIME | Flow ID, binding proof, live response from `Projetos`. |
| GAP-B2 ConsultarProjeto real | PENDING RUNTIME | Flow ID, binding proof, live response for one project plus open risks count. |
| GAP-B3 RegistrarRisco real | PENDING RUNTIME | SharePoint `Riscos e Bloqueios` item with `Tipo=Risco`. |
| GAP-B4 RegistrarBloqueio real | PENDING RUNTIME | SharePoint `Riscos e Bloqueios` item with `Tipo=Bloqueio`. |
| GAP-B5 PedirDecisao real | PENDING RUNTIME | SharePoint `Decisoes do Board` item. |
| GAP-B6 AtualizarStatus STT compatible | PENDING RUNTIME | Long-text input parses, confirms, and invokes intended status path. |
| GAP-B7 String confirmation published | PENDING RUNTIME | Runtime evidence for `sim`, `s`, `yes`, or `confirmo`. |
| GAP-C1 Ghost cleanup | PENDING ADMIN | Discovery report and Human/Admin-approved deletion or explicit risk acceptance. |
| GAP-C2 Recurrence evidence | FAIL | Green run evidence for recurrence flows. |
| GAP-C3 SyncPlannerStats evidence | FAIL | Pilot project with Planner IDs and green run evidence. |
| GAP-C4 AlertaProjetoVermelho E2E | FAIL | SharePoint status change and Teams alert evidence. |
| GAP-C5 Operations Manual | DONE LOCAL | `docs/MANUAL_OPERACIONAL_PMO.md`; review if required. |
| Automated local tests | PARTIAL PASS | All local new tests pass; live export audit still fails ASCII/mojibake. |
| Zero SEV-0/P0 open | FAIL | Runtime proof required for GAP-A1, A2, B1-B7. |

## Current Automated Evidence

| Command | Result |
|---|---|
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarTarefaContract.ps1 -TemplatePath deploy\copilot\AssistentePMO.template.yaml` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CriarTarefaFlowDefinition.ps1 -Path deploy\PA_CriarTarefa_Flow.ps1 -AllowRuntimeRawAuthentication` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotStopShipGaps.ps1 -TemplatePath deploy\copilot\AssistentePMO.template.yaml` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-ConsultarPortfolioFlowDefinition.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-ConsultarProjetoFlowDefinition.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-RegistrarRiscoFlowDefinition.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-RegistrarBloqueioFlowDefinition.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PedirDecisaoFlowDefinition.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotGhostBotInventory.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-OperationsManualArtifact.ps1` | PASS |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath .planning\stop_ship\live_export\PMO_v11_Tarefas_live_20260507_132627_unpacked` | FAIL: live GPT data has non-ASCII/mojibake |

## Opus Browser Gate

Opus should execute `.planning/comms/CODEX_BROWSER_REQUESTS_20260507.md` in one browser session:

1. Create/update flow definitions.
2. Bind all Copilot topics to the correct flow actions.
3. Publish once.
4. Run all chat tests.
5. Capture screenshots, run URLs, SharePoint item IDs, and flow IDs.

## Rollback Plan Requirement

Before browser/UI changes, preserve:

1. Current solution export.
2. Current bot/version identity.
3. Current flow version identity for V3 and topic-bound flows.
4. Screenshots or run URLs showing the previous state.

Rollback requires republish and fresh bot chat validation when Copilot runtime registration changes.
