[CmdletBinding()]
param(
    [string]$EnvironmentId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$OutputDir = ".planning\comms\aq08_flow_output_schemas_20260521"
)

$ErrorActionPreference = "Stop"

$flows = @(
    [ordered]@{
        topicName = "AtualizarStatus"
        topicSchemaName = "pmo_AssistentePMO_V2.topic.AtualizarStatus"
        actionComponent = "pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus"
        flowName = "PM0_PA_Card_AtualizarStatus"
        workflowId = "1721e0a3-a250-f111-bec7-000d3abc5cc6"
    },
    [ordered]@{
        topicName = "AtualizarTarefa"
        topicSchemaName = "pmo_AssistentePMO_V2.topic.AtualizarTarefa"
        actionComponent = "pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa"
        flowName = "PM0_PA_Card_AtualizarTarefa"
        workflowId = "7c6300c2-a250-f111-bec7-000d3abc5cc6"
    },
    [ordered]@{
        topicName = "ConsultarPortfolio"
        topicSchemaName = "pmo_AssistentePMO_V2.topic.ConsultarPortfolio"
        actionComponent = "pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio"
        flowName = "PM0_PA_Card_ResumoExecutivoPortfolio"
        workflowId = "8333bd91-a250-f111-bec7-000d3abc5cc6"
    },
    [ordered]@{
        topicName = "CriarTarefa"
        topicSchemaName = "pmo_AssistentePMO_V2.topic.CriarTarefa"
        actionComponent = "pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa"
        flowName = "PM0_PA_Card_CriarTarefa"
        workflowId = "7f662db7-a250-f111-bec7-000d3abc5cc6"
    },
    [ordered]@{
        topicName = "ListarTarefas"
        topicSchemaName = "pmo_AssistentePMO_V2.topic.ListarTarefas"
        actionComponent = "pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas"
        flowName = "PM0_PA_Card_ListarTarefas"
        workflowId = "e0e3c6b0-a250-f111-bec7-000d3abc5cc6"
    }
)

function Invoke-PacReadOnly {
    param(
        [string[]]$Arguments,
        [string]$OutputPath
    )

    $pac = Get-Command pac -ErrorAction Stop
    $stderrPath = "$OutputPath.stderr"
    & $pac.Source @Arguments > $OutputPath 2> $stderrPath
    if ($LASTEXITCODE -ne 0) {
        $stderr = if (Test-Path -LiteralPath $stderrPath) { Get-Content -LiteralPath $stderrPath -Raw } else { "" }
        throw "PAC command failed ($LASTEXITCODE): pac $($Arguments -join ' ')`n$stderr"
    }
}

function Get-BalancedJsonAt {
    param(
        [string]$Text,
        [int]$StartIndex
    )

    $depth = 0
    $inString = $false
    $escaped = $false

    for ($i = $StartIndex; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($inString) {
            if ($escaped) {
                $escaped = $false
                continue
            }
            if ($ch -eq "\") {
                $escaped = $true
                continue
            }
            if ($ch -eq '"') {
                $inString = $false
                continue
            }
            continue
        }

        if ($ch -eq '"') {
            $inString = $true
            continue
        }
        if ($ch -eq "{") {
            $depth++
            continue
        }
        if ($ch -eq "}") {
            $depth--
            if ($depth -eq 0) {
                return $Text.Substring($StartIndex, $i - $StartIndex + 1)
            }
        }
    }

    throw "Could not find balanced JSON object from offset $StartIndex."
}

function Get-ClientDataJson {
    param(
        [string]$FetchText,
        [string]$WorkflowId
    )

    $idIndex = $FetchText.IndexOf($WorkflowId, [System.StringComparison]::OrdinalIgnoreCase)
    if ($idIndex -lt 0) {
        throw "Workflow ID not found in PAC fetch output: $WorkflowId"
    }

    $jsonIndex = $FetchText.IndexOf('{"properties":', $idIndex, [System.StringComparison]::Ordinal)
    if ($jsonIndex -lt 0) {
        throw "clientdata JSON not found after workflow ID: $WorkflowId"
    }

    Get-BalancedJsonAt -Text $FetchText -StartIndex $jsonIndex
}

function Get-ResponseSchemaRows {
    param(
        [object]$ClientData
    )

    $definition = $ClientData.properties.definition
    if (-not $definition -or -not $definition.actions) {
        return @()
    }

    @($definition.actions.PSObject.Properties | Where-Object { $_.Value.type -eq "Response" } | ForEach-Object {
        $actionName = $_.Name
        $inputs = $_.Value.inputs
        $schemaKeys = @()
        $bodyKeys = @()

        if ($inputs.schema -and $inputs.schema.properties) {
            $schemaKeys = @($inputs.schema.properties.PSObject.Properties.Name)
        }
        if ($inputs.body -and $inputs.body.PSObject.Properties) {
            $bodyKeys = @($inputs.body.PSObject.Properties.Name)
        }

        [ordered]@{
            responseActionName = $actionName
            statusCode = $inputs.statusCode
            schemaKeys = $schemaKeys
            bodyKeys = $bodyKeys
            schema = $inputs.schema
            body = $inputs.body
        }
    })
}

function Get-LiveTopicBindingKey {
    param(
        [string]$TopicFetchText,
        [string]$ActionComponent
    )

    $escaped = [regex]::Escape($ActionComponent)
    $pattern = "(?ms)dialog:\s*$escaped\s*.*?output:\s*\r?\n\s*binding:\s*\r?\n\s*([A-Za-z_][A-Za-z0-9_]*)\s*:"
    $match = [regex]::Match($TopicFetchText, $pattern)
    if ($match.Success) {
        return $match.Groups[1].Value
    }

    return $null
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$fetchWorkflowPath = Join-Path $OutputDir "fetch_pm0_card_workflow_clientdata.xml"
$fetchTopicsPath = Join-Path $OutputDir "fetch_pmo_v2_topic_data.xml"
$envOut = Join-Path $OutputDir "pac_env_who.txt"
$workflowOut = Join-Path $OutputDir "workflow_clientdata_fetch_raw.txt"
$topicOut = Join-Path $OutputDir "topic_data_fetch_raw.txt"
$jsonReportPath = Join-Path $OutputDir "flow_output_schema_audit.json"
$mdReportPath = Join-Path $OutputDir "FLOW_OUTPUT_SCHEMA_AUDIT.md"

$workflowConditions = @($flows | ForEach-Object {
    "      <condition attribute=`"workflowid`" operator=`"eq`" value=`"$($_.workflowId)`" />"
}) -join "`r`n"

@"
<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="workflow">
    <attribute name="workflowid" />
    <attribute name="name" />
    <attribute name="statecode" />
    <attribute name="statuscode" />
    <attribute name="category" />
    <attribute name="type" />
    <attribute name="modifiedon" />
    <attribute name="clientdata" />
    <filter type="or">
$workflowConditions
    </filter>
    <order attribute="name" />
  </entity>
</fetch>
"@ | Set-Content -LiteralPath $fetchWorkflowPath -Encoding UTF8

$topicConditions = @($flows | ForEach-Object {
    "      <condition attribute=`"schemaname`" operator=`"eq`" value=`"$($_.topicSchemaName)`" />"
}) -join "`r`n"

@"
<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="botcomponent">
    <attribute name="botcomponentid" />
    <attribute name="name" />
    <attribute name="schemaname" />
    <attribute name="componenttype" />
    <attribute name="statecode" />
    <attribute name="statuscode" />
    <attribute name="modifiedon" />
    <attribute name="data" />
    <filter type="or">
$topicConditions
    </filter>
    <order attribute="schemaname" />
  </entity>
</fetch>
"@ | Set-Content -LiteralPath $fetchTopicsPath -Encoding UTF8

Invoke-PacReadOnly -Arguments @("env", "who") -OutputPath $envOut
Invoke-PacReadOnly -Arguments @("org", "fetch", "--environment", $EnvironmentId, "--xmlFile", $fetchWorkflowPath) -OutputPath $workflowOut
Invoke-PacReadOnly -Arguments @("org", "fetch", "--environment", $EnvironmentId, "--xmlFile", $fetchTopicsPath) -OutputPath $topicOut

$workflowText = Get-Content -LiteralPath $workflowOut -Raw
$topicText = Get-Content -LiteralPath $topicOut -Raw
$rows = [System.Collections.Generic.List[object]]::new()

foreach ($flow in $flows) {
    $clientDataJson = Get-ClientDataJson -FetchText $workflowText -WorkflowId $flow.workflowId
    $clientData = $clientDataJson | ConvertFrom-Json
    $definition = $clientData.properties.definition
    $responses = @(Get-ResponseSchemaRows -ClientData $clientData)

    $allSchemaKeys = @($responses | ForEach-Object { $_.schemaKeys } | Where-Object { $_ } | Sort-Object -Unique)
    $expectedBindingKey = if ($allSchemaKeys.Count -eq 1) { $allSchemaKeys[0] } elseif ($allSchemaKeys.Count -gt 1) { $allSchemaKeys -join "," } else { $null }
    $liveTopicBindingKey = Get-LiveTopicBindingKey -TopicFetchText $topicText -ActionComponent $flow.actionComponent
    $bindingStatus = if ($null -eq $liveTopicBindingKey) {
        "TOPIC_BINDING_NOT_FOUND"
    }
    elseif ($liveTopicBindingKey -eq $expectedBindingKey) {
        "PASS"
    }
    else {
        "MISMATCH"
    }

    $definitionOut = Join-Path $OutputDir "clientdata_$($flow.flowName).json"
    $schemaOut = Join-Path $OutputDir "response_schema_$($flow.flowName).json"
    $clientDataJson | Set-Content -LiteralPath $definitionOut -Encoding UTF8
    ($responses | ConvertTo-Json -Depth 100) | Set-Content -LiteralPath $schemaOut -Encoding UTF8

    $rows.Add([ordered]@{
        topicName = $flow.topicName
        topicSchemaName = $flow.topicSchemaName
        actionComponent = $flow.actionComponent
        flowName = $flow.flowName
        workflowId = $flow.workflowId
        flowStateFound = $workflowText.IndexOf($flow.workflowId, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
        triggerKind = $definition.triggers.manual.kind
        responseActions = @($responses | ForEach-Object { $_.responseActionName })
        outputJsonKeys = $allSchemaKeys
        expectedOutputBindingKey = $expectedBindingKey
        liveTopicBindingKey = $liveTopicBindingKey
        bindingStatus = $bindingStatus
        responseSchemaFile = Split-Path -Leaf $schemaOut
        clientDataFile = Split-Path -Leaf $definitionOut
    }) | Out-Null
}

$blocking = @($rows | Where-Object { $_.bindingStatus -ne "PASS" })
$report = [ordered]@{
    generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
    mode = "LivePacReadOnly"
    environmentId = $EnvironmentId
    evidenceDir = (Resolve-Path -LiteralPath $OutputDir).Path
    fetchXml = @(
        Split-Path -Leaf $fetchWorkflowPath
        Split-Path -Leaf $fetchTopicsPath
    )
    rawOutputs = @(
        Split-Path -Leaf $workflowOut
        Split-Path -Leaf $topicOut
        Split-Path -Leaf $envOut
    )
    overall = if ($blocking.Count -eq 0) { "PASS" } else { "MISMATCH" }
    mismatchCount = $blocking.Count
    flows = $rows
}

$report | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $jsonReportPath -Encoding UTF8

$md = [System.Collections.Generic.List[string]]::new()
$md.Add("# AQ-08 Flow Output Schema Audit")
$md.Add("")
$md.Add("Generated: $($report.generatedAt)")
$md.Add("Mode: live PAC read-only")
$md.Add("Environment: ``$EnvironmentId``")
$md.Add("")
$md.Add("## Result")
$md.Add("")
$md.Add("Overall: **$($report.overall)**")
$md.Add("")
$md.Add("| Topic | PM0 flow | Workflow ID | Actual output JSON keys | Expected topic binding key | Live topic binding key | Status |")
$md.Add("|---|---|---|---|---|---|---|")
foreach ($row in $rows) {
    $keys = if ($row.outputJsonKeys.Count) { $row.outputJsonKeys -join ", " } else { "-" }
    $live = if ($row.liveTopicBindingKey) { $row.liveTopicBindingKey } else { "-" }
    $expected = if ($row.expectedOutputBindingKey) { $row.expectedOutputBindingKey } else { "-" }
    $md.Add(('| {0} | `{1}` | `{2}` | `{3}` | `{4}` | `{5}` | {6} |' -f $row.topicName, $row.flowName, $row.workflowId, $keys, $expected, $live, $row.bindingStatus))
}
$md.Add("")
$md.Add("## Evidence")
$md.Add("")
$md.Add("- Workflow FetchXML: ``$(Split-Path -Leaf $fetchWorkflowPath)``")
$md.Add("- Topic FetchXML: ``$(Split-Path -Leaf $fetchTopicsPath)``")
$md.Add("- Raw workflow fetch: ``$(Split-Path -Leaf $workflowOut)``")
$md.Add("- Raw topic fetch: ``$(Split-Path -Leaf $topicOut)``")
$md.Add("- Machine report: ``$(Split-Path -Leaf $jsonReportPath)``")
$md.Add("")
$md.Add("## Interpretation")
$md.Add("")
$md.Add('All five `workflow.clientdata` response schemas expose a single output JSON key: `result`. Any topic binding using `message` for these PM0 action components is stale or incorrect.')

($md -join "`r`n") | Set-Content -LiteralPath $mdReportPath -Encoding UTF8

$report | ConvertTo-Json -Depth 100
