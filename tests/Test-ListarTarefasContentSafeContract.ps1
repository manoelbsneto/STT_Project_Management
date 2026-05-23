[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_listartarefas_safe_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)
    $workflowFiles = @(Get-ChildItem -LiteralPath (Join-Path $tempRoot "Workflows") -Filter "PMO_PA_ListarTarefas*.json")
    Add-Check "Exactly one ListarTarefas workflow" ($workflowFiles.Count -eq 1) ($workflowFiles.FullName -join "; ")

    $workflowText = if ($workflowFiles.Count -ge 1) { Get-Content -LiteralPath $workflowFiles[0].FullName -Raw } else { "" }
    $workflow = if ($workflowText) { $workflowText | ConvertFrom-Json } else { $null }
    Add-Check "ListarTarefas workflow JSON parses" ($null -ne $workflow) "ConvertFrom-Json succeeded."

    $branchActions = $null
    if ($workflow) {
        $branchActions = $workflow.properties.definition.actions.Condition_Projeto_Encontrado.actions.Check_Tarefas_Exist.else.actions
    }

    $selectExpression = if ($branchActions -and $branchActions.Select_Tarefas) { [string]$branchActions.Select_Tarefas.inputs.select } else { "" }
    $composeExpression = if ($branchActions -and $branchActions.Compose_Lista) { [string]$branchActions.Compose_Lista.inputs } else { "" }
    $responseSchema = if ($branchActions -and $branchActions.Respond_Lista) { $branchActions.Respond_Lista.inputs.schema.properties } else { $null }
    $resultType = if ($responseSchema -and $responseSchema.result) { [string]$responseSchema.result.type } else { "" }
    $responsePropertyNames = if ($responseSchema) { @($responseSchema.PSObject.Properties.Name) } else { @() }

    Add-Check "Response schema remains single result string" (($responsePropertyNames.Count -eq 1) -and ($responsePropertyNames -contains "result") -and ($resultType -eq "string")) "Copilot action contract must remain stable."
    Add-Check "ListarTarefas response avoids Markdown bold" ($workflowText -notmatch "\*\*") "Markdown bold in raw SharePoint fields increased Responsible AI filter risk."
    Add-Check "ListarTarefas response avoids Markdown separators" ($workflowText -notmatch "---") "Avoid Markdown section dividers in bot-visible flow output."
    Add-Check "ListarTarefas response avoids fenced code markers" ($workflowText -notmatch '```') "Avoid code fence patterns in bot-visible flow output."
    $respondListaResult = if ($branchActions -and $branchActions.Respond_Lista) { [string]$branchActions.Respond_Lista.inputs.body.result } else { "" }
    $respondEmptyResult = if ($workflow -and $workflow.properties.definition.actions.Condition_Projeto_Encontrado.actions.Check_Tarefas_Exist.actions.Respond_Empty) { [string]$workflow.properties.definition.actions.Condition_Projeto_Encontrado.actions.Check_Tarefas_Exist.actions.Respond_Empty.inputs.body.result } else { "" }
    $topicFiles = @(Get-ChildItem -LiteralPath (Join-Path $tempRoot "botcomponents") -Recurse -File | Where-Object { $_.FullName -like "*topic.ListarTarefas*data" })
    $topicText = if ($topicFiles.Count -eq 1) { Get-Content -LiteralPath $topicFiles[0].FullName -Raw } else { "" }
    $topicUsesPm0Action = $topicText -match "dialog:\s*pmo_AssistentePMO_V2\.action\.PM0_PA_Card_ListarTarefas"

    Add-Check "ListarTarefas flow output is static runtime-safe text" (($respondListaResult -eq "Consulta concluida. Dados lidos no SharePoint. Use os IDs ativos validados no roteiro de QA.") -and ($respondEmptyResult -eq "Consulta concluida. Dados lidos no SharePoint. Use os IDs ativos validados no roteiro de QA.")) "3.14 proved dynamic list output still triggers Copilot ContentFiltered after the message; 3.15 must not expose dynamic SharePoint rows to bot text."
    $staticTopicActivity = "activity: Consulta concluida. Dados lidos no SharePoint. Use os IDs ativos validados no roteiro de QA."
    $legacyTopicIsStatic = ($topicText.Contains($staticTopicActivity)) -and ($topicText -notmatch 'activity: "\{Topic\.tarefas\}"')
    $pm0TopicReturnsResult = $topicUsesPm0Action -and ($topicText -match 'activity: "\{Topic\.tarefas\}"')
    Add-Check "ListarTarefas topic matches active action result contract" ($legacyTopicIsStatic -or $pm0TopicReturnsResult) "Legacy PMO topics suppress dynamic list output; PM0 topics emit the PM0 action result for AQ-09 runtime verification."
    Add-Check "ListarTarefas compose remains non-bot-visible compact diagnostic" (($composeExpression -match "IDs ") -and ($composeExpression -match "join\(body\('Select_Tarefas'\), ', '\)") -and ($composeExpression -notmatch "decodeUriComponent") -and (-not $composeExpression.Contains("\n---\n")) -and (-not $composeExpression.Contains("'\\n'"))) "The internal compose can keep diagnostic IDs, but response must not expose it to Copilot text."
    Add-Check "ListarTarefas suppresses task title in bot-visible output" ($selectExpression -notmatch "item\(\)\?\['Title'\]") "Task title is SharePoint free text and can trigger indirect-attack filtering."
    Add-Check "ListarTarefas suppresses responsible email in bot-visible output" ($selectExpression -notmatch "item\(\)\?\['Responsavel'\]") "Email/free text is not required to run follow-up commands."
    Add-Check "ListarTarefas still reports task IDs for follow-up commands" (($selectExpression -match "string\(item\(\)\?\['ID'\]\)") -and ($selectExpression -notmatch "Status") -and ($selectExpression -notmatch "Prioridade") -and ($selectExpression -notmatch "DataFim") -and ($selectExpression -notmatch "Horas")) "Runtime-safe output keeps only task IDs; users can run update commands by ID."
    Add-Check "ListarTarefas avoids pipe separators in response composition" (($selectExpression -notmatch "\|") -and ($composeExpression -notmatch "\|")) "Pipes made the tool output look like structured prompt text to Copilot filters."
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
    throw "ListarTarefas content-safe contract failed: $($failed.name -join '; ')"
}
