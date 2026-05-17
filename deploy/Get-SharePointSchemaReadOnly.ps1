param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string[]]$ListNames = @("Projetos", "Tarefas"),
    [string]$OutputDir = ".planning/comms/sharepoint_schema_2_4_20260511"
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

$result = @()

foreach ($listName in $ListNames) {
    $list = Get-PnPList -Identity $listName -Includes Id,Title,ItemCount,Hidden,BaseTemplate
    $fields = Get-PnPField -List $listName |
        Where-Object {
            -not $_.Hidden -or
            $_.InternalName -in @("ID", "Title", "Created", "Modified", "Author", "Editor")
        } |
        Select-Object Title,InternalName,TypeAsString,Required,ReadOnlyField,Hidden,Choices,DefaultValue

    $sampleFields = @("ID", "Title", "ProjectID", "NomeProjeto", "Deleted", "Ativo", "Status", "Prioridade", "Responsavel", "Prazo", "Created", "Modified")
    $sample = Get-PnPListItem -List $listName -PageSize 20 -Fields $sampleFields |
        Select-Object -First 5 |
        ForEach-Object {
            $values = [ordered]@{}
            foreach ($key in $_.FieldValues.Keys) {
                if ($key -in $sampleFields) {
                    $values[$key] = $_.FieldValues[$key]
                }
            }
            [pscustomobject]$values
        }

    $result += [pscustomobject]@{
        SiteUrl = $SiteUrl
        ListName = $listName
        ListId = $list.Id.Guid
        ItemCount = $list.ItemCount
        BaseTemplate = $list.BaseTemplate
        Fields = $fields
        Sample = $sample
    }
}

$jsonPath = Join-Path $OutputDir "schema_projetos_tarefas.json"
$summaryPath = Join-Path $OutputDir "schema_summary.txt"

$result | ConvertTo-Json -Depth 12 | Set-Content -Path $jsonPath -Encoding UTF8

$summary = New-Object System.Collections.Generic.List[string]
foreach ($entry in $result) {
    $summary.Add(("LIST: {0} ID={1} Items={2}" -f $entry.ListName, $entry.ListId, $entry.ItemCount))
    $summary.Add(($entry.Fields | Select-Object Title,InternalName,TypeAsString,Required,ReadOnlyField | Format-Table -AutoSize | Out-String))
}
$summary | Set-Content -Path $summaryPath -Encoding UTF8

Write-Host "Wrote $jsonPath"
Write-Host "Wrote $summaryPath"
Get-Content -Path $summaryPath
