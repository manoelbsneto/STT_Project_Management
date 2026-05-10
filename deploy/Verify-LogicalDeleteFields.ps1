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
$csvPath = Join-Path $outputRoot "logical_delete_fields_verify_$timestamp.csv"
$summaryPath = Join-Path $outputRoot "logical_delete_fields_verify_$timestamp.md"

Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
Import-Module SharePointPnPPowerShellOnline -DisableNameChecking -ErrorAction Stop

if (-not $SkipConnect) {
    Connect-PnPOnline -Url $SiteUrl -UseWebLogin
}

$requiredFields = @("Deleted", "DeletedAt", "DeletedReason", "DeletedByUPN")
$results = [System.Collections.Generic.List[object]]::new()

foreach ($listName in $ListNames) {
    foreach ($fieldName in $requiredFields) {
        try {
            $field = Get-PnPField -List $listName -Identity $fieldName -ErrorAction Stop
            $results.Add([pscustomobject]@{
                ListName = $listName
                Field = $fieldName
                Exists = $true
                Type = $field.TypeAsString
                Indexed = $field.Indexed
                DefaultValue = $field.DefaultValue
                Status = "OK"
            })
        }
        catch {
            $results.Add([pscustomobject]@{
                ListName = $listName
                Field = $fieldName
                Exists = $false
                Type = ""
                Indexed = ""
                DefaultValue = ""
                Status = $_.Exception.Message
            })
        }
    }
}

$results | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8

$missing = @($results | Where-Object { -not $_.Exists })
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("# Logical Delete Field Verification")
$lines.Add("")
$lines.Add("- Timestamp: $((Get-Date).ToString("o"))")
$lines.Add("- Site: $SiteUrl")
$lines.Add("- CSV: $csvPath")
$lines.Add("- Missing fields: $($missing.Count)")
$lines.Add("")
$lines.Add("| List | Field | Exists | Type | Indexed | Default | Status |")
$lines.Add("|---|---|---:|---|---:|---|---|")
foreach ($row in $results) {
    $lines.Add("| $($row.ListName) | $($row.Field) | $($row.Exists) | $($row.Type) | $($row.Indexed) | $($row.DefaultValue) | $($row.Status) |")
}

Set-Content -LiteralPath $summaryPath -Value $lines -Encoding UTF8

Write-Host "Logical delete verification CSV: $csvPath" -ForegroundColor Green
Write-Host "Logical delete verification summary: $summaryPath" -ForegroundColor Green

if ($missing.Count -gt 0) {
    throw "Missing logical delete fields: $($missing.Count)"
}
