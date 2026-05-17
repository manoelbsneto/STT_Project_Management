[CmdletBinding()]
param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string[]]$ListNames = @(
        "Projetos",
        "Tarefas",
        "Status Diario",
        "Riscos e Bloqueios",
        "Decisoes do Board"
    ),
    [switch]$SkipConnection
)

$ErrorActionPreference = "Stop"

if (-not $SkipConnection) {
    Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
}

if (-not (Get-Module SharePointPnPPowerShellOnline)) {
    Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
}

if (-not $SkipConnection) {
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
}

function Ensure-Field {
    param(
        [string]$ListName,
        [string]$InternalName,
        [string]$DisplayName,
        [string]$Type,
        [string]$Xml
    )

    $existing = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
    if ($existing) {
        return [pscustomobject]@{
            List = $ListName
            Field = $InternalName
            Action = "Exists"
        }
    }

    if ($Xml) {
        Add-PnPFieldFromXml -List $ListName -FieldXml $Xml | Out-Null
    }
    else {
        Add-PnPField -List $ListName -DisplayName $DisplayName -InternalName $InternalName -Type $Type | Out-Null
    }

    [pscustomobject]@{
        List = $ListName
        Field = $InternalName
        Action = "Created"
    }
}

$results = [System.Collections.Generic.List[object]]::new()

foreach ($listName in $ListNames) {
    Write-Host "Configuring logical delete fields on $listName"

    $results.Add((Ensure-Field `
        -ListName $listName `
        -InternalName "Deleted" `
        -DisplayName "Deleted" `
        -Type Boolean `
        -Xml "<Field Type='Boolean' DisplayName='Deleted' Name='Deleted' StaticName='Deleted'><Default>0</Default></Field>")) | Out-Null

    $results.Add((Ensure-Field `
        -ListName $listName `
        -InternalName "DeletedAt" `
        -DisplayName "DeletedAt" `
        -Type DateTime `
        -Xml "<Field Type='DateTime' DisplayName='DeletedAt' Name='DeletedAt' StaticName='DeletedAt' Format='DateTime' />")) | Out-Null

    $results.Add((Ensure-Field `
        -ListName $listName `
        -InternalName "DeletedReason" `
        -DisplayName "DeletedReason" `
        -Type Note `
        -Xml $null)) | Out-Null

    $results.Add((Ensure-Field `
        -ListName $listName `
        -InternalName "DeletedByUPN" `
        -DisplayName "DeletedByUPN" `
        -Type Text `
        -Xml $null)) | Out-Null

    Set-PnPField -List $listName -Identity "Deleted" -Values @{ Indexed = $true } -ErrorAction SilentlyContinue

    $items = Get-PnPListItem -List $listName -PageSize 500 -Fields "Deleted" -ErrorAction Stop
    foreach ($item in $items) {
        if ($null -eq $item["Deleted"]) {
            Set-PnPListItem -List $listName -Identity $item.Id -Values @{ Deleted = $false } -SystemUpdate | Out-Null
        }
    }
}

$results | Format-Table -AutoSize
