[CmdletBinding()]
param(
    [string]$DriftRoot = ".planning\comms\aq08_topic_routing_verification_20260520\post_publish_verify\drift_monitoring_20260522_0816"
)

$ErrorActionPreference = 'Stop'

$topics = 'AtualizarStatus','AtualizarTarefa','ConsultarPortfolio','CriarTarefa','ListarTarefas'

Write-Host "=== Topic Data Drift T+5min -> T+1h ===" -ForegroundColor Cyan
Write-Host "Drift root: $DriftRoot" -ForegroundColor DarkGray
Write-Host ""

$rows = foreach ($t in $topics) {
    $a = Get-Item "$DriftRoot\T+5min\topic_data\$t.botcomponent.data.txt" -ErrorAction SilentlyContinue
    $b = Get-Item "$DriftRoot\T+1h\topic_data\$t.botcomponent.data.txt" -ErrorAction SilentlyContinue
    if (-not $a -or -not $b) {
        Write-Warning "Missing file for topic $t"
        continue
    }
    $delta = $b.Length - $a.Length
    $pct = if ($a.Length -gt 0) { [math]::Round(($delta / $a.Length) * 100, 1) } else { 0 }
    [pscustomobject]@{
        Topic = $t
        T5min_Bytes = $a.Length
        T1h_Bytes = $b.Length
        Delta_Bytes = $delta
        Pct_Change = "$pct%"
    }
}

$rows | Format-Table -AutoSize

Write-Host ""
Write-Host "=== Per-topic file existence and SHA256 ===" -ForegroundColor Cyan
foreach ($t in $topics) {
    $aPath = "$DriftRoot\T+5min\topic_data\$t.botcomponent.data.txt"
    $bPath = "$DriftRoot\T+1h\topic_data\$t.botcomponent.data.txt"
    if ((Test-Path -LiteralPath $aPath) -and (Test-Path -LiteralPath $bPath)) {
        $aHash = (Get-FileHash -LiteralPath $aPath -Algorithm SHA256).Hash
        $bHash = (Get-FileHash -LiteralPath $bPath -Algorithm SHA256).Hash
        $changed = if ($aHash -ne $bHash) { 'CHANGED' } else { 'STABLE' }
        Write-Host ("  {0,-22} {1,-7}  |  T+5min={2}  T+1h={3}" -f $t, $changed, $aHash.Substring(0,16), $bHash.Substring(0,16))
    }
}

Write-Host ""
Write-Host "=== Per-topic head 8 lines diff ===" -ForegroundColor Cyan
foreach ($t in $topics) {
    $aPath = "$DriftRoot\T+5min\topic_data\$t.botcomponent.data.txt"
    $bPath = "$DriftRoot\T+1h\topic_data\$t.botcomponent.data.txt"
    if ((Test-Path -LiteralPath $aPath) -and (Test-Path -LiteralPath $bPath)) {
        $aHead = (Get-Content -LiteralPath $aPath -TotalCount 8) -join "`n"
        $bHead = (Get-Content -LiteralPath $bPath -TotalCount 8) -join "`n"
        if ($aHead -ceq $bHead) {
            Write-Host ("  {0,-22} HEAD identical" -f $t)
        } else {
            Write-Host ("  {0,-22} HEAD DIFF (showing T+5min then T+1h)" -f $t) -ForegroundColor Yellow
            Write-Host "  ----- T+5min -----"
            Write-Host $aHead
            Write-Host "  ----- T+1h -----"
            Write-Host $bHead
        }
    }
}

Write-Host ""
Write-Host "=== Per-topic tail 8 lines diff ===" -ForegroundColor Cyan
foreach ($t in $topics) {
    $aPath = "$DriftRoot\T+5min\topic_data\$t.botcomponent.data.txt"
    $bPath = "$DriftRoot\T+1h\topic_data\$t.botcomponent.data.txt"
    if ((Test-Path -LiteralPath $aPath) -and (Test-Path -LiteralPath $bPath)) {
        $aTail = (Get-Content -LiteralPath $aPath -Tail 8) -join "`n"
        $bTail = (Get-Content -LiteralPath $bPath -Tail 8) -join "`n"
        if ($aTail -ceq $bTail) {
            Write-Host ("  {0,-22} TAIL identical" -f $t)
        } else {
            Write-Host ("  {0,-22} TAIL DIFF" -f $t) -ForegroundColor Yellow
            Write-Host "  ----- T+5min -----"
            Write-Host $aTail
            Write-Host "  ----- T+1h -----"
            Write-Host $bTail
        }
    }
}

Write-Host ""
Write-Host "=== Per-topic line count and unique displayName count ===" -ForegroundColor Cyan
foreach ($t in $topics) {
    $aPath = "$DriftRoot\T+5min\topic_data\$t.botcomponent.data.txt"
    $bPath = "$DriftRoot\T+1h\topic_data\$t.botcomponent.data.txt"
    if ((Test-Path -LiteralPath $aPath) -and (Test-Path -LiteralPath $bPath)) {
        $aLines = (Get-Content -LiteralPath $aPath).Count
        $bLines = (Get-Content -LiteralPath $bPath).Count
        $aDisplayNames = @(Select-String -LiteralPath $aPath -Pattern '^\s*displayName:').Count
        $bDisplayNames = @(Select-String -LiteralPath $bPath -Pattern '^\s*displayName:').Count
        Write-Host ("  {0,-22} T+5min: {1,5} lines, {2} displayName  |  T+1h: {3,5} lines, {4} displayName" -f $t, $aLines, $aDisplayNames, $bLines, $bDisplayNames)
    }
}
