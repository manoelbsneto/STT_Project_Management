[CmdletBinding()]
param()

$base = '.planning\comms\aq09_smoke_runbook_20260520\_validator_self_test\opus_47_independent_run'

foreach ($name in 'negative_real','positive','xpia_trigger') {
    $reportPath = Join-Path $base ($name + '_report.json')
    $report = Get-Content -Raw -LiteralPath $reportPath | ConvertFrom-Json
    Write-Host ('=== ' + $name + ' ===')
    Write-Host ('decision=' + $report.decision)
    Write-Host ('inScopeFailureCount=' + $report.inScopeFailureCount)
    foreach ($r in $report.results) {
        Write-Host ('  ' + $r.scope + ' ' + $r.id + ' -> ' + $r.status)
    }
}
