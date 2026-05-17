param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$ListName = "Tarefas",
    [string]$FieldInternalName = "Status",
    [string]$OutputDir = ".planning\comms\aq07_power_automate_build_20260515\schema_update_20260515\evidence",
    [switch]$SkipConnection,
    [switch]$ConfirmTenantWrite
)

$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"

if (-not $ConfirmTenantWrite) {
    throw "This script changes SharePoint schema. Re-run only after explicit owner approval with -ConfirmTenantWrite."
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking -ErrorAction Stop

if (-not $SkipConnection) {
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
}

$canonicalChoices = @(
    "Pendente",
    "Em Andamento",
    "Concluída",
    "Cancelada",
    "Testes",
    "Piloto e Implantacao",
    "Concluido",
    "Cancelado"
)

$field = Get-PnPField -List $ListName -Identity $FieldInternalName -ErrorAction Stop

if ($field.TypeAsString -ne "Choice") {
    throw "Field $FieldInternalName is $($field.TypeAsString), expected Choice."
}

$beforeChoices = @($field.Choices)
$combinedChoices = New-Object System.Collections.Generic.List[string]

foreach ($choice in $beforeChoices) {
    if (-not [string]::IsNullOrWhiteSpace($choice) -and -not $combinedChoices.Contains($choice)) {
        $combinedChoices.Add($choice) | Out-Null
    }
}

foreach ($choice in $canonicalChoices) {
    if (-not $combinedChoices.Contains($choice)) {
        $combinedChoices.Add($choice) | Out-Null
    }
}

$addedChoices = @($canonicalChoices | Where-Object { $beforeChoices -notcontains $_ })

Set-PnPField -List $ListName -Identity $FieldInternalName -Values @{
    Choices = [string[]]$combinedChoices.ToArray()
    DefaultValue = "Pendente"
    Indexed = $true
} -ErrorAction Stop

$verify = Get-PnPField -List $ListName -Identity $FieldInternalName -ErrorAction Stop

$summary = [pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    taskId = "AQ-07-STATUS-SCHEMA-ALIGNMENT"
    siteUrl = $SiteUrl
    listName = $ListName
    fieldInternalName = $FieldInternalName
    accessType = "SharePoint schema write via legacy PnP"
    tenantWriteConfirmed = $true
    removedChoices = @()
    beforeChoices = $beforeChoices
    requiredChoices = $canonicalChoices
    addedChoices = $addedChoices
    afterChoices = @($verify.Choices)
    defaultValue = $verify.DefaultValue
    indexed = $verify.Indexed
    itemWritesPerformed = 0
}

$summaryPath = Join-Path $OutputDir "aq07_tarefas_status_choices_update_summary.json"
$csvPath = Join-Path $OutputDir "aq07_tarefas_status_choices_after.csv"

$summary |
    ConvertTo-Json -Depth 10 |
    Set-Content -LiteralPath $summaryPath -Encoding UTF8

@($verify.Choices | ForEach-Object {
    [pscustomobject]@{
        ListName = $ListName
        FieldInternalName = $FieldInternalName
        Choice = $_
    }
}) | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

$summary
