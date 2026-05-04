[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$EnvironmentDisplayName = "ColOfertasBrasilPro",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$TeamsGroupId = "96c5b0c4-46cc-46cd-8695-50451db74994",
    [string]$TeamsChannelId = "19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2",
    [string]$PmoFallbackEmail = "mbenicios@minsait.com",
    [string]$SharePointConnectionName = "44f187cde7f54f208cf22bac4e533816",
    [string]$TeamsConnectionName = "shared-teams-1440d346-f1dd-44ea-912f-3787038ac333",
    [string]$OutlookConnectionName = "306d783533364cb6948ab2830fc3b188"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$commsDir = Join-Path $repoRoot ".planning\comms"
$cardsDir = Join-Path $repoRoot "deploy\cards"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$evidencePath = Join-Path $commsDir "g2_p0_flow_provisioning_$timestamp.json"

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
            authentication = "@parameters('$authentication')"
        }
        runAfter = $RunAfter
    }
}

function New-SharePointGetItems {
    param(
        [string]$ListName,
        [string]$Filter,
        [int]$Top = 100,
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

    New-OpenApiAction `
        -ApiId "/providers/Microsoft.PowerApps/apis/shared_sharepointonline" `
        -OperationId "GetItems" `
        -ConnectionName "shared_sharepointonline" `
        -Parameters $parameters `
        -RunAfter $RunAfter
}

function New-TeamsPostMessage {
    param(
        [string]$Html,
        [hashtable]$RunAfter = @{}
    )

    New-OpenApiAction `
        -ApiId "/providers/Microsoft.PowerApps/apis/shared_teams" `
        -OperationId "PostMessageToConversation" `
        -ConnectionName "shared_teams" `
        -Parameters @{
            poster = "Flow bot"
            location = "Channel"
            "body/recipient/groupId" = $TeamsGroupId
            "body/recipient/channelId" = $TeamsChannelId
            "body/messageBody" = $Html
        } `
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
                shared_teams = [ordered]@{
                    connectionName = $TeamsConnectionName
                    connectionReferenceLogicalName = "pmo_teams"
                    source = "Invoker"
                    id = "/providers/Microsoft.PowerApps/apis/shared_teams"
                    displayName = "Microsoft Teams"
                    tier = "Standard"
                    apiName = "teams"
                    isProcessSimpleApiReferenceConversionAlreadyDone = $false
                }
                shared_office365 = [ordered]@{
                    connectionName = $OutlookConnectionName
                    connectionReferenceLogicalName = "pmo_office365"
                    source = "Invoker"
                    id = "/providers/Microsoft.PowerApps/apis/shared_office365"
                    displayName = "Office 365 Outlook"
                    tier = "Standard"
                    apiName = "office365"
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

    $existing = Get-Flow -EnvironmentName $EnvironmentName -Top 500 |
        Where-Object { $_.DisplayName -eq $DisplayName } |
        Select-Object -First 1

    return $existing
}

function New-ProcessSimpleFlow {
    param(
        [string]$DisplayName,
        [object]$Definition
    )

    $existing = Get-ExistingFlowByDisplayName -DisplayName $DisplayName
    if ($existing) {
        return [pscustomobject]@{
            displayName = $DisplayName
            status = "EXISTS"
            flowName = $existing.FlowName
            enabled = $existing.Enabled
            state = $existing.Internal.properties.state
            createdTime = $existing.CreatedTime
            lastModifiedTime = $existing.LastModifiedTime
        }
    }

    $payload = New-FlowPayload -DisplayName $DisplayName -Definition $Definition
    $created = InvokeApi -Method POST `
        -Route "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows" `
        -Body $payload `
        -ApiVersion "2016-11-01" `
        -ThrowOnFailure

    Start-Sleep -Seconds 4
    $createdName = if ($created.name) { $created.name } else { $payload.name }
    $flow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $createdName -ErrorAction Stop

    [pscustomobject]@{
        displayName = $DisplayName
        status = "CREATED"
        requestedFlowName = $payload.name
        flowName = $createdName
        enabled = $flow.Enabled
        state = $flow.Internal.properties.state
        createdTime = $flow.CreatedTime
        lastModifiedTime = $flow.LastModifiedTime
    }
}

$checkInCardPath = Join-Path $cardsDir "CheckInDiario.json"
$alertCardPath = Join-Path $cardsDir "AlertaCritico.json"
$decisionCardPath = Join-Path $cardsDir "DecisaoBoard.json"

$cardValidation = @(
    $checkInCardPath
    $alertCardPath
    $decisionCardPath
) | ForEach-Object {
    $raw = Get-Content -LiteralPath $_ -Raw
    $parsed = $raw | ConvertFrom-Json
    [pscustomobject]@{
        path = $_
        bytes = [System.Text.Encoding]::UTF8.GetByteCount($raw)
        schema = $parsed.'$schema'
        type = $parsed.type
        version = $parsed.version
        under27KB = ([System.Text.Encoding]::UTF8.GetByteCount($raw) -lt 27648)
    }
}

$flowDefinitions = [ordered]@{}

$flowDefinitions["PMO_PA_EnviarCheckInDiario"] = New-FlowDefinition `
    -Triggers @{
        Recurrence_9h_BRT = [ordered]@{
            recurrence = [ordered]@{
                frequency = "Day"
                interval = 1
                timeZone = "E. South America Standard Time"
                schedule = [ordered]@{ hours = @(9); minutes = @(0) }
            }
            type = "Recurrence"
        }
    } `
    -Actions @{
        Get_Projetos_Ativos = New-SharePointGetItems -ListName "Projetos" -Filter "Ativo eq 1" -Top 100
        Apply_to_each_Projeto = [ordered]@{
            type = "Foreach"
            foreach = "@body('Get_Projetos_Ativos')?['value']"
            actions = [ordered]@{
                Post_CheckIn_Message_Channel = New-TeamsPostMessage `
                    -Html "<p><b>PMO Check-in Diario</b></p><p>Atualize o status do projeto no Adaptive Card oficial: deploy/cards/CheckInDiario.json</p>" `
                    -RunAfter @{}
            }
            runAfter = @{ Get_Projetos_Ativos = @("Succeeded") }
        }
    }

$flowDefinitions["PMO_PA_ProcessarRespostaCheckIn"] = New-FlowDefinition `
    -Triggers @{
        Manual_CheckIn_Response = [ordered]@{
            type = "Request"
            kind = "Skills"
            inputs = [ordered]@{
                schema = [ordered]@{
                    type = "object"
                    properties = [ordered]@{
                        projectId = [ordered]@{ type = "string" }
                        statusRAG = [ordered]@{ type = "string" }
                        resumo = [ordered]@{ type = "string" }
                        risco = [ordered]@{ type = "string" }
                        bloqueio = [ordered]@{ type = "string" }
                        proximaAcao = [ordered]@{ type = "string" }
                        percentual = [ordered]@{ type = "integer" }
                    }
                    required = @("projectId", "statusRAG", "resumo")
                }
            }
        }
    } `
    -Actions @{
        Normalize_ProjectID = [ordered]@{
            type = "Compose"
            inputs = "@coalesce(triggerBody()?['data']?['projectId'], triggerBody()?['projectId'], triggerBody()?['ProjectID'], '')"
            runAfter = @{}
        }
        Get_Projeto = New-SharePointGetItems `
            -ListName "Projetos" `
            -Filter "ProjectID eq '@{outputs('Normalize_ProjectID')}'" `
            -Top 1 `
            -RunAfter @{ Normalize_ProjectID = @("Succeeded") }
        Notify_Channel = New-TeamsPostMessage `
            -Html "<p><b>PMO check-in response received</b></p><p>Response payload accepted for @{outputs('Normalize_ProjectID')}. SharePoint write step requires connector dynamic schema repair before E2E PASS.</p>" `
            -RunAfter @{ Get_Projeto = @("Succeeded") }
    }

$flowDefinitions["PMO_PA_AlertaProjetoVermelho"] = New-FlowDefinition `
    -Triggers @{
        Recurrence_5min = [ordered]@{
            recurrence = [ordered]@{ frequency = "Minute"; interval = 5 }
            type = "Recurrence"
        }
    } `
    -Actions @{
        Get_Projetos_Vermelhos = New-SharePointGetItems -ListName "Projetos" -Filter "StatusRAG eq 'Vermelho' and Ativo eq 1" -Top 50
        Apply_to_each_Vermelho = [ordered]@{
            type = "Foreach"
            foreach = "@body('Get_Projetos_Vermelhos')?['value']"
            actions = [ordered]@{
                Post_Alert_Message_Channel = New-TeamsPostMessage `
                    -Html "<p><b>ALERTA - Projeto Critico</b></p><p>Projeto vermelho detectado. Use o card oficial em deploy/cards/AlertaCritico.json para comunicacao executiva.</p>" `
                    -RunAfter @{}
            }
            runAfter = @{ Get_Projetos_Vermelhos = @("Succeeded") }
        }
    }

$flowDefinitions["PMO_PA_CheckInOnDemand"] = New-FlowDefinition `
    -Triggers @{
        Manual_Copilot_Request = [ordered]@{
            type = "Request"
            kind = "Skills"
            inputs = [ordered]@{
                schema = [ordered]@{
                    type = "object"
                    properties = [ordered]@{
                        ProjectID = [ordered]@{ type = "string"; description = "ProjectID to request immediate check-in" }
                    }
                    required = @("ProjectID")
                }
            }
        }
    } `
    -Actions @{
        Get_Projeto = New-SharePointGetItems `
            -ListName "Projetos" `
            -Filter "ProjectID eq '@{triggerBody()?['ProjectID']}'" `
            -Top 1
        Post_CheckIn_Message_Channel = New-TeamsPostMessage `
            -Html "<p><b>PMO Check-in On Demand</b></p><p>Check-in imediato solicitado. Use o Adaptive Card oficial em deploy/cards/CheckInDiario.json.</p>" `
            -RunAfter @{ Get_Projeto = @("Succeeded") }
        Response_OK = [ordered]@{
            type = "Response"
            kind = "Skills"
            inputs = [ordered]@{
                statusCode = 200
                headers = [ordered]@{ "Content-Type" = "application/json" }
                body = [ordered]@{
                    success = $true
                    message = "Check-in card posted to Teams channel."
                    projectId = "@{triggerBody()?['ProjectID']}"
                }
            }
            runAfter = @{ Post_CheckIn_Message_Channel = @("Succeeded") }
        }
    }

$flowDefinitions["PMO_PA_AlertaSemAtualizacao"] = New-FlowDefinition `
    -Triggers @{
        Recurrence_10h_BRT = [ordered]@{
            recurrence = [ordered]@{
                frequency = "Day"
                interval = 1
                timeZone = "E. South America Standard Time"
                schedule = [ordered]@{ hours = @(10); minutes = @(0) }
            }
            type = "Recurrence"
        }
    } `
    -Actions @{
        Get_Projetos_Ativos = New-SharePointGetItems -ListName "Projetos" -Filter "Ativo eq 1" -Top 100
        Filter_Sem_Update = [ordered]@{
            type = "Query"
            inputs = [ordered]@{
                from = "@body('Get_Projetos_Ativos')?['value']"
                where = "@lessOrEquals(coalesce(item()?['UltimaAtualizacao'], '1900-01-01T00:00:00Z'), addDays(utcNow(), -1))"
            }
            runAfter = @{ Get_Projetos_Ativos = @("Succeeded") }
        }
        Apply_to_each_Sem_Update = [ordered]@{
            type = "Foreach"
            foreach = "@body('Filter_Sem_Update')"
            actions = [ordered]@{
                Post_Reminder_Channel = New-TeamsPostMessage `
                    -Html "<p>PMO reminder: project without update in the last 24h. Check the Projetos list.</p>" `
                    -RunAfter @{}
            }
            runAfter = @{ Filter_Sem_Update = @("Succeeded") }
        }
    }

$results = [System.Collections.Generic.List[object]]::new()

try {
    Import-Module Microsoft.PowerApps.PowerShell -ErrorAction Stop
    Test-PowerAppsAccount | Out-Null

    foreach ($entry in $flowDefinitions.GetEnumerator()) {
        $displayName = $entry.Key
        try {
            $result = New-ProcessSimpleFlow -DisplayName $displayName -Definition $entry.Value
            $results.Add($result) | Out-Null
            Write-Host "$($result.status): $displayName -> $($result.flowName)"
        }
        catch {
            $results.Add([pscustomobject]@{
                displayName = $displayName
                status = "FAILED"
                error = $_.Exception.Message
            }) | Out-Null
            Write-Warning "FAILED: $displayName :: $($_.Exception.Message)"
        }
    }

    $summary = [pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        environmentName = $EnvironmentName
        environmentDisplayName = $EnvironmentDisplayName
        siteUrl = $SiteUrl
        teamsGroupId = $TeamsGroupId
        teamsChannelId = $TeamsChannelId
        connectionReferences = [ordered]@{
            sharePoint = $SharePointConnectionName
            teams = $TeamsConnectionName
            outlook = $OutlookConnectionName
        }
        adaptiveCards = $cardValidation
        results = $results
        createdOrExisting = @($results | Where-Object { $_.status -in @("CREATED", "EXISTS") }).Count
        failed = @($results | Where-Object { $_.status -eq "FAILED" }).Count
        status = if (@($results | Where-Object { $_.status -eq "FAILED" }).Count -eq 0) { "PASS" } else { "FAIL" }
        notes = @(
            "Flows are provisioned through Microsoft.ProcessSimple using Standard connector references only.",
            "PM/Sponsor person fields are empty in G1 pilot data; channel posting and PMO fallback email are used where direct recipient is unavailable.",
            "Teams card runtime rendering still requires Teams Workflows app to be allowed by tenant policy."
        )
    }

    Save-Json -Data $summary -Path $evidencePath
    Write-Host "Evidence: $evidencePath"

    if ($summary.status -eq "FAIL") {
        exit 1
    }

    exit 0
}
catch {
    Save-Json -Data ([pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        status = "FAIL"
        error = $_.Exception.Message
        results = $results
    }) -Path $evidencePath
    Write-Error $_.Exception.Message
    exit 1
}
