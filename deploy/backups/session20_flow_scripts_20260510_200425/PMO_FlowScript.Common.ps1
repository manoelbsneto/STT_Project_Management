[CmdletBinding()]
param()

Set-StrictMode -Version Latest

function Initialize-PMOFlowScript {
    param(
        [Parameter(Mandatory)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory)]
        [string]$EvidenceDir,

        [switch]$SkipModuleImport
    )

    Set-Location $RepositoryRoot

    $evidenceRoot = Join-Path $RepositoryRoot $EvidenceDir
    New-Item -ItemType Directory -Force -Path $evidenceRoot | Out-Null

    if (-not $SkipModuleImport) {
        $adminModule = Get-PMOPowerShellModulePath -ModuleName "Microsoft.PowerApps.Administration.PowerShell"
        $powerAppsModule = Get-PMOPowerShellModulePath -ModuleName "Microsoft.PowerApps.PowerShell"

        Import-Module $adminModule -ErrorAction Stop
        Import-Module $powerAppsModule -ErrorAction Stop
    }

    $evidenceRoot
}

function Get-PMOPowerShellModulePath {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName
    )

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

function Save-PMOJson {
    param(
        [Parameter(Mandatory)]
        [object]$Data,

        [Parameter(Mandatory)]
        [string]$Path,

        [int]$Depth = 100
    )

    $Data | ConvertTo-Json -Depth $Depth | Set-Content -LiteralPath $Path -Encoding UTF8
}

function New-PMOFlowDefinition {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Triggers,

        [Parameter(Mandatory)]
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

function New-PMOSkillsTrigger {
    param(
        [Parameter(Mandatory)]
        [hashtable]$Properties,

        [string[]]$Required = @()
    )

    [ordered]@{
        Copilot_Request = [ordered]@{
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

function New-PMOStringProperty {
    param([string]$Description)
    [ordered]@{ type = "string"; description = $Description }
}

function New-PMONumberProperty {
    param([string]$Description)
    [ordered]@{ type = "number"; description = $Description }
}

function New-PMOOpenApiAction {
    param(
        [string]$Type = "OpenApiConnection",
        [Parameter(Mandatory)]
        [string]$ApiId,
        [Parameter(Mandatory)]
        [string]$OperationId,
        [Parameter(Mandatory)]
        [string]$ConnectionName,
        [hashtable]$Parameters = @{},
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

function New-PMOSharePointGetItems {
    param(
        [Parameter(Mandatory)]
        [string]$SiteUrl,
        [Parameter(Mandatory)]
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

    New-PMOOpenApiAction `
        -ApiId "/providers/Microsoft.PowerApps/apis/shared_sharepointonline" `
        -OperationId "GetItems" `
        -ConnectionName "shared_sharepointonline" `
        -Parameters $parameters `
        -RunAfter $RunAfter
}

function New-PMOSharePointPostItem {
    param(
        [Parameter(Mandatory)]
        [string]$SiteUrl,
        [Parameter(Mandatory)]
        [string]$ListName,
        [Parameter(Mandatory)]
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

    New-PMOOpenApiAction `
        -ApiId "/providers/Microsoft.PowerApps/apis/shared_sharepointonline" `
        -OperationId "PostItem" `
        -ConnectionName "shared_sharepointonline" `
        -Parameters $parameters `
        -RunAfter $RunAfter
}

function New-PMOResponse {
    param(
        [Parameter(Mandatory)]
        [object]$Result,
        [int]$StatusCode = 200,
        [hashtable]$RunAfter = @{}
    )

    [ordered]@{
        type = "Response"
        kind = "Skills"
        inputs = [ordered]@{
            statusCode = $StatusCode
            headers = [ordered]@{ "Content-Type" = "application/json" }
            body = [ordered]@{ result = $Result }
        }
        runAfter = $RunAfter
    }
}

function New-PMOCompose {
    param(
        [Parameter(Mandatory)]
        [object]$Inputs,
        [hashtable]$RunAfter = @{}
    )

    [ordered]@{
        type = "Compose"
        inputs = $Inputs
        runAfter = $RunAfter
    }
}

function New-PMOInitializeIntegerVariable {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [int]$Value = 0,
        [hashtable]$RunAfter = @{}
    )

    [ordered]@{
        type = "InitializeVariable"
        inputs = [ordered]@{
            variables = @(
                [ordered]@{
                    name = $Name
                    type = "integer"
                    value = $Value
                }
            )
        }
        runAfter = $RunAfter
    }
}

function New-PMOIncrementVariable {
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [int]$Value = 1,
        [hashtable]$RunAfter = @{}
    )

    [ordered]@{
        type = "IncrementVariable"
        inputs = [ordered]@{
            name = $Name
            value = $Value
        }
        runAfter = $RunAfter
    }
}

function Get-PMOExistingFlowByDisplayName {
    param(
        [Parameter(Mandatory)]
        [string]$EnvironmentName,
        [Parameter(Mandatory)]
        [string]$DisplayName,
        [switch]$ForceCreate
    )

    if ($ForceCreate) {
        return $null
    }

    Get-Flow -EnvironmentName $EnvironmentName -Top 500 |
        Where-Object { $_.DisplayName -eq $DisplayName } |
        Select-Object -First 1
}

function Invoke-PMOWithRetry {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        [Parameter(Mandatory)]
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

function Set-PMOProcessSimpleFlow {
    param(
        [Parameter(Mandatory)]
        [string]$EnvironmentName,
        [Parameter(Mandatory)]
        [string]$DisplayName,
        [Parameter(Mandatory)]
        [object]$Definition,
        [Parameter(Mandatory)]
        [string]$SharePointConnectionName,
        [Parameter(Mandatory)]
        [string]$EvidenceRoot,
        [Parameter(Mandatory)]
        [string]$EvidencePrefix,
        [switch]$ForceCreate
    )

    $existing = Get-PMOExistingFlowByDisplayName -EnvironmentName $EnvironmentName -DisplayName $DisplayName -ForceCreate:$ForceCreate
    $method = "POST"
    $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows"
    $flowName = [guid]::NewGuid().ToString()
    $status = "CREATED"

    if ($existing) {
        $method = "PATCH"
        $flowName = $existing.FlowName
        $route = "https://{flowEndpoint}/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows/$flowName"
        $status = "PATCHED"
    }

    $payload = [ordered]@{
        name = $flowName
        type = "Microsoft.ProcessSimple/environments/flows"
        id = "/providers/Microsoft.ProcessSimple/environments/$EnvironmentName/flows/$flowName"
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

    $requestPath = Join-Path $EvidenceRoot "$($EvidencePrefix)_request_$flowName.json"
    $resultPath = Join-Path $EvidenceRoot "$($EvidencePrefix)_result_$flowName.json"
    Save-PMOJson -Data $payload -Path $requestPath
    $apiPayload = Get-Content -LiteralPath $requestPath -Raw | ConvertFrom-Json

    $result = Invoke-PMOWithRetry -Operation "$method ProcessSimple $DisplayName" -Attempts 4 -DelaySeconds 12 -ScriptBlock {
        InvokeApi -Method $method -Route $route -Body $apiPayload -ApiVersion "2016-11-01" -ThrowOnFailure
    }
    Save-PMOJson -Data $result -Path $resultPath

    Start-Sleep -Seconds 5
    $createdName = if ($result.name) { $result.name } else { $flowName }
    $flow = Invoke-PMOWithRetry -Operation "Get-Flow $DisplayName" -Attempts 6 -DelaySeconds 8 -ScriptBlock {
        $f = Get-Flow -EnvironmentName $EnvironmentName -FlowName $createdName -ErrorAction Stop
        if (-not $f -or -not $f.Internal) {
            throw "Flow not ready"
        }
        $f
    }

    [ordered]@{
        displayName = $DisplayName
        status = $status
        flowName = $createdName
        enabled = $flow.Enabled
        state = $flow.Internal.properties.state
        workflowEntityId = $flow.Internal.properties.workflowEntityId
        requestPath = $requestPath
        resultPath = $resultPath
    }
}
