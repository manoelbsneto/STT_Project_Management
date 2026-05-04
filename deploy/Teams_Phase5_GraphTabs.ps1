[CmdletBinding()]
param(
    [string]$TeamId = "96c5b0c4-46cc-46cd-8695-50451db74994",
    [string]$TenantId = "7808e005-1489-4374-954b-d3b08f193920",
    [string]$ChannelName,
    [string]$EvidenceDir = ".planning\comms"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$evidenceRoot = Join-Path $repoRoot $EvidenceDir
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

$graphChannelPath = Join-Path $evidenceRoot "g5_graph_channel_$timestamp.json"
$graphTabsBeforePath = Join-Path $evidenceRoot "g5_graph_tabs_before_$timestamp.json"
$graphTabsAfterPath = Join-Path $evidenceRoot "g5_graph_tabs_after_$timestamp.json"
$summaryPath = Join-Path $evidenceRoot "g5_graph_tabs_summary_$timestamp.json"
$errorPath = Join-Path $evidenceRoot "g5_graph_tabs_error_$timestamp.txt"

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 50)
    [System.IO.File]::WriteAllText($Path, ($Data | ConvertTo-Json -Depth $Depth), [System.Text.UTF8Encoding]::new($false))
}

try {
    $portfolioTabName = "Portf$([char]0x00F3)lio Executivo"
    $criticalTabName = "Projetos Cr$([char]0x00ED)ticos"
    $decisionsTabName = "Decis$([char]0x00F5)es Pendentes"
    if (-not $ChannelName) {
        $ChannelName = "Projetos_Tranforma$([char]0x00E7)$([char]0x00E3)o_Digital"
    }

    $viewEvidence = Get-ChildItem -Path $evidenceRoot -Filter "g5_sharepoint_views_*.json" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $viewEvidence) {
        throw "No g5_sharepoint_views_*.json evidence file found. Run Teams_Phase5_Tabs.ps1 through the SharePoint view step first."
    }

    $views = Get-Content -LiteralPath $viewEvidence.FullName -Raw | ConvertFrom-Json
    $boardUrl = ($views | Where-Object { $_.title -eq "Board RAG" } | Select-Object -First 1).absoluteUrl
    $criticalUrl = ($views | Where-Object { $_.title -eq $criticalTabName } | Select-Object -First 1).absoluteUrl
    $pendingUrl = ($views | Where-Object { $_.title -eq "Pendentes" } | Select-Object -First 1).absoluteUrl
    if (-not $boardUrl -or -not $criticalUrl -or -not $pendingUrl) {
        throw "Missing one or more SharePoint view URLs in $($viewEvidence.FullName)"
    }

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Connect-MgGraph -TenantId $TenantId -Scopes "Team.ReadBasic.All","Channel.ReadBasic.All","TeamsTab.ReadWriteForTeam","TeamsTab.ReadWrite.All","Group.ReadWrite.All" -UseDeviceCode -NoWelcome

    $channels = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels"
    $targetChannel = @($channels.value | Where-Object { $_.displayName -eq $ChannelName -or $_.id -eq $ChannelName } | Select-Object -First 1)
    if (-not $targetChannel) {
        throw "Channel '$ChannelName' not found. Available: $((@($channels.value).displayName) -join ', ')"
    }
    Save-Json -Data $targetChannel -Path $graphChannelPath

    $tabsBefore = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels/$($targetChannel.id)/tabs?`$expand=teamsApp"
    Save-Json -Data $tabsBefore -Path $graphTabsBeforePath

    $sharePointTeamsAppId = "2a527703-1f6f-4559-a332-d8a7d288cd88"
    $desiredTabs = @(
        [pscustomobject]@{ displayName = $portfolioTabName; contentUrl = $boardUrl; entityId = "pmo-portfolio-executivo" },
        [pscustomobject]@{ displayName = $criticalTabName; contentUrl = $criticalUrl; entityId = "pmo-projetos-criticos" },
        [pscustomobject]@{ displayName = $decisionsTabName; contentUrl = $pendingUrl; entityId = "pmo-decisoes-pendentes" }
    )

    $tabResults = foreach ($desired in $desiredTabs) {
        $existing = @($tabsBefore.value | Where-Object { $_.displayName -eq $desired.displayName } | Select-Object -First 1)
        if ($existing) {
            [pscustomobject]@{
                displayName = $desired.displayName
                action = "exists"
                id = $existing.id
                contentUrl = $existing.configuration.contentUrl
            }
            continue
        }

        $body = [ordered]@{
            displayName = $desired.displayName
            "teamsApp@odata.bind" = "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/$sharePointTeamsAppId"
            configuration = [ordered]@{
                entityId = $desired.entityId
                contentUrl = $desired.contentUrl
                websiteUrl = $desired.contentUrl
                removeUrl = $null
            }
        }

        $created = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels/$($targetChannel.id)/tabs" -ContentType "application/json" -Body ($body | ConvertTo-Json -Depth 10)
        [pscustomobject]@{
            displayName = $desired.displayName
            action = "created"
            id = $created.id
            contentUrl = $desired.contentUrl
        }
    }

    $tabsAfter = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels/$($targetChannel.id)/tabs?`$expand=teamsApp"
    Save-Json -Data $tabsAfter -Path $graphTabsAfterPath

    $expected = @($portfolioTabName, $criticalTabName, $decisionsTabName)
    $present = @($tabsAfter.value | Where-Object { $expected -contains $_.displayName })
    $status = if ($present.Count -ge 3) { "PASS" } else { "PARTIAL" }

    Save-Json -Data ([pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        status = $status
        teamId = $TeamId
        channel = $targetChannel
        viewEvidence = $viewEvidence.FullName
        tabResults = $tabResults
        expectedTabsPresent = $present.displayName
        formsFallback = "skipped: optional, no approved Forms provisioning API/auth route in this tenant session"
        evidence = [pscustomobject]@{
            channel = $graphChannelPath
            tabsBefore = $graphTabsBeforePath
            tabsAfter = $graphTabsAfterPath
            summary = $summaryPath
        }
    }) -Path $summaryPath

    Write-Host "G5 Graph tab provisioning status: $status"
    Write-Host "Summary: $summaryPath"
}
catch {
    $_ | Out-String | Set-Content -LiteralPath $errorPath -Encoding UTF8
    Write-Error $_
    exit 1
}
