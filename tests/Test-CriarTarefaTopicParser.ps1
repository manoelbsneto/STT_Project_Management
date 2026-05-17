[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_criartarefa_parser_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

function Test-ConditionalQuestion {
    param(
        [string]$Yaml,
        [string]$ConditionId,
        [string]$Variable,
        [string]$QuestionId
    )

    $block = [regex]::Match(
        $Yaml,
        "(?ms)^\s{4}- kind:\s+ConditionGroup\s*\r?\n\s+id:\s+$([regex]::Escape($ConditionId))\b.*?(?=^\s{4}- kind:|\z)"
    ).Value

    return (-not [string]::IsNullOrWhiteSpace($block)) -and
        ($block -match "condition:\s*=IsBlank\($([regex]::Escape($Variable))\)") -and
        ($block -match "id:\s+$([regex]::Escape($QuestionId))\b") -and
        ($block -match "variable:\s+$([regex]::Escape($Variable))\b")
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)

    $topicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarTarefa\data"
    $yaml = if (Test-Path -LiteralPath $topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }

    Add-Check "CriarTarefa topic exists" (Test-Path -LiteralPath $topicPath) "Expected pmo_AssistentePMO_V2.topic.CriarTarefa/data."
    Add-Check "Parses project inline" (($yaml -match "id:\s+parse_projeto") -and ($yaml -match "variable:\s+Topic\.NomeProjeto")) "NomeProjeto inline parser required."
    Add-Check "Parses title inline" (($yaml -match "id:\s+parse_titulo") -and ($yaml -match "variable:\s+Topic\.Titulo")) "Titulo inline parser required."
    Add-Check "Parses responsavel inline" (($yaml -match "id:\s+parse_responsavel") -and ($yaml -match "variable:\s+Topic\.Responsavel") -and ($yaml -match "respons.vel\\s\*\[:=\]")) "Responsavel inline parser must accept accented and unaccented label."
    Add-Check "Parses prazo inline" (($yaml -match "id:\s+parse_prazo") -and ($yaml -match "variable:\s+Topic\.Prazo") -and ($yaml -match "prazo\\s\*\[:=\]")) "Prazo inline parser required for one-shot command."
    Add-Check "Parses horas inline as number" (($yaml -match "id:\s+parse_horas") -and ($yaml -match "variable:\s+Topic\.Horas") -and ($yaml -match "Value\(Substitute")) "Horas inline parser must coerce text to number for action input."
    Add-Check "Parses prioridade inline" (($yaml -match "id:\s+parse_prioridade") -and ($yaml -match "variable:\s+Topic\.Prioridade") -and ($yaml -match "prioridade\\s\*\[:=\]")) "Prioridade inline parser required."
    Add-Check "One-shot fields are parsed before questions" (
        ($yaml.IndexOf("id: parse_prioridade") -ge 0) -and
        ($yaml.IndexOf("id: ask_responsavel") -ge 0) -and
        ($yaml.IndexOf("id: parse_prioridade") -lt $yaml.IndexOf("id: ask_responsavel"))
    ) "All parsers must run before collection questions so Copilot can skip already-populated variables."
    Add-Check "NomeProjeto question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_nome_projeto" "Topic.NomeProjeto" "ask_nome_projeto") "Parsed project name must not be overwritten by a follow-up question."
    Add-Check "Titulo question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_titulo" "Topic.Titulo" "ask_titulo") "Parsed task title must not be overwritten by a follow-up question."
    Add-Check "Responsavel question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_responsavel" "Topic.Responsavel" "ask_responsavel") "Parsed responsible UPN must not be overwritten by a follow-up question."
    Add-Check "Prazo question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_prazo" "Topic.Prazo" "ask_prazo") "Parsed task prazo must not be overwritten by a follow-up question."
    Add-Check "Horas question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_horas" "Topic.Horas" "ask_horas") "Parsed estimated hours must not be overwritten by a follow-up question."
    Add-Check "Prioridade question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_prioridade" "Topic.Prioridade" "ask_prioridade") "Parsed priority must not be overwritten by a follow-up question."
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = (Resolve-Path -LiteralPath $tempRoot).Path
        $resolvedBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
        if ($resolvedTemp.StartsWith($resolvedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
        }
    }
}

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    packagePath = $resolvedPackagePath
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10
if ($failed.Count -gt 0) {
    throw "CriarTarefa parser test failed: $($failed.name -join '; ')"
}
