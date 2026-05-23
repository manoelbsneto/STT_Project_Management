[CmdletBinding()]
param(
    [string]$SourceMcsRoot = "Local_Repo\Assistente PMO V2",
    [string]$BaseZip = "Solution\PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip",
    [string]$Pm0TemplateRoot = ".planning\comms\aq07_power_automate_build_20260515\connection_reference_repair_20260515_1902\package",
    [string]$PackageRoot = ".planning\comms\codex_pm0_remediation_20260522\CODEX2\PACKAGE",
    [string]$OutputZip = ".planning\comms\codex_pm0_remediation_20260522\CODEX2\PACKAGE\package\PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip",
    [string]$PackageVersion = "3.16.0.0"
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$pm0Flows = @(
    [ordered]@{ Name = "PM0_PA_Card_AtualizarStatus"; Id = "1721e0a3-a250-f111-bec7-000d3abc5cc6"; Topic = "AtualizarStatus"; ActionObjectId = "beb83cc5-c09c-4cd3-a279-20846686ea3e" },
    [ordered]@{ Name = "PM0_PA_Card_AtualizarTarefa"; Id = "7c6300c2-a250-f111-bec7-000d3abc5cc6"; Topic = "AtualizarTarefa"; ActionObjectId = "f6afac82-ec2b-47fb-a3d6-4aebad708702" },
    [ordered]@{ Name = "PM0_PA_Card_ResumoExecutivoPortfolio"; Id = "8333bd91-a250-f111-bec7-000d3abc5cc6"; Topic = "ConsultarPortfolio"; ActionObjectId = "0635831a-6b13-45d6-b10e-983fcc63eefe" },
    [ordered]@{ Name = "PM0_PA_Card_CriarTarefa"; Id = "7f662db7-a250-f111-bec7-000d3abc5cc6"; Topic = "CriarTarefa"; ActionObjectId = "3f9abdf2-8801-4602-83dd-002a31f0b53e" },
    [ordered]@{ Name = "PM0_PA_Card_ListarTarefas"; Id = "e0e3c6b0-a250-f111-bec7-000d3abc5cc6"; Topic = "ListarTarefas"; ActionObjectId = "0956d0c0-05f1-429c-8893-6352a927d535" }
)

function Get-BrtTimestamp {
    (Get-Date).ToString("yyyy-MM-dd HH:mm:ss") + " BRT"
}

function Resolve-RequiredPath {
    param(
        [string]$Path,
        [string]$Description,
        [switch]$Directory
    )

    if ($Directory) {
        if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
            throw "$Description not found: $Path"
        }
    }
    else {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            throw "$Description not found: $Path"
        }
    }
    (Resolve-Path -LiteralPath $Path).Path
}

function Assert-UnderPath {
    param(
        [string]$Path,
        [string]$BasePath
    )

    $full = [System.IO.Path]::GetFullPath($Path)
    $base = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (-not $full.StartsWith($base, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to write outside package root. Path=$full Base=$base"
    }
    $full
}

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )

    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($Path), $Content, $encoding)
}

function Copy-FileNoBomText {
    param(
        [string]$Source,
        [string]$Destination
    )

    $content = Get-Content -LiteralPath $Source -Raw -Encoding UTF8
    Write-Utf8NoBom -Path $Destination -Content $content
}

function New-DataverseSolutionZip {
    param(
        [string]$SourceDir,
        [string]$DestinationPath
    )

    $resolvedSource = (Resolve-Path -LiteralPath $SourceDir).Path
    $sourcePrefix = $resolvedSource.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Force
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $DestinationPath) | Out-Null

    $zip = [System.IO.Compression.ZipFile]::Open($DestinationPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        Get-ChildItem -LiteralPath $resolvedSource -Recurse -File |
            Sort-Object FullName |
            ForEach-Object {
                $relative = $_.FullName.Substring($sourcePrefix.Length)
                $entryName = $relative -replace '\\', '/'
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $zip,
                    $_.FullName,
                    $entryName,
                    [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
            }
    }
    finally {
        $zip.Dispose()
    }
}

function Get-ZipInventory {
    param([string]$ZipPath)

    $archive = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $ZipPath).Path)
    try {
        @($archive.Entries | Sort-Object FullName | ForEach-Object {
            [pscustomobject]@{
                Name = $_.FullName
                Length = $_.Length
                CompressedLength = $_.CompressedLength
            }
        })
    }
    finally {
        $archive.Dispose()
    }
}

function Get-ZipHashesByEntry {
    param([string]$ZipPath)

    $archive = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $ZipPath).Path)
    try {
        $map = @{}
        foreach ($entry in @($archive.Entries | Where-Object { -not $_.FullName.EndsWith("/") })) {
            $stream = $entry.Open()
            try {
                $sha = [System.Security.Cryptography.SHA256]::Create()
                try {
                    $hashBytes = $sha.ComputeHash($stream)
                    $hash = -join ($hashBytes | ForEach-Object { $_.ToString("x2") })
                    $map[$entry.FullName] = [pscustomobject]@{
                        Length = $entry.Length
                        Sha256 = $hash
                    }
                }
                finally {
                    $sha.Dispose()
                }
            }
            finally {
                $stream.Dispose()
            }
        }
        $map
    }
    finally {
        $archive.Dispose()
    }
}

function Update-ContentTypes {
    param(
        [string]$ContentTypesPath,
        [string[]]$Entries
    )

    $text = Get-Content -LiteralPath $ContentTypesPath -Raw -Encoding UTF8
    foreach ($entry in $Entries) {
        $partName = "/" + ($entry -replace '\\', '/')
        if ($text -notmatch [regex]::Escape($partName)) {
            $override = "  <Override PartName=""$partName"" ContentType=""application/octet-stream"" />`r`n"
            $text = $text -replace "</Types>\s*$", ($override + "</Types>")
        }
    }
    Write-Utf8NoBom -Path $ContentTypesPath -Content $text
}

function Get-WorkflowManifestNode {
    param(
        [string]$Name,
        [string]$Id,
        [string]$JsonFileName,
        [string]$LanguageCode,
        [string]$IntroducedVersion
    )

@"
    <Workflow WorkflowId="{$Id}" Name="$Name">
      <JsonFileName>/$JsonFileName</JsonFileName>
      <Type>1</Type>
      <Subprocess>0</Subprocess>
      <Category>5</Category>
      <Mode>0</Mode>
      <Scope>4</Scope>
      <OnDemand>0</OnDemand>
      <TriggerOnCreate>0</TriggerOnCreate>
      <TriggerOnDelete>0</TriggerOnDelete>
      <AsyncAutodelete>0</AsyncAutodelete>
      <SyncWorkflowLogOnFailure>0</SyncWorkflowLogOnFailure>
      <StateCode>1</StateCode>
      <StatusCode>2</StatusCode>
      <RunAs>1</RunAs>
      <IsTransacted>1</IsTransacted>
      <IntroducedVersion>$IntroducedVersion</IntroducedVersion>
      <IsCustomizable>1</IsCustomizable>
      <BusinessProcessType>0</BusinessProcessType>
      <IsCustomProcessingStepAllowedForOtherPublishers>1</IsCustomProcessingStepAllowedForOtherPublishers>
      <ModernFlowType>0</ModernFlowType>
      <PrimaryEntity>none</PrimaryEntity>
      <LocalizedNames>
        <LocalizedName languagecode="$LanguageCode" description="$Name" />
      </LocalizedNames>
    </Workflow>
"@
}

function Update-CustomizationsXml {
    param(
        [string]$Path,
        [object[]]$Flows
    )

    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $languageCode = if ($text -match 'languagecode="(?<code>[0-9]+)"') { $Matches.code } else { "3082" }
    foreach ($flow in $Flows) {
        if ($text -match [regex]::Escape($flow.Id)) {
            continue
        }
        $jsonFile = "Workflows/$($flow.Name)-$($flow.Id).json"
        $node = Get-WorkflowManifestNode -Name $flow.Name -Id $flow.Id -JsonFileName $jsonFile -LanguageCode $languageCode -IntroducedVersion "1.0"
        $text = $text -replace "\s*</Workflows>", ("`r`n" + $node + "`r`n  </Workflows>")
    }
    Write-Utf8NoBom -Path $Path -Content $text
}

function Update-SolutionXml {
    param(
        [string]$Path,
        [object[]]$Flows,
        [string]$Version
    )

    [xml]$xml = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $manifest = $xml.ImportExportXml.SolutionManifest
    $manifest.Version = $Version

    $root = $manifest.RootComponents
    $existing = @($root.RootComponent)
    foreach ($component in $existing) {
        $type = [string]$component.type
        if ($type -notmatch '^[0-9]+$') {
            [void]$root.RemoveChild($component)
        }
    }

    $known = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($component in @($root.RootComponent)) {
        [void]$known.Add(([string]$component.id).Trim("{}"))
    }

    foreach ($flow in $Flows) {
        if ($known.Contains($flow.Id)) {
            continue
        }
        $node = $xml.CreateElement("RootComponent")
        $node.SetAttribute("type", "29")
        $node.SetAttribute("id", "{$($flow.Id)}")
        $node.SetAttribute("behavior", "0")
        [void]$root.AppendChild($node)
    }

    $writerSettings = [System.Xml.XmlWriterSettings]::new()
    $writerSettings.Encoding = [System.Text.UTF8Encoding]::new($false)
    $writerSettings.Indent = $true
    $writerSettings.OmitXmlDeclaration = $true
    $writer = [System.Xml.XmlWriter]::Create([System.IO.Path]::GetFullPath($Path), $writerSettings)
    try {
        $xml.Save($writer)
    }
    finally {
        $writer.Dispose()
    }
}

function Merge-WorkflowSet {
    param(
        [string]$BaseWorkflowSetPath,
        [object[]]$Flows
    )

    $text = Get-Content -LiteralPath $BaseWorkflowSetPath -Raw -Encoding UTF8
    foreach ($flow in $Flows) {
        $schemaName = "pmo_AssistentePMO_V2.action.$($flow.Name)"
        if ($text -match [regex]::Escape($schemaName)) {
            continue
        }
        $node = @"
  <botcomponent_workflow botcomponentid.schemaname="$schemaName" workflowid.workflowid="$($flow.Id)">
    <iscustomizable>1</iscustomizable>
  </botcomponent_workflow>
"@
        $text = $text -replace "\s*</botcomponent_workflowset>", ("`r`n" + $node + "`r`n</botcomponent_workflowset>")
    }
    Write-Utf8NoBom -Path $BaseWorkflowSetPath -Content $text
}

function Write-PackageInventory {
    param(
        [string]$Path,
        [string]$ZipPath,
        [object[]]$Flows
    )

    $inventory = Get-ZipInventory -ZipPath $ZipPath
    $entryNames = @($inventory | ForEach-Object { $_.Name })
    $hash = Get-FileHash -Algorithm SHA256 -LiteralPath $ZipPath

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("Last updated: $(Get-BrtTimestamp) | Codex sub-2A | Package inventory generated for local 3.16 candidate.") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("# PMO 3.16 Package Inventory") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- Package: `$ZipPath`") | Out-Null
    $lines.Add("- SHA256: `$($hash.Hash)`") | Out-Null
    $lines.Add("- Entry count: $($inventory.Count)") | Out-Null
    $lines.Add("- Build source: `$SourceMcsRoot`") | Out-Null
    $lines.Add("- Base ZIP: `$BaseZip`") | Out-Null
    $lines.Add("- PM0 template root: `$Pm0TemplateRoot`") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## PM0 Required Components") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Flow | Workflow file | Action data | Topic data | Workflow root component |") | Out-Null
    $lines.Add("|---|---|---|---|---|") | Out-Null
    foreach ($flow in $Flows) {
        $workflowEntry = "Workflows/$($flow.Name)-$($flow.Id).json"
        $actionEntry = "botcomponents/pmo_AssistentePMO_V2.action.$($flow.Name)/data"
        $topicEntry = "botcomponents/pmo_AssistentePMO_V2.topic.$($flow.Topic)/data"
        $solutionXml = Get-Content -LiteralPath (Join-Path $workRoot "solution.xml") -Raw -Encoding UTF8
        $rootPresent = $solutionXml -match [regex]::Escape($flow.Id)
        $lines.Add("| $($flow.Name) | $($entryNames -contains $workflowEntry) | $($entryNames -contains $actionEntry) | $($entryNames -contains $topicEntry) | $rootPresent |") | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Entries") | Out-Null
    $lines.Add("") | Out-Null
    foreach ($entry in $inventory) {
        $lines.Add("- `$($entry.Name)` ($($entry.Length) bytes)") | Out-Null
    }

    Write-Utf8NoBom -Path $Path -Content ($lines -join "`r`n")
}

function Write-ZipDiff {
    param(
        [string]$Path,
        [string]$OldZip,
        [string]$NewZip
    )

    $old = Get-ZipHashesByEntry -ZipPath $OldZip
    $new = Get-ZipHashesByEntry -ZipPath $NewZip
    $allNames = @($old.Keys + $new.Keys | Sort-Object -Unique)
    $added = @()
    $removed = @()
    $changed = @()
    $same = @()

    foreach ($name in $allNames) {
        if (-not $old.ContainsKey($name)) {
            $added += $name
        }
        elseif (-not $new.ContainsKey($name)) {
            $removed += $name
        }
        elseif ($old[$name].Sha256 -ne $new[$name].Sha256) {
            $changed += $name
        }
        else {
            $same += $name
        }
    }

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.Add("Last updated: $(Get-BrtTimestamp) | Codex sub-2A | Diffed local 3.16 candidate against active 3.15.1 ZIP.") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("# Diff 3.16 vs 3.15.1") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- Old: `$OldZip`") | Out-Null
    $lines.Add("- New: `$NewZip`") | Out-Null
    $lines.Add("- Added: $($added.Count)") | Out-Null
    $lines.Add("- Removed: $($removed.Count)") | Out-Null
    $lines.Add("- Changed: $($changed.Count)") | Out-Null
    $lines.Add("- Unchanged: $($same.Count)") | Out-Null
    foreach ($section in @(
        [pscustomobject]@{ Title = "Added"; Items = $added },
        [pscustomobject]@{ Title = "Removed"; Items = $removed },
        [pscustomobject]@{ Title = "Changed"; Items = $changed }
    )) {
        $lines.Add("") | Out-Null
        $lines.Add("## $($section.Title)") | Out-Null
        $lines.Add("") | Out-Null
        if (@($section.Items).Count -eq 0) {
            $lines.Add("- None") | Out-Null
        }
        else {
            foreach ($item in @($section.Items | Sort-Object)) {
                $lines.Add("- `$item`") | Out-Null
            }
        }
    }

    Write-Utf8NoBom -Path $Path -Content ($lines -join "`r`n")
}

$repoRoot = (Resolve-Path ".").Path
$packageRootFull = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $PackageRoot))
New-Item -ItemType Directory -Force -Path $packageRootFull | Out-Null

$sourceRootFull = Resolve-RequiredPath -Path $SourceMcsRoot -Description "Source MCS root" -Directory
$baseZipFull = Resolve-RequiredPath -Path $BaseZip -Description "Base 3.15.1 ZIP"
$templateRootFull = Resolve-RequiredPath -Path $Pm0TemplateRoot -Description "PM0 template package root" -Directory
$outputZipFull = Assert-UnderPath -Path (Join-Path $repoRoot $OutputZip) -BasePath $packageRootFull
$workRoot = Assert-UnderPath -Path (Join-Path $packageRootFull "work\PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX_unpacked") -BasePath $packageRootFull
$evidenceRoot = Assert-UnderPath -Path (Join-Path $packageRootFull "evidence") -BasePath $packageRootFull
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

if (Test-Path -LiteralPath $workRoot) {
    Remove-Item -LiteralPath $workRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $workRoot | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory($baseZipFull, $workRoot)

foreach ($flow in $pm0Flows) {
    $sourceWorkflow = Join-Path $sourceRootFull "workflows\$($flow.Name)-$($flow.Id)\workflow.json"
    $destWorkflow = Join-Path $workRoot "Workflows\$($flow.Name)-$($flow.Id).json"
    Copy-FileNoBomText -Source (Resolve-RequiredPath -Path $sourceWorkflow -Description "$($flow.Name) source workflow") -Destination $destWorkflow

    $sourceAction = Join-Path $sourceRootFull "actions\$($flow.Name).mcs.yml"
    $actionFolder = Join-Path $workRoot "botcomponents\pmo_AssistentePMO_V2.action.$($flow.Name)"
    $templateActionFolder = Join-Path $templateRootFull "botcomponents\pmo_AssistentePMO_V2.action.$($flow.Name)"
    if (-not (Test-Path -LiteralPath $actionFolder -PathType Container)) {
        Copy-Item -LiteralPath (Resolve-RequiredPath -Path $templateActionFolder -Description "$($flow.Name) action template" -Directory) -Destination $actionFolder -Recurse
    }
    Copy-FileNoBomText -Source (Resolve-RequiredPath -Path $sourceAction -Description "$($flow.Name) source action") -Destination (Join-Path $actionFolder "data")

    $sourceTopic = Join-Path $sourceRootFull "topics\$($flow.Topic).mcs.yml"
    $topicFolder = Join-Path $workRoot "botcomponents\pmo_AssistentePMO_V2.topic.$($flow.Topic)"
    if (-not (Test-Path -LiteralPath $topicFolder -PathType Container)) {
        throw "Expected existing topic folder missing from base package: $topicFolder"
    }
    Copy-FileNoBomText -Source (Resolve-RequiredPath -Path $sourceTopic -Description "$($flow.Topic) source topic") -Destination (Join-Path $topicFolder "data")
}

Merge-WorkflowSet -BaseWorkflowSetPath (Join-Path $workRoot "Assets\botcomponent_workflowset.xml") -Flows $pm0Flows
Update-CustomizationsXml -Path (Join-Path $workRoot "customizations.xml") -Flows $pm0Flows
Update-SolutionXml -Path (Join-Path $workRoot "solution.xml") -Flows $pm0Flows -Version $PackageVersion

$contentEntries = [System.Collections.Generic.List[string]]::new()
foreach ($flow in $pm0Flows) {
    $contentEntries.Add("Workflows/$($flow.Name)-$($flow.Id).json") | Out-Null
    $contentEntries.Add("botcomponents/pmo_AssistentePMO_V2.action.$($flow.Name)/data") | Out-Null
}
Update-ContentTypes -ContentTypesPath (Join-Path $workRoot "[Content_Types].xml") -Entries $contentEntries.ToArray()

New-DataverseSolutionZip -SourceDir $workRoot -DestinationPath $outputZipFull
$hash = Get-FileHash -Algorithm SHA256 -LiteralPath $outputZipFull

Write-Utf8NoBom -Path (Join-Path $packageRootFull "package_sha256.txt") -Content ("$($hash.Hash)  $outputZipFull`r`n")
Write-PackageInventory -Path (Join-Path $packageRootFull "package_inventory.md") -ZipPath $outputZipFull -Flows $pm0Flows
Write-ZipDiff -Path (Join-Path $packageRootFull "diff_3_16_vs_3_15_1.md") -OldZip $baseZipFull -NewZip $outputZipFull

$expandedPm0Workflows = Get-ChildItem -LiteralPath (Join-Path $workRoot "Workflows") -Filter "PM0_PA_Card_*.json" -File
$placeholderHits = @($expandedPm0Workflows | Select-String -Pattern '"result"\s*:\s*"[^@{][^"]*successfully\."' -ErrorAction SilentlyContinue)
$solutionXmlText = Get-Content -LiteralPath (Join-Path $workRoot "solution.xml") -Raw -Encoding UTF8
$customizationsText = Get-Content -LiteralPath (Join-Path $workRoot "customizations.xml") -Raw -Encoding UTF8
$missingWorkflowEntries = @()
foreach ($flow in $pm0Flows) {
    if ($solutionXmlText -notmatch [regex]::Escape($flow.Id)) {
        $missingWorkflowEntries += "$($flow.Name) missing from solution.xml"
    }
    if ($customizationsText -notmatch [regex]::Escape($flow.Id)) {
        $missingWorkflowEntries += "$($flow.Name) missing from customizations.xml"
    }
}

$preflight = @"
Last updated: $(Get-BrtTimestamp) | Codex sub-2A | Local-only package preflight recorded; no PAC tenant read was executed.

# Solution Membership Preflight

Status: NOT_RUN_TENANT_READ

Reason: Codex sub-2A write scope is limited to CODEX2/PACKAGE and the build script. The mission-specific user instruction allows read-only PAC if needed, but the project access protocol requires check-in board coordination before tenant access, which is outside this subagent write scope.

Local package evidence:

- solution.xml includes the 5 PM0 workflow RootComponent entries with numeric type 29.
- customizations.xml includes the 5 PM0 Workflow elements.
- The package contains 5 PM0 workflow JSON files, 5 PM0 action data files, and 5 PM0 topic data files.

Microsoft Learn sources already indexed in B2:

- PAC solution CLI reference: https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution
- SolutionComponent componenttype reference: https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/solutioncomponent#componenttype-choicesoptions
- Copilot Studio solution import/export: https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export
"@
Write-Utf8NoBom -Path (Join-Path $packageRootFull "solution_membership_preflight.md") -Content $preflight

$summary = [ordered]@{
    timestampBrt = Get-BrtTimestamp
    agent = "Codex sub-2A"
    packageVersion = $PackageVersion
    sourceMcsRoot = $sourceRootFull
    baseZip = $baseZipFull
    outputZip = $outputZipFull
    sha256 = $hash.Hash
    pm0WorkflowFileCount = @($expandedPm0Workflows).Count
    placeholderHitCount = @($placeholderHits).Count
    manifestIssueCount = @($missingWorkflowEntries).Count
    manifestIssues = @($missingWorkflowEntries)
    placeholderHits = @($placeholderHits | ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" })
}

$summaryJson = $summary | ConvertTo-Json -Depth 8
Write-Utf8NoBom -Path (Join-Path $evidenceRoot ((Get-Date).ToString("yyyyMMdd_HHmmss") + "_Codex_sub-2A_package_build_summary.json")) -Content $summaryJson

if (@($placeholderHits).Count -gt 0) {
    throw "Hardcoded placeholder responses found in PM0 workflows: $(@($placeholderHits).Count)"
}
if (@($missingWorkflowEntries).Count -gt 0) {
    throw "Workflow manifest validation failed: $($missingWorkflowEntries -join '; ')"
}

$summary | ConvertTo-Json -Depth 8
