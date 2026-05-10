[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$OutputDir = ".planning\cleanup",
    [string[]]$ListNames = @(
        "Projetos",
        "Tarefas",
        "Status Diario",
        "Riscos e Bloqueios",
        "Decisoes do Board"
    ),
    [string[]]$CandidatePatterns = @(
        "Teste",
        "Test",
        "Codex",
        "Opus",
        "Demo",
        "Mock",
        "Sample",
        "Fixture",
        "Clean Flow",
        "Direct",
        "Agente qual offer",
        "RISK-OPUS",
        "DEC-OPUS",
        "PRJ-OPUS",
        "PRJ-TEST",
        "PRJ-CODEX",
        "Ã",
        "�",
        "â",
        "ð",
        "Â"
    ),
    [switch]$IncludeAlreadyDeleted,
    [switch]$SkipConnect
)

$ErrorActionPreference = "Stop"

function Convert-FieldValueToText {
    param([object]$Value)

    if ($null -eq $Value) {
        return ""
    }

    if ($Value -is [System.Array]) {
        return (($Value | ForEach-Object { Convert-FieldValueToText $_ }) -join "; ")
    }

    if ($Value.PSObject.Properties.Name -contains "LookupValue") {
        return [string]$Value.LookupValue
    }

    if ($Value.PSObject.Properties.Name -contains "Email") {
        return [string]$Value.Email
    }

    if ($Value.PSObject.Properties.Name -contains "Label") {
        return [string]$Value.Label
    }

    [string]$Value
}

function Test-CandidateText {
    param(
        [string]$Text,
        [string[]]$Patterns
    )

    foreach ($pattern in $Patterns) {
        if ($Text -like "*$pattern*") {
            return $pattern
        }
    }

    return $null
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvPath = Join-Path $OutputDir "sharepoint_test_data_candidates_$stamp.csv"
$mdPath = Join-Path $OutputDir "sharepoint_test_data_candidates_$stamp.md"

if (-not $SkipConnect) {
    Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
    $pnp = Get-Module -ListAvailable -Name SharePointPnPPowerShellOnline | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $pnp) {
        throw "SharePointPnPPowerShellOnline module is required for live SharePoint discovery. Install/import it or run manual inventory."
    }

    Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
}

$results = [System.Collections.Generic.List[object]]::new()

foreach ($listName in $ListNames) {
    Write-Host "Scanning list: $listName"

    try {
        $items = Get-PnPListItem -List $listName -PageSize 500 -ErrorAction Stop
    }
    catch {
        $results.Add([pscustomobject]@{
            ListName = $listName
            ItemId = ""
            Title = ""
            MatchedPattern = "LIST_SCAN_FAILED"
            MatchedText = $_.Exception.Message
            Recommendation = "Investigate"
        }) | Out-Null
        continue
    }

    foreach ($item in $items) {
        $fieldValues = $item.FieldValues
        if (-not $IncludeAlreadyDeleted -and $fieldValues.ContainsKey("Deleted") -and $fieldValues["Deleted"] -eq $true) {
            continue
        }

        $parts = [System.Collections.Generic.List[string]]::new()

        foreach ($key in $fieldValues.Keys) {
            $valueText = Convert-FieldValueToText $fieldValues[$key]
            if (-not [string]::IsNullOrWhiteSpace($valueText)) {
                $parts.Add("$key=$valueText") | Out-Null
            }
        }

        $allText = $parts -join " | "
        $matchedPattern = Test-CandidateText -Text $allText -Patterns $CandidatePatterns

        if ($matchedPattern) {
            $title = ""
            foreach ($candidateTitleField in @("Title", "NomeProjeto", "ProjectID", "RiskID", "DecisionID")) {
                if ($fieldValues.ContainsKey($candidateTitleField)) {
                    $title = Convert-FieldValueToText $fieldValues[$candidateTitleField]
                    if (-not [string]::IsNullOrWhiteSpace($title)) {
                        break
                    }
                }
            }

            $results.Add([pscustomobject]@{
                ListName = $listName
                ItemId = $item.Id
                Title = $title
                MatchedPattern = $matchedPattern
                MatchedText = $allText
            Recommendation = "MarkDeletedYes"
            }) | Out-Null
        }
    }
}

$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

$summaryByList = $results | Group-Object ListName | Sort-Object Name
$summaryLines = [System.Collections.Generic.List[string]]::new()
$summaryLines.Add("# SharePoint Test Data Candidate Discovery") | Out-Null
$summaryLines.Add("") | Out-Null
$summaryLines.Add("Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")") | Out-Null
$summaryLines.Add("Site: $SiteUrl") | Out-Null
$summaryLines.Add("Mode: Read-only discovery. No items were deleted.") | Out-Null
$summaryLines.Add("") | Out-Null
$summaryLines.Add("## Summary") | Out-Null
$summaryLines.Add("") | Out-Null
$summaryLines.Add("| List | Candidate count |") | Out-Null
$summaryLines.Add("|---|---:|") | Out-Null
foreach ($group in $summaryByList) {
    $summaryLines.Add("| $($group.Name) | $($group.Count) |") | Out-Null
}
$summaryLines.Add("") | Out-Null
$summaryLines.Add("Total candidates: $($results.Count)") | Out-Null
$summaryLines.Add("") | Out-Null
$summaryLines.Add("## Files") | Out-Null
$summaryLines.Add("") | Out-Null
$summaryLines.Add("| Artifact | Path |") | Out-Null
$summaryLines.Add("|---|---|") | Out-Null
$summaryLines.Add("| CSV | $csvPath |") | Out-Null
$summaryLines.Add("| Markdown | $mdPath |") | Out-Null
$summaryLines.Add("") | Out-Null
$summaryLines.Add("## Next Step") | Out-Null
$summaryLines.Add("") | Out-Null
$summaryLines.Add("Mark approved candidates as Deleted=Yes with metadata. Keep a logical delete log.") | Out-Null

Set-Content -LiteralPath $mdPath -Value ($summaryLines -join [Environment]::NewLine) -Encoding UTF8

[ordered]@{
    siteUrl = $SiteUrl
    outputCsv = (Resolve-Path -LiteralPath $csvPath).Path
    outputMarkdown = (Resolve-Path -LiteralPath $mdPath).Path
    candidateCount = $results.Count
    listCount = $ListNames.Count
    destructiveActions = 0
} | ConvertTo-Json -Depth 5
