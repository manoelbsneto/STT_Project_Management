# TEST STRATEGY

Status: Active May 7 stop-ship strategy.

Goal: every GAP has automated evidence, browser/runtime evidence, or a documented blocker. Static tests are necessary but not sufficient for Copilot runtime registration.

## Test Layers

| Layer | Scope | Tools | Ship role |
|---|---|---|---|
| Static flow definition | Power Automate script/export shape, Standard connectors, forbidden expressions, duplicate filters, claims fields. | `Test-CriarTarefaFlowDefinition.ps1`, new `Test-*_FlowDefinition.ps1`, `Test-PMOFlowStopShipAudit.ps1` | Blocks broken definitions before UI work. |
| Static Copilot contract | YAML/topic/action bindings, stub detection, confirmation entities, STT parser markers. | `Test-CriarTarefaContract.ps1`, `Test-CopilotStopShipGaps.ps1` | Blocks known topic regressions. |
| Static artifact quality | Manual and ghost-discovery safeguards. | `Test-OperationsManualArtifact.ps1`, `Test-CopilotGhostBotInventory.ps1` | Ensures required artifacts exist and no destructive ghost deletion path is scripted. |
| Live programmatic inventory | Dataverse/PAC/SharePoint/ProcessSimple evidence where supported. | FetchXML, ProcessSimple, SharePoint scripts | Supports release evidence but cannot replace browser chat proof. |
| Browser/runtime proof | Copilot Studio tool registration, publish, test chat, screenshots, Power Automate UI flow runs. | Opus browser work | Mandatory for final ship decision. |

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
