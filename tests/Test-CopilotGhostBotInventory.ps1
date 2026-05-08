[CmdletBinding()]
param(
    [string]$Path = "deploy\Discover-GhostBotComponents.ps1"
)

$ErrorActionPreference = "Stop"
$resolvedPath = (Resolve-Path -LiteralPath $Path).Path
$script = Get-Content -LiteralPath $resolvedPath -Raw

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

Add-Check "Script queries botcomponent" ($script -match '<entity name="botcomponent">') "Ghost discovery must target Dataverse botcomponent rows."
Add-Check "Script filters pmo_AssistentePMO" ($script -match 'pmo_AssistentePMO|NameFilter') "Ghost discovery must support the legacy bot schema/name filter."
Add-Check "Script writes FetchXML evidence" ($script -match 'ghost_botcomponents_fetchxml') "Discovery must leave reviewable FetchXML evidence."
Add-Check "Script uses pac fetch only" ($script -match 'org"\s*,\s*"fetch"') "Read-only Dataverse query should use fetch, not mutation."
Add-Check "Script does not delete Dataverse rows" ($script -notmatch '(?i)\b(remove|delete|deactivate|update|patch)\b.*botcomponent') "Deletion requires Human/Admin approval and must not be in this script."
Add-Check "Script documents human approval gate" ($script -match 'Human/Admin approval') "Report must state deletion is a human/admin gate."

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    scriptPath = $resolvedPath
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10

if ($failed.Count -gt 0) {
    throw "Ghost bot discovery test failed: $($failed.name -join '; ')"
}
