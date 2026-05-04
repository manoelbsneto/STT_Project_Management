param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$TeamsGroupId = "96c5b0c4-46cc-46cd-8695-50451db74994",
    [string]$TeamsChannelId = "19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2",
    [string]$FallbackEmail = "mbenicios@minsait.com",
    [string]$EvidenceDir = ".planning\comms"
)

$ErrorActionPreference = "Stop"
Write-Host "G2 redesign patch starting..."

$adminModule = "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1"
$powerAppsModule = "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"

Import-Module $adminModule -ErrorAction Stop
Import-Module $powerAppsModule -ErrorAction Stop
Write-Host "PowerApps modules imported."

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

$checkInCard = Get-Content -LiteralPath ".\deploy\cards\CheckInDiario.json" -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress
$alertCard = Get-Content -LiteralPath ".\deploy\cards\AlertaCritico.json" -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress
Write-Host "Adaptive card templates loaded."

function Escape-WorkflowLiteral {
    param([string]$Value)
    $Value.Replace("'", "''")
}

$checkInCardEscaped = Escape-WorkflowLiteral $checkInCard
$alertCardEscaped = Escape-WorkflowLiteral $alertCard
$projectNameToken = '$' + '{ProjectName}'
$projectIdToken = '$' + '{ProjectID}'
$pmToken = '$' + '{PM}'
$percentualToken = '$' + '{Percentual}'
$dataAlvoToken = '$' + '{DataAlvo}'
$ultimaAtualizacaoToken = '$' + '{UltimaAtualizacao}'
$resumoToken = '$' + '{Resumo}'
$riscoToken = '$' + '{Risco}'
$bloqueioToken = '$' + '{Bloqueio}'
$linkSharePointToken = '$' + '{LinkSharePoint}'

function New-WorkflowDefinition {
    param(
        [object]$Triggers,
        [object]$Actions
    )

    [ordered]@{
        '$schema' = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
        contentVersion = "1.0.0.0"
        parameters = [ordered]@{
            '$connections' = [ordered]@{
                defaultValue = [ordered]@{}
                type = "Object"
            }
            '$authentication' = [ordered]@{
                defaultValue = [ordered]@{}
                type = "SecureObject"
            }
        }
        triggers = $Triggers
        actions = $Actions
        outputs = [ordered]@{}
    }
}

function New-OpenApiAction {
    param(
        [string]$ApiName,
        [string]$OperationId,
        [hashtable]$Parameters,
        [hashtable]$RunAfter = @{},
        [object]$Authentication = "@parameters('$authentication')",
        [hashtable]$Limit = $null,
        [string]$ActionType = "OpenApiConnection"
    )

    $action = [ordered]@{
        type = $ActionType
        inputs = [ordered]@{
            parameters = $Parameters
            host = [ordered]@{
                apiId = "/providers/Microsoft.PowerApps/apis/$ApiName"
                connectionName = $ApiName
                operationId = $OperationId
            }
            authentication = $Authentication
        }
        runAfter = $RunAfter
    }

    if ($Limit) {
        $action.limit = $Limit
    }

    $action
}

function New-TeamsWaitCardAction {
    param(
        [string]$CardExpression,
        [hashtable]$RunAfter = @{},
        [object]$Authentication = "@parameters('$authentication')"
    )

    New-OpenApiAction `
        -ApiName "shared_teams" `
        -OperationId "PostCardAndWaitForResponse" `
        -Parameters @{
            poster = "Flow bot"
            location = "Channel"
            "body/body/recipient/groupId" = $TeamsGroupId
            "body/body/recipient/channelId" = $TeamsChannelId
            "body/body/messageBody" = $CardExpression
            "body/body/updateMessage" = "Resposta registrada. Obrigado."
        } `
        -RunAfter $RunAfter `
        -Authentication $Authentication `
        -Limit @{ timeout = "P28D" } `
        -ActionType "OpenApiConnectionWebhook"
}

function New-TeamsPostCardAction {
    param(
        [string]$CardExpression,
        [hashtable]$RunAfter = @{}
    )

    New-OpenApiAction `
        -ApiName "shared_teams" `
        -OperationId "PostCardToConversation" `
        -Parameters @{
            poster = "Flow bot"
            location = "Channel"
            "body/recipient/groupId" = $TeamsGroupId
            "body/recipient/channelId" = $TeamsChannelId
            "body/messageBody" = $CardExpression
        } `
        -RunAfter $RunAfter
}

function New-EmailAction {
    param(
        [string]$To,
        [string]$Subject,
        [string]$Body,
        [hashtable]$RunAfter = @{}
    )

    New-OpenApiAction `
        -ApiName "shared_office365" `
        -OperationId "SendEmailV2" `
        -Parameters @{
            "emailMessage/To" = $To
            "emailMessage/Subject" = $Subject
            "emailMessage/Body" = $Body
            "emailMessage/Importance" = "High"
        } `
        -RunAfter $RunAfter
}

function New-ConnectionReferences {
    [ordered]@{
        shared_sharepointonline = [ordered]@{
            connectionName = "44f187cde7f54f208cf22bac4e533816"
            connectionReferenceLogicalName = "pmo_sharepoint"
            source = "Invoker"
            id = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
            displayName = "SharePoint"
            tier = "Standard"
            apiName = "sharepointonline"
            isProcessSimpleApiReferenceConversionAlreadyDone = $false
        }
        shared_teams = [ordered]@{
            connectionName = "shared-teams-1440d346-f1dd-44ea-912f-3787038ac333"
            connectionReferenceLogicalName = "pmo_teams"
            source = "Invoker"
            id = "/providers/Microsoft.PowerApps/apis/shared_teams"
            displayName = "Microsoft Teams"
            tier = "Standard"
            apiName = "teams"
            isProcessSimpleApiReferenceConversionAlreadyDone = $false
        }
        shared_office365 = [ordered]@{
            connectionName = "306d783533364cb6948ab2830fc3b188"
            connectionReferenceLogicalName = "pmo_office365"
            source = "Invoker"
            id = "/providers/Microsoft.PowerApps/apis/shared_office365"
            displayName = "Office 365 Outlook"
            tier = "Standard"
            apiName = "office365"
            isProcessSimpleApiReferenceConversionAlreadyDone = $false
        }
    }
}

function Invoke-FlowPatch {
    param(
        [string]$FlowName,
        [string]$DisplayName,
        [object]$Definition
    )

    $body = [ordered]@{
        name = $FlowName
        type = "Microsoft.ProcessSimple/environments/flows"
        id = "/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows/$FlowName"
        properties = [ordered]@{
            apiId = "/providers/Microsoft.PowerApps/apis/shared_logicflows"
            displayName = $DisplayName
            definition = $Definition
            connectionReferences = New-ConnectionReferences
            flowOpenAiData = [ordered]@{
                isConsequential = $false
                isConsequentialFlagOverwritten = $false
            }
        }
    }

    $requestPath = Join-Path $EvidenceDir "processsimple_redesign_request_$FlowName.json"
    $resultPath = Join-Path $EvidenceDir "processsimple_redesign_result_$FlowName.json"

    $body | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $requestPath -Encoding UTF8

    $result = InvokeApi `
        -Method PATCH `
        -Route "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows/$FlowName" `
        -Body $body `
        -ApiVersion "2016-11-01" `
        -ThrowOnFailure

    $result | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $resultPath -Encoding UTF8

    [pscustomobject]@{
        DisplayName = $DisplayName
        FlowName = $FlowName
        Request = $requestPath
        Result = $resultPath
    }
}

$enviarFlowName = "e117bbc5-5684-4191-8d03-fb183452ac5f"
$onDemandFlowName = "c9e51483-38e7-422a-98cd-cf7604d14a16"
$processarFlowName = "6c8ae320-46e0-42da-bc05-5d5a9622be03"

$enviarLive = Get-Flow -EnvironmentName $EnvironmentName -FlowName $enviarFlowName -ErrorAction Stop
$onDemandLive = Get-Flow -EnvironmentName $EnvironmentName -FlowName $onDemandFlowName -ErrorAction Stop
Write-Host "Live flow definitions loaded."

$dailyCheckInCardExpression = "@replace(replace('$checkInCardEscaped', '$projectNameToken', coalesce(items('Apply_to_each_Projeto')?['NomeProjeto'], items('Apply_to_each_Projeto')?['Title'], items('Apply_to_each_Projeto')?['ProjectID'])), '$projectIdToken', items('Apply_to_each_Projeto')?['ProjectID'])"
$onDemandCheckInCardExpression = "@replace(replace('$checkInCardEscaped', '$projectNameToken', coalesce(first(body('Get_Projeto')?['value'])?['NomeProjeto'], first(body('Get_Projeto')?['value'])?['Title'], triggerBody()?['ProjectID'])), '$projectIdToken', triggerBody()?['ProjectID'])"

$dailyAlertCardExpression = "@replace(replace(replace(replace(replace(replace(replace(replace(replace('$alertCardEscaped', '$projectNameToken', coalesce(items('Apply_to_each_Projeto')?['NomeProjeto'], items('Apply_to_each_Projeto')?['Title'], items('Apply_to_each_Projeto')?['ProjectID'])), '$pmToken', coalesce(items('Apply_to_each_Projeto')?['PM']?['DisplayName'], items('Apply_to_each_Projeto')?['PM']?['Email'], '-')), '$percentualToken', string(outputs('Normalize_Percentual'))), '$dataAlvoToken', coalesce(string(items('Apply_to_each_Projeto')?['DataAlvo']), '-')), '$ultimaAtualizacaoToken', utcNow()), '$resumoToken', outputs('Normalize_Resumo')), '$riscoToken', outputs('Normalize_Risco')), '$bloqueioToken', outputs('Normalize_Bloqueio')), '$linkSharePointToken', coalesce(items('Apply_to_each_Projeto')?['{Link}'], '$SiteUrl/Lists/Projetos/AllItems.aspx'))"

$dailyProjectActions = [ordered]@{
    Post_CheckIn_Wait_Response = New-TeamsWaitCardAction -CardExpression $dailyCheckInCardExpression
    Normalize_RAG = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['statusRAG'], body('Post_CheckIn_Wait_Response')?['statusRAG'], 'Verde')"
        runAfter = [ordered]@{ Post_CheckIn_Wait_Response = @("Succeeded") }
    }
    Normalize_Resumo = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['resumo'], body('Post_CheckIn_Wait_Response')?['resumo'], 'Sem resumo informado')"
        runAfter = [ordered]@{ Normalize_RAG = @("Succeeded") }
    }
    Normalize_Percentual = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['percentual'], body('Post_CheckIn_Wait_Response')?['percentual'], 0)"
        runAfter = [ordered]@{ Normalize_Resumo = @("Succeeded") }
    }
    Normalize_Risco = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['risco'], body('Post_CheckIn_Wait_Response')?['risco'], '')"
        runAfter = [ordered]@{ Normalize_Percentual = @("Succeeded") }
    }
    Normalize_Bloqueio = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['bloqueio'], body('Post_CheckIn_Wait_Response')?['bloqueio'], '')"
        runAfter = [ordered]@{ Normalize_Risco = @("Succeeded") }
    }
    Normalize_ProximaAcao = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['proximaAcao'], body('Post_CheckIn_Wait_Response')?['proximaAcao'], '')"
        runAfter = [ordered]@{ Normalize_Bloqueio = @("Succeeded") }
    }
    Create_Status_Diario = New-OpenApiAction `
        -ApiName "shared_sharepointonline" `
        -OperationId "PostItem" `
        -Parameters @{
            dataset = $SiteUrl
            table = "Status Diario"
            "item/Title" = "@concat('STATUS-', ticks(utcNow()))"
            "item/StatusID" = "@concat('ST-', ticks(utcNow()))"
            "item/ProjectID" = "@items('Apply_to_each_Projeto')?['ProjectID']"
            "item/DataRegistro" = "@utcNow()"
            "item/RAG/Value" = "@outputs('Normalize_RAG')"
            "item/Resumo" = "@outputs('Normalize_Resumo')"
            "item/Risco" = "@outputs('Normalize_Risco')"
            "item/Bloqueio" = "@outputs('Normalize_Bloqueio')"
            "item/ProximaAcao" = "@outputs('Normalize_ProximaAcao')"
            "item/Percentual" = "@if(empty(string(outputs('Normalize_Percentual'))), 0, int(outputs('Normalize_Percentual')))"
            "item/OrigemEntrada/Value" = "AdaptiveCard"
            "item/CardVersion" = "1.0"
        } `
        -RunAfter @{ Normalize_ProximaAcao = @("Succeeded") }
    Update_Projeto = New-OpenApiAction `
        -ApiName "shared_sharepointonline" `
        -OperationId "PatchItem" `
        -Parameters @{
            dataset = $SiteUrl
            table = "Projetos"
            id = "@items('Apply_to_each_Projeto')?['ID']"
            "item/Title" = "@items('Apply_to_each_Projeto')?['Title']"
            "item/ProjectID" = "@items('Apply_to_each_Projeto')?['ProjectID']"
            "item/NomeProjeto" = "@items('Apply_to_each_Projeto')?['NomeProjeto']"
            "item/StatusRAG/Value" = "@outputs('Normalize_RAG')"
            "item/Percentual" = "@if(empty(string(outputs('Normalize_Percentual'))), 0, int(outputs('Normalize_Percentual')))"
            "item/UltimaAtualizacao" = "@utcNow()"
        } `
        -RunAfter @{ Create_Status_Diario = @("Succeeded") }
    Condition_RAG_Vermelho = [ordered]@{
        type = "If"
        expression = [ordered]@{
            equals = @("@outputs('Normalize_RAG')", "Vermelho")
        }
        actions = [ordered]@{
            Post_Alerta_Critico_Teams = New-TeamsPostCardAction -CardExpression $dailyAlertCardExpression
            Send_Email_Sponsor = New-EmailAction `
                -To "@coalesce(items('Apply_to_each_Projeto')?['Sponsor']?['Email'], '$FallbackEmail')" `
                -Subject "ALERTA: Projeto @{coalesce(items('Apply_to_each_Projeto')?['NomeProjeto'], items('Apply_to_each_Projeto')?['ProjectID'])} em status Vermelho" `
                -Body "<p>Projeto em status Vermelho.</p><p><b>ProjectID:</b> @{items('Apply_to_each_Projeto')?['ProjectID']}</p><p><b>Resumo:</b> @{outputs('Normalize_Resumo')}</p><p><b>Risco:</b> @{outputs('Normalize_Risco')}</p><p><b>Bloqueio:</b> @{outputs('Normalize_Bloqueio')}</p>" `
                -RunAfter @{ Post_Alerta_Critico_Teams = @("Succeeded") }
        }
        else = [ordered]@{
            actions = [ordered]@{}
        }
        runAfter = [ordered]@{ Update_Projeto = @("Succeeded") }
    }
}

$enviarActions = [ordered]@{
    Get_Projetos_Ativos = New-OpenApiAction `
        -ApiName "shared_sharepointonline" `
        -OperationId "GetItems" `
        -Parameters @{
            dataset = $SiteUrl
            table = "Projetos"
            '$filter' = "Ativo eq 1"
            '$top' = 100
        }
    Apply_to_each_Projeto = [ordered]@{
        type = "Foreach"
        foreach = "@body('Get_Projetos_Ativos')?['value']"
        actions = $dailyProjectActions
        runAfter = [ordered]@{ Get_Projetos_Ativos = @("Succeeded") }
    }
}

$onDemandActions = [ordered]@{
    Get_Projeto = New-OpenApiAction `
        -ApiName "shared_sharepointonline" `
        -OperationId "GetItems" `
        -Parameters @{
            dataset = $SiteUrl
            table = "Projetos"
            '$filter' = "ProjectID eq '@{triggerBody()?['ProjectID']}'"
            '$top' = 1
        }
    Post_CheckIn_Wait_Response = New-TeamsWaitCardAction `
        -CardExpression $onDemandCheckInCardExpression `
        -RunAfter @{ Get_Projeto = @("Succeeded") } `
        -Authentication ([ordered]@{
            value = "@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']"
            type = "Raw"
        })
    Normalize_RAG = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['statusRAG'], body('Post_CheckIn_Wait_Response')?['statusRAG'], 'Verde')"
        runAfter = [ordered]@{ Post_CheckIn_Wait_Response = @("Succeeded") }
    }
    Normalize_Resumo = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['resumo'], body('Post_CheckIn_Wait_Response')?['resumo'], 'Sem resumo informado')"
        runAfter = [ordered]@{ Normalize_RAG = @("Succeeded") }
    }
    Normalize_Percentual = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['percentual'], body('Post_CheckIn_Wait_Response')?['percentual'], 0)"
        runAfter = [ordered]@{ Normalize_Resumo = @("Succeeded") }
    }
    Normalize_Risco = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['risco'], body('Post_CheckIn_Wait_Response')?['risco'], '')"
        runAfter = [ordered]@{ Normalize_Percentual = @("Succeeded") }
    }
    Normalize_Bloqueio = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['bloqueio'], body('Post_CheckIn_Wait_Response')?['bloqueio'], '')"
        runAfter = [ordered]@{ Normalize_Risco = @("Succeeded") }
    }
    Normalize_ProximaAcao = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(body('Post_CheckIn_Wait_Response')?['data']?['proximaAcao'], body('Post_CheckIn_Wait_Response')?['proximaAcao'], '')"
        runAfter = [ordered]@{ Normalize_Bloqueio = @("Succeeded") }
    }
    Create_Status_Diario = New-OpenApiAction `
        -ApiName "shared_sharepointonline" `
        -OperationId "PostItem" `
        -Parameters @{
            dataset = $SiteUrl
            table = "Status Diario"
            "item/Title" = "@concat('STATUS-', ticks(utcNow()))"
            "item/StatusID" = "@concat('ST-', ticks(utcNow()))"
            "item/ProjectID" = "@triggerBody()?['ProjectID']"
            "item/DataRegistro" = "@utcNow()"
            "item/RAG/Value" = "@outputs('Normalize_RAG')"
            "item/Resumo" = "@outputs('Normalize_Resumo')"
            "item/Risco" = "@outputs('Normalize_Risco')"
            "item/Bloqueio" = "@outputs('Normalize_Bloqueio')"
            "item/ProximaAcao" = "@outputs('Normalize_ProximaAcao')"
            "item/Percentual" = "@if(empty(string(outputs('Normalize_Percentual'))), 0, int(outputs('Normalize_Percentual')))"
            "item/OrigemEntrada/Value" = "AdaptiveCard"
            "item/CardVersion" = "1.0"
        } `
        -RunAfter @{ Normalize_ProximaAcao = @("Succeeded") }
    Apply_to_each_Projeto = [ordered]@{
        type = "Foreach"
        foreach = "@body('Get_Projeto')?['value']"
        actions = [ordered]@{
            Update_Projeto = New-OpenApiAction `
                -ApiName "shared_sharepointonline" `
                -OperationId "PatchItem" `
                -Parameters @{
                    dataset = $SiteUrl
                    table = "Projetos"
                    id = "@items('Apply_to_each_Projeto')?['ID']"
                    "item/Title" = "@items('Apply_to_each_Projeto')?['Title']"
                    "item/ProjectID" = "@items('Apply_to_each_Projeto')?['ProjectID']"
                    "item/NomeProjeto" = "@items('Apply_to_each_Projeto')?['NomeProjeto']"
                    "item/StatusRAG/Value" = "@outputs('Normalize_RAG')"
                    "item/Percentual" = "@if(empty(string(outputs('Normalize_Percentual'))), 0, int(outputs('Normalize_Percentual')))"
                    "item/UltimaAtualizacao" = "@utcNow()"
                }
        }
        runAfter = [ordered]@{ Create_Status_Diario = @("Succeeded") }
    }
    Response_OK = [ordered]@{
        type = "Response"
        kind = "Skills"
        inputs = [ordered]@{
            statusCode = 200
            headers = [ordered]@{ "Content-Type" = "application/json" }
            body = [ordered]@{
                success = $true
                message = "Check-in response captured and written to SharePoint."
                projectId = "@{triggerBody()?['ProjectID']}"
                statusRAG = "@{outputs('Normalize_RAG')}"
            }
        }
        runAfter = [ordered]@{ Apply_to_each_Projeto = @("Succeeded") }
    }
}

$enviarDefinition = New-WorkflowDefinition -Triggers $enviarLive.Internal.properties.definition.triggers -Actions $enviarActions
$onDemandDefinition = New-WorkflowDefinition -Triggers $onDemandLive.Internal.properties.definition.triggers -Actions $onDemandActions

$results = @()
Write-Host "Patching PMO_PA_EnviarCheckInDiario..."
$results += Invoke-FlowPatch -FlowName $enviarFlowName -DisplayName "PMO_PA_EnviarCheckInDiario" -Definition $enviarDefinition
Write-Host "Patching PMO_PA_CheckInOnDemand..."
$results += Invoke-FlowPatch -FlowName $onDemandFlowName -DisplayName "PMO_PA_CheckInOnDemand" -Definition $onDemandDefinition

$disableResult = [ordered]@{
    FlowName = $processarFlowName
    DisplayName = "PMO_PA_ProcessarRespostaCheckIn"
    Disabled = $false
    Error = $null
}

try {
    Write-Host "Disabling PMO_PA_ProcessarRespostaCheckIn..."
    Disable-Flow -EnvironmentName $EnvironmentName -FlowName $processarFlowName -ErrorAction Stop
    $disableResult.Disabled = $true
}
catch {
    $disableResult.Error = $_.Exception.Message
    try {
        Disable-AdminFlow -EnvironmentName $EnvironmentName -FlowName $processarFlowName -ErrorAction Stop
        $disableResult.Disabled = $true
        $disableResult.Error = $null
    }
    catch {
        $disableResult.Error = $_.Exception.Message
    }
}

$summary = [ordered]@{
    Patched = $results
    DisabledReferenceFlow = $disableResult
}

$summary | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $EvidenceDir "g2_redesign_patch_summary.json") -Encoding UTF8
$summary
