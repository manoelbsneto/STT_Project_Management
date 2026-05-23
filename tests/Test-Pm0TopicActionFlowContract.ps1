[CmdletBinding()]
param(
    [string]$SourceRoot = "Local_Repo\Assistente PMO V2",
    [string]$ReportPath = ""
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$actionsRoot = Join-Path $resolvedRoot "actions"
$topicsRoot = Join-Path $resolvedRoot "topics"
$workflowsRoot = Join-Path $resolvedRoot "workflows"

$targets = @(
    [ordered]@{ topic = "AtualizarStatus"; action = "PM0_PA_Card_AtualizarStatus"; workflowId = "1721e0a3-a250-f111-bec7-000d3abc5cc6" },
    [ordered]@{ topic = "AtualizarTarefa"; action = "PM0_PA_Card_AtualizarTarefa"; workflowId = "7c6300c2-a250-f111-bec7-000d3abc5cc6" },
    [ordered]@{ topic = "ConsultarPortfolio"; action = "PM0_PA_Card_ResumoExecutivoPortfolio"; workflowId = "8333bd91-a250-f111-bec7-000d3abc5cc6" },
    [ordered]@{ topic = "CriarTarefa"; action = "PM0_PA_Card_CriarTarefa"; workflowId = "7f662db7-a250-f111-bec7-000d3abc5cc6" },
    [ordered]@{ topic = "ListarTarefas"; action = "PM0_PA_Card_ListarTarefas"; workflowId = "e0e3c6b0-a250-f111-bec7-000d3abc5cc6" }
)

$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Evidence
    )
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

function Get-WorkflowFile {
    param([string]$ActionName, [string]$WorkflowId)
    $path = Join-Path $workflowsRoot "$ActionName-$WorkflowId\workflow.json"
    if (Test-Path -LiteralPath $path) {
        return Get-Item -LiteralPath $path
    }

    @(Get-ChildItem -LiteralPath $workflowsRoot -Directory -Filter "$ActionName-*") |
        Select-Object -First 1 |
        ForEach-Object { Get-Item -LiteralPath (Join-Path $_.FullName "workflow.json") }
}

function Get-ActionInputNames {
    param([string]$Text)

    $inputsMatch = [regex]::Match($Text, "(?ms)^inputs:\s*(?<block>.*?)(?=^outputs:|^action:|\z)")
    if (-not $inputsMatch.Success) {
        return @()
    }

    @([regex]::Matches($inputsMatch.Groups["block"].Value, "propertyName:\s*(?<name>[A-Za-z0-9_]+)") |
        ForEach-Object { $_.Groups["name"].Value } |
        Select-Object -Unique)
}

function Get-BeginDialogCallBlock {
    param([string]$Text, [string]$ActionName)

    $dialogNeedle = "dialog: pmo_AssistentePMO_V2.action.$ActionName"
    $dialogIndex = $Text.IndexOf($dialogNeedle, [System.StringComparison]::Ordinal)
    if ($dialogIndex -lt 0) {
        return ""
    }

    $startNeedle = "- kind: BeginDialog"
    $startIndex = $Text.LastIndexOf($startNeedle, $dialogIndex, [System.StringComparison]::Ordinal)
    if ($startIndex -lt 0) {
        $startIndex = [Math]::Max(0, $dialogIndex - 600)
    }

    $nextIndex = $Text.IndexOf("`n    - kind:", $dialogIndex + $dialogNeedle.Length, [System.StringComparison]::Ordinal)
    if ($nextIndex -lt 0) {
        $nextIndex = [Math]::Min($Text.Length, $dialogIndex + 900)
    }

    $Text.Substring($startIndex, $nextIndex - $startIndex)
}

function Get-WorkflowRequiredFields {
    param([object]$Workflow)

    $schema = $Workflow.properties.definition.triggers.manual.inputs.schema
    if (-not $schema -or -not $schema.required) {
        return @()
    }

    @($schema.required | ForEach-Object { [string]$_ })
}

foreach ($target in $targets) {
    $actionFile = Join-Path $actionsRoot "$($target.action).mcs.yml"
    $topicFile = Join-Path $topicsRoot "$($target.topic).mcs.yml"
    $workflowFile = Get-WorkflowFile -ActionName $target.action -WorkflowId $target.workflowId

    Add-Check "$($target.action) action file exists" (Test-Path -LiteralPath $actionFile) $actionFile
    Add-Check "$($target.topic) topic file exists" (Test-Path -LiteralPath $topicFile) $topicFile
    Add-Check "$($target.action) workflow file exists" ($null -ne $workflowFile) ($workflowFile.FullName)

    if (-not (Test-Path -LiteralPath $actionFile) -or -not (Test-Path -LiteralPath $topicFile) -or $null -eq $workflowFile) {
        continue
    }

    $actionText = Get-Content -LiteralPath $actionFile -Raw -Encoding UTF8
    $topicText = Get-Content -LiteralPath $topicFile -Raw -Encoding UTF8
    $workflowText = Get-Content -LiteralPath $workflowFile.FullName -Raw -Encoding UTF8
    $workflow = $null

    try {
        $workflow = $workflowText | ConvertFrom-Json
        Add-Check "$($target.action) workflow JSON parses" $true $workflowFile.FullName
    }
    catch {
        Add-Check "$($target.action) workflow JSON parses" $false $_.Exception.Message
        continue
    }

    $requiredFields = @(Get-WorkflowRequiredFields -Workflow $workflow)
    $actionInputs = @(Get-ActionInputNames -Text $actionText)
    $callBlock = Get-BeginDialogCallBlock -Text $topicText -ActionName $target.action

    Add-Check "$($target.action) uses expected workflow id" ($actionText -match [regex]::Escape("flowId: $($target.workflowId)")) "Action wrapper must bind to workflow $($target.workflowId)."
    Add-Check "$($target.action) workflow uses Skills trigger" ($workflowText -match '"kind"\s*:\s*"Skills"') "PM0 actions must be agent-callable Skills flows."
    Add-Check "$($target.topic) calls expected PM0 action" ($callBlock.Length -gt 0) "Topic must call pmo_AssistentePMO_V2.action.$($target.action)."

    if ($requiredFields.Count -eq 0) {
        Add-Check "$($target.action) has no required workflow inputs to propagate" $true "Workflow trigger required list is empty."
    }

    foreach ($field in $requiredFields) {
        Add-Check "$($target.action) declares action input $field" ($actionInputs -contains $field) "Required by workflow trigger schema: $($requiredFields -join ', ')."
        $fieldPattern = "(?m)^\s*$([regex]::Escape($field))\s*:"
        Add-Check "$($target.topic) maps topic input $field" (($callBlock -notmatch "input:\s*\{\s*\}") -and ($callBlock -match $fieldPattern)) "BeginDialog call block: $callBlock"
    }

    foreach ($field in $actionInputs) {
        $fieldPattern = "(?m)^\s*$([regex]::Escape($field))\s*:"
        Add-Check "$($target.topic) maps declared action input $field" (($callBlock -notmatch "input:\s*\{\s*\}") -and ($callBlock -match $fieldPattern)) "Every declared action input must be passed by the topic BeginDialog call. BeginDialog call block: $callBlock"
    }
}

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    sourceRoot = $resolvedRoot
    generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$json = $result | ConvertTo-Json -Depth 12
if ($ReportPath) {
    $parent = Split-Path -Parent $ReportPath
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $ReportPath -Value $json -Encoding UTF8
}

$json

if ($failed.Count -gt 0) {
    throw "PM0 topic/action/flow contract test failed: $($failed.name -join '; ')"
}
