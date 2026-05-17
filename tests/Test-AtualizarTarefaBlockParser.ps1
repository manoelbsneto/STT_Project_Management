[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_atualizartarefa_block_parser_" + [guid]::NewGuid().ToString("N"))
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

function Get-ParserPattern {
    param(
        [string]$Yaml,
        [string]$SetVariableId,
        [int]$PatternIndex = 0
    )

    $block = [regex]::Match(
        $Yaml,
        "(?ms)^\s+- kind:\s+SetVariable\s*\r?\n\s+id:\s+$([regex]::Escape($SetVariableId))\b.*?(?=^\s+- kind:|\z)"
    ).Value

    if ([string]::IsNullOrWhiteSpace($block)) {
        return ""
    }

    $patterns = @([regex]::Matches($block, 'IsMatch\(Topic\.WorkingInput,\s*"(?<pattern>[^"]+)"') |
        ForEach-Object { $_.Groups["pattern"].Value })

    if ($patterns.Count -le $PatternIndex) {
        return ""
    }

    return $patterns[$PatternIndex]
}

function Get-ParserMatchValue {
    param(
        [string]$Yaml,
        [string]$SetVariableId,
        [string]$InputText,
        [string]$Group = "v",
        [int[]]$PatternIndexes = @(1)
    )

    foreach ($index in $PatternIndexes) {
        $pattern = Get-ParserPattern -Yaml $Yaml -SetVariableId $SetVariableId -PatternIndex $index
        if ([string]::IsNullOrWhiteSpace($pattern)) {
            continue
        }

        $match = [regex]::Match($InputText, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        if ($match.Success) {
            return $match.Groups[$Group].Value.Trim()
        }
    }

    return ""
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)

    $topicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.AtualizarTarefa\data"
    $yaml = if (Test-Path -LiteralPath $topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }

    Add-Check "AtualizarTarefa topic exists" (Test-Path -LiteralPath $topicPath) "Expected pmo_AssistentePMO_V2.topic.AtualizarTarefa/data."
    Add-Check "Captures original user text" ($yaml -match "id:\s+capture_raw_input" -and $yaml -match "value:\s*=System\.Activity\.Text") "Topic must inspect original one-shot text."
    Add-Check "Collects free-text payload before numeric ID prompt" (
        ($yaml.IndexOf("id: ask_update_payload") -ge 0) -and
        ($yaml.IndexOf("id: ask_taskid") -ge 0) -and
        ($yaml.IndexOf("id: ask_update_payload") -lt $yaml.IndexOf("id: ask_taskid"))
    ) "A pasted multiline/comma block must be accepted before falling back to NumberPrebuiltEntity."
    Add-Check "Update payload uses StringPrebuiltEntity" (
        [regex]::Match($yaml, "(?ms)id:\s+ask_update_payload\b.*?entity:\s+StringPrebuiltEntity").Success
    ) "Block input must not use NumberPrebuiltEntity."

    $newlineInput = "15`nem andamento`n2`nmbenicios@minsait.com`n21/05/2026`nmedia`nsim"
    $commaInput = "15, em andamento, 2, mbenicios@minsait.com, 21/05/2026, media, sim"
    $missingDateInput = "15, em andamento, 2, mbenicios@minsait.com, media, sim"

    $positionalParsers = @(
        [ordered]@{ id = "parse_taskid_payload"; group = "v"; expected = "15"; patternIndex = 1 },
        [ordered]@{ id = "parse_status"; group = "v"; expected = "em andamento"; patternIndex = 1 },
        [ordered]@{ id = "parse_horas_realizadas"; group = "v"; expected = "2"; patternIndex = 1 },
        [ordered]@{ id = "parse_responsavel"; group = "v"; expected = "mbenicios@minsait.com"; patternIndex = 1 },
        [ordered]@{ id = "parse_datafim"; group = "v"; expected = "21/05/2026"; patternIndex = 1 },
        [ordered]@{ id = "parse_prioridade"; group = "v"; expected = "media"; patternIndex = 1 },
        [ordered]@{ id = "parse_confirmar"; group = "v"; expected = "sim"; patternIndex = 1 }
    )

    foreach ($parser in $positionalParsers) {
        $pattern = Get-ParserPattern -Yaml $yaml -SetVariableId $parser.id -PatternIndex $parser.patternIndex
        $newlineActual = if ($pattern) { ([regex]::Match($newlineInput, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Groups[$parser.group].Value.Trim() } else { "" }
        $commaActual = if ($pattern) { ([regex]::Match($commaInput, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Groups[$parser.group].Value.Trim() } else { "" }

        Add-Check "Parser $($parser.id) handles newline block" ($newlineActual -eq $parser.expected) "Expected '$($parser.expected)', got '$newlineActual'. Pattern: $pattern"
        Add-Check "Parser $($parser.id) handles comma block" ($commaActual -eq $parser.expected) "Expected '$($parser.expected)', got '$commaActual'. Pattern: $pattern"
    }

    $missingDateDataFim = Get-ParserMatchValue -Yaml $yaml -SetVariableId "parse_datafim" -InputText $missingDateInput -PatternIndexes @(1)
    $missingDatePrioridade = Get-ParserMatchValue -Yaml $yaml -SetVariableId "parse_prioridade" -InputText $missingDateInput -PatternIndexes @(1, 2)
    $missingDateConfirmar = Get-ParserMatchValue -Yaml $yaml -SetVariableId "parse_confirmar" -InputText $missingDateInput -PatternIndexes @(1, 2, 3, 4)

    Add-Check "Parser does not shift priority into missing date" ([string]::IsNullOrWhiteSpace($missingDateDataFim)) "Expected blank DataFim for omitted date, got '$missingDateDataFim'."
    Add-Check "Parser reads priority when date is omitted" ($missingDatePrioridade -eq "media") "Expected priority 'media', got '$missingDatePrioridade'."
    Add-Check "Parser reads confirmation when date is omitted" ($missingDateConfirmar -eq "sim") "Expected confirmation 'sim', got '$missingDateConfirmar'."

    Add-Check "TaskID question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_taskid" "Topic.TaskID" "ask_taskid") "Parsed task ID must not be overwritten by a follow-up question."
    Add-Check "Status question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_status" "Topic.Status" "ask_status") "Parsed status must not be overwritten by a follow-up question."
    Add-Check "Horas question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_horas_realizadas" "Topic.HorasRealizadas" "ask_horas_realizadas") "Parsed hours must not be overwritten by a follow-up question."
    Add-Check "Responsavel question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_responsavel" "Topic.Responsavel" "ask_responsavel") "Parsed responsible must not be overwritten by a follow-up question."
    Add-Check "DataFim question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_datafim" "Topic.DataFim" "ask_datafim") "Parsed due date must not be overwritten by a follow-up question."
    Add-Check "Prioridade question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_prioridade" "Topic.Prioridade" "ask_prioridade") "Parsed priority must not be overwritten by a follow-up question."
    Add-Check "Confirm question only asks when blank" (Test-ConditionalQuestion $yaml "ask_missing_confirmar" "Topic.Confirmar" "confirm_atualizar") "Parsed confirmation must not be overwritten by a follow-up question."
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
    throw "AtualizarTarefa block parser test failed: $($failed.name -join '; ')"
}
