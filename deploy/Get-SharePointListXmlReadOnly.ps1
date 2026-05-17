param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string[]]$ListNames = @(
        "Projetos",
        "Tarefas",
        "Status Diario",
        "Riscos e Bloqueios",
        "Decisoes do Board"
    ),
    [string]$OutputDir = ".planning/comms/sharepoint_schema_xml_20260513"
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking -ErrorAction Stop
Connect-PnPOnline -Url $SiteUrl -UseWebLogin

function ConvertTo-SafeFileName {
    param([string]$Value)
    $invalid = [IO.Path]::GetInvalidFileNameChars()
    $safe = $Value
    foreach ($char in $invalid) {
        $safe = $safe.Replace($char, "_")
    }
    return $safe.Replace(" ", "_")
}

$inventory = New-Object System.Collections.Generic.List[object]

foreach ($listName in $ListNames) {
    $list = Get-PnPList -Identity $listName -Includes Id,Title,ItemCount,Hidden,BaseTemplate,Fields,Views,RootFolder
    $safeListName = ConvertTo-SafeFileName -Value $list.Title
    $listDir = Join-Path $OutputDir $safeListName
    $fieldDir = Join-Path $listDir "fields"
    $viewDir = Join-Path $listDir "views"

    New-Item -ItemType Directory -Force -Path $fieldDir | Out-Null
    New-Item -ItemType Directory -Force -Path $viewDir | Out-Null

    $list.SchemaXml | Set-Content -LiteralPath (Join-Path $listDir "list_schema.xml") -Encoding UTF8

    $fields = Get-PnPField -List $list.Title
    $fieldSummary = New-Object System.Collections.Generic.List[object]

    foreach ($field in $fields) {
        $safeFieldName = ConvertTo-SafeFileName -Value $field.InternalName
        $field.SchemaXml | Set-Content -LiteralPath (Join-Path $fieldDir "$safeFieldName.xml") -Encoding UTF8

        $fieldSummary.Add([pscustomobject]@{
            ListTitle = $list.Title
            Title = $field.Title
            InternalName = $field.InternalName
            TypeAsString = $field.TypeAsString
            Required = $field.Required
            ReadOnlyField = $field.ReadOnlyField
            Hidden = $field.Hidden
            DefaultValue = $field.DefaultValue
            Choices = @($field.Choices) -join "|"
        })
    }

    $views = Get-PnPView -List $list.Title
    foreach ($view in $views) {
        $safeViewName = ConvertTo-SafeFileName -Value $view.Title
        $view.SchemaXml | Set-Content -LiteralPath (Join-Path $viewDir "$safeViewName.xml") -Encoding UTF8
    }

    $fieldSummary |
        Export-Csv -LiteralPath (Join-Path $listDir "fields_summary.csv") -NoTypeInformation -Encoding UTF8

    $fieldSummary |
        ConvertTo-Json -Depth 12 |
        Set-Content -LiteralPath (Join-Path $listDir "fields_summary.json") -Encoding UTF8

    $inventory.Add([pscustomobject]@{
        SiteUrl = $SiteUrl
        Title = $list.Title
        Id = $list.Id.Guid
        ItemCount = $list.ItemCount
        Hidden = $list.Hidden
        BaseTemplate = $list.BaseTemplate
        RootFolder = $list.RootFolder.ServerRelativeUrl
        FieldCount = @($fields).Count
        ViewCount = @($views).Count
        OutputPath = $listDir
    })
}

$inventory |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath (Join-Path $OutputDir "inventory.json") -Encoding UTF8

$inventory |
    Export-Csv -LiteralPath (Join-Path $OutputDir "inventory.csv") -NoTypeInformation -Encoding UTF8

$inventory | Format-Table -AutoSize
Write-Host "Wrote SharePoint list XML evidence to $OutputDir"
