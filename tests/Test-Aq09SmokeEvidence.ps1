[CmdletBinding()]
param(
    [string]$EvidenceDir = ".planning\comms\aq09_smoke_runbook_20260520\evidence",
    [string]$ReportPath = ".planning\comms\xpia_01_verify_20260520\Aq09SmokeEvidenceValidation.json"
)

$ErrorActionPreference = "Stop"

$inScope = @(
    [ordered]@{ id = "A1_CMD-12-H"; aliases = @("A1_CMD-12-H", "CMD-12-H", "ListarTarefas") },
    [ordered]@{ id = "A2_CMD-15"; aliases = @("A2_CMD-15", "CMD-15", "ConsultarPortfolio") },
    [ordered]@{ id = "A3_CMD-11-P0"; aliases = @("A3_CMD-11-P0", "CMD-11", "CriarTarefa") },
    [ordered]@{ id = "A4_CMD-13A"; aliases = @("A4_CMD-13A", "CMD-13A", "AtualizarTarefa") },
    [ordered]@{ id = "A5_CMD-10"; aliases = @("A5_CMD-10", "CMD-10", "AtualizarStatus") }
)

$legacy = @(
    [ordered]@{ id = "B1_ConsultarProjeto"; aliases = @("B1_ConsultarProjeto", "ConsultarProjeto") },
    [ordered]@{ id = "B2_CriarProjeto"; aliases = @("B2_CriarProjeto", "CriarProjeto") },
    [ordered]@{ id = "B3_ExcluirProjeto"; aliases = @("B3_ExcluirProjeto", "ExcluirProjeto") },
    [ordered]@{ id = "B4_ExcluirTarefa"; aliases = @("B4_ExcluirTarefa", "ExcluirTarefa") },
    [ordered]@{ id = "B5_PedirDecisao"; aliases = @("B5_PedirDecisao", "B5_PedirDecisao_InvalidUPN", "PedirDecisao") },
    [ordered]@{ id = "B6_RegistrarBloqueio"; aliases = @("B6_RegistrarBloqueio", "RegistrarBloqueio") },
    [ordered]@{ id = "B7_RegistrarRisco"; aliases = @("B7_RegistrarRisco", "RegistrarRisco") }
)

function Get-EvidenceFilesForTest {
    param(
        [object]$Test,
        [System.IO.FileInfo[]]$Files
    )

    @($Files | Where-Object {
        $name = $_.Name
        foreach ($alias in $Test.aliases) {
            if ($name -like "*$alias*") {
                return $true
            }
        }
        return $false
    } | Sort-Object FullName)
}

function Get-FieldValue {
    param(
        [string]$Content,
        [string]$FieldName
    )

    $escaped = [regex]::Escape($FieldName)
    if ($Content -match "(?im)^\s*-\s*$escaped\s*:\s*(?<value>.*?)\s*$") {
        return $matches.value.Trim()
    }

    return $null
}

function Get-FencedBlock {
    param(
        [string]$Content,
        [string]$Name
    )

    $begin = "<!-- $Name BEGIN -->"
    $end = "<!-- $Name END -->"
    $beginMatches = @([regex]::Matches($Content, [regex]::Escape($begin)))
    $endMatches = @([regex]::Matches($Content, [regex]::Escape($end)))

    if ($beginMatches.Count -ne 1 -or $endMatches.Count -ne 1) {
        return [ordered]@{
            valid = $false
            value = ""
            error = "expected exactly one $Name fence pair"
        }
    }

    if ($endMatches[0].Index -le $beginMatches[0].Index) {
        return [ordered]@{
            valid = $false
            value = ""
            error = "$Name fence end appears before begin"
        }
    }

    $start = $beginMatches[0].Index + $beginMatches[0].Length
    $length = $endMatches[0].Index - $start
    $value = $Content.Substring($start, $length)

    [ordered]@{
        valid = $true
        value = $value
        error = $null
    }
}

function Test-XpiaMarkers {
    param([string]$Transcript)

    [ordered]@{
        contentFiltered = [bool]($Transcript -match "(?i)ContentFiltered")
        openAIIndirectAttack = [bool]($Transcript -match "(?i)openAIIndirectAttack")
        responsibleAi = [bool]($Transcript -match "(?i)Responsible AI restrictions")
        etapaBloqueada = [bool]($Transcript -match "(?i)Etapa Bloqueada")
    }
}

function Test-YesNo {
    param([string]$Value)
    return ($null -ne $Value -and $Value -match "(?i)^(yes|no)$")
}

function Test-NonEmpty {
    param([string]$Value)
    return ($null -ne $Value -and $Value.Trim().Length -gt 0)
}

function Get-HeadingTestId {
    param([string]$Content)

    $emDash = [char]0x2014
    $pattern = "(?m)^\s*#\s*(?<id>\S+)\s+(?:-|$emDash)\s+.+$"
    if ($Content -match $pattern) {
        return $matches.id.Trim()
    }

    return $null
}

function Test-RequiredFields {
    param(
        [object]$Test,
        [System.IO.FileInfo]$File,
        [string]$Content,
        [string]$ChatInput,
        [string]$Transcript
    )

    $missing = [System.Collections.Generic.List[string]]::new()
    $warnings = [System.Collections.Generic.List[string]]::new()

    $headingId = Get-HeadingTestId -Content $Content
    $testId = Get-FieldValue -Content $Content -FieldName "test_id"
    $executor = Get-FieldValue -Content $Content -FieldName "executor"
    $dateBrt = Get-FieldValue -Content $Content -FieldName "date_brt"
    $build = Get-FieldValue -Content $Content -FieldName "build_under_test"
    $bot = Get-FieldValue -Content $Content -FieldName "bot"
    $environment = Get-FieldValue -Content $Content -FieldName "environment"
    $runId = Get-FieldValue -Content $Content -FieldName "run_url_or_id"
    $pnpOutputPath = Get-FieldValue -Content $Content -FieldName "pnp_output_path"
    $cf = Get-FieldValue -Content $Content -FieldName "cf_observed"
    $oai = Get-FieldValue -Content $Content -FieldName "oai_observed"
    $rai = Get-FieldValue -Content $Content -FieldName "rai_observed"
    $eb = Get-FieldValue -Content $Content -FieldName "eb_observed"
    $screenshotPath = Get-FieldValue -Content $Content -FieldName "path"
    $result = Get-FieldValue -Content $Content -FieldName "result"

    if ($headingId -ne $Test.id) { $missing.Add("heading_test_id") | Out-Null }
    if ($testId -ne $Test.id) { $missing.Add("test_id") | Out-Null }

    $filenameMatches = $false
    foreach ($alias in $Test.aliases) {
        if ($File.Name -like "*$alias*") {
            $filenameMatches = $true
            break
        }
    }
    if (-not $filenameMatches) { $missing.Add("filename_test_id") | Out-Null }

    if (-not (Test-NonEmpty $executor)) { $missing.Add("executor") | Out-Null }
    if (-not (Test-NonEmpty $dateBrt)) { $missing.Add("date_brt") | Out-Null }
    if ($build -ne "3.15") { $missing.Add("build_under_test") | Out-Null }
    if (-not (Test-NonEmpty $bot)) { $missing.Add("bot") | Out-Null }
    if (-not (Test-NonEmpty $environment)) { $missing.Add("environment") | Out-Null }
    if (-not (Test-NonEmpty $ChatInput)) { $missing.Add("chat_input") | Out-Null }
    if (-not (Test-NonEmpty $Transcript)) { $missing.Add("transcript") | Out-Null }
    if (-not (Test-NonEmpty $runId)) { $missing.Add("run_url_or_id") | Out-Null }
    if (-not (Test-NonEmpty $pnpOutputPath)) { $missing.Add("pnp_output_path") | Out-Null }
    if (-not (Test-YesNo $cf)) { $missing.Add("cf_observed") | Out-Null }
    if (-not (Test-YesNo $oai)) { $missing.Add("oai_observed") | Out-Null }
    if (-not (Test-YesNo $rai)) { $missing.Add("rai_observed") | Out-Null }
    if (-not (Test-YesNo $eb)) { $missing.Add("eb_observed") | Out-Null }
    if (-not (Test-NonEmpty $screenshotPath)) {
        $missing.Add("screenshot.path") | Out-Null
    }
    else {
        $resolvedScreenshot = Join-Path (Get-Location).Path $screenshotPath
        if (-not (Test-Path -LiteralPath $resolvedScreenshot)) {
            $warnings.Add("screenshot path does not resolve: $screenshotPath") | Out-Null
        }
    }
    if ($null -eq $result -or $result -notmatch "^(PASS|FAIL|NOT_RUN)$") { $missing.Add("result") | Out-Null }

    [ordered]@{
        missingFields = @($missing)
        warnings = @($warnings)
    }
}

function New-TestResult {
    param(
        [object]$Test,
        [string]$Scope,
        [System.IO.FileInfo[]]$Files
    )

    $matched = Get-EvidenceFilesForTest -Test $Test -Files $Files
    $markers = Test-XpiaMarkers -Transcript ""
    $missingFields = @()
    $warnings = @()
    $transcript = ""
    $chatInput = ""
    $selectedFile = $null
    $hasEvidence = $matched.Count -gt 0

    if (-not $hasEvidence) {
        $status = if ($Scope -eq "InScope") { "FAIL_MISSING_EVIDENCE" } else { "LEGACY_NOT_RUN" }
        return [ordered]@{
            id = $Test.id
            scope = $Scope
            status = $status
            hasEvidence = $false
            evidenceFiles = @()
            selectedEvidenceFile = $null
            missingFields = @()
            warnings = @()
            markers = $markers
        }
    }

    $selectedFile = $matched[0]
    if ($matched.Count -gt 1) {
        $warnings += "multiple evidence files matched; selected first sorted file"
    }

    $content = Get-Content -LiteralPath $selectedFile.FullName -Raw -Encoding UTF8
    $transcriptBlock = Get-FencedBlock -Content $content -Name "TRANSCRIPT"
    $chatInputBlock = Get-FencedBlock -Content $content -Name "INPUT"

    if ($chatInputBlock.valid) {
        $chatInput = $chatInputBlock.value
    }
    else {
        $missingFields += "chat_input_fence"
    }

    if (-not $transcriptBlock.valid -or -not (Test-NonEmpty $transcriptBlock.value)) {
        $missingFields += "transcript"
        $status = if ($Scope -eq "InScope") { "FAIL_MISSING_TRANSCRIPT" } else { "LEGACY_INCOMPLETE" }
        return [ordered]@{
            id = $Test.id
            scope = $Scope
            status = $status
            hasEvidence = $true
            evidenceFiles = @($matched | ForEach-Object { $_.FullName })
            selectedEvidenceFile = $selectedFile.FullName
            missingFields = @($missingFields)
            warnings = @($warnings)
            markers = $markers
        }
    }

    $transcript = $transcriptBlock.value
    $fieldCheck = Test-RequiredFields -Test $Test -File $selectedFile -Content $content -ChatInput $chatInput -Transcript $transcript
    $missingFields = @($missingFields + $fieldCheck.missingFields)
    $warnings = @($warnings + $fieldCheck.warnings)

    if ($missingFields.Count -gt 0) {
        $status = if ($Scope -eq "InScope") { "FAIL_MISSING_REQUIRED_FIELD" } else { "LEGACY_INCOMPLETE" }
        return [ordered]@{
            id = $Test.id
            scope = $Scope
            status = $status
            hasEvidence = $true
            evidenceFiles = @($matched | ForEach-Object { $_.FullName })
            selectedEvidenceFile = $selectedFile.FullName
            missingFields = @($missingFields | Select-Object -Unique)
            warnings = @($warnings)
            markers = $markers
        }
    }

    $markers = Test-XpiaMarkers -Transcript $transcript
    $hasXpia = $markers.contentFiltered -or $markers.openAIIndirectAttack -or $markers.responsibleAi -or $markers.etapaBloqueada
    $status = if ($Scope -eq "InScope") {
        if ($hasXpia) { "FAIL_XPIA_RECURS" } else { "PASS" }
    }
    else {
        if ($hasXpia) { "LEGACY_XPIA_DEBT" } else { "LEGACY_NO_XPIA" }
    }

    [ordered]@{
        id = $Test.id
        scope = $Scope
        status = $status
        hasEvidence = $true
        evidenceFiles = @($matched | ForEach-Object { $_.FullName })
        selectedEvidenceFile = $selectedFile.FullName
        missingFields = @()
        warnings = @($warnings)
        markers = $markers
    }
}

$resolvedEvidenceDir = if (Test-Path -LiteralPath $EvidenceDir) {
    (Resolve-Path -LiteralPath $EvidenceDir).Path
}
else {
    $EvidenceDir
}

$files = @()
if (Test-Path -LiteralPath $EvidenceDir) {
    $files = @(Get-ChildItem -LiteralPath $EvidenceDir -Recurse -File -Include *.md,*.txt,*.json,*.log)
}

$results = [System.Collections.Generic.List[object]]::new()
foreach ($test in $inScope) {
    $results.Add((New-TestResult -Test $test -Scope "InScope" -Files $files)) | Out-Null
}
foreach ($test in $legacy) {
    $results.Add((New-TestResult -Test $test -Scope "LegacyDebt" -Files $files)) | Out-Null
}

$inScopeFailures = @($results | Where-Object { $_.scope -eq "InScope" -and $_.status -ne "PASS" })
$hasRecursOrMissingEvidence = @($inScopeFailures | Where-Object { $_.status -in @("FAIL_XPIA_RECURS", "FAIL_MISSING_EVIDENCE") }).Count -gt 0
$hasIncomplete = @($inScopeFailures | Where-Object { $_.status -in @("FAIL_MISSING_TRANSCRIPT", "FAIL_MISSING_REQUIRED_FIELD") }).Count -gt 0

$decision = if ($inScopeFailures.Count -eq 0) {
    "PASS_XPIA_01_RESOLVED"
}
elseif ($hasRecursOrMissingEvidence) {
    "FAIL_XPIA_01_RECURS_OR_UNKNOWN"
}
elseif ($hasIncomplete) {
    "FAIL_AQ09_INCOMPLETE"
}
else {
    "FAIL_XPIA_01_RECURS_OR_UNKNOWN"
}

$report = [ordered]@{
    evidenceDir = $resolvedEvidenceDir
    decision = $decision
    inScopeFailureCount = $inScopeFailures.Count
    generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
    results = $results
}

$reportJson = $report | ConvertTo-Json -Depth 10
$reportParent = Split-Path -Parent $ReportPath
if ($reportParent) {
    New-Item -ItemType Directory -Force -Path $reportParent | Out-Null
}
Set-Content -LiteralPath $ReportPath -Value $reportJson -Encoding UTF8
$reportJson

if ($decision -ne "PASS_XPIA_01_RESOLVED") {
    throw "AQ-09 smoke evidence validation failed: $decision; in-scope failures: $($inScopeFailures.id -join ', ')"
}
