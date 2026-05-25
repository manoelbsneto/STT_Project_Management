[CmdletBinding()]
param(
    [string]$PackagePath = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip",
    [string]$McsSourceRoot = "Local_Repo/Assistente PMO V2",
    [string]$EvidenceDir = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/evidence",
    [string]$DiffDir = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/diffs"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Resolve-RepoPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }
    [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Write-Utf8Text {
    param([string]$Path, [string]$Text)
    $directory = Split-Path -Parent $Path
    if ($directory) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

function Get-Sha256FromText {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        return ([System.BitConverter]::ToString($sha.ComputeHash($bytes))).Replace("-", "")
    }
    finally {
        $sha.Dispose()
    }
}

function Read-ZipEntryText {
    param([System.IO.Compression.ZipArchive]$Zip, [string]$EntryName)
    $entry = $Zip.GetEntry($EntryName)
    if ($null -eq $entry) {
        return $null
    }

    $reader = New-Object System.IO.StreamReader($entry.Open(), [System.Text.Encoding]::UTF8)
    try {
        return $reader.ReadToEnd()
    }
    finally {
        $reader.Dispose()
    }
}

function Add-LeafValues {
    param([object]$Node, [string]$Path, [hashtable]$Map)

    if ($null -eq $Node) {
        $Map[$Path] = "<null>"
        return
    }

    if ($Node -is [System.Collections.IDictionary]) {
        foreach ($key in $Node.Keys) {
            Add-LeafValues -Node $Node[$key] -Path "$Path.$key" -Map $Map
        }
        return
    }

    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string]) -and -not ($Node -is [pscustomobject])) {
        $index = 0
        foreach ($item in $Node) {
            Add-LeafValues -Node $item -Path "$Path[$index]" -Map $Map
            $index++
        }
        if ($index -eq 0) {
            $Map[$Path] = "[]"
        }
        return
    }

    if ($Node -is [pscustomobject]) {
        $properties = @($Node.PSObject.Properties)
        if ($properties.Count -eq 0) {
            $Map[$Path] = "{}"
        }
        foreach ($property in $properties) {
            Add-LeafValues -Node $property.Value -Path "$Path.$($property.Name)" -Map $Map
        }
        return
    }

    $Map[$Path] = [string]$Node
}

function Get-DiffClassification {
    param([pscustomobject]$Diff)

    if ($Diff.Path -match '^\$\.properties\.connectionReferences\.[^.]+\.(source|runtimeSource)$') {
        return [pscustomobject]@{
            Classification = "INTENTIONAL_PACKAGER"
            Reason = "Builder normalizes invoker connection-reference source metadata to embedded package metadata."
        }
    }

    if ($Diff.Path -match '^\$\.properties\.definition\.actions\.[^.]+\.inputs\.authentication(\.(type|value))?$') {
        return [pscustomobject]@{
            Classification = "INTENTIONAL_PACKAGER"
            Reason = "Builder replaces raw APIM token authentication object with package authentication parameter reference."
        }
    }

    return [pscustomobject]@{
        Classification = "UNEXPLAINED"
        Reason = "No builder normalization rule matched this field."
    }
}

function Compare-WorkflowLeafValues {
    param([string]$LocalJson, [string]$PackageJson)

    $localValues = @{}
    $packageValues = @{}
    Add-LeafValues -Node ($LocalJson | ConvertFrom-Json) -Path '$' -Map $localValues
    Add-LeafValues -Node ($PackageJson | ConvertFrom-Json) -Path '$' -Map $packageValues

    $diffs = foreach ($key in @($localValues.Keys + $packageValues.Keys | Sort-Object -Unique)) {
        if (-not $localValues.ContainsKey($key)) {
            [pscustomobject]@{ Change = "ONLY_PACKAGE"; Path = $key; Local = ""; Package = $packageValues[$key] }
            continue
        }
        if (-not $packageValues.ContainsKey($key)) {
            [pscustomobject]@{ Change = "ONLY_LOCAL"; Path = $key; Local = $localValues[$key]; Package = "" }
            continue
        }
        if ($localValues[$key] -ne $packageValues[$key]) {
            [pscustomobject]@{ Change = "VALUE"; Path = $key; Local = $localValues[$key]; Package = $packageValues[$key] }
        }
    }

    foreach ($diff in @($diffs)) {
        $classification = Get-DiffClassification -Diff $diff
        $diff | Add-Member -NotePropertyName Classification -NotePropertyValue $classification.Classification
        $diff | Add-Member -NotePropertyName Reason -NotePropertyValue $classification.Reason
    }
    return @($diffs)
}

function Convert-ToMarkdownCell {
    param([string]$Value)
    if ($null -eq $Value) {
        return ""
    }
    return (($Value -replace '\|', '\|' -replace "`r?`n", " ") | ForEach-Object {
        if ($_.Length -gt 140) {
            return $_.Substring(0, 137) + "..."
        }
        return $_
    })
}

function Write-DiffReport {
    param([pscustomobject]$Flow, [object[]]$Diffs, [string]$OutputPath)

    $rows = foreach ($diff in $Diffs) {
        "| $($diff.Change) | ``$(Convert-ToMarkdownCell $diff.Path)`` | ``$(Convert-ToMarkdownCell $diff.Local)`` | ``$(Convert-ToMarkdownCell $diff.Package)`` | $($diff.Classification) | $($diff.Reason) |"
    }
    if ($rows.Count -eq 0) {
        $rows = @("| MATCH | - | - | - | MATCH | No leaf-value diff after canonical leaf comparison. |")
    }

    $report = @"
# Codex #2 PM0 Workflow Diff - $($Flow.Name)

Package workflow: ``$($Flow.Action)-$($Flow.Id.ToUpperInvariant()).json``

| Change | JSON path | Local Alpha | Packaged | Classification | Reason |
|---|---|---|---|---|---|
$($rows -join "`r`n")

Summary: $($Diffs.Count) canonical leaf-value differences; $(@($Diffs | Where-Object Classification -eq "UNEXPLAINED").Count) UNEXPLAINED.
"@
    Write-Utf8Text -Path $OutputPath -Text $report
}

function Write-TextPng {
    param([string]$Text, [string]$OutputPath)

    Add-Type -AssemblyName System.Drawing
    $lines = @($Text -split "`r?`n")
    $font = New-Object System.Drawing.Font("Consolas", 11)
    $lineHeight = [int][Math]::Ceiling($font.GetHeight() + 3)
    $width = 1700
    $height = [Math]::Max(420, (($lines.Count + 2) * $lineHeight))
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::FromArgb(18, 18, 18))
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
        try {
            $y = 14
            foreach ($line in $lines) {
                $graphics.DrawString($line, $font, $brush, 14, $y)
                $y += $lineHeight
            }
        }
        finally {
            $brush.Dispose()
        }
        $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
        $font.Dispose()
    }
}

$flows = @(
    [pscustomobject]@{ Name = "AtualizarStatus"; Topic = "AtualizarStatus"; Action = "PM0_PA_Card_AtualizarStatus"; Id = "1721e0a3-a250-f111-bec7-000d3abc5cc6" },
    [pscustomobject]@{ Name = "AtualizarTarefa"; Topic = "AtualizarTarefa"; Action = "PM0_PA_Card_AtualizarTarefa"; Id = "7c6300c2-a250-f111-bec7-000d3abc5cc6" },
    [pscustomobject]@{ Name = "CriarTarefa"; Topic = "CriarTarefa"; Action = "PM0_PA_Card_CriarTarefa"; Id = "7f662db7-a250-f111-bec7-000d3abc5cc6" },
    [pscustomobject]@{ Name = "ListarTarefas"; Topic = "ListarTarefas"; Action = "PM0_PA_Card_ListarTarefas"; Id = "e0e3c6b0-a250-f111-bec7-000d3abc5cc6" },
    [pscustomobject]@{ Name = "ResumoExecutivoPortfolio"; Topic = "ConsultarPortfolio"; Action = "PM0_PA_Card_ResumoExecutivoPortfolio"; Id = "8333bd91-a250-f111-bec7-000d3abc5cc6" }
)

$packageFullPath = Resolve-RepoPath $PackagePath
$sourceFullPath = Resolve-RepoPath $McsSourceRoot
$evidenceFullPath = Resolve-RepoPath $EvidenceDir
$diffFullPath = Resolve-RepoPath $DiffDir
$now = Get-Date
$timestamp = $now.ToString("yyyy-MM-dd HH:mm:ss") + " BRT"
$stem = $now.ToString("yyyyMMdd_HHmmss") + "_Codex2_package_consistency_strict"
$textPath = Join-Path $evidenceFullPath "$stem.txt"
$jsonPath = Join-Path $evidenceFullPath "$stem.json"
$mdPath = Join-Path $evidenceFullPath "$stem.md"
$pngPath = Join-Path $evidenceFullPath "$stem.png"

$zip = [System.IO.Compression.ZipFile]::OpenRead($packageFullPath)
try {
    $entryNames = @($zip.Entries | ForEach-Object FullName)
    $workflowSet = Read-ZipEntryText -Zip $zip -EntryName "Assets/botcomponent_workflowset.xml"
    $flowChecks = foreach ($flow in $flows) {
        $workflowEntryName = "Workflows/$($flow.Action)-$($flow.Id.ToUpperInvariant()).json"
        $packageJson = Read-ZipEntryText -Zip $zip -EntryName $workflowEntryName
        $localPath = Join-Path $sourceFullPath "workflows\$($flow.Action)-$($flow.Id)\workflow.json"
        $localJson = if (Test-Path -LiteralPath $localPath) { Get-Content -LiteralPath $localPath -Raw -Encoding UTF8 } else { $null }
        $diffs = if ($packageJson -and $localJson) { Compare-WorkflowLeafValues -LocalJson $localJson -PackageJson $packageJson } else { @() }

        Write-DiffReport -Flow $flow -Diffs $diffs -OutputPath (Join-Path $diffFullPath "diff_$($flow.Name)_local_vs_packaged.md")

        [pscustomobject]@{
            Flow = $flow.Name
            WorkflowEntryPresent = $null -ne $packageJson
            WorkflowsetHasAction = $workflowSet -match [regex]::Escape("pmo_AssistentePMO_V2.action.$($flow.Action)")
            WorkflowsetHasWorkflowId = $workflowSet -match [regex]::Escape($flow.Id)
            LocalWorkflowExists = $null -ne $localJson
            RawShaMatches = ($null -ne $localJson -and $null -ne $packageJson -and (Get-Sha256FromText $localJson) -eq (Get-Sha256FromText $packageJson))
            CanonicalLeafDiffCount = $diffs.Count
            UnexplainedLeafDiffCount = @($diffs | Where-Object Classification -eq "UNEXPLAINED").Count
            PlaceholderPatternPresent = ($packageJson -match '(?i)placeholder|TODO_BACKFILL|aguardando runtime')
        }
    }

    $pm0ActionComponents = @($entryNames | Where-Object { $_ -match '^botcomponents/pmo_AssistentePMO_V2\.action\.PM0_PA_Card_[^/]+/botcomponent\.xml$' })
    $pm0TopicComponents = @($entryNames | Where-Object { $_ -match '^botcomponents/pmo_AssistentePMO_V2\.topic\.(AtualizarStatus|AtualizarTarefa|ConsultarPortfolio|CriarTarefa|ListarTarefas)/botcomponent\.xml$' })
    $duplicateEntries = @($entryNames | Group-Object | Where-Object Count -gt 1)
    $duplicatePm0BotComponents = @($pm0ActionComponents + $pm0TopicComponents | Group-Object | Where-Object Count -gt 1)
    $workflowSetPm0Lines = @($workflowSet -split "`r?`n" | Where-Object { $_ -match "PM0_PA_Card_" })

    $result = [ordered]@{
        TimestampBRT = $timestamp
        Agent = "Codex #2 Bravo"
        PackagePath = $packageFullPath
        PackageSha256 = (Get-FileHash -LiteralPath $packageFullPath -Algorithm SHA256).Hash
        EntryCount = $entryNames.Count
        WorkflowsetPresent = $null -ne $workflowSet
        PM0ActionComponentCount = $pm0ActionComponents.Count
        PM0TopicComponentCount = $pm0TopicComponents.Count
        DuplicateZipEntryCount = $duplicateEntries.Count
        DuplicatePM0BotComponentCount = $duplicatePm0BotComponents.Count
        WorkflowsetPM0LineCount = $workflowSetPm0Lines.Count
        FlowChecks = @($flowChecks)
        WorkflowsetPM0Lines = $workflowSetPm0Lines
    }
}
finally {
    $zip.Dispose()
}

$textLines = @(
    "Evidence Triplet - Codex #2 Package Consistency Strict Check",
    "Timestamp BRT: $timestamp",
    "Agent: Codex #2 Bravo",
    "Package SHA256: $($result.PackageSha256)",
    "Entry count: $($result.EntryCount)",
    "PM0 action components: $($result.PM0ActionComponentCount)",
    "PM0 topic components: $($result.PM0TopicComponentCount)",
    "Duplicate zip entries: $($result.DuplicateZipEntryCount)",
    "Duplicate PM0 bot components: $($result.DuplicatePM0BotComponentCount)",
    "Workflowset PM0 mapping lines: $($result.WorkflowsetPM0LineCount)",
    "",
    "Flow checks:"
)
foreach ($check in $result.FlowChecks) {
    $textLines += "- $($check.Flow): workflow=$($check.WorkflowEntryPresent), workflowsetAction=$($check.WorkflowsetHasAction), workflowsetId=$($check.WorkflowsetHasWorkflowId), local=$($check.LocalWorkflowExists), rawSha=$($check.RawShaMatches), canonicalLeafDiffs=$($check.CanonicalLeafDiffCount), unexplained=$($check.UnexplainedLeafDiffCount), placeholder=$($check.PlaceholderPatternPresent)"
}
$text = $textLines -join "`r`n"

Write-Utf8Text -Path $textPath -Text $text
Write-Utf8Text -Path $jsonPath -Text ($result | ConvertTo-Json -Depth 10)
Write-TextPng -Text $text -OutputPath $pngPath

$flowRows = foreach ($check in $result.FlowChecks) {
    "| $($check.Flow) | $($check.WorkflowEntryPresent) | $($check.WorkflowsetHasAction) | $($check.WorkflowsetHasWorkflowId) | $($check.LocalWorkflowExists) | $($check.RawShaMatches) | $($check.CanonicalLeafDiffCount) | $($check.UnexplainedLeafDiffCount) | $($check.PlaceholderPatternPresent) |"
}
$evidenceMd = @"
# Evidence Triplet - Codex #2 Package Consistency Strict Check

- Screenshot: $pngPath
- Timestamp BRT: $timestamp
- Agent: Codex #2 Bravo
- JSON: $jsonPath
- Text: $textPath

## Summary

- Package SHA256: $($result.PackageSha256)
- Entry count: $($result.EntryCount)
- Workflowset present: $($result.WorkflowsetPresent)
- PM0 action component count: $($result.PM0ActionComponentCount)
- PM0 topic component count: $($result.PM0TopicComponentCount)
- Duplicate zip entries: $($result.DuplicateZipEntryCount)
- Duplicate PM0 bot components: $($result.DuplicatePM0BotComponentCount)
- Workflowset PM0 mapping line count: $($result.WorkflowsetPM0LineCount)

## Flow Checks

| Flow | Workflow entry | Workflowset action | Workflowset workflow ID | Local exists | Raw SHA match | Canonical leaf diffs | Unexplained leaf diffs | Placeholder pattern |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
$($flowRows -join "`r`n")
"@
Write-Utf8Text -Path $mdPath -Text $evidenceMd

[ordered]@{
    evidence = $mdPath
    screenshot = $pngPath
    packageSha256 = $result.PackageSha256
    workflowsetPm0Lines = $result.WorkflowsetPM0LineCount
    unexplainedDiffs = @($result.FlowChecks | Measure-Object -Property UnexplainedLeafDiffCount -Sum).Sum
} | ConvertTo-Json -Depth 4
