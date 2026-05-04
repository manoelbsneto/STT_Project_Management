# OPUS Handoff Prompt — G1 Final Review / Phase 2 Dispatch

Copy/paste to OPUS-ARCH:

```text
You are OPUS-ARCH for PMO Intelligent Hub MVP.

Context:
- G0 passed on 2026-05-01.
- G1 SharePoint provisioning passed on 2026-05-02.
- Phase 1 is complete; Phase 2 is the next active phase.
- Current next execution owner: Codex Sub-2 (Power Automate Expert).
- Mandatory Power Platform environment for all phases: `ColOfertasBrasilPro`.
- Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`.
- Environment URL: `https://colofertasbrasilpro.crm4.dynamics.com/`.
- Do not use the Default environment for Power Automate or Copilot Studio work.
- Correct SharePoint tenant access is documented in `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`.
- Do not use PowerShell 7, modern `PnP.PowerShell`, `Connect-PnPOnline -Interactive`, ClientId, app registration, service principal, certificate auth, HTTP with Microsoft Entra ID, custom connector, or Graph direct for SharePoint provisioning in this tenant.
- Use Windows PowerShell 5.1 + `SharePointPnPPowerShellOnline 3.29.2101.0` + `Connect-PnPOnline -UseWebLogin`; login and provisioning command must run in the same PowerShell process.

Evidence:
- Gate status: `.planning/comms/GATE_STATUS.md`
- Lead log: `.planning/comms/CODEX_LEAD_LOG.md`
- SharePoint specialist log: `.planning/comms/SUB1_SP_LOG.md`
- Provisioning transcript: `.planning/comms/g1_legacy_pnp_provisioning_20260502_115923.log`
- Verification transcript: `.planning/comms/g1_legacy_pnp_verify_20260502_120214.log`
- State: `.planning/STATE.md`
- Roadmap: `.planning/ROADMAP.md`
- SharePoint access runbook: `.planning/SHAREPOINT_ACCESS_RUNBOOK.md`
- Environment control: `.planning/.env`

Verified tenant result:
- `Projetos`: 22 custom fields, views `Board RAG`, `Gallery`, `Todos`, 5 pilot items.
- `Status Diario`: 13 custom fields, view `Por Projeto`.
- `Riscos e Bloqueios`: 13 custom fields, view `Abertos`.
- `Decisoes do Board`: 14 custom fields, view `Pendentes`.

Known operational caveat:
- `deploy/SP_Provisioning.ps1` was used successfully for G1, but should not be rerun blindly against the same tenant objects without either idempotency hardening or explicit cleanup planning.

Request:
1. Review G1 evidence.
2. Confirm G1 final PASS formally if acceptable.
3. Dispatch Phase 2 / G2 work to CODEX-LEAD and CODEX-PA in `ColOfertasBrasilPro`: Power Automate P0 flows and Adaptive Cards validation.
4. Preserve `.planning/SHAREPOINT_ACCESS_RUNBOOK.md` as the authoritative SharePoint tenant access runbook.
5. Preserve `ColOfertasBrasilPro` as the mandatory Power Platform environment for all remaining phases.
```
