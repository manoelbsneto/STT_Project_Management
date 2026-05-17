param()
$token = az account get-access-token --resource https://service.flow.microsoft.com --query accessToken -o tsv
$envId = 'e2d10003-4d8e-e007-9d63-76d5fe89ef56'
$flowId = '89050663-1163-b36c-659b-6fcaa0edfee0'

$uri = "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/$envId/flows/$flowId`?api-version=2016-11-01"
$headers = @{ Authorization = "Bearer $token" }
$resp = Invoke-RestMethod -Uri $uri -Headers $headers -Method GET

Write-Host "FLOW NAME: $($resp.properties.displayName)"
Write-Host ""

# Save full definition
$resp.properties.definition | ConvertTo-Json -Depth 20 | Set-Content "d:\VMs\Projetos\STT_Project_Management\deploy\flow_def.json" -Encoding UTF8

# List all actions
Write-Host "=== ACTIONS ==="
foreach ($k in $resp.properties.definition.actions.PSObject.Properties.Name) {
    Write-Host "  $k  =>  type=$($resp.properties.definition.actions.$k.type)"
}

# Find Response action and show its schema
Write-Host ""
Write-Host "=== RESPONSE ACTION OUTPUT SCHEMA ==="
foreach ($k in $resp.properties.definition.actions.PSObject.Properties.Name) {
    $act = $resp.properties.definition.actions.$k
    if ($act.type -eq 'Response') {
        Write-Host "Action name: $k"
        Write-Host "Body:"
        $act.inputs.body | ConvertTo-Json -Depth 10
        Write-Host "Schema:"
        if ($act.inputs.schema) {
            $act.inputs.schema | ConvertTo-Json -Depth 10
        }
    }
}

# Also check trigger inputs
Write-Host ""
Write-Host "=== TRIGGER INPUT SCHEMA ==="
$trig = $resp.properties.definition.triggers
foreach ($k in $trig.PSObject.Properties.Name) {
    $t = $trig.$k
    Write-Host "Trigger: $k"
    if ($t.inputs.schema.properties) {
        foreach ($p in $t.inputs.schema.properties.PSObject.Properties.Name) {
            $prop = $t.inputs.schema.properties.$p
            Write-Host "  Input param: $p  (type=$($prop.type), title=$($prop.'x-ms-content-hint'))"
        }
    }
}
