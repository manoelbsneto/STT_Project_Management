# G5 No-Graph Fallback — Teams Tabs

## Status

SharePoint view preparation is complete. Teams tab creation cannot be completed programmatically by the current account because the user confirmed they do not have Microsoft Graph access.

Teams channel tabs are Graph-backed. The following routes all require Graph permissions, app consent, or an account with equivalent Teams administration rights:

- Microsoft Graph API `/teams/{team-id}/channels/{channel-id}/tabs`
- `PnP.PowerShell` / PnP Teams tab cmdlets
- `MicrosoftTeams` PowerShell tab cmdlets
- CLI for Microsoft 365 Teams tab commands

## Ready URLs

Use these URLs when adding SharePoint tabs manually in Teams:

| Teams Tab | SharePoint View URL |
|-----------|---------------------|
| Portfólio Executivo | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos/Board%20RAG.aspx` |
| Projetos Críticos | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Projetos/Projetos%20Crticos1.aspx` |
| Decisões Pendentes | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital/Lists/Decisoes%20do%20Board/Pendentes.aspx` |

Source evidence: `.planning/comms/g5_sharepoint_views_20260503_142829.json`

## Manual Teams UI Steps

1. Open Microsoft Teams.
2. Go to team `Grp_T_DN_Transformacao_Digital`.
3. Open channel `Projetos_Tranformação_Digital`.
4. Select `+` to add a tab.
5. Choose `SharePoint` or `Website`.
6. Add each URL above with the matching tab name.
7. Confirm all three tabs appear in the channel.

## Programmatic Resume Path

If a Teams owner/admin account with Graph access is available, run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\deploy\Teams_Phase5_GraphTabs.ps1
```

Expected output/evidence after success:

- `.planning/comms/g5_graph_channel_*.json`
- `.planning/comms/g5_graph_tabs_before_*.json`
- `.planning/comms/g5_graph_tabs_after_*.json`
- `.planning/comms/g5_graph_tabs_summary_*.json`

G5 can only be marked PASSED after the tab listing confirms `Portfólio Executivo`, `Projetos Críticos`, and `Decisões Pendentes`.
