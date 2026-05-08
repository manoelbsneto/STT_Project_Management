# Codex Browser Requests For Opus

Date: 2026-05-07
Owner: Opus for browser execution
Prepared by: Codex
Status: Pending browser session

## Context

Codex completed local programmatic preparation for GAP-A1 and GAP-B1 through GAP-B7. Programmatic tenant deployment timed out, so new runtime flow IDs are still pending.

Opus must create/update/bind the flows through Power Automate and Copilot Studio UI, publish once, then capture evidence.

## Required Browser Work

| BR ID | GAP | Browser task | Input from Codex | Evidence required | Status |
|---|---|---|---|---|---|
| BR-001 | GAP-A1 | Ensure `PMO_PA_CriarTarefa_V3` contains real SharePoint write logic | `deploy/PA_CriarTarefa_Flow.ps1`; `.planning/comms/CODEX_PROGRAMMATIC_DEPLOY_ATTEMPT_20260507.md` | Flow run URL success, duplicate run URL, SharePoint item proof | Pending |
| BR-002 | GAP-A2 | Bind `CriarTarefa` topic to V3 flow `3104124d-364a-f111-bec7-7ced8d955c6c` | `deploy/copilot/AssistentePMO.template.yaml` | Topic binding screenshot, publish screenshot | Pending |
| BR-003 | GAP-B1 | Create/bind `PMO_PA_ConsultarPortfolio` | `deploy/PA_ConsultarPortfolio_Flow.ps1`; build JSON in `.planning/comms/` | Flow ID, topic binding screenshot, test chat result | Pending |
| BR-004 | GAP-B2 | Create/bind `PMO_PA_ConsultarProjeto` | `deploy/PA_ConsultarProjeto_Flow.ps1`; build JSON in `.planning/comms/` | Flow ID, topic binding screenshot, test chat result | Pending |
| BR-005 | GAP-B3 | Create/bind `PMO_PA_RegistrarRiscoBot` | `deploy/PA_RegistrarRiscoBot_Flow.ps1`; build JSON in `.planning/comms/` | Flow ID, risk item in SharePoint, flow run URL | Pending |
| BR-006 | GAP-B4 | Create/bind `PMO_PA_RegistrarBloqueioBot` | `deploy/PA_RegistrarBloqueioBot_Flow.ps1`; build JSON in `.planning/comms/` | Flow ID, bloqueio item in SharePoint, flow run URL | Pending |
| BR-007 | GAP-B5 | Create/bind `PMO_PA_PedirDecisaoBot` | `deploy/PA_PedirDecisaoBot_Flow.ps1`; build JSON in `.planning/comms/` | Flow ID, decisao item in SharePoint, flow run URL | Pending |
| BR-008 | GAP-B6/B7 | Apply/publish `AtualizarStatus` STT redesign and String confirmations | `deploy/copilot/AssistentePMO.template.yaml` | Long-text chat proof, confirm `sim` proof, publish screenshot | Pending |
| BR-009 | GAP-C2 | Capture recurrence flow evidence | Release checklist | Run history screenshots/URLs | Pending |
| BR-010 | GAP-C3 | Run SyncPlannerStats pilot test | Release checklist | Pilot item and run history proof | Pending |
| BR-011 | GAP-C4 | Run AlertaProjetoVermelho E2E | Release checklist | Teams alert and flow run proof | Pending |

## Test Inputs

### T-007 CriarTarefa

```text
Criar tarefa: Titulo=Teste Wave1 20260507, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=100, Prioridade=Alta
```

Then:

```text
sim
```

Expected: SharePoint `Projetos` item created and ProjectID returned.

Repeat the same input for duplicate proof. Expected: duplicate response and no second item.

### ConsultarPortfolio

```text
como esta o portfolio
```

Expected: live summary with total active projects, Verde, Amarelo, Vermelho, stale count.

### ConsultarProjeto

```text
consultar projeto
```

When asked, provide a known `NomeProjeto` from `Projetos`.

Expected: live project details and open risk count.

### RegistrarRisco

```text
registrar risco
```

Use a known project, description `Risco teste Codex 20260507`, severidade `Alta`, then confirm `sim`.

Expected: item in `Riscos e Bloqueios` with `Tipo=Risco`.

### RegistrarBloqueio

```text
registrar bloqueio
```

Use a known project, description `Bloqueio teste Codex 20260507`, impacto `Alto`, then confirm `sim`.

Expected: item in `Riscos e Bloqueios` with `Tipo=Bloqueio`.

### PedirDecisao

```text
preciso de uma decisao
```

Use a known project, descricao `Decisao teste Codex 20260507`, impacto `Medio`, prazo `30/06/2026`, aprovador `mbenicios@minsait.com`, then confirm `sim`.

Expected: item in `Decisoes do Board` with `StatusDecisao=Pendente`.

### AtualizarStatus Long Text

```text
Atualizar status: Projeto=Projeto piloto, Verde, Resumo=sem desvios, Risco=nao, Acao=seguir plano, Percentual=40
```

Expected: bot parses the message, asks only missing fields if any, accepts `sim`.

## Codex Recheck After Opus

After Opus exports/fetches the updated bot artifacts, Codex will rerun:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-CopilotStopShipGaps.ps1 -TemplatePath <fresh-exported-yaml>
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Test-PMOFlowStopShipAudit.ps1 -SolutionSourcePath <fresh-unpacked-export>
```
