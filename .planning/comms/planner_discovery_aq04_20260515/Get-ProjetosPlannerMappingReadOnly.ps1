param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$OutputDir = ".planning\comms\planner_discovery_aq04_20260515"
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$fields = @(
    "ID",
    "Title",
    "ProjectID",
    "NomeProjeto",
    "Ativo",
    "Deleted",
    "PlannerGroupId",
    "PlannerPlanId",
    "LinkPlanner",
    "PlannerLastSyncAt",
    "PlannerSyncStatus",
    "TarefasTotal",
    "TarefasAbertas",
    "TarefasConcluidas",
    "TarefasAtrasadas"
)

$items = Get-PnPListItem -List "Projetos" -PageSize 200 -Fields $fields

$rows = foreach ($item in $items) {
    $v = $item.FieldValues
    [pscustomobject]@{
        ID = $v["ID"]
        Title = $v["Title"]
        ProjectID = $v["ProjectID"]
        NomeProjeto = $v["NomeProjeto"]
        Ativo = $v["Ativo"]
        Deleted = $v["Deleted"]
        PlannerGroupId = $v["PlannerGroupId"]
        PlannerPlanId = $v["PlannerPlanId"]
        LinkPlanner = if ($v["LinkPlanner"]) { $v["LinkPlanner"].Url } else { $null }
        PlannerLastSyncAt = $v["PlannerLastSyncAt"]
        PlannerSyncStatus = if ($v["PlannerSyncStatus"]) { $v["PlannerSyncStatus"] } else { $null }
        TarefasTotal = $v["TarefasTotal"]
        TarefasAbertas = $v["TarefasAbertas"]
        TarefasConcluidas = $v["TarefasConcluidas"]
        TarefasAtrasadas = $v["TarefasAtrasadas"]
    }
}

$withPlanner = @($rows | Where-Object { $_.PlannerGroupId -or $_.PlannerPlanId -or $_.LinkPlanner })

$rows |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath (Join-Path $OutputDir "sharepoint_projetos_planner_mapping.json") -Encoding UTF8

$rows |
    Export-Csv -LiteralPath (Join-Path $OutputDir "sharepoint_projetos_planner_mapping.csv") -NoTypeInformation -Encoding UTF8

$withPlanner |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath (Join-Path $OutputDir "sharepoint_projetos_with_planner_values.json") -Encoding UTF8

$summary = [pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    siteUrl = $SiteUrl
    list = "Projetos"
    itemCount = @($rows).Count
    itemsWithPlannerValues = $withPlanner.Count
    outputDir = (Resolve-Path $OutputDir).Path
    accessType = "SharePoint read-only via legacy PnP"
}

$summary |
    ConvertTo-Json -Depth 5 |
    Set-Content -LiteralPath (Join-Path $OutputDir "sharepoint_read_summary.json") -Encoding UTF8

$summary
