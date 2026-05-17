[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_criarprojeto_parser_" + [guid]::NewGuid().ToString("N"))
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
    $topicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarProjeto\data"
    $yaml = if (Test-Path -LiteralPath $topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }

    $parseMatch = [regex]::Match(
        $yaml,
        "(?ms)^\s*-\s+kind:\s+SetVariable\s*\r?\n\s+id:\s+parse_nome_projeto\s*\r?\n\s+variable:\s+Topic\.NomeProjeto\s*\r?\n\s+value:\s*=(?<value>.+?)(?=\r?\n\s*-\s+kind:|\z)"
    )
    $parseValue = if ($parseMatch.Success) { $parseMatch.Groups["value"].Value.Trim() } else { "" }
    $parserPatterns = @(
        [regex]::Matches($parseValue, 'IsMatch\(Topic\.RawInput,\s*"(?<pattern>[^"]+)"') |
            ForEach-Object { $_.Groups["pattern"].Value }
    )

    Add-Check "CriarProjeto topic exists" (Test-Path -LiteralPath $topicPath) "Expected pmo_AssistentePMO_V2.topic.CriarProjeto/data."
    Add-Check "Has parse_nome_projeto assignment" $parseMatch.Success "CriarProjeto must parse project name from raw text before asking."
    Add-Check "Parser reads raw activity text" ($yaml -match "Topic\.RawInput" -and $yaml -match "System\.Activity\.Text") "Parser must inspect original typed/STT utterance."
    Add-Check "Parser exposes ordered IsMatch patterns" ($parserPatterns.Count -ge 4) "Expected key-value and command-tail patterns."
    Add-Check "Nested NomeProjeto key parser exists" ($parseValue.Contains('criar\s+projeto\s*:\s*nome\s*_?\s*projeto\s*[:=]\s*(?<v>[^,\r\n]+)')) "Input 'criar projeto: NomeProjeto=...' must not return the literal key."
    Add-Check "Command tail fallback parser exists" ($parseValue.Contains('criar\s+projeto\s*:\s*(?<v>[^,\r\n]+)')) "Input 'criar projeto: Projeto Alpha' must still work."
    Add-Check "Project key parser is boundary scoped" ($parseValue -match '\(\?:\^\|\[,;\\r\\n\]\)\\s\*projeto') "Bare projeto key parser must not capture the command prefix."

    $cases = @(
        [ordered]@{ name = "Nested NomeProjeto"; input = "criar projeto: NomeProjeto=Projeto Alpha"; expected = "Projeto Alpha" },
        [ordered]@{ name = "Command tail"; input = "criar projeto: Projeto Alpha"; expected = "Projeto Alpha" },
        [ordered]@{ name = "Spaced key"; input = "Nome Projeto: Projeto Alpha"; expected = "Projeto Alpha" },
        [ordered]@{ name = "Generic project key"; input = "projeto=Projeto Alpha"; expected = "Projeto Alpha" },
        [ordered]@{ name = "Multiline"; input = "Criar projeto:`r`nNomeProjeto: Projeto Alpha`r`nPM: mbenicios@minsait.com"; expected = "Projeto Alpha" }
    )

    foreach ($case in $cases) {
        $actual = $null
        foreach ($pattern in $parserPatterns) {
            $match = [regex]::Match($case.input, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            if ($match.Success) {
                $actual = $match.Groups["v"].Value.Trim()
                break
            }
        }
        Add-Check "Regression parses $($case.name)" ($actual -eq $case.expected) "Input '$($case.input)' parsed '$actual'."
    }

    Add-Check "Parses PM inline" ($yaml -match "id:\s+parse_pm" -and $yaml -match "variable:\s+Topic\.PM") "PM inline parser required for one-shot command."
    Add-Check "Parses Prazo inline" ($yaml -match "id:\s+parse_prazo" -and $yaml -match "variable:\s+Topic\.Prazo") "Prazo inline parser required for one-shot command."
    Add-Check "Parses Prioridade inline" ($yaml -match "id:\s+parse_prioridade" -and $yaml -match "variable:\s+Topic\.Prioridade") "Prioridade inline parser required for one-shot command."
    Add-Check "NomeProjeto question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_nome_projeto" "Topic.NomeProjeto" "ask_nome_projeto") "Parsed project name must not be overwritten by a follow-up question."
    Add-Check "PM question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_pm" "Topic.PM" "ask_pm") "Parsed PM must not be overwritten by a follow-up question."
    Add-Check "Prazo question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_prazo" "Topic.Prazo" "ask_prazo") "Parsed prazo must not be overwritten by a follow-up question."
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
    throw "CriarProjeto topic parser regression test failed: $($failed.name -join '; ')"
}
