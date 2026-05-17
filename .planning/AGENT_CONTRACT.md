# PMO Intelligent Hub — Agentic Contract & Communication Protocol

## 1. Agent Registry

| Agent ID | Name | Role | Model | Capabilities |
|----------|------|------|-------|-------------|
| `OPUS-ARCH` | Opus 4.6 | Principal Solutions Architect | Claude Opus 4.6 | Arquitetura, PRD, revisão, decisões, aprovação de gates |
| `CODEX-LEAD` | Codex 1 (5.5 HT) | Senior Deployment Engineer + QA + Troubleshooting | o1 5.5 high-think | Orquestração deploy, QA E2E, troubleshooting |
| `CODEX-SP` | Codex Sub-1 | SharePoint Provisioning Agent | o1 5.5 | Criação de listas, colunas, views, índices, pages, tabs |
| `CODEX-PA` | Codex Sub-2 | Power Automate Flows Agent | o1 5.5 | Criação de flows, adaptive cards, triggers, conditions |
| `CODEX-CS` | Codex Sub-3 | Copilot Studio Agent | o1 5.5 | Topics, entities, NLU, publicação, guardrails |

---

## 2. Communication Protocol

### 2.0A. Active P0 Agentic Delivery Protocol

For the Adaptive Cards + Planner P0 delivery, the mandatory point of coordination is:

```text
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
```

This file supersedes ad hoc progress reporting for the P0 delivery. Every active agent must write updates:

1. when starting work;
2. before editing files;
3. after editing files;
4. every 5 minutes while actively working;
5. immediately when blocked;
6. immediately when handing off work;
7. at completion.

Failure to update the check-in board means downstream agents must treat that task as at risk until status is re-confirmed.

Active P0 roster:

| Agent ID | Role | Write Scope |
|---|---|---|
| `CODEX-LEAD` | Integration owner and gatekeeper | Final integration, gates, task assignment |
| `GEMINI-PA` | Power Automate principal deploy engineer | Flow design/definitions only |
| `CODEX-DOCS` | Governance/docs sub-agent | `.planning`, `PRD`, `docs` documentation only |
| `CODEX-CARDS` | Adaptive Cards sub-agent | `deploy/cards/*.json`, card visual standards |
| `CODEX-QA` | QA/evidence sub-agent | `tests/*`, evidence docs, read-only readiness reports |

Mandatory file-scope rule:

No two agents may edit the same file, same Copilot topic, same flow definition, same solution package, or same Adaptive Card JSON at the same time.

Mandatory access protocol:

```text
.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
```

All agents must use the project master docs/runbooks for tenant, SharePoint, Power Automate, Teams, Planner, Copilot Studio, and remote access. Do not use Microsoft 365 CLI / `m365` for discovery or Planner lookup in this project. The master docs are the access authority:

- `.planning/TENANT_COMMAND_RUNBOOK.md`
- `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
- `docs/TAILSCALE_SSH_CONNECTIVITY_GUIDE.md`
- `.planning/CURRENT_BASELINE.md`
- `.planning/GOLDEN_RULES.md`
- `docs/MANUAL_OPERACIONAL_PMO.md` when PMO runtime behavior is involved

Before any access-related command, the agent must post the exact planned route/command in the P0 check-in board and wait for the required owner approval gate.

Mandatory SEV-0 quality gate rule:

CI may be ignored only when explicitly owner-excluded. Every other quality gate is mandatory before any ship/import/publish/runtime-readiness decision. If any non-CI gate is missing, failed, stale, unverified, or not tied to the current artifact, the release decision is `NO-SHIP`.

### 2.0B. Mandatory Task I/O Contract

For the Adaptive Cards + Planner P0 delivery, every task assigned to any agent must follow:

```text
.planning/comms/AGENT_TASK_IO_CONTRACT_PROTOCOL_20260515.md
```

Each task must explicitly define:

- `TASK_ID`
- `INPUTS`
- `OUTPUTS`
- `WRITE_SCOPE`
- `DELIVERY_FORMAT`
- `VALIDATION_REQUIRED`
- `QUALITY_GATES_REQUIRED`
- `EVIDENCE_REQUIRED`
- `ACCEPTANCE_CRITERIA`
- `REJECTION_CRITERIA`
- `HANDOFF_STATUS_ALLOWED`
- `FINAL_RESPONSE_REQUIRED`

If any of these are missing, the agent must stop and report:

```text
BLOCKED_FOR_INPUT_CONTRACT
```

If applicable quality gates or evidence requirements are missing, the agent must stop and report:

```text
BLOCKED_FOR_GATE_CONTRACT
```

If the output uses the wrong format, lacks required files, lacks validation, or contains ambiguous placeholders such as `TBD`, `same as above`, or `same context`, the task status is:

```text
BLOCKED_REWORK_REQUIRED
```

Blocked output cannot be used to request owner approval for tenant write, import, publish, runtime, or release gates.

### 2.0. Mandatory Power Platform Environment
Todas as fases que envolvem Power Platform, Power Automate ou Copilot Studio devem usar sempre o ambiente `ColOfertasBrasilPro`.

| Property | Value |
|----------|-------|
| Environment display name | `ColOfertasBrasilPro` |
| Environment ID | `e2d10003-4d8e-e007-9d63-76d5fe89ef56` |
| Environment URL | `https://colofertasbrasilpro.crm4.dynamics.com/` |
| Org ID | `e0b9c35e-79a2-ef11-8a66-000d3a24857a` |
| Unique name | `unqe0b9c35e79a2ef118a66000d3a248` |

Não usar Default environment para Power Automate, Copilot Studio, PAC, solution import/export ou validações de flows.

### 2.1. Message Bus (File-Based)
Todos os agentes se comunicam via arquivos markdown no diretório `.planning/comms/`.

```
.planning/comms/
├── DISPATCH.md          ← OPUS-ARCH publica tarefas para CODEX-LEAD
├── CODEX_LEAD_LOG.md    ← CODEX-LEAD registra progresso e dispatcha sub-agents
├── SUB1_SP_LOG.md       ← CODEX-SP registra progresso SharePoint
├── SUB2_PA_LOG.md       ← CODEX-PA registra progresso Power Automate
├── SUB3_CS_LOG.md       ← CODEX-CS registra progresso Copilot Studio
├── GATE_STATUS.md       ← Status de cada gate (PASS/FAIL/BLOCKED)
└── ESCALATION.md        ← Issues escalados para OPUS-ARCH
```

### 2.2. Message Format
Cada entrada no log deve seguir o formato:

```markdown
### [TIMESTAMP] — [AGENT_ID] — [ACTION_TYPE]
- **Phase:** [phase number]
- **Task:** [task description]
- **Status:** STARTED | IN_PROGRESS | COMPLETED | FAILED | BLOCKED
- **Details:** [free text with evidence]
- **Artifacts:** [list of files created/modified]
- **Next:** [what the next agent should do]
- **Gate:** [PASS | FAIL | N/A]
```

### 2.3. Action Types
| Action | Emitter | Consumer |
|--------|---------|----------|
| `DISPATCH` | OPUS-ARCH | CODEX-LEAD |
| `ASSIGN` | CODEX-LEAD | Sub-agents |
| `PROGRESS` | Any | All |
| `GATE_CHECK` | Any | OPUS-ARCH |
| `ESCALATION` | Any | OPUS-ARCH |
| `APPROVAL` | OPUS-ARCH | CODEX-LEAD |
| `COMPLETION` | Any | All |

---

## 3. Contract: OPUS-ARCH (Principal Solutions Architect)

### Inputs
- PRD v1.3 (`PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md`)
- Estado atual (`.planning/STATE.md`)
- Escalações (`.planning/comms/ESCALATION.md`)

### Outputs
- Dispatch de fases (`.planning/comms/DISPATCH.md`)
- Aprovações de gates (`.planning/comms/GATE_STATUS.md`)
- Decisões arquiteturais (`.planning/STATE.md`)
- Revisões de PRD (PRD file)

### Responsibilities
1. Validar arquitetura contra PRD antes de cada fase
2. Revisar artefatos de cada gate antes de aprovar
3. Resolver escalações de sub-agents
4. Manter STATE.md atualizado com decisões
5. Aprovar ou rejeitar gates formalmente

### Guardrails
- **NÃO** implementa código diretamente
- **NÃO** modifica SharePoint, Power Automate ou Copilot Studio
- **SEMPRE** valida contra documentação oficial Microsoft
- **SEMPRE** documenta decisões com referências

---

## 4. Contract: CODEX-LEAD (Deployment Engineer)

### Inputs
- Dispatches de OPUS-ARCH (`.planning/comms/DISPATCH.md`)
- PRD v1.3 e ROADMAP.md

### Outputs
- Atribuições para sub-agents (`.planning/comms/CODEX_LEAD_LOG.md`)
- Gate checks (`.planning/comms/GATE_STATUS.md`)
- Troubleshooting reports

### Responsibilities
1. Receber dispatch de OPUS-ARCH e decompor em tarefas para sub-agents
2. Monitorar progresso de todos os sub-agents
3. Executar QA E2E após cada fase
4. Troubleshooting de falhas reportadas por sub-agents
5. Consolidar gate status para aprovação de OPUS-ARCH

### Sub-Agent Orchestration Rules
- Sub-agents rodam em **paralelo** quando não há dependência
- Sub-agents rodam em **sequência** quando Phase N depende de Phase N-1
- Cada sub-agent tem um **escopo isolado** e não acessa artefatos de outros sub-agents
- Sub-agents reportam COMPLETION antes que CODEX-LEAD inicie QA

---

## 5. Contract: CODEX-SP (SharePoint Provisioning)

### Inputs
- PRD Seções 6 (Modelo de Dados) e 8.4 (SP Limits)
- Atribuições do CODEX-LEAD

### Outputs
- SharePoint Lists criadas com schema completo
- Views configuradas (Board, Gallery, List)
- Índices criados nas colunas críticas
- Dados piloto inseridos
- Log em `.planning/comms/SUB1_SP_LOG.md`

### Deliverables Detalhados

#### Lista: Projetos
| Coluna | Tipo | Indexed | Required | Default |
|--------|------|---------|----------|---------|
| ProjectID | Single line text | ✅ | ✅ | PRJ-XXX |
| Nome | Single line text | ❌ | ✅ | — |
| PM | Person | ✅ | ✅ | — |
| Sponsor | Person | ✅ | ❌ | — |
| StatusRAG | Choice (Verde/Amarelo/Vermelho) | ✅ | ✅ | Verde |
| Percentual | Number (0-100) | ❌ | ❌ | 0 |
| DataAlvo | Date only | ❌ | ❌ | — |
| UltimaAtualizacao | Date and time | ✅ | ❌ | — |
| Ativo | Yes/No | ✅ | ✅ | Yes |
| Unidade | Choice | ❌ | ❌ | — |
| Prioridade | Choice (Alta/Média/Baixa) | ❌ | ❌ | Média |
| PlannerGroupId | Single line text | ❌ | ❌ | — |
| PlannerPlanId | Single line text | ❌ | ❌ | — |
| LinkPlanner | Hyperlink | ❌ | ❌ | — |
| TarefasTotal | Number | ❌ | ❌ | 0 |
| TarefasAbertas | Number | ❌ | ❌ | 0 |
| TarefasConcluidas | Number | ❌ | ❌ | 0 |
| TarefasAtrasadas | Number | ❌ | ❌ | 0 |
| PlannerLastSyncAt | Date and time | ❌ | ❌ | — |
| PlannerSyncStatus | Choice (OK/Erro/Pendente) | ❌ | ❌ | Pendente |
| DiasSemUpdate | Calculated (Now - UltimaAtualizacao) | ❌ | ❌ | — |
| ResumoExecutivo | Multiple lines text | ❌ | ❌ | — |

#### Lista: Status Diário
| Coluna | Tipo | Indexed | Required |
|--------|------|---------|----------|
| StatusID | Single line text | ✅ | ✅ |
| ProjectID | Single line text (Lookup-like) | ✅ | ✅ |
| DataRegistro | Date and time | ✅ | ✅ |
| PM | Person | ✅ | ❌ |
| RAG | Choice (Verde/Amarelo/Vermelho) | ❌ | ✅ |
| Resumo | Multiple lines text | ❌ | ✅ |
| Risco | Multiple lines text | ❌ | ❌ |
| Bloqueio | Multiple lines text | ❌ | ❌ |
| ProximaAcao | Multiple lines text | ❌ | ❌ |
| Percentual | Number (0-100) | ❌ | ❌ |
| OrigemEntrada | Choice (AdaptiveCard/CopilotStudio/FormsFallback/ManualPMO) | ❌ | ✅ |
| ResumoTarefas | Multiple lines text | ❌ | ❌ |
| CardVersion | Single line text | ❌ | ❌ |

#### Lista: Riscos e Bloqueios
| Coluna | Tipo | Indexed | Required |
|--------|------|---------|----------|
| RiskID | Single line text | ✅ | ✅ |
| ProjectID | Single line text | ✅ | ✅ |
| Tipo | Choice (Risco/Bloqueio) | ❌ | ✅ |
| Severidade | Choice (Baixa/Média/Alta/Crítica) | ✅ | ✅ |
| Descricao | Multiple lines text | ❌ | ✅ |
| Impacto | Choice (Baixo/Médio/Alto/Crítico) | ❌ | ❌ |
| Probabilidade | Choice (Baixa/Média/Alta) | ❌ | ❌ |
| Owner | Person | ❌ | ❌ |
| DataCriacao | Date and time | ❌ | ✅ |
| SLA | Date only | ❌ | ❌ |
| Status | Choice (Aberto/Em Mitigação/Escalado/Resolvido/Aceito) | ✅ | ✅ |
| PlanoMitigacao | Multiple lines text | ❌ | ❌ |
| EscaladoPara | Person | ❌ | ❌ |

#### Lista: Decisões do Board
| Coluna | Tipo | Indexed | Required |
|--------|------|---------|----------|
| DecisionID | Single line text | ✅ | ✅ |
| ProjectID | Single line text | ✅ | ✅ |
| Descricao | Multiple lines text | ❌ | ✅ |
| Solicitante | Person | ❌ | ✅ |
| Aprovador | Person | ❌ | ✅ |
| Prazo | Date only | ❌ | ❌ |
| Status | Choice (Pendente/Aprovada/Rejeitada/Adiada/Cancelada) | ✅ | ✅ |
| Resposta | Multiple lines text | ❌ | ❌ |
| DataResposta | Date and time | ❌ | ❌ |
| Impacto | Choice (Baixo/Médio/Alto/Crítico) | ❌ | ❌ |
| Justificativa | Multiple lines text | ❌ | ❌ |
| ApproverUPN | Single line text | ❌ | ❌ |
| CardVersion | Single line text | ❌ | ❌ |
| ResponseSource | Choice (AdaptiveCard/CopilotStudio/Manual) | ❌ | ❌ |

### Acceptance Criteria
- [ ] Todas as 4 listas criadas com schema exato acima
- [ ] Índices criados em todas as colunas marcadas como Indexed=✅
- [ ] Views Board (agrupada RAG), Gallery e List criadas na lista Projetos
- [ ] Views filtradas criadas para Riscos (Status=Aberto) e Decisões (Status=Pendente)
- [ ] 5 projetos piloto inseridos com dados realistas
- [ ] Permissions groups criados: PMO-PMs, PMO-Board, PMO-Admins, PMO-Sponsors

---

## 6. Contract: CODEX-PA (Power Automate Flows)

### Inputs
- PRD Seção 4.1 (10 flows listados com triggers)
- PRD Seção 7 (Requisitos Funcionais)
- PRD Seção 8.3 (PA Capacity Model)
- Adaptive Cards Schema Reference: https://adaptivecards.io/explorer/

### Outputs
- 10 Cloud Flows criados e testados
- 3 Adaptive Cards JSON validados (<27KB)
- Log em `.planning/comms/SUB2_PA_LOG.md`

### Flow Specifications

#### Flow 1: PMO_PA_EnviarCheckInDiario
- **Trigger:** Recurrence — diário 9h (UTC-3)
- **Input:** Lista Projetos (Ativo=Sim)
- **Actions:**
  1. Get items: Projetos WHERE Ativo=Yes
  2. For each projeto:
     a. Compose Adaptive Card JSON (Check-in template)
     b. Post adaptive card to Teams (canal ou chat PM conforme design)
- **Output:** Adaptive Card postado no Teams para cada PM
- **Error handling:** Log falha + continue loop
- **Size limit:** Card <27KB

#### Flow 2: PMO_PA_ProcessarRespostaCheckIn
- **Trigger:** When someone responds to an adaptive card (HTTP Response URL)
- **Input:** Card response payload (ProjectID, RAG, Resumo, Risco, Bloqueio, ProximaAcao, Percentual)
- **Actions:**
  1. Parse card response
  2. Create item: Status Diário (todos campos + OrigemEntrada=AdaptiveCard)
  3. Update item: Projetos (StatusRAG, Percentual, UltimaAtualizacao=utcNow())
  4. Condition: IF RAG=Vermelho → trigger child flow AlertaProjetoVermelho
- **Output:** Item criado em Status Diário + Projetos atualizado
- **Error handling:** Notify PMO on failure

#### Flow 3: PMO_PA_AlertaProjetoVermelho
- **Trigger:** When an item is created or modified — Projetos WHERE StatusRAG changed to Vermelho
- **Actions:**
  1. Get item details (Projeto)
  2. Get Sponsor from Person field
  3. Compose alert Adaptive Card
  4. Post to Teams channel "Projetos Críticos"
  5. Send email to Sponsor (Office 365 Outlook Standard)
- **Output:** Alerta postado + email enviado

#### Flow 4: PMO_PA_CheckInOnDemand
- **Trigger:** Manually triggered (button flow) ou When agent calls flow (Copilot)
- **Input:** ProjectID (from user)
- **Actions:**
  1. Get item: Projetos WHERE ProjectID=input
  2. Compose Check-in Adaptive Card
  3. Post to Teams (PM's chat or channel)
- **Output:** Card on-demand postado

#### Flow 5: PMO_PA_AlertaSemAtualizacao
- **Trigger:** Recurrence — diário 10h (UTC-3)
- **Actions:**
  1. Get items: Projetos WHERE Ativo=Yes
  2. Filter: UltimaAtualizacao < addDays(utcNow(),-1)
  3. For each projeto sem update:
     a. Post reminder card to PM
     b. Post to PMO channel list of delinquent projects
- **Output:** Lembretes enviados

#### Flow 6: PMO_PA_ResumoDiarioBoard
- **Trigger:** Recurrence — diário 17h (UTC-3)
- **Actions:**
  1. Get items: Projetos WHERE Ativo=Yes
  2. Count: total, verdes, amarelos, vermelhos
  3. Get items: Projetos WHERE UltimaAtualizacao < addDays(utcNow(),-1)
  4. Get items: Decisões WHERE Status=Pendente
  5. Compose summary Adaptive Card
  6. Post to Teams channel "Board Status"
- **Output:** Card consolidado no canal Board

#### Flow 7: PMO_PA_RegistrarDecisaoBoard
- **Trigger:** When an item is created — Decisões
- **Actions:**
  1. Get item details
  2. Compose Decision Adaptive Card (approve/reject/defer)
  3. Post card to Aprovador via Teams
  4. Wait for response (or use separate response flow)
  5. Update item: Decisões (Resposta, DataResposta, Status)
- **Output:** Card de decisão postado + resposta gravada

#### Flow 8: PMO_PA_SyncPlannerStats_Standard
- **Trigger:** Recurrence — a cada 6h (controlado)
- **Actions:**
  1. Get items: Projetos WHERE PlannerPlanId != empty AND Ativo=Yes
  2. For each projeto:
     a. List tasks (Planner Standard connector, by PlanId)
     b. Calculate: TarefasTotal, TarefasAbertas, TarefasConcluidas, TarefasAtrasadas, TarefasSemPrazo
     c. Update item: Projetos (métricas + PlannerLastSyncAt + PlannerSyncStatus=OK)
  3. On error per projeto: PlannerSyncStatus=Erro, PlannerSyncError=message
- **Output:** Métricas Planner atualizadas em Projetos
- **Concurrency:** Degree of parallelism = 1 (sequential loop to avoid throttling)

#### Flow 9: PMO_PA_EscalarRiscoCritico
- **Trigger:** When an item is created — Riscos e Bloqueios WHERE Severidade=Crítica
- **Actions:**
  1. Get item details
  2. Get Sponsor from linked Projeto
  3. Compose escalation Adaptive Card
  4. Post to Teams channel "Riscos"
  5. Send email to Sponsor + PMO Lead
- **Output:** Risco escalado automaticamente

#### Flow 10: PMO_PA_ResumoSemanal
- **Trigger:** Recurrence — segunda-feira 8h (UTC-3)
- **Actions:**
  1. Get items: Projetos (all active)
  2. Get items: Status Diário (last 7 days)
  3. Calculate trends: RAG changes, entregas, atrasos
  4. Get items: Decisões (última semana)
  5. Compose weekly summary Adaptive Card (extended)
  6. Post to Teams "Board Status"
- **Output:** Report semanal expandido

### Acceptance Criteria
- [ ] Todos os 10 flows criados e salvos no ambiente
- [ ] Flows 1-5 (P0) testados end-to-end
- [ ] Flows 6-10 (P1/P2) testados end-to-end
- [ ] Adaptive Cards renderizam em Teams Desktop + Mobile
- [ ] Cada card < 27KB validado
- [ ] Nenhum conector Premium utilizado (validar DLP)

---

## 7. Contract: CODEX-CS (Copilot Studio)

### Inputs
- PRD Seção 12 (Agentes de IA)
- PRD Seção 9 (Segurança e Governança)
- Flows PA ativos (output de CODEX-PA)

### Outputs
- Agente "Assistente PMO" publicado no Teams
- 8 Topics configurados
- 4 Entidades customizadas
- Log em `.planning/comms/SUB3_CS_LOG.md`

### Topic Specifications

#### Topic 1: AtualizarStatus
- **Trigger phrases:** "atualizar projeto", "status do [projeto]", "update [projeto]"
- **Slot filling:** ProjectName → StatusRAG → Resumo → Risco (optional) → ProximaAcao (optional) → Percentual (optional)
- **Confirm-Before-Action:** "Vou registrar: [projeto] como [RAG], resumo: [resumo]. Confirma?"
- **On confirm:** Call flow PMO_PA_ProcessarRespostaCheckIn
- **On deny:** "Ok, vamos refazer. Qual projeto?"
- **Response:** "✅ Status do [projeto] atualizado para [RAG]."

#### Topic 2: ConsultarPortfolio
- **Trigger phrases:** "como está o portfólio", "resumo dos projetos", "dashboard"
- **Action:** Query SharePoint Projetos WHERE Ativo=Yes
- **Response format:**
  ```
  📊 Portfólio PMO
  🟢 Verde: X projetos
  🟡 Amarelo: Y projetos
  🔴 Vermelho: Z projetos
  📋 Total: N projetos ativos
  ⚠️ Sem atualização (>24h): W projetos
  ```

#### Topic 3: ConsultarProjeto
- **Trigger phrases:** "como está o [projeto]", "status de [projeto]", "detalhes [projeto]"
- **Slot filling:** ProjectName
- **Action:** Query SharePoint Projetos + último Status Diário + Riscos abertos
- **Response format:**
  ```
  📌 [NomeProjeto]
  🚦 Status: [RAG]
  📈 Progresso: [Percentual]%
  📅 Alvo: [DataAlvo]
  👤 PM: [PM]
  📝 Último update: [data] — [resumo]
  ⚠️ Riscos abertos: [count]
  📋 Tarefas Planner: [abertas]/[total] (✅[concluídas] ⏰[atrasadas])
  ```

#### Topic 4: RegistrarRisco
- **Trigger phrases:** "registrar risco", "novo risco", "risco no [projeto]"
- **Slot filling:** ProjectName → Descrição → Severidade
- **Confirm-Before-Action:** "Risco: [desc] | Severidade: [sev] | Projeto: [proj]. Confirma?"
- **On confirm:** Create item in Riscos list + if Crítica → call PMO_PA_EscalarRiscoCritico
- **Response:** "✅ Risco registrado. [Se crítico: Escalação enviada para Sponsor.]"

#### Topic 5: RegistrarBloqueio
- **Trigger phrases:** "registrar bloqueio", "projeto bloqueado", "bloqueio em [projeto]"
- **Similar to RegistrarRisco but Tipo=Bloqueio**

#### Topic 6: PedirDecisao
- **Trigger phrases:** "preciso de uma decisão", "solicitar aprovação", "decisão para [projeto]"
- **Slot filling:** ProjectName → Descrição → Impacto → Prazo → Aprovador
- **Confirm-Before-Action:** Full summary before submission
- **On confirm:** Create item in Decisões + call PMO_PA_RegistrarDecisaoBoard
- **Response:** "✅ Solicitação de decisão criada. Card enviado para [Aprovador]."

#### Topic 7: LowConfidence
- **Trigger:** NLU confidence < 0.6
- **Response:** "Não entendi bem. Você pode reformular? Posso ajudar com: atualizar status, consultar portfólio, registrar risco, solicitar decisão."

#### Topic 8: Greeting
- **Trigger phrases:** "olá", "oi", "bom dia", "help"
- **Response:** Menu com opções disponíveis

### Acceptance Criteria
- [ ] Agente criado com nome "Assistente PMO"
- [ ] Autenticação = Authenticate with Microsoft
- [ ] 4 entidades customizadas criadas
- [ ] 8 topics funcionais com trigger phrases pt-BR
- [ ] Confirm-Before-Action testado em Topics 1, 4, 5, 6
- [ ] LowConfidence fallback funcional
- [ ] Publicado no Teams
- [ ] Sem acesso a fontes públicas/internet
- [ ] Sem HTTP externo

---

## 8. Gate Definitions

| Gate | Phase | Criteria | Approver |
|------|-------|----------|----------|
| G0 | Phase 0 | PRD aprovada, endpoints definidos, DLP validada | OPUS-ARCH ✅ |
| G1 | Phase 1 | Listas criadas, views OK, dados piloto, permissões | OPUS-ARCH |
| G2 | Phase 2 | 5 flows P0 ativos, cards renderizam | OPUS-ARCH |
| G3 | Phase 3 | 10 flows completos, métricas Planner sync OK | OPUS-ARCH |
| G4 | Phase 4 | Copilot publicado, 8 topics OK, Confirm-Before-Action OK | OPUS-ARCH |
| G5 | Phase 5 | Tabs no Teams, visibilidade executiva OK | OPUS-ARCH |
| G6 | Phase 6 | QA E2E pass, >70% adoção por 5 dias, feedback coletado | OPUS-ARCH |

---

## 9. Mandatory Update Protocol

Após a conclusão de cada tarefa, o agente responsável **DEVE**:

1. Atualizar seu log de comunicação (`.planning/comms/[AGENT]_LOG.md`)
2. Atualizar `.planning/STATE.md` (Current Phase, Next Phase, Active Agent)
3. Atualizar `.planning/ROADMAP.md` (marcar fase como DONE)
4. Atualizar `.planning/comms/GATE_STATUS.md` (se gate relevante)
5. Postar mensagem de COMPLETION no log para notificar o próximo agente

**NENHUM agente pode iniciar uma nova fase sem confirmar que a fase anterior está marcada como DONE no ROADMAP.md e GATE_STATUS.md.**

---

## 10. Escalation Protocol

Se um agente encontrar um problema que não consegue resolver:

1. Registrar em `.planning/comms/ESCALATION.md` com detalhes
2. Marcar status como BLOCKED no respectivo log
3. CODEX-LEAD tenta troubleshooting (3 tentativas)
4. Se não resolver, OPUS-ARCH é notificado via ESCALATION.md
5. OPUS-ARCH analisa e decide: corrigir, workaround, ou redesign

---

## 11. Rollback Protocol

Se uma fase falhar no gate:

1. Documentar falha no GATE_STATUS.md com evidências
2. CODEX-LEAD cria plano de correção
3. OPUS-ARCH aprova plano de correção
4. Sub-agent relevante executa correção
5. Gate é re-executado
6. Máximo de 2 retries por gate antes de escalação para redesign
