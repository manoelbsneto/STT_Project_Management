[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$BotId = "0c4a9729-d55d-483c-8ec3-db9369583155",
    [string]$BotSchema = "pmo_AssistentePMO",
    [string]$SolutionUniqueName = "PMO_G4_KnowledgePatch",
    [string]$EvidenceDir = ".planning\comms",
    [string]$KnowledgeSchema = "pmo_AssistentePMO.topic.PMOSharePointKnowledge",
    [string]$KnowledgeName = "PMO SharePoint Knowledge",
    [string]$SharePointSite = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$BaseUnpackPath = ".planning\comms\g4_carrier_export_20260503_1325\unpacked"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$evidenceRoot = Join-Path $repoRoot $EvidenceDir
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$packageRoot = Join-Path $evidenceRoot "g4_knowledge_patch_$timestamp"
$botDir = Join-Path $packageRoot "bots\$BotSchema"
$componentDir = Join-Path $packageRoot "botcomponents\$KnowledgeSchema"
$packageZip = Join-Path $evidenceRoot "PMO_G4_KnowledgePatch_$timestamp.zip"
$manifestPath = Join-Path $evidenceRoot "g4_knowledge_patch_manifest_$timestamp.json"
$importLog = Join-Path $evidenceRoot "pac_import_g4_knowledge_$timestamp.txt"
$publishLog = Join-Path $evidenceRoot "pac_publish_g4_knowledge_$timestamp.txt"
$listLog = Join-Path $evidenceRoot "pac_list_g4_knowledge_$timestamp.txt"

function Save-Text {
    param([string]$Path, [string]$Value)
    $dir = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    [System.IO.File]::WriteAllText($Path, $Value, [System.Text.UTF8Encoding]::new($false))
}

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 20)
    [System.IO.File]::WriteAllText($Path, ($Data | ConvertTo-Json -Depth $Depth), [System.Text.UTF8Encoding]::new($false))
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
        ContainsFailure = $containsPacFailure
    }
}

function Escape-Xml {
    param([string]$Value)
    [System.Security.SecurityElement]::Escape($Value)
}

if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}
$resolvedBase = if ([System.IO.Path]::IsPathRooted($BaseUnpackPath)) { $BaseUnpackPath } else { Join-Path $repoRoot $BaseUnpackPath }
if (Test-Path -LiteralPath $resolvedBase) {
    New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null
    Copy-Item -Path (Join-Path $resolvedBase "*") -Destination $packageRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $componentDir, $botDir | Out-Null

$knowledgeData = @"
kind: KnowledgeSourceConfiguration
source:
  kind: SharePointSearchSource
  site: $SharePointSite
"@

Save-Text -Path (Join-Path $componentDir "botcomponent.xml") -Value @"
<botcomponent schemaname="$KnowledgeSchema">
  <componenttype>16</componenttype>
  <description>Knowledge source restricted to the PMO SharePoint site and PMO lists.</description>
  <iscustomizable>0</iscustomizable>
  <name>$(Escape-Xml $KnowledgeName)</name>
  <parentbotid>
    <schemaname>$BotSchema</schemaname>
  </parentbotid>
  <statecode>0</statecode>
  <statuscode>1</statuscode>
</botcomponent>
"@

Save-Text -Path (Join-Path $componentDir "data") -Value $knowledgeData

$configuration = [ordered]@{
    '$kind' = "BotConfiguration"
    channels = @(
        [ordered]@{
            '$kind' = "ChannelDefinition"
            channelId = "MsTeams"
        }
    )
    settings = [ordered]@{
        GenerativeActionsEnabled = $false
    }
    aISettings = [ordered]@{
        '$kind' = "AISettings"
        useModelKnowledge = $false
        isFileAnalysisEnabled = $false
        isSemanticSearchEnabled = $false
        contentModeration = "High"
    }
    isAgentConnectable = $true
    publishOnImport = $true
    gPTSettings = [ordered]@{
        '$kind' = "GPTSettings"
        defaultSchemaName = "$BotSchema.gpt.default"
    }
}
Save-Json -Data $configuration -Path (Join-Path $botDir "configuration.json")

Save-Text -Path (Join-Path $botDir "bot.xml") -Value @"
<bot schemaname="$BotSchema">
  <authenticationmode>2</authenticationmode>
  <authenticationtrigger>1</authenticationtrigger>
  <iscustomizable>0</iscustomizable>
  <language>1046</language>
  <name>Assistente PMO</name>
  <runtimeprovider>0</runtimeprovider>
  <template>default-2.1.0</template>
  <timezoneruleversionnumber>4</timezoneruleversionnumber>
</bot>
"@

if (Test-Path -LiteralPath (Join-Path $packageRoot "[Content_Types].xml")) {
    $contentTypesPath = Join-Path $packageRoot "[Content_Types].xml"
    $contentTypes = Get-Content -LiteralPath $contentTypesPath -Raw
    $override = "<Override PartName=""/botcomponents/$KnowledgeSchema/data"" ContentType=""application/octet-stream"" />"
    if ($contentTypes -notlike "*$KnowledgeSchema/data*") {
        $contentTypes = $contentTypes -replace "</Types>", "$override</Types>"
        Save-Text -Path $contentTypesPath -Value $contentTypes
    }
}
else {
    Save-Text -Path (Join-Path $packageRoot "[Content_Types].xml") -Value @"
<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/octet-stream" /><Default Extension="json" ContentType="application/octet-stream" /><Override PartName="/botcomponents/$KnowledgeSchema/data" ContentType="application/octet-stream" /></Types>
"@
}

if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "solution.xml"))) {
    Save-Text -Path (Join-Path $packageRoot "solution.xml") -Value @"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2.26041.172" SolutionPackageVersion="9.2" languagecode="1046" generatedBy="CrmLive" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <SolutionManifest>
    <UniqueName>$SolutionUniqueName</UniqueName>
    <LocalizedNames>
      <LocalizedName description="PMO G4 Knowledge Patch" languagecode="1046" />
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
      <EMailAddress xsi:nil="true" />
      <SupportingWebsiteUrl xsi:nil="true" />
      <CustomizationPrefix>cr8a5</CustomizationPrefix>
      <CustomizationOptionValuePrefix>10000</CustomizationOptionValuePrefix>
      <Addresses />
    </Publisher>
    <RootComponents />
    <MissingDependencies />
  </SolutionManifest>
</ImportExportXml>
"@
}

if (-not (Test-Path -LiteralPath (Join-Path $packageRoot "customizations.xml"))) {
    Save-Text -Path (Join-Path $packageRoot "customizations.xml") -Value @"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <Entities />
  <Roles />
  <Workflows />
  <FieldSecurityProfiles />
  <Templates />
  <EntityMaps />
  <EntityRelationships />
  <OrganizationSettings />
  <optionsets />
  <CustomControls />
  <EntityDataProviders />
  <Languages>
    <Language>1046</Language>
  </Languages>
</ImportExportXml>
"@
}

if (Test-Path -LiteralPath $packageZip) {
    Remove-Item -LiteralPath $packageZip -Force
}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($packageZip, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in Get-ChildItem -LiteralPath $packageRoot -Recurse -File) {
        $relative = $file.FullName.Substring($packageRoot.Length).TrimStart('\', '/').Replace('\', '/')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $relative) | Out-Null
    }
}
finally {
    $zip.Dispose()
}

$import = Invoke-Pac -Command "pac solution import --environment $EnvironmentName --path `"$packageZip`" --publish-changes" -LogPath $importLog
$publish = Invoke-Pac -Command "pac copilot publish --environment $EnvironmentName --bot $BotId" -LogPath $publishLog -AllowFailure
Invoke-Pac -Command "pac copilot list --environment $EnvironmentName" -LogPath $listLog | Out-Null

Save-Json -Data ([ordered]@{
    timestamp = (Get-Date).ToString("o")
    status = if ($import.ExitCode -eq 0 -and $publish.ExitCode -eq 0) { "PASS" } else { "PASS_WITH_PUBLISH_WARNING" }
    environmentName = $EnvironmentName
    botId = $BotId
    botSchema = $BotSchema
    knowledgeSchema = $KnowledgeSchema
    knowledgeName = $KnowledgeName
    sharePointSite = $SharePointSite
    baseUnpackPath = $resolvedBase
    packageRoot = $packageRoot
    packageZip = $packageZip
    importLog = $importLog
    publishLog = $publishLog
    publishExitCode = $publish.ExitCode
    listLog = $listLog
}) -Path $manifestPath

Write-Host "Knowledge patch completed. Manifest: $manifestPath"
