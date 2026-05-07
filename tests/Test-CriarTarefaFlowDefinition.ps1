[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path,

    [switch]$AllowRuntimeRawAuthentication
)

$ErrorActionPreference = "Stop"

$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$text = Get-Content -LiteralPath $resolvedPath -Raw

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

Add-Check "Flow uses GUID-based ProjectID composer" ($text -match "Compose_ProjectID" -and $text -match "guid\(\)") "ProjectID must not depend on reading the latest SharePoint item."
Add-Check "Flow no longer reads latest SharePoint project" ($text -notmatch "Get_Existing_Projects") "No GetItems top 1/order by ID desc ProjectID generation."
Add-Check "Flow no longer increments Compose_New_ProjectID" ($text -notmatch "Compose_New_ProjectID") "No race-prone sequential increment expression."
$mojibakePattern = "$([char]0x00F0)|$([char]0x00C3)|$([char]0x00E2)|$([char]0x00C2)|$([char]0xFFFD)"
Add-Check "Flow has no priority mojibake" ($text -notmatch $mojibakePattern) "No corrupt UTF-8 priority literals."
Add-Check "Flow text is ASCII-only" ($text -notmatch "[^\x00-\x7F]") "Flow text must avoid accents, emoji, cedilla, and special punctuation."
Add-Check "Flow requires horas" ($text -match '"horas"') "Contract includes horas as an input/required field."
Add-Check "Flow normalizes pt-BR date" ($text -match "Compose_DataAlvo") "Date normalization compose exists."
Add-Check "Flow normalizes priority without accented literals" ($text -match "Map_Prioridade" -and $text -match "startsWith\(toLower") "Priority mapping uses ASCII-safe prefix matching."
Add-Check "Flow checks duplicate project before create" ($text -match "Get_Duplicate_Projects" -and $text -match "Condition_Duplicate_Projeto") "Repeated same NomeProjeto/DataAlvo requests should return the existing project."
Add-Check "Flow has duplicate response branch" ($text -match "Response_Duplicate" -and $text -match "Nenhum item duplicado foi criado") "Duplicate branch must not create another SharePoint item."

if (-not $AllowRuntimeRawAuthentication) {
    Add-Check "Workflow package uses parameter authentication" ($text -match [regex]::Escape('"authentication": "@parameters(''$authentication'')"')) "Solution package should use supported connection parameter authentication."
    Add-Check "Workflow package has no raw APIM token auth" ($text -notmatch "X-MS-APIM-Tokens|ConnectionKey") "Source package must not use raw APIM token auth."
}

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    path = $resolvedPath
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10

if ($failed.Count -gt 0) {
    throw "CriarTarefa flow definition test failed: $($failed.name -join '; ')"
}
