[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$ProjectID = "PRJ-2127A0E4"
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

Import-Module SharePointPnPPowerShellOnline -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$statusConcluida = "Conclu$([char]0x00ED)da"
$fixtures = @(
    @{
        Title = "Preparar proposta"
        ProjectID = $ProjectID
        Status = "Pendente"
        Prioridade = "Alta"
        Responsavel = "mbenicios@minsait.com"
        DataFim = [datetime]"2026-06-30"
        HorasEstimadas = 8
        HorasRealizadas = 0
    },
    @{
        Title = "Revisao tecnica"
        ProjectID = $ProjectID
        Status = $statusConcluida
        Prioridade = "Media"
        Responsavel = "mbenicios@minsait.com"
        DataFim = [datetime]"2026-06-29"
        HorasEstimadas = 4
        HorasRealizadas = 4
    }
)

$results = @()

foreach ($fixture in $fixtures) {
    $title = $fixture.Title.Replace("'", "''")
    $query = @"
<View>
  <Query>
    <Where>
      <And>
        <Eq><FieldRef Name="ProjectID"/><Value Type="Text">$ProjectID</Value></Eq>
        <Eq><FieldRef Name="Title"/><Value Type="Text">$title</Value></Eq>
      </And>
    </Where>
  </Query>
</View>
"@

    $existing = Get-PnPListItem -List "Tarefas" -PageSize 100 -Query $query | Select-Object -First 1
    if ($existing) {
        $results += [pscustomobject]@{
            Action = "AlreadyExists"
            Id = $existing.Id
            Title = $existing["Title"]
            ProjectID = $existing["ProjectID"]
            Status = $existing["Status"]
            Prioridade = $existing["Prioridade"]
        }
        continue
    }

    $item = Add-PnPListItem -List "Tarefas" -Values $fixture
    $results += [pscustomobject]@{
        Action = "Created"
        Id = $item.Id
        Title = $item["Title"]
        ProjectID = $item["ProjectID"]
        Status = $item["Status"]
        Prioridade = $item["Prioridade"]
    }
}

$results | Format-Table -AutoSize
