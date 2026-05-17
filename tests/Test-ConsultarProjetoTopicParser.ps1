[CmdletBinding()]
param([string]$Path = "deploy\copilot\ConsultarProjeto_topic.yaml")

$ErrorActionPreference = "Stop"
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$yaml = Get-Content -LiteralPath $resolvedPath -Raw

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

$parseMatch = [regex]::Match(
    $yaml,
    "(?ms)^\s*-\s+kind:\s+SetVariable\s*\r?\n\s+id:\s+parse_project\s*\r?\n\s+variable:\s+Topic\.NomeProjeto\s*\r?\n\s+value:\s*=(?<value>.+?)(?=\r?\n\s*-\s+kind:|\z)"
)

$parseValue = if ($parseMatch.Success) { $parseMatch.Groups["value"].Value.Trim() } else { "" }
$commandKeyPattern = 'consultar\s+projeto\s*:\s*projeto\s*[:=]\s*(?<v>[^,\r\n]+)'
$commandPattern = 'consultar\s+projeto\s*:\s*(?<v>[^,\r\n]+)'
$commandKeyPatternIndex = $parseValue.IndexOf($commandKeyPattern, [System.StringComparison]::Ordinal)
$commandPatternIndex = $parseValue.IndexOf($commandPattern, [System.StringComparison]::Ordinal)
$parserPatterns = @(
    [regex]::Matches($parseValue, 'IsMatch\(Topic\.RawInput,\s*"(?<pattern>[^"]+)"') |
        ForEach-Object { $_.Groups["pattern"].Value }
)

Add-Check "Has parse_project assignment" $parseMatch.Success "ConsultarProjeto topic must assign Topic.NomeProjeto from raw input."
Add-Check "Parser reads raw activity text" ($yaml -match "Topic\.RawInput" -and $yaml -match "System\.Activity\.Text") "Parser must inspect the original STT utterance."
Add-Check "Parser exposes ordered IsMatch patterns" ($parserPatterns.Count -gt 0) "The test simulates parser behavior using IsMatch pattern order."
Add-Check "Nested projeto key parser exists" ($commandKeyPatternIndex -ge 0) "Expected parser pattern: $commandKeyPattern"
Add-Check "Consultar projeto fallback parser exists" ($commandPatternIndex -ge 0) "Expected fallback pattern: $commandPattern"
Add-Check "Nested projeto key parser runs before command fallback" (($commandKeyPatternIndex -ge 0) -and ($commandPatternIndex -ge 0) -and ($commandKeyPatternIndex -lt $commandPatternIndex)) "Input 'consultar projeto: projeto=...' must prefer the key-value value over the command tail."
Add-Check "Parser avoids bare ambiguous projeto key regex" (-not $parseValue.Contains('IsMatch(Topic.RawInput, "projeto\s*[:=]\s*')) "A bare projeto[:=] regex also matches the command prefix in 'consultar projeto: projeto=...'."

$inputText = "consultar projeto: projeto=Mobile App Corporativo"
$simulatedProjectName = $null
foreach ($pattern in $parserPatterns) {
    $match = [regex]::Match($inputText, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($match.Success) {
        $simulatedProjectName = $match.Groups["v"].Value.Trim()
        break
    }
}

Add-Check "Regression parses project name without key prefix" ($simulatedProjectName -eq "Mobile App Corporativo") "Parsed value was '$simulatedProjectName'."

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    topicPath = $resolvedPath
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10

if ($failed.Count -gt 0) {
    throw "ConsultarProjeto topic parser regression test failed: $($failed.name -join '; ')"
}
