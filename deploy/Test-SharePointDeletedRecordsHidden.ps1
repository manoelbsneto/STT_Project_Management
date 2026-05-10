[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [Parameter(Mandatory)]
    [string]$CandidatesCsv,
    [string]$OutputDir = ".planning\cleanup",
    [switch]$SkipConnect
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

if (-not (Test-Path -LiteralPath $CandidatesCsv)) {
    throw "Candidates CSV not found: $CandidatesCsv"
}

$outputRoot = Join-Path $repoRoot $OutputDir
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvPath = Join-Path $outputRoot "deleted_records_hidden_validation_$timestamp.csv"
$summaryPath = Join-Path $outputRoot "deleted_records_hidden_validation_$timestamp.md"

Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop

if (-not $SkipConnect) {
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
}

$candidates = Import-Csv -LiteralPath $CandidatesCsv
$results = [System.Collections.Generic.List[object]]::new()

foreach ($candidate in $candidates) {
    if ([string]::IsNullOrWhiteSpace($candidate.ListName) -or [string]::IsNullOrWhiteSpace($candidate.ItemId)) {
        continue
    }

    $item = Get-PnPListItem -List $candidate.ListName -Id ([int]$candidate.ItemId) -Fields "Deleted", "DeletedAt", "DeletedReason", "DeletedByUPN" -ErrorAction Stop
    $isDeleted = [bool]$item["Deleted"]

    $visibleFilter = "ID eq $($candidate.ItemId) and Deleted ne 1"
    $visibleRows = @(Get-PnPListItem -List $candidate.ListName -Query "<View><Query><Where><And><Eq><FieldRef Name='ID'/><Value Type='Counter'>$($candidate.ItemId)</Value></Eq><Neq><FieldRef Name='Deleted'/><Value Type='Boolean'>1</Value></Neq></And></Where></Query></View>" -ErrorAction Stop)

    $results.Add([pscustomobject]@{
        ListName = $candidate.ListName
        ItemId = $candidate.ItemId
        Title = $candidate.Title
        Deleted = $isDeleted
        DeletedAtPresent = -not [string]::IsNullOrWhiteSpace([string]$item["DeletedAt"])
        DeletedReasonPresent = -not [string]::IsNullOrWhiteSpace([string]$item["DeletedReason"])
        DeletedByUPN = [string]$item["DeletedByUPN"]
        HiddenByDefaultFilter = ($visibleRows.Count -eq 0)
        DefaultFilter = $visibleFilter
    })
}

$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

$failures = @($results | Where-Object { -not $_.Deleted -or -not $_.HiddenByDefaultFilter })
$lines = [System.Collections.Generic.List[string]]::new()
$validationTimestamp = (Get-Date).ToString("o")
$lines.Add("# Deleted Records Hidden Validation")
$lines.Add("")
$lines.Add("- Timestamp: $validationTimestamp")
$lines.Add("- Site: $SiteUrl")
$lines.Add("- Candidates CSV: $CandidatesCsv")
$lines.Add("- Checked: $($results.Count)")
$lines.Add("- Failures: $($failures.Count)")
$lines.Add("- Default filter: Deleted ne 1")
$lines.Add("")
$lines.Add("| List | Item ID | Title | Deleted | Hidden by default filter | DeletedByUPN |")
$lines.Add("|---|---:|---|---:|---:|---|")
foreach ($row in $results) {
    $lines.Add("| $($row.ListName) | $($row.ItemId) | $($row.Title) | $($row.Deleted) | $($row.HiddenByDefaultFilter) | $($row.DeletedByUPN) |")
}

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

Write-Host "Deleted hidden validation CSV: $csvPath" -ForegroundColor Green
Write-Host "Deleted hidden validation summary: $summaryPath" -ForegroundColor Green

if ($failures.Count -gt 0) {
    throw "Deleted hidden validation failed for $($failures.Count) records."
}
