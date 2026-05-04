# [NOME DO PROJETO] - Product Requirements Document (PRD)

## 1. Visão Geral
**Status:** [Ideia / Discovery / MVP / Produção]
**Data da Revisão:** [DD/MM/AAAA]
**Product Manager / Owner:** [Nome]

---

## 2. Contexto de Negócio
### 2.1. O Problema (Problem Statement)
[Descreva o problema raiz que motivou este projeto. Por que precisamos construir isso agora?]

### 2.2. Processo Atual (AS-IS)
[Como as coisas funcionam hoje? Qual é o fluxo, as dores e ineficiências?]

### 2.3. Processo Futuro (TO-BE)
[Como o mundo vai parecer após a nossa solução? Qual é o novo fluxo de valor?]

### 2.4. Impacto Esperado (Business Impact)
[Quais os KPIs que serão impactados? (ex: redução de custo, tempo de operação, conversão, ARR)]

---

## 3. Escopo e Fronteiras
### 3.1. In-Scope (No Escopo)
- [Funcionalidade, Integração, Módulo 1]
- [Funcionalidade, Integração, Módulo 2]
- [Regras de Negócio específicas]

### 3.2. Out-of-Scope (Fora do Escopo)
- [Geralmente o que os stakeholders podem confundir que seria feito, MAS NÃO SERÁ]
- [O que foi postergado para v2]

---

## 4. Personas e Permissões (RBAC)
### 4.1. [Nome da Persona 1 - Ex: Admin]
- **Objetivo:** [O que ele precisa resolver na ferramenta]
- **Permissões:** [Leitura completa, Edição de X, Exclusão de Y]

### 4.2. [Nome da Persona 2 - Ex: Operador]
- **Objetivo:** [O que ele precisa resolver na ferramenta]
- **Permissões:** [Somente leitura em X, pode criar Y]

---

## 5. Requisitos Funcionais e Épicos
| ID | Épico / Funcionalidade | Descrição / User Story | Prioridade | Critérios de Aceite (AoD) |
|---|---|---|---|---|
| REQ-01 | [Módulo] | Como [Persona], eu quero [Ação] para [Motivo] | [P0/P1/P2] | - [Condição 1]<br>- [Condição 2] |
| REQ-02 | [Módulo] | [Ação esperada do sistema ao ocorrer evento X] | [P0/P1/P2] | - [Condição 1]<br>- [Condição 2] |
| REQ-03 | [Módulo] | [Descrição] | [P0/P1/P2] | - [Condição 1]<br>- [Condição 2] |

---

## 6. Requisitos Não-Funcionais (NFRs)
### 6.1. UI/UX e Frontend
- **Design System / Estilo:** [Descrição da identidade visual esperada, densidade]
- **Dispositivos:** [Mobile-first, Desktop only?]

### 6.2. Performance
- **Tempos de Resposta:** [ex: < 200ms para queries críticas]
- **Volumetria / Scale:** [ex: X usuários simultâneos, Y milhões de registros/mês]

### 6.3. Segurança e Infraestrutura
- **Autenticação:** [SSO (SAML, OIDC), E-mail/Senha, Active Directory]
- **LGPD/GDPR:** [Campos sensíveis que necessitam de ofuscação/criptografia]

---

## 7. Arquitetura e Stack
### 7.1. Desenho Macro
- **Frontend App:** [Tecnologia, framework]
- **Backend / APIs:** [Tecnologia, framework, tipo de API (REST/GraphQL)]
- **Persistência / Banco:** [Relacional, NoSQL]

### 7.2. Pontos de Integração e APIs Externas
- [Sistema A] - [Endpoint / Job batido] - [Sentido: Inbound/Outbound]
- [Sistema B] - [Endpoint / Job batido] - [Sentido: Inbound/Outbound]

---

## 8. Agentes de IA / LLM (Opcional)
- **Agente Principal:** [Modelo utilizado (ex: Gemini 1.5, Claude 3.5)]
- **Grau de Autonomia (Strictness):** [Até onde a IA pode agir sem aprovação humana]
- **Casos de Uso (Prompts Base):**
  - [Caso de Uso 1: O que a IA fará? Ex: Extrair dados de faturas]

---

## 9. Plano de Lançamento (Roadmap)
- **Fase 1 (Alpha):** [Objetivos e Escopo Restrito]
- **Fase 2 (Beta / MVP Público):** [Go-live focado nos Core Features]
- **Fase 3 (v1.0):** [Adição das funcionalidades P2 e refinamentos]

---
*Este é um template mestre ("Esqueleto") 100% puro. Adapte os tópicos conforme a necessidade do projeto.*
