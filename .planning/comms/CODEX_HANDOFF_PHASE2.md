# CODEX Handoff Prompt — Phase 2: Power Automate P0 Flows

Copy/paste to CODEX-LEAD:

```text
You are CODEX-LEAD for PMO Intelligent Hub MVP.

Context:
- G0 passed on 2026-05-01. G1 passed on 2026-05-02. Both formally approved by OPUS-ARCH.
- Phase 2 is the current active phase. You are the execution owner.
- OPUS-ARCH dispatched Phase 2 via `.planning/comms/DISPATCH.md`.
- Your sub-agent for this phase is CODEX-PA (Sub-2, Power Automate Expert).
- All Power Platform / Power Automate / Copilot work for every phase must target environment `ColOfertasBrasilPro` only.

SharePoint tenant access (mandatory):
- Do NOT use PowerShell 7, modern PnP.PowerShell, Connect-PnPOnline -Interactive, ClientId, app registration, service principal, certificate auth, HTTP with Microsoft Entra ID, custom connector, or Graph direct.
- Use Windows PowerShell 5.1 + SharePointPnPPowerShellOnline 3.29.2101.0 + Connect-PnPOnline -UseWebLogin.
- Login and commands must run in the same PowerShell process.
- Full runbook: `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`

SharePoint lists already provisioned (G1 verified):
- Projetos: 22 custom fields, 5 pilot items, views: Board RAG, Gallery, Todos
- Status Diario: 13 custom fields, view: Por Projeto
- Riscos e Bloqueios: 13 custom fields, view: Abertos
- Decisoes do Board: 14 custom fields, view: Pendentes
- Site URL: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital

Teams channel:
- Name: Projetos_Tranformação_Digital
- GroupID: 96c5b0c4-46cc-46cd-8695-50451db74994
- TenantID: 7808e005-1489-4374-954b-d3b08f193920
- Power Platform environment: ColOfertasBrasilPro
- Environment ID: e2d10003-4d8e-e007-9d63-76d5fe89ef56
- Environment URL: https://colofertasbrasilpro.crm4.dynamics.com/

Phase 2 scope — create 5 P0 Power Automate cloud flows:
1. PMO_PA_EnviarCheckInDiario — Recurrence daily 9h BRT → Get active projects → Post Adaptive Card check-in to each PM in Teams
2. PMO_PA_ProcessarRespostaCheckIn — When someone responds to adaptive card → Parse response → Create item in Status Diario → Update item in Projetos (RAG, Percentual, UltimaAtualizacao) → If RAG=Vermelho trigger alert
3. PMO_PA_AlertaProjetoVermelho — When item modified in Projetos WHERE StatusRAG changed to Vermelho → Post alert card to Teams channel → Email Sponsor
4. PMO_PA_CheckInOnDemand — Manual trigger or When agent calls flow → Post check-in card for specific project immediately
5. PMO_PA_AlertaSemAtualizacao — Recurrence daily 10h BRT → Get projects WHERE UltimaAtualizacao < 24h ago → Post reminder to each PM

Adaptive Card JSONs ready at:
- deploy/cards/CheckInDiario.json (~2.5KB)
- deploy/cards/AlertaCritico.json (~1.8KB)
- deploy/cards/DecisaoBoard.json (~2.8KB)
All cards are <27KB and use Adaptive Card schema v1.4.

Constraints:
- Standard connectors ONLY. No Premium, no HTTP, no Graph, no Dataverse.
- Allowed connectors: SharePoint (Standard), Office 365 Outlook (Standard), Microsoft Teams (Standard), Planner (Standard).
- All flows must use the SharePoint Standard connector pointing to site: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
- All flows must be created in `ColOfertasBrasilPro`. Do not use the Default environment.

Detailed flow specifications:
- See `.planning/AGENT_CONTRACT.md` Section 6 (Contract: CODEX-PA), Flows 1-5.

Evidence and project files:
- Dispatch: `.planning/comms/DISPATCH.md`
- Gate status: `.planning/comms/GATE_STATUS.md`
- Lead log: `.planning/comms/CODEX_LEAD_LOG.md`
- PA sub-agent log: `.planning/comms/SUB2_PA_LOG.md`
- State: `.planning/STATE.md`
- Roadmap: `.planning/ROADMAP.md`
- Agent contract: `.planning/AGENT_CONTRACT.md`
- PRD: PRD/PRD_PMO_M365_AJUSTADO_v1_3_ENDPOINTS_DEPLOY.md

Your deliverables:
1. Create all 5 P0 flows in Power Automate (`ColOfertasBrasilPro` environment).
2. Validate each Adaptive Card renders in Teams Desktop and Mobile.
3. Test each flow end-to-end (trigger → action → verify SP data).
4. Update `.planning/comms/SUB2_PA_LOG.md` with progress per flow.
5. Update `.planning/comms/CODEX_LEAD_LOG.md` with G2 execution result.
6. When all 5 flows pass, update `.planning/comms/GATE_STATUS.md` with G2 evidence.
7. Create `.planning/comms/OPUS_HANDOFF_PHASE2.md` with G2 review prompt for OPUS-ARCH.

Mandatory update protocol:
After completing each task, update your log files. No phase advances without all logs updated. See `.planning/AGENT_CONTRACT.md` Section 9.
```
