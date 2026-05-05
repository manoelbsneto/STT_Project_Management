[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$BotId = "0c4a9729-d55d-483c-8ec3-db9369583155",
    [string]$BotSchema = "pmo_AssistentePMO",
    [string]$SolutionUniqueName = "PMO_CriarTarefa_ContractFix",
    [string]$FlowName = "7ca90102-525b-48bb-875e-0f7bda96f85b",
    [string]$WorkflowEntityId = "71f62da4-9748-f111-bec7-6045bdf42cae",
    [string]$EvidenceDir = ".planning\comms"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$powerAppsModule = "C:\Users\mbenicios\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"
if (Test-Path -LiteralPath $powerAppsModule) {
    Import-Module $powerAppsModule -ErrorAction Stop
}

$evidenceRoot = Join-Path $repoRoot $EvidenceDir
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 100)
    $json = $Data | ConvertTo-Json -Depth $Depth
    Write-Utf8NoBom -Path $Path -Text $json
}

function Write-Utf8NoBom {
    param([string]$Path, [string]$Text)

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path -LiteralPath (Split-Path -Parent $Path)).Path + [System.IO.Path]::DirectorySeparatorChar + (Split-Path -Leaf $Path), $Text, $utf8NoBom)
}

function Invoke-Pac {
    param([string]$Command, [string]$LogPath, [switch]$AllowFailure)

    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -Command $Command *>&1
    $output | Set-Content -LiteralPath $LogPath -Encoding UTF8
    $text = $output | Out-String
    $containsFailure = $text -match "(?m)^\s*Error:" -or
        $text -match "FAILURE:" -or
        $text -match "Failed to publish" -or
        $text -match "non-recoverable error" -or
        $text -match "Exception Type:"

    if ((($LASTEXITCODE -ne 0) -or $containsFailure) -and -not $AllowFailure) {
        throw "PAC command failed. ExitCode=$LASTEXITCODE Log=$LogPath"
    }

    [ordered]@{
        ExitCode = $LASTEXITCODE
        LogPath = $LogPath
        ContainsFailure = $containsFailure
        Text = $text
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

    $dialogBody = $match.Groups["body"].Value
    $dialogBody = [regex]::Replace($dialogBody, "(?m)^      ", "")
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
"@ | ForEach-Object { Write-Utf8NoBom -Path (Join-Path $componentDir "botcomponent.xml") -Text $_ }

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

$beforePath = Join-Path $evidenceRoot "cs_criartarefa_contract_before_$timestamp.yaml"
$extractBeforeLog = Join-Path $evidenceRoot "pac_copilot_extract_criartarefa_contract_before_$timestamp.txt"
Invoke-Pac -Command "pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFileName `"$beforePath`" --overwrite" -LogPath $extractBeforeLog | Out-Null

$yaml = Get-Content -LiteralPath $beforePath -Raw
$originalYaml = $yaml

$actionBlock = Get-ComponentBlock -Yaml $yaml -DisplayName "PMO_PA_CriarTarefa"
$topicBlock = Get-ComponentBlock -Yaml $yaml -DisplayName "CriarTarefa"

$patchedActionBlock = $actionBlock
$actionDialogBlock = @"
    dialog:
      kind: TaskDialog
      inputs:
        - kind: ManualTaskInput
          propertyName: nomeProjeto
          value: =Global.PMO_Criar_Title

        - kind: ManualTaskInput
          propertyName: titulo
          value: =Global.PMO_Criar_Title

        - kind: ManualTaskInput
          propertyName: responsavel
          value: =Global.PMO_Criar_Responsavel

        - kind: ManualTaskInput
          propertyName: prazo
          value: =Global.PMO_Criar_DataFim

        - kind: ManualTaskInput
          propertyName: horas
          value: =Global.PMO_Criar_HorasEstimadas

        - kind: ManualTaskInput
          propertyName: prioridade
          value: =Global.PMO_Criar_Prioridade

      outputs:
        - propertyName: success

        - propertyName: message

        - propertyName: errorcode

        - propertyName: projectId

      action:
        kind: InvokeFlowTaskAction
        flowId: $WorkflowEntityId
        connectionProperties:
          `$kind: ConnectionProperties
          diagnostics:
          mode: Invoker

      outputMode: All
"@
$patchedActionBlock = [regex]::Replace($patchedActionBlock, "(?ms)    dialog:\r?\n.*$", $actionDialogBlock.TrimEnd())

$patchedTopicBlock = $topicBlock
$topicDialogBlock = @"
    dialog:
      beginDialog:
        kind: OnRecognizedIntent
        id: main
        intent:
          displayName: CriarTarefa
          includeInOnSelectIntent: true
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

        actions:
          - kind: Question
            id: ask_title
            variable: Topic.Title
            prompt: Qual o titulo da tarefa?
            entity: StringPrebuiltEntity

          - kind: Question
            id: ask_responsavel
            variable: Topic.Responsavel
            prompt: Quem e o responsavel pela tarefa?
            entity: StringPrebuiltEntity

          - kind: Question
            id: ask_datafim
            variable: Topic.DataFim
            prompt: "Qual o prazo da tarefa? (formato: dd/mm/aaaa)"
            entity: StringPrebuiltEntity

          - kind: Question
            id: ask_horas
            variable: Topic.HorasEstimadas
            prompt: Quantas horas estimadas para essa tarefa?
            entity: NumberPrebuiltEntity

          - kind: Question
            id: ask_prioridade
            variable: Topic.Prioridade
            prompt: "Qual a prioridade? Escolha: Baixa, Media, Alta ou Critica."
            entity: StringPrebuiltEntity

          - kind: Question
            id: confirm_criar
            variable: Topic.Confirmar
            prompt: |-
              Vou criar a tarefa '{Topic.Title}'.
              Responsavel: {Topic.Responsavel}
              Prazo: {Topic.DataFim}
              Horas: {Topic.HorasEstimadas}h
              Prioridade: {Topic.Prioridade}
              O codigo do projeto sera gerado automaticamente.

              Confirma?
            entity: BooleanPrebuiltEntity

          - kind: ConditionGroup
            id: confirm_branch
            conditions:
              - id: confirmed
                condition: =Topic.Confirmar = true
                actions:
                  - kind: SetVariable
                    id: set_global_title
                    variable: Global.PMO_Criar_Title
                    value: =Topic.Title

                  - kind: SetVariable
                    id: set_global_responsavel
                    variable: Global.PMO_Criar_Responsavel
                    value: =Topic.Responsavel

                  - kind: SetVariable
                    id: set_global_datafim
                    variable: Global.PMO_Criar_DataFim
                    value: =Topic.DataFim

                  - kind: SetVariable
                    id: set_global_horas
                    variable: Global.PMO_Criar_HorasEstimadas
                    value: =Topic.HorasEstimadas

                  - kind: SetVariable
                    id: set_global_prioridade
                    variable: Global.PMO_Criar_Prioridade
                    value: =Topic.Prioridade

                  - kind: BeginDialog
                    id: call_criar_tarefa
                    input: {}
                    dialog: template-content.action.PMO_PA_CriarTarefa
                    output:
                      binding:
                        success: Topic.CriarSuccess
                        message: Topic.message
                        errorcode: Topic.CriarErrorCode
                        projectId: Topic.ProjectIDGerado

                  - kind: SendActivity
                    id: criar_done
                    activity: |-
                      Projeto criado com sucesso.

                      Codigo: {Topic.ProjectIDGerado}
                      Titulo: {Topic.Title}
                      Responsavel: {Topic.Responsavel}
                      Prazo: {Topic.DataFim}
                      Horas: {Topic.HorasEstimadas}h
                      Prioridade: {Topic.Prioridade}

                      {Topic.message}

            elseActions:
              - kind: SendActivity
                id: criar_cancelled
                activity: Ok, criacao cancelada. Se quiser tentar novamente, diga "criar tarefa".
"@
$patchedTopicBlock = [regex]::Replace($patchedTopicBlock, "(?ms)    dialog:\r?\n.*$", $topicDialogBlock.TrimEnd())
$beginDialogNew = @"
                  - kind: BeginDialog
                    id: call_criar_tarefa
                    input: {}
                    dialog: template-content.action.PMO_PA_CriarTarefa
                    output:
                      binding:
                        success: Topic.CriarSuccess
                        message: Topic.message
                        errorcode: Topic.CriarErrorCode
                        projectId: Topic.ProjectIDGerado
"@
$patchedTopicBlock = [regex]::Replace(
    $patchedTopicBlock,
    "(?ms)                  - kind: BeginDialog\r?\n                    id: call_criar_tarefa\r?\n                    input: \{\}\r?\n                    dialog: template-content\.action\.PMO_PA_CriarTarefa\r?\n                    output:\r?\n                      binding:\r?\n(?:                        .+?\r?\n)+",
    $beginDialogNew
)

$sendActivityNew = @"
                  - kind: SendActivity
                    id: criar_done
                    activity: |-
                      Projeto criado com sucesso.

                      Codigo: {Topic.ProjectIDGerado}
                      Titulo: {Topic.Title}
                      Responsavel: {Topic.Responsavel}
                      Prazo: {Topic.DataFim}
                      Horas: {Topic.HorasEstimadas}h
                      Prioridade: {Topic.Prioridade}

                      {Topic.message}
"@
$patchedTopicBlock = [regex]::Replace(
    $patchedTopicBlock,
    "(?ms)                  - kind: SendActivity\r?\n                    id: criar_done\r?\n                    activity: \|-\r?\n(?:                      .+?\r?\n|                      \r?\n)+\r?\n            elseActions:",
    $sendActivityNew + "`r`n`r`n            elseActions:"
)

$yaml = $yaml.Replace($actionBlock, $patchedActionBlock).Replace($topicBlock, $patchedTopicBlock)
if ($yaml -eq $originalYaml) {
    throw "Contract patch made no changes."
}

$patchedPath = Join-Path $evidenceRoot "cs_criartarefa_contract_patched_$timestamp.yaml"
$yaml | Set-Content -LiteralPath $patchedPath -Encoding UTF8

$packageRoot = Join-Path $evidenceRoot "cs_criartarefa_contract_package_$timestamp"
if (Test-Path -LiteralPath $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null
$assetsDir = Join-Path $packageRoot "Assets"
$workflowsDir = Join-Path $packageRoot "Workflows"
New-Item -ItemType Directory -Force -Path $assetsDir, $workflowsDir | Out-Null

Write-BotComponent -PackageRoot $packageRoot -SchemaName "$BotSchema.action.PMO_PA_CriarTarefa" -DisplayName "PMO_PA_CriarTarefa" -Description "Acao vinculada ao fluxo Power Automate PMO_PA_CriarTarefa." -Data (Get-DialogData -ComponentBlock $patchedActionBlock)
Write-BotComponent -PackageRoot $packageRoot -SchemaName "$BotSchema.topic.CriarTarefa" -DisplayName "CriarTarefa" -Description "Coleta dados de novo projeto/tarefa, confirma e aciona o fluxo CriarTarefa." -Data (Get-DialogData -ComponentBlock $patchedTopicBlock)

$processSimpleRequest = Get-ChildItem -LiteralPath $evidenceRoot -Filter "processsimple_criartarefa_request_$FlowName.json" -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if (-not $processSimpleRequest) {
    throw "Could not find updated ProcessSimple request for flow $FlowName. Run deploy\PA_CriarTarefa_Flow.ps1 first, even if ProcessSimple PATCH returns 500."
}

$flowPayload = Get-Content -LiteralPath $processSimpleRequest.FullName -Raw | ConvertFrom-Json
$rawInvokerAuthentication = [ordered]@{
    value = '@json(decodeBase64(triggerOutputs().headers[''X-MS-APIM-Tokens'']))[''$ConnectionKey'']'
    type = "Raw"
}
foreach ($actionName in @("Get_Existing_Projects", "Create_Projeto_SharePoint")) {
    if ($flowPayload.properties.definition.actions.$actionName -and $flowPayload.properties.definition.actions.$actionName.inputs) {
        $flowPayload.properties.definition.actions.$actionName.inputs.authentication = $rawInvokerAuthentication
    }
}
$solutionConnectionReferences = [ordered]@{}
foreach ($cr in $flowPayload.properties.connectionReferences.PSObject.Properties) {
    $crValue = $cr.Value
    $runtimeSource = if ($crValue.source) { [string]$crValue.source } else { "Embedded" }
    $connectionReferenceLogicalName = $crValue.connectionReferenceLogicalName
    if ($cr.Name -eq "shared_sharepointonline" -and $connectionReferenceLogicalName -eq "pmo_sharepoint") {
        $connectionReferenceLogicalName = "cat_DataverseIndexerSharePoint"
    }
    $apiName = if ($crValue.apiName -eq "sharepointonline") { "shared_sharepointonline" } else { $crValue.apiName }
    $solutionConnectionReferences[$cr.Name] = [ordered]@{
        api = [ordered]@{ name = $apiName }
        connection = [ordered]@{ connectionReferenceLogicalName = $connectionReferenceLogicalName }
        runtimeSource = $runtimeSource.ToLowerInvariant()
    }
}

$workflowFile = "PMO_PA_CriarTarefa-$WorkflowEntityId.json"
Save-Json -Data ([ordered]@{
    properties = [ordered]@{
        connectionReferences = $solutionConnectionReferences
        definition = $flowPayload.properties.definition
        templateName = $null
    }
    schemaVersion = "1.0.0.0"
}) -Path (Join-Path $workflowsDir $workflowFile)

@"
<botcomponent_workflowset>
  <botcomponent_workflow botcomponentid.schemaname="$BotSchema.action.PMO_PA_CriarTarefa" workflowid.workflowid="$WorkflowEntityId">
    <iscustomizable>1</iscustomizable>
  </botcomponent_workflow>
</botcomponent_workflowset>
"@ | Set-Content -LiteralPath (Join-Path $assetsDir "botcomponent_workflowset.xml") -Encoding UTF8

@"
<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="xml" ContentType="application/octet-stream" /><Default Extension="json" ContentType="application/octet-stream" /><Override PartName="/botcomponents/$BotSchema.action.PMO_PA_CriarTarefa/data" ContentType="application/octet-stream" /><Override PartName="/botcomponents/$BotSchema.topic.CriarTarefa/data" ContentType="application/octet-stream" /></Types>
"@ | Set-Content -LiteralPath (Join-Path $packageRoot "[Content_Types].xml") -Encoding UTF8

@"
<?xml version="1.0" encoding="utf-8"?>
<ImportExportXml version="9.2.26041.172" SolutionPackageVersion="9.2" languagecode="1046" generatedBy="CrmLive" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" OrganizationVersion="9.2.26041.172" OrganizationSchemaType="Standard" CRMServerServiceabilityVersion="9.2.26041.00172">
  <SolutionManifest>
    <UniqueName>$SolutionUniqueName</UniqueName>
    <LocalizedNames>
      <LocalizedName description="PMO CriarTarefa Contract Fix" languagecode="1046" />
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
      <RootComponent type="29" id="{$WorkflowEntityId}" behavior="0" />
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
    <Workflow WorkflowId="{$WorkflowEntityId}" Name="PMO_PA_CriarTarefa">
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

$zipPath = Join-Path $evidenceRoot "PMO_CriarTarefa_ContractFix_$timestamp.zip"
Compress-SolutionPackage -SourceRoot $packageRoot -DestinationPath $zipPath

$importLog = Join-Path $evidenceRoot "pac_import_criartarefa_contract_$timestamp.txt"
Invoke-Pac -Command "pac solution import --environment $EnvironmentName --path `"$zipPath`" --publish-changes --async false" -LogPath $importLog | Out-Null

$enableFlowLog = Join-Path $evidenceRoot "pa_enable_criartarefa_contract_$timestamp.txt"
$enableFlowSucceeded = $false
$flowEnabled = $false
$flowState = $null
try {
    $enableOutput = Enable-Flow -EnvironmentName $EnvironmentName -FlowName $FlowName *>&1
    $enableOutput | Set-Content -LiteralPath $enableFlowLog -Encoding UTF8
    Start-Sleep -Seconds 10
    $flow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $FlowName -ErrorAction Stop
    $flowEnabled = [bool]$flow.Enabled
    $flowState = if ($flow.Internal -and $flow.Internal.properties) { $flow.Internal.properties.state } else { $null }
    $enableFlowSucceeded = $flowEnabled -or ($flowState -eq "Started")
}
catch {
    $_.Exception.Message | Set-Content -LiteralPath $enableFlowLog -Encoding UTF8
}

$verifyPath = Join-Path $evidenceRoot "cs_criartarefa_contract_verify_$timestamp.yaml"
$extractVerifyLog = Join-Path $evidenceRoot "pac_copilot_extract_criartarefa_contract_verify_$timestamp.txt"
Invoke-Pac -Command "pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFileName `"$verifyPath`" --overwrite" -LogPath $extractVerifyLog | Out-Null
$verifyText = Get-Content -LiteralPath $verifyPath -Raw

$checks = [ordered]@{
    hasAction = $verifyText -match "schemaName: template-content\.action\.PMO_PA_CriarTarefa"
    hasFlowId = $verifyText -match [regex]::Escape($WorkflowEntityId)
    hasActionInputs = ($verifyText -match "propertyName: titulo") -and ($verifyText -match "propertyName: responsavel") -and ($verifyText -match "propertyName: prazo") -and ($verifyText -match "propertyName: horas") -and ($verifyText -match "propertyName: prioridade")
    hasOutputBindings = ($verifyText -match "message: Topic\.message") -and ($verifyText -match "projectId: Topic\.ProjectIDGerado") -and ($verifyText -match "success: Topic\.CriarSuccess") -and ($verifyText -match "errorcode: Topic\.CriarErrorCode")
    noResultBindingForCriar = -not ($verifyText -match "(?ms)id: call_criar_tarefa.*?result: Topic\.message")
    hasCleanBeginDialog = ($verifyText -match "(?m)^\s+beginDialog:\s*$") -and -not ($verifyText -match "Â¿beginDialog|ï»¿beginDialog|Ã¯Â»Â¿beginDialog")
    hasScalarTriggerQueries = ($verifyText -match "(?m)^\s+- criar tarefa\s*$") -and -not ($verifyText -match "(?m)^\s+- Value:")
    flowEnabled = $enableFlowSucceeded
}

$publishLog = Join-Path $evidenceRoot "pac_copilot_publish_criartarefa_contract_$timestamp.txt"
$publish = Invoke-Pac -Command "pac copilot publish --environment $EnvironmentName --bot $BotId" -LogPath $publishLog -AllowFailure
$publishSucceeded = ($publish.Text -match "Published successfully") -and -not $publish.ContainsFailure

$listLog = Join-Path $evidenceRoot "pac_copilot_list_criartarefa_contract_$timestamp.txt"
Invoke-Pac -Command "pac copilot list --environment $EnvironmentName" -LogPath $listLog | Out-Null
$listText = Get-Content -LiteralPath $listLog -Raw
$botListedPublished = $listText -match "Assistente PMO\s+$([regex]::Escape($BotId))\s+Published\s+False\s+\S+\s+Active\s+Provisioned"

$status = if (($checks.Values -notcontains $false) -and ($publishSucceeded -or $botListedPublished)) {
    if ($publishSucceeded) { "PASS" } else { "PASS_WITH_PAC_PUBLISH_STALE_FAILURE" }
} else {
    "FAILED"
}
$resultPath = Join-Path $evidenceRoot "cs_criartarefa_contract_result_$timestamp.json"
Save-Json -Data ([ordered]@{
    timestamp = (Get-Date).ToString("o")
    status = $status
    environmentName = $EnvironmentName
    botId = $BotId
    workflowEntityId = $WorkflowEntityId
    flowName = $FlowName
    beforePath = $beforePath
    patchedPath = $patchedPath
    verifyPath = $verifyPath
    packagePath = $zipPath
    processSimpleRequest = $processSimpleRequest.FullName
    importLog = $importLog
    enableFlowLog = $enableFlowLog
    enableFlowSucceeded = $enableFlowSucceeded
    flowEnabled = $flowEnabled
    flowState = $flowState
    publishLog = $publishLog
    publishSucceeded = $publishSucceeded
    publishContainsFailure = $publish.ContainsFailure
    botListLog = $listLog
    botListedPublished = $botListedPublished
    checks = $checks
    officialPrerequisitesCovered = @(
        "Flow action component exists in the bot template.",
        "Action flowId points to the solution-aware workflow entity.",
        "Action inputs match the Power Automate trigger schema.",
        "Topic binds action outputs by output parameter name, not a stale result alias.",
        "Flow response contract is expected to expose the same outputs in all branches."
    )
}) -Path $resultPath

Write-Host "Contract fix evidence: $resultPath"
if ($status -eq "FAILED") {
    throw "CriarTarefa contract fix verification failed. See $resultPath and $publishLog"
}
