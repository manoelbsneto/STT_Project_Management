# CODEX Handoff Prompt — G2 Remediation: Flow Wiring + E2E Validation

Copy/paste to CODEX-LEAD:

```text
You are CODEX-LEAD for PMO Intelligent Hub MVP.

Context:
- G0 PASSED. G1 PASSED. G2 is CONDITIONAL — 5/5 flows exist in ColOfertasBrasilPro but 2 have placeholder actions only.
- OPUS-ARCH created the 2 previously failed flows via browser portal remediation.
- Your task is to complete the wiring and run E2E validation for all 5 flows.

Mandatory environment:
- All work in `ColOfertasBrasilPro` (e2d10003-4d8e-e007-9d63-76d5fe89ef56).
- Do NOT use Default environment.
- Standard connectors ONLY: SharePoint, Teams, Office 365 Outlook, Planner.

SharePoint site: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
Lists (G1 verified): Projetos (22 fields), Status Diario (13 fields), Riscos e Bloqueios (13 fields), Decisoes do Board (14 fields).

Teams channel: Projetos_Tranformação_Digital
- GroupID: 96c5b0c4-46cc-46cd-8695-50451db74994
- TenantID: 7808e005-1489-4374-954b-d3b08f193920

Adaptive Card JSONs: deploy/cards/CheckInDiario.json, deploy/cards/AlertaCritico.json, deploy/cards/DecisaoBoard.json (all <27KB, schema v1.4).

---

TASK 1 — Wire PMO_PA_ProcessarRespostaCheckIn (currently has placeholder Compose only)

This flow must do:
- Trigger: "When someone responds to an adaptive card" (already set)
- Action 1: Parse JSON — parse the adaptive card response body to extract: ProjectID, StatusRAG, Percentual, Resumo, Bloqueios
- Action 2: SharePoint "Create item" → list "Status Diario" with fields:
  - ProjectID = parsed ProjectID
  - StatusRAG = parsed StatusRAG
  - Percentual = parsed Percentual
  - Resumo = parsed Resumo
  - Bloqueios = parsed Bloqueios
  - DataCheckin = utcNow()
  - PM = trigger user
- Action 3: SharePoint "Update item" → list "Projetos" WHERE ID matches ProjectID:
  - StatusRAG = parsed StatusRAG
  - Percentual = parsed Percentual
  - UltimaAtualizacao = utcNow()
- Action 4: Condition — IF StatusRAG = "Vermelho" THEN:
  - Post adaptive card (AlertaCritico.json) to Teams channel
  - Send email to Sponsor (from Projetos item Sponsor field)
- Remove or replace the placeholder Compose action.

---

TASK 2 — Wire PMO_PA_AlertaProjetoVermelho (currently has placeholder Compose only)

This flow must do:
- Trigger: "When an item is created or modified" on SP list "Projetos" (already set)
- Action 1: Condition — IF StatusRAG equals "Vermelho"
  - Yes branch:
    - Action 2a: Get item from "Projetos" to fetch Sponsor, PM, Nome
    - Action 2b: Post adaptive card (AlertaCritico.json) to Teams channel Projetos_Tranformação_Digital with dynamic values (ProjectID, Nome, PM, StatusRAG)
    - Action 2c: Send email (Office 365 Outlook) to Sponsor with subject "🔴 ALERTA: Projeto [Nome] em status Vermelho" and body with project details
  - No branch: do nothing (terminate)
- Remove or replace the placeholder Compose action.

---

TASK 3 — Verify the other 3 flows already have correct actions

Review in the portal:
- PMO_PA_EnviarCheckInDiario: Should have Recurrence 9h → Get items (Projetos WHERE Status != Concluído) → Apply to each → Post adaptive card (CheckInDiario.json) to each PM
- PMO_PA_CheckInOnDemand: Should have Manual/Instant trigger → Post adaptive card (CheckInDiario.json) for specific project
- PMO_PA_AlertaSemAtualizacao: Should have Recurrence 10h → Get items (Projetos WHERE UltimaAtualizacao < addDays(utcNow(),-1)) → Apply to each → Post reminder to PM

If any of these 3 flows also have only placeholder actions, wire them following the specifications in `.planning/AGENT_CONTRACT.md` Section 6.

---

TASK 4 — E2E Validation (all 5 flows)

For each flow:
1. Open the flow in the portal
2. Run a test (click "Testar" / Test)
3. Verify the trigger fires correctly
4. Verify SharePoint data is written/read correctly
5. Verify Teams card posts correctly (screenshot)
6. Document result per flow

---

TASK 5 — Teams Adaptive Card Render Validation

Test each card JSON in Teams:
- CheckInDiario.json — must render with input fields for StatusRAG, Percentual, Resumo, Bloqueios
- AlertaCritico.json — must render with project alert details
- DecisaoBoard.json — must render with decision options

Take screenshots of each card rendered in Teams Desktop.

---

Evidence and logs:
- Update `.planning/comms/SUB2_PA_LOG.md` with wiring completion per flow
- Update `.planning/comms/CODEX_LEAD_LOG.md` with G2 final result
- Update `.planning/comms/GATE_STATUS.md` with G2 evidence
- Create `.planning/comms/OPUS_HANDOFF_G2_FINAL.md` with G2 review prompt for OPUS-ARCH

Specifications reference: `.planning/AGENT_CONTRACT.md` Section 6 (Flows 1-5).
Auth reference: `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
Current gate status: `.planning/comms/GATE_STATUS.md`
Current PA log: `.planning/comms/SUB2_PA_LOG.md`

G2 FULL PASS criteria:
- All 5 flows active with real actions (no placeholders)
- All 5 flows in ColOfertasBrasilPro using Standard connectors only
- SharePoint actions target the verified G1 lists
- At least 1 E2E test per flow documented
- At least 1 Teams card render screenshot
```
