$ErrorActionPreference = "Stop"
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
$env:PNPLEGACYMESSAGE = "false"
Remove-Module PnP.PowerShell,SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin
$fields = Get-PnPField -List "Status Diario" | Select-Object Title,InternalName,TypeAsString,Required
$fields | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath 'D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\CODEX2\RCA_3_19_ATUALIZARSTATUS\evidence\20260524_054740_Codex2Lead_status_diario_field_schema.raw.json' -Encoding UTF8
Disconnect-PnPOnline -ErrorAction SilentlyContinue
