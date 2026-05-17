# RELEASE READINESS CHECKLIST

Decision: NO-SHIP — targeted P0 runtime validation passed, but owner-approved import/publish remains mandatory for any new package and broader release gates remain pending.
Last updated: 2026-05-11 20:10 BRT

All SEV-0 items remain gated by current evidence. Ship decision upgrades only after owner-approved import and remaining P0 E2E validation pass. No agent may import, publish, deploy, commit, delete, modify portal/runtime, or write to production without explicit written approval from the project owner in the current thread.

## Gates

| Gate | Status | Required proof to mark green |
|---|---|---|
| GAP-A1 V3 real SharePoint write | **DONE** | V3 flow rebuilt, success + duplicate tested in Copilot Studio. Session 18. |
| GAP-A2 CriarTarefa bound to V3 | **DONE** | Topic binding fixed, published, T-007 PASS. Sessions 17-18. |
| COLD-START NLU mitigation | **DONE** | Greeting + Fallback SmartRedirect deployed, 7/7 tests PASS. Session 19. |
| GAP-B1 ConsultarPortfolio/listar projetos ativos real | **DONE for targeted P0** | User runtime screenshots show real SP counts plus active project names for `listar projetos ativos` and `como esta o portfolio`. |
| ListarTarefas accepts NomeProjeto | **DONE for targeted P0** | User runtime screenshot shows `listar tarefas` followed by `Mobile App Corporativo` returns a clean project-scoped response without `PROJECT_NOT_FOUND`. |
| ListarTarefas inline project parser | **DONE for targeted P0/UX fix** | User runtime screenshot on 2026-05-11 shows `listar tarefas PRJ-001` and `listar tarefas Mobile App Corporativo` parsed directly without a second prompt. |
| ExcluirTarefa motivo inline parser | LOCAL FIX READY | Local 2.2 package `Solution/PMO_v11_Tarefas_2_2_EXCLUIRTAREFA_MOTIVO_INLINE_FIX.zip` supports `motivo:`, `motivo=`, `motivo <texto>`, and trailing reason after task ID. Owner import/publish and runtime proof pending. |
| GAP-B2 ConsultarProjeto real | **DONE** | Runtime returned details for `QA Robust 20260513 F` after follow-up project answer; SP confirmed ItemId `33`, `ProjectID=PRJ-274E5ACC`, PM `mbenicios@minsait.com`, `Percentual=0`, `Deleted=false`, and 2 open `Riscos e Bloqueios`. Inline project-name capture remains a hardening gap. |
| GAP-B3 RegistrarRisco real | **DONE** | Runtime created `RISK-16E1AE89`; SP `Riscos e Bloqueios` ItemId `6`, `ProjectID=PRJ-274E5ACC`, `Tipo=Risco`, `Severidade=Alta`, `StatusRisco=Aberto`, `Deleted=false`. |
| GAP-B4 RegistrarBloqueio real | **DONE** | Runtime created `BLOCK-ED57742E`; SP `Riscos e Bloqueios` ItemId `7`, `ProjectID=PRJ-274E5ACC`, `Tipo=Bloqueio`, `Severidade=Alta`, `Impacto=Alto`, `StatusRisco=Aberto`, `Deleted=false`. |
| GAP-B5 PedirDecisao real | **DONE** | Runtime created `DEC-313AA4D0`; SP `Decisoes do Board` ItemId `4`, `ProjectID=PRJ-274E5ACC`, `ApproverUPN=mbenicios@minsait.com`, `Impacto=Alto`, `StatusDecisao=Pendente`, `Deleted=false`. Invalid approver test with `UPN ?` remains a validation-hardening gap. |
| GAP-B6 AtualizarStatus STT/multiline | **PARTIAL** | Runtime created `STU-20260513170804`; SP `Status Diario` preserved multiline text in `Resumo` and updated project `StatusRAG=Amarelo`, but `Risco`, `Bloqueio`, `ProximaAcao` stayed null and `Percentual=0`. |
| GAP-B7 String confirmation | **DONE** | `sim` confirmation tested in Session 19. |
| GAP-C1 Ghost cleanup | PENDING ADMIN | Discovery report ready. Deletion or risk acceptance required. |
| GAP-C2 Recurrence evidence | OPEN | Green run evidence for recurrence flows. |
| GAP-C3 SyncPlannerStats evidence | OPEN | Pilot project with Planner IDs and green run evidence. |
| GAP-C4 AlertaProjetoVermelho E2E | OPEN | SharePoint status change and Teams alert evidence. |
| GAP-C5 Operations Manual | **DONE** | `docs/MANUAL_OPERACIONAL_PMO.md` delivered. |
| Automated local tests | PASS FOR LOCAL 2.2 PACKAGE | `Test-PMOFlowStopShipAudit`, `Test-SolutionZipP0Contracts`, `Test-ExcluirSoftDeleteCapability`; package sanity confirmed version `2.2`, `[Content_Types].xml`, `solution.xml`, `customizations.xml`. |
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

## 2026-05-13 Candidate 3.3 Gate

Decision: SHIP for the targeted 3.3 `CriarProjeto` content-safe/routing fix. Broader PMO release gates remain governed by the main checklist above.

Local gates:
- [x] Package identity recorded: `Solution/PMO_v11_Tarefas_3_3_CRIARPROJETO_CONTENT_ROUTE_SAFE_FIX.zip`, SHA256 `C9C913A0C520CADA2B7D63D9EB323C20336B5FB3F34CF9D93D905E82A96946B4`.
- [x] Version gate: `3.3`.
- [x] `Test-PMOFlowStopShipAudit.ps1`: PASS.
- [x] `Test-SolutionZipP24Contracts.ps1`: PASS.
- [x] `Test-SolutionZipP0Contracts.ps1`: PASS.
- [x] `Test-CriarProjetoContentSafeOutput.ps1`: PASS.
- [x] `Test-CopilotRoutingInstructions.ps1`: PASS.
- [x] `Test-ExcluirSoftDeleteCapability.ps1`: PASS.

Runtime gates:
- [x] Owner import 3.3 into `ColOfertasBrasilPro`.
- [x] Owner publish `Assistente PMO V2`.
- [x] Fresh guided Copilot test: `novo projeto` -> project fields -> `sim` returns `Projeto criado com sucesso.` and no `ContentFiltered`.
- [x] Fresh one-shot Copilot test routes project creation to `CriarProjeto`.
- [x] Assistant performs read-only SharePoint verification for guided project `QA Robust 20260513 E`.
- [x] Assistant performs read-only SharePoint verification for one-shot project `QA Robust 20260513 F`.

Rollback:
- Re-import previously successful package `Solution/PMO_v11_Tarefas_3_1_LISTARTAREFAS_CONTENT_SAFE_FIX.zip` only if 3.3 import/publish causes a new blocking runtime regression.
- After rollback, publish the bot and repeat the same runtime smoke test from a new session.
