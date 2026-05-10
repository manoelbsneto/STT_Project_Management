[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [Parameter(Mandatory)]
    [string]$CandidatesCsv,
    [string]$Reason = "Marked Deleted=Yes before official PROD QA baseline. Current candidates classified by Project Owner as non-real test/trash data on 2026-05-10.",
    [string]$DeletedByUPN = $env:USERNAME,
    [switch]$SkipConnection
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $CandidatesCsv)) {
    throw "Candidates CSV not found: $CandidatesCsv"
}

if (-not $SkipConnection) {
    Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
}

if (-not (Get-Module SharePointPnPPowerShellOnline)) {
    Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
}

if (-not $SkipConnection) {
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
}

$candidates = Import-Csv -LiteralPath $CandidatesCsv
if (-not $candidates) {
    Write-Host "No candidates found in CSV."
    return
}

$log = [System.Collections.Generic.List[object]]::new()
$now = Get-Date

foreach ($candidate in $candidates) {
    if ([string]::IsNullOrWhiteSpace($candidate.ListName) -or [string]::IsNullOrWhiteSpace($candidate.ItemId)) {
        continue
    }

    $values = @{
        Deleted = $true
        DeletedAt = $now
        DeletedReason = $Reason
        DeletedByUPN = $DeletedByUPN
    }

    $target = "$($candidate.ListName) item $($candidate.ItemId) ($($candidate.Title))"
    if ($PSCmdlet.ShouldProcess($target, "Set Deleted=Yes")) {
        Set-PnPListItem -List $candidate.ListName -Identity ([int]$candidate.ItemId) -Values $values -SystemUpdate | Out-Null
        $status = "MarkedDeleted"
    }
    else {
        $status = "WhatIf"
    }

    $log.Add([pscustomobject]@{
        ListName = $candidate.ListName
        ItemId = $candidate.ItemId
        Title = $candidate.Title
        MatchedPattern = $candidate.MatchedPattern
        Status = $status
        DeletedAt = $now.ToString("s")
        DeletedByUPN = $DeletedByUPN
    }) | Out-Null
}

$outDir = Split-Path -Parent $CandidatesCsv
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = Join-Path $outDir "sharepoint_deleted_flag_log_$stamp.csv"
$summaryPath = Join-Path $outDir "sharepoint_deleted_flag_log_$stamp.md"
$log | Export-Csv -LiteralPath $logPath -NoTypeInformation -Encoding UTF8

$summaryLines = [System.Collections.Generic.List[string]]::new()
$summaryLines.Add("# SharePoint Logical Delete Log")
$summaryLines.Add("")
$summaryTimestamp = (Get-Date).ToString("o")
$summaryLines.Add("- Timestamp: $summaryTimestamp")
$summaryLines.Add("- Candidates CSV: $CandidatesCsv")
$summaryLines.Add("- Processed: $($log.Count)")
$summaryLines.Add("- Logical delete: true")
$summaryLines.Add("- Destructive delete: false")
$summaryLines.Add("")
$summaryLines.Add("| List | Item ID | Title | Pattern | Status | DeletedByUPN |")
$summaryLines.Add("|---|---:|---|---|---|---|")
foreach ($row in $log) {
    $summaryLines.Add("| $($row.ListName) | $($row.ItemId) | $($row.Title) | $($row.MatchedPattern) | $($row.Status) | $($row.DeletedByUPN) |")
}
Set-Content -LiteralPath $summaryPath -Value $summaryLines -Encoding UTF8

$resolvedLogPath = if (Test-Path -LiteralPath $logPath) { (Resolve-Path -LiteralPath $logPath).Path } else { $logPath }
$resolvedSummaryPath = if (Test-Path -LiteralPath $summaryPath) { (Resolve-Path -LiteralPath $summaryPath).Path } else { $summaryPath }

[ordered]@{
    candidatesCsv = (Resolve-Path -LiteralPath $CandidatesCsv).Path
    processed = $log.Count
    logPath = $resolvedLogPath
    summaryPath = $resolvedSummaryPath
    destructiveDelete = $false
    logicalDelete = $true
} | ConvertTo-Json -Depth 5
