[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TemplatePath
)

$ErrorActionPreference = "Stop"

$resolvedTemplatePath = (Resolve-Path -LiteralPath $TemplatePath).Path
$yaml = Get-Content -LiteralPath $resolvedTemplatePath -Raw

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

function Get-ComponentBlock {
    param(
        [string]$Yaml,
        [string]$DisplayName
    )

    $displayMatch = [regex]::Match($Yaml, "(?m)^\s{4}displayName: $([regex]::Escape($DisplayName))\s*$")
    if (-not $displayMatch.Success) {
        return ""
    }

    $startMarker = "  - kind: DialogComponent"
    $start = $Yaml.LastIndexOf($startMarker, $displayMatch.Index, [System.StringComparison]::Ordinal)
    if ($start -lt 0) {
        return ""
    }

    $next = $Yaml.IndexOf("`n$startMarker", $displayMatch.Index + $displayMatch.Length, [System.StringComparison]::Ordinal)
    if ($next -lt 0) {
        $next = $Yaml.Length
    }

    $Yaml.Substring($start, $next - $start).TrimEnd()
}

$criarTarefa = Get-ComponentBlock -Yaml $yaml -DisplayName "CriarTarefa"
$atualizarStatus = Get-ComponentBlock -Yaml $yaml -DisplayName "AtualizarStatus"
$consultarPortfolio = Get-ComponentBlock -Yaml $yaml -DisplayName "ConsultarPortfolio"
$consultarProjeto = Get-ComponentBlock -Yaml $yaml -DisplayName "ConsultarProjeto"
$registrarRisco = Get-ComponentBlock -Yaml $yaml -DisplayName "RegistrarRisco"
$registrarBloqueio = Get-ComponentBlock -Yaml $yaml -DisplayName "RegistrarBloqueio"
$pedirDecisao = Get-ComponentBlock -Yaml $yaml -DisplayName "PedirDecisao"

Add-Check "GAP-A2 YAML has no dead 42d9abd1 binding" ($yaml -notmatch "42d9abd1-8849-f111-bec7-7ced8d955c6c") "Dead V2 flow binding must not be referenced by active bot components."
Add-Check "GAP-A2 YAML has no FlowNotFound 71f62da4 binding" ($yaml -notmatch "71f62da4-9748-f111-bec7-6045bdf42cae") "Prior FlowNotFound ID must not be referenced by active bot components."
Add-Check "GAP-A2 YAML references V3 flow ID" ($yaml -match "3104124d-364a-f111-bec7-7ced8d955c6c") "CriarTarefa must be rebound to PMO_PA_CriarTarefa_V3 through Copilot Studio UI."

Add-Check "GAP-B1 ConsultarPortfolio is not a stub" ($consultarPortfolio -notmatch "portfolio_stub") "Portfolio topic must call a real flow and return live portfolio counts."
Add-Check "GAP-B2 ConsultarProjeto is not a stub" ($consultarProjeto -notmatch "project_stub") "Project query topic must call a real flow and return live project details."
Add-Check "GAP-B3 RegistrarRisco is not confirm-only" ($registrarRisco -notmatch "risk_confirmed_msg") "Risk topic must create a Riscos e Bloqueios item after confirmation."
Add-Check "GAP-B4 RegistrarBloqueio is not confirm-only" ($registrarBloqueio -notmatch "block_confirmed_msg") "Block topic must create a Riscos e Bloqueios item after confirmation."
Add-Check "GAP-B5 PedirDecisao is not confirm-only" ($pedirDecisao -notmatch "decision_confirmed_msg") "Decision topic must create a Decisoes do Board item after confirmation."

Add-Check "GAP-B6 AtualizarStatus captures raw STT input" ($atualizarStatus -match "System\.Activity\.Text|Topic\.RawInput") "STT design must parse one long dictation before asking only missing fields."
Add-Check "GAP-B6 AtualizarStatus does not ask all fields sequentially" ($atualizarStatus -notmatch "ask_project[\s\S]*ask_rag[\s\S]*ask_percentual[\s\S]*ask_resumo[\s\S]*ask_risco[\s\S]*ask_proxima") "Sequential field-by-field questions are not STT-compatible."

Add-Check "GAP-B7 no BooleanPrebuiltEntity confirmations" ($yaml -notmatch "BooleanPrebuiltEntity") "Confirmations must use StringPrebuiltEntity plus sim/s/yes/confirmo checks."
Add-Check "GAP-B7 confirmation accepts sim" ($yaml -match 'Lower\(Topic\.Confirmar\)\s*=\s*"sim"') "STT confirmations must accept pt-BR sim."
Add-Check "GAP-B7 confirmation accepts confirmo" ($yaml -match 'Lower\(Topic\.Confirmar\)\s*=\s*"confirmo"') "STT confirmations must accept confirmo."

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    templatePath = $resolvedTemplatePath
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10

if ($failed.Count -gt 0) {
    throw "Copilot stop-ship GAP test failed: $($failed.name -join '; ')"
}
