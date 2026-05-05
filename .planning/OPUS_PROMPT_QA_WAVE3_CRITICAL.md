# OPUS PROMPT — Phase 6 QA Wave 3: Critical Browser Tests (F1–G3)

Leia `.planning/QA_PHASE6_PLAN.md`, `.planning/STATE.md`, `.planning/comms/G6_QA_WAVE1_RESULTS.md` e `.planning/comms/G6_QA_WAVE2_BROWSER_RESULTS.md`.

## Objetivo
Executar SOMENTE os 6 testes críticos F1–F3 e G1–G3 que exigem interação browser complexa.

## Por que Opus (e não Codex)
Estes testes são **impossíveis de automatizar** via API/PowerShell porque:
- F1–F3: Exigem interação real com **Adaptive Cards** no Teams (dropdown selection, text input, button click, card submission) — não existe endpoint programático para responder cards sem Graph
- G1–G3: Exigem **conversação real-time** com Copilot no Teams chat — NLU, confirmação de ação, escrita em SharePoint

## Contexto
- Ambiente Power Platform: `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- SharePoint site: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
- Teams channel deep link: `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920`
- Teams channel: `Projetos_Tranformação_Digital`
- Bot name: `Assistente PMO`
- Waves 1–2 devem estar concluídas antes de iniciar Wave 3.

## Escopo

### Bloco F: Adaptive Card Interaction (F1–F3)

| ID | Teste | Método | Critério de Aceite | Pré-Requisito |
|----|-------|--------|-------------------|---------------|
| F1 | Responder Check-In Diário card | Encontrar card no canal → selecionar projeto → preencher campos → clicar Enviar | Resposta grava novo item em SP lista `Status Diario` | Card existente no canal |
| F2 | Responder Decisão Board card | Navegar até card de decisão → clicar Aprovar | Status na lista `Decisoes` atualizado para "Aprovado" | Wave 2 D2 + flow disparou |
| F3 | Trigger CheckInOnDemand manual | Power Automate portal → Run flow manual → verificar card no Teams → responder | Card aparece no canal; resposta grava em `Status Diário` | Acesso ao PA portal |

### Bloco G: Copilot Conversation (G1–G3)

| ID | Teste | Método | Critério de Aceite | Pré-Requisito |
|----|-------|--------|-------------------|---------------|
| G1 | Copilot: Greeting + ConsultarPortfólio | Chat com `Assistente PMO` → "Olá" → "Como está o portfólio?" | Saudação pt-BR + distribuição RAG dos 5 projetos | Bot instalado e acessível no Teams |
| G2 | Copilot: ConsultarProjeto drill-down | "Como está o projeto PRJ-001?" | Nome, PM, StatusRAG, %, última atualização retornados | G1 concluído |
| G3 | Copilot: RegistrarRisco Confirm-Before-Action | "Registrar risco crítico no PRJ-001: atraso fornecedor" → confirmar quando bot pedir | Bot pede confirmação → após confirmar, item criado em SP `Riscos e Bloqueios` | G2 concluído |

## Regras
- Não alterar projetos `PRJ-001`–`PRJ-005` diretamente (só via Copilot/Card como parte do teste).
- Capturar screenshots para CADA interação significativa (card rendered, campos preenchidos, resposta do Copilot, item criado no SP).
- Se o bot não estiver instalado no Teams, registrar `BLOCKED` com mensagem exata.
- Se Adaptive Card não renderizar, registrar `BLOCKED` com screenshot da área do canal.
- Tempo máximo de espera por resposta do Copilot: 30 segundos antes de registrar `TIMEOUT`.

## Output Esperado
Criar `.planning/comms/G6_QA_WAVE3_OPUS_RESULTS.md` com:

| ID | Status | Evidência | Observações | Timestamp |
|----|--------|-----------|-------------|-----------|

Também atualizar:
- `.planning/QA_PHASE6_PLAN.md` com status da Wave 3.
- `.planning/STATE.md` com resumo da sessão.

## Após Wave 3
Se todas as 3 Waves PASS → Codex consolida `G6_QA_FINAL_RESULTS.md` (Wave 4).
Se issues encontrados → Opus diagnostica e planeja fixes inline.
