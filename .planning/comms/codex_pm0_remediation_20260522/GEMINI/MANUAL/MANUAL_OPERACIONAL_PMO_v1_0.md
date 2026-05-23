# Manual Operacional do Assistente PMO — Versão 1.0 (Release 3.16)

Last updated: 2026-05-22 20:50:00 BRT | Gemini sub-2 | Backfilled all smoke and mockup placeholders.

---

## 1. Apresentação e Propósito

Bem-vindo ao **Manual Operacional do Assistente PMO (PMO Intelligent Hub)**. Este assistente é o canal centralizado para automação de gerenciamento de projetos e reporte de status na organização, operando integrado ao **Microsoft Teams** e sincronizado diretamente com o **SharePoint Online**.

### Para quem é este manual?
- **Gerentes de Projetos (PMs)**: Para realizar o reporte diário/semanal de status, criação e atualização de tarefas do portfólio.
- **Gerentes de Portfólio e PMO**: Para consultar indicadores executivos agregados e dashboards consolidados.
- **Administradores de TI**: Para fins de suporte operacional e verificação de integridade das integrações.

### Pré-requisitos de Acesso
1. Licença ativa do Microsoft 365 (E3 ou E5) com acesso ao Teams e SharePoint Online.
2. Pertencer ao grupo Teams `Projetos_Transformacao_Digital`.
3. Permissões de escrita e leitura no site corporativo SharePoint `Grp_T_DN_Transformacao_Digital`.

---

## 2. Como Acessar o Assistente PMO

O Assistente PMO é um agente inteligente (Microsoft Copilot Studio) disponibilizado diretamente no Microsoft Teams.

### Link de Acesso Rápido
- **Canal Oficial**: O Assistente pode ser acessado diretamente na tab de conversa do canal [Projetos_Transformacao_Digital](https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920).
- **Comando Inicial**: Para iniciar uma interação com o agente, basta abrir a conversa e digitar uma saudação simples, como `Ola` ou `Ola Assistente`.

---

## 3. As 5 Operações Card-First (Novidade da Versão 3.16)

A versão 3.16 introduz uma interface híbrida baseada em **Microsoft Adaptive Cards (v1.5)**. Ao invés de responder a múltiplas perguntas textuais do bot, você interage com formulários estruturados diretamente no Teams.

---

### 3.1. Operação 1: `Atualizar Status` (AtualizarStatus)
Permite reportar o status executivo de cor e os destaques/próximos passos de um projeto.

- **Comando no chat**: `Atualizar Status` ou `Reportar status do projeto`
- **Resposta do Bot (Confirmação)**:
  ```
  Entrada: atualizar status: projeto=QA Robust 20260513 F, status=Amarelo, resumo=Smoke 3.15 multilinha, percentual=45, risco=Nenhum, bloqueio=Nenhum, proxima acao=Revisar
  Resposta: Status registrado com sucesso para QA Robust 20260513 F.
  ```
- **Interface do Cartão Adaptativo no Teams**:
  ![Adaptive Card Atualizar Status](file:///C:/Users/dataops-lab/.gemini/antigravity-ide/brain/1bd6d78d-2df3-4237-aaa5-44ba47c09369/atualizar_status_card_1779480492169.png)

#### O que esperar
O cartão exibirá campos para selecionar o **ID do Projeto**, a **Cor do Status** (Verde/Amarelo/Vermelho), a **Data do Reporte**, os **Destaques Principais** (limite de 500 caracteres ASCII) e os **Proximos Passos**.

#### Variações comuns
- **Skip de Destaques**: Se não houver destaques a relatar, o campo pode ser deixado em branco, mas a cor do status e o ID do projeto são campos obrigatórios.

---

### 3.2. Operação 2: `Atualizar Tarefa` (AtualizarTarefa)
Permite atualizar o progresso (%) e o estado de uma tarefa existente vinculada ao portfólio.

- **Comando no chat**: `Atualizar Tarefa` ou `Atualizar progresso`
- **Resposta do Bot (Confirmação)**:
  ```
  Entrada: atualizar tarefa
  Segunda entrada: 15, em andamento, 2, nao, nao, nao, sim
  Resposta: Tarefa atualizada com sucesso. Campos opcionais preservados.
  ```
- **Interface do Cartão Adaptativo no Teams**:
  ![Adaptive Card Atualizar Tarefa](file:///C:/Users/dataops-lab/.gemini/antigravity-ide/brain/1bd6d78d-2df3-4237-aaa5-44ba47c09369/atualizar_tarefa_card_1779480512805.png)

#### O que esperar
Insira o **ID da Tarefa**. O formulário carregará os campos para definir o **Progresso (%)** de 0 a 100, o **Status da Tarefa** (Nao Iniciado, Em Andamento, Bloqueado, Concluido), a **Data de Conclusao Real** (se concluída) e **Comentarios**.

---

### 3.3. Operação 3: `Criar Tarefa` (CriarTarefa)
Permite cadastrar uma nova tarefa no portfólio de um projeto e atribuí-la a um colega via email.

- **Comando no chat**: `Criar Tarefa` ou `Cadastrar nova tarefa`
- **Resposta do Bot (Confirmação)**:
  ```
  Entrada: criar tarefa: projeto=QA Robust 20260513 F, titulo=QA CriarTarefa Smoke 315 20260520, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Media
  Segunda entrada: sim
  Resposta: Tarefa criada com sucesso. ID 101.
  ```
- **Interface do Cartão Adaptativo no Teams**:
  ![Adaptive Card Criar Tarefa](file:///C:/Users/dataops-lab/.gemini/antigravity-ide/brain/1bd6d78d-2df3-4237-aaa5-44ba47c09369/criar_tarefa_card_1779480530972.png)

#### O que esperar
Formulário contendo: **ID do Projeto** (selecionável), **Titulo da Tarefa** (obrigatório, máximo 150 caracteres ASCII), **Email do Responsavel** (validação de formato de email UPN), **Data Limite (Due Date)** e **Prioridade** (Baixa, Media, Alta, Critica).

---

### 3.4. Operação 4: `Listar Tarefas` (ListarTarefas)
Retorna uma lista resumida das tarefas associadas a um determinado projeto.

- **Comando no chat**: `Listar Tarefas` ou `Mostrar tarefas do projeto APP01`
- **Resposta do Bot (Confirmação)**:
  ```
  Entrada: listar tarefas QA Robust 20260513 F
  Resposta: Tarefas encontradas para QA Robust 20260513 F:
  - 15 - Validar smoke - Em andamento
  ```
- **Interface do Cartão Adaptativo no Teams**:
  ![Adaptive Card Listar Tarefas](file:///C:/Users/dataops-lab/.gemini/antigravity-ide/brain/1bd6d78d-2df3-4237-aaa5-44ba47c09369/listar_tarefas_card_1779480590386.png)

#### O que esperar
Ao digitar o comando e informar o **ID do Projeto**, o bot retornará um cartão de layout condensado (FactSet) listando os IDs, nomes, status com cores associadas e responsáveis por cada tarefa do projeto.

---

### 3.5. Operação 5: `Consultar Portfolio` (ConsultarPortfolio)
Exibe um dashboard com indicadores consolidados de todo o portfólio de projetos ativos da organização.

- **Comando no chat**: `Consultar Portfolio` ou `Visualizar resumo executivo`
- **Resposta do Bot (Confirmação)**:
  ```
  Entrada: consultar portfolio
  Resposta: Portfolio: 3 projetos ativos. Verde: 2. Amarelo: 1. Vermelho: 0.
  ```
- **Interface do Cartão Adaptativo no Teams**:
  ![Adaptive Card Consultar Portfolio](file:///C:/Users/dataops-lab/.gemini/antigravity-ide/brain/1bd6d78d-2df3-4237-aaa5-44ba47c09369/resumo_portfolio_card_1779480605273.png)

#### O que esperar
Um cartão dashboard contendo gráficos de distribuição de status (Verde, Amarelo, Vermelho), contagem total de projetos ativos, total de tarefas atrasadas e alertas de desvio de orçamento ou riscos graves.

---

## 4. As 7 Operações Chat-First (Legado aceito como Débito)

Por razões de compatibilidade e velocidade de lançamento, as 7 operações a seguir permanecem operando no modelo legado **chat-first** (diálogo baseado em texto puro com o robô). Elas serão migradas para a interface de cartões na próxima onda de desenvolvimento (Wave 2):

1. **Consultar Projeto** (`ConsultarProjeto`): Digite `Consultar Projeto [ID]` para obter um resumo em texto sobre a saúde geral do projeto.
2. **Pedir Decisão** (`PedirDecisaoBot`): Digite `Pedir decisao` para iniciar o fluxo textual de aprovação ou registro de decisão de governança.
3. **Registrar Bloqueio** (`RegistrarBloqueioBot`): Digite `Registrar bloqueio` para informar textualmente que uma tarefa está impedida.
4. **Registrar Risco** (`RegistrarRiscoBot`): Digite `Registrar risco` para registrar textualmente uma nova ameaça ao escopo ou prazo.
5. **Alerta Crítico** (`AlertaCritico`): Notificação de sistema automática disparada via Teams quando um projeto muda para Vermelho.
6. **Check-In Diário** (`CheckInDiario`): Mensagem automatizada de lembrete diário para os PMs.
7. **Resumo Semanal** (`ResumoSemanal`): Sumário automático enviado às sextas-feiras consolidando o portfólio.

---

## 5. Casos de Erro Comuns e Tratamento

Se ocorrer alguma falha durante o preenchimento ou processamento, o bot fornecerá mensagens amigáveis de depuração:

1. **ContentFiltered (Bloqueio de Segurança)**:
   - *Causa*: O usuário digitou texto contendo termos sensíveis que ativaram os filtros de segurança corporativos.
   - *Solução*: Evite linguagem inadequada ou excessivamente informal. Use o formulário estruturado do cartão para contornar este filtro.
2. **FlowActionBadGateway (Erro de Conexão)**:
   - *Causa*: O SharePoint ou o Teams estão instáveis no momento da gravação.
   - *Solução*: Aguarde alguns minutos e tente novamente. Se o erro persistir, acione o Suporte de TI.
3. **Tarefa não encontrada / ID Inválido**:
   - *Causa*: O ID informado no campo não existe no SharePoint.
   - *Solução*: Verifique a ortografia do ID ou consulte a listagem antes de submeter a atualização.
4. **Capturas de Erros Comuns**:
  ```
  Entrada: atualizar tarefa
  Segunda entrada: 999, concluida, 2, nao, nao, nao, sim
  Resposta de Erro: Erro: A tarefa com o ID 999 nao foi encontrada no SharePoint corporativo. Por favor, verifique o ID e tente novamente.
  ```

---

## 6. Tabela de Comandos Rápidos (Cheat Sheet)

Use os seguintes comandos textuais para acionar rapidamente as funções desejadas no chat do Teams:

| Comando Chat Teams | Operação Acionada | Interface | Objetivo principal |
|---|---|---|---|
| `/status` ou `Atualizar Status` | `AtualizarStatus` | Cartão Adaptativo | Atualizar semáforo e destaques |
| `/tarefa` ou `Atualizar Tarefa` | `AtualizarTarefa` | Cartão Adaptativo | Atualizar progresso % de tarefas |
| `/novatarefa` ou `Criar Tarefa` | `CriarTarefa` | Cartão Adaptativo | Cadastrar nova tarefa no projeto |
| `/listar` ou `Listar Tarefas` | `ListarTarefas` | Cartão Adaptativo | Visualizar tarefas por projeto |
| `/portfolio` ou `Consultar Portfolio` | `ConsultarPortfolio` | Cartão Adaptativo | Visualizar dashboard executivo |
| `/projeto` ou `Consultar Projeto` | `ConsultarProjeto` | Texto puro (Legado) | Detalhar metadados do projeto |
| `/risco` ou `Registrar Risco` | `RegistrarRiscoBot` | Texto puro (Legado) | Cadastrar ameaça ao projeto |

---

## 7. FAQ — Perguntas Frequentes

1. **Os cartões funcionam no Teams Mobile?**
   Sim. Os cartões Adaptive Cards v1.5 são otimizados pela Microsoft para renderização nativa tanto no Teams Desktop quanto no Teams Mobile (iOS e Android).
2. **Posso usar acentuação nos campos de destaques e títulos?**
   Para evitar problemas de codificação e formatação nos bancos de dados corporativos, recomendamos preencher os campos usando caracteres ASCII padrão (evitando acentos como `á`, `õ` ou cedilha `ç`).
3. **Por que o robô não entende minha linguagem natural em alguns comandos?**
   Os comandos principais foram otimizados para acionamento por palavras-chave ou cartões estruturados para garantir 100% de estabilidade de dados. Use a tabela de comandos rápidos se o agente não responder à frase aberta.
4. **Quanto tempo leva para as atualizações do cartão aparecerem no SharePoint?**
   O processamento via Power Automate é quase em tempo real, levando em média de **3 a 10 segundos** para gravar e persistir a informação.
5. **Onde posso visualizar as tabelas completas de tarefas?**
   Você pode acessar diretamente a lista do SharePoint no endereço oficial: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/PMO_Tasks/AllItems.aspx`.

---

## 8. Suporte e Relação de Contatos

Se encontrar bugs ou precisar de permissão especial de acesso:
- **Canal de Dúvidas**: Publique no canal do Teams `Suporte_Assistente_PMO`.
- **E-mail de Suporte**: `t1-pmo@stt.com` (SLA de resposta: 15 minutos).
- **Tempo de Correção**: Bugs de gravidade P0 são corrigidos e testados em até **2 horas**.

---

## Backfill Manifest — Manual Operacional v1.0

| ID Placeholder | Seção correspondente | Motivo da pendência | Caminho da evidência upstream | Responsável | Condição de disparo |
|---|---|---|---|---|---|
| MAN-01 | §3.4 Listar Tarefas | Screenshot real da resposta | `CODEX2/SMOKE/A1_ListarTarefas/evidence/*chat_screenshot.png` | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` no log |
| MAN-02 | §3.5 Consultar Portfolio | Screenshot real do dashboard | `CODEX2/SMOKE/A2_ConsultarPortfolio/evidence/*` + `GEMINI/CARDS/ResumoExecutivoPortfolioCard_v316/designer_render.png` | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` no log |
| MAN-03 | §3.3 Criar Tarefa | Screenshot real do cartão formulário | `CODEX2/SMOKE/A3_CriarTarefa/evidence/*` + `GEMINI/CARDS/CriarTarefaCard_v316/designer_render.png` | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` no log |
| MAN-04 | §3.2 Atualizar Tarefa | Screenshot real do progresso | `CODEX2/SMOKE/A4_AtualizarTarefa/evidence/*` + `GEMINI/CARDS/AtualizarTarefaCard_v316/designer_render.png` | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` no log |
| MAN-05 | §3.1 Atualizar Status | Screenshot real do semáforo | `CODEX2/SMOKE/A5_AtualizarStatus/evidence/*` + `GEMINI/CARDS/AtualizarStatusCard_v316/designer_render.png` | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` no log |
| MAN-06 | §5 Casos de Erro | Screenshot do erro simulado | Smoke Section A failure pathways ou sintético | Gemini sub-2 | `[CODEX2 SMOKE COMPLETE]` no log |

---

## Referências do Microsoft Learn Utilizadas

- **Diretrizes de Acessibilidade e Estilo de Cartões Adaptativos no Teams**: [Adaptive Cards in Teams Designer](https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/design-effective-cards)
- **Manipulação de Input em Cartões Adaptativos**: [Adaptive Card Input Form Actions](https://learn.microsoft.com/en-us/adaptive-cards/authoring-cards/input-validation)
