[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_routing_instructions_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)
    $gptPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.gpt.default\data"
    $fallbackPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.LowConfidence\data"
    $projectTopicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarProjeto\data"
    $taskTopicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarTarefa\data"

    Add-Check "Default GPT instructions exist" (Test-Path -LiteralPath $gptPath) "Expected pmo_AssistentePMO_V2.gpt.default/data."
    Add-Check "LowConfidence fallback exists" (Test-Path -LiteralPath $fallbackPath) "Expected pmo_AssistentePMO_V2.topic.LowConfidence/data."
    Add-Check "CriarProjeto topic exists" (Test-Path -LiteralPath $projectTopicPath) "Expected pmo_AssistentePMO_V2.topic.CriarProjeto/data."
    Add-Check "CriarTarefa topic exists" (Test-Path -LiteralPath $taskTopicPath) "Expected pmo_AssistentePMO_V2.topic.CriarTarefa/data."

    $gptText = if (Test-Path -LiteralPath $gptPath) { Get-Content -LiteralPath $gptPath -Raw } else { "" }
    $fallbackText = if (Test-Path -LiteralPath $fallbackPath) { Get-Content -LiteralPath $fallbackPath -Raw } else { "" }
    $projectText = if (Test-Path -LiteralPath $projectTopicPath) { Get-Content -LiteralPath $projectTopicPath -Raw } else { "" }
    $taskText = if (Test-Path -LiteralPath $taskTopicPath) { Get-Content -LiteralPath $taskTopicPath -Raw } else { "" }

    Add-Check "Project creation routes to CriarProjeto" ($gptText -match 'criar projeto.*topico CriarProjeto') "One-shot project requests must not be sent to CriarTarefa."
    Add-Check "Task creation routes to CriarTarefa" ($gptText -match 'criar tarefa.*topico CriarTarefa') "Task requests still need the task topic."
    Add-Check "No combined project/task instruction to CriarTarefa" ($gptText -notmatch 'criar tarefa ou projeto.*CriarTarefa') "This exact instruction caused observed one-shot project misrouting."
    Add-Check "Fallback project creation routes to CriarProjeto" (($fallbackText -match 'id:\s*detect_criar_projeto') -and ($fallbackText -match 'dialog:\s*pmo_AssistentePMO_V2\.topic\.CriarProjeto')) "Unknown project-create phrases must redirect to CriarProjeto."
    Add-Check "Fallback task creation routes to CriarTarefa" (($fallbackText -match 'id:\s*detect_criar_tarefa') -and ($fallbackText -match 'dialog:\s*pmo_AssistentePMO_V2\.topic\.CriarTarefa')) "Unknown task-create phrases must still redirect to CriarTarefa."
    $taskFallbackBlock = [regex]::Match($fallbackText, '(?ms)- id:\s*detect_criar_tarefa.*?(?=\n\s*- id:|\n\s*elseActions:)').Value
    Add-Check "Fallback task route excludes project phrases" (($taskFallbackBlock -notmatch 'criar\\s\+projeto') -and ($taskFallbackBlock -notmatch 'novo\\s\+projeto') -and ($taskFallbackBlock -notmatch 'abrir\\s\+projeto') -and ($taskFallbackBlock -notmatch 'registrar\\s\+projeto')) "Project creation must not be captured by detect_criar_tarefa."
    Add-Check "Project topic advertises project phrases" (($projectText -match 'criar projeto') -and ($projectText -match 'novo projeto') -and ($projectText -match 'registrar projeto')) "CriarProjeto needs direct trigger coverage."
    Add-Check "Task topic does not advertise project creation phrase" ($taskText -notmatch 'criar projeto') "Task topic must not compete for project creation utterances."
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
    throw "Copilot routing instructions test failed: $($failed.name -join '; ')"
}
