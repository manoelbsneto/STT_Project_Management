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
    [string]$OutputDir = ".planning\cleanup",
    [switch]$SkipConnect
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$outputRoot = Join-Path $repoRoot $OutputDir
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logPath = Join-Path $outputRoot "logical_delete_fields_$timestamp.csv"
$summaryPath = Join-Path $outputRoot "logical_delete_fields_$timestamp.md"

function Import-PnPLegacyModule {
    Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
    Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop
}

function Test-PMOFieldExists {
    param(
        [Parameter(Mandatory)]
        [string]$ListName,
        [Parameter(Mandatory)]
        [string]$InternalName
    )

    try {
        Get-PnPField -List $ListName -Identity $InternalName -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Add-PMOFieldIfMissing {
    param(
        [Parameter(Mandatory)]
        [string]$ListName,
        [Parameter(Mandatory)]
        [string]$InternalName,
        [Parameter(Mandatory)]
        [string]$DisplayName,
        [Parameter(Mandatory)]
        [ValidateSet("Boolean", "DateTime", "Text")]
        [string]$Type
    )

    if (Test-PMOFieldExists -ListName $ListName -InternalName $InternalName) {
        return "Exists"
    }

    if ($Type -eq "Boolean") {
        Add-PnPFieldFromXml -List $ListName -FieldXml "<Field Type='Boolean' DisplayName='$DisplayName' Name='$InternalName' StaticName='$InternalName'><Default>0</Default></Field>" | Out-Null
        Set-PnPField -List $ListName -Identity $InternalName -Values @{ Indexed = $true } -ErrorAction Stop
    }
    else {
        Add-PnPField -List $ListName -DisplayName $DisplayName -InternalName $InternalName -Type $Type -ErrorAction Stop | Out-Null
    }

    return "Created"
}

function Initialize-PMODeletedDefault {
    param([Parameter(Mandatory)][string]$ListName)

    $updated = 0
    $items = Get-PnPListItem -List $ListName -PageSize 500 -Fields "Deleted" -ErrorAction Stop
    foreach ($item in $items) {
        if ($null -eq $item["Deleted"]) {
            Set-PnPListItem -List $ListName -Identity $item.Id -Values @{ Deleted = $false } -SystemUpdate -ErrorAction Stop | Out-Null
            $updated++
        }
    }

    return $updated
}

Import-PnPLegacyModule

if (-not $SkipConnect) {
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
}

$results = [System.Collections.Generic.List[object]]::new()

foreach ($listName in $ListNames) {
    Write-Host "Processing list: $listName" -ForegroundColor Cyan

    $fields = @(
        @{ InternalName = "Deleted"; DisplayName = "Deleted"; Type = "Boolean" },
        @{ InternalName = "DeletedAt"; DisplayName = "DeletedAt"; Type = "DateTime" },
        @{ InternalName = "DeletedReason"; DisplayName = "DeletedReason"; Type = "Text" },
        @{ InternalName = "DeletedByUPN"; DisplayName = "DeletedByUPN"; Type = "Text" }
    )

    foreach ($field in $fields) {
        $status = Add-PMOFieldIfMissing `
            -ListName $listName `
            -InternalName $field.InternalName `
            -DisplayName $field.DisplayName `
            -Type $field.Type

        $results.Add([pscustomobject]@{
            Timestamp = (Get-Date).ToString("o")
            ListName = $listName
            Field = $field.InternalName
            Type = $field.Type
            Status = $status
            SiteUrl = $SiteUrl
        })
    }

    $defaulted = Initialize-PMODeletedDefault -ListName $listName
    $results.Add([pscustomobject]@{
        Timestamp = (Get-Date).ToString("o")
        ListName = $listName
        Field = "Deleted"
        Type = "Boolean"
        Status = "DefaultedNullItems:$defaulted"
        SiteUrl = $SiteUrl
    })
}

$results | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $logPath

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Logical Delete Fields Evidence")
$lines.Add("")
$summaryTimestamp = (Get-Date).ToString("o")
$lines.Add("- Timestamp: $summaryTimestamp")
$lines.Add("- Site: $SiteUrl")
$lines.Add(("- CSV: {0}" -f $logPath))
$lines.Add("")
$lines.Add("| List | Field | Type | Status |")
$lines.Add("|---|---|---|---|")
foreach ($row in $results) {
    $lines.Add("| $($row.ListName) | $($row.Field) | $($row.Type) | $($row.Status) |")
}

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

Write-Host "Logical delete field evidence CSV: $logPath" -ForegroundColor Green
Write-Host "Logical delete field evidence summary: $summaryPath" -ForegroundColor Green
