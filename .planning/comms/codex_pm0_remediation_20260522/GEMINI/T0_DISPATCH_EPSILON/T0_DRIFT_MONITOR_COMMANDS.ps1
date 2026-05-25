<#
.SYNOPSIS
    T0_DRIFT_MONITOR_COMMANDS.ps1 - Pre-staged drift monitoring commands for Track E.
.DESCRIPTION
    This script contains and documents the exact PowerShell command sequences to execute
    the post-publish drift monitoring (T+5min, T+1h, T+6h) for STT PMO 3.16.
    
    It is prepared by Gemini Flash #2 Sub G2A.
.PARAMETER PublishUtc
    The UTC timestamp of the Gate 4B Publish event (e.g., "2026-05-23T18:15:23Z").
    If not provided, the script will prompt or use a placeholder.
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$PublishUtc
)

$ErrorActionPreference = "Stop"

# Base configuration
$RepoRoot = "D:\VMs\Projetos\STT_Project_Management"
$DriftMonitorScript = Join-Path $RepoRoot "tests\Test-Aq08PublishDriftMonitor.ps1"

# Target placeholder if PublishUtc is not yet provided
if ([string]::IsNullOrEmpty($PublishUtc)) {
    $PublishUtc = "<<TODO_BACKFILL: publish_utc_timestamp (depends on: T3_publish)>>"
}

# Format the folder name safe for Windows paths
$FolderSuffix = $PublishUtc.Replace(":", "").Replace("-", "").Replace("Z", "").Replace(" ", "_")
$BaseOutputDir = Join-Path $RepoRoot ".planning\comms\codex_pm0_remediation_20260522\drift_monitoring_post_3_16_$FolderSuffix"

Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "                STT PMO 3.16 DRIFT MONITORING COMMANDS" -ForegroundColor Cyan
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "Publish UTC:   $PublishUtc" -ForegroundColor Yellow
Write-Host "Output Dir:    $BaseOutputDir" -ForegroundColor Yellow
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "To execute the full T+5min, T+1h, T+6h drift monitor sequence, run:" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------"
Write-Host "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$DriftMonitorScript`" `"
    -PublishUtc `"$PublishUtc`" `"
    -OutputDir `"$BaseOutputDir`"" -ForegroundColor White
Write-Host "-------------------------------------------------------------------------"
Write-Host ""
Write-Host "Expected Output Paths for Individual Passes:" -ForegroundColor Green
Write-Host "  T+5min:  $(Join-Path $BaseOutputDir 'T+5min')"
Write-Host "  T+1h:    $(Join-Path $BaseOutputDir 'T+1h')"
Write-Host "  T+6h:    $(Join-Path $BaseOutputDir 'T+6h')"
Write-Host ""
Write-Host "Expected Output Artifacts:" -ForegroundColor Green
Write-Host "  Verification Report: $(Join-Path $BaseOutputDir 'T+5min\aq08_post_remediation_reverify_report.json')"
Write-Host "  Drift Decision:      $(Join-Path $BaseOutputDir 'DRIFT_DECISION.md')"
Write-Host "=========================================================================" -ForegroundColor Cyan
