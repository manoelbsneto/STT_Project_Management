[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$legacyCriarTarefaFlowId = "0a5d2a41-24c0-4d5e-9f6d-000000000241"
$pm0CriarTarefaFlowId = "7f662db7-a250-f111-bec7-000d3abc5cc6"
$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_criartarefa_publish_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)

    $topicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarTarefa\data"
    $topicText = if (Test-Path -LiteralPath $topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }
    $usesPm0Action = $topicText -match "dialog:\s*pmo_AssistentePMO_V2\.action\.PM0_PA_Card_CriarTarefa"
    $actionComponent = if ($usesPm0Action) { "PM0_PA_Card_CriarTarefa" } else { "PMO_PA_CriarTarefa" }
    $actionFlowId = if ($usesPm0Action) { $pm0CriarTarefaFlowId } else { $legacyCriarTarefaFlowId }
    $actionPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.action.$actionComponent\data"
    $actionXmlPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.action.$actionComponent\botcomponent.xml"
    $actionText = if (Test-Path -LiteralPath $actionPath) { Get-Content -LiteralPath $actionPath -Raw } else { "" }
    $actionXml = if (Test-Path -LiteralPath $actionXmlPath) { Get-Content -LiteralPath $actionXmlPath -Raw } else { "" }

    Add-Check "CriarTarefa topic exists" (Test-Path -LiteralPath $topicPath) "Expected pmo_AssistentePMO_V2.topic.CriarTarefa/data."
    Add-Check "CriarTarefa action component exists" (Test-Path -LiteralPath $actionPath) "Expected pmo_AssistentePMO_V2.action.$actionComponent/data."
    Add-Check "CriarTarefa action XML exists" (Test-Path -LiteralPath $actionXmlPath) "Expected action botcomponent.xml."
    Add-Check "Action XML has correct schema" ($actionXml -match "schemaname=`"pmo_AssistentePMO_V2\.action\.$([regex]::Escape($actionComponent))`"") "Action schema must match topic dialog reference."
    Add-Check "Topic calls action component" (($topicText -match "kind:\s*BeginDialog") -and ($topicText -match "dialog:\s*pmo_AssistentePMO_V2\.action\.$([regex]::Escape($actionComponent))")) "Publish-safe pattern must call the active task action component."
    Add-Check "Topic has no direct CloudFlow invocation" (($topicText -notmatch "kind:\s*InvokeFlowAction") -and ($topicText -notmatch "flowId:\s*$([regex]::Escape($legacyCriarTarefaFlowId))") -and ($topicText -notmatch "flowId:\s*$([regex]::Escape($pm0CriarTarefaFlowId))")) "Only an action component may own the cloud flow reference."
    $topicMapsOutput = if ($usesPm0Action) {
        $topicText -match "(?ms)output:\s*`r?`n\s*binding:\s*`r?`n\s*result:\s*Topic\.Result"
    }
    else {
        $topicText -match "(?ms)output:\s*`r?`n\s*binding:\s*`r?`n\s*message:\s*Topic\.Result"
    }
    Add-Check "Topic maps action output" $topicMapsOutput "The active CriarTarefa action response must still be sent to the user."
    Add-Check "Action is TaskDialog" ($actionText -match "kind:\s*TaskDialog") "Cloud flow must be wrapped as bot action component."
    Add-Check "Action invokes active CriarTarefa flow" (($actionText -match "kind:\s*InvokeFlowTaskAction") -and ($actionText -match "flowId:\s*$([regex]::Escape($actionFlowId))")) "Only the active action component should own the cloud flow reference."
    Add-Check "Action declares connection mode" (($actionText -match "mode:\s*Embedded") -or ($usesPm0Action -and ($actionText -match "mode:\s*Invoker"))) "Legacy actions use Embedded; PM0 action wrappers use the exported PM0 action mode."
    $actionInputsMatch = if ($usesPm0Action) {
        ($actionText -match "propertyName:\s*projectId\b") -and
        ($actionText -match "propertyName:\s*action\b") -and
        ($actionText -match "propertyName:\s*title\b") -and
        ($actionText -match "propertyName:\s*responsavel\b") -and
        ($actionText -match "propertyName:\s*prazo\b") -and
        ($actionText -match "propertyName:\s*horas\b") -and
        ($actionText -match "propertyName:\s*prioridade\b")
    }
    else {
        ($actionText -match "propertyName:\s*text\b") -and
        ($actionText -match "propertyName:\s*text_1\b") -and
        ($actionText -match "propertyName:\s*text_2\b") -and
        ($actionText -match "propertyName:\s*text_3\b") -and
        ($actionText -match "propertyName:\s*number\b") -and
        ($actionText -match "propertyName:\s*text_4\b")
    }
    Add-Check "Action input contract matches flow trigger" $actionInputsMatch "Must preserve the active CriarTarefa flow trigger fields."
    Add-Check "Action exposes caller output" (($actionText -match "propertyName:\s*message\b") -or ($usesPm0Action -and ($actionText -match "propertyName:\s*result\b"))) "The active flow response field must be exposed."
    Add-Check "Topic stages values into globals" (($topicText -match "Global\.PMO_Criar_NomeProjeto") -and ($topicText -match "Global\.PMO_Criar_Titulo") -and ($topicText -match "Global\.PMO_Criar_Responsavel") -and ($topicText -match "Global\.PMO_Criar_Prazo") -and ($topicText -match "Global\.PMO_Criar_Horas") -and ($topicText -match "Global\.PMO_Criar_Prioridade")) "TaskDialog ManualTaskInput reads stable global values."
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
    throw "CriarTarefa publish binding test failed: $($failed.name -join '; ')"
}
