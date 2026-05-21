# PMO Intelligent Hub — M2: Hybrid Card-First Revision

**Milestone:** M2
**Status:** Active — bootstrapping 2026-05-20
**Owner:** Manoel Benicio
**Architect:** Opus 4.7
**Predecessor:** M1 — PMO Hub MVP Chat-First (delivered 3.15 dev/test, NOT shipped to production)
**Target ship:** `Solution/PMO_v11_Tarefas_3_16.zip` to `ColOfertasBrasilPro`

---

## What This Is

PMO Intelligent Hub é um agente Microsoft 365 que centraliza toda a operação de gestão de projetos de transformação digital — criação de projetos e tarefas, atualização de status diário, registro de riscos e bloqueios, decisões do board, e consulta executiva de portfólio. Os usuários são PMs e diretoria; o sistema usa Copilot Studio + Power Automate + SharePoint + Planner + Teams Adaptive Cards.

**M2 promove o produto do padrão chat-first puro (M1) para um padrão híbrido card-first**, onde o usuário coleta dados via conversa no chat e confirma a ação clicando num Adaptive Card no Teams. Isso resolve simultaneamente:

1. O risco recorrente de `ContentFiltered` / `openAIIndirectAttack` (XPIA) que bloqueou três releases consecutivos (3.13/3.14/3.15)
2. A ausência de audit trail visual e confirmação tangível para operações críticas (write SharePoint/Planner)
3. A inconsistência operacional onde 5 fluxos eram parcialmente card-aware enquanto outros 7 permaneciam chat-only

## Core Value

**Toda operação PMO crítica gera evidência visual auditável (card no Teams) sem forçar o usuário a abandonar o chat.**

Se tudo mais falhar, isso precisa funcionar: usuário fala no chat → confirma no card → dado vai pro SharePoint/Planner → audit trail completo.

## Requirements

### Validated (de M1, ainda válidos)

- ✓ Soft-delete logical em todas as 5 listas SharePoint (`Deleted`, `DeletedAt`, `DeletedReason`, `DeletedByUPN`)
- ✓ Confirm-before-action pattern obrigatório para todas as escritas
- ✓ Cold Start NLU (Greeting + Fallback SmartRedirect) garantindo reconhecimento na 1ª mensagem
- ✓ Standard-only connector policy (sem Premium, sem Graph direto, sem Entra registration)
- ✓ Tenant fixo: `ColOfertasBrasilPro` (env id `e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- ✓ ProjectID/TaskID/DecisionID model para traceability
- ✓ Routing de project vs task (CriarProjeto separado de CriarTarefa, sem cross-routing)

### Active (M2 scope)

- [ ] **REQ-M2-01** — 12 operações user-facing migradas para padrão híbrido card-first uniformemente
- [ ] **REQ-M2-02** — Adaptive Cards de confirmação para cada uma das 12 operações de write
- [ ] **REQ-M2-03** — Adaptive Cards de result/summary para as 4 operações de read (ConsultarPortfolio, ConsultarProjeto, ListarTarefas, ResumoExecutivo)
- [ ] **REQ-M2-04** — Adaptive Cards de erro padronizados via `PM0_PA_OpsFailureHandling`
- [ ] **REQ-M2-05** — XPIA (`ContentFiltered`) zero recurrences nas 12 operações in scope (validado em runtime smoke)
- [ ] **REQ-M2-06** — Topics atuais preservados em ~80% (chat collection) com mudança apenas no call final (BeginDialog→PM0)
- [ ] **REQ-M2-07** — Pattern dual-entry para todos os flows de write: `entry=collect` (post confirm card) + `entry=submit` (após card click → write)
- [ ] **REQ-M2-08** — Routing matrix DM + Canal aplicada por audiência (ver decision matrix em `decisions/ADR-001`)
- [ ] **REQ-M2-09** — Schema SharePoint completo: `Tarefas` recebe `PlannerTaskId`, `PlannerBucketId`, `PlannerSyncStatus`, `PlannerLastSyncAt`, `PlannerSyncError` para sync bidirecional
- [ ] **REQ-M2-10** — Planner Bucket IDs lockados: `Pendente=HmzyGOgC4k6uOPm_cwG3zZcAGiAG`, `Em Andamento=ugZSNxsYW0WWCJ5Dtx0-l5cALVXG`, `Testes=7QYPufh54kum7MP4KUzzAZcAL6Ik`, `Piloto e Implantacao=4YAXH7iU9E-6jZE2P1DbG5cAMAzH`, `Concluido=F2WYUsnXeEue5qlwQuu3GJcAN1Ns`, `Cancelado=90TcFTFup0CjiHIdzY4gG5cALWKL`
- [ ] **REQ-M2-11** — `BLK-AT-001` skip semantics: `nao/n/blank/0` preservam valores existentes na atualização de tarefa, com display "(mantido)" no card de confirmação
- [ ] **REQ-M2-12** — Manual Operacional v1.0 com screenshots reais de produção pós-smoke
- [ ] **REQ-M2-13** — Release notes 3.16 PT-BR + EN para stakeholders
- [ ] **REQ-M2-14** — Rollback procedure pré-tested e documentada (target: `3.10_POST_WFSET_CLEAN.zip`)
- [ ] **REQ-M2-15** — Post-publish monitoring runbook (24h sentinel + 30 dias estabilidade)
- [ ] **REQ-M2-16** — Cleanup de dados de teste 2026-05-10/13 antes do M2 publish
- [ ] **REQ-M2-17** — 12 fluxos `PM0_PA_Card_*` ativos em Dataverse (5 atuais refatorados + 7 novos)
- [ ] **REQ-M2-18** — Topics referenciam exclusivamente `PM0_PA_Card_*` actions (zero `PMO_PA_*` legacy invocations)
- [ ] **REQ-M2-19** — `PMO_PA_*` legacy: 12 flows desativados após M2 publish, agendados para deletion em T+30 dias

### Out of Scope (M2)

- **Vertex AI / Google AI Studio integration** — projeto separado, não relacionado ao PMO M365 Standard-Only stack
- **STT (voice → intent) input** — diferido para M3+; usuário usa text input no chat (multiline OK)
- **Premium connectors** — restrição de licenciamento mantida; nada que requeira Premium
- **Microsoft Graph direto** — proibido por arquitetura
- **Microsoft 365 CLI (`m365`)** — não aprovado para discovery neste tenant
- **Adaptive Cards públicos em canais externos** — só os 2 canais já aprovados (`Projetos_Transformacao_Digital` + `QA_Projetos`) e DMs do owner/PMs
- **Multi-tenant** — apenas `ColOfertasBrasilPro`
- **Mobile-specific UX** — cards são responsive Adaptive Cards 1.4+, mas sem tratamento mobile-first dedicado
- **Cross-language UI** — apenas PT-BR para usuários finais; English permitido em ADRs/specs internos
- **Analytics dashboard externo** — Power BI ou similar não está em scope; consulta via Copilot é suficiente
- **Wave 3 Card-first puro (sem chat collection)** — usuário escolheu híbrido; pure card-first fica como M3 hipotético se houver demanda

## Context

**Histórico técnico relevante:**

- M1 entregou 3.15 com static-output bypass para mitigar XPIA. Local gates passaram, mas ship final foi abortado quando arquitetura híbrida foi escolhida (decisão owner em 2026-05-20).
- AQ-07 (executado entre 2026-05-15 e 2026-05-16) criou 5 flows `PM0_PA_Card_*` + 1 ops handler — todos ativos no Dataverse. M2 vai refatorá-los para aderir ao novo padrão híbrido (dual-entry) e criar 7 novos.
- 12 flows `PMO_PA_*` legacy estão ativos e funcionais; servirão como **failsafe de rollback** durante 30 dias pós-M2 publish, depois serão deletados.
- SharePoint schema base existe (5 listas, soft-delete fields). M2 adiciona Planner mapping fields em `Tarefas`.
- 4 channel routes definidos (`board.status`, `pmo.ops`, `pm.status.updates`, `task.card.route`) — M2 mantém os 4 e formaliza routing matrix por operação (ADR-001).
- `BLK-AT-001` (skip semantics no AtualizarTarefa) ainda em aberto — M2 resolve completamente.
- Padrão Adaptive Cards existente em `deploy/cards/` precisa de design system unificado (M2 entrega isso na Fase 3).

**Inventário runtime atual (data 2026-05-20):**

- 12 topics ativos em `pmo_AssistentePMO_V2`, todos com 1 erro detectado pelo Copilot Studio (1 deles com 5 erros) — provavelmente artefatos de import 3.15, M2 vai investigar e resolver.
- Active QA project: `QA Robust 20260513 F` (`PRJ-274E5ACC`, item 33 em Projetos)
- Active QA task: item 13 em Tarefas (atualmente soft-deleted)

## Constraints

- **Tech stack**: Microsoft 365 Standard tier — Copilot Studio, Power Automate Standard, SharePoint Online, Teams, Planner Standard. Sem Premium, sem Graph direto, sem Entra app reg, sem service principal.
- **Tenant**: apenas `ColOfertasBrasilPro` (env id `e2d10003-4d8e-e007-9d63-76d5fe89ef56`).
- **Provisioning**: SharePoint via Windows PowerShell 5.1 + `SharePointPnPPowerShellOnline 3.29.2101.0` + `Connect-PnPOnline -UseWebLogin`. Login + provisioning no mesmo processo PowerShell.
- **Tenant access**: todo comando obedece `.planning/TENANT_COMMAND_RUNBOOK.md` e `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`.
- **Performance**: Adaptive Cards <27KB cada (limite Teams).
- **Security**: nenhum dado pessoal sensível em chat traces; cards mascaram emails parcialmente quando aplicável.
- **Compliance**: audit trail via SharePoint soft-delete fields obrigatório em toda escrita.
- **Owner approval**: todo tenant write (import, publish, save flow, edit topic, schema change, Planner write) requer aprovação explícita do owner em thread atual.
- **Language**: UI em PT-BR, ADRs/specs em English ou PT-BR conforme convenção do projeto (mistos).

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Hybrid card-first sobre pure card-first | Melhor UX (não força usuário ao Teams) + menor esforço dev (preserva ~80% dos topics atuais) | — Pending validação runtime |
| Manter PMO_PA_* legacy desativados por 30 dias | Failsafe rollback se M2 tiver bug crítico em produção | — Pending publish |
| Channel routing por audiência (DM + Canal por operação) | Cada operação tem sua audiência natural; DM para confirmações privadas, canais para visibilidade coletiva | — Pending Fase 7 smoke |
| Versão de release: 3.16 (não 4.0) | Híbrido é evolução sobre 3.15, não revolução. 4.0 fica reservado se houver M3 pure card-first | — Pending |
| Planner Standard mantido (sem Premium) | Restrição de licenciamento + custo + AQ-04 já validou viabilidade | ✓ Good |
| Skip semantics resolvidas no card display ("(mantido)") | Mantém data integrity SP + UX clara | — Pending build Fase 4 |
| BLK-AT-001 fix nativo no PM0_PA_Card_AtualizarTarefa | Não vamos arrastar legacy patches | — Pending build |
| Vertex AI fora de scope | Não relacionado ao stack M365 Standard | ✓ Locked |
| Owner aprovação única (sem stakeholder externo) | Acelera Fase 3 (UX review) | ✓ Locked |
| Modo execução: continuous parallel + auto-advance gates | Velocidade > deliberação iterativa; quality gates protegem qualidade | ✓ Locked |
| Cleanup test data: pré-publish (não pós) | Evita ruído nos testes de smoke E2E | — Pending Fase 6 |
| 30-day production sentinel pré-deletion legacy | Padrão de decommission seguro em sistemas críticos | — Pending |

---

*Last updated: 2026-05-20 17:46 BRT after M2 bootstrap by Opus 4.7*
