[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$TeamId = "96c5b0c4-46cc-46cd-8695-50451db74994",
    [string]$ChannelName,
    [string]$EvidenceDir = ".planning\comms",
    [switch]$SkipConnection,
    [switch]$SkipGraphConnection
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$evidenceRoot = Join-Path $repoRoot $EvidenceDir
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

$summaryPath = Join-Path $evidenceRoot "g5_teams_tabs_summary_$timestamp.json"
$viewEvidencePath = Join-Path $evidenceRoot "g5_sharepoint_views_$timestamp.json"
$tabEvidencePath = Join-Path $evidenceRoot "g5_teams_tabs_$timestamp.json"

$portfolioTabName = "Portf$([char]0x00F3)lio Executivo"
$criticalViewTitle = "Projetos Cr$([char]0x00ED)ticos"
$decisionsTabName = "Decis$([char]0x00F5)es Pendentes"
if (-not $ChannelName) {
    $ChannelName = "Projetos_Tranforma$([char]0x00E7)$([char]0x00E3)o_Digital"
}

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 50)
    [System.IO.File]::WriteAllText($Path, ($Data | ConvertTo-Json -Depth $Depth), [System.Text.UTF8Encoding]::new($false))
}

function Get-ViewUrl {
    param([string]$ListTitle, [string]$ViewTitle)
    $view = Get-PnPView -List $ListTitle -Identity $ViewTitle -ErrorAction Stop
    if ($view.ServerRelativeUrl) {
        return [System.Uri]::new([System.Uri]$SiteUrl, $view.ServerRelativeUrl).AbsoluteUri
    }

    $encodedList = [uri]::EscapeDataString($ListTitle).Replace("%20", "%20")
    $encodedView = [uri]::EscapeDataString($ViewTitle).Replace("%20", "%20")
    return "$SiteUrl/Lists/$encodedList/$encodedView.aspx"
}

function Ensure-View {
    param(
        [string]$ListTitle,
        [string]$ViewTitle,
        [string[]]$Fields,
        [string]$Query
    )

    $existing = Get-PnPView -List $ListTitle -ErrorAction Stop | Where-Object { $_.Title -eq $ViewTitle } | Select-Object -First 1
    if ($existing) {
        return [pscustomobject]@{
            list = $ListTitle
            title = $ViewTitle
            action = "exists"
            serverRelativeUrl = $existing.ServerRelativeUrl
        }
    }

    $view = Add-PnPView -List $ListTitle -Title $ViewTitle -Fields $Fields -Query $Query -RowLimit 100 -Paged -SetAsDefault:$false
    return [pscustomobject]@{
        list = $ListTitle
        title = $ViewTitle
        action = "created"
        serverRelativeUrl = $view.ServerRelativeUrl
    }
}

function Ensure-Tab {
    param(
        [string]$DisplayName,
        [string]$ContentUrl
    )

    $existing = Get-PnPTeamsTab -Team $TeamId -Channel $ChannelName -ByPassPermissionCheck -ErrorAction Stop |
        Where-Object { $_.DisplayName -eq $DisplayName } |
        Select-Object -First 1

    if ($existing) {
        return [pscustomobject]@{
            displayName = $DisplayName
            action = "exists"
            id = $existing.Id
            contentUrl = $existing.Configuration.ContentUrl
            webUrl = $existing.WebUrl
        }
    }

    $tab = Add-PnPTeamsTab -Team $TeamId -Channel $ChannelName -DisplayName $DisplayName -Type SharePointPageAndList -ContentUrl $ContentUrl -ByPassPermissionCheck -ErrorAction Stop
    return [pscustomobject]@{
        displayName = $DisplayName
        action = "created"
        id = $tab.Id
        contentUrl = $ContentUrl
        webUrl = $tab.WebUrl
    }
}

$env:PNPLEGACYMESSAGE = "false"
Remove-Module PnP.PowerShell,SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop

if (-not $SkipConnection) {
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin -WarningAction SilentlyContinue
}

$connectedWeb = Get-PnPWeb -ErrorAction Stop

$viewResults = @()
$mojibakeView = Get-PnPView -List "Projetos" -ErrorAction Stop | Where-Object { $_.Title -eq "Projetos CrAticos" } | Select-Object -First 1
if ($mojibakeView) {
    Remove-PnPView -List "Projetos" -Identity $mojibakeView.Id -Force -ErrorAction Stop
    $viewResults += [pscustomobject]@{
        list = "Projetos"
        title = "Projetos CrAticos"
        action = "removed_mojibake_retry_artifact"
        serverRelativeUrl = $mojibakeView.ServerRelativeUrl
    }
}

$viewResults += Ensure-View -ListTitle "Projetos" -ViewTitle $criticalViewTitle `
    -Fields @("ProjectID", "NomeProjeto", "PM", "Sponsor", "StatusRAG", "Percentual", "UltimaAtualizacao") `
    -Query "<Where><Eq><FieldRef Name='StatusRAG'/><Value Type='Choice'>Vermelho</Value></Eq></Where>"

$requiredViews = @(
    [pscustomobject]@{ ListTitle = "Projetos"; ViewTitle = "Board RAG" },
    [pscustomobject]@{ ListTitle = "Projetos"; ViewTitle = $criticalViewTitle },
    [pscustomobject]@{ ListTitle = "Decisoes do Board"; ViewTitle = "Pendentes" }
)

$resolvedViews = foreach ($item in $requiredViews) {
    $view = Get-PnPView -List $item.ListTitle -Identity $item.ViewTitle -ErrorAction Stop
    [pscustomobject]@{
        list = $item.ListTitle
        title = $item.ViewTitle
        serverRelativeUrl = $view.ServerRelativeUrl
        absoluteUrl = Get-ViewUrl -ListTitle $item.ListTitle -ViewTitle $item.ViewTitle
    }
}
Save-Json -Data $resolvedViews -Path $viewEvidencePath

if (-not $SkipGraphConnection) {
    Connect-PnPOnline -Graph -LaunchBrowser -WarningAction SilentlyContinue
}

$channels = Get-PnPTeamsChannel -Team $TeamId -ByPassPermissionCheck -ErrorAction Stop
$targetChannel = $channels | Where-Object { $_.DisplayName -eq $ChannelName -or $_.Id -eq $ChannelName } | Select-Object -First 1
if (-not $targetChannel) {
    throw "Teams channel '$ChannelName' was not found in team $TeamId. Available: $($channels.DisplayName -join ', ')"
}

$tabResults = @()
$tabResults += Ensure-Tab -DisplayName $portfolioTabName -ContentUrl (($resolvedViews | Where-Object { $_.title -eq "Board RAG" }).absoluteUrl)
$tabResults += Ensure-Tab -DisplayName $criticalViewTitle -ContentUrl (($resolvedViews | Where-Object { $_.title -eq $criticalViewTitle }).absoluteUrl)
$tabResults += Ensure-Tab -DisplayName $decisionsTabName -ContentUrl (($resolvedViews | Where-Object { $_.title -eq "Pendentes" }).absoluteUrl)

$allTabs = Get-PnPTeamsTab -Team $TeamId -Channel $ChannelName -ByPassPermissionCheck -ErrorAction Stop |
    Select-Object Id, DisplayName, WebUrl, @{Name="ContentUrl"; Expression = { $_.Configuration.ContentUrl }}, @{Name="WebsiteUrl"; Expression = { $_.Configuration.WebsiteUrl }}
Save-Json -Data $allTabs -Path $tabEvidencePath

$expected = @($portfolioTabName, $criticalViewTitle, $decisionsTabName)
$presentExpected = @($allTabs | Where-Object { $expected -contains $_.DisplayName })
$status = if ($presentExpected.Count -ge 3) { "PASS" } else { "PARTIAL" }

$summary = [pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    status = $status
    siteUrl = $SiteUrl
    connectedWeb = $connectedWeb.Url
    teamId = $TeamId
    channelName = $ChannelName
    channelId = $targetChannel.Id
    viewResults = $viewResults
    resolvedViews = $resolvedViews
    tabResults = $tabResults
    expectedTabsPresent = $presentExpected.DisplayName
    formsFallback = "skipped: Microsoft Forms creation is optional and not exposed by the approved PnP route"
    evidence = [pscustomobject]@{
        views = $viewEvidencePath
        tabs = $tabEvidencePath
        summary = $summaryPath
    }
}
Save-Json -Data $summary -Path $summaryPath

Write-Host "G5 Teams tabs status: $status"
Write-Host "Summary: $summaryPath"
