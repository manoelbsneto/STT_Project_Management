# PMO Intelligent Hub — Product Requirements Document (PRD)

## 1. Visão Geral

**Status:** MVP — Standard-Only / No-Premium / No-Graph Direto  
**Data da Revisão:** 01/05/2026  
**Versão:** 1.3 — Ajustada com endpoints oficiais Teams/SharePoint, status de preparação e deploy programático  
**Product Manager / Owner:** [A definir — PMO Lead]  
**Solução Arquitetural:** SharePoint Hub + Microsoft Teams + Power Automate Standard + Copilot Studio Agent  
**Nota pós-ajustes:** **94/100**  
**Decisão arquitetural mandatória:** não utilizar Microsoft Graph direto, HTTP com Microsoft Entra ID, conectores Premium, Dataverse, Planner Premium, Project for the Web, Azure DevOps, Jira ou integrações externas no MVP. O conector nativo **Planner Standard** do Power Automate está autorizado como workaround para leitura de tarefas do Planner Basic.

### 1.1. Resumo Executivo dos Ajustes

Esta versão ajustada mantém o objetivo principal do produto: reduzir drasticamente a fricção de atualização de status, centralizar visibilidade executiva e permitir alertas automáticos de riscos/projetos críticos usando apenas componentes já disponíveis no ecossistema Microsoft 365 corporativo.

A principal alteração arquitetural é a substituição do **sync automático Planner → SharePoint via Microsoft Graph/HTTP Premium** por um workaround 100% Standard: o flow `PMO_PA_SyncPlannerStats_Standard` usa o conector nativo **Planner Standard** do Power Automate para listar tarefas de planos básicos, calcular tarefas abertas, concluídas e atrasadas, e gravar os indicadores consolidados no SharePoint.


### 1.2. Ambiente Oficial do MVP e Status de Preparação

Esta versão passa a utilizar os endpoints reais de execução do MVP, substituindo placeholders genéricos de Teams/SharePoint por artefatos corporativos já definidos.

| Item | Valor |
|------|-------|
| Canal oficial do Teams | `Projetos_Tranformação_Digital` |
| URL do canal Teams | `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920` |
| Site SharePoint oficial | `Grp_T_DN_Transformacao_Digital` |
| URL do SharePoint | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/SitePages/Home.aspx` |
| Tenant ID | `7808e005-1489-4374-954b-d3b08f193920` |
| Group ID | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| Ambiente Power Platform oficial | `ColOfertasBrasilPro` |
| Power Platform Environment ID | `e2d10003-4d8e-e007-9d63-76d5fe89ef56` |
| Power Platform Environment URL | `https://colofertasbrasilpro.crm4.dynamics.com/` |

#### Status de Preparação Confirmado

| Frente | Status | Observação |
|--------|--------|------------|
| Conectores e DLP | **Validado** | Conectores permitidos e restrições DLP já validadas para o MVP Standard-Only. |
| Ambiente base Teams/SharePoint | **Concluído** | Canal Teams e site SharePoint oficiais já definidos e passam a ser os endpoints do MVP. |
| SharePoint Lists, views, colunas e artefatos correlatos | **A criar programaticamente no deploy** | O deploy deverá criar listas, colunas, views, índices, páginas/tabs e configurações necessárias de forma padronizada, sem criação manual como dependência crítica. |

#### Implicação Arquitetural

O MVP deixa de depender da criação de um novo site genérico `PMO-Hub` e passa a utilizar o SharePoint corporativo existente `Grp_T_DN_Transformacao_Digital` como hub oficial. A nomenclatura `PMO-Hub` permanece apenas como nome lógico da solução/produto, não como requisito de criação de novo site.

Todas as fases Power Platform, Power Automate e Copilot Studio devem ser executadas exclusivamente no ambiente `ColOfertasBrasilPro`. O ambiente Default não deve ser usado para criação, importação, exportação, teste ou publicação de flows/agentes deste MVP.


---

## 2. Contexto de Negócio

### 2.1. O Problema (Problem Statement)

Os projetos da organização sofrem de **invisibilidade crônica de status**. Os gestores de projeto (PMs) não atualizam diariamente o status porque o processo é manual, demorado e fragmentado. Isso resulta em:

- **C-Level sem visibilidade tempestiva** do portfólio de projetos.
- **Decisões atrasadas** por falta de informação consolidada.
- **Riscos não escalados** a tempo de serem mitigados.
- **Reuniões de status improdutivas** porque os dados chegam desatualizados ou incompletos.
- **Report manual** consumindo aproximadamente 30-45 min/dia por PM em planilhas, apresentações e emails.

**Referência conceitual:** problema classificado como fricção de status reporting em práticas modernas de PMO, associado a baixa cadência de atualização e atraso na tomada de decisão.

### 2.2. Processo Atual (AS-IS)

1. PM trabalha em tarefas distribuídas entre Planner, Excel, emails e reuniões.
2. Semanalmente ou de forma irregular, PM compila status manualmente em PowerPoint/Excel.
3. PM envia email para Sponsor com resumo.
4. PMO consolida N emails em uma planilha geral.
5. PMO prepara slide deck para o Board.
6. Board recebe informação com 3-7 dias úteis de defasagem.
7. Riscos são descobertos tardiamente, geralmente em reuniões periódicas.
8. Decisões pendentes ficam em emails sem rastreamento estruturado.

**Tempo médio de report por PM:** ~35 minutos/dia  
**Defasagem da informação para o Board:** 3-7 dias úteis  
**Taxa de atualização diária estimada:** ~20% dos projetos

### 2.3. Processo Futuro (TO-BE) — MVP Ajustado

1. PM recebe notificação no Teams via Adaptive Card ou interage com Copilot Studio Agent.
2. PM fala ou digita em linguagem natural: “Mobile App amarelo, sprint atrasada por bug crítico, próxima ação é correção até sexta”.
3. Copilot Studio ou Adaptive Card confirma os dados extraídos antes da gravação.
4. Power Automate grava a atualização em SharePoint Lists usando conectores standard.
5. SharePoint Lists atualizam automaticamente as tabs de visibilidade no Teams.
6. Power Automate dispara alertas automáticos para projetos vermelhos ou riscos críticos.
7. Board acessa a tab do Teams para visualizar o portfólio com dados atualizados.
8. Decisões são registradas e rastreadas via DecisionID, com responsável, timestamp, resposta e justificativa.

**Tempo médio de report por PM no MVP:** <2 minutos inicialmente; alvo operacional <1 minuto.  
**Defasagem da informação para o Board no MVP:** <24h; alvo pós-adoção <4h.  
**Taxa de atualização diária esperada no piloto:** 70-80%; alvo pós-adoção 85-90%; alvo aspiracional >95%.

### 2.4. Impacto Esperado (Business Impact)

| KPI | Baseline (AS-IS) | Meta MVP | Meta Pós-Adoção | Método de Medição |
|-----|------------------|----------|-----------------|-------------------|
| Tempo de report/PM/dia | ~35 min | <2 min | <1 min | Timestamp do card/agente |
| Defasagem para Board | 3-7 dias úteis | <24h | <4h | ÚltimaAtualizacao vs agora |
| Taxa de update diário | ~20% | 70-80% | 85-90% | Contagem SP vs total ativos |
| Riscos escalados em <24h | ~30% | >70% | >85% | Timestamp criação risco vs alerta |
| Decisões com SLA rastreado | 0% | 100% | 100% | Lista Decisões com datas |
| Reuniões de status eliminadas | 0 | 20-30% | 50%+ | Contagem mensal |

---

## 3. Decisão Arquitetural Crítica — Sem Graph Direto e Sem Power Automate Premium

### 3.1. Restrição Confirmada

A organização **não possui autorização para utilizar Microsoft Graph diretamente** e **não possui licença Premium do Power Automate**. Portanto, a solução MVP deve operar exclusivamente com conectores standard e recursos permitidos dentro do tenant Microsoft 365 corporativo.

A restrição bloqueia **HTTP with Microsoft Entra ID**, **custom connector**, **Graph REST API direta** e qualquer conector Premium. Porém, **não bloqueia o conector nativo Microsoft Planner Standard**, desde que ele esteja liberado pela DLP do tenant e seja usado apenas com **Planner Basic**, que é suportado pelo próprio conector.

### 3.2. Solução de Contorno Aprovada — Planner Standard Connector

| Área | Impacto | Decisão |
|------|---------|---------|
| Planner Sync automático | Mantido no MVP, sem Graph direto. | Usar conector nativo Planner Standard com ação `List tasks`. |
| Microsoft Graph API direta | Não será utilizada. | Excluir endpoints Graph/HTTP da arquitetura MVP. |
| HTTP with Microsoft Entra ID | Não será utilizado, pois é Premium no Power Automate. | Excluir do MVP. |
| Conectores Premium | Não serão utilizados. | DLP deve bloquear conectores Premium/HTTP não aprovados. |
| Métricas de tarefas Planner | Serão coletadas automaticamente para Planner Basic. | Flow calcula abertas, concluídas, atrasadas e total por plano. |
| Visibilidade executiva | Mantida e fortalecida. | SharePoint + Teams tabs passam a exibir também métricas automáticas de tarefas. |
| Alertas de risco/status | Mantidos. | Alertas continuam baseados em SharePoint List events e regras de RAG/severidade. |

### 3.3. Impacto Real de Escopo

A restrição **não inviabiliza o projeto** e **não exige remover a feature de contagem automática de tarefas**. O que muda é a abordagem técnica:

- **Não usar:** Graph REST API, HTTP with Microsoft Entra ID, custom connector ou Premium.
- **Usar:** conector nativo **Planner Standard** do Power Automate.
- **Manter:** `PMO_PA_SyncPlannerStats_Standard` no MVP.
- **Adicionar:** campos de métricas Planner na lista Projetos e, opcionalmente, uma lista de snapshot histórico.

### 3.4. Arquitetura do Workaround

O flow `PMO_PA_SyncPlannerStats_Standard` deverá executar em recorrência controlada, por exemplo às 18h ou a cada 4/6 horas, e seguir o fluxo abaixo:

1. Buscar projetos ativos na lista `Projetos` onde `PlannerPlanId` e `PlannerGroupId` estejam preenchidos.
2. Para cada projeto/plano, chamar a ação Planner Standard `List tasks`.
3. Calcular indicadores em memória dentro do Power Automate:
   - `TarefasTotal` = total de tarefas retornadas.
   - `TarefasConcluidas` = tarefas com `percentComplete = 100` ou `completedDateTime` preenchido.
   - `TarefasAbertas` = tarefas com `percentComplete < 100`.
   - `TarefasAtrasadas` = tarefas com `percentComplete < 100` e `dueDateTime < utcNow()`.
   - `TarefasSemPrazo` = tarefas abertas sem `dueDateTime`.
4. Atualizar a lista `Projetos` com os indicadores consolidados.
5. Opcionalmente, gravar um snapshot na lista `Planner Metrics Snapshot` para histórico e tendência.
6. Em caso de falha, gravar `PlannerSyncStatus = Erro`, `PlannerSyncError` e notificar PMO.

### 3.5. Limitações Aceitas

- A solução funciona apenas para **Planner Basic**, não para Planner Premium.
- A acuracidade de tarefas atrasadas depende de as tarefas terem `dueDateTime` preenchido.
- A sincronização não deve rodar em frequência excessiva para evitar throttling.
- O conector Planner possui limite de chamadas por conexão; o flow deve usar paginação/controle de concorrência/delay quando houver muitos planos.
- Campos avançados não expostos pelo conector Planner Standard não entram no MVP.

### 3.6. Mitigação Sem Premium

- Manter Planner Basic como ferramenta operacional de tarefas.
- Adicionar `PlannerGroupId`, `PlannerPlanId` e `LinkPlanner` na lista Projetos.
- Usar o flow standard `PMO_PA_SyncPlannerStats_Standard` para métricas automáticas.
- Manter campos manuais no check-in como fallback: `Percentual`, `Bloqueio`, `Risco`, `ProximaAcao`, `ResumoTarefas`.
- Avaliar Planner Premium/Graph apenas como evolução futura caso surjam requisitos não suportados pelo conector standard.

---

## 4. Escopo e Fronteiras

### 4.1. In-Scope (No Escopo do MVP)

**Dados e Persistência:**

- 4 SharePoint Lists obrigatórias: Projetos, Status Diário, Riscos e Bloqueios, Decisões do Board.
- 1 SharePoint List opcional: Marcos e Entregas.
- SharePoint site “PMO-Hub” com views Board, Gallery, Calendar e List.

**Adendo 2.4 - Abertura operacional de projetos e tarefas:**

- A lista `Projetos` permanece a fonte oficial de cadastro/status executivo dos projetos.
- A lista `Tarefas` passa a ser componente operacional obrigatorio para tarefas gerenciadas pelo Assistente PMO quando o usuario solicitar criacao/listagem/atualizacao/exclusao de tarefas via bot.
- O comando/topico `CriarProjeto` deve criar somente registros na lista `Projetos`.
- O comando/topico `CriarTarefa` deve criar somente registros na lista `Tarefas`, sempre vinculado a um `ProjectID` existente, ativo e nao deletado na lista `Projetos`.
- O comando/topico `Gerar_Multiplos_Projetos` deve criar projetos em lote e, opcionalmente, tarefas iniciais pareadas por indice. Exemplo: `Nome_Projeto1` recebe `Tarefa1`, `Nome_Projeto2` recebe `Tarefa2`.
- `ProjectID` deve ser sempre definido pelo sistema. Entradas como `ProjectID: sistema define automaticamente` devem ser aceitas como instrucao e nao como valor literal.
- Campos de sistema do SharePoint, como `Created`, podem ser lidos do texto para auditoria/contexto, mas nao devem ser sobrescritos pelo flow.

**Interface e Entrada:**

- Copilot Studio Agent PMO publicado no Microsoft Teams.
- 3 Adaptive Cards: Check-in Diário, Alerta Projeto Crítico, Decisão do Board.
- Adendo 2.4: Adaptive Cards passam a ser o Plano A para revisao, validacao e confirmacao de `CriarProjeto`, `CriarTarefa` e `Gerar_Multiplos_Projetos`.
- Microsoft Forms como fallback operacional.
- Entrada por texto e voz usando dictation do sistema operacional ou teclado mobile.
- Entrada por microfone no ecossistema Copilot/M365 apenas quando disponível no tenant e sem exigir integração premium.
- Adendo 2.4: texto multilinha e Speech-to-Text achatado devem ser suportados como Plano B para os mesmos comandos, principalmente quando o card nao renderizar, o usuario estiver em mobile/voz, ou o usuario colar um bloco estruturado.

**Automação (Power Automate — Standard Only):**

- 10 fluxos cloud no MVP, todos com conectores standard:
  1. `PMO_PA_EnviarCheckInDiario` — Recurrence 9h → Post Card.
  2. `PMO_PA_ProcessarRespostaCheckIn` — Resposta Card → Grava SharePoint.
  3. `PMO_PA_AlertaSemAtualizacao` — Recurrence 10h → Lembrete.
  4. `PMO_PA_ResumoDiarioBoard` — Recurrence 17h → Card consolidado.
  5. `PMO_PA_AlertaProjetoVermelho` — When modified (RAG=🔴) → Alerta.
  6. `PMO_PA_RegistrarDecisaoBoard` — When created (Decisões) → Card aprovação.
  7. `PMO_PA_CheckInOnDemand` — Trigger manual → Card imediato.
  8. `PMO_PA_SyncPlannerStats_Standard` — Recurrence controlada → Planner Standard `List tasks` → calcula métricas → atualiza SharePoint.
  9. `PMO_PA_EscalarRiscoCritico` — When created (Riscos, Severidade=Crítica) → Alerta.
  10. `PMO_PA_ResumoSemanal` — Recurrence segunda-feira 8h → Card expandido.

Adendo 2.4:

- `PMO_PA_CriarProjeto` deve preservar o contrato de criacao de projeto em `Projetos`.
- `PMO_PA_CriarTarefa` deve criar item em `Tarefas`, apos resolver `NomeProjeto` ou `ProjectID` contra `Projetos`.
- `PMO_PA_Gerar_Multiplos_Projetos` deve orquestrar lote limitado, validar antes de gravar, exigir confirmacao, criar projetos e tarefas iniciais, e retornar resultado por linha.
- Todos os flows 2.4 devem usar conectores standard, preferencialmente SharePoint Connector `Get items`, `Create item` e `Update item`, sem HTTP premium/custom connector.

**Copilot Studio Agent:**

- 8 topics: AtualizarStatus, ConsultarPortfolio, ConsultarProjeto, RegistrarRisco, RegistrarBloqueio, PedirDecisao, LowConfidence, Greeting.
- Entidades customizadas: ProjectName, StatusRAG, RiskSeverity, ImpactLevel.
- Pattern obrigatório: Confirm-Before-Action em todos os topics de escrita.
- Publicação: Microsoft Teams channel.

Adendo 2.4:

- Topics adicionais/renomeados: `CriarProjeto`, `CriarTarefa`, `Gerar_Multiplos_Projetos`.
- `CriarProjeto` nao deve conter trigger phrases de tarefa.
- `CriarTarefa` nao deve conter trigger phrases de projeto e nunca deve gravar em `Projetos`.
- `Gerar_Multiplos_Projetos` deve aceitar frases como `gerar multiplos projetos`, `criar varios projetos`, `criar projetos em lote` e `gerar projetos em batch`.
- Qualquer escrita deve ser bloqueada sem confirmacao explicita via Adaptive Card ou confirmacao textual equivalente.

**Visibilidade:**

- Teams Tabs embeddando SharePoint List views.
- SharePoint Page Dashboard com web parts de lista filtradas.
- Canais temáticos no Teams: Board Status, Projetos Críticos, Riscos, Decisões.

**Execução Operacional:**

- Planner Basic para tarefas de cada equipe/projeto.
- Sync automático Planner → SharePoint mantido via conector Planner Standard, sem Graph direto e sem Premium.
- Percentual, bloqueios, riscos e resumo de tarefas continuam disponíveis no check-in como fallback operacional.

### 4.2. Out-of-Scope (Fora do Escopo do MVP)

- ❌ Microsoft Graph API direta / HTTP custom.
- ❌ HTTP with Microsoft Entra ID.
- ❌ Conectores Premium do Power Automate.
- ❌ Power BI dashboards.
- ❌ Dataverse como persistência.
- ❌ Planner Premium.
- ❌ Project for the Web / Microsoft Project.
- ❌ Gantt charts interativos.
- ❌ Time tracking em horas.
- ❌ Budget tracking automatizado.
- ❌ Real-time Voice Agent Copilot Studio dependente de Teams Phone ou roadmap específico.
- ❌ Multi-tenant / multi-org.
- ❌ Integrações com Azure DevOps, Jira ou ferramentas externas.

---

## 5. Personas e Permissões (RBAC)

### 5.1. PM (Project Manager)

- **Objetivo:** atualizar status dos seus projetos rapidamente, registrar riscos e bloqueios, solicitar decisões.
- **Permissões:**
  - SharePoint: Contribute conforme desenho de segurança aprovado por projeto/PM.
  - Copilot: acesso ao agente PMO no Teams.
  - Planner: Owner/Member do plano da sua equipe.
  - Teams: membro dos canais operacionais.

### 5.2. PMO Lead

- **Objetivo:** monitorar portfólio completo, identificar projetos sem atualização, escalar riscos, preparar reports.
- **Permissões:**
  - SharePoint: Full Control no site PMO-Hub.
  - Copilot: acesso ao agente PMO + consultas de portfólio.
  - Power Automate: co-owner de todos os fluxos.
  - Teams: owner da equipe PMO.

### 5.3. Sponsor / Diretor

- **Objetivo:** visibilidade dos projetos sob sua responsabilidade, aprovar/rejeitar decisões.
- **Permissões:**
  - SharePoint: Read nas listas necessárias + Contribute na lista Decisões.
  - Teams: membro dos canais Board Status e Decisões Pendentes.
  - Copilot: acesso ao agente PMO em modo consulta.

### 5.4. C-Level / Board

- **Objetivo:** visão executiva do portfólio, distribuição RAG, projetos críticos e decisões pendentes.
- **Permissões:**
  - SharePoint: Read only nas listas executivas.
  - Teams: membro do canal Board Status.
  - Acesso à tab “Portfólio Executivo” no Teams.

### 5.5. Tech Lead / Desenvolvedor

- **Objetivo:** executar tarefas no Planner e acompanhar status do projeto.
- **Permissões:**
  - Planner: Member do plano da equipe.
  - SharePoint: Read nos dados aprovados do projeto.
  - Teams: membro do canal do projeto.

### 5.6. Nota de Segurança por Projeto/PM

A segurança por projeto/PM foi validada como requisito aceito pela área solicitante. A implementação deve respeitar o desenho de permissões aprovado pelo tenant, evitando tratar apenas views filtradas como boundary de segurança quando houver necessidade real de segregação. Para MVP, o desenho final deve ser confirmado com o administrador de SharePoint/Teams antes do rollout.

---

## 6. Modelo de Dados

### 6.1. Listas e Campos Obrigatórios

| Lista | Campos obrigatórios |
|------|---------------------|
| Projetos | ProjectID, Nome, PM, Sponsor, StatusRAG, Percentual, DataAlvo, UltimaAtualizacao, Ativo, Unidade, Prioridade, PlannerGroupId, PlannerPlanId, TarefasTotal, TarefasAbertas, TarefasConcluidas, TarefasAtrasadas, PlannerLastSyncAt, PlannerSyncStatus |
| Status Diário | StatusID, ProjectID, DataRegistro, PM, RAG, Resumo, Risco, Bloqueio, ProximaAcao, Percentual, OrigemEntrada |
| Riscos e Bloqueios | RiskID, ProjectID, Tipo, Severidade, Impacto, Probabilidade, Owner, DataCriacao, SLA, Status, PlanoMitigacao |
| Decisões | DecisionID, ProjectID, Descricao, Solicitante, Aprovador, Prazo, Status, Resposta, DataResposta, Impacto |
| Marcos | MilestoneID, ProjectID, Nome, DataPlanejada, DataReal, Status, AtrasoDias |
| Planner Metrics Snapshot (opcional) | SnapshotID, ProjectID, PlannerPlanId, DataSnapshot, TarefasTotal, TarefasAbertas, TarefasConcluidas, TarefasAtrasadas, TarefasSemPrazo, SyncStatus |

### 6.2. Campos Opcionais Recomendados

| Lista | Campos opcionais recomendados | Motivo |
|------|-------------------------------|--------|
| Projetos | ResumoExecutivo, ClienteInterno, CategoriaProjeto, DataInicio, DataFimPrevista, DiasSemUpdate, LinkPlanner, LinkDocumentacao, TarefasSemPrazo, PlannerSyncError | Melhorar navegação executiva, gestão operacional e auditoria do sync Planner |
| Status Diário | ResumoTarefas, EvidenciaLink, CriadoPor, ModificadoPor, CardVersion | Permitir auditoria e fallback manual caso o sync Planner falhe ou esteja temporariamente indisponível |
| Riscos e Bloqueios | DataMitigacaoPrevista, DataMitigacaoReal, EscaladoPara, DataEscalacao | Melhorar controle de SLA e histórico |
| Decisões | Justificativa, CardVersion, ResponseSource, ApproverUPN | Rastreabilidade das decisões do Board |
| Marcos | Owner, Observacao, Criticidade, EvidenciaEntrega | Melhorar tracking de atraso |

### 6.3. Enums Oficiais

**StatusRAG / RAG**

| Valor | Definição |
|------|-----------|
| Verde | Projeto dentro do prazo, sem bloqueios críticos, risco controlado. |
| Amarelo | Projeto com risco, atraso moderado ou bloqueio que exige atenção. |
| Vermelho | Projeto crítico, bloqueado, com risco alto ou impacto relevante em prazo/escopo/qualidade. |

**Severidade de Risco**

| Valor | Definição |
|------|-----------|
| Baixa | Risco monitorável, sem impacto material imediato. |
| Média | Pode impactar prazo, qualidade ou dependência se não tratado. |
| Alta | Impacto provável em prazo, escopo, qualidade ou stakeholder. |
| Crítica | Exige escalação imediata para Sponsor/PMO/Board. |

**Status de Decisão**

| Valor | Definição |
|------|-----------|
| Pendente | Decisão criada e aguardando resposta. |
| Aprovada | Decisão aprovada pelo aprovador responsável. |
| Rejeitada | Decisão rejeitada com justificativa. |
| Adiada | Decisão postergada para nova data/prazo. |
| Cancelada | Decisão removida do fluxo por mudança de contexto. |

**Status de Risco/Bloqueio**

| Valor | Definição |
|------|-----------|
| Aberto | Risco/bloqueio identificado e ainda ativo. |
| Em Mitigação | Plano de mitigação em execução. |
| Escalado | Escalado para Sponsor/PMO/Board. |
| Resolvido | Risco/bloqueio solucionado. |
| Aceito | Risco aceito formalmente pela liderança. |

**OrigemEntrada**

| Valor | Definição |
|------|-----------|
| AdaptiveCard | Atualização enviada por card no Teams. |
| CopilotStudio | Atualização enviada via agente conversacional. |
| FormsFallback | Atualização enviada por Microsoft Forms. |
| ManualPMO | Atualização inserida manualmente pelo PMO. |
| ImportacaoInicial | Dados migrados ou cadastrados na carga inicial. |

---

## 7. Requisitos Funcionais e Épicos

| ID | Épico | Descrição / User Story | Prioridade | Critérios de Aceite |
|----|-------|------------------------|------------|---------------------|
| REQ-01 | Check-in Diário | Como PM, quero receber um Adaptive Card no Teams às 9h para atualizar o status do meu projeto rapidamente. | P0 | Card chega no chat/canal definido; campos RAG, resumo, risco, bloqueio, próxima ação e percentual; resposta grava em Status Diário; atualiza StatusRAG e UltimaAtualizacao em Projetos. |
| REQ-02 | Copilot STT/Text | Como PM, quero atualizar meu projeto falando ou digitando em linguagem natural no Teams. | P0 | Agente reconhece projeto, RAG, resumo, risco e próxima ação; confirma antes de gravar; grava no SharePoint via Power Automate standard. |
| REQ-03 | Portfólio Executivo | Como C-Level, quero ver todos os projetos agrupados por RAG em uma tab do Teams. | P0 | Tab do Teams com SharePoint List Board View; agrupamento por StatusRAG; mostra nome, PM, percentual e data alvo; reflete atualizações gravadas em SharePoint. |
| REQ-04 | Alerta Vermelho | Como Sponsor, quero ser notificado quando um projeto sob minha responsabilidade mudar para vermelho. | P0 | Flow detecta alteração para vermelho; posta no canal Projetos Críticos; menciona Sponsor quando suportado; inclui resumo, risco e bloqueio. |
| REQ-05 | On-Demand Update | Como PM, quero enviar atualizações a qualquer momento. | P0 | Botão ou comando de atualização disponível; múltiplos updates/dia aceitos; último update é status vigente. |
| REQ-06 | Decisão Board | Como Sponsor, quero aprovar/rejeitar decisões pendentes no Teams via card interativo. | P1 | Cada decisão possui DecisionID; resposta registra respondente, timestamp, decisão, justificativa e CardVersion; múltiplos aprovadores geram instâncias individuais ou padrão formal equivalente. |
| REQ-07 | Resumo Diário | Como Board, quero receber resumo consolidado às 17h no canal Board Status. | P1 | Card mostra total de projetos, distribuição RAG, projetos sem update e decisões pendentes. |
| REQ-08 | Alerta Sem Update | Como PMO, quero saber quais projetos não foram atualizados nas últimas 24h. | P1 | Flow roda às 10h; verifica DiasSemUpdate >= 1; envia lembrete ao PM e lista no canal PMO. |
| REQ-09 | Registro de Riscos | Como PM, quero registrar riscos via Copilot ou card e escalar riscos críticos automaticamente. | P1 | Risco grava na lista Riscos e Bloqueios; severidade crítica aciona alerta Sponsor + PMO. |
| REQ-10 | Consulta por Voz/Texto | Como Diretora, quero perguntar “como está o portfólio?” e receber resposta formatada. | P1 | Topic ConsultarPortfolio retorna distribuição RAG; Topic ConsultarProjeto faz drill-down; dados vêm do SharePoint. |
| REQ-11 | Sync Planner Standard | Como PMO, quero que tarefas abertas, concluídas e atrasadas do Planner Basic apareçam automaticamente no status do projeto sem Graph direto/Premium. | P1 MVP | Flow roda em recorrência controlada; usa conector Planner Standard `List tasks`; calcula total, abertas, concluídas, atrasadas e sem prazo; atualiza colunas na lista Projetos; registra erro/status de sync quando falhar. |
| REQ-12 | Resumo Semanal | Como Board, quero report semanal expandido toda segunda às 8h. | P2 | Inclui tendência semanal, entregas da semana, entregas atrasadas e decisões tomadas vs pendentes. |
| REQ-13 | Marcos e Entregas | Como PMO, quero rastrear entregas planejadas vs realizadas para medir atrasos em dias. | P2 | Lista Marcos com DataPlanejada e DataReal; coluna AtrasoDias; view filtrada por projeto. |
| REQ-14 | CriarProjeto | Como PMO, quero cadastrar um novo projeto pelo bot/card sem confundir projeto com tarefa. | P0 2.4 | Adaptive Card como Plano A; texto/STT como Plano B; cria somente em `Projetos`; gera `ProjectID`; exige confirmacao; duplicate guard impede criacao duplicada ativa; retorna SP ID e ProjectID. |
| REQ-15 | CriarTarefa | Como PM, quero criar uma tarefa em um projeto existente para que ela possa ser listada, atualizada e removida logicamente. | P0 2.4 | Resolve `NomeProjeto` ou `ProjectID` em `Projetos`; cria somente em `Tarefas`; nunca grava em `Projetos`; retorna ID da tarefa; bloqueia projeto inexistente/inativo/deletado; exige confirmacao. |
| REQ-16 | Gerar_Multiplos_Projetos | Como PMO, quero criar varios projetos e tarefas iniciais em lote com revisao visual antes da gravacao. | P0 2.4 | Adaptive Card de revisao/confirmacao e o caminho principal; parser multilinha/STT e fallback; suporta ate 10 projetos e 10 tarefas no primeiro corte; pareamento por indice; resultado por linha; sucesso parcial explicito; sem gravacao em modo validacao. |

---

## 8. Requisitos Não-Funcionais (NFRs)

### 8.1. UI/UX e Frontend

- **Design System:** Microsoft Fluent UI nativo via Teams, SharePoint e Adaptive Cards.
- **Dispositivos:** Teams Desktop, Teams Web e Teams Mobile.
- **Idioma:** Português (Brasil) como primário.
- **Acessibilidade:** Adaptive Cards devem seguir schema compatível com Teams e boas práticas de leitura por screen readers.
- **Densidade de informação:** Board View para executivos, List View para PMO e cards curtos para PMs.
- **Meta de UX:** PM completa check-in em <2 minutos no MVP e <1 minuto após estabilização.

### 8.2. Performance e Escala

- **Adaptive Card rendering no Teams:** alvo <2 segundos para cards simples.
- **Copilot Studio response:** alvo <5 segundos para consultas simples.
- **Power Automate flow execution:** alvo <30 segundos end-to-end para fluxos P0/P1.
- **SharePoint List view load:** alvo <3 segundos em views indexadas e filtradas com menos de 5.000 itens retornados.
- **Volumetria inicial:** até 200 projetos ativos simultâneos e até 50 PMs com check-in diário.
- **Status Diário:** aproximadamente 36.500 registros/ano considerando 200 projetos × ~182 dias úteis.

### 8.3. Power Automate Capacity Model

A capacidade não deve ser documentada como “6.000 runs/flow/mês”. O modelo correto para MVP deve considerar ações, retries, paginação e Power Platform requests por período.

| Item | Estimativa MVP | Observação |
|------|----------------|------------|
| Projetos ativos | Até 200 | Volume inicial previsto |
| PMs | Até 50 | Check-in diário |
| Runs/dia principais | ~250-500 | Check-ins, alertas, resumos e updates on-demand |
| Ações médias por run | 5-20 | Varia por fluxo |
| Estimativa ações/dia | ~2.500-10.000 | Deve ser monitorada pelo analytics do Power Automate |
| Perfil esperado | Low/Standard | Sem conectores Premium |
| Mitigação | reduzir ações, dividir fluxos, evitar loops grandes, indexar SharePoint | Aplicar antes de qualquer expansão |

### 8.4. SharePoint List Limits

- Até 30 milhões de itens por lista, mas com atenção ao limite prático de views.
- View threshold de 5.000 itens deve ser mitigado com indexação e views filtradas.
- Colunas críticas a indexar: `StatusRAG`, `ProjectID`, `DataRegistro`, `Ativo`, `Sponsor`, `PM`, `UltimaAtualizacao`.

### 8.5. Adaptive Cards — Limite de Tamanho

O limite depende do canal de postagem. Para o padrão MVP com Power Automate/Teams, adotar limite operacional conservador:

- **Incoming Webhooks:** considerar limite de 28 KB.
- **Bot messages:** considerar até 100 KB quando aplicável.
- **Padrão interno do MVP:** manter Adaptive Cards críticos abaixo de **27 KB**.
- Validar renderização em Teams Desktop, Web e Mobile.
- Versionar cada card com `CardVersion`.

### 8.6. Planner Basic — Capacidade e Mitigação

O Planner Basic permanece suficiente para o MVP, pois a capacidade do produto é maior que a necessidade prevista atual.

| Limite Planner | Valor de referência | Decisão MVP |
|----------------|--------------------|-------------|
| Tarefas ativas por plano | 3.000 | Não preocupante para o volume atual. |
| Tarefas totais por plano | 9.000 | Monitorar apenas em planos muito longos. |
| Buckets por plano | 200 | Suficiente para uso por equipe/projeto. |

**Mitigação futura:** se algum plano se aproximar de 70-80% dos limites ou se houver necessidade de dependências, timeline, gestão avançada ou relatórios nativos, avaliar Planner Premium/Project como evolução, condicionada à aprovação de licença e arquitetura.

### 8.7. Sync Automático Planner — Workaround Standard-Only

O MVP manterá a contagem automática de tarefas abertas, concluídas e atrasadas usando o conector nativo **Planner Standard** do Power Automate, sem Microsoft Graph direto e sem conectores Premium.

| Métrica | Regra de cálculo |
|--------|------------------|
| TarefasTotal | `length(value)` retornado pela ação `List tasks`. |
| TarefasConcluidas | `percentComplete = 100` ou `completedDateTime` preenchido. |
| TarefasAbertas | `percentComplete < 100`. |
| TarefasAtrasadas | `percentComplete < 100` e `dueDateTime < utcNow()`. |
| TarefasSemPrazo | `percentComplete < 100` e `dueDateTime` vazio. |

**Frequência recomendada:** 1 a 4 vezes ao dia no MVP, com controle de concorrência e delay para respeitar throttling do conector Planner.

---

## 9. Segurança, Governança e Compliance

### 9.1. Autenticação e Autorização

- **Autenticação:** Microsoft Entra ID / Authenticate with Microsoft no Copilot Studio.
- **No authentication:** bloqueado por política DLP/governança.
- **Autorização:** SharePoint Permission Levels e grupos de segurança corporativos.
- **Grupos mínimos:** `PMO-PMs`, `PMO-Board`, `PMO-Admins`, `PMO-Sponsors`.

### 9.2. DLP e Restrições Técnicas

- Bloquear conectores Premium não aprovados.
- Bloquear HTTP e HTTP with Microsoft Entra ID.
- Bloquear public websites como knowledge source.
- Permitir apenas SharePoint site aprovado (`PMO-Hub`) como fonte corporativa.
- Não publicar agente em canais externos como Direct Line, websites públicos, WhatsApp ou canais não aprovados.
- Permitir publicação apenas no Microsoft Teams/M365, conforme política do tenant.

### 9.3. Copilot Studio Guardrails

- Confirm-Before-Action obrigatório para escrita.
- LowConfidence fallback para NLU confidence < 0.6.
- Agente restrito ao SharePoint PMO-Hub e aos fluxos Power Automate aprovados.
- Sem chamadas HTTP externas.
- Sem acesso a fontes públicas.
- Sem ações fora do escopo do PMO.
- Logs de execução e erros devem ser monitorados pelo PMO Admin/CoE.

### 9.4. Capacidade Copilot Studio — Estimativa e Fallback

| Item | Estimativa MVP |
|------|----------------|
| Usuários PM ativos | 50 |
| Usuários executivos/sponsors | 20-40 |
| Interações PM/dia | 1-3 por PM |
| Consultas executivas/dia | 10-30 |
| Interações/dia estimadas | 100-250 |
| Interações/mês estimadas | 2.200-5.500 em dias úteis |
| Risco | consumo acima da capacidade contratada ou política mensal |

**Fallback quando capacidade/licença exceder:**

1. Priorizar Adaptive Cards e Forms para check-in diário.
2. Reduzir uso de Copilot para consultas não críticas.
3. Manter SharePoint Tabs como fonte oficial de leitura executiva.
4. Registrar updates via Forms/Adaptive Card enquanto capacidade é regularizada.
5. Acionar PMO Lead + Power Platform Admin para revisão de capacidade.

### 9.5. LGPD/GDPR

- Dados armazenados: nome corporativo, email corporativo, status de projeto, riscos, bloqueios, decisões e responsáveis.
- Nenhum dado pessoal sensível deve ser registrado.
- Nenhum dado pessoal de clientes deve ser processado no MVP.
- Retenção sugerida: 2 anos para Status Diário; depois arquivamento/export.
- Auditoria de SharePoint/M365 deve permanecer habilitada conforme política corporativa.

---

## 10. Arquitetura e Stack

### 10.1. Desenho Macro — MVP Standard-Only

```text
┌─────────────────────────────────────────────────────────┐
│                    MICROSOFT TEAMS                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Copilot  │  │ Adaptive │  │ Tabs SP  │  │ Canais  │ │
│  │ Studio   │  │ Cards    │  │ Views    │  │ Temát.  │ │
│  │ Agent    │  │ (PA)     │  │          │  │         │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬────┘ │
└───────┼──────────────┼────────────┼──────────────┼──────┘
        │              │            │              │
        ▼              ▼            │              │
┌───────────────────────────┐       │              │
│    POWER AUTOMATE         │       │              │
│  10 Cloud Flows           │───────┘              │
│  Standard Connectors      │──────────────────────┘
└───────────┬───────────────┘
            │
            ▼
┌───────────────────────────┐     ┌─────────────────────┐
│   SHAREPOINT ONLINE       │     │   PLANNER BASIC     │
│  ┌──────────────────────┐ │     │  ┌───────────────┐  │
│  │ Lista: Projetos      │ │     │  │ Tarefas por   │  │
│  │ Lista: Status Diário │ │     │  │ equipe/projeto│  │
│  │ Lista: Riscos        │ │     │  │ sync standard │  │
│  │ Lista: Decisões      │ │     │  └───────────────┘  │
│  │ Lista: Marcos opt.   │ │     └─────────────────────┘
│  └──────────────────────┘ │
│  ┌──────────────────────┐ │
│  │ SP Page: Dashboard   │ │
│  └──────────────────────┘ │
└───────────────────────────┘
```

### 10.2. Stack

- **Frontend:** Microsoft Teams + SharePoint views.
- **Conversational AI:** Copilot Studio com autenticação Microsoft.
- **Orquestração:** Power Automate Cloud Flows com conectores standard.
- **Persistência:** SharePoint Online Lists.
- **Execução operacional:** Planner Basic com sync automático via conector Planner Standard.
- **Identidade:** Microsoft Entra ID.

### 10.3. Pontos de Integração Permitidos

#### 10.3.1. Endpoints Oficiais do MVP

| Tipo | Endpoint |
|------|----------|
| Canal Teams oficial | `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920` |
| SharePoint oficial | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/SitePages/Home.aspx` |

#### 10.3.2. Conectores Permitidos

| Sistema | Método | Sentido | Connector | Status |
|---------|--------|---------|-----------|--------|
| SharePoint Online | List trigger/actions | Inbound/Outbound | SharePoint Standard | Permitido |
| Microsoft Teams | Post Adaptive Card / Post Message | Outbound | Teams Standard | Permitido |
| Copilot Studio | When agent calls flow | Inbound | Power Automate Standard conforme tenant | Permitido com governança |
| Microsoft Forms | When response submitted | Inbound | Forms Standard | Permitido como fallback |
| Outlook 365 | Send email notification | Outbound | Office 365 Outlook Standard | Permitido se necessário |
| Planner Basic | `List tasks` | Inbound | Planner Standard | Permitido para sync automático de métricas |

### 10.4. Integrações Bloqueadas no MVP

| Sistema/Recurso | Motivo |
|-----------------|--------|
| Microsoft Graph direto / REST API custom | Não autorizado pela organização. |
| HTTP with Microsoft Entra ID | Premium no Power Automate e não autorizado. |
| HTTP genérico | Bloqueado por governança/DLP. |
| Custom connectors | Fora do escopo MVP e potencial Premium. |
| Conectores não Microsoft | Fora do escopo MVP. |
| Azure DevOps/Jira APIs | Integrações externas fora do escopo. |

---

## 11. Limites Técnicos Documentados

| Componente | Limite / Referência | Impacto | Mitigação |
|-----------|---------------------|---------|-----------|
| SharePoint List | Até 30M itens/lista | Baixo no MVP | Governar views e retenção |
| SP View Threshold | 5.000 itens por view | Pode impactar views grandes | Indexar colunas e filtrar views |
| Power Automate Requests | Medido por Power Platform requests e perfil de performance | Requer monitoramento | Reduzir ações, loops e retries |
| Adaptive Cards | 28 KB Incoming Webhooks; até 100 KB bot messages; padrão interno <27 KB | Cards grandes podem falhar | Cards curtos e versionados |
| Planner Basic | 3.000 tarefas ativas/plano; 9.000 tarefas totais/plano; 200 buckets/plano | Não crítico no MVP | Monitorar 70-80% e avaliar Premium futuramente |
| Copilot Studio Capacity | Consumo por Copilot Credits/capacidade mensal | Pode gerar bloqueio se excedido | Fallback para Cards/Forms/SP Tabs |

---

## 12. Agentes de IA / LLM — Copilot Studio Agent

### 12.1. Agente Principal

- **Plataforma:** Microsoft Copilot Studio.
- **Canal de deploy:** Microsoft Teams.
- **Idioma:** pt-BR primário.
- **Nome do agente:** “PMO Assistant” ou “Assistente PMO”.
- **Autenticação:** Authenticate with Microsoft.
- **Fontes permitidas:** SharePoint PMO-Hub e fluxos Power Automate aprovados.

### 12.2. Grau de Autonomia

- **Leitura:** autônoma para consultas ao portfólio permitido.
- **Escrita:** Confirm-Before-Action obrigatório.
- **Escalação:** se confidence < 0.6, pedir reformulação.
- **Escopo:** restrito a PMO-Hub; sem internet, sem HTTP, sem public websites, sem Graph direto. O conector Planner Standard é permitido apenas para métricas de tarefas do Planner Basic.

### 12.3. Topics e Fluxos Detalhados

| # | Topic | Intent | Entities Extraídas | Flow PA Chamado | Resposta |
|---|-------|--------|-------------------|-----------------|----------|
| 1 | AtualizarStatus | Atualizar status de projeto | ProjectName, StatusRAG, Resumo, Risco, ProximaAcao, Percentual | PMO_PA_ProcessarRespostaCheckIn | Confirmação + resultado |
| 2 | ConsultarPortfolio | Ver resumo do portfólio | — | Consulta SharePoint permitida | Distribuição RAG + destaques |
| 3 | ConsultarProjeto | Ver detalhes de 1 projeto | ProjectName | Consulta SharePoint permitida | Status, riscos, últimos updates |
| 4 | RegistrarRisco | Criar novo risco | ProjectName, Descricao, Severidade | PMO_PA_EscalarRiscoCritico | Confirmação + alerta se crítico |
| 5 | RegistrarBloqueio | Criar bloqueio | ProjectName, Descricao, Impacto | PMO_PA_EscalarRiscoCritico | Confirmação + escalação |
| 6 | PedirDecisao | Solicitar decisão do Board | ProjectName, Descricao, Impacto, Prazo | PMO_PA_RegistrarDecisaoBoard | Confirmação + card no canal |
| 7 | LowConfidence | Fallback | — | — | Pede reformulação |
| 8 | Greeting | Saudação | — | — | Apresentação + menu |

---

## 13. Decisões do Board — Padrão de Rastreabilidade

Cada decisão deve ser tratada como item único e rastreável.

### 13.1. Regra Obrigatória

- Toda decisão deve possuir `DecisionID`.
- Cada resposta deve registrar:
  - `DecisionID`
  - `ProjectID`
  - `Aprovador`
  - `ApproverUPN`
  - `DataResposta`
  - `Resposta`
  - `Justificativa`
  - `CardVersion`
  - `ResponseSource`

### 13.2. Múltiplos Aprovadores

Quando houver múltiplos aprovadores:

- Gerar uma instância individual por aprovador; ou
- Usar padrão formal equivalente aprovado pelo PMO; ou
- Reavaliar uso futuro de Approvals caso a governança/licença permita.

### 13.3. Critério de Aceite

Nenhuma decisão pode ser considerada concluída sem registro de responsável, timestamp, decisão e status final na lista Decisões.

---

## 14. Plano de Lançamento (Roadmap)

### Fase 0 — Design e Preparação (Semana 0-1)

- **Concluído:** conectores e DLP validados para o MVP Standard-Only.
- **Concluído:** ambiente base Teams/SharePoint definido.
- Canal oficial Teams: `Projetos_Tranformação_Digital`.
- SharePoint oficial: `Grp_T_DN_Transformacao_Digital`.
- Definir naming convention (`PRJ-XXX`).
- Configurar ou validar security groups vinculados ao ambiente oficial.
- Cadastrar projetos piloto.
- **Gate:** conectores/DLP validados, canal Teams oficial definido, site SharePoint oficial definido e grupos de segurança validados.

### Fase 1 — MVP Core (Semanas 1-3)

- Criar programaticamente, durante o deploy, as 4 SharePoint Lists com schema completo.
- Criar programaticamente colunas, índices, views Board/Gallery/List, permissões e configurações obrigatórias.
- Criar programaticamente os artefatos de SharePoint necessários no site oficial `Grp_T_DN_Transformacao_Digital`.
- Implementar flows P0.
- Criar 3 Adaptive Cards abaixo de 27 KB.
- Embeddar SharePoint views como tabs no canal Teams oficial `Projetos_Tranformação_Digital`.
- **Gate:** deploy cria a estrutura sem dependência manual, PM atualiza status via card e Board visualiza na tab.

### Fase 2 — Copilot Studio Agent (Semanas 3-5)

- Criar agente no Copilot Studio.
- Configurar 8 topics.
- Criar entidades customizadas.
- Conectar topics aos flows aprovados.
- Implementar Confirm-Before-Action.
- Publicar no Teams com Authenticate with Microsoft.
- Testar com 3 PMs piloto.
- **Gate:** PM atualiza status por linguagem natural com confirmação.

### Fase 3 — Automação Completa Standard-Only (Semanas 5-7)

- Implementar flows P1/P2 permitidos: ResumoDiario, ResumoSemanal, EscalarRisco, RegistrarDecisao.
- Criar SharePoint Page Dashboard.
- Configurar canais temáticos com cards automáticos.
- Criar Forms fallback como tab.
- **Gate:** sistema standard-only operacional sem Graph direto/Premium, incluindo sync Planner via conector Planner Standard.

### Fase 4 — Piloto Controlado (Semanas 7-8)

- Onboarding de todos os PMs.
- Guia rápido de uso.
- Vídeo curto de treinamento.
- Monitorar taxa de adoção diária.
- Coletar feedback dos PMs e Board.
- Ajustar flows e topics.
- **Gate:** >70-80% de taxa de atualização diária por 5 dias consecutivos.

### Fase 5 — Expansão (Semana 9+)

- Criar lista Marcos e Entregas.
- Templates de Planner por tipo de projeto.
- Provisionamento padronizado de novos projetos.
- Métricas de adoção e SLA de resposta.
- Avaliar Planner Premium/Microsoft Graph direto apenas se houver autorização futura para requisitos além do conector Planner Standard.

---

## 15. ALM, Operação e Suporte

### 15.1. Ambientes

- DEV: construção e testes técnicos.
- UAT: validação com PMs piloto e PMO Lead.
- PROD: operação oficial.

#### Ambiente Base Oficial do MVP

| Camada | Ambiente/Endpoint Oficial |
|--------|----------------------------|
| Teams | Canal `Projetos_Tranformação_Digital` |
| SharePoint | Site `Grp_T_DN_Transformacao_Digital` |
| Deploy | Criação programática de listas, colunas, índices, views, páginas/tabs e configurações obrigatórias |
| DLP/Conectores | Validados para uso Standard-Only |

### 15.2. Governança de Mudança

- Toda alteração em lista, fluxo, card ou topic deve ter versão.
- Adaptive Cards devem usar `CardVersion`.
- Flows devem ter owner técnico e co-owner PMO.
- Mudanças em PROD devem ser registradas em log de mudança.

### 15.3. Monitoramento

- Monitorar falhas de flows diariamente no piloto.
- Monitorar consumo de ações/requests do Power Automate.
- Monitorar capacidade do Copilot Studio.
- Monitorar projetos sem atualização.
- Criar rotina semanal de health check.

### 15.4. Runbook Mínimo

| Incidente | Ação |
|----------|------|
| Flow falhou | Verificar run history, corrigir item/ação, reprocessar manualmente se necessário. |
| Card não renderizou | Validar JSON, tamanho <27 KB e compatibilidade Teams Desktop/Mobile. |
| Copilot não entendeu | Acionar LowConfidence, revisar trigger phrases/entities. |
| Capacidade Copilot excedida | Ativar fallback Cards/Forms/SP Tabs. |
| SharePoint view lenta | Revisar filtros, indexação e volume retornado. |

---

## 16. Nota Pós-Ajustes e Avaliação Final

### 16.1. Nota Final

**Nota após alterações:** **94/100**

### 16.2. Justificativa

A PRD agora está mais realista, executável e alinhada às restrições corporativas. O principal risco anterior era prometer automação via Graph/Premium apesar de o projeto não ter autorização/licença. Esse risco foi removido sem sacrificar a feature crítica de contagem automática de tarefas, que foi redesenhada para usar o conector Planner Standard.

### 16.3. O Que Melhorou

- Escopo MVP ficou coerente com “standard only”.
- Graph direto e Premium foram removidos do caminho crítico.
- Planner Sync foi mantido no MVP por meio do conector Planner Standard.
- Modelo de dados foi explicitado.
- Enums oficiais foram definidos.
- Decisões do Board ganharam rastreabilidade por DecisionID.
- Adaptive Cards ganharam limite operacional de 27 KB.
- Governança Copilot Studio foi fortalecida.
- Capacidade e fallback foram documentados.
- Roadmap foi ajustado para metas realistas de adoção.

### 16.4. Risco Residual

| Risco | Severidade | Mitigação |
|------|------------|-----------|
| Adoção baixa pelos PMs | Média | Treinamento curto, cards simples e cobrança executiva. |
| Flow throttling/erros | Média | Monitoramento diário, reduzir ações e dividir fluxos. |
| Capacidade Copilot excedida | Média | Fallback Cards/Forms/SP Tabs. |
| SharePoint views lentas | Média | Indexação, filtros e retenção. |
| Falha ou throttling no sync Planner Standard | Média | Controle de concorrência, delay, frequência controlada, status de sync e fallback manual ResumoTarefas. |

### 16.5. Recomendação Executiva

**Aprovar para build/deploy programático do MVP Standard-Only com sync Planner via conector standard no ambiente oficial já definido.**  
A solução mantém a contagem automática de tarefas abertas, concluídas e atrasadas sem Premium e sem Graph direto, preservando o valor executivo de visibilidade operacional do portfólio. O canal Teams `Projetos_Tranformação_Digital` e o site SharePoint `Grp_T_DN_Transformacao_Digital` passam a ser os endpoints oficiais do MVP.

---

## 17. Referências Oficiais

| # | Tema | URL |
|---|------|-----|
| 1 | HTTP with Microsoft Entra ID — conector Premium | https://learn.microsoft.com/en-us/connectors/webcontentsv2/ |
| 2 | Power Automate Limits | https://learn.microsoft.com/en-us/power-automate/limits-and-config |
| 3 | Planner Limits | https://learn.microsoft.com/en-us/planner/planner-limits |
| 3.1 | Planner Connector — Power Automate Standard e List tasks | https://learn.microsoft.com/en-us/connectors/planner/ |
| 4 | Teams Adaptive Cards Size Limits | https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-format |
| 5 | Teams Connector for Power Automate | https://learn.microsoft.com/en-us/connectors/teams/ |
| 5.1 | Teams e SharePoint Integration | https://learn.microsoft.com/en-us/sharepoint/teams-connected-sites |
| 5.2 | Lists app como tab no Teams | https://learn.microsoft.com/en-us/microsoftteams/manage-lists-app |
| 6 | Copilot Studio Licensing | https://learn.microsoft.com/en-us/microsoft-copilot-studio/billing-licensing |
| 7 | Copilot Studio DLP/Data Policies | https://learn.microsoft.com/en-us/microsoft-copilot-studio/admin-data-loss-prevention |
| 8 | SharePoint Online Limits | https://learn.microsoft.com/en-us/office365/servicedescriptions/sharepoint-online-service-description/sharepoint-online-limits |
| 9 | SharePoint Permission Levels | https://learn.microsoft.com/en-us/sharepoint/understanding-permission-levels |
| 10 | Adaptive Cards Schema | https://adaptivecards.io/explorer/ |

---

*PRD ajustado. Solução MVP Standard-Only — SharePoint Hub + Teams + Power Automate Standard + Copilot Studio Agent. Microsoft Graph direto e HTTP/Premium connectors permanecem bloqueados; sync automático Planner foi mantido via conector Planner Standard.*
