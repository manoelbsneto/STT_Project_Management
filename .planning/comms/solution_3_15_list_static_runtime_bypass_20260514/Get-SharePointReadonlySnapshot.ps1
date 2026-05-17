[CmdletBinding()]
param(
    [string]$ProjectName = "QA Robust 20260513 F",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$OutPath = ".planning/comms/solution_3_15_list_static_runtime_bypass_20260514/sharepoint_readonly_runtime_snapshot_20260514.json"
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$projects = Get-PnPListItem -List "Projetos" -Fields "ID","Title","ProjectID","Ativo","Deleted" -PageSize 1000 |
    Where-Object { $_["Title"] -eq $ProjectName -or $_["ProjectID"] -eq $ProjectName }

$project = $projects | Select-Object -First 1
if (-not $project) {
    throw "Project not found: $ProjectName"
}

$projectId = $project["ProjectID"]
$tasks = Get-PnPListItem -List "Tarefas" -Fields "ID","Title","ProjectID","Status","Prioridade","Responsavel","DataFim","HorasRealizadas","HorasEstimadas","Deleted" -PageSize 1000 |
    Where-Object { $_["ProjectID"] -eq $projectId -and ($null -eq $_["Deleted"] -or $_["Deleted"] -ne $true) } |
    Sort-Object { [int]$_["ID"] }

$rows = @($tasks | ForEach-Object {
    [pscustomobject]@{
        ID = $_.Id
        Title = $_["Title"]
        ProjectID = $_["ProjectID"]
        Status = if ($_["Status"]) { $_["Status"].ToString() } else { $null }
        Prioridade = if ($_["Prioridade"]) { $_["Prioridade"].ToString() } else { $null }
        Responsavel = if ($_["Responsavel"]) { $_["Responsavel"].Email } else { $null }
        DataFim = if ($_["DataFim"]) { ([datetime]$_["DataFim"]).ToString("yyyy-MM-dd") } else { $null }
        HorasRealizadas = $_["HorasRealizadas"]
        HorasEstimadas = $_["HorasEstimadas"]
        Deleted = $_["Deleted"]
    }
})

$snapshot = [pscustomobject]@{
    capturedAt = (Get-Date).ToString("s")
    siteUrl = $SiteUrl
    project = [pscustomobject]@{
        ID = $project.Id
        Title = $project["Title"]
        ProjectID = $project["ProjectID"]
        Ativo = $project["Ativo"]
        Deleted = $project["Deleted"]
    }
    tasks = $rows
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutPath) | Out-Null
$snapshot | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutPath -Encoding UTF8
$snapshot | ConvertTo-Json -Depth 8
