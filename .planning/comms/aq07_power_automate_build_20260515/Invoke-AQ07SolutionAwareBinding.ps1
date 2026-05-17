[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$SolutionId = "fd140aaf-4df4-11dd-bd17-0019b9312238",
    [string]$BotId = "0c4a9729-d55d-483c-8ec3-db9369583155",
    [string]$BotSchema = "pmo_AssistentePMO_V2",
    [string]$SolutionUniqueName = "PMO_AQ07_CopilotBinding",
    [string]$EvidenceDir = ".planning\comms\aq07_power_automate_build_20260515\execution_evidence"
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..\..\..")).Path
Set-Location $repoRoot

$adminModule = "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1"
$powerAppsModule = "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"

Import-Module $adminModule -ErrorAction Stop
Import-Module $powerAppsModule -ErrorAction Stop

$evidenceRoot = Join-Path $repoRoot $EvidenceDir
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 100)
    Write-Utf8NoBom -Path $Path -Content ($Data | ConvertTo-Json -Depth $Depth)
}

function Write-Utf8NoBom {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(ValueFromPipeline = $true)]
        [AllowEmptyString()]
        [string]$Content
    )

    begin {
        $parts = New-Object System.Collections.Generic.List[string]
    }

    process {
        if ($null -ne $Content) {
            [void]$parts.Add($Content)
        }
    }

    end {
        $dir = Split-Path -Parent $Path
        if ($dir) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
        $encoding = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($Path, [string]::Join([Environment]::NewLine, $parts), $encoding)
    }
}

function Invoke-Pac {
    param([string]$Command, [string]$LogPath, [switch]$AllowFailure)
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $Command *>&1
    $output | Set-Content -LiteralPath $LogPath -Encoding UTF8
    $text = $output | Out-String
    $containsPacFailure = $text -match "(?m)^\s*Error:" -or $text -match "FAILURE:"
    if ((($LASTEXITCODE -ne 0) -or $containsPacFailure) -and -not $AllowFailure) {
        throw "PAC command failed with exit code $LASTEXITCODE. See $LogPath"
    }
    [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        LogPath = $LogPath
        Output = $text
        ContainsFailure = $containsPacFailure
    }
}

$flows = @(
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_ResumoExecutivoPortfolio"; FlowName = "b4df90ec-a721-44cf-adbd-a5ced1d7f9f7"; Schema = "$BotSchema.action.PM0_PA_Card_ResumoExecutivoPortfolio" },
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_AtualizarStatus"; FlowName = "b7678a81-df01-4070-b6db-3c0dbcc7f924"; Schema = "$BotSchema.action.PM0_PA_Card_AtualizarStatus" },
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_ListarTarefas"; FlowName = "c9e44878-77ed-4b17-9b6f-0bab008a0587"; Schema = "$BotSchema.action.PM0_PA_Card_ListarTarefas" },
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_CriarTarefa"; FlowName = "76146280-a6c2-4068-8a3f-3310e3e9210f"; Schema = "$BotSchema.action.PM0_PA_Card_CriarTarefa" },
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_AtualizarTarefa"; FlowName = "36142fd3-9f83-4d4f-81e2-748ded919a92"; Schema = "$BotSchema.action.PM0_PA_Card_AtualizarTarefa" },
    [pscustomobject]@{ DisplayName = "PM0_PA_OpsFailureHandling"; FlowName = "2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441"; Schema = "$BotSchema.action.PM0_PA_OpsFailureHandling" }
)

Write-Host "Setting flows as solution-aware..."

$flowResults = foreach ($flowRef in $flows) {
    $setOutput = $null
    try {
        $setOutput = Set-FlowAsSolutionAware -EnvironmentName $EnvironmentName -FlowName $flowRef.FlowName -SolutionId $SolutionId *>&1 | Out-String
    }
    catch {
        $setOutput = $_.Exception.Message
    }

    Start-Sleep -Seconds 4
    $flow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $flowRef.FlowName -ErrorAction Stop
    [pscustomobject]@{
        DisplayName = $flowRef.DisplayName
        FlowName = $flowRef.FlowName
        Schema = $flowRef.Schema
        Enabled = $flow.Enabled
        State = $flow.Internal.properties.state
        WorkflowEntityId = $flow.Internal.properties.workflowEntityId
        SolutionAwareOutput = if ($setOutput) { $setOutput.Trim() } else { "" }
    }
}

$flowEvidence = Join-Path $evidenceRoot "aq07_flow_solutionaware_$timestamp.json"
Save-Json -Data $flowResults -Path $flowEvidence

if (@($flowResults | Where-Object { -not $_.WorkflowEntityId }).Count -gt 0) {
    throw "One or more target flows do not have WorkflowEntityId after solution-aware conversion. See $flowEvidence"
}

Write-Host "All flows solution-aware. Building package..."

$packageRoot = Join-Path $evidenceRoot "aq07_binding_package_$timestamp"
$assetsDir = Join-Path $packageRoot "Assets"
$workflowsDir = Join-Path $packageRoot "Workflows"
New-Item -ItemType Directory -Force -Path $assetsDir, $workflowsDir | Out-Null
$packageRoot = (Resolve-Path -LiteralPath $packageRoot).Path

$workflowAssociationRows = [System.Text.StringBuilder]::new()
$contentTypeOverrides = [System.Text.StringBuilder]::new()
[void]$contentTypeOverrides.AppendLine('<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/octet-stream" /><Default Extension="json" ContentType="application/octet-stream" />')

$workflowCustomizations = [System.Text.StringBuilder]::new()
$workflowRootComponents = [System.Text.StringBuilder]::new()

foreach ($flowResult in $flowResults) {
    $actionDir = Join-Path $packageRoot "botcomponents\$($flowResult.Schema)"
    New-Item -ItemType Directory -Force -Path $actionDir | Out-Null

    $liveFlow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $flowResult.FlowName -ErrorAction Stop
    
    $workflowFile = "$($flowResult.DisplayName)-$($flowResult.WorkflowEntityId).json"
    Save-Json -Data ([ordered]@{
        properties = [ordered]@{
            connectionReferences = $liveFlow.Internal.properties.connectionReferences
            definition = $liveFlow.Internal.properties.definition
            templateName = $null
        }
        schemaVersion = "1.0.0.0"
    }) -Path (Join-Path $workflowsDir $workflowFile)

    [void]$workflowRootComponents.AppendLine("      <RootComponent type=""29"" id=""{$($flowResult.WorkflowEntityId)}"" behavior=""0"" />")
    [void]$workflowCustomizations.AppendLine("    <Workflow WorkflowId=""{$($flowResult.WorkflowEntityId)}"" Name=""$($flowResult.DisplayName)"">")
    [void]$workflowCustomizations.AppendLine("      <JsonFileName>/Workflows/$workflowFile</JsonFileName>")
    [void]$workflowCustomizations.AppendLine("      <Type>1</Type>")
    [void]$workflowCustomizations.AppendLine("      <Subprocess>0</Subprocess>")
    [void]$workflowCustomizations.AppendLine("      <Category>5</Category>")
    [void]$workflowCustomizations.AppendLine("      <Mode>0</Mode>")
    [void]$workflowCustomizations.AppendLine("      <Scope>4</Scope>")
    [void]$workflowCustomizations.AppendLine("      <OnDemand>0</OnDemand>")
    [void]$workflowCustomizations.AppendLine("      <TriggerOnCreate>0</TriggerOnCreate>")
    [void]$workflowCustomizations.AppendLine("      <TriggerOnDelete>0</TriggerOnDelete>")
    [void]$workflowCustomizations.AppendLine("      <AsyncAutodelete>0</AsyncAutodelete>")
    [void]$workflowCustomizations.AppendLine("      <SyncWorkflowLogOnFailure>0</SyncWorkflowLogOnFailure>")
    [void]$workflowCustomizations.AppendLine("      <StateCode>1</StateCode>")
    [void]$workflowCustomizations.AppendLine("      <StatusCode>2</StatusCode>")
    [void]$workflowCustomizations.AppendLine("      <RunAs>1</RunAs>")
    [void]$workflowCustomizations.AppendLine("      <IsTransacted>1</IsTransacted>")
    [void]$workflowCustomizations.AppendLine("      <IntroducedVersion>1.0.0.0</IntroducedVersion>")
    [void]$workflowCustomizations.AppendLine("      <IsCustomizable>1</IsCustomizable>")
    [void]$workflowCustomizations.AppendLine("      <BusinessProcessType>0</BusinessProcessType>")
    [void]$workflowCustomizations.AppendLine("      <IsCustomProcessingStepAllowedForOtherPublishers>1</IsCustomProcessingStepAllowedForOtherPublishers>")
    [void]$workflowCustomizations.AppendLine("      <PrimaryEntity>none</PrimaryEntity>")
    [void]$workflowCustomizations.AppendLine("      <LocalizedNames>")
    [void]$workflowCustomizations.AppendLine("        <LocalizedName languagecode=""1046"" description=""$($flowResult.DisplayName)"" />")
    [void]$workflowCustomizations.AppendLine("      </LocalizedNames>")
    [void]$workflowCustomizations.AppendLine("    </Workflow>")

    @"
<botcomponent schemaname="$($flowResult.Schema)">
  <componenttype>9</componenttype>
  <iscustomizable>1</iscustomizable>
  <name>$($flowResult.DisplayName)</name>
  <parentbotid>
    <schemaname>$BotSchema</schemaname>
  </parentbotid>
  <statecode>0</statecode>
  <statuscode>1</statuscode>
</botcomponent>
"@ | Write-Utf8NoBom -Path (Join-Path $actionDir "botcomponent.xml")

    @"
kind: TaskDialog
outputs:
  - propertyName: result
action:
  kind: InvokeFlowTaskAction
  flowId: $($flowResult.WorkflowEntityId)
  connectionProperties:
    `$kind: ConnectionProperties
    diagnostics:
    mode: Embedded
outputMode: All
"@ | Write-Utf8NoBom -Path (Join-Path $actionDir "data")

    [void]$workflowAssociationRows.AppendLine("  <botcomponent_workflow botcomponentid.schemaname=""$($flowResult.Schema)"" workflowid.workflowid=""$($flowResult.WorkflowEntityId)"">")
    [void]$workflowAssociationRows.AppendLine("    <iscustomizable>1</iscustomizable>")
    [void]$workflowAssociationRows.AppendLine("  </botcomponent_workflow>")
    [void]$contentTypeOverrides.AppendLine("<Override PartName=""/botcomponents/$($flowResult.Schema)/data"" ContentType=""application/octet-stream"" />")
}

@"
<botcomponent_workflowset>
$($workflowAssociationRows.ToString().TrimEnd())
</botcomponent_workflowset>
"@ | Write-Utf8NoBom -Path (Join-Path $assetsDir "botcomponent_workflowset.xml")

[void]$contentTypeOverrides.AppendLine("</Types>")
Write-Utf8NoBom -Path (Join-Path $packageRoot "[Content_Types].xml") -Content $contentTypeOverrides.ToString()

@"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2.26041.172" SolutionPackageVersion="9.2" languagecode="1046" generatedBy="CrmLive" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard">
  <SolutionManifest>
    <UniqueName>$SolutionUniqueName</UniqueName>
    <LocalizedNames>
      <LocalizedName description="PMO AQ07 Copilot Binding" languagecode="1046" />
    </LocalizedNames>
    <Descriptions />
    <Version>1.0.0.0</Version>
    <Managed>0</Managed>
    <Publisher>
      <UniqueName>DefaultPublishercolofertasbrasilpro</UniqueName>
      <LocalizedNames>
        <LocalizedName description="Default publisher for colofertasbrasilpro" languagecode="1046" />
      </LocalizedNames>
      <Descriptions />
      <EMailAddress xsi:nil="true"></EMailAddress>
      <SupportingWebsiteUrl xsi:nil="true"></SupportingWebsiteUrl>
      <CustomizationPrefix>pmo</CustomizationPrefix>
      <CustomizationOptionValuePrefix>10000</CustomizationOptionValuePrefix>
      <Addresses />
    </Publisher>
    <RootComponents>
$($workflowRootComponents.ToString().TrimEnd())
    </RootComponents>
    <MissingDependencies />
  </SolutionManifest>
</ImportExportXml>
"@ | Write-Utf8NoBom -Path (Join-Path $packageRoot "solution.xml")

@"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard">
  <Entities />
  <Roles />
  <Workflows>
$($workflowCustomizations.ToString().TrimEnd())
  </Workflows>
</ImportExportXml>
"@ | Write-Utf8NoBom -Path (Join-Path $packageRoot "customizations.xml")

$packageZip = Join-Path $evidenceRoot "PMO_AQ07_CopilotBinding_$timestamp.zip"
if (Test-Path -LiteralPath $packageZip) {
    Remove-Item -LiteralPath $packageZip -Force
}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($packageZip, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $rootLen = $packageRoot.TrimEnd('\', '/').Length + 1
    foreach ($file in Get-ChildItem -LiteralPath $packageRoot -Recurse -File) {
        $relative = $file.FullName.Substring($rootLen).Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $relative) | Out-Null
    }
} finally { $zip.Dispose() }

Write-Host "Created Solution Package: $packageZip"

$importLog = Join-Path $evidenceRoot "pac_import_aq07_binding_$timestamp.txt"
Invoke-Pac -Command "pac solution import --environment $EnvironmentName --path `"$packageZip`" --publish-changes" -LogPath $importLog | Out-Null

$manifestPath = Join-Path $evidenceRoot "aq07_binding_package_manifest_$timestamp.json"
Save-Json -Data ([pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    environmentName = $EnvironmentName
    botId = $BotId
    botSchema = $BotSchema
    solutionUniqueName = $SolutionUniqueName
    packageRoot = $packageRoot
    packageZip = $packageZip
    flowEvidence = $flowEvidence
    flows = $flowResults
    importLog = $importLog
}) -Path $manifestPath

Write-Host "AQ-07 Copilot Binding Script Completed."
