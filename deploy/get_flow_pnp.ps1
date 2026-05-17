param()
# Use PnP to get flow definition from Power Automate
# PnP has cmdlets for Power Automate flows

Import-Module PnP.PowerShell -ErrorAction SilentlyContinue

# Connect to the environment
$siteUrl = "https://indfrj.sharepoint.com/sites/ColOfertasBrasilPro"
Connect-PnPOnline -Url $siteUrl -Interactive -ErrorAction SilentlyContinue

# Get the environment ID
$envId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56"

# List flows to find V3
Write-Host "=== Listing flows ==="
$flows = Get-PnPFlow -Environment $envId -ErrorAction SilentlyContinue
if ($flows) {
    foreach ($f in $flows) {
        if ($f.properties.displayName -like "*CriarTarefa*") {
            Write-Host "Found: $($f.properties.displayName) | ID: $($f.name)"
            
            # Get flow details
            $detail = Get-PnPFlow -Environment $envId -Identity $f.name -ErrorAction SilentlyContinue
            if ($detail) {
                Write-Host ""
                Write-Host "=== FLOW DEFINITION ==="
                
                # Get the definition actions
                $def = $detail.properties.definition
                
                # List all actions
                Write-Host "Actions:"
                foreach ($k in $def.actions.PSObject.Properties.Name) {
                    $act = $def.actions.$k
                    Write-Host "  $k => type=$($act.type)"
                    
                    # If it's a Response action, show its body schema
                    if ($act.type -eq "Response") {
                        Write-Host "  >>> RESPONSE ACTION FOUND <<<"
                        Write-Host "  Body:"
                        $act.inputs.body | ConvertTo-Json -Depth 5
                        Write-Host "  Schema:"
                        if ($act.inputs.schema) {
                            $act.inputs.schema | ConvertTo-Json -Depth 5
                        }
                        # Check the statusCode  
                        Write-Host "  StatusCode: $($act.inputs.statusCode)"
                    }
                }
                
                # Also check trigger inputs  
                Write-Host ""
                Write-Host "=== TRIGGER ==="
                foreach ($k in $def.triggers.PSObject.Properties.Name) {
                    $t = $def.triggers.$k
                    Write-Host "Trigger: $k | type=$($t.type)"
                    if ($t.inputs.schema.properties) {
                        foreach ($p in $t.inputs.schema.properties.PSObject.Properties.Name) {
                            $prop = $t.inputs.schema.properties.$p
                            Write-Host "  Input: $p (type=$($prop.type), hint=$($prop.'x-ms-content-hint'))"
                        }
                    }
                }
            }
        }
    }
} else {
    Write-Host "No flows found or access denied"
    Write-Host "Trying Get-PnPFlow with AsAdmin..."
    $flows = Get-PnPFlow -Environment $envId -AsAdmin -ErrorAction SilentlyContinue
    if ($flows) {
        foreach ($f in $flows) {
            if ($f.properties.displayName -like "*CriarTarefa*") {
                Write-Host "Found: $($f.properties.displayName) | ID: $($f.name)"
            }
        }
    } else {
        Write-Host "Still no access."
    }
}
