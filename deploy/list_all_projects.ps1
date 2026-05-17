param()
$ErrorActionPreference = 'Stop'

$siteUrl = 'https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital'
Connect-PnPOnline -Url $siteUrl -UseWebLogin

Write-Host "`n=== ALL PROJETOS RECORDS ==="
$items = Get-PnPListItem -List 'Projetos' -PageSize 200
foreach ($item in $items) {
    $id = $item.Id
    $deleted = $item['Deleted']
    $nome = $item['NomeProjeto']
    $projId = $item['ProjectID']
    $created = $item['Created']
    Write-Host "ID=$id | Deleted=$deleted | ProjectID=$projId | Nome=$nome | Created=$created"
}
Write-Host "`nTotal: $($items.Count) records"

Write-Host "`n=== PROJETOS WHERE Deleted != Yes (active/visible) ==="
$active = $items | Where-Object { $_['Deleted'] -ne $true }
foreach ($item in $active) {
    $id = $item.Id
    $nome = $item['NomeProjeto']
    $projId = $item['ProjectID']
    Write-Host "ID=$id | ProjectID=$projId | Nome=$nome"
}
Write-Host "`nActive: $($active.Count) records"

Write-Host "`n=== PROJETOS WHERE Deleted = Yes (already flagged) ==="
$deleted = $items | Where-Object { $_['Deleted'] -eq $true }
foreach ($item in $deleted) {
    $id = $item.Id
    $nome = $item['NomeProjeto']
    Write-Host "ID=$id | Nome=$nome"
}
Write-Host "`nDeleted: $($deleted.Count) records"
