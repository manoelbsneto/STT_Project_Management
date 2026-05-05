[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$EnvironmentDisplayName = "ColOfertasBrasilPro",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$SharePointConnectionName = "44f187cde7f54f208cf22bac4e533816",
    [string]$EvidenceDir = ".planning\comms",
    [switch]$BuildOnly
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
    if ($flowName) { $payload.name = $flowName }

    $requestPath = Join-Path $evidenceRoot "processsimple_criartarefa_request_$($payload.name).json"
    $resultPath = Join-Path $evidenceRoot "processsimple_criartarefa_result_$($payload.name).json"
    Save-Json -Data $payload -Path $requestPath

    $result = Invoke-WithRetry -Operation "$method ProcessSimple $DisplayName" -Attempts 4 -DelaySeconds 12 -ScriptBlock {
        InvokeApi -Method $method -Route $route -Body $payload -ApiVersion "2016-11-01" -ThrowOnFailure
    }
    Save-Json -Data $result -Path $resultPath

    Start-Sleep -Seconds 5
    $createdName = if ($result.name) { $result.name } else { $payload.name }

    $flow = Invoke-WithRetry -Operation "Get-Flow $DisplayName" -Attempts 6 -DelaySeconds 8 -ScriptBlock {
        $f = Get-Flow -EnvironmentName $EnvironmentName -FlowName $createdName -ErrorAction Stop
        if (-not $f -or -not $f.Internal) { throw "Flow not ready" }
        $f
    }

    [pscustomobject]@{
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
# Actions: Auto-generate ProjectID → Create item in Projetos → Respond
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
                    required = @("titulo", "responsavel", "prioridade")
                }
            }
        }
    } `
    -Actions ([ordered]@{
        # Step 1: Get all existing projects to determine next ProjectID
        Get_Existing_Projects = New-SharePointGetItems `
            -ListName "Projetos" `
            -Top 5000

        # Step 2: Extract max numeric suffix from existing ProjectIDs
        Select_ProjectID_Numbers = [ordered]@{
            type = "Select"
            inputs = [ordered]@{
                from = "@body('Get_Existing_Projects')?['value']"
                select = "@int(coalesce(last(split(coalesce(item()?['ProjectID'], 'PRJ-0'), '-')), '0'))"
            }
            runAfter = [ordered]@{ Get_Existing_Projects = @("Succeeded") }
        }

        Compose_Max_ID = [ordered]@{
            type = "Compose"
            inputs = "@if(equals(length(body('Select_ProjectID_Numbers')), 0), 0, max(body('Select_ProjectID_Numbers')))"
            runAfter = [ordered]@{ Select_ProjectID_Numbers = @("Succeeded") }
        }

        Compose_New_ProjectID = [ordered]@{
            type = "Compose"
            inputs = "@concat('PRJ-', padLeft(string(add(outputs('Compose_Max_ID'), 1)), 6, '0'))"
            runAfter = [ordered]@{ Compose_Max_ID = @("Succeeded") }
        }

        # Step 3: Map prioridade (Critica → Alta, others pass through)
        Map_Prioridade = [ordered]@{
            type = "Compose"
            inputs = "@if(or(equals(triggerBody()?['prioridade'], 'Critica'), equals(triggerBody()?['prioridade'], 'Crítica')), 'Alta', coalesce(triggerBody()?['prioridade'], 'Media'))"
            runAfter = [ordered]@{ Compose_New_ProjectID = @("Succeeded") }
        }

        # Step 4: Compose project name (use nomeProjeto if provided, else titulo)
        Compose_NomeProjeto = [ordered]@{
            type = "Compose"
            inputs = "@coalesce(triggerBody()?['nomeProjeto'], triggerBody()?['titulo'], 'Sem nome')"
            runAfter = [ordered]@{ Map_Prioridade = @("Succeeded") }
        }

        # Step 5: Create the project item in SharePoint
        Create_Projeto_SharePoint = New-SharePointPostItem `
            -ListName "Projetos" `
            -ItemFields @{
                "Title"                = "@outputs('Compose_NomeProjeto')"
                "ProjectID"            = "@outputs('Compose_New_ProjectID')"
                "NomeProjeto"          = "@outputs('Compose_NomeProjeto')"
                "StatusRAG/Value"      = "Verde"
                "Percentual"           = 0
                "Ativo"                = $true
                "UltimaAtualizacao"    = "@utcNow()"
                "Prioridade/Value"     = "@outputs('Map_Prioridade')"
                "ResumoExecutivo"      = "@concat('Projeto criado via Copilot Studio. Titulo: ', coalesce(triggerBody()?['titulo'], '-'), '. Horas estimadas: ', coalesce(string(triggerBody()?['horas']), 'N/A'), 'h. Responsavel: ', coalesce(triggerBody()?['responsavel'], '-'), '. Prazo: ', coalesce(triggerBody()?['prazo'], '-'), '.')"
            } `
            -RunAfter @{ Compose_NomeProjeto = @("Succeeded") }

        # Step 6: Success response back to Copilot Studio
        Response_Success = [ordered]@{
            type = "Response"
            kind = "Skills"
            inputs = [ordered]@{
                statusCode = 200
                headers = [ordered]@{ "Content-Type" = "application/json" }
                body = [ordered]@{
                    success = $true
                    message = "@{concat('Projeto ', outputs('Compose_NomeProjeto'), ' criado com codigo ', outputs('Compose_New_ProjectID'), '.')}"
                    projectId = "@{outputs('Compose_New_ProjectID')}"
                }
            }
            runAfter = [ordered]@{ Create_Projeto_SharePoint = @("Succeeded") }
        }

        # Step 7: Error response
        Response_Error = [ordered]@{
            type = "Response"
            kind = "Skills"
            inputs = [ordered]@{
                statusCode = 500
                headers = [ordered]@{ "Content-Type" = "application/json" }
                body = [ordered]@{
                    success = $false
                    message = "Erro ao criar projeto no SharePoint."
                    errorcode = "SP_CREATE_FAILED"
                }
            }
            runAfter = [ordered]@{ Create_Projeto_SharePoint = @("Failed", "TimedOut") }
        }
    })

# =============================================================================
# DEPLOY
# =============================================================================

if ($BuildOnly) {
    $buildPath = Join-Path $evidenceRoot "pa_criartarefa_buildonly_$timestamp.json"
    Save-Json -Data ([pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        status = "BUILD_ONLY"
        displayName = "PMO_PA_CriarTarefa"
        definition = $flowDefinition
        triggerType = "Request/Skills"
        connectors = @("shared_sharepointonline")
        standardOnly = $true
    }) -Path $buildPath
    Write-Host "Build-only evidence: $buildPath"
    exit 0
}

try {
    $result = New-ProcessSimpleFlow -DisplayName "PMO_PA_CriarTarefa" -Definition $flowDefinition

    $evidencePath = Join-Path $evidenceRoot "pa_criartarefa_flow_$timestamp.json"
    Save-Json -Data ([pscustomobject]@{
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
            "ProjectID is auto-generated as PRJ-XXXXXX (sequential).",
            "PM field (User type) is deferred to V2; responsavel is stored in ResumoExecutivo.",
            "Prioridade 'Critica' is mapped to 'Alta' (schema constraint).",
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
    Save-Json -Data ([pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        status = "FAILED"
        error = $_.Exception.Message
    }) -Path $errorPath
    Write-Error $_.Exception.Message
    exit 1
}
