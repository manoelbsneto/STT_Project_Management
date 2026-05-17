param(
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$ListName = "Tarefas",
    [string]$OutputDir = ".planning\comms\aq03_tarefas_schema_update_20260515\evidence",
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

$fields = @(
    [pscustomobject]@{
        DisplayName = "Planner Task ID"
        InternalName = "PlannerTaskId"
        Type = "Text"
        Choices = @()
        DefaultValue = $null
        Indexed = $true
    },
    [pscustomobject]@{
        DisplayName = "Planner Bucket ID"
        InternalName = "PlannerBucketId"
        Type = "Text"
        Choices = @()
        DefaultValue = $null
        Indexed = $true
    },
    [pscustomobject]@{
        DisplayName = "Planner Sync Status"
        InternalName = "PlannerSyncStatus"
        Type = "Choice"
        Choices = @("Pendente", "OK", "Erro", "Ignorado")
        DefaultValue = "Pendente"
        Indexed = $true
    },
    [pscustomobject]@{
        DisplayName = "Planner Last Sync At"
        InternalName = "PlannerLastSyncAt"
        Type = "DateTime"
        Choices = @()
        DefaultValue = $null
        Indexed = $false
    },
    [pscustomobject]@{
        DisplayName = "Planner Sync Error"
        InternalName = "PlannerSyncError"
        Type = "Note"
        Choices = @()
        DefaultValue = $null
        Indexed = $false
    }
)

$results = New-Object System.Collections.Generic.List[object]

foreach ($field in $fields) {
    $existing = Get-PnPField -List $ListName -Identity $field.InternalName -ErrorAction SilentlyContinue

    if ($existing) {
        $results.Add([pscustomobject]@{
            InternalName = $field.InternalName
            DisplayName = $field.DisplayName
            Type = $field.Type
            Action = "SkippedExisting"
            FieldId = $existing.Id
        }) | Out-Null
        continue
    }

    if ($field.Type -eq "Choice") {
        Add-PnPField -List $ListName -DisplayName $field.DisplayName -InternalName $field.InternalName -Type Choice -Choices $field.Choices -AddToDefaultView -ErrorAction Stop | Out-Null
    }
    else {
        Add-PnPField -List $ListName -DisplayName $field.DisplayName -InternalName $field.InternalName -Type $field.Type -AddToDefaultView -ErrorAction Stop | Out-Null
    }

    if ($field.DefaultValue) {
        Set-PnPField -List $ListName -Identity $field.InternalName -Values @{ DefaultValue = $field.DefaultValue } -ErrorAction Stop
    }

    if ($field.Indexed) {
        Set-PnPField -List $ListName -Identity $field.InternalName -Values @{ Indexed = $true } -ErrorAction Stop
    }

    $created = Get-PnPField -List $ListName -Identity $field.InternalName -ErrorAction Stop
    $results.Add([pscustomobject]@{
        InternalName = $field.InternalName
        DisplayName = $field.DisplayName
        Type = $field.Type
        Action = "Created"
        FieldId = $created.Id
    }) | Out-Null
}

$verification = foreach ($field in $fields) {
    $current = Get-PnPField -List $ListName -Identity $field.InternalName -ErrorAction Stop
    [pscustomobject]@{
        InternalName = $current.InternalName
        Title = $current.Title
        TypeAsString = $current.TypeAsString
        Required = $current.Required
        Hidden = $current.Hidden
        ReadOnlyField = $current.ReadOnlyField
        DefaultValue = $current.DefaultValue
        Choices = @($current.Choices) -join "|"
        Indexed = $current.Indexed
    }
}

$summary = [pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    siteUrl = $SiteUrl
    listName = $ListName
    accessType = "SharePoint schema write via legacy PnP"
    fieldsRequested = @($fields).Count
    createdCount = @($results | Where-Object { $_.Action -eq "Created" }).Count
    skippedExistingCount = @($results | Where-Object { $_.Action -eq "SkippedExisting" }).Count
    tenantWriteConfirmed = $true
    results = $results
    verification = $verification
}

$summary |
    ConvertTo-Json -Depth 10 |
    Set-Content -LiteralPath (Join-Path $OutputDir "aq03_tarefas_planner_fields_write_summary.json") -Encoding UTF8

$verification |
    Export-Csv -LiteralPath (Join-Path $OutputDir "aq03_tarefas_planner_fields_verify.csv") -NoTypeInformation -Encoding UTF8

$summary
