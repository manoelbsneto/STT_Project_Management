[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$criarProjetoFlowId = "3104124d-364a-f111-bec7-7ced8d955c6c"
$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_criarprojeto_publish_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)

    $topicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarProjeto\data"
    $actionPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto\data"
    $actionXmlPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto\botcomponent.xml"
    $topicText = if (Test-Path -LiteralPath $topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }
    $actionText = if (Test-Path -LiteralPath $actionPath) { Get-Content -LiteralPath $actionPath -Raw } else { "" }
    $actionXml = if (Test-Path -LiteralPath $actionXmlPath) { Get-Content -LiteralPath $actionXmlPath -Raw } else { "" }

    Add-Check "CriarProjeto topic exists" (Test-Path -LiteralPath $topicPath) "Expected pmo_AssistentePMO_V2.topic.CriarProjeto/data."
    Add-Check "CriarProjeto action component exists" (Test-Path -LiteralPath $actionPath) "Expected pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto/data."
    Add-Check "CriarProjeto action XML exists" (Test-Path -LiteralPath $actionXmlPath) "Expected action botcomponent.xml."
    Add-Check "Action XML has correct schema" ($actionXml -match 'schemaname="pmo_AssistentePMO_V2\.action\.PMO_PA_CriarProjeto"') "Action schema must match topic dialog reference."
    Add-Check "Topic calls action component" (($topicText -match "kind:\s*BeginDialog") -and ($topicText -match "dialog:\s*pmo_AssistentePMO_V2\.action\.PMO_PA_CriarProjeto")) "Publish-safe pattern mirrors CriarTarefa action binding."
    Add-Check "Topic has no direct CloudFlow invocation" (($topicText -notmatch "kind:\s*InvokeFlowAction") -and ($topicText -notmatch "flowId:\s*$([regex]::Escape($criarProjetoFlowId))")) "Direct CloudFlow references can trigger Copilot Studio InvalidReferenceError after import."
    Add-Check "Topic maps action message output" ($topicText -match "(?ms)output:\s*`r?`n\s*binding:\s*`r?`n\s*message:\s*Topic\.Result") "Flow response message must still be sent to user."
    Add-Check "Action is TaskDialog" ($actionText -match "kind:\s*TaskDialog") "Cloud flow must be wrapped as bot action component."
    Add-Check "Action invokes PMO_PA_CriarProjeto flow" (($actionText -match "kind:\s*InvokeFlowTaskAction") -and ($actionText -match "flowId:\s*$([regex]::Escape($criarProjetoFlowId))")) "Only action component should own the cloud flow reference."
    Add-Check "Action uses embedded connection mode" ($actionText -match "mode:\s*Embedded") "Matches Standard connector package contract."
    Add-Check "Action input contract matches flow trigger" (($actionText -match "propertyName:\s*text\b") -and ($actionText -match "propertyName:\s*text_1\b") -and ($actionText -match "propertyName:\s*text_2\b") -and ($actionText -match "propertyName:\s*text_3\b") -and ($actionText -match "propertyName:\s*number\b") -and ($actionText -match "propertyName:\s*text_4\b")) "Must preserve CriarProjeto flow trigger fields."
    Add-Check "Action exposes message output" ($actionText -match "propertyName:\s*message\b") "Flow response schema returns message."
    Add-Check "Topic stages values into globals" (($topicText -match "Global\.PMO_Projeto_NomeProjeto") -and ($topicText -match "Global\.PMO_Projeto_PM") -and ($topicText -match "Global\.PMO_Projeto_Prazo") -and ($topicText -match "Global\.PMO_Projeto_Prioridade")) "TaskDialog ManualTaskInput reads stable global values."
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
    throw "CriarProjeto publish binding test failed: $($failed.name -join '; ')"
}
