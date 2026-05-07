[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$RiskID = "RISK-OPUS-NEG-20260506",
    [string]$ProjectID = "PRJ-2127A0E4"
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

Import-Module SharePointPnPPowerShellOnline -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$query = @"
<View>
  <Query>
    <Where>
      <Eq><FieldRef Name="RiskID"/><Value Type="Text">$RiskID</Value></Eq>
    </Where>
  </Query>
</View>
"@

$existing = Get-PnPListItem -List "Riscos e Bloqueios" -PageSize 100 -Query $query | Select-Object -First 1
if ($existing) {
    [pscustomobject]@{
        Action = "AlreadyExists"
        Id = $existing.Id
        Title = $existing["Title"]
        RiskID = $existing["RiskID"]
        ProjectID = $existing["ProjectID"]
        Severidade = $existing["Severidade"]
        StatusRisco = $existing["StatusRisco"]
    } | Format-Table -AutoSize
    return
}

$values = @{
    Title = "Teste Opus risco nao critico 20260506"
    RiskID = $RiskID
    ProjectID = $ProjectID
    Tipo = "Risco"
    Severidade = "Alta"
    Impacto = "Medio"
    StatusRisco = "Aberto"
    Descricao = "Teste Opus risco nao critico"
    PlanoMitigacao = "Monitorar"
}

$item = Add-PnPListItem -List "Riscos e Bloqueios" -Values $values
[pscustomobject]@{
    Action = "Created"
    Id = $item.Id
    Title = $item["Title"]
    RiskID = $item["RiskID"]
    ProjectID = $item["ProjectID"]
    Severidade = $item["Severidade"]
    StatusRisco = $item["StatusRisco"]
} | Format-Table -AutoSize
