<#
.SYNOPSIS
    Remove orphaned pmo_AssistentePMO (non-Clean) ghost bot components
    from the solution source package and bots directory.
    Keeps only pmo_AssistentePMO_Clean components.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SolutionRoot
)

$ErrorActionPreference = "Stop"
$resolvedRoot = (Resolve-Path -LiteralPath $SolutionRoot).Path

# --- botcomponents cleanup ---
$botcompRoot = Join-Path $resolvedRoot "botcomponents"
if (Test-Path $botcompRoot) {
    $ghostDirs = Get-ChildItem -LiteralPath $botcompRoot -Directory |
        Where-Object { $_.Name -match '^pmo_AssistentePMO\.' -and $_.Name -notmatch '^pmo_AssistentePMO_Clean\.' }
    
    Write-Host "`n=== Ghost botcomponent directories to remove ===" -ForegroundColor Yellow
    foreach ($dir in $ghostDirs) {
        Write-Host "  REMOVING: $($dir.Name)" -ForegroundColor Red
        Remove-Item -LiteralPath $dir.FullName -Recurse -Force
    }
    Write-Host "Removed $($ghostDirs.Count) ghost botcomponent directories.`n" -ForegroundColor Green
} else {
    Write-Host "No botcomponents directory found at $botcompRoot" -ForegroundColor Yellow
}

# --- bots cleanup ---
$botsRoot = Join-Path $resolvedRoot "bots"
if (Test-Path $botsRoot) {
    $ghostBots = Get-ChildItem -LiteralPath $botsRoot -Directory |
        Where-Object { $_.Name -eq 'pmo_AssistentePMO' }
    
    Write-Host "=== Ghost bot directories to remove ===" -ForegroundColor Yellow
    foreach ($dir in $ghostBots) {
        Write-Host "  REMOVING: $($dir.Name)" -ForegroundColor Red
        Remove-Item -LiteralPath $dir.FullName -Recurse -Force
    }
    Write-Host "Removed $($ghostBots.Count) ghost bot directories.`n" -ForegroundColor Green
} else {
    Write-Host "No bots directory found at $botsRoot" -ForegroundColor Yellow
}

# --- Verify remaining ---
Write-Host "=== Remaining botcomponents ===" -ForegroundColor Cyan
if (Test-Path $botcompRoot) {
    Get-ChildItem -LiteralPath $botcompRoot -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
}
Write-Host "`n=== Remaining bots ===" -ForegroundColor Cyan
if (Test-Path $botsRoot) {
    Get-ChildItem -LiteralPath $botsRoot -Directory | ForEach-Object { Write-Host "  $($_.Name)" }
}

Write-Host "`nGhost cleanup complete." -ForegroundColor Green
