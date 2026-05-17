param()
# Use the Dataverse API to get the flow definition via the environment where we have access
# First get a token for Dataverse
$envUrl = "https://org7de3c247.crm2.dynamics.com"

# Try using PnP connection
Import-Module PnP.PowerShell -ErrorAction SilentlyContinue

# Alternative: Use Dataverse to query the processworkflow entity
# The flow is a "workflow" in Dataverse
$token = az account get-access-token --resource "$envUrl" --query accessToken -o tsv 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Cannot get Dataverse token via az cli"
    Write-Host "Trying alternate approach - reading flow via Power Automate Management connector..."
    
    # Let's try the management API with the correct tenant
    # The ColOfertasBrasilPro environment tenant is 7808e005-1489-4374-954b-d3b08f193920
    Write-Host ""
    Write-Host "ALTERNATE: Checking flow definition from local export if available..."
    
    # Check if we have any exported flow definition
    $exportPath = "d:\VMs\Projetos\STT_Project_Management\deploy"
    $flowFiles = Get-ChildItem -Path $exportPath -Filter "*.json" -ErrorAction SilentlyContinue
    foreach ($f in $flowFiles) {
        Write-Host "Found: $($f.Name) ($($f.Length) bytes)"
    }
}
