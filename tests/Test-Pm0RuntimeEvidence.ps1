[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$EvidencePath,
    [string]$ReportPath = ""
)

$ErrorActionPreference = "Stop"

$targets = @(
    [ordered]@{ id = "AtualizarStatus"; aliases = @("AtualizarStatus", "PM0_PA_Card_AtualizarStatus", "A5_CMD-10") },
    [ordered]@{ id = "AtualizarTarefa"; aliases = @("AtualizarTarefa", "PM0_PA_Card_AtualizarTarefa", "A4_CMD-13A") },
    [ordered]@{ id = "ConsultarPortfolio"; aliases = @("ConsultarPortfolio", "ResumoExecutivoPortfolio", "PM0_PA_Card_ResumoExecutivoPortfolio", "A2_CMD-15") },
    [ordered]@{ id = "CriarTarefa"; aliases = @("CriarTarefa", "PM0_PA_Card_CriarTarefa", "A3_CMD-11-P0") },
    [ordered]@{ id = "ListarTarefas"; aliases = @("ListarTarefas", "PM0_PA_Card_ListarTarefas", "A1_CMD-12-H") }
)

function Get-FieldValue {
    param([string]$Content, [string]$FieldName)
    $escaped = [regex]::Escape($FieldName)
    $patterns = @(
        "(?im)^\s*-\s*$escaped\s*:\s*(?<value>.*?)\s*$",
        "(?im)^\s*$escaped\s*:\s*(?<value>.*?)\s*$",
        "(?im)^\s*\|\s*$escaped\s*\|\s*(?<value>.*?)\s*\|"
    )

    foreach ($pattern in $patterns) {
        $match = [regex]::Match($Content, $pattern)
        if ($match.Success) {
            return $match.Groups["value"].Value.Trim()
        }
    }

    return $null
}

function Test-NonEmpty {
    param([string]$Value)
    return ($null -ne $Value -and $Value.Trim().Length -gt 0 -and $Value.Trim() -ne "-")
}

function Get-MatchingFiles {
    param([object]$Target, [System.IO.FileInfo[]]$Files)
    @($Files | Where-Object {
        $name = $_.Name
        foreach ($alias in $Target.aliases) {
            if ($name -like "*$alias*") {
                return $true
            }
        }
        return $false
    } | Sort-Object FullName)
}

function Test-EvidenceFile {
    param([object]$Target, [System.IO.FileInfo]$File)

    $content = Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8
    $agent = Get-FieldValue -Content $content -FieldName "agent"
    if (-not (Test-NonEmpty $agent)) { $agent = Get-FieldValue -Content $content -FieldName "executor" }
    if (-not (Test-NonEmpty $agent)) { $agent = Get-FieldValue -Content $content -FieldName "operator" }

    $timestamp = Get-FieldValue -Content $content -FieldName "timestamp_brt"
    if (-not (Test-NonEmpty $timestamp)) { $timestamp = Get-FieldValue -Content $content -FieldName "date_brt" }

    $screenshot = Get-FieldValue -Content $content -FieldName "screenshot"
    if (-not (Test-NonEmpty $screenshot)) { $screenshot = Get-FieldValue -Content $content -FieldName "screenshot_path" }
    if (-not (Test-NonEmpty $screenshot)) { $screenshot = Get-FieldValue -Content $content -FieldName "path" }

    $run = Get-FieldValue -Content $content -FieldName "run_url_or_id"
    if (-not (Test-NonEmpty $run)) { $run = Get-FieldValue -Content $content -FieldName "flow_run_id" }
    if (-not (Test-NonEmpty $run)) { $run = Get-FieldValue -Content $content -FieldName "run_id" }

    $expected = Get-FieldValue -Content $content -FieldName "expected_result"
    if (-not (Test-NonEmpty $expected)) { $expected = Get-FieldValue -Content $content -FieldName "expected" }

    $observed = Get-FieldValue -Content $content -FieldName "observed_result"
    if (-not (Test-NonEmpty $observed)) { $observed = Get-FieldValue -Content $content -FieldName "observed" }

    $result = Get-FieldValue -Content $content -FieldName "result"
    $hasTranscript = ($content -match "(?is)<!--\s*TRANSCRIPT\s+BEGIN\s*-->.+<!--\s*TRANSCRIPT\s+END\s*-->") -or ($content -match "(?im)^\s*transcript\s*:")

    $missing = [System.Collections.Generic.List[string]]::new()
    if (-not (Test-NonEmpty $agent)) { $missing.Add("agent") | Out-Null }
    if (-not (Test-NonEmpty $timestamp) -or $timestamp -notmatch "BRT") { $missing.Add("timestamp_brt") | Out-Null }
    if (-not (Test-NonEmpty $screenshot)) { $missing.Add("screenshot") | Out-Null }
    if (-not (Test-NonEmpty $run)) { $missing.Add("run_url_or_id") | Out-Null }
    if (-not (Test-NonEmpty $expected)) { $missing.Add("expected_result") | Out-Null }
    if (-not (Test-NonEmpty $observed)) { $missing.Add("observed_result") | Out-Null }
    if (-not (Test-NonEmpty $result) -or $result -notmatch "^(PASS|FAIL|BLOCK|NOT_RUN)$") { $missing.Add("result") | Out-Null }
    if (-not $hasTranscript) { $missing.Add("transcript") | Out-Null }

    $status = if ($missing.Count -eq 0 -and $result -eq "PASS") { "PASS" } elseif ($missing.Count -eq 0) { "FAIL_RESULT_NOT_PASS" } else { "FAIL_MISSING_REQUIRED_FIELD" }

    [ordered]@{
        id = $Target.id
        status = $status
        selectedEvidenceFile = $File.FullName
        missingFields = @($missing)
        agent = $agent
        timestampBrt = $timestamp
        runUrlOrId = $run
        result = $result
    }
}

$resolvedEvidencePath = if (Test-Path -LiteralPath $EvidencePath) {
    (Resolve-Path -LiteralPath $EvidencePath).Path
}
else {
    $EvidencePath
}

$files = @()
if (Test-Path -LiteralPath $EvidencePath -PathType Container) {
    $files = @(Get-ChildItem -LiteralPath $EvidencePath -Recurse -File -Include *.md,*.txt,*.json,*.log)
}
elseif (Test-Path -LiteralPath $EvidencePath -PathType Leaf) {
    $files = @(Get-Item -LiteralPath $EvidencePath)
}

$results = [System.Collections.Generic.List[object]]::new()
foreach ($target in $targets) {
    $matched = @(Get-MatchingFiles -Target $target -Files $files)
    if ($matched.Count -eq 0) {
        $results.Add([ordered]@{
            id = $target.id
            status = "FAIL_MISSING_EVIDENCE"
            selectedEvidenceFile = $null
            missingFields = @("evidence_file")
        }) | Out-Null
        continue
    }

    $results.Add((Test-EvidenceFile -Target $target -File $matched[0])) | Out-Null
}

$failures = @($results | Where-Object { $_.status -ne "PASS" })
$decision = if ($failures.Count -eq 0) { "PASS_PM0_RUNTIME_EVIDENCE_COMPLETE" } else { "FAIL_PM0_RUNTIME_EVIDENCE_INCOMPLETE" }

$report = [ordered]@{
    evidencePath = $resolvedEvidencePath
    generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
    decision = $decision
    failureCount = $failures.Count
    results = $results
}

$json = $report | ConvertTo-Json -Depth 12
if ($ReportPath) {
    $parent = Split-Path -Parent $ReportPath
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $ReportPath -Value $json -Encoding UTF8
}

$json

if ($decision -ne "PASS_PM0_RUNTIME_EVIDENCE_COMPLETE") {
    throw "PM0 runtime evidence validation failed: $decision; failures: $($failures.id -join ', ')"
}
