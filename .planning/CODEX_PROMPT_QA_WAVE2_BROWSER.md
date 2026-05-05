# CODEX PROMPT — Phase 6 QA Wave 2: Browser-Light Tests (D1–E4)

Leia `.planning/QA_PHASE6_PLAN.md`, `.planning/STATE.md` e `.planning/comms/G6_QA_WAVE1_RESULTS.md`.

## Objetivo
Executar somente os testes browser-light D1–D2 e E1–E4 da Phase 6.
Estes testes são navegação simples e form fill — NÃO exigem interação com Adaptive Cards ou Copilot.

## Executor
**Codex Sub-Agent** (browser-light) — custo baixo/médio. NÃO usar Opus para estes testes.

## Contexto
- Ambiente Power Platform: `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- SharePoint site: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`
- Teams channel deep link: `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920`
- Teams channel: `Projetos_Tranformação_Digital`
- Tabs esperadas: `Portfolio_Executivo`, `Projetos_Criticos`, `Decisoes do Board`
- Evidência Wave 1: PASS=9, FAIL=0, CHECK=3, NOT_RUN=2

## Escopo

| ID | Teste | Critério |
|----|-------|----------|
| D1 | Cadastrar projeto novo via SharePoint form | Criar `PRJ-QA1`; item aparece na lista `Projetos` com campos principais preenchidos. |
| D2 | Cadastrar risco crítico via SharePoint form | Criar risco crítico para `PRJ-QA1`; item aparece em `Riscos e Bloqueios` e o fluxo `PMO_PA_EscalarRiscoCritico` dispara alerta no Teams. |
| E1 | Verificar tab `Portfolio_Executivo` | Tab abre a view Board RAG com dados agrupados por `StatusRAG`. |
| E2 | Verificar tab `Projetos_Criticos` | Tab mostra somente projetos `StatusRAG=Vermelho`. |
| E3 | Verificar tab `Decisoes do Board` | Tab mostra view `Pendentes` com filtro `Status=Pendente`. |
| E4 | Verificar cards no canal Conversa | Cards `ResumoDiario` e `ResumoSemanal` visíveis no canal. |

## Dados de Teste
- ProjectID: `PRJ-QA1`
- NomeProjeto: `QA Browser Wave 2`
- PMResponsavel: usar usuário logado, se o campo exigir pessoa.
- StatusRAG inicial: `Amarelo`
- Percentual: `10`
- Ativo: `Não` ou `false`, se o campo existir.
- Risco: `QA Wave 2 - risco crítico de validação`
- Severidade: `Crítica`
- StatusRisco: `Aberto`

## Regras
- Não alterar `PRJ-001`–`PRJ-005`.
- Não executar F1–F3 nem G1–G3 nesta Wave (esses são Opus-only).
- Capturar screenshots ou anotar evidência visual suficiente para cada PASS/FAIL.
- Se algum campo do formulário tiver nome ligeiramente diferente, usar o equivalente funcional e registrar o ajuste.
- Se login/browser bloquear, registrar `BLOCKED` com mensagem exata e URL.

## Output Esperado
Criar `.planning/comms/G6_QA_WAVE2_BROWSER_RESULTS.md` com:

| ID | Status | Evidência | Observações | Timestamp |
|----|--------|-----------|-------------|-----------|

Também atualizar:
- `.planning/QA_PHASE6_PLAN.md` com status da Wave 2.
- `.planning/STATE.md` com resumo da sessão e próximo passo.

## Próximo Passo Após Wave 2
Wave 3 (Opus Browser-Critical): F1–F3, G1–G3 — usar prompt separado `.planning/OPUS_PROMPT_QA_WAVE3_CRITICAL.md`
