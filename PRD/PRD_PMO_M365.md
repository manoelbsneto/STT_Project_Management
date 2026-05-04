# PMO Intelligent Hub — Product Requirements Document (PRD)

## 1. Visão Geral
**Status:** MVP
**Data da Revisão:** 01/05/2026
**Product Manager / Owner:** [A definir — PMO Lead]
**Solução Arquitetural:** D + B (SharePoint Hub + Copilot Studio Agent)
**Nota Ponderada:** 9.5/10

### 1.1. Endpoints Oficiais

| Recurso | Valor |
|---------|-------|
| SharePoint Site | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital` |
| Teams Channel | `Projetos_Tranformação_Digital` |
| Teams Channel ID | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` |
| Teams Group ID | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| Teams Tenant ID | `7808e005-1489-4374-954b-d3b08f193920` |
| Teams Deep Link | `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920` |
| Power Platform Environment | `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) |
| Dataverse URL | `https://colofertasbrasilpro.crm4.dynamics.com/` |
| Copilot Bot ID | `0c4a9729-d55d-483c-8ec3-db9369583155` |

> **IMPORTANTE:** Para acesso ao canal Teams via browser, usar **sempre** o Deep Link acima. Nunca navegar manualmente pela sidebar do Teams.

---

## 2. Contexto de Negócio

### 2.1. O Problema (Problem Statement)
Os projetos da organização sofrem de **invisibilidade crônica de status**. Os gestores de projeto (PMs) não atualizam diariamente o status porque o processo é manual, demorado e fragmentado. Isso resulta em:

- **C-Level sem visibilidade em tempo real** do portfólio de projetos
- **Decisões atrasadas** por falta de informação consolidada
- **Riscos não escalados** a tempo de serem mitigados
- **Reuniões de status improdutivas** porque ninguém tem dados atualizados
- **Report manual** consome ~30-45 min/dia por PM em planilhas e emails

**Referência:** Este problema é classificado como "Status Reporting Friction" na literatura de PMO — ref: PMI PMBOK 7ª edição, Seção de Tailoring for Value Delivery.

### 2.2. Processo Atual (AS-IS)
1. PM trabalha em tarefas distribuídas (Planner, Excel, emails, reuniões)
2. Semanalmente (ou menos), PM compila status manualmente em PowerPoint/Excel
3. PM envia email para Sponsor com resumo
4. PMO consolida N emails em uma planilha geral
5. PMO prepara slide deck para o Board
6. Board recebe informação com 3-7 dias de defasagem
7. Riscos são descobertos tardiamente — geralmente em reuniões mensais
8. Decisões pendentes ficam em emails sem rastreamento

**Tempo médio de report por PM:** ~35 minutos/dia
**Defasagem da informação para o Board:** 3-7 dias úteis
**Taxa de atualização diária:** ~20% dos projetos

### 2.3. Processo Futuro (TO-BE)
1. PM recebe notificação no Teams (Adaptive Card ou chat com Copilot)
2. PM fala ou digita em linguagem natural: "Mobile App amarelo, sprint atrasada por bug"
3. Copilot Studio confirma extração e grava via Power Automate no SharePoint
4. SharePoint Lists atualizam automaticamente tabs de visibilidade no Teams
5. Power Automate dispara alertas automáticos para projetos críticos
6. Board abre tab no Teams → vê portfólio em tempo real
7. Decisões são registradas e rastreadas via Adaptive Cards interativos

**Tempo médio de report por PM:** <20 segundos (via voz) a <30 segundos (via card)
**Defasagem da informação para o Board:** tempo real (0 dias)
**Taxa de atualização diária esperada:** >95% dos projetos

### 2.4. Impacto Esperado (Business Impact)

| KPI | Baseline (AS-IS) | Meta (TO-BE) | Método de Medição |
|-----|------------------|--------------|-------------------|
| Tempo de report/PM/dia | ~35 min | <1 min | Timestamp do card/agente |
| Defasagem para Board | 3-7 dias | 0 (real-time) | UltimaAtualizacao vs agora |
| Taxa de update diário | ~20% | >95% | Contagem SP vs total ativos |
| Riscos escalados em <24h | ~30% | >90% | Timestamp criação risco vs alerta |
| Decisões com SLA rastreado | 0% | 100% | Lista Decisões com datas |
| Reuniões de status eliminadas | 0 | 80% (meta) | Contagem mensal |

---

## 3. Escopo e Fronteiras

### 3.1. In-Scope (No Escopo)

**Dados e Persistência:**
- 4 SharePoint Lists: Projetos, Status Diário, Riscos e Bloqueios, Decisões do Board
- 1 SharePoint List adicional (opcional): Marcos e Entregas (para tracking de atrasos)
- SharePoint site "PMO-Hub" com views Board, Gallery e Calendar

**Interface e Entrada:**
- Copilot Studio Agent PMO publicado no Teams (canal principal de entrada)
- 3 Adaptive Cards: Check-in Diário, Alerta Projeto Crítico, Decisão do Board
- Microsoft Forms como fallback (link fixo no Teams)
- Entrada por voz via dictação do OS (Win+H / teclado mobile) nos campos
- Entrada por voz via Copilot M365 microphone (quando disponível no tenant)

**Automação (Power Automate):**
- 10 fluxos cloud (standard connectors apenas):
  1. `PMO_PA_EnviarCheckInDiario` — Recurrence 9h → Post Card
  2. `PMO_PA_ProcessarRespostaCheckIn` — Resposta Card → Grava SP
  3. `PMO_PA_AlertaSemAtualizacao` — Recurrence 10h → Lembrete
  4. `PMO_PA_ResumoDiarioBoard` — Recurrence 17h → Card consolidado
  5. `PMO_PA_AlertaProjetoVermelho` — When modified (RAG=🔴) → Alerta
  6. `PMO_PA_RegistrarDecisaoBoard` — When created (Decisões) → Card aprovação
  7. `PMO_PA_CheckInOnDemand` — Trigger manual → Card imediato
  8. `PMO_PA_SyncPlannerStats` — Recurrence 18h → Graph API → Update SP
  9. `PMO_PA_EscalarRiscoCritico` — When created (Riscos, Severa=Crítica) → Alerta
  10. `PMO_PA_ResumoSemanal` — Recurrence Segunda 8h → Card expandido

**Copilot Studio Agent:**
- 8 topics: AtualizarStatus, ConsultarPortfolio, ConsultarProjeto, RegistrarRisco, RegistrarBloqueio, PedirDecisao, LowConfidence, Greeting
- Entidades customizadas: ProjectName, StatusRAG, RiskSeverity
- Pattern: Confirm-Before-Action em todos os topics de escrita
- Publicação: Microsoft Teams channel

**Visibilidade:**
- Teams Tabs embeddando SharePoint List views (Portfólio, Críticos)
- SharePoint Page Dashboard com web parts de lista filtradas
- Canais temáticos no Teams: Board Status, Projetos Críticos, Riscos, Decisões

**Execução Operacional:**
- Planner Basic para tarefas dentro de cada equipe (kanban por projeto)
- Sync opcional Planner → SharePoint via Graph API (contagem open/closed/late)

### 3.2. Out-of-Scope (Fora do Escopo)
- ❌ Power BI dashboards (substituído por SharePoint views + tabs)
- ❌ Dataverse como persistência (usa SharePoint Lists)
- ❌ Planner Premium (usa Basic apenas)
- ❌ Project for the Web / MS Project
- ❌ Gantt charts interativos (usar SharePoint Calendar view para marcos)
- ❌ Time tracking em horas (MVP usa dias como unidade)
- ❌ Budget tracking automatizado (campo manual na lista Projetos)
- ❌ Real-time Voice Agent Copilot Studio (depende de roadmap Teams Phone)
- ❌ Multi-tenant / multi-org (MVP é single org)
- ❌ Integrações com Azure DevOps, Jira, ou ferramentas externas

---

## 4. Personas e Permissões (RBAC)

### 4.1. PM (Project Manager)
- **Objetivo:** Atualizar status dos seus projetos em <30 segundos via voz ou texto, registrar riscos e bloqueios, solicitar decisões
- **Permissões:**
  - SharePoint: Contribute em todas as 4 listas (filtrado por ProjectID atribuído)
  - Copilot: Acesso ao agente PMO no Teams
  - Planner: Owner/Member do plano da sua equipe
  - Teams: Membro dos canais operacionais
- **Ref:** [SharePoint Permission Levels](https://learn.microsoft.com/en-us/sharepoint/understanding-permission-levels)

### 4.2. PMO Lead
- **Objetivo:** Monitorar portfólio completo, identificar projetos sem atualização, escalar riscos, preparar reports
- **Permissões:**
  - SharePoint: Full Control no site PMO-Hub
  - Copilot: Acesso ao agente PMO + consultas de portfólio
  - Power Automate: Co-owner de todos os fluxos
  - Teams: Owner da equipe PMO

### 4.3. Sponsor / Diretor
- **Objetivo:** Visibilidade dos projetos sob sua responsabilidade, aprovar/rejeitar decisões
- **Permissões:**
  - SharePoint: Read em todas as listas + Contribute apenas na lista Decisões
  - Teams: Membro dos canais Board Status e Decisões Pendentes
  - Copilot: Acesso ao agente PMO (consulta only — sem write)

### 4.4. C-Level / Board
- **Objetivo:** Visão executiva do portfólio (RAG distribution, projetos críticos, decisões pendentes)
- **Permissões:**
  - SharePoint: Read only em todas as listas
  - Teams: Membro do canal Board Status
  - Acesso à tab "Portfólio Executivo" no Teams

### 4.5. Tech Lead / Desenvolvedor
- **Objetivo:** Executar tarefas no Planner, visibilidade do status do seu projeto
- **Permissões:**
  - Planner: Member do plano da equipe
  - SharePoint: Read em Projetos e Status Diário (filtrado)
  - Teams: Membro do canal do projeto

---

## 5. Requisitos Funcionais e Épicos

| ID | Épico | Descrição / User Story | Prioridade | Critérios de Aceite |
|----|-------|------------------------|------------|---------------------|
| REQ-01 | Check-in Diário | Como PM, quero receber um Adaptive Card no Teams às 9h para atualizar o status do meu projeto em <30s | P0 | - Card chega às 9h no chat 1:1<br>- Campos: RAG, resumo, risco, próxima ação, %<br>- Resposta grava na lista Status Diário<br>- Atualiza StatusRAG na lista Projetos |
| REQ-02 | Copilot STT | Como PM, quero atualizar meu projeto falando em linguagem natural no Teams para eliminar fricção | P0 | - Agente reconhece projeto, RAG, resumo, risco<br>- Confirma antes de gravar (Confirm-Before-Action)<br>- Grava no SP via PA após confirmação<br>- Funciona com dictação Win+H e teclado mobile |
| REQ-03 | Portfólio Executivo | Como C-Level, quero ver todos os projetos agrupados por RAG em uma tab do Teams sem pedir report a ninguém | P0 | - Tab embeddada no Teams com SP List Board View<br>- Agrupado por StatusRAG (Verde, Amarelo, Vermelho)<br>- Mostra: nome, PM, %, data alvo<br>- Atualiza em tempo real |
| REQ-04 | Alerta Vermelho | Como Sponsor, quero ser notificado automaticamente quando um projeto sob minha responsabilidade mudar para vermelho | P0 | - PA detecta mudança StatusRAG → Vermelho<br>- Post no canal Projetos Críticos<br>- Notifica Sponsor por @mention<br>- Card inclui resumo, risco, bloqueio |
| REQ-05 | On-Demand Update | Como PM, quero poder enviar atualizações a qualquer momento (não só no horário agendado) | P0 | - Botão "Atualizar Agora" no canal ou Forms tab<br>- Copilot aceita "atualiza X" a qualquer hora<br>- Múltiplos updates/dia são aceitos<br>- Último update é o status vigente |
| REQ-06 | Decisão Board | Como Sponsor, quero aprovar/rejeitar decisões pendentes diretamente no Teams via card interativo | P1 | - Card com contexto + botões Aprovar/Rejeitar/Adiar<br>- Resposta grava na lista Decisões<br>- Timestamp e responsável registrados |
| REQ-07 | Resumo Diário | Como Board, quero receber um resumo consolidado às 17h no canal Board Status | P1 | - Card com: total projetos, distribuição RAG, projetos sem update, decisões pendentes<br>- Posted no canal Board Status |
| REQ-08 | Alerta Sem Update | Como PMO, quero saber quais projetos não foram atualizados nas últimas 24h | P1 | - PA roda às 10h, verifica DiasSemUpdate>=1<br>- Envia lembrete ao PM no Teams<br>- Lista no canal PMO |
| REQ-09 | Registro de Riscos | Como PM, quero registrar riscos via Copilot ou card e que riscos críticos escalem automaticamente | P1 | - Copilot extrai risco + severidade + projeto<br>- Grava na lista Riscos e Bloqueios<br>- Se Severidade=Crítica → alerta Sponsor + PMO |
| REQ-10 | Consulta por Voz | Como Diretora, quero perguntar "como está o portfólio?" ao Copilot e receber resposta formatada | P1 | - Topic ConsultarPortfolio retorna distribuição RAG<br>- Topic ConsultarProjeto faz drill-down<br>- Dados vêm do SharePoint em tempo real |
| REQ-11 | Sync Planner | Como PMO, quero que o número de tarefas abertas/fechadas/atrasadas do Planner apareça no status do projeto | P2 | - PA roda às 18h via Graph API<br>- Conta tasks por plano: open, closed, late<br>- Atualiza colunas TarefasAbertas, TarefasConcluidas na lista Projetos |
| REQ-12 | Resumo Semanal | Como Board, quero um report semanal expandido toda segunda às 8h | P2 | - Inclui tendência semanal (melhorou/piorou/estável)<br>- Entregas da semana + entregas atrasadas<br>- Decisões tomadas vs pendentes |
| REQ-13 | Marcos e Entregas | Como PMO, quero rastrear entregas planejadas vs realizadas para medir atrasos em dias | P2 | - Lista SP "Marcos" com DataPlanejada e DataReal<br>- Coluna calculada AtrasoEmDias<br>- View filtrada por projeto |

---

## 6. Requisitos Não-Funcionais (NFRs)

### 6.1. UI/UX e Frontend
- **Design System:** Microsoft Fluent UI (nativo via Teams, SharePoint, Adaptive Cards)
- **Dispositivos:** Desktop (Teams Windows/Mac) + Mobile (Teams iOS/Android)
- **Idioma:** Português (Brasil) como primário. Copilot Studio configurado para pt-BR.
- **Acessibilidade:** Adaptive Cards seguem schema 1.4+ com suporte a screen readers ([Ref: Adaptive Cards Accessibility](https://learn.microsoft.com/en-us/adaptive-cards/authoring-cards/speech))
- **Densidade de informação:** Board View para executivos (alto nível), List View para PMO (detalhado)
- **Meta de UX:** PM completa check-in em <30 segundos; C-Level encontra informação em <3 cliques

### 6.2. Performance
- **Tempos de Resposta:**
  - Adaptive Card rendering no Teams: <2 segundos ([Ref: Teams card size limits](https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-reference))
  - Copilot Studio response: <5 segundos para consultas simples
  - Power Automate flow execution: <30 segundos end-to-end
  - SharePoint List view load: <3 segundos para views com <5.000 itens
- **Volumetria / Scale:**
  - Até 200 projetos ativos simultâneos
  - Até 50 PMs com check-in diário
  - ~36.500 registros/ano na lista Status Diário (200 projetos × ~182 dias úteis) — bem abaixo do threshold de 5.000 por view (gerenciar via views filtradas)
  - Power Automate: 6.000 runs/flow/mês (standard) — suficiente para 10 fluxos ([Ref: PA Limits](https://learn.microsoft.com/en-us/power-automate/limits-and-config))
- **SharePoint List Limits:**
  - 30 milhões de itens por lista (hard limit) ([Ref: SP Service Limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits))
  - 5.000 itens por view threshold — mitigado via indexação e views filtradas
  - 12 lookup columns por list view — arquitetura usa apenas 1-2 lookups
  - Indexar colunas: StatusRAG, ProjectID, DataRegistro, Ativo, Sponsor

### 6.3. Segurança e Infraestrutura
- **Autenticação:** Microsoft Entra ID (Azure AD) — SSO via M365 tenant existente. Zero configuração adicional.
- **Autorização:** SharePoint Permission Levels (Read, Contribute, Full Control) por grupo de segurança
  - Grupo `PMO-PMs`: Contribute nas 4 listas
  - Grupo `PMO-Board`: Read nas 4 listas + Contribute em Decisões
  - Grupo `PMO-Admins`: Full Control no site
  - ([Ref: SP Permission Levels](https://learn.microsoft.com/en-us/sharepoint/understanding-permission-levels))
- **LGPD/GDPR:**
  - Dados armazenados: nome do PM, email (Person column) — dados corporativos, não sensíveis
  - Nenhum dado pessoal de clientes é processado
  - Retenção: definir política de 2 anos para Status Diário, depois archive
  - SharePoint audit log habilitado por padrão no M365 E3/E5
- **DLP:** Power Automate flows usam apenas Standard Connectors dentro do tenant M365. Sem external endpoints.
- **Copilot Studio Guardrails:**
  - Agente restrito a ações via Power Automate (não acessa diretamente APIs externas)
  - Confirm-Before-Action em todos os topics de escrita
  - LowConfidence fallback para NLU < 0.6
  - Sem acesso a dados fora do SharePoint site PMO-Hub
  - ([Ref: Copilot Studio Security](https://learn.microsoft.com/en-us/microsoft-copilot-studio/security-and-governance))

---

## 7. Arquitetura e Stack

### 7.1. Desenho Macro

```
┌─────────────────────────────────────────────────────────┐
│                    MICROSOFT TEAMS                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│
│  │ Copilot  │  │ Adaptive │  │ Tabs SP  │  │ Canais  ││
│  │ Studio   │  │ Cards    │  │ Views    │  │ Temát.  ││
│  │ Agent    │  │ (PA)     │  │          │  │         ││
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘│
└───────┼──────────────┼────────────┼──────────────┼──────┘
        │              │            │              │
        ▼              ▼            │              │
┌───────────────────────────┐       │              │
│    POWER AUTOMATE         │       │              │
│  10 Cloud Flows           │───────┘              │
│  (Standard Connectors)    │──────────────────────┘
└───────────┬───────────────┘
            │
            ▼
┌───────────────────────────┐     ┌─────────────────────┐
│   SHAREPOINT ONLINE       │     │   PLANNER BASIC     │
│  ┌──────────────────────┐ │     │  ┌───────────────┐  │
│  │ Lista: Projetos      │ │     │  │ 1 Plano/equipe│  │
│  │ Lista: Status Diário │ │     │  │ Buckets/Tasks │  │
│  │ Lista: Riscos        │ │     │  │ Assignments   │  │
│  │ Lista: Decisões      │ │     │  └───────────────┘  │
│  │ (Lista: Marcos) opt. │ │     └──────────┬──────────┘
│  └──────────────────────┘ │                │
│  ┌──────────────────────┐ │                │
│  │ SP Page: Dashboard   │ │     Graph API (sync)
│  └──────────────────────┘ │                │
└───────────────────────────┘     ◄───────────┘
```

- **Frontend:** Microsoft Teams (Desktop + Mobile)
- **Conversational AI:** Copilot Studio (topics + entities + Power Automate actions)
- **Orchestration:** Power Automate Cloud Flows (Standard Connectors)
- **Persistência:** SharePoint Online Lists (4-5 listas)
- **Execução Operacional:** Planner Basic (kanban por equipe)
- **API:** Microsoft Graph REST API v1.0 (para sync Planner → SharePoint)
- **Identidade:** Microsoft Entra ID (SSO corporativo)

### 7.2. Pontos de Integração e APIs

| Sistema | Endpoint / Método | Sentido | Connector | Ref |
|---------|-------------------|---------|-----------|-----|
| SharePoint Online | `/_api/web/lists` | Inbound/Outbound | Standard | [SP REST API](https://learn.microsoft.com/en-us/sharepoint/dev/sp-add-ins/get-to-know-the-sharepoint-rest-service) |
| Microsoft Teams | Post Adaptive Card, Post Message | Outbound | Standard | [Teams Connector PA](https://learn.microsoft.com/en-us/connectors/teams/) |
| Planner (Graph) | `GET /planner/plans/{id}/tasks` | Inbound | Standard (HTTP with Azure AD) | [Planner API](https://learn.microsoft.com/en-us/graph/api/resources/plannertask) |
| Copilot Studio | "When agent calls flow" trigger | Inbound | Standard | [CS + PA](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-create) |
| Microsoft Forms | "When response submitted" trigger | Inbound (fallback) | Standard | [Forms Connector](https://learn.microsoft.com/en-us/connectors/microsoftforms/) |
| Outlook (Email) | Send Email v2 | Outbound (alertas) | Standard | [Outlook Connector](https://learn.microsoft.com/en-us/connectors/office365/) |

### 7.3. Limites Técnicos Documentados

| Componente | Limite | Impacto | Mitigação | Ref Oficial |
|-----------|--------|---------|-----------|-------------|
| SharePoint List | 30M itens/lista | Nenhum no MVP | — | [SP Limits](https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits) |
| SP View Threshold | 5.000 itens/view | Views lentas se >5k | Indexar colunas + views filtradas | [SP Threshold](https://support.microsoft.com/en-us/office/manage-large-lists-and-libraries-b8588dae-9387-48c2-9248-c24122f07c59) |
| SP Indexed Columns | 20 por lista | Suficiente (usamos 5-6) | — | Mesmo link acima |
| SP Lookup Columns | 12 por view | Arquitetura usa 1-2 | — | Mesmo link acima |
| PA Standard Flow Runs | 6.000/mês por flow | Suficiente (200 projetos × 22 dias = 4.400) | Monitorar runs | [PA Limits](https://learn.microsoft.com/en-us/power-automate/limits-and-config) |
| PA Actions per Flow | 500 ações/flow | Nenhum flow excede 20 | — | Mesmo link acima |
| PA Flow Duration | 30 dias max | Flows executam em <1 min | — | Mesmo link acima |
| Adaptive Card | 28KB payload max | Cards dentro do limite | Manter JSON < 20KB | [AC Limits Teams](https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-reference) |
| Copilot Studio Topics | 1.000/agent | Usamos 8 | — | [CS Limits](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-quotas) |
| Copilot Studio Entities | 200/agent | Usamos 3-5 | — | Mesmo link acima |
| Planner Tasks | 2.400/plano | Suficiente | Criar novo plano se exceder | [Planner Limits](https://learn.microsoft.com/en-us/office365/planner/planner-limits) |
| Planner Buckets | 200/plano | Suficiente | — | Mesmo link acima |

---

## 8. Agentes de IA / LLM — Copilot Studio Agent

### 8.1. Agente Principal
- **Plataforma:** Microsoft Copilot Studio
- **Modelo:** GPT-4o (via Microsoft backbone, gerenciado pelo Copilot Studio)
- **Canal de deploy:** Microsoft Teams
- **Idioma:** pt-BR (primário), com fallback para en-US
- **Nome do agente:** "PMO Assistant" ou "Assistente PMO"

### 8.2. Grau de Autonomia (Strictness)
- **Leitura (consultas):** Autônomo — o agente pode consultar SharePoint e retornar dados sem confirmação
- **Escrita (atualizações):** Confirm-Before-Action OBRIGATÓRIO — o agente DEVE exibir o que vai gravar e aguardar confirmação explícita ("Sim", "Confirma", "Ok") antes de executar o Power Automate flow
- **Escalação:** Se NLU confidence < 0.6, o agente NÃO executa — pede reformulação
- **Escopo:** Restrito ao SharePoint site PMO-Hub. Sem acesso a internet, sem knowledge sources externas.

### 8.3. Topics e Fluxos Detalhados

| # | Topic | Intent | Entities Extraídas | Flow PA Chamado | Resposta |
|---|-------|--------|-------------------|-----------------|----------|
| 1 | AtualizarStatus | Atualizar status de projeto | ProjectName, StatusRAG, Resumo, Risco, ProximaAcao, Percentual | PMO_PA_ProcessarRespostaCheckIn | Confirmação + resultado |
| 2 | ConsultarPortfolio | Ver resumo do portfólio | — | — (query direto SP) | Distribuição RAG + destaques |
| 3 | ConsultarProjeto | Ver detalhes de 1 projeto | ProjectName | — (query direto SP) | Status, riscos, últimos updates |
| 4 | RegistrarRisco | Criar novo risco | ProjectName, Descricao, Severidade | PMO_PA_EscalarRiscoCritico | Confirmação + alerta se crítico |
| 5 | RegistrarBloqueio | Criar bloqueio | ProjectName, Descricao, Impacto | PMO_PA_EscalarRiscoCritico | Confirmação + escalação |
| 6 | PedirDecisao | Solicitar decisão do Board | ProjectName, Descricao, Impacto, Prazo | PMO_PA_RegistrarDecisaoBoard | Confirmação + card no canal |
| 7 | LowConfidence | Fallback | — | — | "Não entendi. Reformule." |
| 8 | Greeting | Saudação | — | — | Apresentação + menu |

### 8.4. Entidades Customizadas

| Entidade | Tipo | Valores | Ref |
|----------|------|---------|-----|
| ProjectName | Closed List | Populada dinamicamente da lista Projetos (via PA) | [Entities](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-entities-slot-filling) |
| StatusRAG | Closed List | Verde, Amarelo, Vermelho | Mesmo |
| RiskSeverity | Closed List | Baixa, Média, Alta, Crítica | Mesmo |
| ImpactLevel | Closed List | Baixo, Médio, Alto, Crítico | Mesmo |

---

## 9. Plano de Lançamento (Roadmap)

### Fase 0 — Design e Preparação (Semana 0-1)
- Criar site SharePoint "PMO-Hub"
- Criar equipe Teams "PMO-Team" com canais temáticos
- Definir naming convention (PRJ-XXX)
- Configurar security groups (PMO-PMs, PMO-Board, PMO-Admins)
- Cadastrar projetos piloto (5 projetos)
- **Gate:** Site, equipe e grupos criados e validados

### Fase 1 — MVP Core (Semanas 1-3)
- Criar 4 SharePoint Lists com schema completo
- Indexar colunas críticas
- Criar views Board, Gallery e List
- Implementar 5 flows P0 (EnviarCheckIn, ProcessarResposta, AlertaVermelho, CheckInOnDemand, AlertaSemUpdate)
- Criar 3 Adaptive Cards (JSON)
- Embeddar SP views como tabs no Teams
- **Gate:** PM consegue atualizar status via card e Board vê na tab

### Fase 2 — Copilot Studio Agent (Semanas 3-5)
- Criar agente no Copilot Studio
- Configurar 8 topics com trigger phrases
- Criar entidades customizadas
- Conectar topics aos flows PA
- Implementar Confirm-Before-Action
- Publicar no Teams
- Testar com 3 PMs piloto (voz + texto)
- **Gate:** PM atualiza status por linguagem natural com confirmação

### Fase 3 — Automação Completa (Semanas 5-7)
- Implementar flows P1 e P2 restantes (ResumoDiario, ResumoSemanal, SyncPlanner, EscalarRisco, RegistrarDecisao)
- Criar SharePoint Page Dashboard
- Configurar canais temáticos com cards automáticos
- Criar Form de fallback como tab
- **Gate:** Sistema 100% automatizado, todos os 10 flows ativos

### Fase 4 — Piloto Controlado (Semanas 7-8)
- Onboarding de todos os PMs (treinamento de 30 min)
- Guia rápido de 1 página (uso de voz: Win+H / teclado mobile)
- Vídeo de 2 min: "Como atualizar seu projeto em 20 segundos"
- Monitorar taxa de adoção diária
- Coletar feedback dos PMs e Board
- Ajustar flows e topics com base no feedback
- **Gate:** >80% de taxa de atualização diária por 5 dias consecutivos

### Fase 5 — Expansão (Semana 9+)
- Criar lista Marcos e Entregas (tracking de atrasos)
- Templates de Planner por tipo de projeto
- Provisionamento automatizado de novos projetos
- Métricas de adoção e SLA de resposta
- Avaliação de Real-time Voice Agent (quando disponível no Teams Phone)

---

## 10. Referências Oficiais Completas

| # | Tema | URL |
|---|------|-----|
| 1 | SharePoint REST API | https://learn.microsoft.com/en-us/sharepoint/dev/sp-add-ins/get-to-know-the-sharepoint-rest-service |
| 2 | SharePoint Service Limits | https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits |
| 3 | SharePoint List View Threshold | https://support.microsoft.com/en-us/office/manage-large-lists-and-libraries-b8588dae-9387-48c2-9248-c24122f07c59 |
| 4 | SharePoint Permission Levels | https://learn.microsoft.com/en-us/sharepoint/understanding-permission-levels |
| 5 | Power Automate Limits | https://learn.microsoft.com/en-us/power-automate/limits-and-config |
| 6 | Power Automate Standard Connectors | https://learn.microsoft.com/en-us/connectors/connector-reference/connector-reference-standard-connectors |
| 7 | Planner Task API (Graph) | https://learn.microsoft.com/en-us/graph/api/resources/plannertask |
| 8 | Planner Limits | https://learn.microsoft.com/en-us/office365/planner/planner-limits |
| 9 | Planner API Overview | https://learn.microsoft.com/en-us/graph/planner-concept-overview |
| 10 | Adaptive Cards Schema | https://adaptivecards.io/explorer/ |
| 11 | Adaptive Cards in Teams | https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-reference |
| 12 | Copilot Studio — Topics | https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-create-edit-topics |
| 13 | Copilot Studio — Entities | https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-entities-slot-filling |
| 14 | Copilot Studio — PA Flows | https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-create |
| 15 | Copilot Studio — Fallback | https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-system-fallback-topic |
| 16 | Copilot Studio — Deploy Teams | https://learn.microsoft.com/en-us/microsoft-copilot-studio/publication-add-bot-to-microsoft-teams |
| 17 | Copilot Studio — Security | https://learn.microsoft.com/en-us/microsoft-copilot-studio/security-and-governance |
| 18 | Copilot Studio — Quotas/Limits | https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-quotas |
| 19 | Copilot Studio — Voice Overview | https://learn.microsoft.com/en-us/microsoft-copilot-studio/voice-overview |
| 20 | Teams Connector (PA) | https://learn.microsoft.com/en-us/connectors/teams/ |
| 21 | Windows Voice Typing | https://support.microsoft.com/en-us/windows/use-voice-typing-to-talk-instead-of-type-on-your-pc |

---

*PRD completo. Solução D+B — SharePoint Hub + Copilot Studio Agent. Todas as seções preenchidas com referências oficiais Microsoft.*
