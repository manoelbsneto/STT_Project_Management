$ErrorActionPreference = "Stop"
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
$env:PNPLEGACYMESSAGE = "false"
Remove-Module PnP.PowerShell,SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin
$fields = Get-PnPField -List "Status Diario" | Select-Object Title,InternalName,TypeAsString,Required
$fields | ConvertTo-Json -Depth 5
