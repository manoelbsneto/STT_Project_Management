# CODEX PROMPT — Phase 6 QA Wave 1: Automated Tests

Leia o plano de QA em `.planning/QA_PHASE6_PLAN.md` e execute os **14 testes automatizados** (A1–A5, B1–B5, C1–C4) usando 3 subagentes em paralelo.

## Contexto
- **Projeto:** PMO Intelligent Hub
- **Ambiente Power Platform:** `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- **SharePoint Site:** `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
- **PnP Auth:** Windows PowerShell 5.1 + `SharePointPnPPowerShellOnline 3.29.2101.0` + `Connect-PnPOnline -Url "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital" -UseWebLogin`
- **PAC Auth:** Já autenticado via `pac auth` em `ColOfertasBrasilPro` (user: `mbenicios@minsait.com`)
- **Listas SP:** Projetos, Status Diário, Riscos e Bloqueios, Decisões do Board
- **Flow IDs conhecidos (Phase 2):** ver tabela "Flow IDs de Referência" no QA plan

## Subagente 1 — SharePoint Data Integrity (A1–A5)
Executar no Windows PowerShell 5.1 (não pwsh):
1. **A1:** `Get-PnPList` para confirmar 4 listas existem. Para cada lista, `Get-PnPField -List <nome>` e contar campos.
2. **A2:** `Get-PnPView -List "Projetos"` e verificar que existem views: "Board RAG", "Projetos Críticos". Repetir para outras listas.
3. **A3:** `Add-PnPListItem` com dados de teste em cada lista (usar ProjectID="PRJ-QA-TEST", marcar como Ativo=Não para não poluir). Guardar IDs retornados.
4. **A4:** `Set-PnPListItem` no item criado em A3 para mudar StatusRAG de "Verde" para "Vermelho". Verificar com `Get-PnPListItem`.
5. **A5:** Para cada campo crítico (StatusRAG, ProjectID, DataRegistro), verificar se `Indexed` = True via `Get-PnPField`.

Após completar, remover itens de teste criados em A3 com `Remove-PnPListItem`.

## Subagente 2 — Power Automate Flow Health (B1–B5)
1. **B1:** Listar todos os flows com nome `PMO_PA_*` no ambiente. Usar `pac org fetch` com FetchXML query no arquivo `.planning/comms/fetch_flows.xml` (já existe). Se retornar poucos resultados, tentar sem filtro de category. Devem existir 10 flows, 9 Started e 1 Stopped (ProcessarRespostaCheckIn).
2. **B2:** Para os flows de Recurrence (EnviarCheckInDiario, ResumoDiarioBoard, ResumoSemanal), verificar se têm runs nos últimos 3 dias. Usar portal Power Automate via URL ou ProcessSimple API se disponível.
3. **B3:** Verificar nos flow definitions exportados em `.planning/comms/flow_definition_*` e `.planning/comms/flow_summary_*` que os trigger types estão corretos.
4. **B4:** Verificar nos mesmos arquivos que todos os connectors são Standard (SharePoint, Teams, Outlook, Planner). Nenhum Premium.
5. **B5:** Validar os 6 arquivos JSON em `deploy/cards/`: parse JSON, verificar `version` = "1.4", verificar tamanho < 27KB.

## Subagente 3 — Copilot Studio Config (C1–C4)
1. **C1:** `pac copilot list` — confirmar "Assistente PMO" com status Published/Active/Provisioned.
2. **C2:** Fazer FetchXML query na entity `bot` filtrando por botid=`0c4a9729-d55d-483c-8ec3-db9369583155`. Verificar campos de configuração de segurança (GenerativeActions, useModelKnowledge, etc). Usar `pac org fetch --xmlFile <arquivo>`.
3. **C3:** No mesmo resultado de C2, verificar campo `language` = pt-BR ou código 1046.
4. **C4:** Fazer FetchXML query na entity `workflow` filtrando por `name like '%PMO_PA_%'` SEM filtro de category. Verificar que existem pelo menos 3 com nome CheckInOnDemand, EscalarRiscoCritico, RegistrarDecisaoBoard com statecode=Activado.

## Output Esperado
Salvar resultado consolidado em `.planning/comms/G6_QA_WAVE1_RESULTS.md` com tabela:

| ID | Teste | Status (PASS/FAIL) | Detalhes | Timestamp |
|----|-------|-------------------|----------|-----------|

Ao final, atualizar `.planning/QA_PHASE6_PLAN.md` marcando os testes concluídos.

## REGRAS
- NÃO executar testes browser (D1–G3). Esses são de outro agente.
- NÃO modificar dados de produção (PRJ-001 a PRJ-005). Itens de teste devem ter ProjectID="PRJ-QA-TEST" e Ativo=Não.
- Se PnP não conectar, documentar o erro e prosseguir com os outros grupos.
- Se PAC fetch falhar, tentar abordagens alternativas e documentar.
