[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$SolutionId = "fd140aaf-4df4-11dd-bd17-0019b9312238",
    [string]$BotId = "0c4a9729-d55d-483c-8ec3-db9369583155",
    [string]$BotSchema = "pmo_AssistentePMO",
    [string]$SolutionUniqueName = "PMO_G4_Completion",
    [string]$EvidenceDir = ".planning\comms",
    [string]$ExistingFlowEvidence
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

function Escape-Xml {
    param([string]$Value)
    [System.Security.SecurityElement]::Escape($Value)
}

$instructions = @"
Você é o Assistente PMO, um agente de IA para gestão de portfólio de projetos da equipe de Transformação Digital.

Regras:
1. Responda SEMPRE em português do Brasil (pt-BR).
2. Use APENAS dados das listas SharePoint do PMO (Projetos, Status Diário, Riscos e Bloqueios, Decisões do Board).
3. NUNCA invente dados. Se não encontrar informação, diga 'Não encontrei essa informação nas listas do PMO.'
4. Para QUALQUER operação de escrita (atualizar status, registrar risco, pedir decisão, criar tarefa), SEMPRE confirme com o usuário antes de executar.
5. NÃO pesquise na internet. NÃO use conhecimento genérico.
6. Formate respostas com emojis para status: 🟢 Verde, 🟡 Amarelo, 🔴 Vermelho.
7. Seja conciso e direto.
8. ACEITE entrada estruturada em bloco único. Quando o usuário enviar múltiplos campos de uma vez (ex: Projeto=PRJ-001, Título=..., Responsável=..., Prazo=..., Horas=..., Prioridade=...), EXTRAIA todos os valores do texto e preencha os campos automaticamente. NÃO peça cada campo individualmente se já foram fornecidos.
9. Aceite entrada em formatos flexíveis: Key=Value separado por vírgula, Key: Value separado por linha, texto livre em linguagem natural, ou qualquer combinação. O objetivo é que o PM gaste o MÍNIMO de tempo possível.
10. Se algum campo obrigatório estiver FALTANDO na mensagem do usuário, pergunte APENAS os campos faltantes — nunca repita perguntas para campos já fornecidos.
"@

$flows = @(
    [pscustomobject]@{
        DisplayName = "PMO_PA_EscalarRiscoCritico"
        FlowName = "cd0467a2-c989-474e-a629-28c704913489"
        Schema = "$BotSchema.action.PMO_PA_EscalarRiscoCritico"
    },
    [pscustomobject]@{
        DisplayName = "PMO_PA_RegistrarDecisaoBoard"
        FlowName = "f67daf7b-53a7-4d35-9275-7c8c42a35896"
        Schema = "$BotSchema.action.PMO_PA_RegistrarDecisaoBoard"
    }
)

if ($ExistingFlowEvidence) {
    $resolvedEvidence = if ([System.IO.Path]::IsPathRooted($ExistingFlowEvidence)) { $ExistingFlowEvidence } else { Join-Path $repoRoot $ExistingFlowEvidence }
    $flowResults = Get-Content -LiteralPath $resolvedEvidence -Raw | ConvertFrom-Json
    $flowEvidence = $resolvedEvidence
}
else {
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

    $flowEvidence = Join-Path $evidenceRoot "g4_flow_solutionaware_workflowids_$timestamp.json"
    Save-Json -Data $flowResults -Path $flowEvidence
}

if (@($flowResults | Where-Object { -not $_.WorkflowEntityId }).Count -gt 0) {
    throw "One or more target flows do not have WorkflowEntityId after solution-aware conversion. See $flowEvidence"
}

$packageRoot = Join-Path $evidenceRoot "g4_completion_package_$timestamp"
$assetsDir = Join-Path $packageRoot "Assets"
$workflowsDir = Join-Path $packageRoot "Workflows"
$botDir = Join-Path $packageRoot "bots\$BotSchema"
$gptDir = Join-Path $packageRoot "botcomponents\$BotSchema.gpt.default"
if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $assetsDir, $workflowsDir, $botDir, $gptDir | Out-Null

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

@"
kind: GptComponentMetadata
instructions: |
$($instructions -split "`r?`n" | ForEach-Object { "  $_" } | Out-String)gptCapabilities:
  webBrowsing: false

aISettings:
  model:
    modelNameHint: GPT5Chat
"@ | Set-Content -LiteralPath (Join-Path $gptDir "data") -Encoding UTF8

$workflowAssociationRows = [System.Text.StringBuilder]::new()
$contentTypeOverrides = [System.Text.StringBuilder]::new()
[void]$contentTypeOverrides.AppendLine('<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/octet-stream" /><Default Extension="json" ContentType="application/octet-stream" />')
[void]$contentTypeOverrides.AppendLine("<Override PartName=""/botcomponents/$BotSchema.gpt.default/data"" ContentType=""application/octet-stream"" />")

$workflowCustomizations = [System.Text.StringBuilder]::new()
$workflowRootComponents = [System.Text.StringBuilder]::new()

foreach ($flowResult in $flowResults) {
    $actionDir = Join-Path $packageRoot "botcomponents\$($flowResult.Schema)"
    New-Item -ItemType Directory -Force -Path $actionDir | Out-Null

    $liveFlow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $flowResult.FlowName -ErrorAction Stop
    $solutionConnectionReferences = [ordered]@{}
    foreach ($cr in $liveFlow.Internal.properties.connectionReferences.PSObject.Properties) {
        $crValue = $cr.Value
        $runtimeSource = if ($crValue.source) { [string]$crValue.source } else { "Embedded" }
        $solutionConnectionReferences[$cr.Name] = [ordered]@{
            api = [ordered]@{
                name = $crValue.apiName
            }
            connection = [ordered]@{
                connectionReferenceLogicalName = $crValue.connectionReferenceLogicalName
            }
            runtimeSource = $runtimeSource.ToLowerInvariant()
        }
    }

    $workflowFile = "$($flowResult.DisplayName)-$($flowResult.WorkflowEntityId).json"
    Save-Json -Data ([ordered]@{
        properties = [ordered]@{
            connectionReferences = $solutionConnectionReferences
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
    [void]$workflowCustomizations.AppendLine("      <ModernFlowType>0</ModernFlowType>")
    [void]$workflowCustomizations.AppendLine("      <PrimaryEntity>none</PrimaryEntity>")
    [void]$workflowCustomizations.AppendLine("      <LocalizedNames>")
    [void]$workflowCustomizations.AppendLine("        <LocalizedName languagecode=""1046"" description=""$($flowResult.DisplayName)"" />")
    [void]$workflowCustomizations.AppendLine("      </LocalizedNames>")
    [void]$workflowCustomizations.AppendLine("    </Workflow>")

    @"
<botcomponent schemaname="$($flowResult.Schema)">
  <componenttype>9</componenttype>
  <iscustomizable>0</iscustomizable>
  <name>$($flowResult.DisplayName)</name>
  <parentbotid>
    <schemaname>$BotSchema</schemaname>
  </parentbotid>
  <statecode>0</statecode>
  <statuscode>1</statuscode>
</botcomponent>
"@ | Set-Content -LiteralPath (Join-Path $actionDir "botcomponent.xml") -Encoding UTF8

    @"
kind: TaskDialog
outputs:
  - propertyName: success

  - propertyName: message

  - propertyName: errorcode

action:
  kind: InvokeFlowTaskAction
  flowId: $($flowResult.WorkflowEntityId)
  connectionProperties:
    `$kind: ConnectionProperties
    diagnostics:
    mode: Invoker

outputMode: All
"@ | Set-Content -LiteralPath (Join-Path $actionDir "data") -Encoding UTF8

    [void]$workflowAssociationRows.AppendLine("  <botcomponent_workflow botcomponentid.schemaname=""$($flowResult.Schema)"" workflowid.workflowid=""$($flowResult.WorkflowEntityId)"">")
    [void]$workflowAssociationRows.AppendLine("    <iscustomizable>1</iscustomizable>")
    [void]$workflowAssociationRows.AppendLine("  </botcomponent_workflow>")
    [void]$contentTypeOverrides.AppendLine("<Override PartName=""/botcomponents/$($flowResult.Schema)/data"" ContentType=""application/octet-stream"" />")
}

@"
<botcomponent_workflowset>
$($workflowAssociationRows.ToString().TrimEnd())
</botcomponent_workflowset>
"@ | Set-Content -LiteralPath (Join-Path $assetsDir "botcomponent_workflowset.xml") -Encoding UTF8

[void]$contentTypeOverrides.AppendLine("</Types>")
$contentTypeOverrides.ToString() | Set-Content -LiteralPath (Join-Path $packageRoot "[Content_Types].xml") -Encoding UTF8

@"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2.26041.172" SolutionPackageVersion="9.2" languagecode="1046" generatedBy="CrmLive" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <SolutionManifest>
    <UniqueName>$SolutionUniqueName</UniqueName>
    <LocalizedNames>
      <LocalizedName description="PMO G4 Completion" languagecode="1046" />
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
"@ | Set-Content -LiteralPath (Join-Path $packageRoot "solution.xml") -Encoding UTF8

@"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <Entities />
  <Roles />
  <Workflows>
$($workflowCustomizations.ToString().TrimEnd())
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

$packageZip = Join-Path $evidenceRoot "PMO_G4_Completion_$timestamp.zip"
if (Test-Path -LiteralPath $packageZip) {
    Remove-Item -LiteralPath $packageZip -Force
}
Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $packageZip -Force

$manifestPath = Join-Path $evidenceRoot "g4_completion_package_manifest_$timestamp.json"
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
    instructionsConfigured = $true
    webBrowsingDisabled = $true
    modelKnowledgeDisabled = $true
}) -Path $manifestPath

$importLog = Join-Path $evidenceRoot "pac_import_g4_completion_$timestamp.txt"
Invoke-Pac -Command "pac solution import --environment $EnvironmentName --path `"$packageZip`" --publish-changes" -LogPath $importLog | Out-Null

$publishLog = Join-Path $evidenceRoot "pac_copilot_publish_g4_completion_$timestamp.txt"
$publish = Invoke-Pac -Command "pac copilot publish --environment $EnvironmentName --bot $BotId" -LogPath $publishLog -AllowFailure

$listLog = Join-Path $evidenceRoot "pac_copilot_list_g4_completion_$timestamp.txt"
Invoke-Pac -Command "pac copilot list --environment $EnvironmentName" -LogPath $listLog | Out-Null

$extractPath = Join-Path $evidenceRoot "g4_assistente_pmo_export_complete_$timestamp.yaml"
$extractLog = Join-Path $evidenceRoot "pac_copilot_extract_g4_completion_$timestamp.txt"
Invoke-Pac -Command "pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFile `"$extractPath`" --overwrite" -LogPath $extractLog | Out-Null

$resultPath = Join-Path $evidenceRoot "g4_completion_result_$timestamp.json"
Save-Json -Data ([pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    status = if ($publish.ExitCode -eq 0) { "PASS" } else { "PASS_WITH_PUBLISH_WARNING" }
    environmentName = $EnvironmentName
    botId = $BotId
    botSchema = $BotSchema
    importedPackage = $packageZip
    importLog = $importLog
    publishExitCode = $publish.ExitCode
    publishLog = $publishLog
    listLog = $listLog
    extractPath = $extractPath
    extractLog = $extractLog
    manifest = $manifestPath
    flowEvidence = $flowEvidence
}) -Path $resultPath

Write-Host "G4 completion result: $resultPath"
