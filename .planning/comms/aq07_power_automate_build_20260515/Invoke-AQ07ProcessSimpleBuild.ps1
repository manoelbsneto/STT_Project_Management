param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$SharePointConnectionName = "44f187cde7f54f208cf22bac4e533816",
    [string]$TeamsConnectionName = "shared-teams-1440d346-f1dd-44ea-912f-3787038ac333",
    [string]$PlannerConnectionName = "6b763b98729c4d99a7a8df4033d381af",
    [switch]$BuildOnly
)

$ErrorActionPreference = "Stop"

$PackageRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$EvidenceRoot = Join-Path $PackageRoot "execution_evidence"
New-Item -Path $EvidenceRoot -ItemType Directory -Force | Out-Null

$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
$TeamsGroupId = "96c5b0c4-46cc-46cd-8695-50451db74994"
$TeamsChannelId = "19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2"
$PlannerPlanId = "-1kBj1PLv0qQM-R4PwkqbpcABv_P"

$BucketMap = [ordered]@{
    "Piloto e Implantacao" = @{ bucketId = "4YAXH7iU9E-6jZE2P1DbG5cAMAzH"; status = "Piloto e Implantacao"; percentComplete = 50 }
    "Testes" = @{ bucketId = "7QYPufh54kum7MP4KUzzAZcAL6Ik"; status = "Testes"; percentComplete = 50 }
    "Cancelado" = @{ bucketId = "90TcFTFup0CjiHIdzY4gG5cALWKL"; status = "Cancelado"; percentComplete = 100 }
    "Concluido" = @{ bucketId = "F2WYUsnXeEue5qlwQuu3GJcAN1Ns"; status = "Concluido"; percentComplete = 100 }
    "Em Andamento" = @{ bucketId = "ugZSNxsYW0WWCJ5Dtx0-l5cALVXG"; status = "Em Andamento"; percentComplete = 50 }
    "Pendente" = @{ bucketId = "HmzyGOgC4k6uOPm_cwG3zZcAGiAG"; status = "Pendente"; percentComplete = 0 }
}

function ConvertTo-JsonFile {
    param([Parameter(Mandatory)]$InputObject, [Parameter(Mandatory)][string]$Path)
    $InputObject | ConvertTo-Json -Depth 100 | Out-File -FilePath $Path -Encoding utf8
}

function New-Definition {
    param([Parameter(Mandatory)][hashtable]$Triggers, [Parameter(Mandatory)][hashtable]$Actions)
    [ordered]@{
        '$schema' = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
        contentVersion = "1.0.0.0"
        parameters = [ordered]@{
            '$authentication' = [ordered]@{ defaultValue = [ordered]@{}; type = "SecureObject" }
            '$connections' = [ordered]@{ defaultValue = [ordered]@{}; type = "Object" }
        }
        triggers = $Triggers
        actions = $Actions
        outputs = [ordered]@{}
    }
}

function New-StringProperty {
    param([string]$Description)
    [ordered]@{ type = "string"; description = $Description }
}

function New-SkillsTrigger {
    param([hashtable]$Properties, [string[]]$Required = @())
    [ordered]@{
        manual = [ordered]@{
            type = "Request"
            kind = "Skills"
            inputs = [ordered]@{
                schema = [ordered]@{
                    type = "object"
                    properties = $Properties
                    required = $Required
                }
            }
        }
    }
}

function New-ManualTrigger {
    param([hashtable]$Properties, [string[]]$Required = @())
    [ordered]@{
        manual = [ordered]@{
            type = "Request"
            kind = "Button"
            inputs = [ordered]@{
                schema = [ordered]@{
                    type = "object"
                    properties = $Properties
                    required = $Required
                }
            }
        }
    }
}

function New-OpenApiAction {
    param(
        [Parameter(Mandatory)][string]$ApiName,
        [Parameter(Mandatory)][string]$OperationId,
        [hashtable]$Parameters = @{},
        [hashtable]$RunAfter = @{},
        [string]$Type = "OpenApiConnection"
    )
    [ordered]@{
        type = $Type
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
}

function New-SharePointGetItems {
    param([string]$ListName, [hashtable]$RunAfter = @{}, [string]$Filter = $null, [int]$Top = 100)
    $parameters = @{
        dataset = $SiteUrl
        table = $ListName
        '$top' = $Top
    }
    if ($Filter) { $parameters['$filter'] = $Filter }
    New-OpenApiAction -ApiName "shared_sharepointonline" -OperationId "GetItems" -Parameters $parameters -RunAfter $RunAfter
}

function New-SharePointGetItem {
    param([string]$ListName, [string]$IdExpression, [hashtable]$RunAfter = @{})
    New-OpenApiAction -ApiName "shared_sharepointonline" -OperationId "GetItem" -Parameters @{
        dataset = $SiteUrl
        table = $ListName
        id = $IdExpression
    } -RunAfter $RunAfter
}

function New-SharePointPostItem {
    param([string]$ListName, [hashtable]$Fields, [hashtable]$RunAfter = @{})
    $parameters = @{
        dataset = $SiteUrl
        table = $ListName
    }
    foreach ($key in $Fields.Keys) { $parameters[$key] = $Fields[$key] }
    New-OpenApiAction -ApiName "shared_sharepointonline" -OperationId "PostItem" -Parameters $parameters -RunAfter $RunAfter
}

function New-SharePointPatchItem {
    param([string]$ListName, [string]$IdExpression, [hashtable]$Fields, [hashtable]$RunAfter = @{})
    $parameters = @{
        dataset = $SiteUrl
        table = $ListName
        id = $IdExpression
    }
    foreach ($key in $Fields.Keys) { $parameters[$key] = $Fields[$key] }
    New-OpenApiAction -ApiName "shared_sharepointonline" -OperationId "PatchItem" -Parameters $parameters -RunAfter $RunAfter
}

function New-Compose {
    param([Parameter(Mandatory)]$Inputs, [hashtable]$RunAfter = @{})
    [ordered]@{ type = "Compose"; inputs = $Inputs; runAfter = $RunAfter }
}

function New-Select {
    param([string]$From, [hashtable]$Select, [hashtable]$RunAfter = @{})
    [ordered]@{ type = "Select"; inputs = [ordered]@{ from = $From; select = $Select }; runAfter = $RunAfter }
}

function New-Response {
    param([string]$Message, [hashtable]$RunAfter = @{})
    [ordered]@{
        type = "Response"
        kind = "Skills"
        inputs = [ordered]@{
            statusCode = 200
            headers = [ordered]@{ "Content-Type" = "application/json" }
            body = [ordered]@{ result = $Message }
            schema = [ordered]@{
                type = "object"
                properties = [ordered]@{
                    result = [ordered]@{
                        title = "result"
                        "x-ms-dynamically-added" = $true
                        type = "string"
                    }
                }
            }
        }
        runAfter = $RunAfter
    }
}

function New-ConnectionReferences {
    [ordered]@{
        shared_sharepointonline = [ordered]@{
            connectionName = $SharePointConnectionName
            connectionReferenceLogicalName = "pmo_aq07_sharepoint"
            source = "Invoker"
            id = "/providers/Microsoft.PowerApps/apis/shared_sharepointonline"
            displayName = "SharePoint"
            tier = "Standard"
            apiName = "sharepointonline"
            isProcessSimpleApiReferenceConversionAlreadyDone = $false
        }
        shared_teams = [ordered]@{
            connectionName = $TeamsConnectionName
            connectionReferenceLogicalName = "pmo_aq07_teams"
            source = "Invoker"
            id = "/providers/Microsoft.PowerApps/apis/shared_teams"
            displayName = "Microsoft Teams"
            tier = "Standard"
            apiName = "teams"
            isProcessSimpleApiReferenceConversionAlreadyDone = $false
        }
        shared_planner = [ordered]@{
            connectionName = $PlannerConnectionName
            connectionReferenceLogicalName = "pmo_aq07_planner"
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
    if (-not $FlowName) { $FlowName = [guid]::NewGuid().ToString() }
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
    Get-Flow -EnvironmentName $EnvironmentName -Top 1000 |
        Where-Object { $_.DisplayName -eq $DisplayName } |
        Select-Object -First 1
}

function Invoke-WithRetry {
    param([scriptblock]$ScriptBlock, [string]$Operation)
    for ($i = 1; $i -le 3; $i++) {
        try { return & $ScriptBlock }
        catch {
            if ($i -eq 3) { throw }
            Start-Sleep -Seconds 10
        }
    }
}

function Set-ProcessSimpleFlow {
    param([string]$DisplayName, [object]$Definition)
    $existing = $null
    if (-not $BuildOnly) {
        $existing = Get-ExistingFlowByDisplayName -DisplayName $DisplayName
    }
    $flowName = if ($existing) { $existing.FlowName } else { [guid]::NewGuid().ToString() }
    $payload = New-FlowPayload -DisplayName $DisplayName -Definition $Definition -FlowName $flowName
    $requestPath = Join-Path $EvidenceRoot ("request_{0}.json" -f $DisplayName)
    ConvertTo-JsonFile -InputObject $payload -Path $requestPath

    if ($BuildOnly) {
        return [ordered]@{ displayName = $DisplayName; mode = "BuildOnly"; flowName = $flowName; requestPath = $requestPath }
    }

    $method = if ($existing) { "PATCH" } else { "POST" }
    $route = if ($existing) {
        "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows/$flowName"
    } else {
        "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows"
    }

    $result = Invoke-WithRetry -Operation "$method $DisplayName" -ScriptBlock {
        InvokeApi -Method $method -Route $route -Body $payload -ApiVersion "2016-11-01" -ThrowOnFailure
    }
    $responsePath = Join-Path $EvidenceRoot ("response_{0}.json" -f $DisplayName)
    ConvertTo-JsonFile -InputObject $result -Path $responsePath
    [ordered]@{
        displayName = $DisplayName
        mode = if ($existing) { "PATCH" } else { "POST" }
        flowName = $flowName
        requestPath = $requestPath
        responsePath = $responsePath
    }
}

function New-FI01 {
    New-Definition -Triggers (New-SkillsTrigger -Properties ([ordered]@{}) -Required @()) -Actions ([ordered]@{
        Get_Projetos = New-SharePointGetItems -ListName "Projetos" -Top 100
        Get_Tarefas = New-SharePointGetItems -ListName "Tarefas" -Top 100 -RunAfter @{ Get_Projetos = @("Succeeded") }
        Respond_Success = New-Response -Message "Executive portfolio retrieved successfully." -RunAfter @{ Get_Tarefas = @("Succeeded") }
    })
}

function New-FI02 {
    $props = [ordered]@{
        routeKey = New-StringProperty "Route key"
        status = New-StringProperty "Status"
        action = New-StringProperty "Action"
    }
    $card = '{"type":"AdaptiveCard","version":"1.5","body":[{"type":"TextBlock","text":"Status update requested","wrap":true}]}'
    New-Definition -Triggers (New-SkillsTrigger -Properties $props -Required @("routeKey")) -Actions ([ordered]@{
        Post_Status_Card = New-OpenApiAction -ApiName "shared_teams" -OperationId "PostCardToConversation" -Parameters @{
            poster = "Flow bot"
            location = "Channel"
            "body/recipient/groupId" = $TeamsGroupId
            "body/recipient/channelId" = $TeamsChannelId
            "body/messageBody" = $card
        }
        Respond_Success = New-Response -Message "Status update card posted successfully." -RunAfter @{ Post_Status_Card = @("Succeeded") }
    })
}

function New-FI03 {
    $props = [ordered]@{
        projectId = New-StringProperty "Project ID"
        action = New-StringProperty "Action"
    }
    New-Definition -Triggers (New-SkillsTrigger -Properties $props -Required @("projectId","action")) -Actions ([ordered]@{
        Get_Tarefas = New-SharePointGetItems -ListName "Tarefas" -Top 100 -Filter "ProjectID eq '@{replace(triggerBody()?['projectId'],'''','''''')}'"
        List_Planner_Tasks = New-OpenApiAction -ApiName "shared_planner" -OperationId "ListTasks_V3" -Parameters @{
            groupId = $TeamsGroupId
            id = $PlannerPlanId
        } -RunAfter @{ Get_Tarefas = @("Succeeded") }
        Normalize_Tasks = New-Select -From "@body('Get_Tarefas')?['value']" -Select ([ordered]@{
            title = "@item()?['Title']"
            projectId = "@item()?['ProjectID']"
            status = "@coalesce(item()?['Status']?['Value'], item()?['Status'])"
            plannerTaskId = "@item()?['PlannerTaskId']"
            plannerBucketId = "@item()?['PlannerBucketId']"
        }) -RunAfter @{ List_Planner_Tasks = @("Succeeded") }
        Respond_Success = New-Response -Message "Tasks retrieved successfully." -RunAfter @{ Normalize_Tasks = @("Succeeded") }
    })
}

function New-FI04 {
    $props = [ordered]@{
        title = New-StringProperty "Task title"
        taskTitle = New-StringProperty "Task title from card"
        projectId = New-StringProperty "Project ID"
        action = New-StringProperty "Action"
        startDate = New-StringProperty "Start date"
        endDate = New-StringProperty "End date"
        dueDate = New-StringProperty "Due date from card"
        bucket = New-StringProperty "Bucket"
        plannerBucketName = New-StringProperty "Bucket from card"
    }
    $bucketExpr = "@if(equals(coalesce(triggerBody()?['bucket'],triggerBody()?['plannerBucketName']), 'Piloto e Implantacao'), json('{""bucketId"":""4YAXH7iU9E-6jZE2P1DbG5cAMAzH"",""status"":""Piloto e Implantacao""}'), if(equals(coalesce(triggerBody()?['bucket'],triggerBody()?['plannerBucketName']), 'Testes'), json('{""bucketId"":""7QYPufh54kum7MP4KUzzAZcAL6Ik"",""status"":""Testes""}'), if(equals(coalesce(triggerBody()?['bucket'],triggerBody()?['plannerBucketName']), 'Cancelado'), json('{""bucketId"":""90TcFTFup0CjiHIdzY4gG5cALWKL"",""status"":""Cancelado""}'), if(equals(coalesce(triggerBody()?['bucket'],triggerBody()?['plannerBucketName']), 'Concluido'), json('{""bucketId"":""F2WYUsnXeEue5qlwQuu3GJcAN1Ns"",""status"":""Concluido""}'), if(equals(coalesce(triggerBody()?['bucket'],triggerBody()?['plannerBucketName']), 'Em Andamento'), json('{""bucketId"":""ugZSNxsYW0WWCJ5Dtx0-l5cALVXG"",""status"":""Em Andamento""}'), json('{""bucketId"":""HmzyGOgC4k6uOPm_cwG3zZcAGiAG"",""status"":""Pendente""}'))))))"
    New-Definition -Triggers (New-SkillsTrigger -Properties $props -Required @("projectId","action")) -Actions ([ordered]@{
        Determine_Bucket_and_Status = New-Compose -Inputs $bucketExpr
        Create_Planner_Task = New-OpenApiAction -ApiName "shared_planner" -OperationId "CreateTask_V3" -Parameters @{
            "body/groupId" = $TeamsGroupId
            "body/planId" = $PlannerPlanId
            "body/title" = "@coalesce(triggerBody()?['title'],triggerBody()?['taskTitle'])"
        } -RunAfter @{ Determine_Bucket_and_Status = @("Succeeded") }
        Create_SharePoint_Item = New-SharePointPostItem -ListName "Tarefas" -Fields @{
            "item/Title" = "@coalesce(triggerBody()?['title'],triggerBody()?['taskTitle'])"
            "item/ProjectID" = "@triggerBody()?['projectId']"
            "item/Status/Value" = "@outputs('Determine_Bucket_and_Status')?['status']"
            "item/PlannerTaskId" = "@body('Create_Planner_Task')?['id']"
            "item/PlannerBucketId" = "@outputs('Determine_Bucket_and_Status')?['bucketId']"
            "item/PlannerSyncStatus/Value" = "OK"
            "item/PlannerLastSyncAt" = "@utcNow()"
            "item/PlannerSyncError" = ""
        } -RunAfter @{ Create_Planner_Task = @("Succeeded") }
        Respond_Success = New-Response -Message "Task created successfully." -RunAfter @{ Create_SharePoint_Item = @("Succeeded") }
    })
}

function New-FI05 {
    $props = [ordered]@{
        spItemId = New-StringProperty "SharePoint item ID"
        taskId = New-StringProperty "SharePoint item ID from card"
        status = New-StringProperty "Status"
        taskStatus = New-StringProperty "Status from card"
        action = New-StringProperty "Action"
        comments = New-StringProperty "Comments"
    }
    $mapExpr = "@if(equals(coalesce(triggerBody()?['status'],triggerBody()?['taskStatus']), 'Em Andamento'), json('{""bucketId"":""ugZSNxsYW0WWCJ5Dtx0-l5cALVXG"",""percentComplete"":50}'), if(equals(coalesce(triggerBody()?['status'],triggerBody()?['taskStatus']), 'Testes'), json('{""bucketId"":""7QYPufh54kum7MP4KUzzAZcAL6Ik"",""percentComplete"":50}'), if(equals(coalesce(triggerBody()?['status'],triggerBody()?['taskStatus']), 'Piloto e Implantacao'), json('{""bucketId"":""4YAXH7iU9E-6jZE2P1DbG5cAMAzH"",""percentComplete"":50}'), if(equals(coalesce(triggerBody()?['status'],triggerBody()?['taskStatus']), 'Concluido'), json('{""bucketId"":""F2WYUsnXeEue5qlwQuu3GJcAN1Ns"",""percentComplete"":100}'), if(equals(coalesce(triggerBody()?['status'],triggerBody()?['taskStatus']), 'Cancelado'), json('{""bucketId"":""90TcFTFup0CjiHIdzY4gG5cALWKL"",""percentComplete"":100}'), json('{""bucketId"":""HmzyGOgC4k6uOPm_cwG3zZcAGiAG"",""percentComplete"":0}'))))))"
    New-Definition -Triggers (New-SkillsTrigger -Properties $props -Required @("action")) -Actions ([ordered]@{
        Get_SharePoint_Item = New-SharePointGetItem -ListName "Tarefas" -IdExpression "@coalesce(triggerBody()?['spItemId'],triggerBody()?['taskId'])"
        Determine_Bucket_and_Percent = New-Compose -Inputs $mapExpr -RunAfter @{ Get_SharePoint_Item = @("Succeeded") }
        Update_Planner_Task = New-OpenApiAction -ApiName "shared_planner" -OperationId "UpdateTask_V2" -Parameters @{
            id = "@body('Get_SharePoint_Item')?['PlannerTaskId']"
            "body/percentComplete" = "@outputs('Determine_Bucket_and_Percent')?['percentComplete']"
        } -RunAfter @{ Determine_Bucket_and_Percent = @("Succeeded") }
        Update_SharePoint_Item = New-SharePointPatchItem -ListName "Tarefas" -IdExpression "@coalesce(triggerBody()?['spItemId'],triggerBody()?['taskId'])" -Fields @{
            "item/Title" = "@body('Get_SharePoint_Item')?['Title']"
            "item/ProjectID" = "@body('Get_SharePoint_Item')?['ProjectID']"
            "item/Status/Value" = "@coalesce(triggerBody()?['status'],triggerBody()?['taskStatus'])"
            "item/PlannerBucketId" = "@outputs('Determine_Bucket_and_Percent')?['bucketId']"
            "item/PlannerSyncStatus/Value" = "OK"
            "item/PlannerLastSyncAt" = "@utcNow()"
            "item/PlannerSyncError" = ""
        } -RunAfter @{ Update_Planner_Task = @("Succeeded") }
        Respond_Success = New-Response -Message "Task updated successfully." -RunAfter @{ Update_SharePoint_Item = @("Succeeded") }
    })
}

function New-FI06 {
    $props = [ordered]@{
        source = New-StringProperty "Source"
        code = New-StringProperty "Code"
        details = New-StringProperty "Details"
    }
    New-Definition -Triggers (New-SkillsTrigger -Properties $props -Required @("source","code")) -Actions ([ordered]@{
        Sanitize_Error = New-Compose -Inputs "@substring(coalesce(triggerBody()?['details'],''),0,min(length(coalesce(triggerBody()?['details'],'')),500))"
        Respond_Success = New-Response -Message "Operation failed securely." -RunAfter @{ Sanitize_Error = @("Succeeded") }
    })
}

$definitions = [ordered]@{
    "PM0_PA_Card_ResumoExecutivoPortfolio" = New-FI01
    "PM0_PA_Card_AtualizarStatus" = New-FI02
    "PM0_PA_Card_ListarTarefas" = New-FI03
    "PM0_PA_Card_CriarTarefa" = New-FI04
    "PM0_PA_Card_AtualizarTarefa" = New-FI05
    "PM0_PA_OpsFailureHandling" = New-FI06
}

$preflight = [ordered]@{
    timestampUtc = (Get-Date).ToUniversalTime().ToString("o")
    environmentName = $EnvironmentName
    route = "ProcessSimple direct flow create/update"
    pacSolutionImportUsed = $false
    runtimeTestsPerformed = $false
    existingTargets = @()
    bucketMap = $BucketMap
}

if (-not $BuildOnly) {
    Import-Module "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1" -Force
    Import-Module "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1" -Force
    try {
        Get-Flow -EnvironmentName $EnvironmentName -Top 1 -ErrorAction Stop | Out-Null
    }
    catch {
        Add-PowerAppsAccount -Endpoint prod | Out-Null
    }
    $preflight.existingTargets = @(Get-Flow -EnvironmentName $EnvironmentName -Top 1000 |
        Where-Object { $definitions.Keys -contains $_.DisplayName } |
        Select-Object DisplayName, FlowName, Enabled, CreatedTime, LastModifiedTime)
}

ConvertTo-JsonFile -InputObject $preflight -Path (Join-Path $EvidenceRoot "preflight.json")

$results = @()
foreach ($name in $definitions.Keys) {
    $definitionPath = Join-Path $EvidenceRoot ("definition_{0}.json" -f $name)
    ConvertTo-JsonFile -InputObject $definitions[$name] -Path $definitionPath
    $results += Set-ProcessSimpleFlow -DisplayName $name -Definition $definitions[$name]
}

$summary = [ordered]@{
    taskId = "AQ-07-POWER-AUTOMATE-BUILD-SAVE-IMPORT"
    status = if ($BuildOnly) { "BUILD_ONLY_LOCAL_READY" } else { "PROGRAMMATIC_SAVE_COMPLETE_READY_FOR_AQ08" }
    buildOnly = [bool]$BuildOnly
    environmentName = $EnvironmentName
    environmentUrl = "https://colofertasbrasilpro.crm4.dynamics.com/"
    flows = $results
    connectionReferences = [ordered]@{
        SharePoint = $SharePointConnectionName
        Teams = $TeamsConnectionName
        Planner = $PlannerConnectionName
    }
    forbiddenActionsConfirmedNotPerformed = [ordered]@{
        pacSolutionImport = $true
        m365Cli = $true
        copilotPublish = $true
        runtimeSmokeTests = $true
        teamsProductionPosts = $true
    }
    releaseDecision = "NO-SHIP"
}

ConvertTo-JsonFile -InputObject $summary -Path (Join-Path $EvidenceRoot "execution_summary.json")
$summary
