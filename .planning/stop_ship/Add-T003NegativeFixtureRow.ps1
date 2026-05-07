[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$ProjectID = "PRJ-NO-MATCH"
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

Import-Module SharePointPnPPowerShellOnline -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$title = "Teste Projeto Inexistente"
$escapedTitle = $title.Replace("'", "''")
$query = @"
<View>
  <Query>
    <Where>
      <And>
        <Eq><FieldRef Name="ProjectID"/><Value Type="Text">$ProjectID</Value></Eq>
        <Eq><FieldRef Name="Title"/><Value Type="Text">$escapedTitle</Value></Eq>
      </And>
    </Where>
  </Query>
</View>
"@

$existing = Get-PnPListItem -List "Tarefas" -PageSize 100 -Query $query | Select-Object -First 1
if ($existing) {
    [pscustomobject]@{
        Action = "AlreadyExists"
        Id = $existing.Id
        Title = $existing["Title"]
        ProjectID = $existing["ProjectID"]
        Status = $existing["Status"]
        Prioridade = $existing["Prioridade"]
    } | Format-Table -AutoSize
    return
}

$values = @{
    Title = $title
    ProjectID = $ProjectID
    Status = "Pendente"
    Prioridade = "Alta"
    Responsavel = "mbenicios@minsait.com"
    DataFim = [datetime]"2026-06-30"
    HorasEstimadas = 1
    HorasRealizadas = 0
}

$item = Add-PnPListItem -List "Tarefas" -Values $values
[pscustomobject]@{
    Action = "Created"
    Id = $item.Id
    Title = $item["Title"]
    ProjectID = $item["ProjectID"]
    Status = $item["Status"]
    Prioridade = $item["Prioridade"]
} | Format-Table -AutoSize
