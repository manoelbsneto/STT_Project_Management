param()
$ErrorActionPreference = 'Stop'

$siteUrl = 'https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital'
Connect-PnPOnline -Url $siteUrl -UseWebLogin

$listName = 'Projetos'
$idsToDelete = @(6, 12, 13)
$upn = 'mbenicios@minsait.com'
$timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'

Write-Host "`n=== MARKING TEST PROJECTS AS DELETED ==="
foreach ($id in $idsToDelete) {
    $item = Get-PnPListItem -List $listName -Id $id
    $nome = $item['NomeProjeto']
    Write-Host "Processing ID=$id | Nome=$nome ..."
    
    Set-PnPListItem -List $listName -Identity $id -Values @{
        'Deleted'       = $true
        'DeletedAt'     = $timestamp
        'DeletedReason' = 'Test/trash data cleanup - Session 18'
        'DeletedByUPN'  = $upn
    } | Out-Null
    
    Write-Host "  -> Marked Deleted=Yes | DeletedAt=$timestamp"
}

Write-Host "`n=== VERIFICATION ==="
$active = Get-PnPListItem -List $listName -PageSize 200 | Where-Object { $_['Deleted'] -ne $true }
Write-Host "Active projects remaining: $($active.Count)"
foreach ($item in $active) {
    $id = $item.Id
    $nome = $item['NomeProjeto']
    Write-Host "  ID=$id | Nome=$nome"
}

$deleted = Get-PnPListItem -List $listName -PageSize 200 | Where-Object { $_['Deleted'] -eq $true }
Write-Host "`nDeleted projects total: $($deleted.Count)"

Write-Host "`nDONE."
