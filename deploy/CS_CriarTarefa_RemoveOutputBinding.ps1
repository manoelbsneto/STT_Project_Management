[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$BotId = "0c4a9729-d55d-483c-8ec3-db9369583155",
    [string]$BotSchema = "pmo_AssistentePMO",
    [string]$SolutionUniqueName = "PMO_CriarTarefa_NoOutputBinding",
    [string]$EvidenceDir = ".planning\comms"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$evidenceRoot = Join-Path $repoRoot $EvidenceDir
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

function Write-Utf8NoBom {
    param([string]$Path, [string]$Text)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 100)
    Write-Utf8NoBom -Path $Path -Text ($Data | ConvertTo-Json -Depth $Depth)
}

function Invoke-Pac {
    param([string]$Command, [string]$LogPath, [switch]$AllowFailure)

    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $Command *>&1
    $output | Set-Content -LiteralPath $LogPath -Encoding UTF8
    $text = $output | Out-String
    $containsFailure = $text -match "FAILURE:" -or
        $text -match "Failed to publish" -or
        $text -match "non-recoverable error" -or
        $text -match "Exception Type:"

    if ((($LASTEXITCODE -ne 0) -or $containsFailure) -and -not $AllowFailure) {
        throw "PAC command failed. ExitCode=$LASTEXITCODE Log=$LogPath"
    }

    [ordered]@{
        ExitCode = $LASTEXITCODE
        LogPath = $LogPath
        Output = $text
        ContainsFailure = $containsFailure
    }
}

function Get-ComponentBlock {
    param([string]$Yaml, [string]$DisplayName)

    $displayMatch = [regex]::Match($Yaml, "(?m)^\s{4}displayName: $([regex]::Escape($DisplayName))\s*$")
    if (-not $displayMatch.Success) {
        throw "Could not find component block for $DisplayName."
    }

    $startMarker = "  - kind: DialogComponent"
    $start = $Yaml.LastIndexOf($startMarker, $displayMatch.Index, [System.StringComparison]::Ordinal)
    if ($start -lt 0) {
        throw "Could not find component start for $DisplayName."
    }

    $next = $Yaml.IndexOf("`n$startMarker", $displayMatch.Index + $displayMatch.Length, [System.StringComparison]::Ordinal)
    if ($next -lt 0) {
        $next = $Yaml.Length
    }

    $Yaml.Substring($start, $next - $start).TrimEnd()
}

function Get-DialogData {
    param([string]$ComponentBlock)

    $match = [regex]::Match($ComponentBlock, "(?ms)^\s{4}dialog:\r?\n(?<body>.*)$")
    if (-not $match.Success) {
        throw "Component block does not contain dialog."
    }

    $dialogBody = [regex]::Replace($match.Groups["body"].Value, "(?m)^      ", "")
    if ($dialogBody -match "(?m)^\s*beginDialog:") {
        $dialogBody = "kind: AdaptiveDialog`r`n" + $dialogBody
    }
    $dialogBody.TrimEnd() + "`r`n"
}

function Write-BotComponent {
    param(
        [string]$PackageRoot,
        [string]$SchemaName,
        [string]$DisplayName,
        [string]$Description,
        [string]$Data
    )

    $componentDir = Join-Path $PackageRoot "botcomponents\$SchemaName"
    New-Item -ItemType Directory -Force -Path $componentDir | Out-Null

    Write-Utf8NoBom -Path (Join-Path $componentDir "botcomponent.xml") -Text @"
<botcomponent schemaname="$SchemaName">
  <componenttype>9</componenttype>
  <description>$Description</description>
  <iscustomizable>1</iscustomizable>
  <name>$DisplayName</name>
  <parentbotid>
    <schemaname>$BotSchema</schemaname>
  </parentbotid>
  <statecode>0</statecode>
  <statuscode>1</statuscode>
</botcomponent>
"@

    Write-Utf8NoBom -Path (Join-Path $componentDir "data") -Text $Data
}

function Compress-SolutionPackage {
    param([string]$SourceRoot, [string]$DestinationPath)

    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Force
    }

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::Open($DestinationPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        $sourceFullPath = [System.IO.Path]::GetFullPath($SourceRoot).TrimEnd('\', '/')
        Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object {
            $fileFullPath = [System.IO.Path]::GetFullPath($_.FullName)
            $relativePath = $fileFullPath.Substring($sourceFullPath.Length + 1).Replace('\', '/')
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $fileFullPath, $relativePath, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
        }
    }
    finally {
        $zip.Dispose()
    }
}

$beforePath = Join-Path $evidenceRoot "cs_criartarefa_no_output_before_$timestamp.yaml"
$extractBeforeLog = Join-Path $evidenceRoot "pac_extract_criartarefa_no_output_before_$timestamp.txt"
Invoke-Pac -Command "pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFileName `"$beforePath`" --overwrite" -LogPath $extractBeforeLog | Out-Null

$yaml = Get-Content -LiteralPath $beforePath -Raw
$topicBlock = Get-ComponentBlock -Yaml $yaml -DisplayName "CriarTarefa"
$patchedTopicBlock = $topicBlock

$patchedTopicBlock = [regex]::Replace(
    $patchedTopicBlock,
    "(?ms)(                  - kind: BeginDialog\r?\n                    id: call_criar_tarefa\r?\n)(?:                    input: \{\}\r?\n)?(                    dialog: (?:template-content|pmo_AssistentePMO)\.action\.PMO_PA_CriarTarefa\r?\n)                    output:\r?\n                      binding:\r?\n                        result: Topic\.message\r?\n",
    "`$1`$2"
)

$patchedTopicBlock = [regex]::Replace(
    $patchedTopicBlock,
    "(?ms)                  - kind: SendActivity\r?\n                    id: criar_done\r?\n                    activity: (?:\|-\r?\n                      \{Topic\.message\}|`"\{Topic\.message\}`")",
    "                  - kind: SendActivity`r`n                    id: criar_done`r`n                    activity: Solicitacao enviada para criacao. O codigo do projeto sera gerado automaticamente."
)

if ($patchedTopicBlock -match "(?ms)id:\s*call_criar_tarefa.*?output:\s*" -or $patchedTopicBlock -match "Topic\.message") {
    throw "Patch failed: CriarTarefa still contains output binding or Topic.message."
}

$patchedYaml = $yaml.Replace($topicBlock, $patchedTopicBlock)
$patchedPath = Join-Path $evidenceRoot "cs_criartarefa_no_output_patched_$timestamp.yaml"
Write-Utf8NoBom -Path $patchedPath -Text $patchedYaml

$packageRoot = Join-Path $evidenceRoot "cs_criartarefa_no_output_package_$timestamp"
if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null

Write-BotComponent -PackageRoot $packageRoot -SchemaName "$BotSchema.topic.CriarTarefa" -DisplayName "CriarTarefa" -Description "Coleta dados de novo projeto/tarefa, confirma e aciona o fluxo CriarTarefa." -Data (Get-DialogData -ComponentBlock $patchedTopicBlock)

Write-Utf8NoBom -Path (Join-Path $packageRoot "[Content_Types].xml") -Text @"
<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/octet-stream" /><Default Extension="json" ContentType="application/octet-stream" /><Override PartName="/botcomponents/$BotSchema.topic.CriarTarefa/data" ContentType="application/octet-stream" /></Types>
"@

Write-Utf8NoBom -Path (Join-Path $packageRoot "solution.xml") -Text @"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2.26041.172" SolutionPackageVersion="9.2" languagecode="1046" generatedBy="CrmLive" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <SolutionManifest>
    <UniqueName>$SolutionUniqueName</UniqueName>
    <LocalizedNames>
      <LocalizedName description="PMO CriarTarefa No Output Binding" languagecode="1046" />
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
    <RootComponents />
    <MissingDependencies />
  </SolutionManifest>
</ImportExportXml>
"@

Write-Utf8NoBom -Path (Join-Path $packageRoot "customizations.xml") -Text @"
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

$zipPath = Join-Path $evidenceRoot "PMO_CriarTarefa_NoOutputBinding_$timestamp.zip"
Compress-SolutionPackage -SourceRoot $packageRoot -DestinationPath $zipPath

$importLog = Join-Path $evidenceRoot "pac_import_criartarefa_no_output_$timestamp.txt"
Invoke-Pac -Command "pac solution import --environment $EnvironmentName --path `"$zipPath`" --publish-changes --async false" -LogPath $importLog | Out-Null

$verifyPath = Join-Path $evidenceRoot "cs_criartarefa_no_output_verify_$timestamp.yaml"
$extractVerifyLog = Join-Path $evidenceRoot "pac_extract_criartarefa_no_output_verify_$timestamp.txt"
Invoke-Pac -Command "pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFileName `"$verifyPath`" --overwrite" -LogPath $extractVerifyLog | Out-Null

$verifyYaml = Get-Content -LiteralPath $verifyPath -Raw
$verifyTopicBlock = Get-ComponentBlock -Yaml $verifyYaml -DisplayName "CriarTarefa"
$checks = [ordered]@{
    includeInOnSelectIntent = $verifyTopicBlock -match "includeInOnSelectIntent:\s*true"
    hasCriarTarefaTriggers = ($verifyTopicBlock -match "criar tarefa") -and ($verifyTopicBlock -match "criar projeto") -and ($verifyTopicBlock -match "abrir tarefa")
    callsAction = $verifyTopicBlock -match "(?ms)id:\s*call_criar_tarefa.*?dialog:\s*(template-content|pmo_AssistentePMO)\.action\.PMO_PA_CriarTarefa"
    noOutputBinding = -not ($verifyTopicBlock -match "(?ms)id:\s*call_criar_tarefa.*?output:\s*")
    noTopicMessageReference = -not ($verifyTopicBlock -match "Topic\.message")
    noProjectIdPrompt = -not ($verifyTopicBlock -match "ask_projectid|Topic\.ProjectID|set_global_projectid")
}

$status = if ($checks.Values -contains $false) { "FAILED" } else { "PASS" }
$resultPath = Join-Path $evidenceRoot "cs_criartarefa_no_output_result_$timestamp.json"
Save-Json -Data ([ordered]@{
    timestamp = (Get-Date).ToString("o")
    status = $status
    environmentName = $EnvironmentName
    botId = $BotId
    beforePath = $beforePath
    patchedPath = $patchedPath
    verifyPath = $verifyPath
    packagePath = $zipPath
    importLog = $importLog
    checks = $checks
}) -Path $resultPath

Write-Host "CriarTarefa no-output-binding result: $resultPath"
if ($status -ne "PASS") {
    throw "CriarTarefa no-output-binding verification failed. See $resultPath"
}
