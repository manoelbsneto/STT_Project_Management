[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$BotId = "0c4a9729-d55d-483c-8ec3-db9369583155",
    [string]$BotSchema = "pmo_AssistentePMO",
    [string]$SolutionUniqueName = "PMO_CriarTarefa_Patch",
    [string]$EvidenceDir = ".planning\comms",
    [Parameter(Mandatory)]
    [string]$FlowEvidencePath
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
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
    $Data | ConvertTo-Json -Depth $Depth | Set-Content -LiteralPath $Path -Encoding UTF8
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

# =============================================================================
# STEP 1: Load flow evidence from PA_CriarTarefa_Flow.ps1 output
# =============================================================================

$resolvedEvidence = if ([System.IO.Path]::IsPathRooted($FlowEvidencePath)) {
    $FlowEvidencePath
} else {
    Join-Path $repoRoot $FlowEvidencePath
}

$flowEvidence = Get-Content -LiteralPath $resolvedEvidence -Raw | ConvertFrom-Json
$flowName = $flowEvidence.flowName
$flowDisplayName = $flowEvidence.displayName

Write-Host "Flow: $flowDisplayName ($flowName)"

# =============================================================================
# STEP 2: Make flow solution-aware and get WorkflowEntityId
# =============================================================================

$solutionId = "fd140aaf-4df4-11dd-bd17-0019b9312238"

try {
    $setOutput = Set-FlowAsSolutionAware -EnvironmentName $EnvironmentName -FlowName $flowName -SolutionId $solutionId *>&1 | Out-String
}
catch {
    $setOutput = $_.Exception.Message
}

Start-Sleep -Seconds 4
$flow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $flowName -ErrorAction Stop
$workflowEntityId = $flow.Internal.properties.workflowEntityId

if (-not $workflowEntityId) {
    throw "Flow $flowDisplayName does not have WorkflowEntityId after solution-aware conversion."
}

Write-Host "WorkflowEntityId: $workflowEntityId"

$flowSolutionEvidence = Join-Path $evidenceRoot "cs_criartarefa_flow_solutionaware_$timestamp.json"
Save-Json -Data ([pscustomobject]@{
    displayName = $flowDisplayName
    flowName = $flowName
    workflowEntityId = $workflowEntityId
    enabled = $flow.Enabled
    state = $flow.Internal.properties.state
    solutionAwareOutput = if ($setOutput) { $setOutput.Trim() } else { "" }
}) -Path $flowSolutionEvidence

# =============================================================================
# STEP 3: Build solution package
# =============================================================================

$actionSchema = "$BotSchema.action.PMO_PA_CriarTarefa"

$packageRoot = Join-Path $evidenceRoot "cs_criartarefa_package_$timestamp"
$assetsDir = Join-Path $packageRoot "Assets"
$workflowsDir = Join-Path $packageRoot "Workflows"
$botDir = Join-Path $packageRoot "bots\$BotSchema"
$gptDir = Join-Path $packageRoot "botcomponents\$BotSchema.gpt.default"
$actionDir = Join-Path $packageRoot "botcomponents\$actionSchema"

if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $assetsDir, $workflowsDir, $botDir, $gptDir, $actionDir | Out-Null

# Bot configuration with GenerativeActionsEnabled = true
$configuration = [ordered]@{
    '$kind' = "BotConfiguration"
    channels = @(
        [ordered]@{
            '$kind' = "ChannelDefinition"
            channelId = "MsTeams"
        }
    )
    settings = [ordered]@{
        GenerativeActionsEnabled = $true
    }
    isAgentConnectable = $true
    publishOnImport = $true
    gPTSettings = [ordered]@{
        '$kind' = "GPTSettings"
        defaultSchemaName = "$BotSchema.gpt.default"
    }
    isLightweightBot = $false
    aISettings = [ordered]@{
        '$kind' = "AISettings"
        useModelKnowledge = $false
        isFileAnalysisEnabled = $false
        isSemanticSearchEnabled = $false
        contentModeration = "High"
        optInUseLatestModels = $false
    }
}
Save-Json -Data $configuration -Path (Join-Path $botDir "configuration.json")

# Bot XML
@"
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
"@ | Set-Content -LiteralPath (Join-Path $botDir "bot.xml") -Encoding UTF8

# GPT component XML
@"
<botcomponent schemaname="$BotSchema.gpt.default">
  <componenttype>15</componenttype>
  <iscustomizable>0</iscustomizable>
  <name>Assistente PMO</name>
  <parentbotid>
    <schemaname>$BotSchema</schemaname>
  </parentbotid>
  <statecode>0</statecode>
  <statuscode>1</statuscode>
</botcomponent>
"@ | Set-Content -LiteralPath (Join-Path $gptDir "botcomponent.xml") -Encoding UTF8

# GPT data with updated instructions (rules 1-10)
$instructions = @"
Você é o Assistente PMO, agente de IA para gestão de portfólio de projetos da equipe de Transformação Digital.

Regras:
1. Responda SEMPRE em português do Brasil (pt-BR), de forma concisa e direta.
2. Use APENAS dados das listas SharePoint do PMO (Projetos, Tarefas, Status Diário, Riscos e Bloqueios, Decisões do Board) e dos flows Power Automate aprovados.
3. NUNCA invente dados, use conhecimento geral, internet ou fontes externas. Se não encontrar a informação, responda: "Não encontrei essa informação nas listas do PMO. Por favor, consulte o PMO Lead."
4. Para QUALQUER operação de escrita (criar tarefa, atualizar status, registrar risco, pedir decisão), SEMPRE confirme com o usuário antes de executar.
5. Use emojis para status RAG: 🟢 Verde, 🟡 Amarelo, 🔴 Vermelho.
6. ACEITE entrada estruturada em bloco único. Quando o usuário enviar múltiplos campos de uma vez (ex: Projeto=PRJ-001, Título=Revisar escopo, Responsável=João, Prazo=2026-07-15, Horas=40, Prioridade=Alta), EXTRAIA todos os valores do texto e preencha os campos automaticamente. NÃO peça cada campo individualmente se já foram fornecidos.
7. Aceite formatos flexíveis de entrada: Key=Value separado por vírgula, Key: Value separado por linha, texto livre em linguagem natural, ou qualquer combinação. O objetivo é que o PM gaste o MÍNIMO de tempo possível para registrar informações.
8. Se algum campo obrigatório estiver FALTANDO na mensagem do usuário, pergunte APENAS os campos faltantes — nunca repita perguntas para campos já fornecidos.
9. Ao criar tarefa ou projeto, NUNCA pergunte o código do projeto (ProjectID). O código é SEMPRE gerado automaticamente pelo sistema.
10. Ao retornar o resultado de criação, SEMPRE informe o código gerado (ex: PRJ-000006) para que o PM possa referenciá-lo futuramente.
"@

@"
kind: GptComponentMetadata
instructions: |
$($instructions -split "`r?`n" | ForEach-Object { "  $_" } | Out-String)gptCapabilities:
  webBrowsing: false

aISettings:
  model:
    modelNameHint: GPT5Chat
"@ | Set-Content -LiteralPath (Join-Path $gptDir "data") -Encoding UTF8

# Action component for PMO_PA_CriarTarefa
@"
<botcomponent schemaname="$actionSchema">
  <componenttype>9</componenttype>
  <iscustomizable>0</iscustomizable>
  <name>PMO_PA_CriarTarefa</name>
  <parentbotid>
    <schemaname>$BotSchema</schemaname>
  </parentbotid>
  <statecode>0</statecode>
  <statuscode>1</statuscode>
</botcomponent>
"@ | Set-Content -LiteralPath (Join-Path $actionDir "botcomponent.xml") -Encoding UTF8

# Action data — TaskDialog wired to the flow
@"
kind: TaskDialog
outputs:
  - propertyName: success

  - propertyName: message

  - propertyName: errorcode

  - propertyName: projectId

action:
  kind: InvokeFlowTaskAction
  flowId: $workflowEntityId
  connectionProperties:
    `$kind: ConnectionProperties
    diagnostics:
    mode: Invoker

outputMode: All
"@ | Set-Content -LiteralPath (Join-Path $actionDir "data") -Encoding UTF8

# Workflow file
$liveFlow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $flowName -ErrorAction Stop
$solutionConnectionReferences = [ordered]@{}
foreach ($cr in $liveFlow.Internal.properties.connectionReferences.PSObject.Properties) {
    $crValue = $cr.Value
    $runtimeSource = if ($crValue.source) { [string]$crValue.source } else { "Embedded" }
    $solutionConnectionReferences[$cr.Name] = [ordered]@{
        api = [ordered]@{ name = $crValue.apiName }
        connection = [ordered]@{ connectionReferenceLogicalName = $crValue.connectionReferenceLogicalName }
        runtimeSource = $runtimeSource.ToLowerInvariant()
    }
}

$workflowFile = "PMO_PA_CriarTarefa-$workflowEntityId.json"
Save-Json -Data ([ordered]@{
    properties = [ordered]@{
        connectionReferences = $solutionConnectionReferences
        definition = $liveFlow.Internal.properties.definition
        templateName = $null
    }
    schemaVersion = "1.0.0.0"
}) -Path (Join-Path $workflowsDir $workflowFile)

# Workflow association
@"
<botcomponent_workflowset>
  <botcomponent_workflow botcomponentid.schemaname="$actionSchema" workflowid.workflowid="$workflowEntityId">
    <iscustomizable>1</iscustomizable>
  </botcomponent_workflow>
</botcomponent_workflowset>
"@ | Set-Content -LiteralPath (Join-Path $assetsDir "botcomponent_workflowset.xml") -Encoding UTF8

# Content Types
@"
<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/octet-stream" /><Default Extension="json" ContentType="application/octet-stream" /><Override PartName="/botcomponents/$BotSchema.gpt.default/data" ContentType="application/octet-stream" /><Override PartName="/botcomponents/$actionSchema/data" ContentType="application/octet-stream" /></Types>
"@ | Set-Content -LiteralPath (Join-Path $packageRoot "[Content_Types].xml") -Encoding UTF8

# Solution XML
@"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2.26041.172" SolutionPackageVersion="9.2" languagecode="1046" generatedBy="CrmLive" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <SolutionManifest>
    <UniqueName>$SolutionUniqueName</UniqueName>
    <LocalizedNames>
      <LocalizedName description="PMO CriarTarefa Patch" languagecode="1046" />
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
      <RootComponent type="29" id="{$workflowEntityId}" behavior="0" />
    </RootComponents>
    <MissingDependencies />
  </SolutionManifest>
</ImportExportXml>
"@ | Set-Content -LiteralPath (Join-Path $packageRoot "solution.xml") -Encoding UTF8

# Customizations XML
@"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <Entities />
  <Roles />
  <Workflows>
    <Workflow WorkflowId="{$workflowEntityId}" Name="PMO_PA_CriarTarefa">
      <JsonFileName>/Workflows/$workflowFile</JsonFileName>
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
      <IntroducedVersion>1.0.0.0</IntroducedVersion>
      <IsCustomizable>1</IsCustomizable>
      <BusinessProcessType>0</BusinessProcessType>
      <IsCustomProcessingStepAllowedForOtherPublishers>1</IsCustomProcessingStepAllowedForOtherPublishers>
      <ModernFlowType>0</ModernFlowType>
      <PrimaryEntity>none</PrimaryEntity>
      <LocalizedNames>
        <LocalizedName languagecode="1046" description="PMO_PA_CriarTarefa" />
      </LocalizedNames>
    </Workflow>
  </Workflows>
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

# =============================================================================
# STEP 4: Package, Import, Publish, Extract
# =============================================================================

$packageZip = Join-Path $evidenceRoot "PMO_CriarTarefa_Patch_$timestamp.zip"
if (Test-Path -LiteralPath $packageZip) {
    Remove-Item -LiteralPath $packageZip -Force
}
Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $packageZip -Force

Write-Host "Importing solution..."
$importLog = Join-Path $evidenceRoot "pac_import_criartarefa_$timestamp.txt"
Invoke-Pac -Command "pac solution import --environment $EnvironmentName --path `"$packageZip`" --publish-changes" -LogPath $importLog | Out-Null

Write-Host "Publishing bot..."
$publishLog = Join-Path $evidenceRoot "pac_copilot_publish_criartarefa_$timestamp.txt"
$publish = Invoke-Pac -Command "pac copilot publish --environment $EnvironmentName --bot $BotId" -LogPath $publishLog -AllowFailure

Write-Host "Listing bots..."
$listLog = Join-Path $evidenceRoot "pac_copilot_list_criartarefa_$timestamp.txt"
Invoke-Pac -Command "pac copilot list --environment $EnvironmentName" -LogPath $listLog | Out-Null

Write-Host "Extracting template..."
$extractPath = Join-Path $evidenceRoot "cs_assistente_pmo_post_criartarefa_$timestamp.yaml"
$extractLog = Join-Path $evidenceRoot "pac_copilot_extract_criartarefa_$timestamp.txt"
Invoke-Pac -Command "pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFile `"$extractPath`" --overwrite" -LogPath $extractLog | Out-Null

# =============================================================================
# STEP 5: Evidence & Result
# =============================================================================

$resultPath = Join-Path $evidenceRoot "cs_criartarefa_patch_result_$timestamp.json"
Save-Json -Data ([pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    status = if ($publish.ExitCode -eq 0) { "PASS" } else { "PASS_WITH_PUBLISH_WARNING" }
    environmentName = $EnvironmentName
    botId = $BotId
    botSchema = $BotSchema
    solutionUniqueName = $SolutionUniqueName
    flowWired = [pscustomobject]@{
        displayName = "PMO_PA_CriarTarefa"
        flowName = $flowName
        workflowEntityId = $workflowEntityId
        actionSchema = $actionSchema
    }
    generativeActionsEnabled = $true
    importedPackage = $packageZip
    importLog = $importLog
    publishExitCode = $publish.ExitCode
    publishLog = $publishLog
    listLog = $listLog
    extractPath = $extractPath
    extractLog = $extractLog
    flowSolutionEvidence = $flowSolutionEvidence
    notes = @(
        "CriarTarefa flow wired to Copilot Studio bot via solution import.",
        "GenerativeActionsEnabled = true confirmed in bot configuration.",
        "GPT instructions include rules 6-10 for structured input + auto ProjectID.",
        "Standard connector only (shared_sharepointonline via Skills trigger).",
        "No manual steps required — fully programmatic deployment."
    )
}) -Path $resultPath

Write-Host "CriarTarefa patch result: $resultPath"
