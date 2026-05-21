[CmdletBinding()]
param(
    [string]$ConfigPath = ".planning\comms\aq08_topic_routing_verification_20260520\expected_pm0_routing_post_remediation.json",
    [string]$EvidenceDir = ".planning\comms\aq08_topic_routing_verification_20260520\post_remediation_reverify",
    [switch]$UseExistingSnapshots,
    [string]$TopicSnapshotPath = ".planning\comms\aq08_topic_routing_verification_20260520\botcomponent_topics_inventory.txt",
    [string]$WorkflowSnapshotPath = ".planning\comms\aq08_topic_routing_verification_20260520\botcomponent_workflow_inventory.txt"
)

$ErrorActionPreference = "Stop"

function Invoke-PacReadOnly {
    param(
        [string[]]$Arguments,
        [string]$OutputPath
    )

    $pac = Get-Command pac -ErrorAction Stop
    $stderrPath = "$OutputPath.stderr"
    & $pac.Source @Arguments > $OutputPath 2> $stderrPath
    $exitCode = $LASTEXITCODE
    if ($null -eq $exitCode) {
        $exitCode = 0
    }
    if ($exitCode -ne 0) {
        $stderr = if (Test-Path -LiteralPath "$OutputPath.stderr") { Get-Content -LiteralPath "$OutputPath.stderr" -Raw } else { "" }
        throw "PAC command failed with exit code ${exitCode}: pac $($Arguments -join ' ')`n$stderr"
    }
}

function Get-TopicBlock {
    param(
        [string]$Text,
        [string]$TopicSchemaName
    )

    $escaped = [regex]::Escape($TopicSchemaName)
    $match = [regex]::Match($Text, "(?s)(?:^|\r?\n)[0-9a-fA-F-]{36}\s+.*?$escaped.*?(?=(?:\r?\n)[0-9a-fA-F-]{36}\s+|$)")
    if ($match.Success) {
        return $match.Value
    }

    $idx = $Text.IndexOf($TopicSchemaName, [System.StringComparison]::OrdinalIgnoreCase)
    if ($idx -lt 0) {
        return ""
    }

    $start = [Math]::Max(0, $idx - 1000)
    $length = [Math]::Min($Text.Length - $start, 20000)
    $Text.Substring($start, $length)
}

function Test-ContainsLiteral {
    param([string]$Text, [string]$Needle)
    if ([string]::IsNullOrWhiteSpace($Needle)) { return $false }
    $Text.IndexOf($Needle, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

$topicOut = Join-Path $EvidenceDir "botcomponent_topics_inventory_reverify.txt"
$workflowOut = Join-Path $EvidenceDir "botcomponent_workflow_inventory_reverify.txt"
$envOut = Join-Path $EvidenceDir "pac_env_who_reverify.txt"
$reportPath = Join-Path $EvidenceDir "aq08_post_remediation_reverify_report.json"

if ($UseExistingSnapshots) {
    Copy-Item -LiteralPath $TopicSnapshotPath -Destination $topicOut -Force
    Copy-Item -LiteralPath $WorkflowSnapshotPath -Destination $workflowOut -Force
    Set-Content -LiteralPath $envOut -Value "Skipped live PAC env check because -UseExistingSnapshots was supplied." -Encoding UTF8
}
else {
    Invoke-PacReadOnly -Arguments @("env", "who") -OutputPath $envOut
    Invoke-PacReadOnly -Arguments @("org", "fetch", "--environment", $config.environmentId, "--xmlFile", ".planning\comms\aq08_topic_routing_verification_20260520\fetch_botcomponent_topics_inventory.xml") -OutputPath $topicOut
    Invoke-PacReadOnly -Arguments @("org", "fetch", "--environment", $config.environmentId, "--xmlFile", ".planning\comms\aq08_topic_routing_verification_20260520\fetch_botcomponent_workflow_inventory.xml") -OutputPath $workflowOut
}

$topicText = Get-Content -LiteralPath $topicOut -Raw
$workflowText = Get-Content -LiteralPath $workflowOut -Raw
$topicResults = [System.Collections.Generic.List[object]]::new()

foreach ($topic in $config.inScopeTopics) {
    $block = Get-TopicBlock -Text $topicText -TopicSchemaName $topic.topicSchemaName
    $foundTopic = -not [string]::IsNullOrWhiteSpace($block)
    $hasExpectedAction = Test-ContainsLiteral -Text $block -Needle $topic.expectedActionComponent
    $legacyHits = @()
    foreach ($legacy in $topic.legacyForbidden) {
        if (Test-ContainsLiteral -Text $block -Needle $legacy) {
            $legacyHits += $legacy
        }
    }
    $workflowBound = (Test-ContainsLiteral -Text $workflowText -Needle $topic.expectedActionComponent) -and
        (Test-ContainsLiteral -Text $workflowText -Needle $topic.expectedWorkflowName) -and
        (Test-ContainsLiteral -Text $workflowText -Needle $topic.expectedWorkflowId)

    $status = if ($foundTopic -and $hasExpectedAction -and $legacyHits.Count -eq 0 -and $workflowBound) { "PASS" } else { "BLOCK" }

    $topicResults.Add([ordered]@{
        topicName = $topic.topicName
        topicSchemaName = $topic.topicSchemaName
        expectedActionComponent = $topic.expectedActionComponent
        expectedWorkflowId = $topic.expectedWorkflowId
        foundTopic = $foundTopic
        hasExpectedActionReferenceInTopic = $hasExpectedAction
        legacyHitsInTopic = $legacyHits
        expectedActionWorkflowBound = $workflowBound
        status = $status
    }) | Out-Null
}

$blocking = @($topicResults | Where-Object { $_.status -ne "PASS" })
$overall = if ($blocking.Count -eq 0) { "PASS" } else { "BLOCK" }

$report = [ordered]@{
    generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
    mode = if ($UseExistingSnapshots) { "ExistingSnapshots" } else { "LivePacReadOnly" }
    evidenceDir = (Resolve-Path -LiteralPath $EvidenceDir).Path
    overall = $overall
    blockingTopicCount = $blocking.Count
    topics = $topicResults
}

$json = $report | ConvertTo-Json -Depth 10
Set-Content -LiteralPath $reportPath -Value $json -Encoding UTF8
$json

if ($overall -ne "PASS") {
    exit 1
}
