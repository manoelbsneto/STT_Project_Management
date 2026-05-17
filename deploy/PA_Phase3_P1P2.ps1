[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$EnvironmentDisplayName = "ColOfertasBrasilPro",
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$TeamsGroupId = "96c5b0c4-46cc-46cd-8695-50451db74994",
    [string]$TeamsChannelId = "19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2",
    [string]$PmoLeadEmail = "mbenicios@minsait.com",
    [string]$SharePointConnectionName = "44f187cde7f54f208cf22bac4e533816",
    [string]$TeamsConnectionName = "shared-teams-1440d346-f1dd-44ea-912f-3787038ac333",
    [string]$OutlookConnectionName = "306d783533364cb6948ab2830fc3b188",
    [string]$PlannerConnectionName = "6b763b98729c4d99a7a8df4033d381af",
    [string]$EvidenceDir = ".planning\comms",
    [switch]$BuildOnly
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$cardsDir = Join-Path $repoRoot "deploy\cards"
$evidenceRoot = Join-Path $repoRoot $EvidenceDir
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

$adminModule = "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1"
$powerAppsModule = "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"

Import-Module $adminModule -ErrorAction Stop
Import-Module $powerAppsModule -ErrorAction Stop

function Save-Json {
    param([object]$Data, [string]$Path, [int]$Depth = 100)
    $Data | ConvertTo-Json -Depth $Depth | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Escape-WorkflowLiteral {
    param([string]$Value)
    $Value.Replace("'", "''")
}

function Read-CardTemplate {
    param([string]$FileName)
    $path = Join-Path $cardsDir $FileName
    $raw = Get-Content -LiteralPath $path -Raw
    $parsed = $raw | ConvertFrom-Json
    [pscustomobject]@{
        Path = $path
        Raw = $raw
        Compressed = ($parsed | ConvertTo-Json -Depth 100 -Compress)
        Bytes = [System.Text.Encoding]::UTF8.GetByteCount($raw)
        Schema = $parsed.'$schema'
        Type = $parsed.type
        Version = $parsed.version
        Under27KB = ([System.Text.Encoding]::UTF8.GetByteCount($raw) -lt 27648)
    }
}

function New-ReplaceExpression {
    param(
        [string]$Template,
        [System.Collections.IDictionary]$Map
    )

    $expression = "'" + (Escape-WorkflowLiteral $Template) + "'"
    foreach ($key in $Map.Keys) {
        $escapedKey = Escape-WorkflowLiteral $key
        $expression = "replace($expression, '$escapedKey', $($Map[$key]))"
    }
    "@$expression"
}

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
        [string]$ActionType = "OpenApiConnection",
        [hashtable]$Limit = $null
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
            authentication = "@parameters('`$authentication')"
        }
        runAfter = $RunAfter
    }

    if ($Limit) {
        $action.limit = $Limit
    }

    $action
}

function New-SharePointCreatedTrigger {
    param([string]$ListName)

    [ordered]@{
        recurrence = [ordered]@{
            frequency = "Minute"
            interval = 1
        }
        splitOn = "@triggerOutputs()?['body/value']"
        type = "OpenApiConnection"
        inputs = [ordered]@{
            parameters = [ordered]@{
                dataset = $SiteUrl
                table = $ListName
            }
            host = [ordered]@{
                apiId = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
                connectionName = "shared_sharepointonline"
                operationId = "GetOnNewItems"
            }
            authentication = "@parameters('`$authentication')"
        }
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

    New-OpenApiAction -ApiName "shared_sharepointonline" -OperationId "GetItems" -Parameters $parameters -RunAfter $RunAfter
}

function New-SharePointGetItem {
    param(
        [string]$ListName,
        [string]$Id,
        [hashtable]$RunAfter = @{}
    )

    New-OpenApiAction `
        -ApiName "shared_sharepointonline" `
        -OperationId "GetItem" `
        -Parameters @{
            dataset = $SiteUrl
            table = $ListName
            id = $Id
        } `
        -RunAfter $RunAfter
}

function New-SharePointPatchItem {
    param(
        [string]$ListName,
        [hashtable]$Parameters,
        [hashtable]$RunAfter = @{}
    )

    $base = @{
        dataset = $SiteUrl
        table = $ListName
    }
    foreach ($key in $Parameters.Keys) {
        $base[$key] = $Parameters[$key]
    }

    New-OpenApiAction -ApiName "shared_sharepointonline" -OperationId "PatchItem" -Parameters $base -RunAfter $RunAfter
}

function New-TeamsPostCard {
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

function New-TeamsWaitCard {
    param(
        [string]$CardExpression,
        [hashtable]$RunAfter = @{}
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
            "body/body/updateMessage" = "Resposta registrada no Hub PMO."
        } `
        -RunAfter $RunAfter `
        -ActionType "OpenApiConnectionWebhook" `
        -Limit @{ timeout = "P28D" }
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

function New-PlannerListTasks {
    param([hashtable]$RunAfter = @{})

    New-OpenApiAction `
        -ApiName "shared_planner" `
        -OperationId "ListTasks_V3" `
        -Parameters @{
            groupId = "@items('Apply_to_each_Projeto_Planner')?['PlannerGroupId']"
            id = "@items('Apply_to_each_Projeto_Planner')?['PlannerPlanId']"
        } `
        -RunAfter $RunAfter
}

function New-ConnectionReferences {
    [ordered]@{
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
        shared_planner = [ordered]@{
            connectionName = $PlannerConnectionName
            connectionReferenceLogicalName = "pmo_planner"
            source = "Invoker"
            id = "/providers/Microsoft.PowerApps/apis/shared_planner"
            displayName = "Planner"
            tier = "Standard"
            apiName = "planner"
            isProcessSimpleApiReferenceConversionAlreadyDone = $false
        }
    }
}

function New-FlowPayload {
    param([string]$DisplayName, [object]$Definition, [string]$FlowName = $null)

    if (-not $FlowName) {
        $FlowName = [guid]::NewGuid().ToString()
    }

    [ordered]@{
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
            if ($attempt -ge $Attempts) {
                throw
            }
            Write-Warning "$Operation failed on attempt $attempt/${Attempts}: $($_.Exception.Message). Retrying in $DelaySeconds seconds."
            Start-Sleep -Seconds $DelaySeconds
        }
    }

    if ($lastError) {
        throw $lastError
    }
}

function Get-FlowWithRetry {
    param(
        [string]$DisplayName,
        [string]$FlowName
    )

    Invoke-WithRetry -Operation "Get-Flow $DisplayName" -Attempts 6 -DelaySeconds 8 -ScriptBlock {
        $flow = $null
        if ($FlowName) {
            try {
                $flow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $FlowName -ErrorAction Stop
            }
            catch {
                $flow = $null
            }
        }

        if (-not $flow) {
            $flow = Get-ExistingFlowByDisplayName -DisplayName $DisplayName
        }

        if (-not $flow) {
            throw "Flow '$DisplayName' was not returned by Get-Flow yet."
        }

        if (-not $flow.Internal -or -not $flow.Internal.properties -or -not $flow.Internal.properties.definition) {
            throw "Flow '$DisplayName' was returned without an exported workflow definition."
        }

        $flow
    }
}

function Set-ProcessSimpleFlow {
    param([string]$DisplayName, [object]$Definition)

    $existing = Invoke-WithRetry -Operation "Get existing flow $DisplayName" -Attempts 4 -DelaySeconds 8 -ScriptBlock {
        Get-ExistingFlowByDisplayName -DisplayName $DisplayName
    }
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

    $payload = New-FlowPayload -DisplayName $DisplayName -Definition $Definition -FlowName $flowName
    $requestPath = Join-Path $evidenceRoot "processsimple_phase3_request_$($payload.name).json"
    $resultPath = Join-Path $evidenceRoot "processsimple_phase3_result_$($payload.name).json"
    Save-Json -Data $payload -Path $requestPath

    $result = Invoke-WithRetry -Operation "$method ProcessSimple $DisplayName" -Attempts 4 -DelaySeconds 12 -ScriptBlock {
        InvokeApi -Method $method -Route $route -Body $payload -ApiVersion "2016-11-01" -ThrowOnFailure
    }
    Save-Json -Data $result -Path $resultPath

    Start-Sleep -Seconds 5
    $createdName = if ($result.name) { $result.name } else { $payload.name }
    $flow = Get-FlowWithRetry -DisplayName $DisplayName -FlowName $createdName
    $definitionPath = Join-Path $evidenceRoot "flow_definition_PHASE3_$($DisplayName)_$createdName.json"
    $summaryPath = Join-Path $evidenceRoot "flow_summary_PHASE3_$($DisplayName)_$createdName.json"
    Save-Json -Data $flow.Internal.properties.definition -Path $definitionPath

    $summary = [pscustomobject]@{
        displayName = $DisplayName
        flowName = $createdName
        status = $status
        state = $flow.Internal.properties.state
        enabled = $flow.Enabled
        triggerNames = @($flow.Internal.properties.definition.triggers.PSObject.Properties.Name)
        actionNames = @($flow.Internal.properties.definition.actions.PSObject.Properties.Name)
        connectorApis = @($flow.Internal.properties.connectionReferences.PSObject.Properties.Name)
        request = $requestPath
        result = $resultPath
        definition = $definitionPath
    }
    Save-Json -Data $summary -Path $summaryPath
    $summary
}

$cardResumoDiario = Read-CardTemplate "ResumoDiarioBoard.json"
$cardResumoSemanal = Read-CardTemplate "ResumoSemanal.json"
$cardEscalacaoRisco = Read-CardTemplate "EscalacaoRisco.json"
$cardDecisao = Read-CardTemplate "DecisaoBoard.json"

$cardValidation = @($cardResumoDiario, $cardResumoSemanal, $cardEscalacaoRisco, $cardDecisao) |
    Select-Object Path, Bytes, Schema, Type, Version, Under27KB

if (@($cardValidation | Where-Object { $_.Version -ne "1.4" -or -not $_.Under27KB }).Count -gt 0) {
    throw "Adaptive card validation failed. All Phase 3 cards must be schema v1.4 and under 27KB."
}

$hubUrl = "$SiteUrl/Lists/Projetos/AllItems.aspx"
$riskListUrl = "$SiteUrl/Lists/Riscos%20e%20Bloqueios/AllItems.aspx"

$dailyCardExpression = New-ReplaceExpression -Template $cardResumoDiario.Compressed -Map ([ordered]@{
    '${DataReferencia}' = "formatDateTime(convertTimeZone(utcNow(), 'UTC', 'E. South America Standard Time'), 'dd/MM/yyyy HH:mm')"
    '${TotalProjetos}' = "string(outputs('Count_Total'))"
    '${Verdes}' = "string(outputs('Count_Verdes'))"
    '${Amarelos}' = "string(outputs('Count_Amarelos'))"
    '${Vermelhos}' = "string(outputs('Count_Vermelhos'))"
    '${SemUpdateCount}' = "string(outputs('Count_Sem_Update'))"
    '${ProjetosSemUpdate}' = "outputs('Compose_Projetos_Sem_Update')"
    '${DecisoesPendentesCount}' = "string(outputs('Count_Decisoes_Pendentes'))"
    '${DecisoesPendentes}' = "outputs('Compose_Decisoes_Pendentes')"
    '${HubUrl}' = "'$hubUrl'"
})

$weeklyCardExpression = New-ReplaceExpression -Template $cardResumoSemanal.Compressed -Map ([ordered]@{
    '${Periodo}' = "concat(formatDateTime(addDays(utcNow(), -7), 'dd/MM/yyyy'), ' - ', formatDateTime(utcNow(), 'dd/MM/yyyy'))"
    '${TotalProjetos}' = "string(outputs('Count_Total'))"
    '${Verdes}' = "string(outputs('Count_Verdes'))"
    '${Amarelos}' = "string(outputs('Count_Amarelos'))"
    '${Vermelhos}' = "string(outputs('Count_Vermelhos'))"
    '${SemUpdateCount}' = "string(outputs('Count_Sem_Update'))"
    '${StatusSemanaCount}' = "string(outputs('Count_Status_Semana'))"
    '${DecisoesSemanaCount}' = "string(outputs('Count_Decisoes_Semana'))"
    '${AtrasadosCount}' = "string(outputs('Count_Atrasados'))"
    '${ProjetosSemUpdate}' = "outputs('Compose_Projetos_Sem_Update')"
    '${ProjetosAtrasados}' = "outputs('Compose_Projetos_Atrasados')"
    '${DecisoesSemana}' = "outputs('Compose_Decisoes_Semana')"
    '${HubUrl}' = "'$hubUrl'"
})

$riskCardExpression = New-ReplaceExpression -Template $cardEscalacaoRisco.Compressed -Map ([ordered]@{
    '${RiskID}' = "coalesce(body('Get_Risco_Detalhes')?['RiskID'], triggerBody()?['RiskID'], '-')"
    '${ProjectID}' = "coalesce(body('Get_Risco_Detalhes')?['ProjectID'], triggerBody()?['ProjectID'], '-')"
    '${ProjectName}' = "coalesce(first(body('Get_Projeto')?['value'])?['NomeProjeto'], first(body('Get_Projeto')?['value'])?['Title'], '-')"
    '${Tipo}' = "coalesce(body('Get_Risco_Detalhes')?['Tipo']?['Value'], body('Get_Risco_Detalhes')?['Tipo'], '-')"
    '${Severidade}' = "coalesce(body('Get_Risco_Detalhes')?['Severidade']?['Value'], body('Get_Risco_Detalhes')?['Severidade'], '-')"
    '${Impacto}' = "coalesce(body('Get_Risco_Detalhes')?['Impacto']?['Value'], body('Get_Risco_Detalhes')?['Impacto'], '-')"
    '${Owner}' = "coalesce(body('Get_Risco_Detalhes')?['Owner']?['DisplayName'], body('Get_Risco_Detalhes')?['Owner']?['Email'], '-')"
    '${SLA}' = "coalesce(string(body('Get_Risco_Detalhes')?['SLA']), '-')"
    '${Descricao}' = "coalesce(body('Get_Risco_Detalhes')?['Descricao'], '-')"
    '${PlanoMitigacao}' = "coalesce(body('Get_Risco_Detalhes')?['PlanoMitigacao'], 'Nao informado')"
    '${RiskListUrl}' = "'$riskListUrl'"
})

$decisionCardExpression = New-ReplaceExpression -Template $cardDecisao.Compressed -Map ([ordered]@{
    '${DecisionID}' = "coalesce(body('Get_Decisao_Detalhes')?['DecisionID'], triggerBody()?['DecisionID'], '-')"
    '${ProjectName}' = "coalesce(body('Get_Decisao_Detalhes')?['ProjectID'], triggerBody()?['ProjectID'], '-')"
    '${Solicitante}' = "coalesce(body('Get_Decisao_Detalhes')?['Solicitante']?['DisplayName'], body('Get_Decisao_Detalhes')?['Solicitante']?['Email'], '-')"
    '${Prazo}' = "coalesce(string(body('Get_Decisao_Detalhes')?['Prazo']), '-')"
    '${Impacto}' = "coalesce(body('Get_Decisao_Detalhes')?['Impacto']?['Value'], body('Get_Decisao_Detalhes')?['Impacto'], '-')"
    '${Descricao}' = "coalesce(body('Get_Decisao_Detalhes')?['Descricao'], '-')"
})

function New-PortfolioSummaryActions {
    param(
        [string]$PostCardExpression,
        [string]$DecisionActionName,
        [string]$DecisionFilter,
        [bool]$IncludeWeeklyStatus = $false
    )

    $actions = [ordered]@{
        Get_Projetos_Ativos = New-SharePointGetItems -ListName "Projetos" -Filter "Ativo eq 1 and Deleted eq 0" -Top 200
        Filter_Verdes = [ordered]@{
            type = "Query"
            inputs = [ordered]@{
                from = "@body('Get_Projetos_Ativos')?['value']"
                where = "@equals(coalesce(item()?['StatusRAG']?['Value'], item()?['StatusRAG']), 'Verde')"
            }
            runAfter = [ordered]@{ Get_Projetos_Ativos = @("Succeeded") }
        }
        Filter_Amarelos = [ordered]@{
            type = "Query"
            inputs = [ordered]@{
                from = "@body('Get_Projetos_Ativos')?['value']"
                where = "@equals(coalesce(item()?['StatusRAG']?['Value'], item()?['StatusRAG']), 'Amarelo')"
            }
            runAfter = [ordered]@{ Filter_Verdes = @("Succeeded") }
        }
        Filter_Vermelhos = [ordered]@{
            type = "Query"
            inputs = [ordered]@{
                from = "@body('Get_Projetos_Ativos')?['value']"
                where = "@equals(coalesce(item()?['StatusRAG']?['Value'], item()?['StatusRAG']), 'Vermelho')"
            }
            runAfter = [ordered]@{ Filter_Amarelos = @("Succeeded") }
        }
        Filter_Projetos_Sem_Update = [ordered]@{
            type = "Query"
            inputs = [ordered]@{
                from = "@body('Get_Projetos_Ativos')?['value']"
                where = "@lessOrEquals(coalesce(item()?['UltimaAtualizacao'], '1900-01-01T00:00:00Z'), addDays(utcNow(), -1))"
            }
            runAfter = [ordered]@{ Filter_Vermelhos = @("Succeeded") }
        }
        Select_Projetos_Sem_Update = [ordered]@{
            type = "Select"
            inputs = [ordered]@{
                from = "@body('Filter_Projetos_Sem_Update')"
                select = "@concat('- ', item()?['ProjectID'], ' | ', coalesce(item()?['NomeProjeto'], item()?['Title'], '-'), ' | Ultima: ', coalesce(string(item()?['UltimaAtualizacao']), '-'))"
            }
            runAfter = [ordered]@{ Filter_Projetos_Sem_Update = @("Succeeded") }
        }
        Compose_Projetos_Sem_Update = [ordered]@{
            type = "Compose"
            inputs = "@if(equals(length(body('Select_Projetos_Sem_Update')), 0), 'Nenhum projeto atrasado no check-in.', join(body('Select_Projetos_Sem_Update'), '\n'))"
            runAfter = [ordered]@{ Select_Projetos_Sem_Update = @("Succeeded") }
        }
        Get_Decisoes = New-SharePointGetItems -ListName "Decisoes do Board" -Filter $DecisionFilter -Top 100 -RunAfter @{ Compose_Projetos_Sem_Update = @("Succeeded") }
        Select_Decisoes = [ordered]@{
            type = "Select"
            inputs = [ordered]@{
                from = "@body('Get_Decisoes')?['value']"
                select = "@concat('- ', item()?['DecisionID'], ' | ', item()?['ProjectID'], ' | ', coalesce(item()?['Descricao'], '-'))"
            }
            runAfter = [ordered]@{ Get_Decisoes = @("Succeeded") }
        }
        $DecisionActionName = [ordered]@{
            type = "Compose"
            inputs = "@if(equals(length(body('Select_Decisoes')), 0), 'Nenhuma decisao no criterio do resumo.', join(body('Select_Decisoes'), '\n'))"
            runAfter = [ordered]@{ Select_Decisoes = @("Succeeded") }
        }
        Count_Total = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Get_Projetos_Ativos')?['value'])"
            runAfter = [ordered]@{ $DecisionActionName = @("Succeeded") }
        }
        Count_Verdes = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Filter_Verdes'))"
            runAfter = [ordered]@{ Count_Total = @("Succeeded") }
        }
        Count_Amarelos = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Filter_Amarelos'))"
            runAfter = [ordered]@{ Count_Verdes = @("Succeeded") }
        }
        Count_Vermelhos = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Filter_Vermelhos'))"
            runAfter = [ordered]@{ Count_Amarelos = @("Succeeded") }
        }
        Count_Sem_Update = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Filter_Projetos_Sem_Update'))"
            runAfter = [ordered]@{ Count_Vermelhos = @("Succeeded") }
        }
    }

    if ($IncludeWeeklyStatus) {
        $actions.Get_Status_Semana = New-SharePointGetItems -ListName "Status Diario" -Filter "DataRegistro ge '@{addDays(utcNow(),-7)}' and Deleted eq 0" -Top 500 -RunAfter @{ Count_Sem_Update = @("Succeeded") }
        $actions.Filter_Projetos_Atrasados = [ordered]@{
            type = "Query"
            inputs = [ordered]@{
                from = "@body('Get_Projetos_Ativos')?['value']"
                where = "@and(not(empty(item()?['DataAlvo'])), less(item()?['DataAlvo'], utcNow()))"
            }
            runAfter = [ordered]@{ Get_Status_Semana = @("Succeeded") }
        }
        $actions.Select_Projetos_Atrasados = [ordered]@{
            type = "Select"
            inputs = [ordered]@{
                from = "@body('Filter_Projetos_Atrasados')"
                select = "@concat('- ', item()?['ProjectID'], ' | ', coalesce(item()?['NomeProjeto'], item()?['Title'], '-'), ' | Alvo: ', coalesce(string(item()?['DataAlvo']), '-'))"
            }
            runAfter = [ordered]@{ Filter_Projetos_Atrasados = @("Succeeded") }
        }
        $actions.Compose_Projetos_Atrasados = [ordered]@{
            type = "Compose"
            inputs = "@if(equals(length(body('Select_Projetos_Atrasados')), 0), 'Nenhum projeto com data alvo vencida.', join(body('Select_Projetos_Atrasados'), '\n'))"
            runAfter = [ordered]@{ Select_Projetos_Atrasados = @("Succeeded") }
        }
        $actions.Count_Status_Semana = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Get_Status_Semana')?['value'])"
            runAfter = [ordered]@{ Compose_Projetos_Atrasados = @("Succeeded") }
        }
        $actions.Count_Decisoes_Semana = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Get_Decisoes')?['value'])"
            runAfter = [ordered]@{ Count_Status_Semana = @("Succeeded") }
        }
        $actions.Count_Atrasados = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Filter_Projetos_Atrasados'))"
            runAfter = [ordered]@{ Count_Decisoes_Semana = @("Succeeded") }
        }
        $actions.Post_Resumo_Semanal_Teams = New-TeamsPostCard -CardExpression $PostCardExpression -RunAfter @{ Count_Atrasados = @("Succeeded") }
    }
    else {
        $actions.Count_Decisoes_Pendentes = [ordered]@{
            type = "Compose"
            inputs = "@length(body('Get_Decisoes')?['value'])"
            runAfter = [ordered]@{ Count_Sem_Update = @("Succeeded") }
        }
        $actions.Post_Resumo_Diario_Teams = New-TeamsPostCard -CardExpression $PostCardExpression -RunAfter @{ Count_Decisoes_Pendentes = @("Succeeded") }
    }

    $actions
}

$flowDefinitions = [ordered]@{}

$flowDefinitions["PMO_PA_ResumoDiarioBoard"] = New-WorkflowDefinition `
    -Triggers ([ordered]@{
        Recurrence_17h_BRT = [ordered]@{
            recurrence = [ordered]@{
                frequency = "Day"
                interval = 1
                timeZone = "E. South America Standard Time"
                schedule = [ordered]@{ hours = @(17); minutes = @(0) }
            }
            type = "Recurrence"
        }
    }) `
    -Actions (New-PortfolioSummaryActions -PostCardExpression $dailyCardExpression -DecisionActionName "Compose_Decisoes_Pendentes" -DecisionFilter "StatusDecisao eq 'Pendente' and Deleted eq 0")

$flowDefinitions["PMO_PA_RegistrarDecisaoBoard"] = New-WorkflowDefinition `
    -Triggers ([ordered]@{ When_Decisao_Created = New-SharePointCreatedTrigger -ListName "Decisoes do Board" }) `
    -Actions ([ordered]@{
        Get_Decisao_Detalhes = New-SharePointGetItem -ListName "Decisoes do Board" -Id "@triggerBody()?['ID']"
        Post_Decision_Card_Wait_Response = New-TeamsWaitCard -CardExpression $decisionCardExpression -RunAfter @{ Get_Decisao_Detalhes = @("Succeeded") }
        Normalize_Decision_Status = [ordered]@{
            type = "Compose"
            inputs = "@coalesce(body('Post_Decision_Card_Wait_Response')?['data']?['resposta'], body('Post_Decision_Card_Wait_Response')?['resposta'], 'Adiada')"
            runAfter = [ordered]@{ Post_Decision_Card_Wait_Response = @("Succeeded") }
        }
        Normalize_Justificativa = [ordered]@{
            type = "Compose"
            inputs = "@coalesce(body('Post_Decision_Card_Wait_Response')?['data']?['justificativa'], body('Post_Decision_Card_Wait_Response')?['justificativa'], '')"
            runAfter = [ordered]@{ Normalize_Decision_Status = @("Succeeded") }
        }
        Update_Decisao_Board = New-SharePointPatchItem `
            -ListName "Decisoes do Board" `
            -Parameters @{
                id = "@body('Get_Decisao_Detalhes')?['ID']"
                "item/Title" = "@body('Get_Decisao_Detalhes')?['Title']"
                "item/DecisionID" = "@body('Get_Decisao_Detalhes')?['DecisionID']"
                "item/ProjectID" = "@body('Get_Decisao_Detalhes')?['ProjectID']"
                "item/Descricao" = "@body('Get_Decisao_Detalhes')?['Descricao']"
                "item/StatusDecisao/Value" = "@outputs('Normalize_Decision_Status')"
                "item/Resposta" = "@outputs('Normalize_Justificativa')"
                "item/Justificativa" = "@outputs('Normalize_Justificativa')"
                "item/DataResposta" = "@utcNow()"
                "item/ApproverUPN" = "@coalesce(body('Get_Decisao_Detalhes')?['Aprovador']?['Email'], '')"
                "item/ResponseSource/Value" = "AdaptiveCard"
                "item/CardVersion" = "1.0"
            } `
            -RunAfter @{ Normalize_Justificativa = @("Succeeded") }
    })

$flowDefinitions["PMO_PA_SyncPlannerStats_Standard"] = New-WorkflowDefinition `
    -Triggers ([ordered]@{
        Recurrence_Every_6h = [ordered]@{
            recurrence = [ordered]@{
                frequency = "Hour"
                interval = 6
            }
            type = "Recurrence"
        }
    }) `
    -Actions ([ordered]@{
        Get_Projetos_Ativos = New-SharePointGetItems -ListName "Projetos" -Filter "Ativo eq 1 and Deleted eq 0" -Top 200
        Filter_Projetos_Com_Planner = [ordered]@{
            type = "Query"
            inputs = [ordered]@{
                from = "@body('Get_Projetos_Ativos')?['value']"
                where = "@and(not(empty(item()?['PlannerPlanId'])), not(empty(item()?['PlannerGroupId'])))"
            }
            runAfter = [ordered]@{ Get_Projetos_Ativos = @("Succeeded") }
        }
        Apply_to_each_Projeto_Planner = [ordered]@{
            type = "Foreach"
            foreach = "@body('Filter_Projetos_Com_Planner')"
            runtimeConfiguration = [ordered]@{
                concurrency = [ordered]@{ repetitions = 1 }
            }
            actions = [ordered]@{
                List_Planner_Tasks = New-PlannerListTasks
                Filter_Tarefas_Concluidas = [ordered]@{
                    type = "Query"
                    inputs = [ordered]@{
                        from = "@body('List_Planner_Tasks')?['value']"
                        where = "@equals(coalesce(item()?['percentComplete'], 0), 100)"
                    }
                    runAfter = [ordered]@{ List_Planner_Tasks = @("Succeeded") }
                }
                Filter_Tarefas_Abertas = [ordered]@{
                    type = "Query"
                    inputs = [ordered]@{
                        from = "@body('List_Planner_Tasks')?['value']"
                        where = "@not(equals(coalesce(item()?['percentComplete'], 0), 100))"
                    }
                    runAfter = [ordered]@{ Filter_Tarefas_Concluidas = @("Succeeded") }
                }
                Filter_Tarefas_Atrasadas = [ordered]@{
                    type = "Query"
                    inputs = [ordered]@{
                        from = "@body('Filter_Tarefas_Abertas')"
                        where = "@and(not(empty(item()?['dueDateTime'])), less(item()?['dueDateTime'], utcNow()))"
                    }
                    runAfter = [ordered]@{ Filter_Tarefas_Abertas = @("Succeeded") }
                }
                Update_Projeto_Planner_OK = New-SharePointPatchItem `
                    -ListName "Projetos" `
                    -Parameters @{
                        id = "@items('Apply_to_each_Projeto_Planner')?['ID']"
                        "item/Title" = "@items('Apply_to_each_Projeto_Planner')?['Title']"
                        "item/ProjectID" = "@items('Apply_to_each_Projeto_Planner')?['ProjectID']"
                        "item/NomeProjeto" = "@items('Apply_to_each_Projeto_Planner')?['NomeProjeto']"
                        "item/TarefasTotal" = "@length(body('List_Planner_Tasks')?['value'])"
                        "item/TarefasAbertas" = "@length(body('Filter_Tarefas_Abertas'))"
                        "item/TarefasConcluidas" = "@length(body('Filter_Tarefas_Concluidas'))"
                        "item/TarefasAtrasadas" = "@length(body('Filter_Tarefas_Atrasadas'))"
                        "item/PlannerLastSyncAt" = "@utcNow()"
                        "item/PlannerSyncStatus/Value" = "OK"
                    } `
                    -RunAfter @{ Filter_Tarefas_Atrasadas = @("Succeeded") }
                Update_Projeto_Planner_Erro = New-SharePointPatchItem `
                    -ListName "Projetos" `
                    -Parameters @{
                        id = "@items('Apply_to_each_Projeto_Planner')?['ID']"
                        "item/Title" = "@items('Apply_to_each_Projeto_Planner')?['Title']"
                        "item/ProjectID" = "@items('Apply_to_each_Projeto_Planner')?['ProjectID']"
                        "item/NomeProjeto" = "@items('Apply_to_each_Projeto_Planner')?['NomeProjeto']"
                        "item/PlannerLastSyncAt" = "@utcNow()"
                        "item/PlannerSyncStatus/Value" = "Erro"
                    } `
                    -RunAfter @{ List_Planner_Tasks = @("Failed", "TimedOut") }
            }
            runAfter = [ordered]@{ Filter_Projetos_Com_Planner = @("Succeeded") }
        }
    })

$flowDefinitions["PMO_PA_EscalarRiscoCritico"] = New-WorkflowDefinition `
    -Triggers ([ordered]@{ When_Risco_Created = New-SharePointCreatedTrigger -ListName "Riscos e Bloqueios" }) `
    -Actions ([ordered]@{
        Get_Risco_Detalhes = New-SharePointGetItem -ListName "Riscos e Bloqueios" -Id "@triggerBody()?['ID']"
        Condition_Risco_Critico = [ordered]@{
            type = "If"
            expression = [ordered]@{
                or = @(
                    [ordered]@{ equals = @("@coalesce(body('Get_Risco_Detalhes')?['Severidade']?['Value'], body('Get_Risco_Detalhes')?['Severidade'])", "Critica") },
                    [ordered]@{ equals = @("@coalesce(body('Get_Risco_Detalhes')?['Severidade']?['Value'], body('Get_Risco_Detalhes')?['Severidade'])", "Critica") }
                )
            }
            actions = [ordered]@{
                Get_Projeto = New-SharePointGetItems -ListName "Projetos" -Filter "ProjectID eq '@{body('Get_Risco_Detalhes')?['ProjectID']}'" -Top 1
                Post_Escalacao_Risco_Teams = New-TeamsPostCard -CardExpression $riskCardExpression -RunAfter @{ Get_Projeto = @("Succeeded") }
                Send_Email_Sponsor_PMO = New-EmailAction `
                    -To "@coalesce(first(body('Get_Projeto')?['value'])?['Sponsor']?['Email'], '$PmoLeadEmail')" `
                    -Subject "RISCO CRITICO: @{coalesce(body('Get_Risco_Detalhes')?['Descricao'], body('Get_Risco_Detalhes')?['RiskID'], 'Sem descricao')}" `
                    -Body "<p><b>Risco critico escalado.</b></p><p><b>Projeto:</b> @{body('Get_Risco_Detalhes')?['ProjectID']}</p><p><b>Descricao:</b> @{body('Get_Risco_Detalhes')?['Descricao']}</p><p><b>Impacto:</b> @{coalesce(body('Get_Risco_Detalhes')?['Impacto']?['Value'], body('Get_Risco_Detalhes')?['Impacto'], '-')}</p><p>PMO Lead: $PmoLeadEmail</p>" `
                    -RunAfter @{ Post_Escalacao_Risco_Teams = @("Succeeded") }
            }
            else = [ordered]@{
                actions = [ordered]@{
                    Terminate_Nao_Critico = [ordered]@{
                        type = "Terminate"
                        inputs = [ordered]@{ runStatus = "Succeeded" }
                        runAfter = [ordered]@{}
                    }
                }
            }
            runAfter = [ordered]@{ Get_Risco_Detalhes = @("Succeeded") }
        }
    })

$flowDefinitions["PMO_PA_ResumoSemanal"] = New-WorkflowDefinition `
    -Triggers ([ordered]@{
        Recurrence_Monday_8h_BRT = [ordered]@{
            recurrence = [ordered]@{
                frequency = "Week"
                interval = 1
                timeZone = "E. South America Standard Time"
                schedule = [ordered]@{ weekDays = @("Monday"); hours = @(8); minutes = @(0) }
            }
            type = "Recurrence"
        }
    }) `
    -Actions (New-PortfolioSummaryActions -PostCardExpression $weeklyCardExpression -DecisionActionName "Compose_Decisoes_Semana" -DecisionFilter "Created ge '@{addDays(utcNow(),-7)}'" -IncludeWeeklyStatus $true)

$cardValidationPath = Join-Path $evidenceRoot "g3_phase3_card_validation_$timestamp.json"
Save-Json -Data $cardValidation -Path $cardValidationPath

if ($BuildOnly) {
    $buildResults = [System.Collections.Generic.List[object]]::new()
    foreach ($entry in $flowDefinitions.GetEnumerator()) {
        $definitionPath = Join-Path $evidenceRoot "flow_definition_INTENDED_PHASE3_$($entry.Key).json"
        Save-Json -Data $entry.Value -Path $definitionPath
        $buildResults.Add([pscustomobject]@{
            displayName = $entry.Key
            status = "BUILT_NOT_DEPLOYED"
            definition = $definitionPath
            triggerNames = @($entry.Value.triggers.Keys)
            actionNames = @($entry.Value.actions.Keys)
        }) | Out-Null
    }

    $buildSummaryPath = Join-Path $evidenceRoot "g3_phase3_p1p2_buildonly_$timestamp.json"
    Save-Json -Data ([pscustomobject]@{
        timestamp = (Get-Date).ToString("o")
        environmentName = $EnvironmentName
        environmentDisplayName = $EnvironmentDisplayName
        siteUrl = $SiteUrl
        teamsGroupId = $TeamsGroupId
        teamsChannelId = $TeamsChannelId
        connectorSources = [ordered]@{
            sharePoint = $SharePointConnectionName
            teams = $TeamsConnectionName
            outlook = $OutlookConnectionName
            planner = $PlannerConnectionName
        }
        standardConnectorsOnly = $true
        plannerOperation = "shared_planner/ListTasks_V3"
        cardValidation = $cardValidationPath
        results = $buildResults
        status = "BUILD_ONLY"
        blocker = "Not deployed. Use without -BuildOnly after refreshing interactive Microsoft.PowerApps.PowerShell authentication for ColOfertasBrasilPro."
    }) -Path $buildSummaryPath

    Write-Host "Build-only evidence: $buildSummaryPath"
    exit 0
}

$results = [System.Collections.Generic.List[object]]::new()
$errors = [System.Collections.Generic.List[object]]::new()

$account = [ordered]@{
    note = "PowerApps authenticated session reused. Test-PowerAppsAccount is intentionally not called because it can hang under MFA-backed cached auth in this tenant."
}

foreach ($entry in $flowDefinitions.GetEnumerator()) {
    $displayName = $entry.Key
    Write-Host "Deploying $displayName..."
    try {
        $summary = Set-ProcessSimpleFlow -DisplayName $displayName -Definition $entry.Value
        $results.Add($summary) | Out-Null
        Write-Host "$($summary.status): $displayName -> $($summary.flowName)"
    }
    catch {
        $failure = [pscustomobject]@{
            displayName = $displayName
            status = "FAILED"
            error = $_.Exception.Message
        }
        $errors.Add($failure) | Out-Null
        Write-Warning "FAILED: $displayName :: $($_.Exception.Message)"
    }
}

$summaryPath = Join-Path $evidenceRoot "g3_phase3_p1p2_summary_$timestamp.json"

$summary = [pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    environmentName = $EnvironmentName
    environmentDisplayName = $EnvironmentDisplayName
    account = $account
    siteUrl = $SiteUrl
    teamsGroupId = $TeamsGroupId
    teamsChannelId = $TeamsChannelId
    connectorSources = [ordered]@{
        sharePoint = $SharePointConnectionName
        teams = $TeamsConnectionName
        outlook = $OutlookConnectionName
        planner = $PlannerConnectionName
    }
    standardConnectorsOnly = $true
    plannerOperation = "shared_planner/ListTasks_V3"
    cardValidation = $cardValidationPath
    results = $results
    errors = $errors
    successCount = $results.Count
    failureCount = $errors.Count
    status = if ($errors.Count -eq 0 -and $results.Count -eq 5) { "PASS" } else { "FAIL" }
    notes = @(
        "G2 runtime E2E remains deferred to Phase 6 per handoff.",
        "Flow 8 uses Planner Standard connector operation ListTasks_V3 with groupId and plan id.",
        "No premium, HTTP, Graph direct, Dataverse, or custom connector action is used in these definitions."
    )
}

Save-Json -Data $summary -Path $summaryPath
Write-Host "Evidence: $summaryPath"

if ($summary.status -ne "PASS") {
    exit 1
}

exit 0
