# CODEX Handoff — Phase 4: Copilot Studio Agent

Copy/paste to CODEX-LEAD:

```text
You are CODEX-LEAD for PMO Intelligent Hub MVP.

Context:
- G0 PASSED. G1 PASSED. G2 CONDITIONAL. G3 PASSED.
- Phase 4 dispatched by OPUS-ARCH.
- Your sub-agent for this phase is CODEX-CS (Sub-3, Copilot Studio Expert).
- E2E runtime validation for P0/P1/P2 flows is deferred to Phase 6 backlog.

Mandatory environment:
- All work in `ColOfertasBrasilPro` (e2d10003-4d8e-e007-9d63-76d5fe89ef56).
- Do NOT use Default environment.
- Standard connectors ONLY.

SharePoint site: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
Teams channel: Projetos_Tranformação_Digital (GroupID: 96c5b0c4-46cc-46cd-8695-50451db74994)

Active Power Automate flows (10 total, 9 active + 1 disabled):
P0 flows:
- PMO_PA_EnviarCheckInDiario (e117bbc5-5684-4191-8d03-fb183452ac5f)
- PMO_PA_CheckInOnDemand (c9e51483-38e7-422a-98cd-cf7604d14a16)
- PMO_PA_AlertaProjetoVermelho (5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd)
- PMO_PA_AlertaSemAtualizacao (0550c8ba-faf8-4e21-864e-d1fa5f625ce7)
- PMO_PA_ProcessarRespostaCheckIn (6c8ae320 — DISABLED)
P1/P2 flows:
- PMO_PA_ResumoDiarioBoard (a2cf01fb-8559-4398-96b8-c0e0a1c1d8a2)
- PMO_PA_RegistrarDecisaoBoard (f67daf7b-53a7-4d35-9275-7c8c42a35896)
- PMO_PA_SyncPlannerStats_Standard (3eb1be49-a9ff-48ca-888d-847ca7ae8b04)
- PMO_PA_EscalarRiscoCritico (cd0467a2-c989-474e-a629-28c704913489)
- PMO_PA_ResumoSemanal (1964c4bf-ef25-4e46-a88d-4a5a89c71bfb)

---

Phase 4 scope — Copilot Studio Agent "Assistente PMO":

TASK 1: Create the agent
- Name: "Assistente PMO"
- Authentication: "Authenticate with Microsoft"
- Language: pt-BR
- Publish target: Microsoft Teams
- Knowledge sources: SharePoint PMO lists ONLY (Projetos, Status Diario, Riscos e Bloqueios, Decisoes do Board)
- Block: public internet, public websites, generic model knowledge
- Block: HTTP external, Microsoft Graph direct

TASK 2: Create 4 custom entities
1. ProjectName — closed list populated from SP Projetos.Nome
2. StatusRAG — closed list: Verde, Amarelo, Vermelho
3. RiskSeverity — closed list: Baixa, Média, Alta, Crítica
4. ImpactLevel — closed list: Baixo, Médio, Alto, Crítico

TASK 3: Create 8 topics with pt-BR trigger phrases

Topic 1: AtualizarStatus
- Triggers: "atualizar projeto", "status do [projeto]", "update [projeto]"
- Slot filling: ProjectName → StatusRAG → Resumo → Risco (optional) → ProximaAcao (optional) → Percentual (optional)
- Confirm-Before-Action: "Vou registrar: [projeto] como [RAG], resumo: [resumo]. Confirma?"
- On confirm: Call flow PMO_PA_CheckInOnDemand (for on-demand card post+wait pattern)
- On deny: "Ok, vamos refazer. Qual projeto?"
- Response: "✅ Status do [projeto] atualizado para [RAG]."

Topic 2: ConsultarPortfolio
- Triggers: "como está o portfólio", "resumo dos projetos", "dashboard"
- Action: Query SharePoint Projetos WHERE Ativo=Yes
- Response format:
  📊 Portfólio PMO
  🟢 Verde: X projetos
  🟡 Amarelo: Y projetos
  🔴 Vermelho: Z projetos
  📋 Total: N projetos ativos
  ⚠️ Sem atualização (>24h): W projetos

Topic 3: ConsultarProjeto
- Triggers: "como está o [projeto]", "status de [projeto]", "detalhes [projeto]"
- Slot filling: ProjectName
- Action: Query SP Projetos + último Status Diário + Riscos abertos
- Response format:
  📌 [NomeProjeto]
  🚦 Status: [RAG]
  📈 Progresso: [Percentual]%
  📅 Alvo: [DataAlvo]
  👤 PM: [PM]
  📝 Último update: [data] — [resumo]
  ⚠️ Riscos abertos: [count]

Topic 4: RegistrarRisco
- Triggers: "registrar risco", "novo risco", "risco no [projeto]"
- Slot filling: ProjectName → Descrição → Severidade
- Confirm-Before-Action: "Risco: [desc] | Severidade: [sev] | Projeto: [proj]. Confirma?"
- On confirm: Create item in Riscos list + if Crítica → call PMO_PA_EscalarRiscoCritico
- Response: "✅ Risco registrado. [Se crítico: Escalação enviada para Sponsor.]"

Topic 5: RegistrarBloqueio
- Triggers: "registrar bloqueio", "projeto bloqueado", "bloqueio em [projeto]"
- Similar to RegistrarRisco but Tipo=Bloqueio

Topic 6: PedirDecisao
- Triggers: "preciso de uma decisão", "solicitar aprovação", "decisão para [projeto]"
- Slot filling: ProjectName → Descrição → Impacto → Prazo → Aprovador
- Confirm-Before-Action: Full summary before submission
- On confirm: Create item in Decisoes do Board → triggers PMO_PA_RegistrarDecisaoBoard
- Response: "✅ Solicitação de decisão criada. Card enviado para [Aprovador]."

Topic 7: LowConfidence
- Trigger: NLU confidence < 0.6
- Response: "Não entendi bem. Você pode reformular? Posso ajudar com: atualizar status, consultar portfólio, registrar risco, solicitar decisão."

Topic 8: Greeting
- Triggers: "olá", "oi", "bom dia", "help"
- Response: Menu with available options

TASK 4: Connect topics to PA flows
- Topic 1 (AtualizarStatus) → PMO_PA_CheckInOnDemand
- Topic 4 (RegistrarRisco) → PMO_PA_EscalarRiscoCritico (triggered via SP create when Severidade=Crítica)
- Topic 6 (PedirDecisao) → PMO_PA_RegistrarDecisaoBoard (triggered via SP create)
- Topics 2, 3 → direct SharePoint queries (no flow needed)

TASK 5: Implement Confirm-Before-Action
- Topics 1, 4, 5, 6 MUST have confirmation step before any write operation
- User must explicitly confirm before data is written to SharePoint

TASK 6: Configure LowConfidence fallback
- NLU threshold < 0.6 → Topic 7 (LowConfidence)
- No default "search web" behavior

TASK 7: Restrict knowledge sources
- ONLY SharePoint PMO-Hub lists
- NO public websites
- NO HTTP external calls
- NO generic AI model knowledge (Bing, web search)

TASK 8: Publish to Teams
- Authenticate with Microsoft
- Publish to Teams channel Projetos_Tranformação_Digital
- Test basic conversation flow after publish

---

Deliverables:
1. Agent "Assistente PMO" created and published in ColOfertasBrasilPro
2. 4 custom entities configured
3. 8 topics with pt-BR triggers
4. Flow connections bound to active PA flows
5. Confirm-Before-Action verified on Topics 1, 4, 5, 6
6. LowConfidence fallback configured
7. Knowledge restricted to SP PMO lists only
8. Published to Teams

Logs to update:
- Create .planning/comms/SUB3_CS_LOG.md
- Update .planning/comms/CODEX_LEAD_LOG.md
- Update .planning/comms/GATE_STATUS.md
- Create .planning/comms/OPUS_HANDOFF_G4.md

Specifications reference: .planning/AGENT_CONTRACT.md Section 7 (CODEX-CS contract, Topics 1-8, Entities, Acceptance Criteria).
```
