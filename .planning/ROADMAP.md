# PMO Intelligent Hub — Roadmap

## Milestone 1: MVP Standard-Only Deploy

### Phase 0: Preparação e Validação do Ambiente ✅ DONE
- Conectores e DLP validados
- Canal Teams oficial definido: `Projetos_Tranformação_Digital`
- SharePoint oficial definido: `Grp_T_DN_Transformacao_Digital`
- GSD Framework instalado (v1.39.1)
- PRD v1.3 ajustada e aprovada (94/100)
- **Requirements:** Preparação
- **Depends on:** nada

### Phase 1: SharePoint Provisioning Programático ✅ DONE
- Criar 4 SharePoint Lists: Projetos, Status Diário, Riscos e Bloqueios, Decisões
- Criar todas as colunas com tipos corretos (Text, Choice, Person, DateTime, Number, Lookup)
- Indexar colunas críticas: StatusRAG, ProjectID, DataRegistro, Ativo, Sponsor, PM
- Criar views: Board (agrupado RAG), Gallery, List, Calendar
- Criar lista opcional: Marcos e Entregas
- Criar SharePoint Page Dashboard
- Cadastrar 5 projetos piloto
- **Requirements:** REQ-03, REQ-13
- **Depends on:** Phase 0
- **Agent:** Codex Sub-1 (SharePoint Specialist)
- **Validation:** Listas criadas, views renderizam, dados piloto inseridos
- **Gate:** G1 PASSED em 2026-05-02
- **Evidence:** `.planning/comms/g1_legacy_pnp_provisioning_20260502_115923.log`, `.planning/comms/g1_legacy_pnp_verify_20260502_120214.log`
- **Access Runbook:** `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`

### Phase 2: Power Automate Flows — Core (P0)
- **Handoff Input:** `.planning/comms/CODEX_HANDOFF_PHASE2.md`
- **Dispatch Status:** OPUS redesign applied; runtime E2E validation pending OPUS-ARCH/user.
- **Power Platform Environment:** `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- Criar flow `PMO_PA_EnviarCheckInDiario` (Recurrence 9h → Post Card Teams) — REDESIGNED via ProcessSimple PATCH `e117bbc5-5684-4191-8d03-fb183452ac5f`; now uses Teams `PostCardAndWaitForResponse` and writes response to SharePoint
- Criar flow `PMO_PA_ProcessarRespostaCheckIn` (Card response → Grava SP) — DISABLED after redesign, kept for reference `6c8ae320-46e0-42da-bc05-5d5a9622be03`
- Criar flow `PMO_PA_AlertaProjetoVermelho` (When modified RAG=Vermelho → Alerta) — CREATED via portal, then WIRED via ProcessSimple PATCH `5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd`
- Criar flow `PMO_PA_CheckInOnDemand` (Manual trigger → Card imediato) — REDESIGNED via ProcessSimple PATCH `c9e51483-38e7-422a-98cd-cf7604d14a16`; now uses Teams `PostCardAndWaitForResponse` and writes response to SharePoint
- Criar flow `PMO_PA_AlertaSemAtualizacao` (Recurrence 10h → Lembrete PMs) — EXISTS by evidence `0550c8ba-faf8-4e21-864e-d1fa5f625ce7`
- Criar 3 Adaptive Cards JSON (<27KB cada)
- **Requirements:** REQ-01, REQ-04, REQ-05, REQ-08
- **Depends on:** Phase 1
- **Agent:** Codex Sub-2 (Power Automate Expert)
- **Validation:** PASSED. Redesign definitions accepted and deployed. **E2E runtime confirmed 2026-05-04:** Teams screenshot shows `ResumoDiarioBoard` and `ResumoSemanal` cards rendered with live SharePoint data (5 projetos, RAG distribution) in channel `Projetos_Tranformação_Digital`.
- **Gate:** G2 PASSED em 2026-05-04 (upgraded from CONDITIONAL after E2E evidence)

### Phase 3: Power Automate Flows — Extended (P1/P2) ✅ DONE
- Criar flow `PMO_PA_ResumoDiarioBoard` (Recurrence 17h → Card consolidado)
- Criar flow `PMO_PA_RegistrarDecisaoBoard` (When created Decisões → Card aprovação)
- Criar flow `PMO_PA_EscalarRiscoCritico` (When created Riscos Severidade=Crítica → Alerta)
- Criar flow `PMO_PA_SyncPlannerStats_Standard` (Recurrence → Planner Standard List tasks → calcula métricas → Update SP)
- Criar flow `PMO_PA_ResumoSemanal` (Recurrence segunda 8h → Card expandido)
- **Requirements:** REQ-06, REQ-07, REQ-09, REQ-11, REQ-12
- **Depends on:** Phase 2
- **Agent:** Codex Sub-2 (Power Automate Expert)
- **Validation:** G3 PASSED for structural deployment. All five Phase 3 flows are live, started, enabled, and exported; runtime E2E remains deferred to Phase 6.
- **Gate:** G3 PASSED em 2026-05-03
- **Evidence:** `.planning/comms/g3_phase3_p1p2_summary_20260503_111051.json`, `.planning/comms/g3_phase3_card_validation_20260503_111051.json`, `.planning/comms/flow_definition_PHASE3_*`, `.planning/comms/flow_summary_PHASE3_*`

### Phase 4: Copilot Studio Agent ✅ DONE
- Criar agente "Assistente PMO" no Copilot Studio
- Configurar autenticação: Authenticate with Microsoft
- Criar 4 entidades customizadas: ProjectName, StatusRAG, RiskSeverity, ImpactLevel
- Criar 8 topics com trigger phrases pt-BR
- Conectar topics aos flows PA aprovados (ProcessarResposta, EscalarRisco, RegistrarDecisao)
- Implementar Confirm-Before-Action em todos topics de escrita
- Configurar LowConfidence fallback (NLU <0.6)
- Restringir fontes: apenas SharePoint PMO-Hub
- Bloquear HTTP, public websites, Graph direto
- Publicar no Teams com Authenticate with Microsoft
- **Requirements:** REQ-02, REQ-09, REQ-10
- **Depends on:** Phase 3
- **Agent:** Codex Sub-3 (Copilot Studio Expert)
- **Validation:** G4 PASSED for programmatic/structural completion. Agent `Assistente PMO` is Published/Active/Provisioned in `ColOfertasBrasilPro`; bot language is pt-BR, Teams channel config is present, GPT/model/web knowledge restrictions are enabled, PMO SharePoint knowledge source is bound, and three PA action workflows are active. Runtime Teams conversation and E2E write validation remain deferred to Phase 6 QA.
- **Gate:** G4 PASSED em 2026-05-03
- **Evidence:** `.planning/comms/g4_knowledge_patch_manifest_20260503_140052.json`, `.planning/comms/g4_assistente_pmo_export_complete_final_20260503_1400.yaml`, `.planning/comms/PMO_G4_Completion_final_20260503_1404.zip`, `.planning/comms/PMO_G4_Completion_final_20260503_1404/`, `.planning/comms/OPUS_HANDOFF_G4_COMPLETE.md`

### Phase 5: Teams Integration e Visibilidade ✅ DONE
- Embeddar SP views como tabs no canal Teams oficial
- Criar tab "Portfólio Executivo" (Board View agrupada por StatusRAG) — ✅ Tab `Portfolio_Executivo` criada
- Criar tab "Projetos Críticos" (List View filtrada RAG=Vermelho) — ✅ Tab `Projetos_Criticos` criada
- Criar tab "Decisões Pendentes" (List View filtrada Status=Pendente) — ✅ Tab `Decisoes do Board` criada
- Configurar canais temáticos: Board Status, Riscos, Decisões
- Criar Forms fallback como tab no canal
- **Requirements:** REQ-03
- **Depends on:** Phase 1
- **Agent:** Manual (Teams UI) — Graph API auth was blocked; manual tab creation was the approved fallback.
- **Validation:** PASSED. 3/3 SharePoint list tabs created in Teams channel `Projetos_Tranformação_Digital`. `Portfolio_Executivo` shows Board RAG view with StatusRAG groups (Amarelo=2, Verde=2, Vermelho=1); `Projetos_Criticos` shows filtered Vermelho view with PRJ-003 Portal do Colaborador 25%; `Decisoes do Board` shows Pendentes view (empty — no pending decisions yet). User screenshots confirm all tabs visible and functional.
- **Gate:** G5 PASSED em 2026-05-04
- **Evidence:** User screenshots 2026-05-04T07:32–07:37, `deploy/PHASE5_TEAMS_TABS_BROWSER_GUIDE.md`, `.planning/comms/g5_sharepoint_views_20260503_142829.json`, `.planning/comms/G5_NO_GRAPH_FALLBACK.md`

### Phase 6: Piloto Controlado + QA
- Onboarding 3 PMs piloto (treinamento 30min)
- Teste E2E: PM atualiza via card → Board vê na tab
- Teste E2E: PM atualiza via Copilot (voz) → Board vê na tab
- Teste E2E: Projeto vira vermelho → Sponsor recebe alerta
- Teste E2E: Decisão solicitada → Sponsor aprova via card
- Teste E2E: PM não atualiza → Lembrete automático às 10h
- Teste E2E: Consulta portfólio via Copilot → resposta formatada
- Teste Planner Sync: métricas de tarefas aparecem na lista Projetos
- Monitorar taxa de adoção por 5 dias
- Coletar feedback e ajustar
- **Requirements:** Todos REQs
- **Depends on:** Phase 4, Phase 5
- **Agent:** Codex 1 (QA Lead) + Sub-agents
- **Validation:** >70-80% taxa de atualização diária por 5 dias consecutivos

### Phase 2.4: Correcao de Contrato CriarProjeto/CriarTarefa + Gerar_Multiplos_Projetos
- Separar semanticamente `CriarProjeto` e `CriarTarefa`.
- `CriarProjeto` preserva a criacao de projetos na lista `Projetos`, com duplicate guard e `ProjectID` gerado pelo sistema.
- `CriarTarefa` cria tarefas somente na lista `Tarefas`, apos resolver projeto ativo/nao deletado em `Projetos`.
- Criar `Gerar_Multiplos_Projetos` para abertura em lote de projetos e tarefas iniciais pareadas por indice.
- Plano A: Adaptive Card de revisao/confirmacao antes de qualquer escrita.
- Plano B: texto multilinha e Speech-to-Text achatado quando card nao renderizar, usuario estiver em mobile/voz, ou houver bloco estruturado colado.
- Limite inicial: ate 10 projetos e 10 tarefas no modo simples por indice.
- **Requirements:** REQ-14, REQ-15, REQ-16
- **Depends on:** Phase 4, Phase 6 runtime evidence for current bot, package 2.3 ExcluirTarefa guard.
- **Validation:** static gates for topic routing, flow target lists, Adaptive Card contract, fallback parser, no Premium/Graph/HTTP, and runtime smoke after owner-approved import/publish.
- **Gate:** NO-SHIP until local package 2.4 passes static audits and owner completes controlled runtime validation.
