# M2 Requirements — Hybrid Card-First Revision

**Milestone:** M2
**Date:** 2026-05-20
**Status:** Active
**Owner:** Manoel Benicio
**Reference:** `.planning/milestones/M2_card_first_revision_v2/PROJECT.md`

---

## Format

Each requirement carries:
- **ID** — REQ-M2-NN
- **Priority** — P0 (blocker) | P1 (high) | P2 (medium)
- **Phase** — which roadmap phase delivers this
- **Acceptance criteria** — observable evidence required to mark complete
- **Verification** — how it gets validated (smoke, unit test, evidence pack)

---

## P0 — Release Blockers

### REQ-M2-01 — 12 operações migradas para padrão híbrido

**Priority:** P0
**Phase:** 4 (Flow Build) + 5 (Topic Update)
**Owner runtime:** Owner manual remediation per topic + AI-generated YAMLs

**Scope completo (12 operações):**

| # | Operação | Tipo | Topic atual | Flow target |
|---:|---|---|---|---|
| 1 | CriarProjeto | Write | CriarProjeto | PM0_PA_Card_CriarProjeto |
| 2 | ConsultarProjeto | Read | ConsultarProjeto | PM0_PA_Card_ConsultarProjeto |
| 3 | ExcluirProjeto | Write (soft) | ExcluirProjeto | PM0_PA_Card_ExcluirProjeto |
| 4 | CriarTarefa | Write | CriarTarefa | PM0_PA_Card_CriarTarefa (refactor existing) |
| 5 | ListarTarefas | Read | ListarTarefas | PM0_PA_Card_ListarTarefas (refactor existing) |
| 6 | AtualizarTarefa | Write | AtualizarTarefa | PM0_PA_Card_AtualizarTarefa (refactor existing) |
| 7 | ExcluirTarefa | Write (soft) | ExcluirTarefa | PM0_PA_Card_ExcluirTarefa |
| 8 | AtualizarStatus | Write | AtualizarStatus | PM0_PA_Card_AtualizarStatus (refactor existing) |
| 9 | RegistrarRisco | Write | RegistrarRisco | PM0_PA_Card_RegistrarRisco |
| 10 | RegistrarBloqueio | Write | RegistrarBloqueio | PM0_PA_Card_RegistrarBloqueio |
| 11 | PedirDecisao | Write | PedirDecisao | PM0_PA_Card_PedirDecisao |
| 12 | ConsultarPortfolio | Read | ConsultarPortfolio | PM0_PA_Card_ResumoExecutivoPortfolio (refactor existing — semantic upgrade) |

**Acceptance:**
- 12 topics chamam exclusivamente `PM0_PA_Card_*` action components
- 0 referências `PMO_PA_*` em topics ativos (LowConfidence/Greeting/SeHouverErro/Gerar_Multiplos_Projetos exceções legítimas)
- `tests/Test-Aq08PostRemediationReverify.ps1` retorna PASS para todos 12 topics

**Verification:** PAC FetchXML diff matrix + automated reverify script

---

### REQ-M2-02 — Adaptive Cards de confirmação (writes)

**Priority:** P0
**Phase:** 3 (Card Design)
**Owner approval:** Visual review pelo owner

**Scope:** 9 cards de confirmação

| Card | Operação | Conteúdo |
|---|---|---|
| `CriarProjetoConfirmCard.json` | CriarProjeto | Form preview com NomeProjeto, PM, Prazo, Prioridade + Confirmar/Cancelar |
| `ExcluirProjetoConfirmCard.json` | ExcluirProjeto | Aviso destrutivo + ProjectID + motivo + Confirmar/Cancelar |
| `CriarTarefaConfirmCard.json` | CriarTarefa | Preview com Titulo, Projeto, Responsavel, Prazo, Horas, Prioridade + Confirmar/Cancelar |
| `AtualizarTarefaConfirmCard.json` | AtualizarTarefa | Preview com TaskID, Status novo, Horas, Responsavel ("(mantido)" se skip), Prazo ("(mantido)" se skip), Prioridade ("(mantido)" se skip) + Confirmar/Cancelar |
| `ExcluirTarefaConfirmCard.json` | ExcluirTarefa | Aviso + TaskID + Motivo + Confirmar/Cancelar |
| `AtualizarStatusConfirmCard.json` | AtualizarStatus | Preview multilinhas com Projeto, RAG colorido, Resumo, Percentual, Risco, Bloqueio, ProximaAcao + Confirmar/Cancelar |
| `RegistrarRiscoConfirmCard.json` | RegistrarRisco | Preview Projeto, Descricao, Severidade, Impacto + Confirmar/Cancelar |
| `RegistrarBloqueioConfirmCard.json` | RegistrarBloqueio | Preview Projeto, Descricao, Severidade, Impacto + Confirmar/Cancelar |
| `PedirDecisaoConfirmCard.json` | PedirDecisao | Preview Projeto, Descricao, Impacto, Prazo, AprovadorUPN + Confirmar/Cancelar |

**Acceptance:**
- 9 JSON files em `deploy/cards/`
- Adaptive Card v1.4+ schema válido (validado em https://adaptivecards.io/designer)
- Cada um <27KB
- Owner-approved visual review

**Verification:** Schema validator + visual smoke

---

### REQ-M2-03 — Adaptive Cards de result/summary (reads)

**Priority:** P0
**Phase:** 3 (Card Design)

**Scope:** 4 cards

| Card | Operação | Conteúdo |
|---|---|---|
| `ConsultarPortfolioCard.json` | ConsultarPortfolio | KPI grid: total, RAG counts, recent updates, drill-down actions |
| `ConsultarProjetoCard.json` | ConsultarProjeto | Detalhe full do projeto + tarefas + riscos + decisões pendentes |
| `ListarTarefasCard.json` | ListarTarefas | Lista interativa de até 10 tarefas com inline actions (Edit, Mark Done, Delete) |
| `ResumoExecutivoPortfolio.json` | ResumoExecutivo | Card executivo já existente — refinar conforme design system |

**Acceptance:** Same schema/size constraints as REQ-M2-02

---

### REQ-M2-04 — Card de erro padronizado

**Priority:** P0
**Phase:** 3 (Card Design)

**Scope:** 1 card universal

| Card | Uso |
|---|---|
| `OpsFailureCard.json` | Posted via PM0_PA_OpsFailureHandling em qualquer falha de write/read. Contém: tipo do erro (sanitized), correlation ID, próxima ação sugerida, contato suporte. |

**Acceptance:** Schema válido, sem stack traces expostos, sanitização garantida.

---

### REQ-M2-05 — XPIA zero recurrences

**Priority:** P0
**Phase:** 7 (Smoke E2E)
**Verification source:** `tests/Test-Aq09SmokeEvidence.ps1` + manual chat traces

**Acceptance:**
- 12 comandos AQ-09 smoke executados em runtime após M2 publish
- 0 ocorrências de `ContentFiltered` / `openAIIndirectAttack` em qualquer trace
- Em caso de recurrence: ADR de fallback strategy (Strategy α/β/γ) ativada antes do ship final

---

### REQ-M2-06 — Topics preservation

**Priority:** P0
**Phase:** 5 (Topic Update)

**Acceptance:**
- Topics atuais mantêm: trigger queries, regex parsing, condition groups, prompts, confirm gates
- Mudança ÚNICA: substituir o `InvokeFlowAction`/`BeginDialog` final pelo target PM0_PA_Card_*
- Diff por topic: <30 linhas alteradas em média
- Tests existentes (`Test-CriarTarefaContract`, etc.) continuam PASS

---

### REQ-M2-07 — Dual-entry flow pattern

**Priority:** P0
**Phase:** 4 (Flow Build)

**Pattern:**

```
Trigger schema:
{
  "action": "preview" | "submit",  // dispatch key
  "operationId": "<guid>",          // correlation
  "routeKey": "<route>",            // routing target
  "...operation-specific fields"
}

Flow logic:
IF action = "preview":
  - Validate inputs
  - Compose confirmation card with operation data + Confirmar/Cancelar buttons embedding action="submit", operationId, all fields
  - Post card to route(s) — DM and/or Channel per ADR-001 routing matrix
  - Return static ack to Copilot: "Card enviado para confirmação no Teams."

IF action = "submit":
  - Re-validate inputs (defensive)
  - Idempotency check via operationId
  - Write SharePoint
  - Sync Planner (if applicable)
  - Update card with success state OR post result card
  - Return static ack: "Operação concluída."
```

**Acceptance:**
- Todos 12 PM0_PA_Card_* implementam dual-entry
- Idempotency verified (re-submit do mesmo operationId não duplica writes)
- Cancel button no card não deixa lixo

---

### REQ-M2-08 — Routing matrix DM + Canal por audiência

**Priority:** P0
**Phase:** 2 (Architecture Spec) + 4 (Flow Build)
**Source of truth:** `decisions/ADR-001-end-state-card-first-hybrid.md`

**Matriz definitiva** (DM = direct chat com criador da operação; Canal = canal Teams apropriado):

| Operação | DM (criador) | Canal (audiência) |
|---|---|---|
| CriarProjeto | Confirm + Result card | `board.status` (broadcast novo projeto) |
| ConsultarProjeto | Result card | — (privado) |
| ExcluirProjeto | Confirm + Result card | `pmo.ops` (audit trail) |
| CriarTarefa | Confirm + Result card | `pm.status.updates` (PM responsável recebe) |
| ListarTarefas | Result card | — (privado) |
| AtualizarTarefa | Confirm + Result card | `pm.status.updates` (mudança visível ao PM) |
| ExcluirTarefa | Confirm + Result card | `pmo.ops` (audit trail) |
| AtualizarStatus | Confirm + Result card | `pm.status.updates` + `board.status` (se RAG=Vermelho, broadcast diretoria) |
| RegistrarRisco | Confirm + Result card | `pmo.ops` (PMO ops alerta) |
| RegistrarBloqueio | Confirm + Result card | `pmo.ops` (PMO ops alerta) |
| PedirDecisao | Confirm card (criador) | `board.status` (decision card ao aprovador) |
| ConsultarPortfolio | Result card | `board.status` (se solicitado por executivo) — opcional |

**Acceptance:**
- ADR-001 com matriz formalizada
- Cada flow PM0_PA_Card_* implementa o routing correto baseado em operação
- Smoke valida que DMs chegam ao usuário correto e canais recebem broadcasts esperados

---

### REQ-M2-09 — Schema SharePoint completo

**Priority:** P0
**Phase:** 6 (Schema Update)

**Mudanças em `Tarefas`:**

| Campo | Tipo | Default | Razão |
|---|---|---|---|
| `PlannerTaskId` | Single line text | empty | Sync key Planner ↔ SP |
| `PlannerBucketId` | Single line text | empty | Bucket atual da tarefa |
| `PlannerSyncStatus` | Choice [`OK`,`Erro`,`Pending`,`NotApplicable`] | `Pending` | Health do sync |
| `PlannerLastSyncAt` | DateTime | empty | Timestamp última sync |
| `PlannerSyncError` | Multiline text (sanitized) | empty | Última msg de erro do sync |

**Outras listas (verificar via Discovery Phase 1):**
- `Projetos` — pode precisar de `PlannerGroupId`, `PlannerPlanId` por projeto se houver multi-plan
- `Status Diario` — review se precisa de novos campos
- `Riscos e Bloqueios` — review se precisa de novos campos
- `Decisoes do Board` — review se precisa de novos campos

**Acceptance:**
- Schema applied via PnP script com `-WhatIf` aprovado
- Discovery script confirma campos presentes
- Nenhum dado existente perdido

---

### REQ-M2-10 — Planner Bucket IDs lockados

**Priority:** P0
**Phase:** 4 (Flow Build)
**Source:** AQ-04 evidence pack

**Mapping definitivo:**

| Status | Bucket ID | percentComplete |
|---|---|---:|
| Pendente | `HmzyGOgC4k6uOPm_cwG3zZcAGiAG` | 0 |
| Em Andamento | `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG` | 50 |
| Testes | `7QYPufh54kum7MP4KUzzAZcAL6Ik` | 50 |
| Piloto e Implantacao | `4YAXH7iU9E-6jZE2P1DbG5cAMAzH` | 50 |
| Concluido | `F2WYUsnXeEue5qlwQuu3GJcAN1Ns` | 100 |
| Cancelado | `90TcFTFup0CjiHIdzY4gG5cALWKL` | 100 |

**Plan ID:** `-1kBj1PLv0qQM-R4PwkqbpcABv_P`
**Group ID:** `96c5b0c4-46cc-46cd-8695-50451db74994`

**Acceptance:** Hard-coded no PM0_PA_Card_CriarTarefa e PM0_PA_Card_AtualizarTarefa.

---

### REQ-M2-11 — BLK-AT-001 skip semantics resolvidas

**Priority:** P0
**Phase:** 4 (Flow Build) + 3 (Card Design)

**Acceptance:**
- `nao` / `n` / `blank` / `0` em campo Hours preservam valor existente no SP
- Card de confirmação exibe "(mantido)" no lugar de `nao` literal
- `tests/Test-AtualizarTarefaResponseDisplay.ps1` PASS após patch

---

### REQ-M2-17 — 12 fluxos PM0_PA_Card_* ativos

**Priority:** P0
**Phase:** 4 (Flow Build)

**Inventário target:**

Refactor (5 atuais):
- `PM0_PA_Card_AtualizarStatus` (refactor for dual-entry hybrid)
- `PM0_PA_Card_AtualizarTarefa` (refactor for dual-entry hybrid + BLK-AT-001 fix)
- `PM0_PA_Card_CriarTarefa` (refactor for dual-entry hybrid)
- `PM0_PA_Card_ListarTarefas` (refactor for hybrid result card)
- `PM0_PA_Card_ResumoExecutivoPortfolio` (refactor for hybrid + ConsultarPortfolio semantic merge)

New (7):
- `PM0_PA_Card_CriarProjeto`
- `PM0_PA_Card_ConsultarProjeto`
- `PM0_PA_Card_ExcluirProjeto`
- `PM0_PA_Card_ExcluirTarefa`
- `PM0_PA_Card_RegistrarRisco`
- `PM0_PA_Card_RegistrarBloqueio`
- `PM0_PA_Card_PedirDecisao`

Reusable (1):
- `PM0_PA_OpsFailureHandling` (already exists, validate)

**Acceptance:** 13 flows ativos no Dataverse, todos com `Activado` state, todos importados via solution-aware path.

---

### REQ-M2-18 — Topics 100% PM0 (zero PMO_PA_* em topics ativos)

**Priority:** P0
**Phase:** 5 (Topic Update)

**Acceptance:** PAC FetchXML diff confirma 0 references a `PMO_PA_*` em topics ativos. `Test-Aq08PostRemediationReverify.ps1` retorna PASS for all 12 in-scope topics.

---

### REQ-M2-19 — Legacy decommission timeline

**Priority:** P0
**Phase:** 9 (Cutover) + post-launch

**Timeline:**
- T+0 (M2 publish): 12 PMO_PA_* legacy → state=Deactivated (não delete)
- T+30 dias produção estável (zero P0 incidents): 12 PMO_PA_* → DELETE
- Backup: solution export pre-deactivation guardado em `Solution/legacy_pmo_pa_backup_20260520.zip`

**Acceptance:** ADR-002 (decommission timeline) registrado + execution checklist em `phases/09_cutover/`.

---

## P1 — High Priority

### REQ-M2-12 — Manual Operacional v1.0

**Priority:** P1
**Phase:** 8 (Documentation)

**Acceptance:**
- `docs/MANUAL_OPERACIONAL_PMO_v1_0.md` completo PT-BR
- Screenshots reais capturados durante Fase 7 smoke
- Cobre 12 operações + troubleshooting + FAQ

---

### REQ-M2-13 — Release notes 3.16

**Priority:** P1
**Phase:** 8 (Documentation)

**Acceptance:**
- PT-BR + EN
- Sumário executivo + breaking changes (zero esperado) + new features + known issues + monitoring

---

### REQ-M2-14 — Rollback procedure validada

**Priority:** P1
**Phase:** 9 (Cutover)

**Acceptance:**
- Procedure documentada em `phases/09_cutover/ROLLBACK_PROCEDURE.md`
- Pre-tested via dry-run (sem executar tenant write)
- RTO target: 15 min
- Rollback target: `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip`

---

### REQ-M2-15 — Post-publish monitoring runbook

**Priority:** P1
**Phase:** 8 (Documentation)

**Acceptance:**
- 24h sentinel + 30-day stability checklist
- Sinais a observar: PA run history, SharePoint audit, Copilot analytics, user feedback
- Daily check-in template para owner

---

### REQ-M2-16 — Cleanup test data

**Priority:** P1
**Phase:** 6 (Schema Update — pre-publish)

**Acceptance:**
- Script PnP run + evidence: 0 candidatos de teste 2026-05-10/13 ativos pós-cleanup
- Soft-delete only (Deleted=Yes), nada deletado fisicamente

---

## Acceptance Criteria Summary

| Phase | Gate criteria |
|---|---|
| 1 — Discovery | Inventory 100% completo, gap list lockada |
| 2 — Architecture Spec | ADR-001 (routing) + ADR-002 (decommission) + arch doc reviewed e aprovado pelo owner |
| 3 — Card Design | 13 cards JSON validados schema + visual review owner |
| 4 — Flow Build | 13 flows ativos + importados + dual-entry verified |
| 5 — Topic Update | 12 topics PM0-only + zero PMO_PA_* + reverify PASS |
| 6 — Schema Update | Planner mapping fields applied + 0 test data residual |
| 7 — Smoke E2E | 12 operações × DM + canal verificados + 0 XPIA recurrences |
| 8 — Docs | Manual v1.0 + Release Notes + Monitoring runbook entregues |
| 9 — Cutover | Publish 3.16 + rollback validado + monitoring ativo |

---

*Last updated: 2026-05-20 17:46 BRT*
