# Teams Phase 5 - Tab Creation with Interactive Auth (no device-code)
# Run with: pwsh -NoProfile -ExecutionPolicy Bypass -File .\deploy\Teams_Phase5_InteractiveTabs.ps1
[CmdletBinding()]
param(
    [string]$TeamId = "96c5b0c4-46cc-46cd-8695-50451db74994",
    [string]$TenantId = "7808e005-1489-4374-954b-d3b08f193920",
    [string]$EvidenceDir = ".planning\comms"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$evidenceRoot = Join-Path $repoRoot $EvidenceDir
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

$summaryPath = Join-Path $evidenceRoot "g5_interactive_tabs_summary_$timestamp.json"
$errorPath   = Join-Path $evidenceRoot "g5_interactive_tabs_error_$timestamp.txt"

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 50)
    [System.IO.File]::WriteAllText($Path, ($Data | ConvertTo-Json -Depth $Depth), [System.Text.UTF8Encoding]::new($false))
}

try {
    $portfolioTabName = "Portf$([char]0x00F3)lio Executivo"
    $criticalTabName  = "Projetos Cr$([char]0x00ED)ticos"
    $decisionsTabName = "Decis$([char]0x00F5)es Pendentes"
    $channelName      = "Projetos_Tranforma$([char]0x00E7)$([char]0x00E3)o_Digital"

    # --- Load view URLs from G5 evidence ---
    $viewEvidence = Get-ChildItem -Path $evidenceRoot -Filter "g5_sharepoint_views_*.json" |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $viewEvidence) {
        throw "No g5_sharepoint_views_*.json found. SP views must exist first."
    }
    $views = Get-Content -LiteralPath $viewEvidence.FullName -Raw | ConvertFrom-Json
    $boardUrl    = ($views | Where-Object { $_.title -eq "Board RAG" }    | Select-Object -First 1).absoluteUrl
    $criticalUrl = ($views | Where-Object { $_.title -eq $criticalTabName } | Select-Object -First 1).absoluteUrl
    $pendingUrl  = ($views | Where-Object { $_.title -eq "Pendentes" }    | Select-Object -First 1).absoluteUrl

    if (-not $boardUrl -or -not $criticalUrl -or -not $pendingUrl) {
        throw "Missing view URLs. Board=$boardUrl Critical=$criticalUrl Pending=$pendingUrl"
    }
    Write-Host "View URLs loaded OK" -ForegroundColor Green

    # --- Interactive Graph login (browser popup, NOT device-code) ---
    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Write-Host "Connecting to Graph... A browser window will open for login." -ForegroundColor Yellow
    Connect-MgGraph -TenantId $TenantId -Scopes "Team.ReadBasic.All","Channel.ReadBasic.All","TeamsTab.ReadWriteForTeam","TeamsTab.ReadWrite.All" -NoWelcome
    Write-Host "Graph connected OK" -ForegroundColor Green

    # --- Find channel ---
    $channels = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels"
    $ch = @($channels.value | Where-Object { $_.displayName -like "*Tranforma*" } | Select-Object -First 1)
    if (-not $ch) {
        $ch = @($channels.value | Select-Object -First 1)
        Write-Host "WARNING: Channel not found by name, using first channel: $($ch.displayName)" -ForegroundColor Yellow
    }
    $channelId = $ch.id
    Write-Host "Channel: $($ch.displayName) [$channelId]" -ForegroundColor Cyan

    # --- Create tabs ---
    $sharePointAppId = "2a527703-1f6f-4559-a332-d8a7d288cd88"
    $tabs = @(
        @{ name = $portfolioTabName; url = $boardUrl;    entity = "pmo-portfolio" },
        @{ name = $criticalTabName;  url = $criticalUrl; entity = "pmo-criticos" },
        @{ name = $decisionsTabName; url = $pendingUrl;  entity = "pmo-decisoes" }
    )

    $results = @()
    foreach ($tab in $tabs) {
        # Check if tab already exists
        $existing = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels/$channelId/tabs"
        $found = @($existing.value | Where-Object { $_.displayName -eq $tab.name })
        if ($found) {
            Write-Host "  Tab '$($tab.name)' already exists - skipping" -ForegroundColor Gray
            $results += [pscustomobject]@{ name=$tab.name; action="exists"; id=$found[0].id }
            continue
        }

        $body = @{
            displayName = $tab.name
            "teamsApp@odata.bind" = "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/$sharePointAppId"
            configuration = @{
                entityId   = $tab.entity
                contentUrl = $tab.url
                websiteUrl = $tab.url
                removeUrl  = $null
            }
        } | ConvertTo-Json -Depth 5

        $created = Invoke-MgGraphRequest -Method POST `
            -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels/$channelId/tabs" `
            -ContentType "application/json" -Body $body
        Write-Host "  Tab '$($tab.name)' CREATED [$($created.id)]" -ForegroundColor Green
        $results += [pscustomobject]@{ name=$tab.name; action="created"; id=$created.id }
    }

    # --- Verify ---
    $finalTabs = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/teams/$TeamId/channels/$channelId/tabs"
    $present = @($finalTabs.value | Where-Object { $tabs.name -contains $_.displayName })
    $status = if ($present.Count -ge 3) { "PASS" } else { "PARTIAL ($($present.Count)/3)" }

    Save-Json -Data ([pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        status    = $status
        teamId    = $TeamId
        channelId = $channelId
        channelName = $ch.displayName
        tabResults = $results
        totalTabsInChannel = $finalTabs.value.Count
    }) -Path $summaryPath

    Write-Host "`nG5 Status: $status" -ForegroundColor $(if ($status -eq "PASS") { "Green" } else { "Yellow" })
    Write-Host "Evidence: $summaryPath"
}
catch {
    $_ | Out-String | Set-Content -LiteralPath $errorPath -Encoding UTF8
    Write-Error $_
    exit 1
}
