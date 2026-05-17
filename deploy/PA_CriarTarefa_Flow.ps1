[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$EnvironmentDisplayName = "ColOfertasBrasilPro",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$SharePointConnectionName = "44f187cde7f54f208cf22bac4e533816",
    [string]$FlowDisplayName = "PMO_PA_CriarTarefa_V3",
    [string]$EvidenceDir = ".planning\comms",
    [switch]$ForceCreate,
    [switch]$BuildOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$evidenceRoot = Join-Path $repoRoot $EvidenceDir
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

function Get-RequiredModulePath {
    param([string]$ModuleName)

    $module = Get-Module -ListAvailable $ModuleName | Select-Object -First 1
    if ($module) {
        return $module.Path
    }

    $candidateRoots = @(
        (Join-Path $HOME "Documents\PowerShell\Modules"),
        (Join-Path $HOME "Documents\WindowsPowerShell\Modules")
    )
    foreach ($root in $candidateRoots) {
        $moduleRoot = Join-Path $root $ModuleName
        if (-not (Test-Path -LiteralPath $moduleRoot)) {
            continue
        }
        $manifest = Get-ChildItem -LiteralPath $moduleRoot -Recurse -Filter "$ModuleName.psd1" |
            Sort-Object FullName -Descending |
            Select-Object -First 1
        if ($manifest) {
            return $manifest.FullName
        }
    }

    throw "$ModuleName module not found."
}

if (-not $BuildOnly) {
    Import-Module (Get-RequiredModulePath "Microsoft.PowerApps.Administration.PowerShell") -ErrorAction Stop
    Import-Module (Get-RequiredModulePath "Microsoft.PowerApps.PowerShell") -ErrorAction Stop
}

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 100)
    $Data | ConvertTo-Json -Depth $Depth | Set-Content -LiteralPath $Path -Encoding UTF8
}

function New-FlowDefinition {
    param(
        [hashtable]$Triggers,
        [hashtable]$Actions
    )

    [ordered]@{
        '$schema' = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
        contentVersion = "1.0.0.0"
        parameters = [ordered]@{
            '$authentication' = [ordered]@{
                defaultValue = [ordered]@{}
                type = "SecureObject"
            }
            '$connections' = [ordered]@{
                defaultValue = [ordered]@{}
                type = "Object"
            }
        }
        triggers = $Triggers
        actions = $Actions
        outputs = [ordered]@{}
    }
}

function New-OpenApiAction {
    param(
        [string]$Type = "OpenApiConnection",
        [string]$ApiId,
        [string]$OperationId,
        [string]$ConnectionName,
        [hashtable]$Parameters,
        [hashtable]$RunAfter = @{}
    )

    [ordered]@{
        type = $Type
        inputs = [ordered]@{
            parameters = $Parameters
            host = [ordered]@{
                apiId = $ApiId
                operationId = $OperationId
                connectionName = $ConnectionName
            }
            authentication = "@parameters('`$authentication')"
        }
        runAfter = $RunAfter
    }
}

function New-SharePointGetItems {
    param(
        [string]$ListName,
        [string]$Filter,
        [int]$Top = 100,
        [string]$OrderBy = $null,
        [hashtable]$RunAfter = @{}
    )

    $parameters = @{
        dataset = $SiteUrl
        table = $ListName
        '$top' = $Top
    }
    if ($Filter) {
        $parameters['$filter'] = $Filter
    }
    if ($OrderBy) {
        $parameters['$orderby'] = $OrderBy
    }

    New-OpenApiAction `
        -ApiId "/providers/Microsoft.PowerApps/apis/shared_sharepointonline" `
        -OperationId "GetItems" `
        -ConnectionName "shared_sharepointonline" `
        -Parameters $parameters `
        -RunAfter $RunAfter
}

function New-SharePointPostItem {
    param(
        [string]$ListName,
        [hashtable]$ItemFields,
        [hashtable]$RunAfter = @{}
    )

    $parameters = @{
        dataset = $SiteUrl
        table = $ListName
    }
    foreach ($key in $ItemFields.Keys) {
        $parameters["item/$key"] = $ItemFields[$key]
    }

    New-OpenApiAction `
        -ApiId "/providers/Microsoft.PowerApps/apis/shared_sharepointonline" `
        -OperationId "PostItem" `
        -ConnectionName "shared_sharepointonline" `
        -Parameters $parameters `
        -RunAfter $RunAfter
}

function New-FlowPayload {
    param(
        [string]$DisplayName,
        [object]$Definition
    )

    $requestedFlowName = [guid]::NewGuid().ToString()

    [ordered]@{
        name = $requestedFlowName
        type = "Microsoft.ProcessSimple/environments/flows"
        id = "/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows/$requestedFlowName"
        properties = [ordered]@{
            apiId = "/providers/Microsoft.PowerApps/apis/shared_logicflows"
            displayName = $DisplayName
            definition = $Definition
            connectionReferences = [ordered]@{
                shared_sharepointonline = [ordered]@{
                    connectionName = $SharePointConnectionName
                    connectionReferenceLogicalName = "pmo_sharepoint"
                    source = "Invoker"
                    id = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
                    displayName = "SharePoint"
                    tier = "Standard"
                    apiName = "sharepointonline"
                    isProcessSimpleApiReferenceConversionAlreadyDone = $false
                }
            }
            flowOpenAiData = [ordered]@{
                isConsequential = $false
                isConsequentialFlagOverwritten = $false
            }
        }
    }
}

function Get-ExistingFlowByDisplayName {
    param([string]$DisplayName)

    if ($ForceCreate) {
        return $null
    }

    Get-Flow -EnvironmentName $EnvironmentName -Top 500 |
        Where-Object { $_.DisplayName -eq $DisplayName } |
        Select-Object -First 1
}

function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [string]$Operation,
        [int]$Attempts = 4,
        [int]$DelaySeconds = 10
    )

    $lastError = $null
    for ($attempt = 1; $attempt -le $Attempts; $attempt++) {
        try {
            return & $ScriptBlock
        }
        catch {
            $lastError = $_
            if ($attempt -ge $Attempts) { throw }
            Write-Warning "$Operation failed on attempt $attempt/${Attempts}: $($_.Exception.Message). Retrying in $DelaySeconds seconds."
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    if ($lastError) { throw $lastError }
}

function New-ProcessSimpleFlow {
    param(
        [string]$DisplayName,
        [object]$Definition
    )

    $existing = Get-ExistingFlowByDisplayName -DisplayName $DisplayName
    $method = "POST"
    $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows"
    $flowName = $null
    $status = "CREATED"

    if ($existing) {
        $method = "PATCH"
        $flowName = $existing.FlowName
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows/$flowName"
        $status = "PATCHED"
    }

    $payload = New-FlowPayload -DisplayName $DisplayName -Definition $Definition
    if ($flowName) {
        $payload.name = $flowName
        $payload.id = "/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows/$flowName"
    }

    $requestPath = Join-Path $evidenceRoot "processsimple_criartarefa_request_$($payload.name).json"
    $resultPath = Join-Path $evidenceRoot "processsimple_criartarefa_result_$($payload.name).json"
    Save-Json -Data $payload -Path $requestPath
    $apiPayload = Get-Content -LiteralPath $requestPath -Raw | ConvertFrom-Json

    $result = Invoke-WithRetry -Operation "$method ProcessSimple $DisplayName" -Attempts 4 -DelaySeconds 12 -ScriptBlock {
        InvokeApi -Method $method -Route $route -Body $apiPayload -ApiVersion "2016-11-01" -ThrowOnFailure
    }
    Save-Json -Data $result -Path $resultPath

    Start-Sleep -Seconds 5
    $createdName = if ($result.name) { $result.name } else { $payload.name }

    $flow = Invoke-WithRetry -Operation "Get-Flow $DisplayName" -Attempts 6 -DelaySeconds 8 -ScriptBlock {
        $f = Get-Flow -EnvironmentName $EnvironmentName -FlowName $createdName -ErrorAction Stop
        if (-not $f -or -not $f.Internal) { throw "Flow not ready" }
        $f
    }

    [ordered]@{
        displayName = $DisplayName
        status = $status
        flowName = $createdName
        enabled = $flow.Enabled
        state = $flow.Internal.properties.state
        workflowEntityId = $flow.Internal.properties.workflowEntityId
    }
}

# =============================================================================
# FLOW DEFINITION: PMO_PA_CriarTarefa
# =============================================================================
# Trigger: Copilot Studio Skills request
# Actions: Normalize input -> idempotency lookup -> create -> patch final ProjectID
# =============================================================================

$flowDefinition = New-FlowDefinition `
    -Triggers @{
        Copilot_CriarTarefa_Request = [ordered]@{
            type = "Request"
            kind = "Skills"
            inputs = [ordered]@{
                schema = [ordered]@{
                    type = "object"
                    properties = [ordered]@{
                        nomeProjeto   = [ordered]@{ type = "string"; description = "Nome do projeto (fornecido pelo PM)" }
                        titulo        = [ordered]@{ type = "string"; description = "Titulo da tarefa/projeto" }
                        responsavel   = [ordered]@{ type = "string"; description = "Nome do responsavel" }
                        prazo         = [ordered]@{ type = "string"; description = "Data alvo no formato ISO 8601 ou dd/MM/yyyy" }
                        horas         = [ordered]@{ type = "integer"; description = "Horas estimadas" }
                        prioridade    = [ordered]@{ type = "string"; description = "Prioridade: Alta, Media, Baixa ou Critica" }
                    }
                    required = @("titulo", "responsavel", "prazo", "horas", "prioridade")
                }
            }
        }
    } `
    -Actions ([ordered]@{
        Compose_NomeProjeto = [ordered]@{
            type = "Compose"
            inputs = "@trim(coalesce(triggerBody()?['nomeProjeto'], triggerBody()?['titulo'], 'Sem nome'))"
            runAfter = [ordered]@{}
        }

        Compose_DataAlvo = [ordered]@{
            type = "Compose"
            inputs = "@if(or(empty(triggerBody()?['prazo']), not(contains(string(triggerBody()?['prazo']), '/'))), triggerBody()?['prazo'], concat(last(split(string(triggerBody()?['prazo']), '/')), '-', if(equals(length(first(skip(split(string(triggerBody()?['prazo']), '/'), 1))), 1), concat('0', first(skip(split(string(triggerBody()?['prazo']), '/'), 1))), first(skip(split(string(triggerBody()?['prazo']), '/'), 1))), '-', if(equals(length(first(split(string(triggerBody()?['prazo']), '/'))), 1), concat('0', first(split(string(triggerBody()?['prazo']), '/'))), first(split(string(triggerBody()?['prazo']), '/')))))"
            runAfter = [ordered]@{ Compose_NomeProjeto = @("Succeeded") }
        }

        Map_Prioridade = [ordered]@{
            type = "Compose"
            inputs = "@if(startsWith(toLower(coalesce(triggerBody()?['prioridade'], 'Media')), 'cr'), 'Critica', if(startsWith(toLower(coalesce(triggerBody()?['prioridade'], 'Media')), 'a'), 'Alta', if(startsWith(toLower(coalesce(triggerBody()?['prioridade'], 'Media')), 'b'), 'Baixa', 'Media')))"
            runAfter = [ordered]@{ Compose_DataAlvo = @("Succeeded") }
        }

        Compose_ProjectID = [ordered]@{
            type = "Compose"
            inputs = "@concat('PRJ-', toUpper(substring(guid(), 0, 8)))"
            runAfter = [ordered]@{ Map_Prioridade = @("Succeeded") }
        }

        Get_Duplicate_Projects = New-SharePointGetItems `
            -ListName "Projetos" `
            -Filter "NomeProjeto eq '@{replace(outputs('Compose_NomeProjeto'),'''','''''')}' and Deleted ne 1 and DataAlvo ge datetime'@{convertTimeZone(concat(outputs('Compose_DataAlvo'), 'T00:00:00'), 'Romance Standard Time', 'UTC', 'yyyy-MM-ddTHH:mm:ssZ')}' and DataAlvo lt datetime'@{convertTimeZone(concat(formatDateTime(addDays(outputs('Compose_DataAlvo'), 1), 'yyyy-MM-dd'), 'T00:00:00'), 'Romance Standard Time', 'UTC', 'yyyy-MM-ddTHH:mm:ssZ')}'" `
            -Top 1 `
            -RunAfter @{ Compose_ProjectID = @("Succeeded") }

        Condition_Duplicate_Projeto = [ordered]@{
            type = "If"
            expression = [ordered]@{
                greater = @(
                    "@length(body('Get_Duplicate_Projects')?['value'])",
                    0
                )
            }
            actions = [ordered]@{
                Response_Duplicate = [ordered]@{
                    type = "Response"
                    kind = "Skills"
                    inputs = [ordered]@{
                        statusCode = 200
                        headers = [ordered]@{ "Content-Type" = "application/json" }
                        body = [ordered]@{
                            result = "@{concat('Projeto duplicado: ja existe um projeto com esse nome e data alvo. Nenhum item duplicado foi criado. Codigo existente: ', first(body('Get_Duplicate_Projects')?['value'])?['ProjectID'], '.')}"
                        }
                    }
                    runAfter = [ordered]@{}
                }
            }
            else = [ordered]@{
                actions = [ordered]@{
                    Create_Projeto_SharePoint = New-SharePointPostItem `
                        -ListName "Projetos" `
                        -ItemFields @{
                            "Title"             = "@outputs('Compose_NomeProjeto')"
                            "ProjectID"         = "@outputs('Compose_ProjectID')"
                            "NomeProjeto"       = "@outputs('Compose_NomeProjeto')"
                            "StatusRAG/Value"   = "Verde"
                            "Percentual"        = 0
                            "Ativo"             = $true
                            "Deleted"           = $false
                            "DataAlvo"          = "@outputs('Compose_DataAlvo')"
                            "UltimaAtualizacao" = "@utcNow()"
                            "Prioridade/Value"  = "@outputs('Map_Prioridade')"
                            "PM/Claims"         = "@concat('i:0#.f|membership|', triggerBody()?['responsavel'])"
                            "ResumoExecutivo"   = "@concat('Projeto criado via Copilot Studio. Titulo: ', coalesce(triggerBody()?['titulo'], '-'), '. Horas estimadas: ', coalesce(string(triggerBody()?['horas']), 'N/A'), 'h. Responsavel: ', coalesce(triggerBody()?['responsavel'], '-'), '. Prazo: ', coalesce(triggerBody()?['prazo'], '-'), '.')"
                        } `
                        -RunAfter @{}

                    Response_Success = [ordered]@{
                        type = "Response"
                        kind = "Skills"
                        inputs = [ordered]@{
                            statusCode = 200
                            headers = [ordered]@{ "Content-Type" = "application/json" }
                            body = [ordered]@{
                                result = "@{concat('Projeto ', outputs('Compose_NomeProjeto'), ' criado com codigo ', outputs('Compose_ProjectID'), '.')}"
                            }
                        }
                        runAfter = [ordered]@{ Create_Projeto_SharePoint = @("Succeeded") }
                    }

                    Response_Error_Write = [ordered]@{
                        type = "Response"
                        kind = "Skills"
                        inputs = [ordered]@{
                            statusCode = 500
                            headers = [ordered]@{ "Content-Type" = "application/json" }
                            body = [ordered]@{
                                result = "Erro ao criar ou atualizar projeto no SharePoint. Codigo: SP_WRITE_FAILED."
                            }
                        }
                        runAfter = [ordered]@{ Create_Projeto_SharePoint = @("Failed", "TimedOut") }
                    }
                }
            }
            runAfter = [ordered]@{ Get_Duplicate_Projects = @("Succeeded") }
        }
    })

# =============================================================================
# DEPLOY
# =============================================================================

if ($BuildOnly) {
    $buildPath = Join-Path $evidenceRoot "pa_criartarefa_buildonly_$timestamp.json"
    Save-Json -Data ([ordered]@{
        timestamp = (Get-Date).ToString("o")
        status = "BUILD_ONLY"
        displayName = $FlowDisplayName
        definition = $flowDefinition
        triggerType = "Request/Skills"
        connectors = @("shared_sharepointonline")
        standardOnly = $true
    }) -Path $buildPath
    Write-Host "Build-only evidence: $buildPath"
    exit 0
}

try {
    $result = New-ProcessSimpleFlow -DisplayName $FlowDisplayName -Definition $flowDefinition

    $evidencePath = Join-Path $evidenceRoot "pa_criartarefa_flow_$timestamp.json"
    Save-Json -Data ([ordered]@{
        timestamp = (Get-Date).ToString("o")
        status = $result.status
        environmentName = $EnvironmentName
        environmentDisplayName = $EnvironmentDisplayName
        siteUrl = $SiteUrl
        displayName = $result.displayName
        flowName = $result.flowName
        workflowEntityId = $result.workflowEntityId
        enabled = $result.enabled
        state = $result.state
        connectors = @("shared_sharepointonline")
        standardOnly = $true
        triggerType = "Request/Skills"
        notes = @(
            "CriarTarefa flow creates a new project item in the Projetos SharePoint list.",
            "ProjectID is generated as PRJ-XXXXXXXX from a GUID, avoiding concurrent duplicate codes without reading the latest SharePoint item.",
            "Brazilian dd/MM/yyyy dates are normalized to yyyy-MM-dd before SharePoint write.",
            "PM field (User type) is written through PM/Claims from responsavel.",
            "Prioridade is normalized to Baixa, Media, Alta, or Critica.",
            "Standard connector only (shared_sharepointonline)."
        )
    }) -Path $evidencePath

    Write-Host "PA CriarTarefa flow deployed: $evidencePath"
    Write-Host "FlowName: $($result.flowName)"
    Write-Host "WorkflowEntityId: $($result.workflowEntityId)"
    exit 0
}
catch {
    $errorPath = Join-Path $evidenceRoot "pa_criartarefa_error_$timestamp.json"
    Save-Json -Data ([ordered]@{
        timestamp = (Get-Date).ToString("o")
        status = "FAILED"
        error = $_.Exception.Message
    }) -Path $errorPath
    Write-Error $_.Exception.Message
    exit 1
}
