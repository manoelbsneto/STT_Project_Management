# PROMPT — Manual de Operações PMO Intelligent Hub (para Gemini 3.1 Pro)

## Tarefa
Criar o **Manual de Operações do PMO Intelligent Hub** — um documento completo, em **Português do Brasil**, que será compartilhado com todos os Project Managers (PMs) da organização. O manual deve permitir que qualquer PM, mesmo um estagiário no primeiro dia de trabalho, consiga operar 100% da ferramenta sem precisar pedir ajuda.

## Localização do Manual
Salvar em: `docs/MANUAL_OPERACOES_PMO_HUB.md`

## Idioma
100% Português do Brasil. Sem termos técnicos não explicados. Quando usar siglas (RAG, PM, SP), explicar na primeira vez.

## Tom e Nível de Detalhe
- Escrever como se estivesse ensinando um estagiário no primeiro dia de emprego
- Cada passo deve ter: **o que clicar**, **onde clicar**, **o que preencher**, **o que esperar como resultado**
- Usar emojis para indicar ações: 🖱️ (clicar), ⌨️ (digitar), 👁️ (verificar), ⏳ (aguardar)
- Incluir capturas de tela reais da aplicação (usar browser para navegar e capturar screenshots do SharePoint e Teams)
- Incluir exemplos concretos com dados fictícios realistas (ex: "Projeto Migração SAP", "Portal do Colaborador")
- Incluir seção de "Erros Comuns e Soluções" em cada capítulo

## Estrutura Obrigatória do Manual

### Capa
- Título: "Manual de Operações — PMO Intelligent Hub"
- Subtítulo: "Guia Completo para Gestores de Projeto"
- Versão: 1.0
- Data: 2026-05-04
- Autor: Equipe PMO — Transformação Digital

### Capítulo 1: O que é o PMO Intelligent Hub?
- O que é a ferramenta e por que foi criada
- Qual problema ela resolve (antes: 35 min/dia de report manual → agora: <30 segundos)
- Quem são os usuários: PM, Sponsor, Board, PMO
- Visão geral da arquitetura (diagrama simples): SharePoint → Power Automate → Teams → Copilot
- Glossário: RAG (Red/Amber/Green), StatusRAG, Check-in, Adaptive Card, Board, Sprint, etc.

### Capítulo 2: Acessando o Sistema
- Como acessar o canal do Teams (link direto obrigatório): `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920`
- Como acessar o SharePoint: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
- Screenshots de como navegar no Teams até o canal
- Screenshots de como navegar no SharePoint até as listas
- Explicar as 3 tabs do Teams: Portfolio_Executivo, Projetos_Criticos, Decisoes do Board

### Capítulo 3: Cadastrando um Novo Projeto (Passo a Passo Completo)
- **Pré-requisito:** Ter acesso ao SharePoint com permissão de edição
- Passo 1: Abrir a lista "Projetos" no SharePoint (screenshot)
- Passo 2: Clicar em "+ Adicionar novo item" (screenshot com seta indicando o botão)
- Passo 3: Preencher TODOS os campos do formulário, um por um:
  - `ProjectID` — Código único do projeto (ex: PRJ-006). Regra: PRJ-XXX sequencial
  - `NomeProjeto` — Nome completo (ex: "Migração SAP S/4HANA")
  - `PM` — Pessoa responsável (selecionar do diretório)
  - `Sponsor` — Executivo responsável (selecionar do diretório)
  - `StatusRAG` — Selecionar: Verde ✅, Amarelo ⚠️, ou Vermelho 🔴
  - `PercentualConcluido` — Número de 0 a 100
  - `DataInicio` — Data de início do projeto
  - `DataAlvo` — Data prevista de conclusão
  - `Ativo` — Sim (projetos ativos) ou Não (encerrados)
  - `ResumoExecutivo` — Texto livre com resumo do status atual
  - `ProximaAcao` — Próximo passo concreto do projeto
  - `PlanoID` — ID do plano no Planner (se houver)
  - Explicar cada campo com exemplo concreto preenchido
- Passo 4: Clicar em "Salvar" (screenshot)
- Passo 5: Verificar que o projeto aparece na lista (screenshot)
- Passo 6: Verificar que o projeto aparece na tab "Portfolio_Executivo" no Teams (screenshot)
- **Exemplo completo preenchido** com dados fictícios realistas
- **Erros comuns:** campo obrigatório vazio, ProjectID duplicado, StatusRAG não selecionado

### Capítulo 4: Atualizando o Status do Projeto (Check-in Diário)
- **Método 1: Via Adaptive Card no Teams (recomendado)**
  - Às 9h, você recebe automaticamente um card no canal do Teams
  - Screenshot do card de Check-in como aparece no Teams
  - Passo 1: Localizar o card "Check-in Diário" no canal
  - Passo 2: Selecionar seu projeto no dropdown
  - Passo 3: Selecionar o StatusRAG (Verde/Amarelo/Vermelho)
  - Passo 4: Preencher "Resumo" com o status atual (ex: "Sprint 3 em andamento, 2 bugs críticos resolvidos")
  - Passo 5: Preencher "Principal Risco" se houver (ex: "Dependência do time de infra para deploy")
  - Passo 6: Preencher "Próxima Ação" (ex: "Finalizar testes de integração até sexta")
  - Passo 7: Informar % de conclusão
  - Passo 8: Clicar "Enviar" ✅
  - O que acontece depois: dados são gravados automaticamente no SharePoint
  - Screenshot do card após envio (confirmação)
- **Método 2: Via Copilot (Assistente PMO) por texto/voz**
  - Como abrir o chat com o Assistente PMO no Teams
  - Passo 1: Digitar ou falar: "Atualizar projeto PRJ-001 para amarelo, sprint atrasada por bug crítico"
  - Passo 2: O bot confirma o que entendeu e pede confirmação
  - Passo 3: Confirmar clicando "Sim" ou digitando "sim"
  - Passo 4: Bot confirma gravação no SharePoint
  - Dica: usar Win+H para ditar por voz no Windows
- **Método 3: Direto no SharePoint (fallback)**
  - Abrir a lista Projetos → clicar no projeto → editar campos → salvar
  - Quando usar: se o card não chegou ou o Copilot não está disponível

### Capítulo 5: O que Esperar no Dia a Dia (Rotina do PM)
Tabela com a rotina diária:

| Horário | O que acontece | Sua ação |
|---------|---------------|----------|
| 09:00 | Card de Check-in chega no canal Teams | Preencher e enviar em <30 segundos |
| 10:00 | Se não atualizou, lembrete automático chega | Atualizar imediatamente |
| 17:00 | Resumo diário do Board é postado no canal | Nenhuma — é informativo para o Board |
| Segunda 08:00 | Resumo semanal expandido é postado | Nenhuma — é informativo para o Board |
| A qualquer momento | Projeto muda para Vermelho | Alerta automático é enviado ao Sponsor |
| A qualquer momento | Você pode consultar via Copilot | Perguntar "como está o portfólio?" |

### Capítulo 6: Registrando Riscos e Bloqueios
- O que é um risco vs um bloqueio
- **Via SharePoint:**
  - Abrir lista "Riscos e Bloqueios" → + Novo
  - Campos: ProjectID, Descrição, Tipo (Risco/Bloqueio), Severidade (Baixa/Média/Alta/Crítica), Responsável, Status
  - Se Severidade = Crítica → alerta automático é enviado ao Sponsor e PMO
  - Screenshot de exemplo preenchido
- **Via Copilot:**
  - "Registrar risco crítico no PRJ-001: atraso de fornecedor externo"
  - Bot confirma → você aprova → gravado no SharePoint
- **Erros comuns:** não selecionar severidade, não vincular ao projeto

### Capítulo 7: Decisões do Board
- O que são decisões e como o fluxo funciona
- Quem solicita: PM ou PMO
- Quem aprova: Sponsor ou Board
- **Criando uma decisão:**
  - Abrir lista "Decisões do Board" → + Novo
  - Campos: Título, Descrição, Projeto, Solicitante, Prioridade, Status (Pendente)
  - Após criar, card de aprovação é enviado automaticamente ao canal
- **Aprovando uma decisão (Sponsor):**
  - Card aparece no canal Teams com botões Aprovar/Rejeitar/Adiar
  - Clicar no botão → status atualizado automaticamente no SharePoint
  - Screenshot do card de decisão
- **Consultando decisões pendentes:**
  - Tab "Decisoes do Board" no Teams mostra todas as pendentes
  - Via Copilot: "Quais decisões estão pendentes?"

### Capítulo 8: Consultando o Portfólio (Painéis e Reports)
- **Tab Portfolio_Executivo no Teams:**
  - View Board agrupada por StatusRAG
  - Verde = projetos saudáveis, Amarelo = atenção, Vermelho = críticos
  - Screenshot da view com dados reais
  - Como interpretar: se tem muitos vermelhos → reunião de escalação
- **Tab Projetos_Criticos:**
  - Filtro automático: só mostra projetos Vermelho
  - Screenshot
- **Via Copilot:**
  - "Como está o portfólio?" → retorna distribuição RAG
  - "Como está o projeto PRJ-001?" → retorna detalhes completos
  - "Quais projetos estão vermelhos?" → lista filtrada
  - Screenshots de cada conversa

### Capítulo 9: Cards Automáticos — O que são e onde aparecem
- Explicar o conceito de Adaptive Cards
- Tabela de todos os cards:

| Card | Quando aparece | Onde aparece | Sua ação |
|------|---------------|-------------|----------|
| Check-in Diário | 09:00 todo dia útil | Canal Teams | Preencher e enviar |
| Lembrete | 10:00 se não atualizou | Canal Teams | Atualizar ASAP |
| Resumo Diário Board | 17:00 todo dia útil | Canal Teams | Nenhuma (informativo) |
| Resumo Semanal | Segunda 08:00 | Canal Teams | Nenhuma (informativo) |
| Alerta Projeto Vermelho | Quando StatusRAG→Vermelho | Canal Teams | Sponsor: verificar/escalar |
| Decisão Board | Quando criada nova decisão | Canal Teams | Sponsor: Aprovar/Rejeitar |
| Escalação Risco Crítico | Quando risco Severidade=Crítica | Canal Teams | Sponsor/PMO: agir |

- Screenshot de cada tipo de card

### Capítulo 10: Usando o Assistente PMO (Copilot) por Voz
- O que é o Assistente PMO
- Como abrir o chat no Teams
- Comandos que ele entende (com exemplos):
  - "Olá" → saudação
  - "Como está o portfólio?" → distribuição RAG
  - "Como está o projeto [nome]?" → detalhes do projeto
  - "Atualizar projeto [nome] para [cor]" → atualiza status (com confirmação)
  - "Registrar risco [severidade] no [projeto]: [descrição]" → cria risco
  - "Quais decisões estão pendentes?" → lista decisões
- Como usar por voz: Win+H no Windows, botão de microfone no mobile
- Screenshot de cada interação
- **O que ele NÃO faz:** não acessa internet, não inventa dados, não modifica sem confirmação

### Capítulo 11: Perguntas Frequentes (FAQ)
- "Não recebi o card de check-in às 9h, o que fazer?" → Usar Copilot ou SP direto
- "Posso atualizar mais de uma vez por dia?" → Sim, último update é o vigente
- "O card não está aparecendo no celular" → Verificar app Teams atualizado
- "Errei o status, como corrigir?" → Atualizar novamente ou editar no SP
- "Quem vê minhas atualizações?" → PMO, Sponsor, Board (conforme permissões)
- "Posso ver projetos de outros PMs?" → Sim, via tab Portfolio ou Copilot
- "O bot não entendeu meu comando" → Reformular ou usar card/SP direto

### Capítulo 12: Contatos e Suporte
- Quem contatar em caso de problemas
- Canal de suporte
- Email do PMO

## Requisitos Técnicos para Construção
- **Screenshots:** Navegar via browser no SharePoint (`https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos`) e Teams (deep link acima) para capturar screenshots reais de cada tela mencionada
- **Formato:** Markdown com imagens embeddadas
- **Imagens:** Salvar em `docs/images/` e referenciar com caminho relativo
- **Se não conseguir capturar screenshot real:** usar a tool de geração de imagem para criar mockup fiel da tela Microsoft, com dados realistas em português

## Dados Reais para Referência (usar nos screenshots/exemplos)
Projetos existentes na lista:
- PRJ-001 — Migração ERP (Verde, 45%)
- PRJ-002 — App Mobile RH (Amarelo, 60%)
- PRJ-003 — Portal do Colaborador (Vermelho, 25%)
- PRJ-004 — Dashboard BI (Verde, 80%)
- PRJ-005 — Automação Fiscal (Amarelo, 35%)

## Referências de Arquitetura (ler antes de começar)
- PRD completo: `PRD/PRD_PMO_M365.md`
- Card JSONs: `deploy/cards/` (6 arquivos)
- Endpoints: `.planning/.env`
- State atual: `.planning/STATE.md`
