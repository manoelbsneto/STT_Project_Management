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
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_gerarmultiplos_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)
    $customizations = Get-Content -LiteralPath (Join-Path $tempRoot "customizations.xml") -Raw
    $workflowPath = Get-ChildItem -LiteralPath (Join-Path $tempRoot "Workflows") -Filter "*Gerar*Multiplos*Projetos*.json" |
        Select-Object -First 1 -ExpandProperty FullName
    $workflowText = if ($workflowPath) { Get-Content -LiteralPath $workflowPath -Raw } else { "" }
    $topicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos\data"
    $topicText = if (Test-Path -LiteralPath $topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }
    $allText = $workflowText + "`n" + $topicText
    $previewOnlyTopic = (($topicText -match "BATCH_PREVIEW_ONLY_NO_WRITE") -and ($topicText -notmatch "InvokeFlowAction") -and ($topicText -notmatch "flowId:\s*0a5d2a42-24c0-4d5e-9f6d-000000000241"))

    Add-Check "Topic exists" (Test-Path -LiteralPath $topicPath) "Expected bot topic for batch intent."
    if ($previewOnlyTopic) {
        Add-Check "Preview-only batch has no orphan workflow registration" ($customizations -notmatch 'Name="PMO_PA_Gerar_Multiplos_Projetos"') "Preview-only mode must not ship an unused batch workflow root component."
        Add-Check "Preview-only batch has no orphan workflow file" ([string]::IsNullOrWhiteSpace($workflowPath)) "Preview-only topic must not ship an unused Workflows/*Gerar*Multiplos*Projetos*.json file."
    } else {
        Add-Check "Package registers PMO_PA_Gerar_Multiplos_Projetos" ($customizations -match 'Name="PMO_PA_Gerar_Multiplos_Projetos"') "customizations.xml must expose batch flow."
        Add-Check "Gerar_Multiplos_Projetos workflow exists" (-not [string]::IsNullOrWhiteSpace($workflowPath)) "Expected Workflows/*Gerar*Multiplos*Projetos*.json."
        Add-Check "Uses Skills trigger" ($workflowText -match '"kind"\s*:\s*"Skills"') "Flow must be callable from Copilot Studio."
        Add-Check "Uses SharePoint connector" ($workflowText -match "shared_sharepointonline") "Only SharePoint Standard connector expected."
        Add-Check "Uses embedded connection" ($workflowText -match '"runtimeSource"\s*:\s*"embedded"' -and $workflowText -notmatch '"runtimeSource"\s*:\s*"invoker"') "No per-user invoker connection."
    }
    Add-Check "Has Adaptive Card preview contract" (($allText -match "AdaptiveCard") -and ($allText -match "Action.Submit") -and ($allText -match "previewCreateBatch") -and ($allText -match "writeMode")) "Adaptive Card must be Plan A for review/confirmation."
    Add-Check "Has multiline/STT fallback marker" (($allText -match "multiline") -and ($allText -match "STT") -and ($allText -match "fallback")) "Text and Speech-to-Text fallback must be explicit."
    Add-Check "Enforces batch limits" (($allText -match "maxBatchProjects") -and ($allText -match "maxBatchTasks") -and ($allText -match "10")) "Initial cut is max 10 projects and 10 tasks."
    Add-Check "Batch write path is disabled until parser hardening" (($allText -match "BATCH_PREVIEW_ONLY_NO_WRITE") -and ($allText -match "nenhuma gravacao foi executada")) "Current safe release must not write batch data until per-line parser and card review are validated."
    Add-Check "Does not create Projetos from raw lines" (($workflowText -notmatch [regex]::Escape($projectListId)) -and ($workflowText -notmatch "Create_Projeto_Batch_SharePoint")) "Must not write raw input lines into Projetos."
    Add-Check "Does not create Tarefas from raw lines" (($workflowText -notmatch [regex]::Escape($taskListId)) -and ($workflowText -notmatch "Create_Tarefa_Batch_SharePoint")) "Must not create default tasks from unvalidated raw lines."
    Add-Check "No confirmed write branch" (($workflowText -notmatch "Condition_Confirmed") -and ($workflowText -notmatch "Append_Row_Result") -and ($workflowText -notmatch "partialSuccess")) "Preview-only mode must not contain a hidden confirmation write path."
    Add-Check "Preview topic does not invoke flow" (($topicText -notmatch "InvokeFlowAction") -and ($topicText -notmatch "flowId:\s*0a5d2a42-24c0-4d5e-9f6d-000000000241")) "Preview/no-write mode must not depend on a bot flow binding."
    Add-Check "Preview topic returns no-write response directly" (($topicText -match "BATCH_PREVIEW_ONLY_NO_WRITE") -and ($topicText -match "nenhuma gravacao foi executada")) "Topic must return deterministic no-write response after confirmation."
    Add-Check "Topic routes batch phrases" (($topicText -match "gerar multiplos projetos") -and ($topicText -match "criar varios projetos") -and ($topicText -match "criar projetos em lote") -and ($topicText -match "gerar projetos em batch")) "Required trigger phrases."
    Add-Check "ASCII-only batch text" ($allText -notmatch "[^\x00-\x7F]") "App-facing flow/topic text must be ASCII-only."
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
    throw "Gerar_Multiplos_Projetos definition test failed: $($failed.name -join '; ')"
}
