# RELEASE READINESS CHECKLIST

Decision: CONDITIONAL SHIP — SEV-0 clear, P0 E2E pending.
Last updated: 2026-05-10 18:40 BRT

All SEV-0 items are resolved with live runtime evidence. Ship decision upgrades to SHIP when remaining P0 E2E validation passes.

## Gates

| Gate | Status | Required proof to mark green |
|---|---|---|
| GAP-A1 V3 real SharePoint write | **DONE** | V3 flow rebuilt, success + duplicate tested in Copilot Studio. Session 18. |
| GAP-A2 CriarTarefa bound to V3 | **DONE** | Topic binding fixed, published, T-007 PASS. Sessions 17-18. |
| COLD-START NLU mitigation | **DONE** | Greeting + Fallback SmartRedirect deployed, 7/7 tests PASS. Session 19. |
| GAP-B1 ConsultarPortfolio real | **PARTIAL** | Topic redirect works. Validate flow returns real SP counts. |
| GAP-B2 ConsultarProjeto real | PENDING | Test `consultar projeto [name]` and verify SP lookup response. |
| GAP-B3 RegistrarRisco real | PENDING | Test full flow, verify SP `Riscos e Bloqueios` item created. |
| GAP-B4 RegistrarBloqueio real | PENDING | Test full flow, verify SP `Riscos e Bloqueios` item created. |
| GAP-B5 PedirDecisao real | PENDING | Test full flow, verify SP `Decisoes do Board` item created. |
| GAP-B6 AtualizarStatus STT | **PARTIAL** | Topic works, test long-text input parsing. |
| GAP-B7 String confirmation | **DONE** | `sim` confirmation tested in Session 19. |
| GAP-C1 Ghost cleanup | PENDING ADMIN | Discovery report ready. Deletion or risk acceptance required. |
| GAP-C2 Recurrence evidence | OPEN | Green run evidence for recurrence flows. |
| GAP-C3 SyncPlannerStats evidence | OPEN | Pilot project with Planner IDs and green run evidence. |
| GAP-C4 AlertaProjetoVermelho E2E | OPEN | SharePoint status change and Teams alert evidence. |
| GAP-C5 Operations Manual | **DONE** | `docs/MANUAL_OPERACIONAL_PMO.md` delivered. |
| Automated local tests | PARTIAL PASS | All local new tests pass; live export audit still fails ASCII/mojibake. |
| Zero SEV-0 open | **DONE** | All 3 SEV-0 items (A1, A2, Cold Start) resolved. |

## P0 E2E Validation Script (User/Browser)

To close remaining P0 gaps, run these tests in Copilot Studio (new session each):

### Test B1: ConsultarPortfolio
```
Input: consultar portfolio
Expected: Real counts from SP (e.g., "Verde: 2, Amarelo: 2, Vermelho: 1")
Verify: Numbers match actual SP Projetos list
```

### Test B2: ConsultarProjeto
```
Input: consultar projeto Portal do Colaborador
Expected: Project details from SP (PM, status, prazo, etc.)
Verify: Data matches SP Projetos item
```

### Test B3: RegistrarRisco
```
Input: registrar risco
Follow prompts: project name, descricao, severidade
Expected: "Risco registrado com sucesso"
Verify: New item in SP "Riscos e Bloqueios" with Tipo=Risco
```

### Test B4: RegistrarBloqueio
```
Input: registrar bloqueio [if topic exists]
Follow prompts: project name, descricao, impacto
Expected: "Bloqueio registrado com sucesso"
Verify: New item in SP "Riscos e Bloqueios" with Tipo=Bloqueio
```

### Test B5: PedirDecisao
```
Input: solicitar decisao
Follow prompts: project name, descricao, impacto, prazo, aprovador
Expected: "Decisao registrada com sucesso"
Verify: New item in SP "Decisoes do Board"
```

### Test B6: AtualizarStatus STT
```
Input: atualizar status: projeto=Portal do Colaborador, status=Amarelo, resumo=Ajustes no layout, percentual=45, risco=Nenhum, bloqueio=Nenhum, proxima acao=Revisar com equipe
Expected: Parses all fields and confirms
Verify: SP Status Diario item created
```

## Rollback Plan Requirement

Before browser/UI changes, preserve:

1. Current solution export.
2. Current bot/version identity.
3. Current flow version identity for V3 and topic-bound flows.
4. Screenshots or run URLs showing the previous state.

Rollback requires republish and fresh bot chat validation when Copilot runtime registration changes.
