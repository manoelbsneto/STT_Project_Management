# Phase 6 — QA E2E Test Plan | PMO Intelligent Hub

## Objetivo
Validar 100% das funcionalidades antes de liberar para os 3 PMs piloto.

## Princípio de Alocação de Agentes

| Prioridade | Agente | Custo | Escopo |
|------------|--------|-------|--------|
| 🥇 Primário | **Codex** (+ até 3 sub-agents) | Baixo | Todos os testes automatizáveis via PowerShell/API/PnP |
| 🥈 Secundário | **Opus** (browser) | Alto | **Apenas testes críticos** que exigem interação browser real |

**Regra:** Opus browser-based é recurso caro — usar SOMENTE onde automação é impossível (card submission interativa, Copilot conversação real-time). Tudo que pode ser validado via API/script vai para Codex.

---

## Status Wave 1 — 2026-05-04 ✅ CONCLUÍDA

Execução automatizada concluída via `deploy/QA_Phase6_Automated.ps1` no ambiente `ColOfertasBrasilPro`.

- Resultado: **PASS=9; FAIL=0; CHECK=3; NOT_RUN=2**
- Evidência principal: `.planning/comms/G6_QA_WAVE1_RESULTS.md`
- JSON validado: `.planning/comms/g6_qa_wave1_20260504_083202.json`
- Inventário live ProcessSimple: `.planning/comms/g6_wave1_processsimple_flows_20260504_083202.json`
- Run history live: `.planning/comms/g6_wave1_processsimple_runs_20260504_083202.json`
- Observação: A1/A2/A5 ficaram como `CHECK` por modo evidencial baseado em G1/G5; A3/A4 ficaram `NOT_RUN` porque exigem `-RunSharePointPnP`, login interativo e criação/remoção de itens de teste no SharePoint.

---

## Tabela Master — 26 Testes por Agente

### 🤖 Wave 1: Codex Automated (PowerShell/API) — 14 testes

**Executor:** Codex Lead + até 3 Sub-Agents em paralelo
**Método:** PowerShell, ProcessSimple API, PnP, PAC CLI
**Status:** ✅ CONCLUÍDA (PASS=9, CHECK=3, NOT_RUN=2)

| # | ID | Teste | Sub-Agent | Método | Status Wave 1 |
|---|-----|-------|-----------|--------|---------------|
| 1 | A1 | Verificar 4 listas SP existem com campos corretos | Sub-1 (SP) | PnP `Get-PnPList` + `Get-PnPField` | CHECK (evidencial) |
| 2 | A2 | Verificar views SP existem | Sub-1 (SP) | PnP `Get-PnPView` | CHECK (evidencial) |
| 3 | A3 | Criar item teste via PnP em cada lista | Sub-1 (SP) | PnP `Add-PnPListItem` | NOT_RUN (requer -RunSharePointPnP) |
| 4 | A4 | Atualizar StatusRAG via PnP | Sub-1 (SP) | PnP `Set-PnPListItem` | NOT_RUN (requer A3) |
| 5 | A5 | Verificar indexação de colunas | Sub-1 (SP) | PnP `Get-PnPField` | CHECK (evidencial) |
| 6 | B1 | Verificar 10 flows existem e estado correto | Sub-2 (PA) | ProcessSimple API `GET /flows` | ✅ PASS |
| 7 | B2 | Verificar run-history flows recurrence | Sub-2 (PA) | ProcessSimple API `GET /flows/{id}/runs` | ✅ PASS |
| 8 | B3 | Verificar trigger types | Sub-2 (PA) | ProcessSimple API `GET /flows/{id}` | ✅ PASS |
| 9 | B4 | Verificar Standard connectors only | Sub-2 (PA) | Flow definition analysis | ✅ PASS |
| 10 | B5 | Validar 6 card JSON schemas | Sub-2 (PA) | JSON parse + size check | ✅ PASS |
| 11 | C1 | Verificar bot Published/Active/Provisioned | Sub-3 (CS) | PAC `pac copilot list` | ✅ PASS |
| 12 | C2 | Verificar segurança Copilot | Sub-3 (CS) | Dataverse FetchXML | ✅ PASS |
| 13 | C3 | Verificar language pt-BR | Sub-3 (CS) | Dataverse bot fetch | ✅ PASS |
| 14 | C4 | Verificar 3 action bindings ativos | Sub-3 (CS) | Dataverse workflow fetch | ✅ PASS |

**Sub-Agent Allocation:**
- **Sub-1 (SharePoint Specialist):** A1–A5 — PnP-based SharePoint validation
- **Sub-2 (Power Automate Expert):** B1–B5 — ProcessSimple API flow verification
- **Sub-3 (Copilot Studio Expert):** C1–C4 — PAC/Dataverse bot verification

---

### 🤖 Wave 2: Codex Browser-Light (Sub-Agent) — 6 testes

**Executor:** Codex Sub-Agent (browser automation via Gemini Flash ou script)
**Método:** Browser navigation simples — abrir URL, verificar conteúdo visual, screenshot
**Justificativa:** Testes D1–D2 e E1–E4 são navegação read-only ou form fill simples. NÃO exigem interação complexa com Adaptive Cards ou conversação AI. Podem ser executados por agente de menor custo.

| # | ID | Teste | Método | Critério de Aceite | Pré-Requisito |
|---|-----|-------|--------|-------------------|---------------|
| 15 | D1 | Cadastrar projeto novo via SP form | Abrir Projetos → + Novo → Preencher → Salvar | PRJ-QA1 aparece na lista com campos preenchidos | User logado SP |
| 16 | D2 | Cadastrar risco crítico via SP form | Abrir Riscos → + Novo → Severidade=Crítica → Salvar | Item criado; flow EscalarRisco dispara | D1 concluído |
| 17 | E1 | Verificar tab Portfolio_Executivo | Abrir Teams → clicar tab → verificar view | Board RAG view com dados agrupados por StatusRAG | User logado Teams |
| 18 | E2 | Verificar tab Projetos_Criticos | Clicar tab → verificar filtro | Apenas projetos StatusRAG=Vermelho visíveis | User logado Teams |
| 19 | E3 | Verificar tab Decisoes do Board | Clicar tab → verificar view | View Pendentes com filtro Status=Pendente | User logado Teams |
| 20 | E4 | Verificar cards no canal Conversa | Ir à aba Conversa → scrollar | Cards ResumoDiario e ResumoSemanal visíveis | User logado Teams |

**Dados de Teste (Wave 2):**
- ProjectID: `PRJ-QA1`
- NomeProjeto: `QA Browser Wave 2`
- StatusRAG inicial: `Amarelo`
- Percentual: `10`
- Risco: `QA Wave 2 - risco crítico de validação`
- Severidade: `Crítica`

---

### 🧠 Wave 3: Opus Browser-Critical (Orquestrador) — 6 testes

**Executor:** Opus 4.6 (browser direto, custo alto)
**Método:** Interação browser complexa — Adaptive Card submission, Copilot real-time conversation, multi-step E2E flows
**Justificativa:** Estes testes são **CRÍTICOS** e **IMPOSSÍVEIS de automatizar** — exigem:
1. **Adaptive Card interativa** com campos dinâmicos e submission real
2. **Copilot conversação real-time** com NLU, confirmação e escrita em SP
3. **E2E multi-step** onde um flow dispara, um card aparece, e uma ação humana confirma

| # | ID | Teste | Método | Critério de Aceite | Pré-Requisito |
|---|-----|-------|--------|-------------------|---------------|
| 21 | F1 | Responder Check-In Diário card | Encontrar card → selecionar projeto → preencher → Enviar | Resposta grava novo item em SP lista Status Diario | Card existente no canal |
| 22 | F2 | Responder Decisão Board card | Criar decisão SP → esperar card → clicar Aprovar | Status na lista Decisoes atualizado para "Aprovado" | D2 + flow disparou |
| 23 | F3 | Trigger CheckInOnDemand manual | Power Automate portal → Run flow → verificar Teams → responder | Card aparece no canal; resposta grava em Status Diário | Acesso PA portal |
| 24 | G1 | Copilot: Greeting + ConsultarPortfólio | Chat com Assistente PMO → "Olá" → "Como está o portfólio?" | Saudação pt-BR + distribuição RAG dos projetos | Bot instalado Teams |
| 25 | G2 | Copilot: ConsultarProjeto drill-down | "Como está o projeto PRJ-001?" | Nome, PM, StatusRAG, %, última atualização | G1 concluído |
| 26 | G3 | Copilot: RegistrarRisco Confirm-Before-Action | "Registrar risco crítico no PRJ-001: atraso fornecedor" → confirmar | Bot pede confirmação → após confirmar, item criado em SP Riscos | G2 concluído |

**Por que Opus e não Codex para F1–G3:**
- F1–F3: Adaptive Cards no Teams são renderizados como componentes interativos que requerem click real em dropdowns, input fields e botões — não existe API para "responder" um card programaticamente sem o Graph
- G1–G3: Copilot conversação no Teams é chat real-time com NLU — não existe endpoint programático para simular uma conversa com o bot publicado

---

## Resumo por Executor (Revisado)

| Executor | Testes | IDs | Custo Relativo |
|----------|--------|-----|----------------|
| 🤖 Codex Lead | 14 | A1–A5, B1–B5, C1–C4 | ⚡ Baixo |
| 🤖 Codex Sub-Agent (browser-light) | 6 | D1–D2, E1–E4 | ⚡ Baixo-Médio |
| 🧠 Opus Browser | 6 | F1–F3, G1–G3 | 💰 Alto |

**Total:** 20 testes Codex (77%) + 6 testes Opus (23%)

---

## Ordem de Execução (Waves Revisadas)

| Wave | Executor | Testes | Tempo Est. | Status | Depende de |
|------|----------|--------|-----------|--------|------------|
| 1 | 🤖 Codex (3 sub-agents paralelo) | A1–A5, B1–B5, C1–C4 | ✅ Concluída | ✅ DONE | PAC autenticado |
| 2 | 🤖 Codex Sub-Agent (browser-light) | D1–D2, E1–E4 | ~10 min | ⏳ PENDENTE | User logado browser |
| 3 | 🧠 Opus Browser | F1–F3, G1–G3 | ~20 min | ⏳ PENDENTE | Wave 2 concluída |
| 4 | 🤖 Codex | Consolidar G6_QA_RESULTS.md | ~5 min | ⏳ PENDENTE | Waves 1–3 concluídas |

---

## Perguntas Abertas (Aguardando Aprovação)

| # | Pergunta | Impacto |
|---|----------|---------|
| 1 | Assistente PMO já instalado no Teams para chat? | Testes G1–G3 dependem disso |
| 2 | Usar PRJ-001–005 existentes ou criar projetos QA separados? | Testes D1, A3, A4 |
| 3 | Acesso ao Power Automate portal para run manual? | Teste F3 depende disso |

---

## Flow IDs de Referência

| Flow | ID | Status |
|------|----|--------|
| PMO_PA_EnviarCheckInDiario | e117bbc5-5684-4191-8d03-fb183452ac5f | Started |
| PMO_PA_ProcessarRespostaCheckIn | 6c8ae320-46e0-42da-bc05-5d5a9622be03 | Stopped |
| PMO_PA_AlertaProjetoVermelho | 5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd | Started |
| PMO_PA_CheckInOnDemand | c9e51483-38e7-422a-98cd-cf7604d14a16 | Started |
| PMO_PA_AlertaSemAtualizacao | 0550c8ba-faf8-4e21-864e-d1fa5f625ce7 | Started |
| PMO_PA_ResumoDiarioBoard | Phase 3 | Started |
| PMO_PA_RegistrarDecisaoBoard | Phase 3 | Started |
| PMO_PA_SyncPlannerStats_Standard | Phase 3 | Started |
| PMO_PA_EscalarRiscoCritico | Phase 3 | Started |
| PMO_PA_ResumoSemanal | Phase 3 | Started |

---

## Endpoints de Referência

| Recurso | URL |
|---------|-----|
| SharePoint Site | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital` |
| Lista Projetos | `.../Lists/Projetos` |
| Teams Channel | Deep link em `.planning/.env` |
| Power Platform Env | `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`) |
