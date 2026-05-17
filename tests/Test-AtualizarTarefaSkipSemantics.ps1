[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_atualizartarefa_skip_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)

    $workflowPath = Get-ChildItem -LiteralPath (Join-Path $tempRoot "Workflows") -Filter "PMO_PA_AtualizarTarefa*.json" |
        Select-Object -First 1 -ExpandProperty FullName
    Add-Check "AtualizarTarefa workflow exists" ([bool]$workflowPath) "Expected PMO_PA_AtualizarTarefa*.json in package."

    if ($workflowPath) {
        $workflowText = (Get-Content -LiteralPath $workflowPath -Raw) -replace '\\u0027', "'"
        $workflow = $workflowText | ConvertFrom-Json
        $params = $workflow.properties.definition.actions.Update_Tarefa.inputs.parameters

        $horas = $params.'item/HorasRealizadas'
        $responsavel = $params.'item/Responsavel'
        $dataFim = $params.'item/DataFim'
        $prioridade = $params.'item/Prioridade/Value'
        $respondSuccess = $workflow.properties.definition.actions.Respond_Success.inputs.body.result
        $respondSuccessBodyProperties = @($workflow.properties.definition.actions.Respond_Success.inputs.body.PSObject.Properties.Name)
        $respondSuccessSchemaProperties = @($workflow.properties.definition.actions.Respond_Success.inputs.schema.properties.PSObject.Properties.Name)
        $missingProjectResponse = $workflow.properties.definition.actions.Condition_Projeto_Encontrado.else.actions.Response_Project_Not_Found
        $missingProjectBodyProperties = @($missingProjectResponse.inputs.body.PSObject.Properties.Name)
        $missingProjectSchemaProperties = @($missingProjectResponse.inputs.schema.properties.PSObject.Properties.Name)

        Add-Check "HorasRealizadas zero skips and preserves current value" (
            ($horas -match "or\(equals\(triggerBody\(\)\?\['number_1'\], null\), equals\(triggerBody\(\)\?\['number_1'\], 0\)\)") -and
            ($horas -match "body\('Get_Tarefa_Atual'\)\?\['HorasRealizadas'\]")
        ) $horas

        foreach ($field in @(
            @{ name = "Responsavel"; text = $responsavel; trigger = "text_1"; current = "body\('Get_Tarefa_Atual'\)\?\['Responsavel'\]" },
            @{ name = "DataFim"; text = $dataFim; trigger = "text_2"; current = "body\('Get_Tarefa_Atual'\)\?\['DataFim'\]" },
            @{ name = "Prioridade"; text = $prioridade; trigger = "text_3"; current = "body\('Get_Tarefa_Atual'\)\?\['Prioridade'\]" }
        )) {
            $expr = $field.text
            $trigger = [regex]::Escape($field.trigger)
            Add-Check "$($field.name) preserves current value on skip" ($expr -match $field.current) $expr
            Add-Check "$($field.name) handles blank skip" ($expr -match "empty\(triggerBody\(\)\?\['$trigger'\]\)") $expr
            Add-Check "$($field.name) handles ascii nao skip" ($expr -match "equals\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['$trigger'\], ''\)\)\), 'nao'\)") $expr
            Add-Check "$($field.name) handles single-letter n skip" ($expr -match "equals\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['$trigger'\], ''\)\)\), 'n'\)") $expr
            Add-Check "$($field.name) handles short n-token skip without non-ASCII literal" (
                ($expr -match "startsWith\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['$trigger'\], ''\)\)\), 'n'\)") -and
                ($expr -match "lessOrEquals\(length\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['$trigger'\], ''\)\)\)\), 3\)")
            ) $expr
            Add-Check "$($field.name) no longer relies only on empty check" (
                $expr -notmatch "^@if\(empty\(triggerBody\(\)\?\['$trigger'\]\)"
            ) $expr
        }

        Add-Check "DataFim trims and normalizes BR dd/MM/yyyy to ISO yyyy-MM-dd" (
            ($dataFim -match "trim\(coalesce\(triggerBody\(\)\?\['text_2'\], ''\)\)") -and
            ($dataFim -match "substring\(trim\(coalesce\(triggerBody\(\)\?\['text_2'\], ''\)\), 6, 4\)") -and
            ($dataFim -match "substring\(trim\(coalesce\(triggerBody\(\)\?\['text_2'\], ''\)\), 3, 2\)") -and
            ($dataFim -match "substring\(trim\(coalesce\(triggerBody\(\)\?\['text_2'\], ''\)\), 0, 2\)") -and
            ($dataFim -match "concat\(")
        ) $dataFim

        Add-Check "Respond_Success is static and content-filter safe" (
            ($respondSuccess -match "Tarefa atualizada com sucesso") -and
            ($respondSuccess -notmatch "body\('Update_Tarefa'\)") -and
            ($respondSuccess -notmatch "triggerBody") -and
            ($respondSuccess -notmatch "ProjectID") -and
            ($respondSuccess -notmatch "Responsavel") -and
            ($respondSuccess -notmatch "\n")
        ) $respondSuccess

        Add-Check "Respond_Success suppresses free-text title and responsible email" (
            ($respondSuccess -notmatch "body\('Update_Tarefa'\)\?\['Title'\]") -and
            ($respondSuccess -notmatch "body\('Update_Tarefa'\)\?\['Responsavel'\]") -and
            ($respondSuccess -notmatch "\*\*") -and
            ($respondSuccess -notmatch "\|")
        ) $respondSuccess

        Add-Check "AtualizarTarefa flow responses expose only result field" (
            (($respondSuccessBodyProperties -join ",") -eq "result") -and
            (($respondSuccessSchemaProperties -join ",") -eq "result") -and
            (($missingProjectBodyProperties -join ",") -eq "result") -and
            (($missingProjectSchemaProperties -join ",") -eq "result")
        ) "Respond_Success body=$($respondSuccessBodyProperties -join ','); schema=$($respondSuccessSchemaProperties -join ','); missing project body=$($missingProjectBodyProperties -join ','); schema=$($missingProjectSchemaProperties -join ',')"
    }

    $topicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.AtualizarTarefa\data"
    if (Test-Path -LiteralPath $topicPath) {
        $topicText = Get-Content -LiteralPath $topicPath -Raw
        $finalMessageBlock = if ($topicText -match "(?s)id:\s*atualizar_done.*?(?:elseActions:|$)") { $matches[0] } else { "" }
        Add-Check "AtualizarTarefa topic final message does not echo raw skip inputs" (
            ($finalMessageBlock -match "id:\s*atualizar_done") -and
            ($finalMessageBlock -match "activity:\s*Tarefa atualizada com sucesso") -and
            ($finalMessageBlock -notmatch "\{Topic\.message\}") -and
            ($finalMessageBlock -notmatch "Responsavel:\s*\{Topic\.Responsavel\}") -and
            ($finalMessageBlock -notmatch "Prazo:\s*\{Topic\.DataFim\}") -and
            ($finalMessageBlock -notmatch "Prioridade:\s*\{Topic\.Prioridade\}")
        ) $finalMessageBlock

        $confirmPromptBlock = if ($topicText -match "(?s)id:\s*confirm_atualizar.*?entity:\s*StringPrebuiltEntity") { $matches[0] } else { "" }
        Add-Check "AtualizarTarefa confirmation prompt is static" (
            ($confirmPromptBlock -match "prompt:\s*Confirma a atualizacao da tarefa\?") -and
            ($confirmPromptBlock -notmatch "\{Topic\.TaskID\}") -and
            ($confirmPromptBlock -notmatch "\{Topic\.Status\}") -and
            ($confirmPromptBlock -notmatch "\{Topic\.HorasRealizadas\}") -and
            ($confirmPromptBlock -notmatch "\{Topic\.Responsavel\}") -and
            ($confirmPromptBlock -notmatch "\{Topic\.DataFim\}") -and
            ($confirmPromptBlock -notmatch "\{Topic\.Prioridade\}")
        ) $confirmPromptBlock
    }
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
    throw "AtualizarTarefa skip semantics test failed: $($failed.name -join '; ')"
}
