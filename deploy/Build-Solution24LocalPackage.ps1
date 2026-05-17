[CmdletBinding()]
param(
    [string]$SourceUnpacked = ".planning/comms/solution_3_0_criartarefa_inline_parser_20260513/unpacked",
    [string]$WorkingDir = ".planning/comms/solution_3_1_listartarefas_content_safe_20260513/unpacked",
    [string]$OutputZip = "Solution/PMO_v11_Tarefas_3_1_LISTARTAREFAS_CONTENT_SAFE_FIX.zip",
    [string]$PackageVersion = "3.1"
)

$ErrorActionPreference = "Stop"

$projectListId = "0271c9e8-c184-4b91-99f9-5b71f9b08826"
$taskListId = "36d78ca1-1f60-4dd3-a4d5-5c94b89969e9"
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
$criarProjetoId = "3104124d-364a-f111-bec7-7ced8d955c6c"
$criarProjetoIdFile = "3104124D-364A-F111-BEC7-7CED8D955C6C"
$criarTarefaId = "0a5d2a41-24c0-4d5e-9f6d-000000000241"
$criarTarefaIdFile = "0A5D2A41-24C0-4D5E-9F6D-000000000241"
$batchId = "0a5d2a42-24c0-4d5e-9f6d-000000000241"
$batchIdFile = "0A5D2A42-24C0-4D5E-9F6D-000000000241"

function Write-TextFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $encoding)
}

function New-DataverseSolutionZip {
    param(
        [string]$SourceDir,
        [string]$DestinationPath
    )

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $resolvedSource = (Resolve-Path -LiteralPath $SourceDir).Path
    $sourcePrefix = $resolvedSource.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Force
    }

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

function New-FlowBase {
    param(
        [hashtable]$TriggerProperties,
        [hashtable]$Actions
    )

    [ordered]@{
        properties = [ordered]@{
            connectionReferences = [ordered]@{
                shared_sharepointonline = [ordered]@{
                    runtimeSource = "embedded"
                    connection = [ordered]@{
                        connectionReferenceLogicalName = "pmo_sharedsharepointonline_6e373"
                    }
                    api = [ordered]@{
                        name = "shared_sharepointonline"
                    }
                }
            }
            definition = [ordered]@{
                '$schema' = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
                contentVersion = "1.0.0.0"
                parameters = [ordered]@{
                    '$connections' = [ordered]@{ defaultValue = [ordered]@{}; type = "Object" }
                    '$authentication' = [ordered]@{ defaultValue = [ordered]@{}; type = "SecureObject" }
                }
                triggers = [ordered]@{
                    manual = [ordered]@{
                        type = "Request"
                        kind = "Skills"
                        inputs = [ordered]@{
                            schema = [ordered]@{
                                type = "object"
                                properties = $TriggerProperties
                                required = @($TriggerProperties.Keys)
                            }
                        }
                    }
                }
                actions = $Actions
                outputs = [ordered]@{}
            }
            templateName = ""
        }
        schemaVersion = "1.0.0.0"
    }
}

function New-TextInput {
    param([string]$Description, [string]$Title)
    [ordered]@{
        description = $Description
        title = $Title
        type = "string"
        'x-ms-content-hint' = "TEXT"
        'x-ms-dynamically-added' = $true
    }
}

function New-NumberInput {
    param([string]$Description, [string]$Title)
    [ordered]@{
        description = $Description
        title = $Title
        type = "number"
        'x-ms-content-hint' = "NUMBER"
        'x-ms-dynamically-added' = $true
    }
}

function New-GetItemsAction {
    param([string]$ListId, [string]$Filter, [int]$Top = 1)
    [ordered]@{
        type = "OpenApiConnection"
        inputs = [ordered]@{
            host = [ordered]@{
                connectionName = "shared_sharepointonline"
                operationId = "GetItems"
                apiId = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
            }
            parameters = [ordered]@{
                dataset = $siteUrl
                table = $ListId
                '$filter' = $Filter
                '$top' = $Top
            }
            authentication = "@parameters('`$authentication')"
        }
    }
}

function New-PostItemAction {
    param([string]$ListId, [hashtable]$Parameters)
    $allParams = [ordered]@{ dataset = $siteUrl; table = $ListId }
    foreach ($key in $Parameters.Keys) {
        $allParams[$key] = $Parameters[$key]
    }
    [ordered]@{
        type = "OpenApiConnection"
        inputs = [ordered]@{
            host = [ordered]@{
                connectionName = "shared_sharepointonline"
                operationId = "PostItem"
                apiId = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
            }
            parameters = $allParams
            authentication = "@parameters('`$authentication')"
        }
    }
}

function New-SetResponse {
    param([string]$Name, [string]$Value)
    [ordered]@{
        type = "SetVariable"
        inputs = [ordered]@{ name = $Name; value = $Value }
    }
}

function New-ResponseAction {
    [ordered]@{
        type = "Response"
        kind = "VirtualAgent"
        inputs = [ordered]@{
            statusCode = 200
            body = [ordered]@{
                message = "@variables('responseMessage')"
            }
            schema = [ordered]@{
                type = "object"
                properties = [ordered]@{
                    message = [ordered]@{ title = "message"; type = "string"; 'x-ms-content-hint' = "TEXT" }
                }
            }
        }
    }
}

function Set-ListarTarefasContentSafeOutput {
    param([string]$SolutionDir)

    $workflowPath = Get-ChildItem -LiteralPath (Join-Path $SolutionDir "Workflows") -Filter "PMO_PA_ListarTarefas*.json" |
        Select-Object -First 1 -ExpandProperty FullName
    if (-not $workflowPath) {
        throw "PMO_PA_ListarTarefas workflow not found under $SolutionDir"
    }

    $workflow = Get-Content -LiteralPath $workflowPath -Raw | ConvertFrom-Json
    $branchActions = $workflow.properties.definition.actions.Condition_Projeto_Encontrado.actions.Check_Tarefas_Exist.else.actions
    if (-not $branchActions.Select_Tarefas -or -not $branchActions.Compose_Lista) {
        throw "PMO_PA_ListarTarefas expected Select_Tarefas/Compose_Lista actions were not found."
    }

    $safeTitle = "replace(replace(replace(replace(replace(replace(replace(replace(replace(trim(coalesce(string(item()?['Title']), '-')), '\r', ' '), '\n', ' '), '*', ''), '#', ''), '[', '('), ']', ')'), '<', '('), '>', ')'), '|', '/')"
    $safeResponsible = "replace(replace(replace(replace(trim(coalesce(string(item()?['Responsavel']), '-')), '\r', ' '), '\n', ' '), '*', ''), '|', '/')"
    $safeProjectName = "replace(replace(replace(replace(replace(replace(replace(replace(replace(trim(coalesce(body('Get_Projeto')?['value']?[0]?['NomeProjeto'], outputs('Compose_ProjectInput'))), '\r', ' '), '\n', ' '), '*', ''), '#', ''), '[', '('), ']', ')'), '<', '('), '>', ')'), '|', '/')"

    $branchActions.Select_Tarefas.inputs.select = "@concat('ID ', string(item()?['ID']), ' | Titulo: ', $safeTitle, ' | Status ', coalesce(item()?['Status']?['Value'], item()?['Status'], '-'), ' | Prioridade ', coalesce(item()?['Prioridade']?['Value'], item()?['Prioridade'], '-'), ' | Responsavel ', $safeResponsible, ' | Fim ', coalesce(string(item()?['DataFim']), '-'), ' | Horas ', coalesce(string(item()?['HorasEstimadas']), '0'), '/', coalesce(string(item()?['HorasRealizadas']), '0'))"
    $branchActions.Compose_Lista.inputs = "@concat('Lista de tarefas do projeto ', $safeProjectName, ' (', body('Get_Projeto')?['value']?[0]?['ProjectID'], ') - Total: ', string(outputs('Count_Total')), ' | Concluidas: ', string(outputs('Count_Concluidas')), '\n', join(body('Select_Tarefas'), '\n'))"
    $workflow.properties.definition.actions.Condition_Projeto_Encontrado.actions.Check_Tarefas_Exist.actions.Respond_Empty.inputs.body.result = "@{concat('Nenhuma tarefa encontrada para o projeto ', $safeProjectName, '. Use o comando criar tarefa para adicionar tarefas a este projeto.')}"

    Write-TextFile -Path $workflowPath -Content ($workflow | ConvertTo-Json -Depth 80)
}

$resolvedSource = (Resolve-Path -LiteralPath $SourceUnpacked).Path
$resolvedWorkingParent = Split-Path -Parent (Join-Path (Get-Location) $WorkingDir)
New-Item -ItemType Directory -Force -Path $resolvedWorkingParent | Out-Null
if (Test-Path -LiteralPath $WorkingDir) {
    $resolvedWorking = (Resolve-Path -LiteralPath $WorkingDir).Path
    $repoRoot = (Resolve-Path ".").Path
    if (-not $resolvedWorking.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean working dir outside repo: $resolvedWorking"
    }
    Remove-Item -LiteralPath $resolvedWorking -Recurse -Force
}
Copy-Item -LiteralPath $resolvedSource -Destination $WorkingDir -Recurse

$solutionXmlPath = Join-Path $WorkingDir "solution.xml"
$customizationsPath = Join-Path $WorkingDir "customizations.xml"
$contentTypesPath = Join-Path $WorkingDir "[Content_Types].xml"
$workflowSetPath = Join-Path $WorkingDir "Assets/botcomponent_workflowset.xml"

$solutionXml = Get-Content -LiteralPath $solutionXmlPath -Raw
$solutionXml = $solutionXml -replace "<Version>[0-9]+\.[0-9]+</Version>", "<Version>$PackageVersion</Version>"
if ($solutionXml -notmatch [regex]::Escape($criarTarefaId)) {
    $solutionXml = $solutionXml -replace "</RootComponents>", "      <RootComponent type=`"29`" id=`"{$criarTarefaId}`" behavior=`"0`" />`r`n      <RootComponent type=`"29`" id=`"{$batchId}`" behavior=`"0`" />`r`n    </RootComponents>"
}
Write-TextFile -Path $solutionXmlPath -Content $solutionXml

$oldProjectFlowPath = Join-Path $WorkingDir "Workflows/PMO_PA_CriarTarefa_V3-$criarProjetoIdFile.json"
$newProjectFlowPath = Join-Path $WorkingDir "Workflows/PMO_PA_CriarProjeto-$criarProjetoIdFile.json"
if (Test-Path -LiteralPath $oldProjectFlowPath) {
    Move-Item -LiteralPath $oldProjectFlowPath -Destination $newProjectFlowPath -Force
}

$customizations = Get-Content -LiteralPath $customizationsPath -Raw
$customizations = $customizations -replace 'Name="PMO_PA_CriarTarefa_V3"', 'Name="PMO_PA_CriarProjeto"'
$customizations = $customizations -replace '/Workflows/PMO_PA_CriarTarefa_V3-3104124D-364A-F111-BEC7-7CED8D955C6C.json', '/Workflows/PMO_PA_CriarProjeto-3104124D-364A-F111-BEC7-7CED8D955C6C.json'
$customizations = $customizations -replace 'description="PMO_PA_CriarTarefa_V3"', 'description="PMO_PA_CriarProjeto"'

$newWorkflowXml = @"
    <Workflow WorkflowId="{$criarTarefaId}" Name="PMO_PA_CriarTarefa">
      <JsonFileName>/Workflows/PMO_PA_CriarTarefa-$criarTarefaIdFile.json</JsonFileName>
      <Type>1</Type><Subprocess>0</Subprocess><Category>5</Category><Mode>0</Mode>
      <TriggerOnCreate>0</TriggerOnCreate><TriggerOnUpdateAttributeList /><TriggerOnDelete>0</TriggerOnDelete><AsyncAutodelete>0</AsyncAutodelete>
      <SyncWorkflowLogOnFailure>0</SyncWorkflowLogOnFailure><StateCode>1</StateCode><StatusCode>2</StatusCode><RunAs>1</RunAs><IsTransacted>1</IsTransacted>
      <IntroducedVersion>1.0</IntroducedVersion><IsCustomizable>1</IsCustomizable><BusinessProcessType>0</BusinessProcessType><PrimaryEntity>none</PrimaryEntity>
      <LocalizedNames><LocalizedName languagecode="3082" description="PMO_PA_CriarTarefa" /></LocalizedNames>
    </Workflow>
    <Workflow WorkflowId="{$batchId}" Name="PMO_PA_Gerar_Multiplos_Projetos">
      <JsonFileName>/Workflows/PMO_PA_Gerar_Multiplos_Projetos-$batchIdFile.json</JsonFileName>
      <Type>1</Type><Subprocess>0</Subprocess><Category>5</Category><Mode>0</Mode>
      <TriggerOnCreate>0</TriggerOnCreate><TriggerOnUpdateAttributeList /><TriggerOnDelete>0</TriggerOnDelete><AsyncAutodelete>0</AsyncAutodelete>
      <SyncWorkflowLogOnFailure>0</SyncWorkflowLogOnFailure><StateCode>1</StateCode><StatusCode>2</StatusCode><RunAs>1</RunAs><IsTransacted>1</IsTransacted>
      <IntroducedVersion>1.0</IntroducedVersion><IsCustomizable>1</IsCustomizable><BusinessProcessType>0</BusinessProcessType><PrimaryEntity>none</PrimaryEntity>
      <LocalizedNames><LocalizedName languagecode="3082" description="PMO_PA_Gerar_Multiplos_Projetos" /></LocalizedNames>
    </Workflow>
"@
if ($customizations -notmatch 'Name="PMO_PA_CriarTarefa"') {
    $customizations = $customizations -replace "</Workflows>", "$newWorkflowXml`r`n  </Workflows>"
}
Write-TextFile -Path $customizationsPath -Content $customizations

$taskInputs = [ordered]@{
    text = New-TextInput "nomeProjeto" "Texto"
    text_1 = New-TextInput "titulo" "Texto 1"
    text_2 = New-TextInput "responsavel" "Texto 2"
    text_3 = New-TextInput "prazo" "Texto 3"
    number = New-NumberInput "horas" "Numero"
    text_4 = New-TextInput "prioridade" "Texto 4"
}

$validBrazilianDays = "'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31'"
$validBrazilianMonths = "'01','02','03','04','05','06','07','08','09','10','11','12'"
$brazilianDateExpression = "@if(and(equals(length(split(outputs('Compose_PrazoRaw'), '/')), 3), equals(length(first(split(outputs('Compose_PrazoRaw'), '/'))), 2), equals(length(first(skip(split(outputs('Compose_PrazoRaw'), '/'), 1))), 2), equals(length(last(split(outputs('Compose_PrazoRaw'), '/'))), 4), contains(createArray($validBrazilianDays), first(split(outputs('Compose_PrazoRaw'), '/'))), contains(createArray($validBrazilianMonths), first(skip(split(outputs('Compose_PrazoRaw'), '/'), 1)))), concat(last(split(outputs('Compose_PrazoRaw'), '/')), '-', first(skip(split(outputs('Compose_PrazoRaw'), '/'), 1)), '-', first(split(outputs('Compose_PrazoRaw'), '/'))), 'INVALID_BR_DATE')"
$projectBrazilianDateExpression = $brazilianDateExpression -replace "Compose_PrazoRaw", "Compose_DataAlvoRaw"

$projectInputs = [ordered]@{
    text = New-TextInput "nomeProjeto" "Texto"
    text_1 = New-TextInput "titulo" "Texto 1"
    text_2 = New-TextInput "pm" "Texto 2"
    text_3 = New-TextInput "prazo" "Texto 3"
    number = New-NumberInput "horas" "Numero"
    text_4 = New-TextInput "prioridade" "Texto 4"
}

$createProjectAction = New-PostItemAction -ListId $projectListId -Parameters @{
    "item/Title" = "@outputs('Compose_NomeProjeto')"
    "item/ProjectID" = "@outputs('Compose_ProjectID')"
    "item/NomeProjeto" = "@outputs('Compose_NomeProjeto')"
    "item/StatusRAG/Value" = "Verde"
    "item/Percentual" = 0
    "item/DataAlvo" = "@outputs('Compose_DataAlvo')"
    "item/Ativo" = $true
    "item/PM/Claims" = "@concat('i:0#.f|membership|', if(contains(coalesce(triggerBody()?['text_2'], ''), '@'), triggerBody()?['text_2'], 'mbenicios@minsait.com'))"
    "item/UltimaAtualizacao" = "@utcNow()"
    "item/Prioridade/Value" = "@outputs('Map_Prioridade')"
    "item/ResumoExecutivo" = "@concat('Projeto criado via Copilot Studio. Titulo: ', coalesce(triggerBody()?['text_1'], '-'), '. Horas estimadas: ', coalesce(string(triggerBody()?['number']), 'N/A'), 'h. Responsavel: ', coalesce(triggerBody()?['text_2'], '-'), '. Prazo: ', coalesce(triggerBody()?['text_3'], '-'), '.')"
    "item/Deleted" = $false
}

$projectDuplicateCondition = [ordered]@{
    type = "If"
    runAfter = [ordered]@{ Get_Duplicate_Projects = @("Succeeded") }
    expression = [ordered]@{ equals = @("@empty(outputs('Get_Duplicate_Projects')?['body/value'])", "@true") }
    actions = [ordered]@{
        Create_Projeto_SharePoint = $createProjectAction
        Set_Response_Success = (New-SetResponse -Name "responseMessage" -Value "Projeto criado com sucesso!")
    }
    else = [ordered]@{
        actions = [ordered]@{
            Response_Duplicate = (New-SetResponse -Name "responseMessage" -Value "Ja existe um projeto com o nome especificado. Nenhum item duplicado foi criado.")
        }
    }
}
$projectDuplicateCondition.actions.Set_Response_Success.runAfter = [ordered]@{ Create_Projeto_SharePoint = @("Succeeded") }

$projectActions = [ordered]@{
    Initialize_ResponseMessage = [ordered]@{
        type = "InitializeVariable"
        runAfter = [ordered]@{}
        inputs = [ordered]@{ variables = @([ordered]@{ name = "responseMessage"; type = "string" }) }
    }
    Compose_NomeProjeto = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Initialize_ResponseMessage = @("Succeeded") }; inputs = "@trim(coalesce(triggerBody()?['text'], triggerBody()?['text_1'], 'Sem nome'))" }
    Compose_DataAlvoRaw = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_NomeProjeto = @("Succeeded") }; inputs = "@trim(coalesce(string(triggerBody()?['text_3']), ''))" }
    Compose_DataAlvo = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_DataAlvoRaw = @("Succeeded") }; inputs = $projectBrazilianDateExpression }
    Map_Prioridade = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_DataAlvo = @("Succeeded") }; inputs = "@if(startsWith(toLower(trim(coalesce(triggerBody()?['text_4'], 'Media'))), 'cr'), 'Critica', if(startsWith(toLower(trim(coalesce(triggerBody()?['text_4'], 'Media'))), 'al'), 'Alta', if(startsWith(toLower(trim(coalesce(triggerBody()?['text_4'], 'Media'))), 'ba'), 'Baixa', 'Media')))" }
    Compose_ProjectID = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Map_Prioridade = @("Succeeded") }; inputs = "@concat('PRJ-', toUpper(substring(guid(), 0, 8)))" }
    Condition_DataAlvo_Valido = [ordered]@{
        type = "If"
        runAfter = [ordered]@{ Compose_ProjectID = @("Succeeded") }
        expression = [ordered]@{ not = [ordered]@{ equals = @("@outputs('Compose_DataAlvo')", "INVALID_BR_DATE") } }
        actions = [ordered]@{
            Get_Duplicate_Projects = New-GetItemsAction -ListId $projectListId -Filter "NomeProjeto eq '@{replace(outputs('Compose_NomeProjeto'), '''', '''''')}' and DataAlvo ge datetime'@{convertTimeZone(concat(outputs('Compose_DataAlvo'), 'T00:00:00'), 'Romance Standard Time', 'UTC', 'yyyy-MM-ddTHH:mm:ssZ')}' and DataAlvo lt datetime'@{convertTimeZone(concat(formatDateTime(addDays(outputs('Compose_DataAlvo'), 1), 'yyyy-MM-dd'), 'T00:00:00'), 'Romance Standard Time', 'UTC', 'yyyy-MM-ddTHH:mm:ssZ')}' and Deleted ne 1" -Top 1
            Condition_Duplicate_Projeto = $projectDuplicateCondition
        }
        else = [ordered]@{
            actions = [ordered]@{
                Set_Response_InvalidDate = (New-SetResponse -Name "responseMessage" -Value "Prazo invalido. Use formato brasileiro dd/MM/aaaa, ex: 30/06/2026. Codigo: INVALID_BR_DATE.")
            }
        }
    }
    Valores_retornados_para_o_Power_Virtual_Agents = New-ResponseAction
}
$projectActions.Valores_retornados_para_o_Power_Virtual_Agents.runAfter = [ordered]@{ Condition_DataAlvo_Valido = @("Succeeded") }
$projectFlow = New-FlowBase -TriggerProperties $projectInputs -Actions $projectActions
Write-TextFile -Path $newProjectFlowPath -Content ($projectFlow | ConvertTo-Json -Depth 70)

$conditionProjetoEncontrado = [ordered]@{
    type = "If"
    runAfter = [ordered]@{}
    expression = [ordered]@{ greater = @("@length(body('Get_Projeto')?['value'])", 0) }
    actions = [ordered]@{
        Create_Tarefa_SharePoint = New-PostItemAction -ListId $taskListId -Parameters @{
            "item/Title" = "@outputs('Compose_Titulo')"
            "item/ProjectID" = "@body('Get_Projeto')?['value']?[0]?['ProjectID']"
            "item/Responsavel" = "@coalesce(triggerBody()?['text_2'], '')"
            "item/DataFim" = "@outputs('Compose_DataFim')"
            "item/HorasEstimadas" = "@triggerBody()?['number']"
            "item/Status/Value" = "Pendente"
            "item/Prioridade/Value" = "@outputs('Map_Prioridade')"
            "item/Deleted" = $false
        }
        Set_Response_Success = (New-SetResponse -Name "responseMessage" -Value "@concat('Tarefa criada com sucesso. ID: ', string(body('Create_Tarefa_SharePoint')?['ID']), ' ProjectID: ', body('Get_Projeto')?['value']?[0]?['ProjectID'])")
    }
    else = [ordered]@{
        actions = [ordered]@{
            Set_Response_ProjectNotFound = (New-SetResponse -Name "responseMessage" -Value "Projeto nao encontrado, inativo ou deletado. Codigo: PROJECT_NOT_FOUND.")
        }
    }
}

$taskActions = [ordered]@{
    Initialize_ResponseMessage = [ordered]@{
        type = "InitializeVariable"
        runAfter = [ordered]@{}
        inputs = [ordered]@{ variables = @([ordered]@{ name = "responseMessage"; type = "string" }) }
    }
    Compose_NomeProjeto = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Initialize_ResponseMessage = @("Succeeded") }; inputs = "@trim(coalesce(triggerBody()?['text'], ''))" }
    Compose_Titulo = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_NomeProjeto = @("Succeeded") }; inputs = "@trim(coalesce(triggerBody()?['text_1'], 'Nova tarefa'))" }
    Compose_PrazoRaw = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_Titulo = @("Succeeded") }; inputs = "@trim(coalesce(string(triggerBody()?['text_3']), ''))" }
    Compose_DataFim = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_PrazoRaw = @("Succeeded") }; inputs = $brazilianDateExpression }
    Map_Prioridade = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_DataFim = @("Succeeded") }; inputs = "@if(startsWith(toLower(trim(coalesce(triggerBody()?['text_4'], 'Media'))), 'cr'), 'Critica', if(startsWith(toLower(trim(coalesce(triggerBody()?['text_4'], 'Media'))), 'al'), 'Alta', if(startsWith(toLower(trim(coalesce(triggerBody()?['text_4'], 'Media'))), 'ba'), 'Baixa', 'Media')))" }
    Get_Projeto = New-GetItemsAction -ListId $projectListId -Filter "(ProjectID eq '@{replace(outputs('Compose_NomeProjeto'), '''', '''''')}' or NomeProjeto eq '@{replace(outputs('Compose_NomeProjeto'), '''', '''''')}') and Ativo eq 1 and Deleted ne 1" -Top 1
    Condition_Prazo_Valido = [ordered]@{
        type = "If"
        runAfter = [ordered]@{ Get_Projeto = @("Succeeded") }
        expression = [ordered]@{ not = [ordered]@{ equals = @("@outputs('Compose_DataFim')", "INVALID_BR_DATE") } }
        actions = [ordered]@{
            Condition_Projeto_Encontrado = $conditionProjetoEncontrado
        }
        else = [ordered]@{
            actions = [ordered]@{
                Set_Response_InvalidDate = (New-SetResponse -Name "responseMessage" -Value "Prazo invalido. Use formato brasileiro dd/MM/aaaa, ex: 30/06/2026. Codigo: INVALID_BR_DATE.")
            }
        }
    }
    Valores_retornados_para_o_Power_Virtual_Agents = New-ResponseAction
}
$taskActions.Get_Projeto.runAfter = [ordered]@{ Map_Prioridade = @("Succeeded") }
$taskActions.Condition_Prazo_Valido.actions.Condition_Projeto_Encontrado.actions.Set_Response_Success.runAfter = [ordered]@{ Create_Tarefa_SharePoint = @("Succeeded") }
$taskActions.Valores_retornados_para_o_Power_Virtual_Agents.runAfter = [ordered]@{ Condition_Prazo_Valido = @("Succeeded") }
$taskFlow = New-FlowBase -TriggerProperties $taskInputs -Actions $taskActions
Write-TextFile -Path (Join-Path $WorkingDir "Workflows/PMO_PA_CriarTarefa-$criarTarefaIdFile.json") -Content ($taskFlow | ConvertTo-Json -Depth 50)

$batchInputs = [ordered]@{
    text = New-TextInput "rawBatchText" "Texto"
    text_1 = New-TextInput "confirmacao" "Texto 1"
}
$batchCard = '{"type":"AdaptiveCard","version":"1.4","body":[{"type":"TextBlock","text":"Revisao de projetos em lote","weight":"Bolder"},{"type":"TextBlock","text":"Modo seguro v3.0: preview/no-write ate o Adaptive Card/parser por linha ser validado.","wrap":true}],"actions":[{"type":"Action.Submit","title":"Validar lote","data":{"action":"previewCreateBatch","cardVersion":"3.0","maxBatchProjects":10,"maxBatchTasks":10,"writeMode":"disabled"}}]}'
$batchActions = [ordered]@{
    Initialize_ResponseMessage = [ordered]@{ type = "InitializeVariable"; runAfter = [ordered]@{}; inputs = [ordered]@{ variables = @([ordered]@{ name = "responseMessage"; type = "string" }) } }
    Initialize_RowResults = [ordered]@{ type = "InitializeVariable"; runAfter = [ordered]@{ Initialize_ResponseMessage = @("Succeeded") }; inputs = [ordered]@{ variables = @([ordered]@{ name = "rowResults"; type = "array"; value = @() }) } }
    Compose_AdaptiveCardPreview = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Initialize_RowResults = @("Succeeded") }; inputs = $batchCard }
    Compose_RawBatchText = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_AdaptiveCardPreview = @("Succeeded") }; inputs = "@coalesce(triggerBody()?['text'], '')" }
    Compose_InputLines = [ordered]@{ type = "Compose"; runAfter = [ordered]@{ Compose_RawBatchText = @("Succeeded") }; inputs = "@take(split(replace(outputs('Compose_RawBatchText'), decodeUriComponent('%0D'), ''), decodeUriComponent('%0A')), 50)" }
    Set_Response_BatchPreviewOnly = (New-SetResponse -Name "responseMessage" -Value "@concat('BATCH_PREVIEW_ONLY_NO_WRITE. Modo seguro v3.0: nenhuma gravacao foi executada. Linhas recebidas: ', string(length(outputs('Compose_InputLines'))), '. Proximo passo tecnico: Adaptive Card/parser por linha para Nome_ProjetoN e TarefaN antes de habilitar escrita. maxBatchProjects=10 maxBatchTasks=10.')")
    Valores_retornados_para_o_Power_Virtual_Agents = New-ResponseAction
}
$batchActions.Set_Response_BatchPreviewOnly.runAfter = [ordered]@{ Compose_InputLines = @("Succeeded") }
$batchActions.Valores_retornados_para_o_Power_Virtual_Agents.runAfter = [ordered]@{ Set_Response_BatchPreviewOnly = @("Succeeded") }
$batchFlow = New-FlowBase -TriggerProperties $batchInputs -Actions $batchActions
Write-TextFile -Path (Join-Path $WorkingDir "Workflows/PMO_PA_Gerar_Multiplos_Projetos-$batchIdFile.json") -Content ($batchFlow | ConvertTo-Json -Depth 70)

$criarProjetoTopicDir = Join-Path $WorkingDir "botcomponents/pmo_AssistentePMO_V2.topic.CriarProjeto"
$criarTarefaTopicDir = Join-Path $WorkingDir "botcomponents/pmo_AssistentePMO_V2.topic.CriarTarefa"
$criarProjetoActionDir = Join-Path $WorkingDir "botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto"
$criarTarefaActionDir = Join-Path $WorkingDir "botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa"
$batchTopicDir = Join-Path $WorkingDir "botcomponents/pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos"
New-Item -ItemType Directory -Force -Path $criarProjetoTopicDir,$criarTarefaTopicDir,$criarProjetoActionDir,$criarTarefaActionDir,$batchTopicDir | Out-Null

Write-TextFile -Path (Join-Path $criarProjetoTopicDir "botcomponent.xml") -Content '<botcomponent schemaname="pmo_AssistentePMO_V2.topic.CriarProjeto"><componenttype>9</componenttype><description>Cria projeto na lista Projetos.</description><iscustomizable>1</iscustomizable><name>CriarProjeto</name><parentbotid><schemaname>pmo_AssistentePMO_V2</schemaname></parentbotid><statecode>0</statecode><statuscode>1</statuscode></botcomponent>'
Write-TextFile -Path (Join-Path $criarTarefaTopicDir "botcomponent.xml") -Content '<botcomponent schemaname="pmo_AssistentePMO_V2.topic.CriarTarefa"><componenttype>9</componenttype><description>Cria tarefa na lista Tarefas vinculada a projeto ativo.</description><iscustomizable>1</iscustomizable><name>CriarTarefa</name><parentbotid><schemaname>pmo_AssistentePMO_V2</schemaname></parentbotid><statecode>0</statecode><statuscode>1</statuscode></botcomponent>'
Write-TextFile -Path (Join-Path $criarProjetoActionDir "botcomponent.xml") -Content '<botcomponent schemaname="pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto"><componenttype>9</componenttype><description>Acao vinculada ao fluxo Power Automate PMO_PA_CriarProjeto - cria projeto na lista Projetos.</description><iscustomizable>1</iscustomizable><name>PMO_PA_CriarProjeto</name><parentbotid><schemaname>pmo_AssistentePMO_V2</schemaname></parentbotid><statecode>0</statecode><statuscode>1</statuscode></botcomponent>'
Write-TextFile -Path (Join-Path $criarTarefaActionDir "botcomponent.xml") -Content '<botcomponent schemaname="pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa"><componenttype>9</componenttype><description>Acao vinculada ao fluxo Power Automate PMO_PA_CriarTarefa - cria tarefa na lista Tarefas.</description><iscustomizable>1</iscustomizable><name>PMO_PA_CriarTarefa</name><parentbotid><schemaname>pmo_AssistentePMO_V2</schemaname></parentbotid><statecode>0</statecode><statuscode>1</statuscode></botcomponent>'
Write-TextFile -Path (Join-Path $batchTopicDir "botcomponent.xml") -Content '<botcomponent schemaname="pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos"><componenttype>9</componenttype><description>Gera multiplos projetos e tarefas iniciais com revisao.</description><iscustomizable>1</iscustomizable><name>Gerar_Multiplos_Projetos</name><parentbotid><schemaname>pmo_AssistentePMO_V2</schemaname></parentbotid><statecode>0</statecode><statuscode>1</statuscode></botcomponent>'

Write-TextFile -Path (Join-Path $criarProjetoActionDir "data") -Content @"
kind: TaskDialog
modelDescription: Cria projeto na lista SharePoint Projetos.
outputs:
  - propertyName: message
    name: Mensagem
    description: Mensagem retornada pelo fluxo PMO_PA_CriarProjeto.
inputs:
  - kind: ManualTaskInput
    propertyName: text
    value: =Global.PMO_Projeto_NomeProjeto

  - kind: ManualTaskInput
    propertyName: text_1
    value: =Global.PMO_Projeto_NomeProjeto

  - kind: ManualTaskInput
    propertyName: text_2
    value: =Global.PMO_Projeto_PM

  - kind: ManualTaskInput
    propertyName: text_3
    value: =Global.PMO_Projeto_Prazo

  - kind: ManualTaskInput
    propertyName: number
    value: =0

  - kind: ManualTaskInput
    propertyName: text_4
    value: =Global.PMO_Projeto_Prioridade

action:
  kind: InvokeFlowTaskAction
  flowId: $criarProjetoId
  connectionProperties:
    `$kind: ConnectionProperties
    diagnostics:
    mode: Embedded

outputMode: All
"@

Write-TextFile -Path (Join-Path $criarTarefaActionDir "data") -Content @"
kind: TaskDialog
inputs:
  - kind: ManualTaskInput
    propertyName: text
    value: =Global.PMO_Criar_NomeProjeto

  - kind: ManualTaskInput
    propertyName: text_1
    value: =Global.PMO_Criar_Titulo

  - kind: ManualTaskInput
    propertyName: text_2
    value: =Global.PMO_Criar_Responsavel

  - kind: ManualTaskInput
    propertyName: text_3
    value: =Global.PMO_Criar_Prazo

  - kind: ManualTaskInput
    propertyName: number
    value: =Global.PMO_Criar_Horas

  - kind: ManualTaskInput
    propertyName: text_4
    value: =Global.PMO_Criar_Prioridade

outputs:
  - propertyName: message
    name: Mensagem
    description: Mensagem retornada pelo fluxo PMO_PA_CriarTarefa.

action:
  kind: InvokeFlowTaskAction
  flowId: $criarTarefaId
  connectionProperties:
    `$kind: ConnectionProperties
    diagnostics:
    mode: Embedded

outputMode: All
"@

Write-TextFile -Path (Join-Path $criarProjetoTopicDir "data") -Content @"
kind: AdaptiveDialog
beginDialog:
  kind: OnRecognizedIntent
  id: main
  intent:
    displayName: CriarProjeto
    includeInOnSelectIntent: true
    triggerQueries:
      - criar projeto
      - novo projeto
      - abrir projeto
      - registrar projeto
  actions:
    - kind: SetVariable
      id: set_raw_input
      variable: Topic.RawInput
      value: =System.Activity.Text
    - kind: SetVariable
      id: parse_nome_projeto
      variable: Topic.NomeProjeto
      value: =If(IsMatch(Topic.RawInput, "criar\s+projeto\s*:\s*nome\s*_?\s*projeto\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "criar\s+projeto\s*:\s*nome\s*_?\s*projeto\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*nome\s*_?\s*projeto\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*nome\s*_?\s*projeto\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*projeto\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*projeto\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.RawInput, "criar\s+projeto\s*:\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "criar\s+projeto\s*:\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank()))))
    - kind: SetVariable
      id: parse_pm
      variable: Topic.PM
      value: =If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*pm\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*pm\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank())
    - kind: SetVariable
      id: parse_prazo
      variable: Topic.Prazo
      value: =If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*(?:prazo|data\s*alvo|dataalvo)\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*(?:prazo|data\s*alvo|dataalvo)\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank())
    - kind: SetVariable
      id: parse_prioridade
      variable: Topic.Prioridade
      value: =If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*prioridade\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*prioridade\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank())
    - kind: Question
      id: ask_nome_projeto
      variable: Topic.NomeProjeto
      prompt: Qual o nome do projeto?
      entity: StringPrebuiltEntity
    - kind: Question
      id: ask_pm
      variable: Topic.PM
      prompt: Qual o email do PM?
      entity: StringPrebuiltEntity
    - kind: Question
      id: ask_prazo
      variable: Topic.Prazo
      prompt: Qual o prazo do projeto? Use dd/MM/aaaa.
      entity: StringPrebuiltEntity
    - kind: Question
      id: ask_prioridade
      variable: Topic.Prioridade
      prompt: Qual a prioridade? Baixa, Media, Alta ou Critica.
      entity: StringPrebuiltEntity
    - kind: Question
      id: confirm_criar_projeto
      variable: Topic.ConfirmacaoTexto
      prompt: |-
        Vou criar o projeto {Topic.NomeProjeto}. Confirma?
      entity: StringPrebuiltEntity
    - kind: ConditionGroup
      id: confirm_branch
      conditions:
        - id: confirmed
          condition: =Or(Lower(Trim(Topic.ConfirmacaoTexto)) = "sim", Lower(Trim(Topic.ConfirmacaoTexto)) = "s", Lower(Trim(Topic.ConfirmacaoTexto)) = "yes", Lower(Trim(Topic.ConfirmacaoTexto)) = "confirmo")
          actions:
            - kind: SetVariable
              id: set_global_projeto_nome
              variable: Global.PMO_Projeto_NomeProjeto
              value: =Topic.NomeProjeto
            - kind: SetVariable
              id: set_global_projeto_pm
              variable: Global.PMO_Projeto_PM
              value: =Topic.PM
            - kind: SetVariable
              id: set_global_projeto_prazo
              variable: Global.PMO_Projeto_Prazo
              value: =Topic.Prazo
            - kind: SetVariable
              id: set_global_projeto_prioridade
              variable: Global.PMO_Projeto_Prioridade
              value: =Topic.Prioridade
            - kind: BeginDialog
              id: call_criar_projeto
              input: {}
              dialog: pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto
              output:
                binding:
                  message: Topic.Result
            - kind: SendActivity
              id: done
              activity: "{Topic.Result}"
      elseActions:
        - kind: SendActivity
          id: cancelled
          activity: Criacao cancelada.
inputType: {}
outputType: {}
"@

Write-TextFile -Path (Join-Path $criarTarefaTopicDir "data") -Content @"
kind: AdaptiveDialog
beginDialog:
  kind: OnRecognizedIntent
  id: main
  intent:
    displayName: CriarTarefa
    includeInOnSelectIntent: true
    triggerQueries:
      - criar tarefa
      - criar uma tarefa
      - nova tarefa
      - adicionar tarefa
      - cadastrar tarefa
      - "criar tarefa:"
  actions:
    - kind: SetVariable
      id: set_raw_input
      variable: Topic.RawInput
      value: =System.Activity.Text
    - kind: SetVariable
      id: parse_projeto
      variable: Topic.NomeProjeto
      value: =If(IsMatch(Topic.RawInput, "projeto\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "projeto\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank())
    - kind: SetVariable
      id: parse_titulo
      variable: Topic.Titulo
      value: =If(IsMatch(Topic.RawInput, "t.tulo\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "t.tulo\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*tarefa\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*tarefa\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank()))
    - kind: SetVariable
      id: parse_responsavel
      variable: Topic.Responsavel
      value: =If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*respons.vel\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*respons.vel\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank())
    - kind: SetVariable
      id: parse_prazo
      variable: Topic.Prazo
      value: =If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*prazo\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*prazo\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank())
    - kind: SetVariable
      id: parse_horas
      variable: Topic.Horas
      value: =If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*horas\s*[:=]\s*(?<v>\d+(?:[\.,]\d+)?)", MatchOptions.IgnoreCase), Value(Substitute(Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*horas\s*[:=]\s*(?<v>\d+(?:[\.,]\d+)?)", MatchOptions.IgnoreCase).v), ",", ".")), Blank())
    - kind: SetVariable
      id: parse_prioridade
      variable: Topic.Prioridade
      value: =If(IsMatch(Topic.RawInput, "(?:^|[,;\r\n])\s*prioridade\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase), Trim(Match(Topic.RawInput, "(?:^|[,;\r\n])\s*prioridade\s*[:=]\s*(?<v>[^,\r\n]+)", MatchOptions.IgnoreCase).v), Blank())
    - kind: Question
      id: ask_nome_projeto
      variable: Topic.NomeProjeto
      prompt: Qual o nome ou codigo do projeto?
      entity: StringPrebuiltEntity
    - kind: Question
      id: ask_titulo
      variable: Topic.Titulo
      prompt: Qual o titulo da tarefa?
      entity: StringPrebuiltEntity
    - kind: Question
      id: ask_responsavel
      variable: Topic.Responsavel
      prompt: Quem e o responsavel pela tarefa?
      entity: StringPrebuiltEntity
    - kind: Question
      id: ask_prazo
      variable: Topic.Prazo
      prompt: Qual o prazo da tarefa? Use dd/MM/aaaa.
      entity: StringPrebuiltEntity
    - kind: Question
      id: ask_horas
      variable: Topic.Horas
      prompt: Quantas horas estimadas?
      entity: NumberPrebuiltEntity
    - kind: Question
      id: ask_prioridade
      variable: Topic.Prioridade
      prompt: Qual a prioridade? Baixa, Media, Alta ou Critica.
      entity: StringPrebuiltEntity
    - kind: Question
      id: confirm_criar_tarefa
      variable: Topic.ConfirmacaoTexto
      prompt: |-
        Vou criar a tarefa {Topic.Titulo} no projeto {Topic.NomeProjeto}. Confirma?
      entity: StringPrebuiltEntity
    - kind: ConditionGroup
      id: confirm_branch
      conditions:
        - id: confirmed
          condition: =Or(Lower(Trim(Topic.ConfirmacaoTexto)) = "sim", Lower(Trim(Topic.ConfirmacaoTexto)) = "s", Lower(Trim(Topic.ConfirmacaoTexto)) = "yes", Lower(Trim(Topic.ConfirmacaoTexto)) = "confirmo")
          actions:
            - kind: SetVariable
              id: set_global_nome_projeto
              variable: Global.PMO_Criar_NomeProjeto
              value: =Topic.NomeProjeto
            - kind: SetVariable
              id: set_global_titulo
              variable: Global.PMO_Criar_Titulo
              value: =Topic.Titulo
            - kind: SetVariable
              id: set_global_responsavel
              variable: Global.PMO_Criar_Responsavel
              value: =Topic.Responsavel
            - kind: SetVariable
              id: set_global_prazo
              variable: Global.PMO_Criar_Prazo
              value: =Topic.Prazo
            - kind: SetVariable
              id: set_global_horas
              variable: Global.PMO_Criar_Horas
              value: =Topic.Horas
            - kind: SetVariable
              id: set_global_prioridade
              variable: Global.PMO_Criar_Prioridade
              value: =Topic.Prioridade
            - kind: BeginDialog
              id: call_criar_tarefa
              input: {}
              dialog: pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa
              output:
                binding:
                  message: Topic.Result
            - kind: SendActivity
              id: done
              activity: "{Topic.Result}"
      elseActions:
        - kind: SendActivity
          id: cancelled
          activity: Criacao cancelada.
inputType: {}
outputType: {}
"@

Write-TextFile -Path (Join-Path $batchTopicDir "data") -Content @"
kind: AdaptiveDialog
beginDialog:
  kind: OnRecognizedIntent
  id: main
  intent:
    displayName: Gerar_Multiplos_Projetos
    includeInOnSelectIntent: true
    triggerQueries:
      - gerar multiplos projetos
      - criar varios projetos
      - criar projetos em lote
      - gerar projetos em batch
  actions:
    - kind: SetVariable
      id: set_raw_input
      variable: Topic.RawBatchText
      value: =System.Activity.Text
    - kind: SendActivity
      id: adaptive_card_preview_marker
      activity: "AdaptiveCard Action.Submit previewCreateBatch cardVersion=3.0 writeMode=disabled maxBatchProjects=10 maxBatchTasks=10 multiline STT fallback"
    - kind: Question
      id: confirm_batch
      variable: Topic.ConfirmacaoTexto
      prompt: Confirma gerar os projetos revisados?
      entity: StringPrebuiltEntity
    - kind: SendActivity
      id: done
      activity: "BATCH_PREVIEW_ONLY_NO_WRITE. Modo seguro v3.0: nenhuma gravacao foi executada. Proximo passo tecnico: Adaptive Card/parser por linha para Nome_ProjetoN e TarefaN antes de habilitar escrita. maxBatchProjects=10 maxBatchTasks=10."
inputType: {}
outputType: {}
"@

$workflowSet = Get-Content -LiteralPath $workflowSetPath -Raw
$workflowSet = [regex]::Replace($workflowSet, '(?ms)\s*<botcomponent_workflow botcomponentid\.schemaname="pmo_AssistentePMO_V2\.topic\.CriarTarefa" workflowid\.workflowid="3104124d-364a-f111-bec7-7ced8d955c6c">.*?</botcomponent_workflow>', '')
foreach ($workflowBinding in @(
    "  <botcomponent_workflow botcomponentid.schemaname=`"pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto`" workflowid.workflowid=`"$criarProjetoId`">`r`n    <iscustomizable>1</iscustomizable>`r`n  </botcomponent_workflow>",
    "  <botcomponent_workflow botcomponentid.schemaname=`"pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa`" workflowid.workflowid=`"$criarTarefaId`">`r`n    <iscustomizable>1</iscustomizable>`r`n  </botcomponent_workflow>"
)) {
    $bindingName = [regex]::Match($workflowBinding, 'botcomponentid\.schemaname="([^"]+)"').Groups[1].Value
    if ($workflowSet -notmatch [regex]::Escape($bindingName)) {
        $workflowSet = $workflowSet -replace "</botcomponent_workflowset>", "$workflowBinding`r`n</botcomponent_workflowset>"
    }
}
Write-TextFile -Path $workflowSetPath -Content $workflowSet

$contentTypes = Get-Content -LiteralPath $contentTypesPath -Raw
foreach ($part in @(
    "/botcomponents/pmo_AssistentePMO_V2.topic.CriarProjeto/data",
    "/botcomponents/pmo_AssistentePMO_V2.topic.Gerar_Multiplos_Projetos/data",
    "/botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto/data",
    "/botcomponents/pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa/data"
)) {
    if ($contentTypes -notmatch [regex]::Escape($part)) {
        $contentTypes = $contentTypes -replace "</Types>", "<Override PartName=`"$part`" ContentType=`"application/octet-stream`" /></Types>"
    }
}
Write-TextFile -Path $contentTypesPath -Content $contentTypes

Set-ListarTarefasContentSafeOutput -SolutionDir $WorkingDir

$resolvedOutput = Join-Path (Get-Location) $OutputZip
if (Test-Path -LiteralPath $resolvedOutput) {
    Remove-Item -LiteralPath $resolvedOutput -Force
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $resolvedOutput) | Out-Null
New-DataverseSolutionZip -SourceDir $WorkingDir -DestinationPath $resolvedOutput

Write-Host "Built $resolvedOutput"
