[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..\..')).Path
$unpackedRoot = Join-Path $PSScriptRoot 'unpacked_base'
$baseUnpackedRoot = Join-Path $repoRoot '.planning\comms\solution_3_15_list_static_runtime_bypass_20260514\unpacked'
$fixedYamlRoot = Join-Path $repoRoot '.planning\comms\aq08_topic_routing_verification_20260520\post_remediation_reverify\fixed_topic_yamls'
$hotfixZip = Join-Path $repoRoot 'Solution\PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip'
$evidencePath = Join-Path $PSScriptRoot 'QA_EVIDENCE_HOTFIX_TOPICS.md'
$solutionXmlPath = Join-Path $unpackedRoot 'solution.xml'

$topics = @(
    [pscustomobject]@{ Name = 'AtualizarStatus'; Folder = 'pmo_AssistentePMO_V2.topic.AtualizarStatus'; Guid = 'ec4416d0-0744-4e8c-b937-aae4ad9c605b'; Action = 'PM0_PA_Card_AtualizarStatus' }
    [pscustomobject]@{ Name = 'AtualizarTarefa'; Folder = 'pmo_AssistentePMO_V2.topic.AtualizarTarefa'; Guid = '6750ff2f-822b-45ab-83ec-058704c7808a'; Action = 'PM0_PA_Card_AtualizarTarefa' }
    [pscustomobject]@{ Name = 'ConsultarPortfolio'; Folder = 'pmo_AssistentePMO_V2.topic.ConsultarPortfolio'; Guid = '74c5fdcc-c121-452e-85af-24d3f260b3c7'; Action = 'PM0_PA_Card_ResumoExecutivoPortfolio' }
    [pscustomobject]@{ Name = 'CriarTarefa'; Folder = 'pmo_AssistentePMO_V2.topic.CriarTarefa'; Guid = 'bcbecd76-3158-40ac-b225-5ae7c3874ed1'; Action = 'PM0_PA_Card_CriarTarefa' }
    [pscustomobject]@{ Name = 'ListarTarefas'; Folder = 'pmo_AssistentePMO_V2.topic.ListarTarefas'; Guid = 'd58258b4-b17f-4bb9-9e1f-161287a041c4'; Action = 'PM0_PA_Card_ListarTarefas' }
)

$gateRows = [System.Collections.Generic.List[object]]::new()
$evidence = [System.Collections.Generic.List[string]]::new()

function Add-GateRow {
    param(
        [Parameter(Mandatory = $true)][string]$Gate,
        [Parameter(Mandatory = $true)][string]$Status,
        [Parameter(Mandatory = $true)][string]$Detail
    )

    $gateRows.Add([pscustomobject]@{
        Gate = $Gate
        Status = $Status
        Detail = $Detail
    })
}

function Add-NotRunRows {
    param([Parameter(Mandatory = $true)][string]$AfterGate)

    foreach ($gate in 'G1','G2','G3','G4','G5','G6','G7','G8','G9') {
        if (-not ($gateRows.Gate -contains $gate)) {
            Add-GateRow -Gate $gate -Status 'NOT RUN' -Detail "Stopped after $AfterGate FAIL."
        }
    }
}

function Get-RelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Root,
        [Parameter(Mandatory = $true)][string]$Path
    )

    return $Path.Substring($Root.Length).TrimStart('\')
}

function Test-ByteEqual {
    param(
        [Parameter(Mandatory = $true)][string]$Left,
        [Parameter(Mandatory = $true)][string]$Right
    )

    if (-not (Test-Path -LiteralPath $Left) -or -not (Test-Path -LiteralPath $Right)) {
        return $false
    }

    return (Get-FileHash -LiteralPath $Left -Algorithm SHA256).Hash -eq
        (Get-FileHash -LiteralPath $Right -Algorithm SHA256).Hash
}

function Get-TopicDataPath {
    param([Parameter(Mandatory = $true)][object]$Topic)

    return Join-Path $unpackedRoot "botcomponents\$($Topic.Folder)\data"
}

function Get-SendActivityTopicRefs {
    param([Parameter(Mandatory = $true)][string]$TopicText)

    $refs = [System.Collections.Generic.List[string]]::new()
    foreach ($line in ($TopicText -split "\r?\n")) {
        if ($line -notmatch '^\s+activity:\s+') {
            continue
        }

        foreach ($match in [regex]::Matches($line, '\{Topic\.([A-Za-z0-9_]+)\}')) {
            $refs.Add($match.Groups[1].Value)
        }
    }

    return @($refs | Sort-Object -Unique)
}

function Write-Evidence {
    param([Parameter(Mandatory = $true)][string]$Decision)

    $evidence.Clear()
    $evidence.Add('# QA Evidence - 3.15.1 Hotfix Topics Phase B')
    $evidence.Add('')
    $evidence.Add('Date BRT: 2026-05-21')
    $evidence.Add('')
    $evidence.Add("Artifact: ``Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip``")
    $evidence.Add("OverallDecision: **$Decision**")
    $evidence.Add('')
    $evidence.Add('| Gate | Status | Evidence |')
    $evidence.Add('|---|---|---|')
    foreach ($row in $gateRows) {
        $detail = $row.Detail.Replace('|', '\|')
        $evidence.Add("| $($row.Gate) | $($row.Status) | $detail |")
    }
    $evidence.Add('')
    $evidence.Add('## Stop Rule')
    $evidence.Add('')
    if ($Decision -eq 'PASS') {
        $evidence.Add('All Phase B gates completed.')
    }
    else {
        $evidence.Add('Phase B stopped at the first failing gate per dispatch.')
    }
    $evidence.Add('')
    $evidence.Add('## Inputs')
    $evidence.Add('')
    $evidence.Add("- Hotfix ZIP: ``$hotfixZip``")
    $evidence.Add("- Unpacked hotfix tree: ``$unpackedRoot``")
    $evidence.Add("- Base 3.15 unpacked tree: ``$baseUnpackedRoot``")
    $evidence.Add("- Fixed topic YAMLs: ``$fixedYamlRoot``")

    Set-Content -LiteralPath $evidencePath -Value $evidence -Encoding utf8
}

$zipEntryCount = 0
$zipOk = $false
$xmlOk = $false
$workflowRootCount = 0
$workflowFileCount = 0
$topicRootCount = 0
$topicDataCount = 0

try {
    $zip = [System.IO.Compression.ZipFile]::OpenRead($hotfixZip)
    try {
        $zipEntryCount = $zip.Entries.Count
        $zipOk = $true
    }
    finally {
        $zip.Dispose()
    }
}
catch {
    $zipOk = $false
}

try {
    [xml]$solutionXml = Get-Content -LiteralPath $solutionXmlPath -Raw
    $xmlOk = $true
    $rootComponents = @($solutionXml.ImportExportXml.SolutionManifest.RootComponents.RootComponent)
    $workflowRootCount = @($rootComponents | Where-Object { $_.type -eq '29' }).Count
    $topicRootCount = @($rootComponents | Where-Object { $_.type -eq 'botcomponent' }).Count
}
catch {
    $xmlOk = $false
}

$workflowFileCount = @(Get-ChildItem -LiteralPath (Join-Path $unpackedRoot 'Workflows') -Recurse -File -Filter '*.json').Count
$topicDataCount = @($topics | Where-Object {
    Test-Path -LiteralPath (Join-Path $unpackedRoot "botcomponents\$($_.Folder)\data")
}).Count
$g1Ok = $zipOk -and $xmlOk -and $workflowRootCount -eq $workflowFileCount -and $topicRootCount -eq $topicDataCount
$g1Detail = "zipEntries=$zipEntryCount; xml=$xmlOk; workflowRoots=$workflowRootCount; workflowFiles=$workflowFileCount; topicRoots=$topicRootCount; topicDataFiles=$topicDataCount"
Add-GateRow -Gate 'G1' -Status $(if ($g1Ok) { 'PASS' } else { 'FAIL' }) -Detail $g1Detail
if (-not $g1Ok) {
    Add-NotRunRows -AfterGate 'G1'
    Write-Evidence -Decision 'FAIL'
    $gateRows | Format-Table -AutoSize
    exit 1
}

$baseWorkflowFiles = @(Get-ChildItem -LiteralPath (Join-Path $baseUnpackedRoot 'Workflows') -Recurse -File -Filter '*.json')
$mismatchedWorkflows = [System.Collections.Generic.List[string]]::new()
foreach ($baseWorkflowFile in $baseWorkflowFiles) {
    $relative = Get-RelativePath -Root (Join-Path $baseUnpackedRoot 'Workflows') -Path $baseWorkflowFile.FullName
    $rebuiltWorkflowFile = Join-Path (Join-Path $unpackedRoot 'Workflows') $relative
    if (-not (Test-ByteEqual -Left $baseWorkflowFile.FullName -Right $rebuiltWorkflowFile)) {
        $mismatchedWorkflows.Add($relative)
    }
}
$g2Ok = $baseWorkflowFiles.Count -gt 0 -and $mismatchedWorkflows.Count -eq 0
$g2Detail = "workflowFilesCompared=$($baseWorkflowFiles.Count); mismatches=$($mismatchedWorkflows.Count)"
if ($mismatchedWorkflows.Count -gt 0) {
    $g2Detail += "; firstMismatch=$($mismatchedWorkflows[0])"
}
Add-GateRow -Gate 'G2' -Status $(if ($g2Ok) { 'PASS' } else { 'FAIL' }) -Detail $g2Detail
if (-not $g2Ok) {
    Add-NotRunRows -AfterGate 'G2'
    Write-Evidence -Decision 'FAIL'
    $gateRows | Format-Table -AutoSize
    exit 1
}

$topicDataMismatches = [System.Collections.Generic.List[string]]::new()
foreach ($topic in $topics) {
    $topicData = Get-TopicDataPath -Topic $topic
    $fixedYaml = Join-Path $fixedYamlRoot "$($topic.Name).yaml"
    if (-not (Test-ByteEqual -Left $topicData -Right $fixedYaml)) {
        $topicDataMismatches.Add($topic.Name)
    }
}
$g3Ok = $topicDataMismatches.Count -eq 0
$g3Detail = "topicDataFilesCompared=$($topics.Count); mismatches=$($topicDataMismatches.Count)"
if ($topicDataMismatches.Count -gt 0) {
    $g3Detail += "; mismatchedTopics=$($topicDataMismatches -join ',')"
}
Add-GateRow -Gate 'G3' -Status $(if ($g3Ok) { 'PASS' } else { 'FAIL' }) -Detail $g3Detail
if (-not $g3Ok) {
    Add-NotRunRows -AfterGate 'G3'
    Write-Evidence -Decision 'FAIL'
    $gateRows | Format-Table -AutoSize
    exit 1
}

$manifestTopicIds = @($rootComponents |
    Where-Object { $_.type -eq 'botcomponent' } |
    ForEach-Object { $_.id.Trim('{}').ToLowerInvariant() } |
    Sort-Object)
$expectedTopicIds = @($topics | ForEach-Object { $_.Guid.ToLowerInvariant() } | Sort-Object)
$g4Ok = ($manifestTopicIds.Count -eq $expectedTopicIds.Count) -and
    -not (Compare-Object -ReferenceObject $expectedTopicIds -DifferenceObject $manifestTopicIds)
$g4Detail = "manifestTopicIds=$($manifestTopicIds.Count); expectedTopicIds=$($expectedTopicIds.Count); ids=$($manifestTopicIds -join ',')"
Add-GateRow -Gate 'G4' -Status $(if ($g4Ok) { 'PASS' } else { 'FAIL' }) -Detail $g4Detail
if (-not $g4Ok) {
    Add-NotRunRows -AfterGate 'G4'
    Write-Evidence -Decision 'FAIL'
    $gateRows | Format-Table -AutoSize
    exit 1
}

$invalidBindingKeys = [System.Collections.Generic.List[string]]::new()
foreach ($topic in $topics) {
    $topicData = Get-TopicDataPath -Topic $topic
    $topicText = Get-Content -LiteralPath $topicData -Raw
    $hasResultBinding = $topicText -match '(?m)^\s+result:\s+Topic\.[A-Za-z0-9_]+\s*$'
    $hasMessageBinding = $topicText -match '(?m)^\s+message:\s+Topic\.[A-Za-z0-9_]+\s*$'
    if (-not $hasResultBinding -or $hasMessageBinding) {
        $invalidBindingKeys.Add("$($topic.Name)(result=$hasResultBinding,message=$hasMessageBinding)")
    }
}
$g5Ok = $invalidBindingKeys.Count -eq 0
$g5Detail = "topicsChecked=$($topics.Count); invalidBindingKeys=$($invalidBindingKeys.Count)"
if ($invalidBindingKeys.Count -gt 0) {
    $g5Detail += "; invalid=$($invalidBindingKeys -join ',')"
}
Add-GateRow -Gate 'G5' -Status $(if ($g5Ok) { 'PASS' } else { 'FAIL' }) -Detail $g5Detail
if (-not $g5Ok) {
    Add-NotRunRows -AfterGate 'G5'
    Write-Evidence -Decision 'FAIL'
    $gateRows | Format-Table -AutoSize
    exit 1
}

$bindingReferenceMismatches = [System.Collections.Generic.List[string]]::new()
$bindingReferenceDetails = [System.Collections.Generic.List[string]]::new()
foreach ($topic in $topics) {
    $topicText = Get-Content -LiteralPath (Get-TopicDataPath -Topic $topic) -Raw
    $bindingMatches = [regex]::Matches($topicText, '(?m)^\s+result:\s+Topic\.([A-Za-z0-9_]+)\s*$')
    $bindingVars = @($bindingMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    $sendRefs = @(Get-SendActivityTopicRefs -TopicText $topicText)
    $mismatchedRefs = @($sendRefs | Where-Object { $bindingVars -notcontains $_ })
    $topicOk = $bindingVars.Count -eq 1 -and $mismatchedRefs.Count -eq 0
    $bindingReferenceDetails.Add("$($topic.Name):binding=$($bindingVars -join '+');sendRefs=$($sendRefs -join '+')")
    if (-not $topicOk) {
        $bindingReferenceMismatches.Add("$($topic.Name)(binding=$($bindingVars -join '+'),sendRefs=$($sendRefs -join '+'))")
    }
}
$g6Ok = $bindingReferenceMismatches.Count -eq 0
$g6Detail = "topicsChecked=$($topics.Count); mismatches=$($bindingReferenceMismatches.Count); $($bindingReferenceDetails -join '; ')"
if ($bindingReferenceMismatches.Count -gt 0) {
    $g6Detail += "; invalid=$($bindingReferenceMismatches -join ',')"
}
Add-GateRow -Gate 'G6' -Status $(if ($g6Ok) { 'PASS' } else { 'FAIL' }) -Detail $g6Detail
if (-not $g6Ok) {
    Add-NotRunRows -AfterGate 'G6'
    Write-Evidence -Decision 'FAIL'
    $gateRows | Format-Table -AutoSize
    exit 1
}

$legacyActionRefs = [System.Collections.Generic.List[string]]::new()
foreach ($topic in $topics) {
    $topicText = Get-Content -LiteralPath (Get-TopicDataPath -Topic $topic) -Raw
    if ($topicText -match 'PMO_PA_[A-Za-z0-9_]+') {
        $legacyActionRefs.Add($topic.Name)
    }
}
$g7Ok = $legacyActionRefs.Count -eq 0
$g7Detail = "topicsChecked=$($topics.Count); legacyTopicRefs=$($legacyActionRefs.Count)"
if ($legacyActionRefs.Count -gt 0) {
    $g7Detail += "; topics=$($legacyActionRefs -join ',')"
}
Add-GateRow -Gate 'G7' -Status $(if ($g7Ok) { 'PASS' } else { 'FAIL' }) -Detail $g7Detail
if (-not $g7Ok) {
    Add-NotRunRows -AfterGate 'G7'
    Write-Evidence -Decision 'FAIL'
    $gateRows | Format-Table -AutoSize
    exit 1
}

$nonAsciiTopics = [System.Collections.Generic.List[string]]::new()
foreach ($topic in $topics) {
    $topicText = Get-Content -LiteralPath (Get-TopicDataPath -Topic $topic) -Raw
    if ($topicText -match '[^\x00-\x7F]') {
        $nonAsciiTopics.Add($topic.Name)
    }
}
$g8Ok = $nonAsciiTopics.Count -eq 0
$g8Detail = "topicsChecked=$($topics.Count); nonAsciiTopics=$($nonAsciiTopics.Count)"
if ($nonAsciiTopics.Count -gt 0) {
    $g8Detail += "; topics=$($nonAsciiTopics -join ',')"
}
Add-GateRow -Gate 'G8' -Status $(if ($g8Ok) { 'PASS' } else { 'FAIL' }) -Detail $g8Detail
if (-not $g8Ok) {
    Add-NotRunRows -AfterGate 'G8'
    Write-Evidence -Decision 'FAIL'
    $gateRows | Format-Table -AutoSize
    exit 1
}

$unexpectedActions = [System.Collections.Generic.List[string]]::new()
$missingActions = [System.Collections.Generic.List[string]]::new()
foreach ($topic in $topics) {
    $topicText = Get-Content -LiteralPath (Get-TopicDataPath -Topic $topic) -Raw
    $actionMatches = [regex]::Matches($topicText, 'PM0_PA_Card_[A-Za-z0-9_]+')
    $actions = @($actionMatches | ForEach-Object { $_.Value } | Sort-Object -Unique)
    if ($actions.Count -ne 1 -or $actions[0] -ne $topic.Action) {
        $unexpectedActions.Add("$($topic.Name)=$($actions -join '+')")
    }
    if ($topicText -notmatch [regex]::Escape($topic.Action)) {
        $missingActions.Add($topic.Name)
    }
}
$g9Ok = $unexpectedActions.Count -eq 0 -and $missingActions.Count -eq 0
$g9Detail = "topicsChecked=$($topics.Count); expectedActions=$($topics.Action -join ','); unexpected=$($unexpectedActions.Count); missing=$($missingActions.Count)"
if ($unexpectedActions.Count -gt 0) {
    $g9Detail += "; unexpectedTopics=$($unexpectedActions -join ',')"
}
if ($missingActions.Count -gt 0) {
    $g9Detail += "; missingTopics=$($missingActions -join ',')"
}
Add-GateRow -Gate 'G9' -Status $(if ($g9Ok) { 'PASS' } else { 'FAIL' }) -Detail $g9Detail
Write-Evidence -Decision $(if ($g9Ok) { 'PASS' } else { 'FAIL' })
$gateRows | Format-Table -AutoSize
exit $(if ($g9Ok) { 0 } else { 1 })
