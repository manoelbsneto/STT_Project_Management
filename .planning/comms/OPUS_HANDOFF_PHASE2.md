# OPUS Handoff Prompt — G2 Phase 2 Partial / Blocked Review

Copy/paste to OPUS-ARCH:

```text
You are OPUS-ARCH for PMO Intelligent Hub MVP.

Review request:
- Gate: G2
- Phase: 2 — Power Automate P0 Flows
- Current decision requested: PASS/FAIL/REMEDIATE
- CODEX-LEAD recommendation: G2 NOT PASS; authorize remediation.

Mandatory environment:
- All Power Platform / Power Automate / Copilot work must target `ColOfertasBrasilPro` only.
- Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`
- Environment URL: `https://colofertasbrasilpro.crm4.dynamics.com/`
- Tenant ID: `7808e005-1489-4374-954b-d3b08f193920`
- Do not use Default environment.

SharePoint tenant:
- Site URL: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
- G1 PASS already verified the lists:
  - Projetos: 22 custom fields, 5 pilot items, views Board RAG/Gallery/Todos
  - Status Diario: 13 custom fields, view Por Projeto
  - Riscos e Bloqueios: 13 custom fields, view Abertos
  - Decisoes do Board: 14 custom fields, view Pendentes

G2 execution result:
- Status: PARTIAL / BLOCKED
- 3 of 5 P0 flows were created or confirmed existing by ProcessSimple evidence:
  1. PMO_PA_EnviarCheckInDiario — CREATED — flowId `e117bbc5-5684-4191-8d03-fb183452ac5f` — state Started
  2. PMO_PA_CheckInOnDemand — CREATED — flowId `c9e51483-38e7-422a-98cd-cf7604d14a16` — state Started
  3. PMO_PA_AlertaSemAtualizacao — EXISTS — flowId `0550c8ba-faf8-4e21-864e-d1fa5f625ce7` — state Started
- 2 of 5 P0 flows failed creation:
  4. PMO_PA_ProcessarRespostaCheckIn — FAILED — ProcessSimple 400
  5. PMO_PA_AlertaProjetoVermelho — FAILED — ProcessSimple 400

Evidence files:
- Provisioning result: `.planning/comms/g2_p0_flow_provisioning_20260502_124959.json`
- Blocked result: `.planning/comms/g2_p0_flow_provisioning_20260502_130919_blocked.json`
- CODEX lead log: `.planning/comms/CODEX_LEAD_LOG.md`
- CODEX-PA log: `.planning/comms/SUB2_PA_LOG.md`
- Gate status: `.planning/comms/GATE_STATUS.md`
- Script used: `deploy/PA_Provisioning_P0.ps1`

Authentication and tooling findings:
- `pac env who` succeeds and is connected to `ColOfertasBrasilPro` as `mbenicios@minsait.com`.
- `pac connection list` succeeds and confirms Standard connector connections:
  - SharePoint: `44f187cde7f54f208cf22bac4e533816`
  - Teams: `shared-teams-1440d346-f1dd-44ea-912f-3787038ac333`
  - Office 365 Outlook: `306d783533364cb6948ab2830fc3b188`
- `Microsoft.PowerApps.PowerShell` cannot re-authenticate with username/password because tenant MFA returns `AADSTS50076`.
- `Microsoft.PowerApps.PowerShell Test-PowerAppsAccount` hangs when interactive MFA is not completed.
- `m365 login --authType browser` timed out; `m365 status` remained `Logged out`.
- Installed PAC version has no supported `pac flow create` command.

Implementation gaps:
- No E2E flow validation completed.
- Teams Desktop/Mobile Adaptive Card rendering not validated.
- Adaptive Card JSON files pass local schema/size validation only:
  - `deploy/cards/CheckInDiario.json`: AdaptiveCard v1.4, 2401 bytes
  - `deploy/cards/AlertaCritico.json`: AdaptiveCard v1.4, 1491 bytes
  - `deploy/cards/DecisaoBoard.json`: AdaptiveCard v1.4, 2123 bytes
- Earlier Teams Adaptive Card action failed with ProcessSimple 400 and was downgraded to message fallback in `deploy/PA_Provisioning_P0.ps1`.
- Earlier SharePoint CreateItem/UpdateItem dynamic schema actions failed with ProcessSimple 400 for `PMO_PA_ProcessarRespostaCheckIn`.
- Earlier Outlook SendEmailV2 action failed with ProcessSimple 400 for `PMO_PA_AlertaProjetoVermelho`.

Recommended OPUS decision:
1. Do not approve G2 PASS yet.
2. Authorize one remediation route:
   - Route A: interactive Power Automate portal completion in `ColOfertasBrasilPro`, using Standard connectors only, then E2E test and update evidence; or
   - Route B: supported ALM/import path with a valid interactive authenticated ProcessSimple or solution import session.
3. Require final G2 evidence before PASS:
   - all 5 flows active in `ColOfertasBrasilPro`;
   - Standard connectors only;
   - SharePoint actions write/read the verified G1 lists;
   - Teams card rendering validated on Desktop and Mobile;
   - trigger-to-action-to-SharePoint E2E test evidence for each P0 flow.

Final requested response:
- Return one of:
  - `G2 FAIL — remediation required`
  - `G2 CONDITIONAL — manual portal remediation authorized`
  - `G2 PASS` only if OPUS independently accepts the partial state, which CODEX-LEAD does not recommend.
```
