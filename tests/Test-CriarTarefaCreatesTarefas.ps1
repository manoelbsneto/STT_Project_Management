[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$projectListId = "0271c9e8-c184-4b91-99f9-5b71f9b08826"
$taskListId = "36d78ca1-1f60-4dd3-a4d5-5c94b89969e9"
$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_criartarefa_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)
    $customizations = Get-Content -LiteralPath (Join-Path $tempRoot "customizations.xml") -Raw
    $workflowPath = Get-ChildItem -LiteralPath (Join-Path $tempRoot "Workflows") -Filter "PMO_PA_CriarTarefa*.json" |
        Where-Object { $_.Name -notmatch "CriarTarefa_V3" } |
        Select-Object -First 1 -ExpandProperty FullName
    $text = if ($workflowPath) { Get-Content -LiteralPath $workflowPath -Raw } else { "" }
    $workflow = if ($text) { $text | ConvertFrom-Json } else { $null }
    $dateExpression = if ($workflow) { [string]$workflow.properties.definition.actions.Compose_DataFim.inputs } else { "" }
    $dateWriteValue = if ($workflow) { [string]$workflow.properties.definition.actions.Condition_Prazo_Valido.actions.Condition_Projeto_Encontrado.actions.Create_Tarefa_SharePoint.inputs.parameters.'item/DataFim' } else { "" }

    Add-Check "Package registers PMO_PA_CriarTarefa" ($customizations -match 'Name="PMO_PA_CriarTarefa"') "customizations.xml must expose a task-create flow."
    Add-Check "CriarTarefa workflow exists" (-not [string]::IsNullOrWhiteSpace($workflowPath)) "Expected Workflows/*CriarTarefa*.json not named CriarTarefa_V3."
    Add-Check "Uses Skills trigger" ($text -match '"kind"\s*:\s*"Skills"') "Flow must be callable from Copilot Studio."
    Add-Check "Uses SharePoint connector" ($text -match "shared_sharepointonline") "Only SharePoint Standard connector expected."
    Add-Check "Uses embedded connection" ($text -match '"runtimeSource"\s*:\s*"embedded"' -and $text -notmatch '"runtimeSource"\s*:\s*"invoker"') "No per-user invoker connection."
    Add-Check "Accepts project and task inputs" (($text -match "nomeProjeto") -and ($text -match "titulo") -and ($text -match "responsavel") -and ($text -match "prazo") -and ($text -match "horas") -and ($text -match "prioridade")) "Required Copilot input contract."
    Add-Check "Looks up Projetos before write" (($text -match "Get_Projeto") -and ($text -match [regex]::Escape($projectListId)) -and ($text -match "Ativo eq 1") -and ($text -match "Deleted ne 1")) "Task creation must resolve active non-deleted project."
    Add-Check "Has project not found guard" (($text -match "Condition_Projeto_Encontrado") -and ($text -match "PROJECT_NOT_FOUND")) "Business error instead of blind write."
    Add-Check "Requires Brazilian task due date format" (($text -match "Compose_PrazoRaw") -and ($text -match "INVALID_BR_DATE") -and ($text -match "dd/MM/aaaa") -and ($text -match "Condition_Prazo_Valido")) "User-facing contract is dd/MM/aaaa; invalid dates are rejected before SharePoint write."
    Add-Check "Converts dd/MM/aaaa to SharePoint ISO date only" (($dateExpression.Contains("concat(last(split(outputs('Compose_PrazoRaw'), '/')), '-', first(skip(split(outputs('Compose_PrazoRaw'), '/'), 1)), '-', first(split(outputs('Compose_PrazoRaw'), '/')))")) -and ($dateWriteValue -eq "@outputs('Compose_DataFim')")) "Flow must normalize Brazilian date input to yyyy-MM-dd internally."
    Add-Check "Rejects raw ISO or US pass-through due dates" (($dateWriteValue -notmatch "triggerBody\(\)\?\['text_3'\]") -and (-not $text.Contains("replace(string(triggerBody()?['text_3']), '/', '-')"))) "No fallback that writes yyyy-MM-dd or yyyy/MM/dd directly from user input."
    Add-Check "Creates Tarefas item" (($text -match "Create_Tarefa_SharePoint") -and ($text -match '"operationId"\s*:\s*"PostItem"') -and ($text -match [regex]::Escape($taskListId))) "CriarTarefa must write to Tarefas."
    Add-Check "Does not create Projetos item" ($text -notmatch "Create_Projeto_SharePoint" -and $text -notmatch '"item/NomeProjeto"' -and $text -notmatch '"item/PM/Claims"') "Task creation must never create/update project master rows."
    Add-Check "Writes task schema fields" (($text -match '"item/Title"') -and ($text -match '"item/ProjectID"') -and ($text -match '"item/Responsavel"') -and ($text -match '"item/DataFim"') -and ($text -match '"item/HorasEstimadas"') -and ($text -match '"item/Status/Value"') -and ($text -match '"item/Prioridade/Value"')) "Tarefas schema mapping from read-only evidence."
    Add-Check "Uses valid initial task status choice" ($text -match '"item/Status/Value"\s*:\s*"Pendente"') "SharePoint XML evidence allows task Status choices: Pendente, Em Andamento, Concluida, Cancelada."
    Add-Check "Does not write invalid task status Aberta" ($text -notmatch '"item/Status/Value"\s*:\s*"Aberta"') "Aberta is not a valid Tarefas.Status choice in live SharePoint XML."
    Add-Check "Sets task visible" ($text -match '"item/Deleted"\s*:\s*false') "New tasks must start Deleted=false."
    Add-Check "Does not overwrite Created" ($text -notmatch '"item/Created"') "SharePoint Created is system managed."
    Add-Check "ASCII-only flow text" ($text -notmatch "[^\x00-\x7F]") "App-facing flow text must be ASCII-only."
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
    throw "CriarTarefa creates Tarefas test failed: $($failed.name -join '; ')"
}
