[CmdletBinding()]
param(
    [string]$Path = "docs\MANUAL_OPERACIONAL_PMO.md"
)

$ErrorActionPreference = "Stop"
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$manual = Get-Content -LiteralPath $resolvedPath -Raw

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

$requiredTopics = @(
    "CriarTarefa",
    "AtualizarStatus",
    "ConsultarPortfolio",
    "ConsultarProjeto",
    "RegistrarRisco",
    "RegistrarBloqueio",
    "PedirDecisao",
    "ListarTarefas"
)

foreach ($topic in $requiredTopics) {
    Add-Check "Manual covers $topic" ($manual -match [regex]::Escape($topic)) "$topic must be documented for PM operations."
}

Add-Check "Manual covers STT/voice use" ($manual -match 'voz|texto longo|Campo=valor') "Manual must explain long text / voice entry pattern."
Add-Check "Manual covers troubleshooting" ($manual -match '## Troubleshooting') "Manual must include troubleshooting section."
Add-Check "Manual covers evidence needed for release" ($manual -match 'Evidencia para release') "Manual must describe release evidence."
Add-Check "Manual is ASCII-only" (-not ($manual.ToCharArray() | Where-Object { [int][char]$_ -gt 127 } | Select-Object -First 1)) "Operational manual must remain ASCII-safe."

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    manualPath = $resolvedPath
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10

if ($failed.Count -gt 0) {
    throw "Operations manual test failed: $($failed.name -join '; ')"
}
