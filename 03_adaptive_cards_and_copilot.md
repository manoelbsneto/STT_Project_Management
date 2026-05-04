# Adaptive Cards e Agente Copilot Studio

## 1. Adaptive Cards

### 1.1 Card de Check-in Diário do Projeto

Card enviado diariamente pelo Power Automate para cada PM. Permite atualizar status em <20 segundos.

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "ColumnSet",
      "columns": [
        {
          "type": "Column",
          "width": "auto",
          "items": [
            {
              "type": "Image",
              "url": "https://img.icons8.com/fluency/48/project-management.png",
              "size": "Small"
            }
          ]
        },
        {
          "type": "Column",
          "width": "stretch",
          "items": [
            {
              "type": "TextBlock",
              "text": "📊 Check-in Diário",
              "weight": "Bolder",
              "size": "Medium"
            },
            {
              "type": "TextBlock",
              "text": "${ProjectName} — ${Area}",
              "spacing": "None",
              "isSubtle": true
            }
          ]
        }
      ]
    },
    {
      "type": "TextBlock",
      "text": "Status anterior: ${PreviousRAG} | Última atualização: ${LastUpdate}",
      "isSubtle": true,
      "size": "Small",
      "separator": true
    },
    {
      "type": "Input.ChoiceSet",
      "id": "statusRAG",
      "label": "Status RAG atual",
      "style": "expanded",
      "isRequired": true,
      "choices": [
        { "title": "🟢 Verde — No prazo", "value": "Verde" },
        { "title": "🟡 Amarelo — Atenção", "value": "Amarelo" },
        { "title": "🔴 Vermelho — Crítico", "value": "Vermelho" }
      ],
      "value": "${PreviousRAGValue}"
    },
    {
      "type": "Input.Text",
      "id": "resumo",
      "label": "Resumo do progresso (1-2 frases)",
      "isMultiline": true,
      "isRequired": true,
      "placeholder": "O que avançou desde a última atualização?",
      "maxLength": 500
    },
    {
      "type": "Input.Text",
      "id": "risco",
      "label": "Risco principal (se houver)",
      "isMultiline": false,
      "placeholder": "Descreva o risco brevemente",
      "maxLength": 300
    },
    {
      "type": "Input.Text",
      "id": "bloqueio",
      "label": "Bloqueio (se houver)",
      "isMultiline": false,
      "placeholder": "O que está impedindo o progresso?",
      "maxLength": 300
    },
    {
      "type": "Input.Text",
      "id": "proximaAcao",
      "label": "Próxima ação",
      "isMultiline": false,
      "isRequired": true,
      "placeholder": "Qual o próximo passo?",
      "maxLength": 300
    },
    {
      "type": "Input.ChoiceSet",
      "id": "decisaoNecessaria",
      "label": "Precisa de decisão do Board?",
      "style": "compact",
      "choices": [
        { "title": "Não", "value": "Nao" },
        { "title": "Sim — descrever abaixo", "value": "Sim" }
      ],
      "value": "Nao"
    },
    {
      "type": "Input.Text",
      "id": "decisaoDescricao",
      "label": "Qual decisão é necessária?",
      "isMultiline": false,
      "placeholder": "Descreva a decisão que o board precisa tomar",
      "maxLength": 500
    },
    {
      "type": "Input.Number",
      "id": "percentual",
      "label": "% de avanço geral",
      "min": 0,
      "max": 100,
      "value": "${PreviousPercentual}"
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "✅ Enviar Atualização",
      "data": {
        "action": "submitCheckin",
        "projectId": "${ProjectID}"
      },
      "style": "positive"
    },
    {
      "type": "Action.Submit",
      "title": "⏭️ Sem mudanças hoje",
      "data": {
        "action": "noChange",
        "projectId": "${ProjectID}"
      }
    }
  ]
}
```

**Notas de implementação:**
- `${...}` são placeholders substituídos pelo Power Automate com dados da lista Projetos
- O botão "Sem mudanças hoje" registra que o PM viu o card mas nada mudou — evita projetos "sem atualização" quando realmente nada mudou
- Após submit, o card deve ser atualizado para mostrar "✅ Registrado às HH:MM"

---

### 1.2 Card de Projeto Crítico / Vermelho

Card enviado automaticamente quando um projeto muda para status 🔴. Postado no canal "🔴 Projetos Críticos".

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "Container",
      "style": "attention",
      "bleed": true,
      "items": [
        {
          "type": "TextBlock",
          "text": "🔴 ALERTA: Projeto Crítico",
          "weight": "Bolder",
          "size": "Large",
          "color": "Attention"
        }
      ]
    },
    {
      "type": "FactSet",
      "facts": [
        { "title": "Projeto:", "value": "${ProjectName}" },
        { "title": "Área:", "value": "${Area}" },
        { "title": "PM:", "value": "${PMName}" },
        { "title": "Sponsor:", "value": "${SponsorName}" },
        { "title": "Status anterior:", "value": "${PreviousRAG}" },
        { "title": "Status atual:", "value": "🔴 Vermelho" },
        { "title": "Data alvo:", "value": "${DataAlvo}" },
        { "title": "Avanço:", "value": "${Percentual}%" }
      ]
    },
    {
      "type": "TextBlock",
      "text": "Resumo da Situação",
      "weight": "Bolder",
      "separator": true
    },
    {
      "type": "TextBlock",
      "text": "${Resumo}",
      "wrap": true
    },
    {
      "type": "TextBlock",
      "text": "⚠️ Risco Principal",
      "weight": "Bolder",
      "color": "Warning",
      "separator": true
    },
    {
      "type": "TextBlock",
      "text": "${RiscoPrincipal}",
      "wrap": true
    },
    {
      "type": "TextBlock",
      "text": "🚫 Bloqueio",
      "weight": "Bolder",
      "color": "Attention",
      "separator": true
    },
    {
      "type": "TextBlock",
      "text": "${Bloqueio}",
      "wrap": true
    },
    {
      "type": "TextBlock",
      "text": "➡️ Próxima Ação: ${ProximaAcao}",
      "weight": "Bolder",
      "separator": true,
      "wrap": true
    },
    {
      "type": "TextBlock",
      "text": "Atualizado por ${AtualizadoPor} em ${DataStatus}",
      "isSubtle": true,
      "size": "Small",
      "separator": true
    }
  ],
  "actions": [
    {
      "type": "Action.OpenUrl",
      "title": "📊 Ver no SharePoint",
      "url": "${SharePointItemUrl}"
    },
    {
      "type": "Action.OpenUrl",
      "title": "📌 Ver Planner",
      "url": "${PlannerUrl}"
    },
    {
      "type": "Action.Submit",
      "title": "📋 Agendar Reunião de Crise",
      "data": {
        "action": "scheduleCrisis",
        "projectId": "${ProjectID}"
      }
    }
  ]
}
```

---

### 1.3 Card de Decisão Pendente do Board

Card enviado no canal "📋 Decisões Pendentes" quando uma decisão é registrada.

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.4",
  "body": [
    {
      "type": "ColumnSet",
      "columns": [
        {
          "type": "Column",
          "width": "auto",
          "items": [
            {
              "type": "TextBlock",
              "text": "📋",
              "size": "ExtraLarge"
            }
          ]
        },
        {
          "type": "Column",
          "width": "stretch",
          "items": [
            {
              "type": "TextBlock",
              "text": "Decisão Pendente do Board",
              "weight": "Bolder",
              "size": "Medium"
            },
            {
              "type": "TextBlock",
              "text": "Projeto: ${ProjectName}",
              "isSubtle": true,
              "spacing": "None"
            }
          ]
        }
      ]
    },
    {
      "type": "FactSet",
      "separator": true,
      "facts": [
        { "title": "Impacto:", "value": "${Impacto}" },
        { "title": "Sponsor:", "value": "${SponsorName}" },
        { "title": "Prazo:", "value": "${PrazoDecisao}" },
        { "title": "Dias restantes:", "value": "${DiasRestantes}" }
      ]
    },
    {
      "type": "TextBlock",
      "text": "Descrição da Decisão",
      "weight": "Bolder",
      "separator": true
    },
    {
      "type": "TextBlock",
      "text": "${DescricaoDecisao}",
      "wrap": true
    },
    {
      "type": "TextBlock",
      "text": "Contexto",
      "weight": "Bolder",
      "separator": true
    },
    {
      "type": "TextBlock",
      "text": "${Contexto}",
      "wrap": true
    },
    {
      "type": "Input.ChoiceSet",
      "id": "decisao",
      "label": "Sua decisão:",
      "style": "expanded",
      "choices": [
        { "title": "✅ Aprovado", "value": "Aprovada" },
        { "title": "❌ Rejeitado", "value": "Rejeitada" },
        { "title": "⏸️ Adiar", "value": "Adiada" },
        { "title": "💬 Preciso de mais informações", "value": "MaisInfo" }
      ]
    },
    {
      "type": "Input.Text",
      "id": "comentario",
      "label": "Comentário (opcional)",
      "isMultiline": true,
      "placeholder": "Justificativa ou observações",
      "maxLength": 500
    }
  ],
  "actions": [
    {
      "type": "Action.Submit",
      "title": "📤 Registrar Decisão",
      "data": {
        "action": "submitDecision",
        "decisionId": "${DecisionID}",
        "projectId": "${ProjectID}"
      },
      "style": "positive"
    }
  ]
}
```

---

## 2. Desenho do Agente Copilot Studio (Fase 2)

### 2.1 Visão Geral

| Atributo | Valor |
|---|---|
| **Nome** | PMO Assistant |
| **Canal** | Microsoft Teams (chat 1:1 e canal) |
| **Idioma** | Português do Brasil |
| **Backend** | Power Automate (standard connectors → SharePoint) |
| **Autenticação** | SSO Microsoft 365 (usuário autenticado) |

### 2.2 Tópicos / Intents

| # | Tópico | Descrição | Prioridade |
|---|---|---|:---:|
| 1 | **Atualizar Status** | Atualizar status RAG + resumo de um projeto | P0 |
| 2 | **Consultar Status** | Ver status atual de um projeto específico | P0 |
| 3 | **Listar Projetos** | Ver todos os projetos do usuário ou de uma área | P0 |
| 4 | **Ver Bloqueios** | Listar bloqueios ativos | P1 |
| 5 | **Projetos Sem Update** | Listar projetos sem atualização >24h | P1 |
| 6 | **Resumo Diário** | Gerar briefing do dia | P1 |
| 7 | **Registrar Risco** | Criar novo risco em um projeto | P2 |
| 8 | **Registrar Decisão** | Criar item na lista de Decisões | P2 |
| 9 | **Briefing Executivo** | Resumo para board/sponsor | P2 |

### 2.3 Frases de Exemplo por Tópico

**Atualizar Status:**
- "Atualiza o projeto Mobile para amarelo"
- "O projeto CRM está verde, avançamos na integração com SAP"
- "Coloca o DataPlatform em vermelho, bloqueado por infra"
- "Update: Mobile App — amarelo — risco de atraso na publicação da loja"
- "Status do projeto ERP: vermelho. Bloqueio é falta de ambiente de homologação"

**Consultar Status:**
- "Como está o projeto Mobile?"
- "Qual o status do CRM?"
- "Me mostra o último update do DataPlatform"

**Listar Projetos:**
- "Quais são meus projetos?"
- "Lista os projetos da área de TI"
- "Quais projetos estão vermelhos?"

**Projetos Sem Update:**
- "Quais projetos estão sem atualização?"
- "Tem algum projeto parado?"

### 2.4 Entidades a Extrair

| Entidade | Tipo | Exemplo | Fonte |
|---|---|---|---|
| **NomeProjeto** | Custom (lista dinâmica) | "Mobile", "CRM", "DataPlatform" | Lookup na lista Projetos |
| **StatusRAG** | Closed list | "verde", "amarelo", "vermelho" | Fixo |
| **Resumo** | Free text | "avançamos na integração" | Extração de texto |
| **Risco** | Free text | "atraso na publicação da loja" | Extração após keywords |
| **Bloqueio** | Free text | "falta de ambiente" | Extração após keywords |
| **ProximaAcao** | Free text | "validar com jurídico" | Extração após keywords |
| **Prazo** | Date/time | "amanhã", "sexta", "15/05" | Built-in date entity |

### 2.5 Regras de Confirmação

> [!IMPORTANT]
> **NUNCA atualizar sem confirmação explícita do usuário.**

Fluxo padrão:
1. Usuário envia mensagem
2. Agente extrai entidades
3. Agente apresenta card de confirmação:

```
Vou registrar a seguinte atualização:

📊 Projeto: Mobile App
🟡 Status: Amarelo
📝 Resumo: Avançamos na integração com a loja
⚠️ Risco: Atraso na publicação da loja
➡️ Próxima ação: Validar com jurídico até amanhã
👤 Atualizado por: João Silva

Confirma? [Sim] [Não] [Editar]
```

### 2.6 Regras para Ambiguidade

| Cenário | Tratamento |
|---|---|
| Nome do projeto não encontrado | "Encontrei projetos similares: Mobile App, Mobile Portal. Qual?" |
| Múltiplos projetos com nome similar | Listar opções com IDs |
| Status não informado | "Qual o status RAG? 🟢 Verde, 🟡 Amarelo ou 🔴 Vermelho?" |
| Mensagem muito vaga | "Pode detalhar? Preciso pelo menos do projeto e status." |
| Confiança baixa na extração | Marcar ConfiancaIA = "Baixa" e pedir confirmação mais explícita |

### 2.7 Regras para Atualização com Baixa Confiança

Se a confiança do NLU for < 70%:
1. **NÃO gravar automaticamente**
2. Apresentar o que entendeu com marcação visual de baixa confiança
3. Pedir confirmação explícita campo a campo
4. Se confirmado, gravar com ConfiancaIA = "Baixa" no SharePoint

### 2.8 Fluxos Power Automate Acionados

| Tópico | Flow PA | Ação |
|---|---|---|
| Atualizar Status | PMO_PA_AtualizarViaCopilot | Create Item (Status Diário) + Update Item (Projetos) |
| Consultar Status | PMO_PA_ConsultarStatus | Get Items (Projetos, filtro: Title = NomeProjeto) |
| Listar Projetos | PMO_PA_ListarProjetos | Get Items (Projetos, filtro: PM = currentUser ou Area = X) |
| Projetos Sem Update | PMO_PA_ProjetosSemUpdate | Get Items (Projetos, filtro: DiasSemUpdate >= 1) |
| Registrar Risco | PMO_PA_RegistrarRisco | Create Item (Riscos e Bloqueios) |
| Registrar Decisão | PMO_PA_RegistrarDecisao | Create Item (Decisões do Board) |

### 2.9 Exemplos de Conversas

**Conversa 1 — Atualização completa:**
```
👤 "Atualiza o projeto Mobile para amarelo. O risco é atraso na publicação da loja. 
    Próxima ação é validar com jurídico até amanhã."

🤖 "Entendi! Vou registrar:
    📊 Projeto: Mobile App (PRJ-012)
    🟡 Status: Amarelo
    📝 Resumo: (não informado — deseja adicionar?)
    ⚠️ Risco: Atraso na publicação da loja
    ➡️ Próxima ação: Validar com jurídico (prazo: amanhã, 02/05)
    👤 Atualizado por: João Silva
    
    Confirma? [Sim] [Não] [Editar]"

👤 "Sim"

🤖 "✅ Atualização registrada às 09:15!
    O projeto Mobile App agora está 🟡 Amarelo.
    Risco registrado na lista de Riscos e Bloqueios."
```

**Conversa 2 — Consulta rápida:**
```
👤 "Como está o CRM?"

🤖 "📊 Projeto CRM (PRJ-005)
    🟢 Status: Verde
    📅 Última atualização: ontem, 14:30
    👤 Por: Maria Santos
    📝 Resumo: Sprint 8 finalizada, integração SAP validada
    ➡️ Próxima ação: Iniciar testes de UAT
    📅 Data alvo: 15/06/2026
    📈 Avanço: 65%"
```

**Conversa 3 — Ambiguidade:**
```
👤 "Atualiza Mobile"

🤖 "Encontrei 2 projetos com 'Mobile':
    1. Mobile App (PRJ-012) — 🟡 Amarelo
    2. Mobile Portal (PRJ-018) — 🟢 Verde
    
    Qual deles?"

👤 "O primeiro"

🤖 "Ok, Mobile App. Qual o status RAG? 🟢🟡🔴"

👤 "Vermelho, bloqueado por infra"

🤖 "Vou registrar:
    📊 Projeto: Mobile App (PRJ-012)
    🔴 Status: Vermelho
    🚫 Bloqueio: Bloqueado por infra
    
    ⚠️ Este projeto será escalado automaticamente ao canal de Projetos Críticos.
    
    Confirma? [Sim] [Não]"

👤 "Sim"

🤖 "✅ Registrado! Alerta de projeto crítico enviado ao canal 🔴 Projetos Críticos."
```
