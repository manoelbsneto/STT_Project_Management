# PMO Intelligent Hub — State

## Current Phase
Phase 6 — Piloto Controlado + QA

## Next Phase
Phase 7 — Rollout + Governança

## Active Agent
Pending — QA Wave 2 browser/manual validation (D1–D2, E1–E4)

## Active Power Platform Environment
ColOfertasBrasilPro — `e2d10003-4d8e-e007-9d63-76d5fe89ef56`

## Decisions Made
1. Solução D+B aprovada (SharePoint Hub + Copilot Studio Agent)
2. Standard-Only — sem Graph direto, sem Premium
3. Planner Standard connector aprovado como workaround
4. Confirm-Before-Action obrigatório no Copilot
5. GSD Framework adotado para orquestração agêntica
6. Endpoints oficiais: `Projetos_Tranformação_Digital` (Teams) + `Grp_T_DN_Transformacao_Digital` (SP)
7. Adaptive Cards limite <27KB
8. PRD v1.3 aprovada com nota 94/100
9. Todas as fases Power Platform / Power Automate / Copilot devem usar sempre o ambiente `ColOfertasBrasilPro`, nunca Default.
10. G2 redesign: flows de check-in usam `PostCardAndWaitForResponse` (ação, não trigger separado). Trigger "When someone responds" descartado por limitação documentada em non-Default environments.
11. **Teams Channel Deep Link (obrigatório para acesso browser):** `https://teams.microsoft.com/l/channel/19%3A4c8fe80b169f4e698c9b1b15d1868691%40thread.tacv2/Projetos_Tranforma%C3%A7%C3%A3o_Digital?groupId=96c5b0c4-46cc-46cd-8695-50451db74994&tenantId=7808e005-1489-4374-954b-d3b08f193920` — Channel ID: `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2`

## Backlog (Postergado)
- [ ] **Manual de Operações PMO Hub (pt-BR)** — Passo a passo completo com screenshots reais para PMs. Prioridade imediata após conclusão QA E2E. Deve cobrir: cadastro projeto, status diário, cards, tabs Teams, Copilot, painéis.
- [x] **Teams Desktop Card Render Screenshots** — ✅ Resolved 2026-05-04. User screenshots show `ResumoDiarioBoard` and `ResumoSemanal` cards rendered in Teams Desktop with real SharePoint data.
- [ ] **E2E Validation P0 Flows** — Teste interativo no Teams: card submission → SP write → alert behavior. Phase 6 priority.
- [ ] **Copilot Runtime Conversation QA** — Validar no Teams: saudação, consultar portfólio, consultar projeto, confirmar ação de escrita e acionar fluxo. Phase 6 priority.

## Blockers
- ~~G5 Teams tab provisioning blocked on Graph~~ — RESOLVED 2026-05-04 via manual Teams UI creation.
- Nota operacional: SharePoint provisioning deve usar Windows PowerShell 5.1 + `SharePointPnPPowerShellOnline 3.29.2101.0` + `Connect-PnPOnline -UseWebLogin`; ver `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`.

## Risk Register
| Risk | Severity | Mitigation |
|------|----------|------------|
| Adoção baixa PMs | Média | Treinamento curto, cards simples, cobrança executiva |
| Flow throttling | Média | Monitoramento diário, reduzir ações, dividir fluxos |
| Capacidade Copilot excedida | Média | Fallback Cards/Forms/SP Tabs |
| SharePoint views lentas | Média | Indexação, filtros, retenção |
| Falha sync Planner Standard | Média | Delay, frequência controlada, fallback manual |

## Session History
- Session 1: PRD v1.0 criada, arquitetura definida, soluções avaliadas
- Session 2: PRD v1.3 ajustada (Standard-Only), endpoints oficiais, score 94/100
- Session 3: GSD instalado, planning framework inicializado, deploy plan agêntico criado
- Session 4: G1 executado e aprovado com caminho legado PnP; 4 listas SharePoint criadas e verificadas.
- Session 5: Prompt de handoff para OPUS-ARCH criado; próximos controles apontam para Phase 2 / G2.
- Session 6: Ambiente Power Platform corrigido para `ColOfertasBrasilPro`.
- Session 7: G2 executado parcialmente; 3/5 flows criados, 2/5 bloqueados por ProcessSimple 400.
- Session 8: G2 wiring patch aplicado; placeholder flows receberam ações reais.
- Session 9: OPUS redesign aplicado: PostCardAndWaitForResponse em EnviarCheckInDiario e CheckInOnDemand; ProcessarRespostaCheckIn desabilitado.
- Session 10: G2 CONDITIONAL aceito. E2E postergado para backlog (Phase 6). Phase 3 despachada.
- Session 11: G3 PASS; cinco flows P1/P2 criados, iniciados e exportados em `ColOfertasBrasilPro`.
- Session 12: G4 CONDITIONAL; agente `Assistente PMO` criado e listado como Published, mas entidades nativas, knowledge/actions SharePoint, idioma pt-BR primário, instalação Teams e teste de conversa seguem pendentes.
- Session 13: G4 programmatic completion; bot pt-BR, GPT restrictions, PMO SharePoint knowledge source, PA action bindings and final solution export verified. Runtime Teams conversation validation moved to Phase 6 QA.
- Session 14: G5 SharePoint view setup completed, but Teams tab creation remains blocked because Microsoft Graph device-code login attempts expired and the user confirmed they do not have Graph access. Fallback documented in `.planning/comms/G5_NO_GRAPH_FALLBACK.md`.
- Session 15 (2026-05-04T07:23–07:38): **G2 upgraded to PASSED** (E2E Teams screenshot: ResumoDiarioBoard + ResumoSemanal cards with live SP data). **G5 PASSED** — user manually created 3 SharePoint tabs via Teams UI: `Portfolio_Executivo`, `Projetos_Criticos`, `Decisoes do Board`. Teams channel deep link documented in PRD §1.1, STATE, `.planning/.env`. All G0–G5 now PASSED. Phase 6 Piloto QA is next.
- Session 16 (2026-05-04T08:32–08:33): **Phase 6 Wave 1 automated QA executed** via `deploy/QA_Phase6_Automated.ps1` in `ColOfertasBrasilPro`. Result: PASS=9, FAIL=0, CHECK=3, NOT_RUN=2. Live ProcessSimple verified 10 PMO flows, recurrence run history, trigger types, Standard-only connectors, 6 card JSON files, Copilot published/active/provisioned, security/language evidence, and 3 action bindings. A1/A2/A5 remain evidence-mode checks; A3/A4 require interactive PnP login. Evidence: `.planning/comms/G6_QA_WAVE1_RESULTS.md` and `.planning/comms/g6_qa_wave1_20260504_083202.json`. Wave 2 browser handoff prepared at `.planning/CODEX_PROMPT_QA_WAVE2_BROWSER.md`.
- Session 17 (2026-05-05T17:00–20:07): **CriarTarefa SEV-0 Stop-Ship diligence pass — SHIP GO/GREEN.** Full RCA pack for 4 issues (P0 routing failure, P0 action/flow contract mismatch, P1 publish ambiguity, P1 repo template drift). Deterministic regression harness `tests/Test-CriarTarefaContract.ps1` fails known-bad (7/9) and passes live+repo (9/9). Runbook-compliant evidence: `pac env who`, `pac connection list`, `pac copilot list` (Published/Active/Provisioned), fresh `extract-template`, raw Dataverse `pac org fetch`, and Windows PowerShell 5.1 `Get-Flow` (enabled/Started, `result` response). Code shipped: `CS_CriarTarefa_ContractFix.ps1`, `AssistentePMO.template.yaml` (action component + action-calling dialog), `Test-CriarTarefaContract.ps1`. Residual risks accepted: R-005 ProjectID concurrency (P1), R-006 input validation (P2). Closure: `.planning/stopship/criartarefa/CLOSURE_HANDOFF.md`.
