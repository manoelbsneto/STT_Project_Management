# PMO Intelligent Hub — Requirements

## V1 (MVP Standard-Only)

### P0 — Critical Path
- [x] REQ-01: Check-in Diário via Adaptive Card (9h → Teams → SP)
- [x] REQ-02: Copilot STT/Text — atualizar projeto por linguagem natural com Confirm-Before-Action
- [x] REQ-03: Portfólio Executivo — tab Teams com SP Board View agrupada por RAG
- [x] REQ-04: Alerta Vermelho — notificação automática para Sponsor quando projeto vira vermelho
- [x] REQ-05: On-Demand Update — atualização a qualquer momento (não só agendado)

### P1 — High Value
- [x] REQ-06: Decisão Board — card interativo para aprovar/rejeitar com DecisionID
- [x] REQ-07: Resumo Diário Board — card consolidado às 17h
- [x] REQ-08: Alerta Sem Update — lembrete para PMs que não atualizaram em 24h
- [x] REQ-09: Registro de Riscos — via Copilot ou card, escalação automática se crítico
- [x] REQ-10: Consulta por Voz/Texto — "como está o portfólio?" retorna dados formatados
- [x] REQ-11: Sync Planner Standard — contagem automática de tarefas via conector Planner Standard

### P0 — Phase 2.4 Contract Correction
- [ ] REQ-14: CriarProjeto — criar somente item em `Projetos`, com Adaptive Card como Plano A, texto/STT como Plano B, `ProjectID` gerado pelo sistema, duplicate guard e Confirm-Before-Action.
- [ ] REQ-15: CriarTarefa — criar somente item em `Tarefas`, vinculado a `ProjectID` existente/ativo/nao deletado em `Projetos`, sem qualquer escrita em `Projetos`.
- [ ] REQ-16: Gerar_Multiplos_Projetos — criar projetos em lote e tarefas iniciais por indice, com Adaptive Card de revisao/confirmacao como Plano A, parser multilinha/STT como Plano B, limite inicial de 10 projetos e 10 tarefas, e resultado por linha.

### P2 — Enhancement
- [x] REQ-12: Resumo Semanal — report expandido toda segunda 8h
- [x] REQ-13: Marcos e Entregas — tracking de atrasos em dias

## V2 (Future)
- Real-time Voice Agent (Teams Phone)
- Power BI integration (se licença aprovada)
- Planner Premium / Graph direto (se autorizado)
- Multi-org / multi-tenant
- Azure DevOps / Jira integration

## Out of Scope
- Todos conectores Premium
- Graph API direto / HTTP with Entra ID
- Dataverse
- Budget tracking automatizado
- Time tracking em horas
- Gantt charts interativos
