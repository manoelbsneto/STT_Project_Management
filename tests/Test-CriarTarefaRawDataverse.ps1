[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$FetchLogPath,

    [string]$BotSchema = "pmo_AssistentePMO_Clean",

    [switch]$ExpectFailure
)

$ErrorActionPreference = "Stop"

$resolvedFetchLogPath = (Resolve-Path -LiteralPath $FetchLogPath).Path
$text = Get-Content -LiteralPath $resolvedFetchLogPath -Raw
$topicStart = $text.IndexOf("$BotSchema.topic.CriarTarefa", [System.StringComparison]::Ordinal)
$topicText = ""
if ($topicStart -ge 0) {
    $nextComponent = $text.IndexOf("`n$BotSchema.", $topicStart + 1, [System.StringComparison]::Ordinal)
    if ($nextComponent -lt 0) {
        $nextComponent = $text.Length
    }
    $topicText = $text.Substring($topicStart, $nextComponent - $topicStart)
}

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

$internalRef = "dialog: $BotSchema.action.PMO_PA_CriarTarefa"
$templateRef = "dialog: template-content.action.PMO_PA_CriarTarefa"

Add-Check "Raw CriarTarefa topic row found" ($topicText.Length -gt 0) "$BotSchema.topic.CriarTarefa"
Add-Check "Raw CriarTarefa uses internal action schema" ($topicText -match [regex]::Escape($internalRef)) $internalRef
Add-Check "Raw CriarTarefa does not use template export alias" ($topicText -notmatch [regex]::Escape($templateRef)) $templateRef
Add-Check "Raw CriarTarefa has no old bot schema reference" ($topicText -notmatch "pmo_AssistentePMO(?!_Clean)\.") "Deleted original bot schema must not be referenced by active topic data."
Add-Check "Raw CriarTarefa has no fragile action output binding" (-not ($topicText -match "(?ms)id:\s*call_criar_tarefa.*?output:\s*")) "No output block under call_criar_tarefa."
Add-Check "Raw CriarTarefa has no direct CloudFlow topic binding" ($topicText -notmatch "kind:\s*InvokeFlowAction|flowId:\s*[0-9a-f-]{36}") "Topic must call the _Clean TaskDialog action instead of binding directly to a CloudFlow."
Add-Check "Raw CriarTarefa has no stale Topic.message" ($topicText -notmatch "Topic\.message") "No Topic.message reference."
$mojibakePattern = "$([char]0x00F0)|$([char]0x00C3)|$([char]0x00E2)|$([char]0x00C2)|$([char]0xFFFD)"
Add-Check "Raw CriarTarefa has no mojibake" ($topicText -notmatch $mojibakePattern) "No corrupt UTF-8 sequences in imported topic data."
Add-Check "Raw CriarTarefa reads the original user message" ($topicText -match [regex]::Escape("value: =System.Activity.Text")) "Parser source is System.Activity.Text."
Add-Check "Raw CriarTarefa uses ASCII-safe title regex" ($topicText -match [regex]::Escape('"t.tulo\s*[:=]\s*(?<v>[^,\r\n]+)"')) "Title parser accepts Titulo and Titulo with accent by wildcard."
Add-Check "Raw CriarTarefa uses ASCII-safe responsavel regex" ($topicText -match [regex]::Escape('"respons.vel\s*[:=]\s*(?<v>[^,\r\n]+)"')) "Responsavel parser accepts accented and non-accented labels."

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    fetchLogPath = $resolvedFetchLogPath
    expectedFailureMode = [bool]$ExpectFailure
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10

if ($ExpectFailure) {
    if ($failed.Count -eq 0) {
        throw "Expected failure, but all checks passed."
    }
    exit 0
}

if ($failed.Count -gt 0) {
    throw "CriarTarefa raw Dataverse test failed: $($failed.name -join '; ')"
}
