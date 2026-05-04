# SharePoint Access Runbook — Authoritative

## Status
This is the authoritative SharePoint provisioning path for this workspace.

## Do Not Use
- Do not use `pwsh` / PowerShell 7 for tenant provisioning.
- Do not use modern `PnP.PowerShell` with `Connect-PnPOnline -Interactive` for this workspace.
- Do not use device code.
- Do not use ClientId, Entra app registration, certificate, service principal, Graph direct, or premium HTTP connector.
- Do not split login and provisioning into separate PowerShell processes.

## Required Runtime
- Shell: Windows PowerShell 5.1 (`powershell.exe`)
- Module: `SharePointPnPPowerShellOnline`
- Observed installed version: `3.29.2101.0`
- Auth command: `Connect-PnPOnline -Url <site> -UseWebLogin`
- Site URL for PnP scripts: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`

## Required Command Pattern
Login and the target SharePoint command must run in the same Windows PowerShell process:

```powershell
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
$env:PNPLEGACYMESSAGE = "false"
Remove-Module PnP.PowerShell,SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin
.\deploy\SP_Provisioning.ps1 -SiteUrl $siteUrl -SkipConnection
```

`-SkipConnection` is intentional: the script must reuse the authenticated legacy PnP context already opened in the same process.

## Evidence
- Previous project reference: `D:\VMs\Projetos\Copilot_Studio_VsCode\Gestao_Ferias_MVP_QA\relatorio_gate10c\01_schema\GATE_10C_STEP1_SCHEMA_BLOCKER.md`
- Current provisioning log: `.planning/comms/g1_legacy_pnp_provisioning_20260502_115923.log`
- Current verification log: `.planning/comms/g1_legacy_pnp_verify_20260502_120214.log`

## G1 Verification Result
- `Projetos`: 22 custom fields, views `Board RAG`, `Gallery`, `Todos`, 5 pilot items.
- `Status Diario`: 13 custom fields, view `Por Projeto`.
- `Riscos e Bloqueios`: 13 custom fields, view `Abertos`.
- `Decisoes do Board`: 14 custom fields, view `Pendentes`.

## Operational Note
`deploy/SP_Provisioning.ps1` is a provisioning script, not a repeat-safe migration. G1 is already provisioned and verified. Do not rerun it unless the tenant objects are intentionally cleaned up or the script is first made idempotent.
