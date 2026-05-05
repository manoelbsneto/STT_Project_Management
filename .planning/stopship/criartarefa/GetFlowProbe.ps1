[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$FlowName = "7ca90102-525b-48bb-875e-0f7bda96f85b",
    [string]$OutputDir = ".planning\stopship\criartarefa"
)

$ErrorActionPreference = "Stop"

$powerAppsModule = "C:\Users\mbenicios\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"
Import-Module $powerAppsModule -ErrorAction Stop

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$topFlows = Get-Flow -EnvironmentName $EnvironmentName -Top 5
$topFlows |
    Select-Object DisplayName, FlowName, Enabled, CreatedTime, LastModifiedTime,
        @{n="State";e={$_.Internal.properties.state}},
        @{n="WorkflowEntityId";e={$_.Internal.properties.workflowEntityId}} |
    ConvertTo-Json -Depth 20 |
    Set-Content -LiteralPath (Join-Path $OutputDir "get_flow_top5_$timestamp.json") -Encoding UTF8

$flow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $FlowName -ErrorAction Stop
$flow |
    ConvertTo-Json -Depth 100 |
    Set-Content -LiteralPath (Join-Path $OutputDir "get_flow_criartarefa_$timestamp.json") -Encoding UTF8

$definition = $flow.Internal.properties.definition
$summary = [ordered]@{
    timestamp = (Get-Date).ToString("o")
    displayName = $flow.DisplayName
    flowName = $flow.FlowName
    enabled = $flow.Enabled
    state = $flow.Internal.properties.state
    workflowEntityId = $flow.Internal.properties.workflowEntityId
    triggerNames = @($definition.triggers.PSObject.Properties.Name)
    actionNames = @($definition.actions.PSObject.Properties.Name)
    successResponseBody = $definition.actions.Response_Success.inputs.body
    errorResponseBody = $definition.actions.Response_Error.inputs.body
    triggerSchema = $definition.triggers.Copilot_CriarTarefa_Request.inputs.schema
}

$summary |
    ConvertTo-Json -Depth 100 |
    Set-Content -LiteralPath (Join-Path $OutputDir "get_flow_criartarefa_summary_$timestamp.json") -Encoding UTF8

$summary | ConvertTo-Json -Depth 100
