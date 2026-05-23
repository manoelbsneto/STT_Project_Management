[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [DateTimeOffset]$PublishUtc,

    [Parameter(Mandatory)]
    [string]$OutputDir,

    [switch]$DryRun,

    [string]$ConfigPath = ".planning\comms\aq08_topic_routing_verification_20260520\expected_pm0_routing_post_remediation.json",
    [string]$TopicSnapshotPath,
    [string]$WorkflowSnapshotPath,
    [string]$ReverifyScriptPath
)

$ErrorActionPreference = "Stop"
$script:Utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$script:RepositoryRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($ReverifyScriptPath)) {
    $ReverifyScriptPath = Join-Path $PSScriptRoot "Test-Aq08PostRemediationReverify.ps1"
}
$script:InvocationUtc = [DateTimeOffset]::UtcNow

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )

    $parent = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    [System.IO.File]::WriteAllText($Path, $Content, $script:Utf8NoBom)
}

function Resolve-RequiredFile {
    param(
        [string]$Path,
        [string]$Description
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "$Description path is required."
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Description file not found: $Path"
    }

    (Resolve-Path -LiteralPath $Path).Path
}

function Wait-ForPassWindow {
    param([DateTimeOffset]$TargetUtc)

    while ([DateTimeOffset]::UtcNow -lt $TargetUtc) {
        $remainingSeconds = [Math]::Ceiling(($TargetUtc - [DateTimeOffset]::UtcNow).TotalSeconds)
        Start-Sleep -Seconds ([Math]::Max(1, [Math]::Min(60, $remainingSeconds)))
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
        return $match.Value.TrimStart("`r", "`n")
    }

    throw "Topic block not found in captured topic inventory: $TopicSchemaName"
}

function Get-TopicData {
    param(
        [string]$TopicBlock,
        [string]$TopicSchemaName
    )

    # PAC prints data as the final botcomponent table column. The localized component
    # type token is the last metadata field before the data text begins.
    $match = [regex]::Match($TopicBlock, "(?s)\b(?:Tema|Topic)\s+\(V2\)\s+(?<data>.*)$")
    if (-not $match.Success) {
        throw "Could not isolate botcomponent.data for $TopicSchemaName from the PAC topic inventory."
    }

    return $match.Groups["data"].Value
}

function Get-Sha256Text {
    param([string]$Text)

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $hashBytes = $sha256.ComputeHash($bytes)
        return (($hashBytes | ForEach-Object { $_.ToString("x2") }) -join "")
    }
    finally {
        $sha256.Dispose()
    }
}

function Get-MarkdownTableValue {
    param([object]$Value)

    if ($null -eq $Value) {
        return ""
    }

    return ([string]$Value).Replace("|", "\|").Replace("`r", " ").Replace("`n", " ")
}

function Write-PassSummary {
    param(
        [string]$Path,
        [object]$Pass
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# AQ-08 Publish Drift Pass $($Pass.label)") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- publish_utc: $($Pass.publishUtc)") | Out-Null
    $lines.Add("- invocation_utc: $($Pass.invocationUtc)") | Out-Null
    $lines.Add("- scheduled_utc: $($Pass.scheduledUtc)") | Out-Null
    $lines.Add("- observed_utc: $($Pass.observedUtc)") | Out-Null
    $lines.Add("- mode: $($Pass.mode)") | Out-Null
    $lines.Add("- decision: $($Pass.decision)") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Topic | Topic schema | Status | botcomponent.data SHA256 | Captured data |") | Out-Null
    $lines.Add("|---|---|---|---|---|") | Out-Null
    foreach ($topic in $Pass.topics) {
        $lines.Add("| $(Get-MarkdownTableValue $topic.topicName) | ``$(Get-MarkdownTableValue $topic.topicSchemaName)`` | $(Get-MarkdownTableValue $topic.status) | ``$(Get-MarkdownTableValue $topic.fingerprint)`` | ``$(Get-MarkdownTableValue $topic.dataPath)`` |") | Out-Null
    }
    $lines.Add("") | Out-Null

    Write-Utf8NoBom -Path $Path -Content ($lines -join "`n")
}

function Invoke-ReverifyPass {
    param(
        [object]$PassDefinition,
        [string]$PassDir,
        [string]$ConfigFile,
        [string]$TopicSnapshotFile,
        [string]$WorkflowSnapshotFile,
        [string]$ReverifyScript,
        [DateTimeOffset]$InvocationUtc,
        [DateTimeOffset]$PublishLabelUtc,
        [object[]]$ConfigTopics
    )

    New-Item -ItemType Directory -Force -Path $PassDir | Out-Null
    $stdoutPath = Join-Path $PassDir "reverify_stdout.json"
    $stderrPath = Join-Path $PassDir "reverify_stderr.txt"
    $reverifyArgs = @{
        ConfigPath = $ConfigFile
        EvidenceDir = $PassDir
    }
    if ($DryRun) {
        $reverifyArgs.UseExistingSnapshots = $true
        $reverifyArgs.TopicSnapshotPath = $TopicSnapshotFile
        $reverifyArgs.WorkflowSnapshotPath = $WorkflowSnapshotFile
    }

    $global:LASTEXITCODE = 0
    Push-Location $script:RepositoryRoot
    try {
        & $ReverifyScript @reverifyArgs 1> $stdoutPath 2> $stderrPath
        $reverifyExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
    }
    finally {
        Pop-Location
    }

    $reportPath = Join-Path $PassDir "aq08_post_remediation_reverify_report.json"
    if (-not (Test-Path -LiteralPath $reportPath -PathType Leaf)) {
        throw "Reverify pass $($PassDefinition.label) did not produce $reportPath. See $stderrPath."
    }

    $report = Get-Content -LiteralPath $reportPath -Raw -Encoding UTF8 | ConvertFrom-Json
    $topicInventoryPath = Join-Path $PassDir "botcomponent_topics_inventory_reverify.txt"
    $topicInventory = Get-Content -LiteralPath $topicInventoryPath -Raw -Encoding UTF8
    $statusBySchemaName = @{}
    foreach ($topicResult in $report.topics) {
        $statusBySchemaName[$topicResult.topicSchemaName] = $topicResult.status
    }

    $capturedTopics = [System.Collections.Generic.List[object]]::new()
    foreach ($topic in $ConfigTopics) {
        $block = Get-TopicBlock -Text $topicInventory -TopicSchemaName $topic.topicSchemaName
        $data = Get-TopicData -TopicBlock $block -TopicSchemaName $topic.topicSchemaName
        $dataRelativePath = Join-Path "topic_data" "$($topic.topicName).botcomponent.data.txt"
        $dataPath = Join-Path $PassDir $dataRelativePath
        Write-Utf8NoBom -Path $dataPath -Content $data
        $capturedTopics.Add([pscustomobject]@{
            topicName = $topic.topicName
            topicSchemaName = $topic.topicSchemaName
            status = if ($statusBySchemaName.ContainsKey($topic.topicSchemaName)) { $statusBySchemaName[$topic.topicSchemaName] } else { "BLOCK" }
            fingerprint = Get-Sha256Text -Text $data
            dataPath = $dataRelativePath.Replace("\", "/")
        }) | Out-Null
    }

    $pass = [pscustomobject]@{
        label = $PassDefinition.label
        publishUtc = $PublishLabelUtc.ToUniversalTime().ToString("o")
        invocationUtc = $InvocationUtc.ToUniversalTime().ToString("o")
        scheduledUtc = $PassDefinition.targetUtc.ToUniversalTime().ToString("o")
        observedUtc = [DateTimeOffset]::UtcNow.ToString("o")
        mode = if ($DryRun) { "DryRunExistingSnapshots" } else { "LivePacReadOnly" }
        reverifyExitCode = $reverifyExitCode
        decision = $report.overall
        reportPath = "aq08_post_remediation_reverify_report.json"
        topics = @($capturedTopics)
    }
    Write-PassSummary -Path (Join-Path $PassDir "summary.md") -Pass $pass

    return $pass
}

function Get-FingerprintForTopic {
    param(
        [object]$Pass,
        [string]$TopicSchemaName
    )

    $topic = @($Pass.topics | Where-Object { $_.topicSchemaName -eq $TopicSchemaName })[0]
    if ($null -eq $topic) {
        return $null
    }

    return $topic.fingerprint
}

function Test-FingerprintChange {
    param(
        [object]$EarlierPass,
        [object]$LaterPass,
        [string]$TopicSchemaName
    )

    (Get-FingerprintForTopic -Pass $EarlierPass -TopicSchemaName $TopicSchemaName) -ne
        (Get-FingerprintForTopic -Pass $LaterPass -TopicSchemaName $TopicSchemaName)
}

function Write-DriftDecision {
    param(
        [string]$Path,
        [object[]]$Passes,
        [object[]]$ConfigTopics,
        [string]$Recommendation,
        [bool]$HasDrift,
        [bool]$HasBlockRegression,
        [DateTimeOffset]$InvocationUtc,
        [DateTimeOffset]$PublishLabelUtc
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("# AQ-08 Publish Drift Decision") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- publish_utc: $($PublishLabelUtc.ToUniversalTime().ToString("o"))") | Out-Null
    $lines.Add("- invocation_utc: $($InvocationUtc.ToUniversalTime().ToString("o"))") | Out-Null
    $lines.Add("- mode: $(if ($DryRun) { "DryRunExistingSnapshots" } else { "LivePacReadOnly" })") | Out-Null
    $lines.Add("- recommendation: **$Recommendation**") | Out-Null
    $lines.Add("- fingerprint_drift_detected: $HasDrift") | Out-Null
    $lines.Add("- pass_to_block_regression_detected: $HasBlockRegression") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Passes") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Pass | Scheduled UTC | Observed UTC | Decision |") | Out-Null
    $lines.Add("|---|---|---|---|") | Out-Null
    foreach ($pass in $Passes) {
        $lines.Add("| $(Get-MarkdownTableValue $pass.label) | ``$(Get-MarkdownTableValue $pass.scheduledUtc)`` | ``$(Get-MarkdownTableValue $pass.observedUtc)`` | $(Get-MarkdownTableValue $pass.decision) |") | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Cross-Pass Diff") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Topic | T+5min -> T+1h fingerprint changed | T+1h -> T+6h fingerprint changed |") | Out-Null
    $lines.Add("|---|---|---|") | Out-Null
    foreach ($topic in $ConfigTopics) {
        $firstChange = Test-FingerprintChange -EarlierPass $Passes[0] -LaterPass $Passes[1] -TopicSchemaName $topic.topicSchemaName
        $secondChange = Test-FingerprintChange -EarlierPass $Passes[1] -LaterPass $Passes[2] -TopicSchemaName $topic.topicSchemaName
        $lines.Add("| $(Get-MarkdownTableValue $topic.topicName) | $(if ($firstChange) { "YES" } else { "NO" }) | $(if ($secondChange) { "YES" } else { "NO" }) |") | Out-Null
    }
    $lines.Add("") | Out-Null

    Write-Utf8NoBom -Path $Path -Content ($lines -join "`n")
}

if ($PublishUtc.ToUniversalTime() -lt $script:InvocationUtc.AddHours(-6)) {
    throw "-PublishUtc is more than six hours behind current UTC; the post-publish monitor window has already been missed."
}

$fixtureRoot = Join-Path $PSScriptRoot "fixtures\aq08_drift_monitor"
if ($DryRun) {
    if (-not $PSBoundParameters.ContainsKey("ConfigPath")) {
        $ConfigPath = Join-Path $fixtureRoot "expected_pm0_routing_dry_run.json"
    }
    if (-not $PSBoundParameters.ContainsKey("TopicSnapshotPath")) {
        $TopicSnapshotPath = Join-Path $fixtureRoot "captured_immediate_pass\botcomponent_topics_inventory_reverify.txt"
    }
    if (-not $PSBoundParameters.ContainsKey("WorkflowSnapshotPath")) {
        $WorkflowSnapshotPath = Join-Path $fixtureRoot "captured_immediate_pass\botcomponent_workflow_inventory_reverify.txt"
    }
}

$configFile = Resolve-RequiredFile -Path $ConfigPath -Description "AQ-08 routing config"
$reverifyScript = Resolve-RequiredFile -Path $ReverifyScriptPath -Description "AQ-08 reverifier script"
$topicSnapshotFile = if ($DryRun) { Resolve-RequiredFile -Path $TopicSnapshotPath -Description "Dry-run topic snapshot" } else { $null }
$workflowSnapshotFile = if ($DryRun) { Resolve-RequiredFile -Path $WorkflowSnapshotPath -Description "Dry-run workflow snapshot" } else { $null }
$config = Get-Content -LiteralPath $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
$invocationUtc = $script:InvocationUtc

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$resolvedOutputDir = (Resolve-Path -LiteralPath $OutputDir).Path
$passDefinitions = @(
    [pscustomobject]@{ label = "T+5min"; targetUtc = $invocationUtc.AddMinutes(5) },
    [pscustomobject]@{ label = "T+1h"; targetUtc = $invocationUtc.AddHours(1) },
    [pscustomobject]@{ label = "T+6h"; targetUtc = $invocationUtc.AddHours(6) }
)

$passes = [System.Collections.Generic.List[object]]::new()
foreach ($passDefinition in $passDefinitions) {
    if (-not $DryRun) {
        Wait-ForPassWindow -TargetUtc $passDefinition.targetUtc
    }

    $pass = Invoke-ReverifyPass `
        -PassDefinition $passDefinition `
        -PassDir (Join-Path $resolvedOutputDir $passDefinition.label) `
        -ConfigFile $configFile `
        -TopicSnapshotFile $topicSnapshotFile `
        -WorkflowSnapshotFile $workflowSnapshotFile `
        -ReverifyScript $reverifyScript `
        -InvocationUtc $invocationUtc `
        -PublishLabelUtc $PublishUtc `
        -ConfigTopics @($config.inScopeTopics)
    $passes.Add($pass) | Out-Null
}

$hasFingerprintDrift = $false
foreach ($topic in $config.inScopeTopics) {
    if ((Test-FingerprintChange -EarlierPass $passes[0] -LaterPass $passes[1] -TopicSchemaName $topic.topicSchemaName) -or
        (Test-FingerprintChange -EarlierPass $passes[1] -LaterPass $passes[2] -TopicSchemaName $topic.topicSchemaName)) {
        $hasFingerprintDrift = $true
        break
    }
}

$hasBlockRegression = $false
for ($i = 1; $i -lt $passes.Count; $i++) {
    if ($passes[$i - 1].decision -eq "PASS" -and $passes[$i].decision -eq "BLOCK") {
        $hasBlockRegression = $true
        break
    }
}

$allPass = @($passes | Where-Object { $_.decision -eq "PASS" }).Count -eq $passes.Count
$recommendation = if ($hasFingerprintDrift -or $hasBlockRegression) {
    "ROLLBACK"
}
elseif ($allPass) {
    "SHIP"
}
else {
    "HOLD"
}

$decisionPath = Join-Path $resolvedOutputDir "DRIFT_DECISION.md"
Write-DriftDecision `
    -Path $decisionPath `
    -Passes @($passes) `
    -ConfigTopics @($config.inScopeTopics) `
    -Recommendation $recommendation `
    -HasDrift $hasFingerprintDrift `
    -HasBlockRegression $hasBlockRegression `
    -InvocationUtc $invocationUtc `
    -PublishLabelUtc $PublishUtc

$result = [ordered]@{
    publishUtc = $PublishUtc.ToUniversalTime().ToString("o")
    invocationUtc = $invocationUtc.ToUniversalTime().ToString("o")
    mode = if ($DryRun) { "DryRunExistingSnapshots" } else { "LivePacReadOnly" }
    outputDir = $resolvedOutputDir
    driftDecisionPath = $decisionPath
    recommendation = $recommendation
    fingerprintDriftDetected = $hasFingerprintDrift
    passToBlockRegressionDetected = $hasBlockRegression
    passes = @($passes)
}
$result | ConvertTo-Json -Depth 12

if ($recommendation -ne "SHIP") {
    exit 1
}
