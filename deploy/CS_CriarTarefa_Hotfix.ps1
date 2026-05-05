[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$BotId = "0c4a9729-d55d-483c-8ec3-db9369583155",
    [string]$BotSchema = "pmo_AssistentePMO",
    [string]$SolutionUniqueName = "PMO_CriarTarefa_RoutingHotfix",
    [string]$EvidenceDir = ".planning\comms"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$evidenceRoot = Join-Path $repoRoot $EvidenceDir
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 100)
    $Data | ConvertTo-Json -Depth $Depth | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Invoke-Pac {
    param([string]$Command, [string]$LogPath, [switch]$AllowFailure)
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $Command *>&1
    $output | Set-Content -LiteralPath $LogPath -Encoding UTF8
    $text = $output | Out-String
    $containsPacFailure = $text -match "(?m)^\s*Error:" -or $text -match "FAILURE:" -or $text -match "Failed to publish" -or $text -match "non-recoverable error" -or $text -match "Exception Type:"
    if ((($LASTEXITCODE -ne 0) -or $containsPacFailure) -and -not $AllowFailure) {
        throw "PAC command failed with exit code $LASTEXITCODE. See $LogPath"
    }
    [ordered]@{
        ExitCode = $LASTEXITCODE
        LogPath = $LogPath
        ContainsFailure = $containsPacFailure
    }
}

function Get-ComponentBlock {
    param(
        [string]$Yaml,
        [string]$DisplayName
    )

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
    param(
        [string]$ComponentBlock
    )

    $match = [regex]::Match($ComponentBlock, "(?ms)^\s{4}dialog:\r?\n(?<body>.*)$")
    if (-not $match.Success) {
        throw "Component block does not contain dialog."
    }

    $dialogBody = $match.Groups["body"].Value
    $dialogBody = [regex]::Replace($dialogBody, "(?m)^      ", "")
    "kind: AdaptiveDialog`r`n$dialogBody"
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

@"
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
"@ | Set-Content -LiteralPath (Join-Path $componentDir "botcomponent.xml") -Encoding UTF8

    $Data | Set-Content -LiteralPath (Join-Path $componentDir "data") -Encoding UTF8
}

# Step 1: Extract current template
$beforePath = Join-Path $evidenceRoot "cs_criartarefa_hotfix_before_$timestamp.yaml"
$extractBeforeLog = Join-Path $evidenceRoot "pac_copilot_extract_criartarefa_hotfix_before_$timestamp.txt"
Invoke-Pac -Command "pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFileName `"$beforePath`" --overwrite" -LogPath $extractBeforeLog | Out-Null

# Step 2: Patch YAML programmatically
$yaml = Get-Content -LiteralPath $beforePath -Raw
$originalYaml = $yaml

$lowConfidenceOld = 'activity: "Não entendi bem. Você pode reformular? Posso ajudar com: atualizar status, consultar portfólio, registrar risco, solicitar decisão."'
$lowConfidenceNew = 'activity: "Não entendi bem. Você pode reformular? Posso ajudar com: criar tarefa/projeto, atualizar tarefa, atualizar status, consultar portfólio, consultar projeto, listar tarefas, registrar risco, registrar bloqueio, solicitar decisão."'
$yaml = $yaml.Replace($lowConfidenceOld, $lowConfidenceNew)

$criarBlock = Get-ComponentBlock -Yaml $yaml -DisplayName "CriarTarefa"
$patchedCriarBlock = $criarBlock
$patchedCriarBlock = $patchedCriarBlock.Replace("includeInOnSelectIntent: false", "includeInOnSelectIntent: true")

$triggerNew = @"
          triggerQueries:
            - criar tarefa
            - nova tarefa
            - adicionar tarefa
            - cadastrar tarefa
            - criar projeto
            - novo projeto
            - abrir projeto
            - registrar projeto
            - "criar tarefa:"
            - abrir tarefa
"@
$patchedCriarBlock = [regex]::Replace(
    $patchedCriarBlock,
    "(?ms)          triggerQueries:\r?\n(?:            - .+?\r?\n)+\r?\n        actions:",
    ($triggerNew + "`r`n        actions:")
)

$patchedCriarBlock = [regex]::Replace(
    $patchedCriarBlock,
    "(?ms)\r?\n          - kind: Question\r?\n            id: ask_projectid\r?\n            variable: Topic\.ProjectID\r?\n            prompt: `"Qual o código do projeto\? \(ex: PRJ-001\)`"\r?\n            entity: StringPrebuiltEntity\r?\n",
    ""
)

$confirmNew = @"
              Vou criar a tarefa '{Topic.Title}'.
              Responsável: {Topic.Responsavel}
              Prazo: {Topic.DataFim}
              Horas: {Topic.HorasEstimadas}h
              Prioridade: {Topic.Prioridade}
              (O código do projeto será gerado automaticamente)

              Confirma?
"@
$patchedCriarBlock = [regex]::Replace(
    $patchedCriarBlock,
    "(?ms)              Vou criar a tarefa '\{Topic\.Title\}' no projeto \{Topic\.ProjectID\}\.\r?\n              Responsável: \{Topic\.Responsavel\}\r?\n              Prazo: \{Topic\.DataFim\}\r?\n              Horas: \{Topic\.HorasEstimadas\}h\r?\n              Prioridade: \{Topic\.Prioridade\}\r?\n\r?\n              Confirma\?",
    $confirmNew.TrimEnd()
)

$patchedCriarBlock = [regex]::Replace(
    $patchedCriarBlock,
    "(?ms)\r?\n                  - kind: SetVariable\r?\n                    id: set_global_projectid\r?\n                    variable: Global\.PMO_Criar_ProjectID\r?\n                    value: =Topic\.ProjectID\r?\n",
    ""
)

$successNew = @"
                      Tarefa criada com sucesso.

                      Título: {Topic.Title}
"@
$patchedCriarBlock = [regex]::Replace(
    $patchedCriarBlock,
    "(?ms)                      Tarefa criada com sucesso\.\r?\n\r?\n                      Projeto: \{Topic\.ProjectID\}\r?\n                      Título: \{Topic\.Title\}",
    $successNew.TrimEnd()
)

$yaml = $yaml.Replace($criarBlock, $patchedCriarBlock)

if ($yaml -eq $originalYaml) {
    throw "Hotfix patch made no changes."
}

$patchedPath = Join-Path $evidenceRoot "cs_criartarefa_hotfix_patched_$timestamp.yaml"
$yaml | Set-Content -LiteralPath $patchedPath -Encoding UTF8

# Step 3: Import patched components. PAC 2.6.4 has no `copilot import-template`;
# use a minimal solution package containing only CriarTarefa and LowConfidence.
$packageRoot = Join-Path $evidenceRoot "cs_criartarefa_hotfix_package_$timestamp"
if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null

$lowConfidenceBlock = Get-ComponentBlock -Yaml $yaml -DisplayName "LowConfidence"
$lowConfidenceData = Get-DialogData -ComponentBlock $lowConfidenceBlock
$criarTarefaData = Get-DialogData -ComponentBlock $patchedCriarBlock

Write-BotComponent -PackageRoot $packageRoot -SchemaName "$BotSchema.topic.LowConfidence" -DisplayName "LowConfidence" -Description "Fallback quando a intenção não for reconhecida." -Data $lowConfidenceData
Write-BotComponent -PackageRoot $packageRoot -SchemaName "$BotSchema.topic.CriarTarefa" -DisplayName "CriarTarefa" -Description "Coleta dados de nova tarefa, confirma antes de acionar o fluxo CriarTarefa." -Data $criarTarefaData

@"
<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/octet-stream" /><Default Extension="json" ContentType="application/octet-stream" /><Override PartName="/botcomponents/$BotSchema.topic.LowConfidence/data" ContentType="application/octet-stream" /><Override PartName="/botcomponents/$BotSchema.topic.CriarTarefa/data" ContentType="application/octet-stream" /></Types>
"@ | Set-Content -LiteralPath (Join-Path $packageRoot "[Content_Types].xml") -Encoding UTF8

@"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2.26041.172" SolutionPackageVersion="9.2" languagecode="1046" generatedBy="CrmLive" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <SolutionManifest>
    <UniqueName>$SolutionUniqueName</UniqueName>
    <LocalizedNames>
      <LocalizedName description="PMO CriarTarefa Routing Hotfix" languagecode="1046" />
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
"@ | Set-Content -LiteralPath (Join-Path $packageRoot "solution.xml") -Encoding UTF8

@"
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
"@ | Set-Content -LiteralPath (Join-Path $packageRoot "customizations.xml") -Encoding UTF8

$packageZip = Join-Path $evidenceRoot "PMO_CriarTarefa_RoutingHotfix_$timestamp.zip"
if (Test-Path -LiteralPath $packageZip) {
    Remove-Item -LiteralPath $packageZip -Force
}
Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $packageZip -Force

$importLog = Join-Path $evidenceRoot "pac_import_criartarefa_hotfix_$timestamp.txt"
Invoke-Pac -Command "pac solution import --environment $EnvironmentName --path `"$packageZip`" --publish-changes" -LogPath $importLog | Out-Null

# Step 4: Publish
$publishLog = Join-Path $evidenceRoot "pac_copilot_publish_criartarefa_hotfix_$timestamp.txt"
$publish = Invoke-Pac -Command "pac copilot publish --environment $EnvironmentName --bot $BotId" -LogPath $publishLog -AllowFailure

$listLog = Join-Path $evidenceRoot "pac_copilot_list_criartarefa_hotfix_$timestamp.txt"
Invoke-Pac -Command "pac copilot list --environment $EnvironmentName" -LogPath $listLog | Out-Null
$listText = Get-Content -LiteralPath $listLog -Raw

# Step 5: Extract again to verify
$verifyPath = Join-Path $evidenceRoot "cs_criartarefa_hotfix_verify_$timestamp.yaml"
$extractVerifyLog = Join-Path $evidenceRoot "pac_copilot_extract_criartarefa_hotfix_verify_$timestamp.txt"
Invoke-Pac -Command "pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFileName `"$verifyPath`" --overwrite" -LogPath $extractVerifyLog | Out-Null

$verifyYaml = Get-Content -LiteralPath $verifyPath -Raw
$verifyCriarBlock = Get-ComponentBlock -Yaml $verifyYaml -DisplayName "CriarTarefa"
$verifyLowConfidenceBlock = Get-ComponentBlock -Yaml $verifyYaml -DisplayName "LowConfidence"

$triggerPhraseChecks = @(
    "criar tarefa",
    "nova tarefa",
    "adicionar tarefa",
    "cadastrar tarefa",
    "criar projeto",
    "novo projeto",
    "abrir projeto",
    "registrar projeto",
    "criar tarefa:",
    "abrir tarefa"
)

$verification = [ordered]@{
    criarTarefaIncludeInOnSelectIntent = ($verifyCriarBlock -match "includeInOnSelectIntent:\s*true")
    criarTarefaTriggerPhraseCount = ([regex]::Matches($verifyCriarBlock, "(?m)^\s+- (`"|')?(criar tarefa|nova tarefa|adicionar tarefa|cadastrar tarefa|criar projeto|novo projeto|abrir projeto|registrar projeto|criar tarefa:|abrir tarefa)(`"|')?\s*$")).Count
    criarTarefaHasAllTriggerPhrases = (@($triggerPhraseChecks | Where-Object { $verifyCriarBlock -notmatch "(?m)^\s+- (`"|')?$([regex]::Escape($_))(`"|')?\s*$" }).Count -eq 0)
    lowConfidenceMentionsCriarTarefaProjeto = ($verifyLowConfidenceBlock -match "criar tarefa/projeto")
    noAskProjectId = ($verifyCriarBlock -notmatch "id:\s*ask_projectid")
    confirmationDoesNotReferenceProjectId = ($verifyCriarBlock -notmatch "Vou criar a tarefa '\{Topic\.Title\}' no projeto \{Topic\.ProjectID\}")
    noSetGlobalProjectId = ($verifyCriarBlock -notmatch "id:\s*set_global_projectid")
    botListShowsPublished = ($listText -match "Assistente PMO\s+$([regex]::Escape($BotId))\s+Published\s+False\s+\S+\s+Active\s+Provisioned")
}

$failedChecks = @($verification.GetEnumerator() | Where-Object {
    if ($_.Key -eq "criarTarefaTriggerPhraseCount") { $_.Value -ne 10 } else { $_.Value -ne $true }
} | ForEach-Object { $_.Key })
if ($failedChecks.Count -gt 0) {
    throw "CriarTarefa routing hotfix verification failed: $($failedChecks -join ', ')"
}

$resultPath = Join-Path $evidenceRoot "cs_criartarefa_hotfix_result_$timestamp.json"
Save-Json -Data ([ordered]@{
    timestamp = (Get-Date).ToString("o")
    status = if ($publish.ContainsFailure) { "PASS_WITH_PUBLISH_CLI_WARNING" } else { "PASS" }
    environmentName = $EnvironmentName
    botId = $BotId
    botSchema = $BotSchema
    pacImportTemplateAvailable = $false
    importMethod = "minimal_solution_package"
    beforeTemplate = $beforePath
    patchedTemplate = $patchedPath
    verifyTemplate = $verifyPath
    packageZip = $packageZip
    importLog = $importLog
    publishLog = $publishLog
    publishExitCode = $publish.ExitCode
    publishContainsFailure = $publish.ContainsFailure
    listLog = $listLog
    extractBeforeLog = $extractBeforeLog
    extractVerifyLog = $extractVerifyLog
    verification = $verification
}) -Path $resultPath

Write-Host "CriarTarefa routing hotfix result: $resultPath"
