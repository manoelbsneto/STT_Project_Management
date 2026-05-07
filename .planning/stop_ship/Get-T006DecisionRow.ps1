[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [int]$ItemId = 1
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

Import-Module SharePointPnPPowerShellOnline -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$item = Get-PnPListItem -List "Decisoes do Board" -Id $ItemId
[pscustomobject]@{
    Id = $item.Id
    Title = $item["Title"]
    DecisionID = $item["DecisionID"]
    ProjectID = $item["ProjectID"]
    StatusDecisao = $item["StatusDecisao"]
    Resposta = $item["Resposta"]
    DataResposta = $item["DataResposta"]
    ResponseSource = $item["ResponseSource"]
    CardVersion = $item["CardVersion"]
    Justificativa = $item["Justificativa"]
    ApproverUPN = $item["ApproverUPN"]
} | ConvertTo-Json -Depth 5
