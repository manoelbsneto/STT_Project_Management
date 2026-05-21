[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'

$base = '.planning\comms\aq09_smoke_runbook_20260520\_validator_self_test\opus_47_independent_run'
$script = 'tests\Test-Aq09SmokeEvidence.ps1'

New-Item -ItemType Directory -Force -Path $base | Out-Null

$cases = @(
    @{ name = 'negative_real';  evid = '.planning\comms\aq09_smoke_runbook_20260520\evidence' },
    @{ name = 'positive';       evid = '.planning\comms\aq09_smoke_runbook_20260520\_validator_self_test\v2\positive' },
    @{ name = 'xpia_trigger';   evid = '.planning\comms\aq09_smoke_runbook_20260520\_validator_self_test\v2\xpia_trigger' }
)

foreach ($c in $cases) {
    $report   = Join-Path $base ($c.name + '_report.json')
    $outFile  = Join-Path $base ($c.name + '_stdout.txt')
    $errFile  = Join-Path $base ($c.name + '_stderr.txt')
    $exitFile = Join-Path $base ($c.name + '_exit.txt')

    $p = Start-Process -FilePath 'powershell.exe' `
        -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File', $script, '-EvidenceDir', $c.evid, '-ReportPath', $report) `
        -NoNewWindow -PassThru -Wait `
        -RedirectStandardOutput $outFile `
        -RedirectStandardError  $errFile

    $p.ExitCode | Out-File -FilePath $exitFile -Encoding ascii
    Write-Host ('[' + $c.name + '] exit=' + $p.ExitCode)
}
