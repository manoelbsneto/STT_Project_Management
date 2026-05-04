# Phase 6 — QA E2E Test Plan | PMO Intelligent Hub

## Objetivo
Validar 100% das funcionalidades antes de liberar para os 3 PMs piloto.

---

## Status Wave 1 — 2026-05-04

Execução automatizada concluída via `deploy/QA_Phase6_Automated.ps1` no ambiente `ColOfertasBrasilPro`.

- Resultado: **PASS=9; FAIL=0; CHECK=3; NOT_RUN=2**
- Evidência principal: `.planning/comms/G6_QA_WAVE1_RESULTS.md`
- JSON validado: `.planning/comms/g6_qa_wave1_20260504_083202.json`
- Inventário live ProcessSimple: `.planning/comms/g6_wave1_processsimple_flows_20260504_083202.json`
- Run history live: `.planning/comms/g6_wave1_processsimple_runs_20260504_083202.json`
- Observação: A1/A2/A5 ficaram como `CHECK` por modo evidencial baseado em G1/G5; A3/A4 ficaram `NOT_RUN` porque exigem `-RunSharePointPnP`, login interativo e criação/remoção de itens de teste no SharePoint.
- Próxima execução: Wave 2 manual/browser (D1-D2, E1-E4) usando `.planning/CODEX_PROMPT_QA_WAVE2_BROWSER.md`.

---

## Tabela Master — Todos os 26 Testes em Ordem Lógica

| # | ID | Teste | Executor | Método | Critério de Aceite | Pré-Requisito |
|---|-----|-------|----------|--------|-------------------|---------------|
| 1 | A1 | Verificar 4 listas SP existem com campos corretos | Codex (PowerShell) | PnP `Get-PnPList` + `Get-PnPField` | Projetos(22), StatusDiario(13), Riscos(13), Decisoes(14) | PnP conectado |
| 2 | A2 | Verificar views SP existem | Codex (PowerShell) | PnP `Get-PnPView` | Board RAG, Gallery, Todos, PorProjeto, Abertos, Pendentes, Críticos | PnP conectado |
| 3 | A3 | Criar item teste via PnP em cada lista | Codex (PowerShell) | PnP `Add-PnPListItem` | Item criado com sucesso, retorna ID | PnP conectado |
| 4 | A4 | Atualizar StatusRAG via PnP | Codex (PowerShell) | PnP `Set-PnPListItem` | StatusRAG muda Verde→Vermelho | A3 concluído |
| 5 | A5 | Verificar indexação de colunas | Codex (PowerShell) | PnP `Get-PnPField` | StatusRAG, ProjectID, DataRegistro indexados | PnP conectado |
| 6 | B1 | Verificar 10 flows existem e estado correto | Codex (PowerShell) | ProcessSimple API `GET /flows` | 9 Started + 1 Stopped | PAC autenticado |
| 7 | B2 | Verificar run-history flows recurrence | Codex (PowerShell) | ProcessSimple API `GET /flows/{id}/runs` | CheckIn, ResumoDiario, ResumoSemanal têm runs recentes | PAC autenticado |
| 8 | B3 | Verificar trigger types | Codex (PowerShell) | ProcessSimple API `GET /flows/{id}` | Recurrence=Recurrence, Event=When_item_created | PAC autenticado |
| 9 | B4 | Verificar Standard connectors only | Codex (PowerShell) | Flow definition check | Todos usam SP/Teams/Outlook/Planner (Standard) | PAC autenticado |
| 10 | B5 | Validar 6 card JSON schemas | Codex (PowerShell) | JSON parse + size check | 6 cards < 27KB, schema v1.4, JSON válido | Arquivos locais |
| 11 | C1 | Verificar bot Published/Active/Provisioned | Codex (PowerShell) | PAC `pac copilot list` | `Assistente PMO` Published/Active/Provisioned | PAC autenticado |
| 12 | C2 | Verificar segurança Copilot | Codex (PowerShell) | Dataverse FetchXML | GPT/web/file analysis desabilitados | PAC autenticado |
| 13 | C3 | Verificar language pt-BR | Codex (PowerShell) | Dataverse bot fetch | Language = Português (Brasil) | PAC autenticado |
| 14 | C4 | Verificar 3 action bindings ativos | Codex (PowerShell) | Dataverse workflow fetch | CheckInOnDemand, EscalarRisco, RegistrarDecisao | PAC autenticado |
| 15 | D1 | Cadastrar projeto novo via SP form | Browser (Flash) | Abrir Projetos → + Novo → Preencher → Salvar | PRJ-QA1 aparece na lista com todos campos | User logado SP |
| 16 | D2 | Cadastrar risco crítico via SP form | Browser (Flash) | Abrir Riscos → + Novo → Severidade=Crítica → Salvar | Item criado; flow EscalarRisco dispara | D1 concluído |
| 17 | E1 | Verificar tab Portfolio_Executivo | Browser (Flash) | Abrir Teams → clicar tab → verificar view | Board RAG view com dados agrupados por StatusRAG | User logado Teams |
| 18 | E2 | Verificar tab Projetos_Criticos | Browser (Flash) | Clicar tab → verificar filtro | Apenas projetos StatusRAG=Vermelho visíveis | User logado Teams |
| 19 | E3 | Verificar tab Decisoes do Board | Browser (Flash) | Clicar tab → verificar view | View Pendentes ativa com filtro Status=Pendente | User logado Teams |
| 20 | E4 | Verificar cards no canal Conversa | Browser (Flash) | Ir à aba Conversa → scrollar | Cards ResumoDiario e ResumoSemanal visíveis | User logado Teams |
| 21 | F1 | Responder Check-In Diário card | Browser (Opus) | Encontrar card → selecionar projeto → preencher → Enviar | Resposta grava novo item em SP lista Status Diario | Card existente no canal |
| 22 | F2 | Responder Decisão Board card | Browser (Opus) | Criar decisão SP → esperar card → clicar Aprovar | Status na lista Decisoes atualizado para "Aprovado" | D2 + flow disparou |
| 23 | F3 | Trigger CheckInOnDemand manual | Browser (Opus) | Power Automate portal → Run flow → verificar Teams → responder | Card aparece no canal; resposta grava em Status Diário | Acesso PA portal |
| 24 | G1 | Copilot: Greeting + ConsultarPortfólio | Browser (Opus) | Chat com Assistente PMO → "Olá" → "Como está o portfólio?" | Saudação pt-BR + distribuição RAG dos projetos | Bot instalado Teams |
| 25 | G2 | Copilot: ConsultarProjeto drill-down | Browser (Opus) | "Como está o projeto PRJ-001?" | Nome, PM, StatusRAG, %, última atualização | G1 concluído |
| 26 | G3 | Copilot: RegistrarRisco Confirm-Before-Action | Browser (Opus) | "Registrar risco crítico no PRJ-001: atraso fornecedor" → confirmar | Bot pede confirmação → após confirmar, item criado em SP Riscos | G2 concluído |

---

## Resumo por Executor

| Executor | Testes | IDs |
|----------|--------|-----|
| 🤖 Codex (PowerShell/API) | 14 | A1–A5, B1–B5, C1–C4 |
| 🌐 Browser Gemini Flash | 6 | D1–D2, E1–E4 |
| 🌐 Browser Opus 4.7 | 6 | F1–F3, G1–G3 |

---

## Ordem de Execução (Waves)

| Wave | Executor | Testes | Tempo Est. | Depende de |
|------|----------|--------|-----------|------------|
| 1 | Codex PowerShell/API | A1–A5, B1–B5, C1–C4 | Concluída em modo evidencial/live híbrido | PAC autenticado; PnP live não executado |
| 2 | Browser Flash | D1–D2, E1–E4 | ~10 min | User logado browser |
| 3 | Browser Opus | F1–F3, G1–G3 | ~20 min | Wave 2 concluída |
| 4 | Report | Consolidar G6_QA_RESULTS.md | ~5 min | Waves 1–3 concluídas |

---

## Perguntas Abertas (Aguardando Aprovação)

| # | Pergunta | Impacto |
|---|----------|---------|
| 1 | Flash=6 simples + Opus=6 complexos ou tudo Opus? | Alocação de agente browser |
| 2 | Assistente PMO já instalado no Teams para chat? | Testes G1–G3 dependem disso |
| 3 | Usar PRJ-001–005 ou criar projetos QA separados? | Testes D1, A3, A4 |
| 4 | Acesso ao Power Automate portal para run manual? | Teste F3 depende disso |

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
