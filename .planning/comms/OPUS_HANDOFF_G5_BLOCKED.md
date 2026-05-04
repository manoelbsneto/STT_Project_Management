# OPUS Handoff — G5 Blocked

## Summary

Phase 5 is partially complete. SharePoint view work succeeded, but Teams tab creation is blocked by Microsoft Graph/Teams permissions.

## Completed

- Created/verified SharePoint view `Projetos Críticos` on list `Projetos`.
- Resolved SharePoint view URLs for:
  - `Board RAG`
  - `Projetos Críticos`
  - `Pendentes`

## Evidence

- `.planning/comms/g5_sharepoint_views_20260503_142829.json`
- `deploy/Teams_Phase5_Tabs.ps1`
- `deploy/Teams_Phase5_GraphTabs.ps1`

## Blocker

Teams tab creation needs Microsoft Graph auth.

- M365 CLI is logged out.
- M365 CLI default app is not consented in the tenant: `AADSTS700016`.
- Legacy PnP `Connect-PnPOnline -UseWebLogin` works for SharePoint but does not provide a Graph OAuth token for Teams commands.
- `Connect-PnPOnline -Graph` and `-PnPManagementShell` fail with `Identificador inválido`.
- Microsoft Graph PowerShell device-code login was attempted multiple times, but each attempt timed out after 120 seconds before browser login/MFA completion.
- Latest generated codes were surfaced to the user (`GJBRZYMG6`, `C3U6CAWSE`, `LSV9MW9C9`); the final attempt also copied the code to the Windows clipboard and opened the device-login page.
- User subsequently confirmed they do not have Graph access.

## Decision

Stop retrying Graph auth with the current account. Teams tab creation is Graph-backed across direct Graph API, PnP Teams cmdlets, MicrosoftTeams PowerShell, and M365 CLI.

## Resume Command

Run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\deploy\Teams_Phase5_GraphTabs.ps1
```

Use an account with Teams/Graph permissions, then complete the device-code login shown in the PowerShell output within 120 seconds. Be ready in the browser before starting the command; the Microsoft Graph PowerShell timeout is short.

If no Graph-enabled account is available, use `.planning/comms/G5_NO_GRAPH_FALLBACK.md` to add the SharePoint list views manually as Teams tabs.

## Pending

- Add Teams tab `Portfólio Executivo`.
- Add Teams tab `Projetos Críticos`.
- Add Teams tab `Decisões Pendentes`.
- Verify tabs via Graph tab listing.
