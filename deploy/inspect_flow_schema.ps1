param()
$ErrorActionPreference = 'Stop'

# Get Azure access token for Flow API
$token = (Get-AzAccessToken -ResourceUrl 'https://service.flow.microsoft.com').Token
$envId = 'e2d10003-4d8e-e007-9d63-76d5fe89ef56'
$flowId = '89050663-1163-b36c-659b-6fcaa0edfee0'

$uri = "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/$envId/flows/${flowId}?api-version=2016-11-01"
$resp = Invoke-RestMethod -Uri $uri -Headers @{Authorization="Bearer $token"} -Method GET

Write-Host "=== FLOW NAME ==="
Write-Host $resp.properties.displayName

Write-Host "`n=== TRIGGER SCHEMA (inputs to the flow) ==="
$triggerSchema = $resp.properties.definition.triggers.manual.inputs.schema
$triggerSchema | ConvertTo-Json -Depth 10

Write-Host "`n=== ALL ACTIONS ==="
$actions = $resp.properties.definition.actions
foreach ($key in $actions.PSObject.Properties.Name) {
    $action = $actions.$key
    Write-Host "Action: $key | Type: $($action.type)"
}

Write-Host "`n=== RESPOND TO AGENT ACTION (output schema) ==="
# Find the Respond action - it could have various names
foreach ($key in $actions.PSObject.Properties.Name) {
    $action = $actions.$key
    if ($action.type -eq 'Response' -or $key -like '*retornados*' -or $key -like '*respond*' -or $key -like '*Valores*') {
        Write-Host "Found response action: $key"
        Write-Host "Full inputs:"
        $action.inputs | ConvertTo-Json -Depth 10
        Write-Host "`nSchema:"
        $action.inputs.schema | ConvertTo-Json -Depth 10
    }
}

Write-Host "`n=== RAW DEFINITION (last 3 actions) ==="
$resp.properties.definition | ConvertTo-Json -Depth 15 | Out-File -FilePath "d:\VMs\Projetos\STT_Project_Management\deploy\flow_v3_definition.json" -Encoding UTF8
Write-Host "Full definition saved to deploy\flow_v3_definition.json"
