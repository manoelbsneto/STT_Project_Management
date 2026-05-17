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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_criarprojeto_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)
    $customizationsPath = Join-Path $tempRoot "customizations.xml"
    $customizations = Get-Content -LiteralPath $customizationsPath -Raw
    $workflowPath = Get-ChildItem -LiteralPath (Join-Path $tempRoot "Workflows") -Filter "*CriarProjeto*.json" |
        Select-Object -First 1 -ExpandProperty FullName
    $text = if ($workflowPath) { Get-Content -LiteralPath $workflowPath -Raw } else { "" }
    $decodedText = $text -replace '\\u0027', "'" -replace '\\/', '/'

    Add-Check "Package registers PMO_PA_CriarProjeto" ($customizations -match 'Name="PMO_PA_CriarProjeto"') "customizations.xml must expose a project-create flow."
    Add-Check "CriarProjeto workflow exists" (-not [string]::IsNullOrWhiteSpace($workflowPath)) "Expected Workflows/*CriarProjeto*.json."
    Add-Check "Uses Skills trigger" ($text -match '"kind"\s*:\s*"Skills"') "Flow must be callable from Copilot Studio."
    Add-Check "Uses SharePoint connector" ($text -match "shared_sharepointonline") "Only SharePoint Standard connector expected."
    Add-Check "Uses embedded connection" ($text -match '"runtimeSource"\s*:\s*"embedded"' -and $text -notmatch '"runtimeSource"\s*:\s*"invoker"') "No per-user invoker connection."
    Add-Check "Creates Projetos item" (($text -match "Create_Projeto_SharePoint") -and ($text -match '"operationId"\s*:\s*"PostItem"') -and ($text -match [regex]::Escape($projectListId))) "CriarProjeto must write to Projetos."
    Add-Check "Does not write Tarefas" ($text -notmatch [regex]::Escape($taskListId) -and $text -notmatch "Create_Tarefa_SharePoint") "Project creation cannot target Tarefas."
    Add-Check "Uses strict Brazilian date raw compose" (($text -match "Compose_DataAlvoRaw") -and ($text -match "Compose_DataAlvo")) "Prazo must be normalized from a raw BR date compose."
    Add-Check "Rejects non-BR project date" ($text -match "INVALID_BR_DATE" -and $text -match "Condition_DataAlvo_Valido") "ISO pass-through dates must be rejected before SharePoint writes."
    Add-Check "Requires dd/MM/aaaa components" (($decodedText -match [regex]::Escape("split(outputs('Compose_DataAlvoRaw'), '/')")) -and ($decodedText -match [regex]::Escape("equals(length(last(split(outputs('Compose_DataAlvoRaw'), '/'))), 4)")) -and ($decodedText -match [regex]::Escape("contains(createArray('01','02','03','04','05','06','07','08','09','10','11','12')"))) "Flow must validate unambiguous Brazilian day/month/year shape."
    Add-Check "No legacy ISO pass-through date fallback" ($decodedText -notmatch "string\(triggerBody\(\)\?\['text_3'\]\)\)\s*`"") "Legacy fallback allowed ISO yyyy-MM-dd through as DataAlvo."
    Add-Check "Uses GUID ProjectID" ($text -match "Compose_ProjectID" -and $text -match "guid\(\)") "ProjectID must be system-defined and not latest-ID based."
    Add-Check "Checks active duplicate project" (($text -match "Get_Duplicate_Projects") -and ($text -match "Deleted ne 1")) "Duplicate guard must ignore logically deleted rows."
    Add-Check "Sets project visible" (($text -match '"item/Deleted"\s*:\s*false') -or ($text -match '"Deleted"\s*=\s*\$false')) "New projects must start Deleted=false."
    Add-Check "Writes project schema fields" (($text -match '"item/ProjectID"') -and ($text -match '"item/NomeProjeto"') -and ($text -match '"item/PM/Claims"') -and ($text -match '"item/StatusRAG/Value"') -and ($text -match '"item/Prioridade/Value"')) "Projetos required schema mapping."
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
    throw "CriarProjeto flow definition test failed: $($failed.name -join '; ')"
}
