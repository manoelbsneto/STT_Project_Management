param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$TeamsGroupId = "96c5b0c4-46cc-46cd-8695-50451db74994",
    [string]$TeamsChannelId = "19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2",
    [string]$FallbackEmail = "mbenicios@minsait.com",
    [string]$EvidenceDir = ".planning\comms"
)

$ErrorActionPreference = "Stop"

$adminModule = "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1"
$powerAppsModule = "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"

Import-Module $adminModule -ErrorAction Stop
Import-Module $powerAppsModule -ErrorAction Stop

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

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
        [hashtable]$RunAfter = @{}
    )

    [ordered]@{
        type = "OpenApiConnection"
        inputs = [ordered]@{
            parameters = $Parameters
            host = [ordered]@{
                apiId = "/providers/Microsoft.PowerApps/apis/$ApiName"
                connectionName = $ApiName
                operationId = $OperationId
            }
            authentication = "@parameters('$authentication')"
        }
        runAfter = $RunAfter
    }
}

function New-TeamsCardAction {
    param(
        [string]$CardJson,
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
            "body/messageBody" = $CardJson
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

    $requestPath = Join-Path $EvidenceDir "processsimple_patch_request_$FlowName.json"
    $resultPath = Join-Path $EvidenceDir "processsimple_patch_result_$FlowName.json"

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

$processarFlowName = "6c8ae320-46e0-42da-bc05-5d5a9622be03"
$alertaFlowName = "5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd"

$processarLive = Get-Flow -EnvironmentName $EnvironmentName -FlowName $processarFlowName -ErrorAction Stop
$alertaLive = Get-Flow -EnvironmentName $EnvironmentName -FlowName $alertaFlowName -ErrorAction Stop

$alertCardFromCheckIn = @'
{"type":"message","attachments":[{"contentType":"application/vnd.microsoft.card.adaptive","contentUrl":null,"content":{"$schema":"http://adaptivecards.io/schemas/adaptive-card.json","type":"AdaptiveCard","version":"1.4","body":[{"type":"TextBlock","text":"ALERTA - Projeto Critico","weight":"Bolder","size":"Medium","color":"Attention"},{"type":"FactSet","facts":[{"title":"ProjectID","value":"@{outputs('Normalize_ProjectID')}"},{"title":"Status","value":"@{outputs('Normalize_RAG')}"},{"title":"Percentual","value":"@{outputs('Normalize_Percentual')}%"},{"title":"Resumo","value":"@{outputs('Normalize_Resumo')}"},{"title":"Risco","value":"@{outputs('Normalize_Risco')}"},{"title":"Bloqueio","value":"@{outputs('Normalize_Bloqueio')}"}]}]}}]}
'@

$alertCardFromProjeto = @'
{"type":"message","attachments":[{"contentType":"application/vnd.microsoft.card.adaptive","contentUrl":null,"content":{"$schema":"http://adaptivecards.io/schemas/adaptive-card.json","type":"AdaptiveCard","version":"1.4","body":[{"type":"TextBlock","text":"ALERTA - Projeto Critico","weight":"Bolder","size":"Medium","color":"Attention"},{"type":"FactSet","facts":[{"title":"ProjectID","value":"@{coalesce(body('Get_Projeto_Detalhes')?['ProjectID'], triggerBody()?['ProjectID'], '-')}"},{"title":"Projeto","value":"@{coalesce(body('Get_Projeto_Detalhes')?['NomeProjeto'], body('Get_Projeto_Detalhes')?['Nome'], triggerBody()?['NomeProjeto'], triggerBody()?['Nome'], '-')}"},{"title":"Status","value":"Vermelho"},{"title":"Percentual","value":"@{coalesce(string(body('Get_Projeto_Detalhes')?['Percentual']), string(triggerBody()?['Percentual']), '0')}%"},{"title":"Ultima Atualizacao","value":"@{coalesce(string(body('Get_Projeto_Detalhes')?['UltimaAtualizacao']), string(triggerBody()?['UltimaAtualizacao']), '-')}"},{"title":"Data Alvo","value":"@{coalesce(string(body('Get_Projeto_Detalhes')?['DataAlvo']), string(triggerBody()?['DataAlvo']), '-')}"}]}]}}]}
'@

$processarActions = [ordered]@{
    Normalize_ProjectID = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(triggerBody()?['projectId'], triggerBody()?['ProjectID'], triggerBody()?['data']?['projectId'], triggerBody()?['data']?['ProjectID'], '')"
        runAfter = [ordered]@{}
    }
    Normalize_RAG = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(triggerBody()?['statusRAG'], triggerBody()?['StatusRAG'], triggerBody()?['RAG'], triggerBody()?['data']?['statusRAG'], triggerBody()?['data']?['StatusRAG'], 'Verde')"
        runAfter = [ordered]@{ Normalize_ProjectID = @("Succeeded") }
    }
    Normalize_Resumo = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(triggerBody()?['resumo'], triggerBody()?['Resumo'], triggerBody()?['data']?['resumo'], triggerBody()?['data']?['Resumo'], 'Sem resumo informado')"
        runAfter = [ordered]@{ Normalize_RAG = @("Succeeded") }
    }
    Normalize_Risco = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(triggerBody()?['risco'], triggerBody()?['Risco'], triggerBody()?['data']?['risco'], triggerBody()?['data']?['Risco'], '')"
        runAfter = [ordered]@{ Normalize_Resumo = @("Succeeded") }
    }
    Normalize_Bloqueio = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(triggerBody()?['bloqueio'], triggerBody()?['Bloqueio'], triggerBody()?['Bloqueios'], triggerBody()?['data']?['bloqueio'], triggerBody()?['data']?['Bloqueio'], triggerBody()?['data']?['Bloqueios'], '')"
        runAfter = [ordered]@{ Normalize_Risco = @("Succeeded") }
    }
    Normalize_ProximaAcao = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(triggerBody()?['proximaAcao'], triggerBody()?['ProximaAcao'], triggerBody()?['data']?['proximaAcao'], triggerBody()?['data']?['ProximaAcao'], '')"
        runAfter = [ordered]@{ Normalize_Bloqueio = @("Succeeded") }
    }
    Normalize_Percentual = [ordered]@{
        type = "Compose"
        inputs = "@coalesce(triggerBody()?['percentual'], triggerBody()?['Percentual'], triggerBody()?['data']?['percentual'], triggerBody()?['data']?['Percentual'], 0)"
        runAfter = [ordered]@{ Normalize_ProximaAcao = @("Succeeded") }
    }
    Get_Projeto = New-OpenApiAction `
        -ApiName "shared_sharepointonline" `
        -OperationId "GetItems" `
        -Parameters @{
            dataset = $SiteUrl
            table = "Projetos"
            '$filter' = "ProjectID eq '@{outputs('Normalize_ProjectID')}'"
            '$top' = 1
        } `
        -RunAfter @{ Normalize_Percentual = @("Succeeded") }
    Create_Status_Diario = New-OpenApiAction `
        -ApiName "shared_sharepointonline" `
        -OperationId "PostItem" `
        -Parameters @{
            dataset = $SiteUrl
            table = "Status Diario"
            "item/Title" = "@concat('STATUS-', ticks(utcNow()))"
            "item/StatusID" = "@concat('ST-', ticks(utcNow()))"
            "item/ProjectID" = "@outputs('Normalize_ProjectID')"
            "item/DataRegistro" = "@utcNow()"
            "item/RAG/Value" = "@outputs('Normalize_RAG')"
            "item/Resumo" = "@outputs('Normalize_Resumo')"
            "item/Risco" = "@outputs('Normalize_Risco')"
            "item/Bloqueio" = "@outputs('Normalize_Bloqueio')"
            "item/ProximaAcao" = "@outputs('Normalize_ProximaAcao')"
            "item/Percentual" = "@if(empty(string(outputs('Normalize_Percentual'))), 0, int(outputs('Normalize_Percentual')))"
            "item/OrigemEntrada/Value" = "AdaptiveCard"
            "item/CardVersion" = "@coalesce(triggerBody()?['cardVersion'], triggerBody()?['data']?['cardVersion'], '1.0')"
        } `
        -RunAfter @{ Get_Projeto = @("Succeeded") }
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
                    "item/NomeProjeto" = "@coalesce(items('Apply_to_each_Projeto')?['NomeProjeto'], items('Apply_to_each_Projeto')?['Nome'])"
                    "item/StatusRAG/Value" = "@outputs('Normalize_RAG')"
                    "item/Percentual" = "@if(empty(string(outputs('Normalize_Percentual'))), 0, int(outputs('Normalize_Percentual')))"
                    "item/UltimaAtualizacao" = "@utcNow()"
                }
        }
        runAfter = [ordered]@{ Create_Status_Diario = @("Succeeded") }
    }
    Condition_RAG_Vermelho = [ordered]@{
        type = "If"
        expression = [ordered]@{
            equals = @("@outputs('Normalize_RAG')", "Vermelho")
        }
        actions = [ordered]@{
            Post_Alerta_Critico_Teams = New-TeamsCardAction -CardJson $alertCardFromCheckIn
            Send_Email_Sponsor = New-EmailAction `
                -To "@coalesce(first(body('Get_Projeto')?['value'])?['Sponsor']?['Email'], '$FallbackEmail')" `
                -Subject "ALERTA: Projeto @{outputs('Normalize_ProjectID')} em status Vermelho" `
                -Body "<p>Projeto @{outputs('Normalize_ProjectID')} informado como Vermelho.</p><p><b>Resumo:</b> @{outputs('Normalize_Resumo')}</p><p><b>Risco:</b> @{outputs('Normalize_Risco')}</p><p><b>Bloqueio:</b> @{outputs('Normalize_Bloqueio')}</p>" `
                -RunAfter @{ Post_Alerta_Critico_Teams = @("Succeeded") }
        }
        else = [ordered]@{
            actions = [ordered]@{}
        }
        runAfter = [ordered]@{ Apply_to_each_Projeto = @("Succeeded") }
    }
}

$alertaActions = [ordered]@{
    Condition_Status_Vermelho = [ordered]@{
        type = "If"
        expression = [ordered]@{
            equals = @("@coalesce(triggerBody()?['StatusRAG']?['Value'], triggerBody()?['StatusRAG'], triggerBody()?['StatusRAG']?['Label'])", "Vermelho")
        }
        actions = [ordered]@{
            Get_Projeto_Detalhes = New-OpenApiAction `
                -ApiName "shared_sharepointonline" `
                -OperationId "GetItem" `
                -Parameters @{
                    dataset = $SiteUrl
                    table = "Projetos"
                    id = "@triggerBody()?['ID']"
                }
            Post_Alerta_Critico_Teams = New-TeamsCardAction `
                -CardJson $alertCardFromProjeto `
                -RunAfter @{ Get_Projeto_Detalhes = @("Succeeded") }
            Send_Email_Sponsor = New-EmailAction `
                -To "@coalesce(body('Get_Projeto_Detalhes')?['Sponsor']?['Email'], triggerBody()?['Sponsor']?['Email'], '$FallbackEmail')" `
                -Subject "ALERTA: Projeto @{coalesce(body('Get_Projeto_Detalhes')?['NomeProjeto'], body('Get_Projeto_Detalhes')?['Nome'], triggerBody()?['NomeProjeto'], triggerBody()?['Nome'], triggerBody()?['ProjectID'])} em status Vermelho" `
                -Body "<p>O projeto foi classificado como Vermelho e requer atencao imediata.</p><p><b>ProjectID:</b> @{coalesce(body('Get_Projeto_Detalhes')?['ProjectID'], triggerBody()?['ProjectID'])}</p><p><b>Percentual:</b> @{coalesce(string(body('Get_Projeto_Detalhes')?['Percentual']), string(triggerBody()?['Percentual']), '0')}%</p>" `
                -RunAfter @{ Post_Alerta_Critico_Teams = @("Succeeded") }
        }
        else = [ordered]@{
            actions = [ordered]@{}
        }
        runAfter = [ordered]@{}
    }
}

$processarDefinition = New-WorkflowDefinition -Triggers $processarLive.Internal.properties.definition.triggers -Actions $processarActions
$alertaDefinition = New-WorkflowDefinition -Triggers $alertaLive.Internal.properties.definition.triggers -Actions $alertaActions

$results = @()
$results += Invoke-FlowPatch -FlowName $processarFlowName -DisplayName "PMO_PA_ProcessarRespostaCheckIn" -Definition $processarDefinition
$results += Invoke-FlowPatch -FlowName $alertaFlowName -DisplayName "PMO_PA_AlertaProjetoVermelho" -Definition $alertaDefinition

$results | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath (Join-Path $EvidenceDir "g2_wiring_patch_summary.json") -Encoding UTF8
$results
