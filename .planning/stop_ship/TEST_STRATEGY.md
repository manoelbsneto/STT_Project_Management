# TEST STRATEGY

Status: Active May 11 stop-ship strategy for `Assistente PMO V2`.

Goal: every GAP has automated evidence, browser/runtime evidence, or a documented blocker. Static tests are necessary but not sufficient for Copilot runtime registration. The active release target is `Assistente PMO V2`; the older `Assistente PMO Clean` bot is not the test target.

## Session 20 Current Runtime State

| Area | Current result | Evidence / next evidence |
|---|---|---|
| Latest local package | READY FOR IMPORT | `Solution/PMO_v11_Tarefas_1_8_ATUALIZAR_STATUS_RAG_FIX.zip`, SHA256 `58276EF084576971035D83B74CF243570FAAD0BD6B036E4DB7ACEF6EDBB17CAF`, version `1.8`. |
| Package validation | PASS LOCAL | Verification unpack confirms `AtualizarStatus` uses `rag\s*[:=]` first and `status\s*=` second; no old `status\s*[:=]` parser in that topic. |
| CriarTarefa | PASS RUNTIME | `Teste Smoke Final V5` created in SharePoint `Projetos` with `Prioridade=Alta`, `Deleted=False`. |
| ConsultarProjeto | PASS RUNTIME | Returned real SharePoint data for `Teste Smoke Final V5`. |
| ConsultarPortfolio | PASS RUNTIME | Returned real SharePoint aggregate counts. |
| AtualizarStatus | FIX PREPARED | Runtime write succeeded before 1.8, but RAG parser captured `projeto=...`; 1.8 package fixes parser and requires retest after import. |
| RegistrarRisco | PENDING RUNTIME | Needs bot transcript, flow run, and `Riscos e Bloqueios` row. |
| RegistrarBloqueio | PENDING RUNTIME | Needs bot transcript, flow run, and `Riscos e Bloqueios` row. |
| PedirDecisao | PENDING RUNTIME | Needs bot transcript, flow run, and `Decisoes do Board` row. |

## Test Layers

| Layer | Scope | Tools | Ship role |
|---|---|---|---|
| Static flow definition | Power Automate script/export shape, Standard connectors, forbidden expressions, duplicate filters, claims fields. | `Test-CriarTarefaFlowDefinition.ps1`, new `Test-*_FlowDefinition.ps1`, `Test-PMOFlowStopShipAudit.ps1` | Blocks broken definitions before UI work. |
| Static Copilot contract | YAML/topic/action bindings, stub detection, confirmation entities, STT parser markers. | `Test-CriarTarefaContract.ps1`, `Test-CopilotStopShipGaps.ps1` | Blocks known topic regressions. |
| Static artifact quality | Manual and ghost-discovery safeguards. | `Test-OperationsManualArtifact.ps1`, `Test-CopilotGhostBotInventory.ps1` | Ensures required artifacts exist and no destructive ghost deletion path is scripted. |
| Live programmatic inventory | Dataverse/PAC/SharePoint/ProcessSimple evidence where supported. | FetchXML, ProcessSimple, SharePoint scripts | Supports release evidence but cannot replace browser chat proof. |
| Browser/runtime proof | Copilot Studio tool registration, publish, test chat, screenshots, Power Automate UI flow runs. | Opus browser work | Mandatory for final ship decision. |

## Mandatory V2 Runtime Smoke Matrix

| Order | Topic | Test command | Expected proof |
|---|---|---|---|
| 1 | Cold start | New test session, then first real command | Greeting/warmup appears; first real command does not fall to generic fallback. |
| 2 | ConsultarPortfolio | `consultar portfolio` | Real SharePoint aggregate counts. |
| 3 | ConsultarProjeto | `consultar projeto: projeto=Teste Smoke Final V5` | Real project fields and open risk count. |
| 4 | AtualizarStatus | `atualizar status: projeto=Teste Smoke Final V5, rag=Amarelo, resumo=Smoke test de atualizacao de status fix RAG, percentual=35, risco=Nenhum, bloqueio=Nenhum, proxima acao=Validar RAG` | Confirmation shows `RAG: Amarelo`; `Status Diario` row created; `Projetos` row updated to `Amarelo` and `35`. |
| 5 | RegistrarRisco | `registrar risco: projeto=Teste Smoke Final V5, descricao=Risco smoke test 1, severidade=Alta, impacto=Alto` | `Riscos e Bloqueios` row with `Tipo=Risco`, `StatusRisco=Aberto`, `Deleted=false`. |
| 6 | RegistrarBloqueio | `registrar bloqueio: projeto=Teste Smoke Final V5, descricao=Bloqueio smoke test 1, impacto=Alto` | `Riscos e Bloqueios` row with `Tipo=Bloqueio`, `StatusRisco=Aberto`, `Deleted=false`. |
| 7 | PedirDecisao | `solicitar decisao: projeto=Teste Smoke Final V5, descricao=Decidir prioridade do smoke test, impacto=Alto, prazo=31/05/2026, aprovador=mbenicios@minsait.com` | `Decisoes do Board` row with `StatusDecisao=Pendente`, `Impacto=Alto`, `Deleted=false`. |
| 8 | CriarTarefa regression | `criar tarefa: titulo=Teste Smoke Final V6, responsavel=Manoel Benicio, prazo=2026/05/31, horas=1, prioridade=Alta` | `Projetos` row with `Prioridade=Alta`, `Ativo=true`, `Deleted=false`. |

## Current Tests

| Test | Current result | Coverage |
|---|---|---|
| `tests/Test-CriarTarefaContract.ps1` | PASS | CriarTarefa topic/action static contract. |
| `tests/Test-CriarTarefaFlowDefinition.ps1` | PASS | V3-style CriarTarefa script shape. |
| `tests/Test-CopilotStopShipGaps.ps1` | PASS on local template | GAP-A2 and GAP-B1 through GAP-B7 local YAML regression. |
| `tests/Test-ConsultarPortfolioFlowDefinition.ps1` | PASS | Portfolio flow definition. |
| `tests/Test-ConsultarProjetoFlowDefinition.ps1` | PASS | Project query flow definition. |
| `tests/Test-RegistrarRiscoFlowDefinition.ps1` | PASS | Risk write flow definition. |
| `tests/Test-RegistrarBloqueioFlowDefinition.ps1` | PASS | Block write flow definition. |
| `tests/Test-PedirDecisaoFlowDefinition.ps1` | PASS | Board decision write flow definition. |
| `tests/Test-CopilotGhostBotInventory.ps1` | PASS | Read-only ghost discovery script guard. |
| `tests/Test-OperationsManualArtifact.ps1` | PASS | Manual existence, topic coverage, ASCII text. |
| `tests/Test-PMOFlowStopShipAudit.ps1` | FAIL on latest live export | Live export ASCII/mojibake gate still fails on GPT data. |

## GAP To Test Mapping

| GAP | Automated test | Current local result | Browser/runtime proof |
|---|---|---|---|
| GAP-A1 | `Test-CriarTarefaFlowDefinition.ps1` | PASS static only | V3 success + duplicate run URLs and SharePoint item. |
| GAP-A2 | `Test-CopilotStopShipGaps.ps1`, `Test-CriarTarefaContract.ps1` | PASS local | Copilot UI binding to V3, publish, T-007 chat. |
| GAP-B1 | `Test-ConsultarPortfolioFlowDefinition.ps1`, `Test-CopilotStopShipGaps.ps1` | PASS local | Portfolio flow/topic live response. |
| GAP-B2 | `Test-ConsultarProjetoFlowDefinition.ps1`, `Test-CopilotStopShipGaps.ps1` | PASS local | Project flow/topic live response. |
| GAP-B3 | `Test-RegistrarRiscoFlowDefinition.ps1`, `Test-CopilotStopShipGaps.ps1` | PASS local | Risk write SharePoint item. |
| GAP-B4 | `Test-RegistrarBloqueioFlowDefinition.ps1`, `Test-CopilotStopShipGaps.ps1` | PASS local | Block write SharePoint item. |
| GAP-B5 | `Test-PedirDecisaoFlowDefinition.ps1`, `Test-CopilotStopShipGaps.ps1` | PASS local | Decision write SharePoint item. |
| GAP-B6 | `Test-CopilotStopShipGaps.ps1` | PASS local | Long-text/STT-style runtime proof. |
| GAP-B7 | `Test-CopilotStopShipGaps.ps1` | PASS local | Published String confirmation proof. |
| GAP-C1 | `Test-CopilotGhostBotInventory.ps1` | PASS local | Human-approved cleanup or risk acceptance. |
| GAP-C2 | Runtime evidence checklist | Missing | Recurrence flow run evidence. |
| GAP-C3 | Runtime evidence checklist | Missing | SyncPlannerStats run evidence. |
| GAP-C4 | Runtime evidence checklist | Missing | AlertaProjetoVermelho Teams proof. |
| GAP-C5 | `Test-OperationsManualArtifact.ps1` | PASS local | Manual review if required. |

## Commands

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

## Release Rule

SHIP is not allowed while any required runtime/browser evidence is missing or while the live export audit still fails. Current verdict remains NO-SHIP.

## 2026-05-13 Strategy Addendum - Candidate 3.3

Active local candidate:
- `Solution/PMO_v11_Tarefas_3_3_CRIARPROJETO_CONTENT_ROUTE_SAFE_FIX.zip`
- Scope: `CriarProjeto` content-safe output and project/task routing separation.

Required automated layers:
- Package integrity and aggregate contracts: `tests/Test-SolutionZipP24Contracts.ps1`.
- P0 read contract regression: `tests/Test-SolutionZipP0Contracts.ps1`.
- Full source stop-ship audit: `tests/Test-PMOFlowStopShipAudit.ps1`.
- Content-filter regression: `tests/Test-CriarProjetoContentSafeOutput.ps1`.
- Routing regression: `tests/Test-CopilotRoutingInstructions.ps1`.
- Write-path regressions: `tests/Test-CriarProjetoFlowDefinition.ps1`, `tests/Test-CriarTarefaCreatesTarefas.ps1`.
- Delete safety regression: `tests/Test-ExcluirSoftDeleteCapability.ps1`.

Coverage goal:
- Block raw bot-visible action output echo for `CriarProjeto`.
- Block fallback/default routing that sends project creation to `CriarTarefa`.
- Preserve prior P0/P24 contracts for project lookup, task creation, list tasks, batch preview, soft delete, and standard-only connectors.

Runtime tests still required after import/publish:
- Guided `novo projeto` creates a project and returns a safe static success message without `ContentFiltered`.
- One-shot project command routes to `CriarProjeto`, not `CriarTarefa`.
- Read-only SharePoint check confirms the created project row.
