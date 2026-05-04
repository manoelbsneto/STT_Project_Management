# CODEX Handoff — Phase 3: Power Automate P1/P2 Flows

Copy/paste to CODEX-LEAD:

```text
You are CODEX-LEAD for PMO Intelligent Hub MVP.

Context:
- G0 PASSED. G1 PASSED. G2 CONDITIONAL (E2E deferred to Phase 6).
- Phase 3 dispatched by OPUS-ARCH.
- Your sub-agent for this phase is CODEX-PA (Sub-2, Power Automate Expert).

Mandatory environment:
- All work in `ColOfertasBrasilPro` (e2d10003-4d8e-e007-9d63-76d5fe89ef56).
- Do NOT use Default environment.
- Standard connectors ONLY: SharePoint, Teams, Office 365 Outlook, Planner (Standard).

SharePoint site: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
Lists (G1 verified): Projetos (22 fields), Status Diario (13 fields), Riscos e Bloqueios (13 fields), Decisoes do Board (14 fields).

Teams channel: Projetos_Tranformação_Digital
- GroupID: 96c5b0c4-46cc-46cd-8695-50451db74994
- TenantID: 7808e005-1489-4374-954b-d3b08f193920

Existing Adaptive Card JSONs: deploy/cards/CheckInDiario.json, deploy/cards/AlertaCritico.json, deploy/cards/DecisaoBoard.json

Auth reference: .planning/SHAREPOINT_ACCESS_RUNBOOK.md

---

Phase 3 scope — create 5 P1/P2 Power Automate flows:

FLOW 6: PMO_PA_ResumoDiarioBoard
- Trigger: Recurrence daily 17h UTC-3
- Actions:
  1. Get items: Projetos WHERE Ativo=Yes
  2. Count: total, verdes, amarelos, vermelhos
  3. Get items: Projetos WHERE UltimaAtualizacao < addDays(utcNow(),-1)
  4. Get items: Decisoes do Board WHERE Status=Pendente
  5. Compose summary Adaptive Card with counts + delinquent list + pending decisions
  6. Post card to Teams channel Projetos_Tranformação_Digital
- Output: Executive summary card posted daily at 17h

FLOW 7: PMO_PA_RegistrarDecisaoBoard
- Trigger: When an item is created in "Decisoes do Board" list
- CRITICAL DESIGN: Use "Post adaptive card and wait for a response" (NOT separate trigger flow). Same pattern as G2 redesign.
- Actions:
  1. Get created item details from Decisoes do Board
  2. Get Aprovador person field
  3. Compose Decision Adaptive Card using deploy/cards/DecisaoBoard.json with dynamic fields (DecisionID, ProjectID, Descricao, Solicitante, Impacto, Prazo)
  4. Post card and wait for response — send to Aprovador via Teams chat or channel
  5. Parse response (Status: Aprovada/Rejeitada/Adiada, Resposta text)
  6. Update item in Decisoes do Board: Status, Resposta, DataResposta=utcNow(), ApproverUPN, ResponseSource=AdaptiveCard
- Output: Decision card sent, response captured and written back to SP

FLOW 8: PMO_PA_SyncPlannerStats_Standard
- Trigger: Recurrence every 6 hours
- Actions:
  1. Get items: Projetos WHERE PlannerPlanId != empty AND Ativo=Yes
  2. For each projeto (sequential, concurrency=1 to avoid throttling):
     a. List tasks using Planner Standard connector (by PlanId from SP item)
     b. Calculate: TarefasTotal, TarefasAbertas, TarefasConcluidas, TarefasAtrasadas
     c. Update item: Projetos with metrics + PlannerLastSyncAt=utcNow() + PlannerSyncStatus=OK
  3. On error per projeto: set PlannerSyncStatus=Erro
- Output: Planner metrics synced to SP every 6h
- IMPORTANT: Use Planner Standard connector (not Premium). Action: "List tasks" with PlanId.

FLOW 9: PMO_PA_EscalarRiscoCritico
- Trigger: When an item is created in "Riscos e Bloqueios" list
- Actions:
  1. Condition: IF Severidade = "Crítica"
     Yes branch:
     a. Get item details
     b. Get linked Projeto (by ProjectID) to fetch Sponsor
     c. Compose escalation Adaptive Card with risk details
     d. Post card to Teams channel
     e. Send email (Office 365 Outlook) to Sponsor + PMO Lead with subject "🔴 RISCO CRÍTICO: [Descricao]"
     No branch: terminate
- Output: Critical risk auto-escalated

FLOW 10: PMO_PA_ResumoSemanal
- Trigger: Recurrence weekly Monday 8h UTC-3
- Actions:
  1. Get items: Projetos WHERE Ativo=Yes
  2. Get items: Status Diario WHERE DataRegistro >= addDays(utcNow(),-7)
  3. Calculate trends: RAG changes, deliveries, delays
  4. Get items: Decisoes do Board (last 7 days)
  5. Compose extended weekly summary Adaptive Card
  6. Post to Teams channel
- Output: Weekly expanded report

---

New Adaptive Cards needed:
- deploy/cards/ResumoDiarioBoard.json — executive summary card (~3KB target)
- deploy/cards/ResumoSemanal.json — weekly expanded card (~4KB target)
- deploy/cards/EscalacaoRisco.json — critical risk escalation card (~2KB target)
All must be Adaptive Card schema v1.4, under 27KB.

---

ProcessSimple PATCH pattern:
- Use the same proven approach from Phase 2: deploy/PA_Patch_G2_Wiring.ps1 and deploy/PA_Redesign_G2_PostCardWait.ps1 as reference.
- Create new script: deploy/PA_Phase3_P1P2.ps1
- Use Windows PowerShell 5.1 with ProcessSimple REST API for flow creation/patching.
- Auth: reuse PAC or PowerApps.PowerShell authenticated session from ColOfertasBrasilPro.

---

Deliverables:
1. Create all 5 P1/P2 flows in ColOfertasBrasilPro
2. Create 3 new Adaptive Card JSONs in deploy/cards/
3. Export post-creation flow definitions as evidence
4. Update .planning/comms/SUB2_PA_LOG.md with progress per flow
5. Update .planning/comms/CODEX_LEAD_LOG.md with G3 result
6. Update .planning/comms/GATE_STATUS.md with G3 evidence
7. Create .planning/comms/OPUS_HANDOFF_G3.md with review prompt for OPUS-ARCH

Specifications reference: .planning/AGENT_CONTRACT.md Section 6, Flows 6-10.
```
