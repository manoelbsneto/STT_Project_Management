[CmdletBinding()]
param(
    [string]$BaseUnpacked = ".planning/comms/solution_3_15_1_hotfix_topics_20260521/build/unpacked_base",
    [string]$McsSourceRoot = "Local_Repo/Assistente PMO V2",
    [string]$WorkingDir = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/work/unpacked_3_16",
    [string]$OutputZip = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip",
    [string]$PackageVersion = "3.16.0.0"
)

$ErrorActionPreference = "Stop"

function Resolve-RepoPath {
    param([string]$Path)
    [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

function Assert-InRepoPath {
    param([string]$Path)
    $repoRoot = (Resolve-Path ".").Path
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if (-not $fullPath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to write outside repository: $fullPath"
    }
    return $fullPath
}

function Write-TextFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function New-DataverseSolutionZip {
    param([string]$SourceDir, [string]$DestinationPath)

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $resolvedSource = (Resolve-Path -LiteralPath $SourceDir).Path
    $sourcePrefix = $resolvedSource.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $destinationFullPath = Assert-InRepoPath -Path (Resolve-RepoPath $DestinationPath)
    if (Test-Path -LiteralPath $destinationFullPath) {
        Remove-Item -LiteralPath $destinationFullPath -Force
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destinationFullPath) | Out-Null

    $zip = [System.IO.Compression.ZipFile]::Open($destinationFullPath, [System.IO.Compression.ZipArchiveMode]::Create)
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

function Get-McsMetadataValue {
    param(
        [string]$Text,
        [string]$Name
    )
    $match = [regex]::Match($Text, "(?m)^\s*$([regex]::Escape($Name)):\s*(?<value>.+?)\s*$")
    if ($match.Success) {
        return $match.Groups["value"].Value.Trim()
    }
    return ""
}

function New-BotComponentXml {
    param(
        [string]$SchemaName,
        [string]$Name,
        [string]$Description
    )

    $escapedDescription = [System.Security.SecurityElement]::Escape($Description)
    $escapedName = [System.Security.SecurityElement]::Escape($Name)
    @"
<botcomponent schemaname="$SchemaName">
  <componenttype>9</componenttype>
  <description>$escapedDescription</description>
  <iscustomizable>1</iscustomizable>
  <name>$escapedName</name>
  <parentbotid>
    <schemaname>pmo_AssistentePMO_V2</schemaname>
  </parentbotid>
  <statecode>0</statecode>
  <statuscode>1</statuscode>
</botcomponent>
"@
}

function Normalize-WorkflowObjectForPackage {
    param([object]$Node)

    if ($null -eq $Node) {
        return
    }

    if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string]) -and -not ($Node -is [pscustomobject])) {
        foreach ($item in $Node) {
            Normalize-WorkflowObjectForPackage -Node $item
        }
        return
    }

    if ($null -eq $Node.PSObject) {
        return
    }

    foreach ($property in @($Node.PSObject.Properties)) {
        if ($property.Name -eq "runtimeSource" -and [string]$property.Value -eq "invoker") {
            $property.Value = "embedded"
            continue
        }

        if ($property.Name -eq "source" -and [string]$property.Value -eq "Invoker") {
            $property.Value = "Embedded"
            continue
        }

        if ($property.Name -eq "authentication") {
            $serialized = $property.Value | ConvertTo-Json -Depth 20 -Compress
            if ($serialized -match "X-MS-APIM-Tokens|ConnectionKey") {
                $property.Value = "@parameters('$authentication')"
                continue
            }
        }

        Normalize-WorkflowObjectForPackage -Node $property.Value
    }
}

function Ensure-ConnectionReferenceXml {
    param(
        [string]$CustomizationsXml,
        [string]$LogicalName,
        [string]$DisplayName,
        [string]$ConnectorId
    )

    if ($CustomizationsXml -match [regex]::Escape("connectionreferencelogicalname=`"$LogicalName`"")) {
        return $CustomizationsXml
    }

    $entry = @"
    <connectionreference connectionreferencelogicalname="$LogicalName">
      <connectionreferencedisplayname>$DisplayName</connectionreferencedisplayname>
      <connectorid>$ConnectorId</connectorid>
      <iscustomizable>1</iscustomizable>
      <promptingbehavior>0</promptingbehavior>
      <statecode>0</statecode>
      <statuscode>1</statuscode>
    </connectionreference>
"@

    return ($CustomizationsXml -replace "(\s*</connectionreferences>)", "`r`n$entry`r`n  </connectionreferences>")
}

function New-WorkflowManifestXml {
    param(
        [string]$WorkflowId,
        [string]$Name,
        [string]$JsonFileName
    )

    @"
    <Workflow WorkflowId="{$WorkflowId}" Name="$Name">
      <JsonFileName>/Workflows/$JsonFileName</JsonFileName>
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
      <IntroducedVersion>3.16.0.0</IntroducedVersion>
      <IsCustomizable>1</IsCustomizable>
      <BusinessProcessType>0</BusinessProcessType>
      <IsCustomProcessingStepAllowedForOtherPublishers>1</IsCustomProcessingStepAllowedForOtherPublishers>
      <ModernFlowType>0</ModernFlowType>
      <PrimaryEntity>none</PrimaryEntity>
      <LocalizedNames>
        <LocalizedName languagecode="3082" description="$Name" />
      </LocalizedNames>
    </Workflow>
"@
}

$flows = @(
    [ordered]@{ topic = "AtualizarStatus"; action = "PM0_PA_Card_AtualizarStatus"; id = "1721e0a3-a250-f111-bec7-000d3abc5cc6" },
    [ordered]@{ topic = "AtualizarTarefa"; action = "PM0_PA_Card_AtualizarTarefa"; id = "7c6300c2-a250-f111-bec7-000d3abc5cc6" },
    [ordered]@{ topic = "ConsultarPortfolio"; action = "PM0_PA_Card_ResumoExecutivoPortfolio"; id = "8333bd91-a250-f111-bec7-000d3abc5cc6" },
    [ordered]@{ topic = "CriarTarefa"; action = "PM0_PA_Card_CriarTarefa"; id = "7f662db7-a250-f111-bec7-000d3abc5cc6" },
    [ordered]@{ topic = "ListarTarefas"; action = "PM0_PA_Card_ListarTarefas"; id = "e0e3c6b0-a250-f111-bec7-000d3abc5cc6" }
)

$baseFullPath = (Resolve-Path -LiteralPath $BaseUnpacked).Path
$mcsFullPath = (Resolve-Path -LiteralPath $McsSourceRoot).Path
$workingFullPath = Assert-InRepoPath -Path (Resolve-RepoPath $WorkingDir)

if (Test-Path -LiteralPath $workingFullPath) {
    Remove-Item -LiteralPath $workingFullPath -Recurse -Force
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $workingFullPath) | Out-Null
Copy-Item -LiteralPath $baseFullPath -Destination $workingFullPath -Recurse

$solutionXmlPath = Join-Path $workingFullPath "solution.xml"
$solutionXml = Get-Content -LiteralPath $solutionXmlPath -Raw
$solutionXml = [regex]::Replace($solutionXml, "<Version>[^<]+</Version>", "<Version>$PackageVersion</Version>", 1)
$solutionXml = [regex]::Replace($solutionXml, "<RootComponent\s+type=`"botcomponent`"[^>]*/>\s*", "")

$customizationsPath = Join-Path $workingFullPath "customizations.xml"
$customizationsXml = Get-Content -LiteralPath $customizationsPath -Raw

foreach ($flow in $flows) {
    $sourceWorkflowPath = Join-Path $mcsFullPath "workflows\$($flow.action)-$($flow.id)\workflow.json"
    if (-not (Test-Path -LiteralPath $sourceWorkflowPath)) {
        throw "Missing PM0 workflow source: $sourceWorkflowPath"
    }

    $workflowFileName = "{0}-{1}.json" -f $flow.action, $flow.id.ToUpperInvariant()
    $workflowObject = Get-Content -LiteralPath $sourceWorkflowPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Normalize-WorkflowObjectForPackage -Node $workflowObject
    Write-TextFile -Path (Join-Path $workingFullPath "Workflows\$workflowFileName") -Content ($workflowObject | ConvertTo-Json -Depth 100)

    $actionSourcePath = Join-Path $mcsFullPath "actions\$($flow.action).mcs.yml"
    if (-not (Test-Path -LiteralPath $actionSourcePath)) {
        throw "Missing PM0 action source: $actionSourcePath"
    }
    $actionText = Get-Content -LiteralPath $actionSourcePath -Raw -Encoding UTF8
    $description = Get-McsMetadataValue -Text $actionText -Name "description"
    if ([string]::IsNullOrWhiteSpace($description)) {
        $description = "PM0 card-first action $($flow.action)."
    }
    $actionComponentDir = Join-Path $workingFullPath "botcomponents\pmo_AssistentePMO_V2.action.$($flow.action)"
    New-Item -ItemType Directory -Force -Path $actionComponentDir | Out-Null
    Write-TextFile -Path (Join-Path $actionComponentDir "data") -Content $actionText
    Write-TextFile -Path (Join-Path $actionComponentDir "botcomponent.xml") -Content (New-BotComponentXml -SchemaName "pmo_AssistentePMO_V2.action.$($flow.action)" -Name $flow.action -Description $description)

    $topicSourcePath = Join-Path $mcsFullPath "topics\$($flow.topic).mcs.yml"
    if (-not (Test-Path -LiteralPath $topicSourcePath)) {
        throw "Missing PM0 topic source: $topicSourcePath"
    }
    $topicText = Get-Content -LiteralPath $topicSourcePath -Raw -Encoding UTF8
    $topicComponentDir = Join-Path $workingFullPath "botcomponents\pmo_AssistentePMO_V2.topic.$($flow.topic)"
    if (-not (Test-Path -LiteralPath $topicComponentDir)) {
        New-Item -ItemType Directory -Force -Path $topicComponentDir | Out-Null
        Write-TextFile -Path (Join-Path $topicComponentDir "botcomponent.xml") -Content (New-BotComponentXml -SchemaName "pmo_AssistentePMO_V2.topic.$($flow.topic)" -Name $flow.topic -Description "PM0 topic $($flow.topic).")
    }
    Write-TextFile -Path (Join-Path $topicComponentDir "data") -Content $topicText

    if ($customizationsXml -notmatch [regex]::Escape($flow.id)) {
        $workflowXml = New-WorkflowManifestXml -WorkflowId $flow.id -Name $flow.action -JsonFileName $workflowFileName
        $customizationsXml = $customizationsXml -replace "(\s*</Workflows>)", "`r`n$workflowXml`r`n  </Workflows>"
    }

    if ($solutionXml -notmatch [regex]::Escape($flow.id)) {
        $rootComponent = "      <RootComponent type=`"29`" id=`"{$($flow.id)}`" behavior=`"0`" />"
        $solutionXml = $solutionXml -replace "(\s*</RootComponents>)", "`r`n$rootComponent`r`n    </RootComponents>"
    }
}

$customizationsXml = Ensure-ConnectionReferenceXml -CustomizationsXml $customizationsXml -LogicalName "cat_DataverseIndexerSharePoint" -DisplayName "SharePoint PMO Dataverse Indexer" -ConnectorId "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
$customizationsXml = Ensure-ConnectionReferenceXml -CustomizationsXml $customizationsXml -LogicalName "pmo_cat_DataverseIndexerSharePoint" -DisplayName "SharePoint PMO Dataverse Indexer pmo" -ConnectorId "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
$customizationsXml = Ensure-ConnectionReferenceXml -CustomizationsXml $customizationsXml -LogicalName "pmo_sharedplanner_87b5f" -DisplayName "Planner PMO" -ConnectorId "/providers/Microsoft.PowerApps/apis/shared_planner"
$customizationsXml = Ensure-ConnectionReferenceXml -CustomizationsXml $customizationsXml -LogicalName "cat_sharedteams_1ef7e" -DisplayName "Teams PMO" -ConnectorId "/providers/Microsoft.PowerApps/apis/shared_teams"

Write-TextFile -Path $solutionXmlPath -Content $solutionXml
Write-TextFile -Path $customizationsPath -Content $customizationsXml

New-DataverseSolutionZip -SourceDir $workingFullPath -DestinationPath $OutputZip

$hash = Get-FileHash -Algorithm SHA256 -LiteralPath (Resolve-RepoPath $OutputZip)
[ordered]@{
    outputZip = (Resolve-RepoPath $OutputZip)
    sha256 = $hash.Hash
    version = $PackageVersion
    workflowCount = $flows.Count
} | ConvertTo-Json -Depth 4
