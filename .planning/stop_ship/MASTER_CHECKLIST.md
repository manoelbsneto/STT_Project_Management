# MASTER CHECKLIST

Status: NO-SHIP
Active plan: `.planning/CODEX_DEPLOYMENT_PLAN_20260507.md`
Last Codex programmatic refresh: 2026-05-07 20:25 BRT

## Release Gates

| Gate | Status | Evidence / next evidence |
|---|---|---|
| All 8 PRD topics functional | PENDING RUNTIME | Local template no longer has B1-B5 stubs; Opus must bind/create flows and prove live chat. |
| STT / long-text support | PENDING RUNTIME | Local `AtualizarStatus` captures `System.Activity.Text` and parses fields; Opus must publish and test. |
| Confirm-before-action | PENDING RUNTIME | Local template has String confirmations; live publish/test required. |
| V3 flow writes to `Projetos` | PENDING RUNTIME | `deploy/PA_CriarTarefa_Flow.ps1` passes static test; deployment attempt timed out; Opus/admin must prove runtime. |
| CriarTarefa binds to V3 | PENDING RUNTIME | Local action flowId changed to `3104124d-364a-f111-bec7-7ced8d955c6c`; Copilot Studio publish/test required. |
| All 10 PRD flows have runtime evidence | FAIL | Recurrence/e2e evidence gaps remain for GAP-C2 through GAP-C4. |
| Ghost components cleaned | PENDING ADMIN | `deploy/Discover-GhostBotComponents.ps1` created and tested; deletion requires Human/Admin approval. |
| Automated tests green | PARTIAL | New local tests pass; live export audit still fails on GPT data ASCII/mojibake. |
| Operations Manual delivered | DONE LOCAL | `docs/MANUAL_OPERACIONAL_PMO.md` exists and passes `Test-OperationsManualArtifact.ps1`. |
| Zero SEV-0/P0 open | FAIL | Runtime evidence is still missing for GAP-A1, A2, B1-B7. |

## GAP Checklist

| GAP ID | Severity | Owner | Status | Programmatic evidence | Browser / admin evidence required |
|---|---|---|---|---|---|
| GAP-A1 | SEV-0 | Codex + Opus | Pending runtime | `Test-CriarTarefaFlowDefinition.ps1` PASS; deploy attempt documented in `.planning/comms/CODEX_PROGRAMMATIC_DEPLOY_ATTEMPT_20260507.md`. | Opus UI/runtime proof: success run, duplicate run, SharePoint item. |
| GAP-A2 | SEV-0 | Opus | Pending runtime | Local YAML references V3 flow ID and passes `Test-CopilotStopShipGaps.ps1`. | Copilot Studio bind/publish and T-007 chat screenshot. |
| GAP-B1 | P0 | Codex + Opus | Pending runtime | `deploy/PA_ConsultarPortfolio_Flow.ps1` and test PASS. | Flow ID, topic binding, live portfolio response. |
| GAP-B2 | P0 | Codex + Opus | Pending runtime | `deploy/PA_ConsultarProjeto_Flow.ps1` and test PASS. | Flow ID, topic binding, live project response. |
| GAP-B3 | P0 | Codex + Opus | Pending runtime | `deploy/PA_RegistrarRiscoBot_Flow.ps1` and test PASS. | SharePoint item with `Tipo=Risco`. |
| GAP-B4 | P0 | Codex + Opus | Pending runtime | `deploy/PA_RegistrarBloqueioBot_Flow.ps1` and test PASS. | SharePoint item with `Tipo=Bloqueio`. |
| GAP-B5 | P0 | Codex + Opus | Pending runtime | `deploy/PA_PedirDecisaoBot_Flow.ps1` and test PASS. | SharePoint item in `Decisoes do Board`. |
| GAP-B6 | P0 | Codex + Opus | Pending runtime | Local `AtualizarStatus` STT redesign passes `Test-CopilotStopShipGaps.ps1`. | Published long-text/STT runtime proof. |
| GAP-B7 | P0 | Codex + Opus | Pending runtime | Local template has no `BooleanPrebuiltEntity`; static test PASS. | Published confirmation proof for `sim/s/yes/confirmo`. |
| GAP-C1 | P1 | Codex + Human/Admin | Pending admin | `Discover-GhostBotComponents.ps1` and `Test-CopilotGhostBotInventory.ps1` PASS; skipped discovery evidence created in `.planning/comms/`. | Human-approved deletion or formal risk acceptance. |
| GAP-C2 | P1 | Opus | Open | No new programmatic change. | Scheduled recurrence screenshots/run URLs. |
| GAP-C3 | P1 | Opus | Open | No new programmatic change. | SyncPlannerStats pilot evidence. |
| GAP-C4 | P1 | Opus | Open | No new programmatic change. | Teams red-project alert proof. |
| GAP-C5 | P1 | Codex | Done local | `docs/MANUAL_OPERACIONAL_PMO.md`; `Test-OperationsManualArtifact.ps1` PASS. | Project Owner/Opus review if required. |
| GAP-D1 | P2 | Codex | Post-ship | Not a release blocker. | Project Owner decision if scope changes. |
| GAP-D2 | P2 | Codex | Post-ship | Not a release blocker. | Project Owner decision if scope changes. |

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
