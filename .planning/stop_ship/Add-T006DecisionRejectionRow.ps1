[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$DecisionID = "DEC-OPUS-REJECT-20260506",
    [string]$ProjectID = "PRJ-2127A0E4",
    [string]$UserEmail = "mbenicios@minsait.com"
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

Import-Module SharePointPnPPowerShellOnline -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$query = @"
<View>
  <Query>
    <Where>
      <Eq><FieldRef Name="DecisionID"/><Value Type="Text">$DecisionID</Value></Eq>
    </Where>
  </Query>
</View>
"@

$existing = Get-PnPListItem -List "Decisoes do Board" -PageSize 100 -Query $query | Select-Object -First 1
if ($existing) {
    [pscustomobject]@{
        Action = "AlreadyExists"
        Id = $existing.Id
        Title = $existing["Title"]
        DecisionID = $existing["DecisionID"]
        ProjectID = $existing["ProjectID"]
        StatusDecisao = $existing["StatusDecisao"]
        Resposta = $existing["Resposta"]
    } | Format-Table -AutoSize
    return
}

$values = @{
    Title = "Teste Opus decisao rejeicao 20260506"
    DecisionID = $DecisionID
    ProjectID = $ProjectID
    Descricao = "Teste Opus decisao rejeicao T006"
    Solicitante = $UserEmail
    Aprovador = $UserEmail
    Prazo = [datetime]"2026-06-30"
    StatusDecisao = "Pendente"
    Impacto = "Medio"
}

$item = Add-PnPListItem -List "Decisoes do Board" -Values $values
[pscustomobject]@{
    Action = "Created"
    Id = $item.Id
    Title = $item["Title"]
    DecisionID = $item["DecisionID"]
    ProjectID = $item["ProjectID"]
    StatusDecisao = $item["StatusDecisao"]
    Resposta = $item["Resposta"]
} | Format-Table -AutoSize
