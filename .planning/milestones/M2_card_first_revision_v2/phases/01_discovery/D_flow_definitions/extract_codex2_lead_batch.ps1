param(
    [string]$OutputDir = ".planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions",
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"
)

$ErrorActionPreference = "Stop"

$flows = @(
    @{ Name = "PMO_PA_AtualizarStatus"; WorkflowId = "c11a165b-c64c-f111-bec7-7ced8d9559c1"; Type = "legacy"; Index = "D.1" },
    @{ Name = "PMO_PA_AtualizarTarefa"; WorkflowId = "98408d55-3748-f111-bec7-000d3abc5cc6"; Type = "legacy"; Index = "D.2" },
    @{ Name = "PMO_PA_ConsultarPortfolio"; WorkflowId = "39cf292d-c64c-f111-bec7-7ced8d955c6c"; Type = "legacy"; Index = "D.3" },
    @{ Name = "PMO_PA_ConsultarProjeto"; WorkflowId = "4a33b53e-c64c-f111-bec7-000d3abc5cc6"; Type = "legacy"; Index = "D.4" },
    @{ Name = "PMO_PA_CriarProjeto"; WorkflowId = "3104124d-364a-f111-bec7-7ced8d955c6c"; Type = "legacy"; Index = "D.5" },
    @{ Name = "PMO_PA_CriarTarefa"; WorkflowId = "0a5d2a41-24c0-4d5e-9f6d-000000000241"; Type = "legacy"; Index = "D.6" }
)

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)] $InputObject,
        [Parameter(Mandatory = $true)] [string] $Path
    )

    $InputObject | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-ActionRecords {
    param(
        $Actions,
        [string] $Prefix = ""
    )

    $records = @()
    if ($null -eq $Actions) {
        return $records
    }

    foreach ($property in $Actions.PSObject.Properties) {
        $actionName = $property.Name
        $action = $property.Value
        $path = if ([string]::IsNullOrWhiteSpace($Prefix)) { $actionName } else { "$Prefix/$actionName" }
        $actionHost = $null
        $operationId = $null
        $connectionName = $null

        if ($action.inputs -and $action.inputs.host) {
            $actionHost = $action.inputs.host
            $operationId = $action.inputs.host.operationId
            $connectionName = $action.inputs.host.connectionName
        }

        $records += [pscustomobject]@{
            name = $actionName
            path = $path
            type = $action.type
            runAfter = $action.runAfter
            operationId = $operationId
            connectionName = $connectionName
            host = $actionHost
            responseSchema = if ($action.type -eq "Response" -and $action.inputs) { $action.inputs.schema } else { $null }
            responseStatusCode = if ($action.type -eq "Response" -and $action.inputs) { $action.inputs.statusCode } else { $null }
        }

        if ($action.actions) {
            $records += Get-ActionRecords -Actions $action.actions -Prefix $path
        }
        if ($action.else -and $action.else.actions) {
            $records += Get-ActionRecords -Actions $action.else.actions -Prefix "$path/else"
        }
    }

    return $records
}

function Get-WorkflowClientData {
    param(
        [Parameter(Mandatory = $true)] [string] $WorkflowId
    )

    $fetchFile = New-TemporaryFile
    try {
        @"
<fetch>
  <entity name='workflow'>
    <attribute name='workflowid' />
    <attribute name='name' />
    <attribute name='clientdata' />
    <attribute name='inputparameters' />
    <filter>
      <condition attribute='workflowid' operator='eq' value='$WorkflowId' />
    </filter>
  </entity>
</fetch>
"@ | Set-Content -LiteralPath $fetchFile -Encoding UTF8

        $raw = (& pac org fetch --xmlFile $fetchFile 2>&1 | ForEach-Object { $_.ToString() }) -join "`n"
        if ($LASTEXITCODE -ne 0) {
            throw "pac org fetch failed for workflow $WorkflowId. Output: $raw"
        }

        $jsonStart = $raw.IndexOf('{"properties"')
        if ($jsonStart -lt 0) {
            throw "Unable to locate clientdata JSON for workflow $WorkflowId. Output: $raw"
        }

        $json = $raw.Substring($jsonStart).Trim()
        return $json | ConvertFrom-Json
    }
    finally {
        Remove-Item -LiteralPath $fetchFile -Force -ErrorAction SilentlyContinue
    }
}

function Get-RunHistorySummary {
    param(
        [Parameter(Mandatory = $true)] [hashtable] $Flow
    )

    $capturedAt = (Get-Date).ToUniversalTime().ToString("o")
    $windowStart = (Get-Date).ToUniversalTime().AddDays(-30)
    try {
        $runs = @(Get-FlowRun -EnvironmentName $EnvironmentName -FlowName $Flow.WorkflowId -ErrorAction Stop)
        $items = @()

        foreach ($run in $runs) {
            $props = $run.Internal.properties
            $startValue = if ($run.StartTime) { $run.StartTime } elseif ($props.startTime) { $props.startTime } else { $null }
            if ($null -eq $startValue) {
                continue
            }

            $startTime = [datetime]$startValue
            if ($startTime.ToUniversalTime() -lt $windowStart) {
                continue
            }

            $items += [pscustomobject]@{
                flowRunName = $run.FlowRunName
                status = $run.Status
                startTime = $startTime.ToUniversalTime().ToString("o")
                endTime = if ($props.endTime) { ([datetime]$props.endTime).ToUniversalTime().ToString("o") } else { $null }
                triggerName = if ($props.trigger) { $props.trigger.name } else { $null }
                triggerStatus = if ($props.trigger) { $props.trigger.status } else { $null }
                responseName = if ($props.response) { $props.response.name } else { $null }
                responseStatus = if ($props.response) { $props.response.status } else { $null }
                responseCode = if ($props.response) { $props.response.code } else { $null }
            }
        }

        $statusCounts = @{}
        foreach ($group in ($items | Group-Object status)) {
            $statusCounts[$group.Name] = $group.Count
        }

        return [pscustomobject]@{
            flowName = $Flow.Name
            workflowId = $Flow.WorkflowId
            flowType = $Flow.Type
            windowStartUtc = $windowStart.ToString("o")
            capturedAtUtc = $capturedAt
            totalRuns = $items.Count
            succeeded = @($items | Where-Object { $_.status -eq "Succeeded" }).Count
            failed = @($items | Where-Object { $_.status -eq "Failed" }).Count
            canceled = @($items | Where-Object { $_.status -eq "Canceled" }).Count
            timedOut = @($items | Where-Object { $_.status -eq "TimedOut" }).Count
            statusCounts = $statusCounts
            runs = $items
        }
    }
    catch {
        return [pscustomobject]@{
            flowName = $Flow.Name
            workflowId = $Flow.WorkflowId
            flowType = $Flow.Type
            windowStartUtc = $windowStart.ToString("o")
            capturedAtUtc = $capturedAt
            totalRuns = 0
            succeeded = 0
            failed = 0
            canceled = 0
            timedOut = 0
            statusCounts = @{}
            runs = @()
            error = $_.Exception.Message
        }
    }
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$summaries = @()

foreach ($flow in $flows) {
    Write-Host "Extracting $($flow.Index) $($flow.Name)"
    $clientData = Get-WorkflowClientData -WorkflowId $flow.WorkflowId
    $definition = $clientData.properties.definition

    Write-JsonFile -InputObject $clientData -Path (Join-Path $OutputDir "definition_$($flow.Name).json")

    $triggerSchemas = @()
    foreach ($triggerProperty in $definition.triggers.PSObject.Properties) {
        $trigger = $triggerProperty.Value
        $triggerSchemas += [pscustomobject]@{
            flowName = $flow.Name
            workflowId = $flow.WorkflowId
            triggerName = $triggerProperty.Name
            type = $trigger.type
            kind = $trigger.kind
            schema = if ($trigger.inputs) { $trigger.inputs.schema } else { $null }
            metadata = $trigger.metadata
        }
    }
    Write-JsonFile -InputObject $triggerSchemas -Path (Join-Path $OutputDir "triggerSchema_$($flow.Name).json")

    $actions = Get-ActionRecords -Actions $definition.actions
    $outputSchemas = @($actions | Where-Object { $_.type -eq "Response" } | ForEach-Object {
        [pscustomobject]@{
            flowName = $flow.Name
            workflowId = $flow.WorkflowId
            responseActionName = $_.name
            responseActionPath = $_.path
            statusCode = $_.responseStatusCode
            schema = $_.responseSchema
        }
    })
    Write-JsonFile -InputObject $outputSchemas -Path (Join-Path $OutputDir "outputSchema_$($flow.Name).json")

    $runSummary = Get-RunHistorySummary -Flow $flow
    Write-JsonFile -InputObject $runSummary -Path (Join-Path $OutputDir "flow_run_history_30d_$($flow.Name).json")
    $summaries += $runSummary
}

Write-JsonFile -InputObject $summaries -Path (Join-Path $OutputDir "flow_run_history_30d_CODEX-2-LEAD_batch1.json")
Write-Host "Done. Extracted $($flows.Count) flows into $OutputDir"
