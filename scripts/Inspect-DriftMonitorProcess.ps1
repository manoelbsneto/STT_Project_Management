[CmdletBinding()]
param(
    [int]$ProcessId = 44496
)

$ErrorActionPreference = 'Stop'

Write-Host "=== Drift Monitor Process Inspection (PID=$ProcessId) ===" -ForegroundColor Cyan
$p = Get-CimInstance -ClassName Win32_Process -Filter "ProcessId=$ProcessId" -ErrorAction SilentlyContinue
if (-not $p) {
    Write-Host "PROCESS_NOT_FOUND" -ForegroundColor Red
    exit 1
}

Write-Host "ProcessId       : $($p.ProcessId)"
Write-Host "Name            : $($p.Name)"
Write-Host "ParentPID       : $($p.ParentProcessId)"
Write-Host "CreationDate    : $($p.CreationDate)"
Write-Host "ThreadCount     : $($p.ThreadCount)"
Write-Host "KernelModeTime  : $($p.KernelModeTime)"
Write-Host "UserModeTime    : $($p.UserModeTime)"
Write-Host "CommandLine     : $($p.CommandLine)"

$cur = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
if ($cur) {
    Write-Host ""
    Write-Host "Get-Process snapshot:" -ForegroundColor Cyan
    Write-Host "  WS(MB)         : $([math]::Round($cur.WorkingSet64/1MB,2))"
    Write-Host "  CPU            : $($cur.CPU)"
    Write-Host "  Responding     : $($cur.Responding)"
}

$now = [DateTimeOffset]::Now
$gateBrt = [DateTimeOffset]::Parse('2026-05-22T14:23:24-03:00')
$delta = $gateBrt - $now
Write-Host ""
Write-Host "Now (BRT)               : $now"
Write-Host "Expected T+6h gate (BRT): $gateBrt"
Write-Host "Time remaining          : $delta"
