[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SmokeStartUtc,

    [Parameter(Mandatory = $true)]
    [string]$SmokeEndUtc,

    [Parameter(Mandatory = $true)]
    [string]$SpSideEffectsReport,

    [string]$EvidenceDir = ".planning\comms\aq09_smoke_runbook_20260520\evidence",

    [Parameter(Mandatory = $true)]
    [string]$Executor,

    [string]$EnvironmentName,

    [switch]$SkipFlowRunLookup
)

$ErrorActionPreference = "Stop"
$autoMarker = "<!-- prepop:auto -->"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content
    )

    $parent = Split-Path -Parent $Path
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText([System.IO.Path]::GetFullPath($Path), $Content, $encoding)
}

function Parse-UtcDate {
    param([string]$Value, [string]$Name)

    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    $parsed = [datetime]::MinValue
    if (-not [datetime]::TryParse($Value, [System.Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$parsed)) {
        throw "Invalid $Name. Use ISO UTC, e.g. 2026-05-21T18:00:00Z."
    }

    return $parsed.ToUniversalTime()
}

function ConvertTo-IsoBrt {
    param([datetime]$Date)

    $dto = New-Object System.DateTimeOffset -ArgumentList $Date.ToUniversalTime(), ([System.TimeSpan]::Zero)
    return $dto.ToOffset((New-Object System.TimeSpan -ArgumentList -3, 0, 0)).ToString("yyyy-MM-ddTHH:mm:sszzz")
}

function Get-TestDefinitions {
    @(
        [ordered]@{
            id = "A1_CMD-12-H"
            file = "A1_CMD-12-H.md"
            input = @("listar tarefas QA Robust 20260513 F")
            expected = "None."
            flows = @("PM0_PA_Card_ListarTarefas", "PMO_PA_ListarTarefas")
        },
        [ordered]@{
            id = "A2_CMD-15"
            file = "A2_CMD-15.md"
            input = @("consultar portfolio")
            expected = "None."
            flows = @("PM0_PA_Card_ResumoExecutivoPortfolio", "PMO_PA_ConsultarPortfolio")
        },
        [ordered]@{
            id = "A3_CMD-11-P0"
            file = "A3_CMD-11-P0.md"
            input = @(
                "criar tarefa: projeto=QA Robust 20260513 F, titulo=QA CriarTarefa Smoke 315 20260520, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Media",
                "sim"
            )
            expected = "One new Tarefas row with ProjectID=PRJ-274E5ACC, Deleted=false, title marker QA CriarTarefa Smoke 315 20260520."
            flows = @("PM0_PA_Card_CriarTarefa", "PMO_PA_CriarTarefa")
        },
        [ordered]@{
            id = "A4_CMD-13A"
            file = "A4_CMD-13A.md"
            input = @("atualizar tarefa", "15, em andamento, 2, nao, nao, nao, sim")
            expected = "Task 15 preserves Responsavel, DataFim, and Prioridade; updates status/hours only as intended."
            flows = @("PM0_PA_Card_AtualizarTarefa", "PMO_PA_AtualizarTarefa")
        },
        [ordered]@{
            id = "A5_CMD-10"
            file = "A5_CMD-10.md"
            input = @(
                "atualizar status: projeto=QA Robust 20260513 F, status=Amarelo, resumo=Smoke 3.15 multilinha, percentual=45, risco=Nenhum, bloqueio=Nenhum, proxima acao=Revisar",
                "sim"
            )
            expected = "One Status Diario row created with structured fields populated."
            flows = @("PM0_PA_Card_AtualizarStatus", "PMO_PA_AtualizarStatus")
        },
        [ordered]@{
            id = "B1_ConsultarProjeto"
            file = "B1_ConsultarProjeto.md"
            input = @("consultar projeto QA Robust 20260513 F")
            expected = "Project summary if the legacy route works; the runbook does not require a SharePoint write."
            flows = @("PMO_PA_ConsultarProjeto")
        },
        [ordered]@{
            id = "B2_CriarProjeto"
            file = "B2_CriarProjeto.md"
            input = @(
                "criar projeto: NomeProjeto=QA Robust 20260513 F, PM=mbenicios@minsait.com, Prazo=30/06/2026, Prioridade=Media",
                "sim"
            )
            expected = "Duplicate guard or no duplicate active project."
            flows = @("PMO_PA_CriarProjeto")
        },
        [ordered]@{
            id = "B3_ExcluirProjeto"
            file = "B3_ExcluirProjeto.md"
            input = @("excluir projeto: projeto=QA Robust 20260513 F, motivo=smoke legacy cancelamento", "nao")
            expected = "No deletion."
            flows = @("PMO_PA_ExcluirProjeto")
        },
        [ordered]@{
            id = "B4_ExcluirTarefa"
            file = "B4_ExcluirTarefa.md"
            input = @("excluir tarefa: projeto=QA Robust 20260513 F, tarefa=15, motivo=smoke legacy cancelamento", "nao")
            expected = "Task 15 remains active."
            flows = @("PMO_PA_ExcluirTarefa")
        },
        [ordered]@{
            id = "B5_PedirDecisao"
            file = "B5_PedirDecisao_InvalidUPN.md"
            input = @("pedir decisao: projeto=QA Robust 20260513 F, descricao=Validar publish regex 3.4 negativo, impacto=Alto, prazo=30/06/2026, aprovador=UPN ?")
            expected = "No row created in Decisoes do Board for the invalid UPN path."
            flows = @("PMO_PA_PedirDecisaoBot")
        },
        [ordered]@{
            id = "B6_RegistrarBloqueio"
            file = "B6_RegistrarBloqueio.md"
            input = @("registrar bloqueio: projeto=QA Robust 20260513 F, descricao=Smoke legacy bloqueio cancelado, impacto=Baixo", "nao")
            expected = "No row created."
            flows = @("PMO_PA_RegistrarBloqueioBot")
        },
        [ordered]@{
            id = "B7_RegistrarRisco"
            file = "B7_RegistrarRisco.md"
            input = @("registrar risco: projeto=QA Robust 20260513 F, descricao=Smoke legacy risco cancelado, severidade=Baixa", "nao")
            expected = "No row created."
            flows = @("PMO_PA_RegistrarRiscoBot")
        }
    )
}

function Add-UpdatedField {
    param([object]$StubResult, [string]$Field)
    $StubResult.updatedFields.Add($Field) | Out-Null
}

function Add-SkippedField {
    param([object]$StubResult, [string]$Field, [string]$Reason)
    $StubResult.skippedFields.Add([ordered]@{ field = $Field; reason = $Reason }) | Out-Null
}

function Set-PlaceholderField {
    param(
        [string]$Content,
        [string]$FieldName,
        [string]$Value,
        [string[]]$DefaultPatterns,
        [object]$StubResult
    )

    $escapedField = [regex]::Escape($FieldName)
    $match = [regex]::Match($Content, "(?m)^(?<prefix>[ \t]*-[ \t]*$escapedField[ \t]*:[ \t]*)(?<value>.*?)[ \t]*$")
    if (-not $match.Success) {
        Add-SkippedField -StubResult $StubResult -Field $FieldName -Reason "field_not_found"
        return $Content
    }

    $current = $match.Groups["value"].Value.Trim()
    if ($current -eq $Value) {
        Add-SkippedField -StubResult $StubResult -Field $FieldName -Reason "already_matches"
        return $Content
    }

    $isDefault = $false
    foreach ($pattern in $DefaultPatterns) {
        if ($current -match $pattern) {
            $isDefault = $true
            break
        }
    }

    if (-not $isDefault) {
        Add-SkippedField -StubResult $StubResult -Field $FieldName -Reason "non_default_content"
        return $Content
    }

    $replacement = $match.Groups["prefix"].Value + $Value
    $newContent = $Content.Remove($match.Index, $match.Length).Insert($match.Index, $replacement)
    Add-UpdatedField -StubResult $StubResult -Field $FieldName
    return $newContent
}

function Set-EmptyInputFence {
    param(
        [string]$Content,
        [string[]]$Lines,
        [object]$StubResult
    )

    $begin = "<!-- INPUT BEGIN -->"
    $end = "<!-- INPUT END -->"
    $beginMatch = [regex]::Match($Content, [regex]::Escape($begin))
    $endMatch = [regex]::Match($Content, [regex]::Escape($end))
    if (-not $beginMatch.Success -or -not $endMatch.Success -or $endMatch.Index -le $beginMatch.Index) {
        Add-SkippedField -StubResult $StubResult -Field "chat_input" -Reason "input_fence_not_found"
        return $Content
    }

    $start = $beginMatch.Index + $beginMatch.Length
    $length = $endMatch.Index - $start
    $current = $Content.Substring($start, $length)
    $normalizedCurrent = ($current -replace "(`r`n|`r)", "`n").Trim()
    $newBlockText = ($Lines -join "`n")
    if ($normalizedCurrent -eq $newBlockText) {
        Add-SkippedField -StubResult $StubResult -Field "chat_input" -Reason "already_matches"
        return $Content
    }
    if (-not [string]::IsNullOrWhiteSpace($current)) {
        Add-SkippedField -StubResult $StubResult -Field "chat_input" -Reason "non_default_content"
        return $Content
    }

    $replacement = "`n$newBlockText`n"
    $newContent = $Content.Remove($start, $length).Insert($start, $replacement)
    Add-UpdatedField -StubResult $StubResult -Field "chat_input"
    return $newContent
}

function Test-VirginStub {
    param([string]$Content)

    return (
        $Content -match "(?m)^\s*-\s*executor\s*:\s*<Owner name or agent>\s*$" -and
        $Content -match "(?m)^\s*-\s*date_brt\s*:\s*<YYYY-MM-DDTHH:MM:SS-03:00>\s*$" -and
        $Content -match "(?ms)<!-- INPUT BEGIN -->\s*<!-- INPUT END -->" -and
        $Content -match "(?m)^\s*-\s*actual\s*:\s*<free text>\s*$"
    )
}

function Test-MetadataMarker {
    param([string]$Content)

    $metadataBlock = [regex]::Match($Content, "(?ms)^## Metadata\s*(?<block>.*?)(?=^## Chat input\s*$)")
    if (-not $metadataBlock.Success) {
        return $false
    }

    $escapedMarker = [regex]::Escape($autoMarker)
    return $metadataBlock.Groups["block"].Value -match "(?m)^$escapedMarker\s*$"
}

function Add-MetadataMarker {
    param([string]$Content)

    $chatHeading = [regex]::Match($Content, "(?m)^## Chat input\s*$")
    if (-not $chatHeading.Success) {
        return $Content
    }

    return $Content.Insert($chatHeading.Index, "$autoMarker`n`n")
}

function Get-ReportTest {
    param([object]$Report, [string]$TestId)

    if ($null -eq $Report.tests) {
        return $null
    }

    $property = $Report.tests.PSObject.Properties[$TestId]
    if ($null -eq $property) {
        return $null
    }

    return $property.Value
}

function Get-ActualSideEffect {
    param([object]$Report, [string]$TestId)

    $test = Get-ReportTest -Report $Report -TestId $TestId
    if ($null -eq $test) {
        return "N/A - Track G side-effect report has no tests.$TestId observation."
    }

    $status = if ($null -ne $test.status) { [string]$test.status } else { "UNKNOWN" }
    $details = if ($null -ne $test.details) { ([string]$test.details).Trim() } else { "No details in report." }
    return "Track G tests.$TestId status=$status; details=$details"
}

function Get-NestedPropertyValue {
    param([object]$Value, [string[]]$Path)

    $cursor = $Value
    foreach ($name in $Path) {
        if ($null -eq $cursor) {
            return $null
        }
        $property = $cursor.PSObject.Properties[$name]
        if ($null -eq $property) {
            return $null
        }
        $cursor = $property.Value
    }

    return $cursor
}

function Get-FirstNestedPropertyValue {
    param([object]$Value, [object[]]$Paths)

    foreach ($path in $Paths) {
        $candidate = Get-NestedPropertyValue -Value $Value -Path $path
        if ($null -ne $candidate -and -not [string]::IsNullOrWhiteSpace([string]$candidate)) {
            return $candidate
        }
    }

    return $null
}

function Get-RunStartUtc {
    param([object]$Run)

    $raw = Get-FirstNestedPropertyValue -Value $Run -Paths @(
        @("StartTime"),
        @("startTime"),
        @("CreatedTime"),
        @("createdTime"),
        @("Properties", "StartTime"),
        @("Properties", "startTime"),
        @("properties", "startTime")
    )
    if ($null -eq $raw) {
        return $null
    }

    $parsed = [datetime]::MinValue
    if ([datetime]::TryParse([string]$raw, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::AssumeUniversal, [ref]$parsed)) {
        return $parsed.ToUniversalTime()
    }

    return $null
}

function Get-FlowNameValue {
    param([object]$Flow)

    return Get-FirstNestedPropertyValue -Value $Flow -Paths @(
        @("FlowName"),
        @("Name"),
        @("flowName"),
        @("Internal", "name")
    )
}

function Get-FlowDisplayNameValue {
    param([object]$Flow)

    return Get-FirstNestedPropertyValue -Value $Flow -Paths @(
        @("DisplayName"),
        @("displayName"),
        @("Properties", "DisplayName"),
        @("properties", "displayName")
    )
}

function Get-RunIdValue {
    param([object]$Run)

    return Get-FirstNestedPropertyValue -Value $Run -Paths @(
        @("FlowRunName"),
        @("RunName"),
        @("Name"),
        @("flowRunName"),
        @("Internal", "name")
    )
}

function New-FlowLookupState {
    param([switch]$Skip, [string]$TargetEnvironment)

    if ($Skip) {
        return [ordered]@{ available = $false; reason = "flow run lookup skipped by -SkipFlowRunLookup"; flows = @() }
    }

    $pac = Get-Command pac -ErrorAction SilentlyContinue
    if ($null -eq $pac) {
        return [ordered]@{ available = $false; reason = "pac command not found before connection check"; flows = @() }
    }

    $connectionArgs = @("connection", "list")
    if (-not [string]::IsNullOrWhiteSpace($TargetEnvironment)) {
        $connectionArgs += @("--environment", $TargetEnvironment)
    }
    $connectionText = & $pac.Source @connectionArgs 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        return [ordered]@{ available = $false; reason = "pac connection list failed: $($connectionText.Trim())"; flows = @() }
    }

    if ($null -eq (Get-Command Get-Flow -ErrorAction SilentlyContinue) -or $null -eq (Get-Command Get-FlowRun -ErrorAction SilentlyContinue)) {
        return [ordered]@{ available = $false; reason = "Get-Flow or Get-FlowRun is unavailable after pac connection check"; flows = @() }
    }

    $flowArgs = @{ Top = 500; ErrorAction = "Stop" }
    if (-not [string]::IsNullOrWhiteSpace($TargetEnvironment)) {
        $flowArgs.EnvironmentName = $TargetEnvironment
    }

    try {
        $flows = @(Get-Flow @flowArgs)
    }
    catch {
        return [ordered]@{ available = $false; reason = "Get-Flow inventory failed: $($_.Exception.Message)"; flows = @() }
    }

    return [ordered]@{ available = $true; reason = "pac connection list and flow inventory succeeded"; flows = $flows }
}

function Find-LatestFlowRun {
    param(
        [object]$LookupState,
        [string[]]$DisplayNames,
        [datetime]$StartUtc,
        [datetime]$EndUtc,
        [string]$TargetEnvironment
    )

    if (-not $LookupState.available) {
        return [ordered]@{ id = "N/A"; note = $LookupState.reason }
    }

    foreach ($displayName in $DisplayNames) {
        $flow = @($LookupState.flows | Where-Object { (Get-FlowDisplayNameValue -Flow $_) -eq $displayName } | Select-Object -First 1)
        if ($flow.Count -eq 0) {
            continue
        }

        $flowName = Get-FlowNameValue -Flow $flow[0]
        if ([string]::IsNullOrWhiteSpace([string]$flowName)) {
            continue
        }

        $runArgs = @{ FlowName = [string]$flowName; ErrorAction = "Stop" }
        if (-not [string]::IsNullOrWhiteSpace($TargetEnvironment)) {
            $runArgs.EnvironmentName = $TargetEnvironment
        }

        try {
            $runs = @(Get-FlowRun @runArgs)
        }
        catch {
            return [ordered]@{ id = "N/A"; note = "Get-FlowRun failed for ${displayName}: $($_.Exception.Message)" }
        }

        $inWindow = @($runs | ForEach-Object {
            $start = Get-RunStartUtc -Run $_
            if ($null -ne $start -and $start -ge $StartUtc -and $start -le $EndUtc) {
                [pscustomobject]@{ run = $_; startUtc = $start }
            }
        } | Sort-Object startUtc -Descending)
        if ($inWindow.Count -eq 0) {
            continue
        }

        $runId = Get-RunIdValue -Run $inWindow[0].run
        if (-not [string]::IsNullOrWhiteSpace([string]$runId)) {
            return [ordered]@{ id = [string]$runId; note = "latest $displayName run in smoke window at $($inWindow[0].startUtc.ToString("o"))" }
        }
    }

    return [ordered]@{ id = "N/A"; note = "no mapped flow run was found in the smoke window" }
}

function Add-RunLookupComment {
    param([string]$Content, [string]$Note)

    $cleanNote = (($Note -replace "\s+", " ").Trim() -replace "-->", "-- >")
    $comment = "<!-- prepop:run_lookup $cleanNote -->"
    if ($Content -match "(?m)^<!-- prepop:run_lookup .* -->\s*$") {
        return $Content
    }

    $runLine = [regex]::Match($Content, "(?m)^\s*-\s*run_url_or_id\s*:\s*.*$")
    if (-not $runLine.Success) {
        return $Content
    }

    return $Content.Insert($runLine.Index + $runLine.Length, "`n$comment")
}

$startUtc = Parse-UtcDate -Value $SmokeStartUtc -Name "SmokeStartUtc"
$endUtc = Parse-UtcDate -Value $SmokeEndUtc -Name "SmokeEndUtc"
if ($endUtc -lt $startUtc) {
    throw "SmokeEndUtc must be greater than or equal to SmokeStartUtc."
}
if (-not (Test-Path -LiteralPath $SpSideEffectsReport)) {
    throw "SharePoint side-effects report not found: $SpSideEffectsReport"
}
if (-not (Test-Path -LiteralPath $EvidenceDir)) {
    throw "Evidence directory not found: $EvidenceDir"
}

$report = Get-Content -LiteralPath $SpSideEffectsReport -Raw -Encoding UTF8 | ConvertFrom-Json
$definitions = Get-TestDefinitions
$flowLookup = New-FlowLookupState -Skip:$SkipFlowRunLookup -TargetEnvironment $EnvironmentName
$generatedAtBrt = ConvertTo-IsoBrt (Get-Date).ToUniversalTime()
$stubResults = [System.Collections.Generic.List[object]]::new()

foreach ($definition in $definitions) {
    $stubPath = Join-Path $EvidenceDir $definition.file
    $stubResult = [ordered]@{
        testId = $definition.id
        path = $stubPath
        markerState = $null
        updatedFields = [System.Collections.Generic.List[string]]::new()
        skippedFields = [System.Collections.Generic.List[object]]::new()
    }
    if (-not (Test-Path -LiteralPath $stubPath)) {
        $stubResult.markerState = "stub_missing"
        Add-SkippedField -StubResult $stubResult -Field "*" -Reason "stub_not_found"
        $stubResults.Add($stubResult) | Out-Null
        continue
    }

    $content = Get-Content -LiteralPath $stubPath -Raw -Encoding UTF8
    $hasMarker = Test-MetadataMarker -Content $content
    if (-not $hasMarker -and (Test-VirginStub -Content $content)) {
        $content = Add-MetadataMarker -Content $content
        $hasMarker = Test-MetadataMarker -Content $content
        $stubResult.markerState = "initialized"
        Add-UpdatedField -StubResult $stubResult -Field "prepop_marker"
    }
    elseif ($hasMarker) {
        $stubResult.markerState = "present"
    }
    else {
        $stubResult.markerState = "missing_or_modified"
    }

    if (-not $hasMarker) {
        Add-SkippedField -StubResult $stubResult -Field "*" -Reason "missing_or_modified_prepop_marker"
        $stubResults.Add($stubResult) | Out-Null
        continue
    }

    $run = Find-LatestFlowRun -LookupState $flowLookup -DisplayNames $definition.flows -StartUtc $startUtc -EndUtc $endUtc -TargetEnvironment $EnvironmentName
    if ($stubResult.markerState -eq "initialized") {
        $content = Set-PlaceholderField -Content $content -FieldName "executor" -Value $Executor -DefaultPatterns @("^<Owner name or agent>$") -StubResult $stubResult
        $content = Set-PlaceholderField -Content $content -FieldName "date_brt" -Value $generatedAtBrt -DefaultPatterns @("^<YYYY-MM-DDTHH:MM:SS-03:00>$") -StubResult $stubResult
        $content = Set-PlaceholderField -Content $content -FieldName "build_under_test" -Value "3.15" -DefaultPatterns @("^<.*>$") -StubResult $stubResult
        $content = Set-PlaceholderField -Content $content -FieldName "bot" -Value "Assistente PMO V2" -DefaultPatterns @("^<.*>$") -StubResult $stubResult
        $content = Set-PlaceholderField -Content $content -FieldName "environment" -Value "ColOfertasBrasilPro" -DefaultPatterns @("^<.*>$") -StubResult $stubResult
    }
    else {
        foreach ($metadataField in @("executor", "date_brt", "build_under_test", "bot", "environment")) {
            Add-SkippedField -StubResult $stubResult -Field $metadataField -Reason "above_existing_prepop_marker"
        }
    }
    $content = Set-EmptyInputFence -Content $content -Lines $definition.input -StubResult $stubResult
    $content = Set-PlaceholderField -Content $content -FieldName "run_url_or_id" -Value $run.id -DefaultPatterns @("^<URL or run ID, or `"N/A`" if no flow was invoked>$", "^<.*>$") -StubResult $stubResult
    $content = Add-RunLookupComment -Content $content -Note $run.note
    $content = Set-PlaceholderField -Content $content -FieldName "expected" -Value $definition.expected -DefaultPatterns @("^<free text>$") -StubResult $stubResult
    $content = Set-PlaceholderField -Content $content -FieldName "actual" -Value (Get-ActualSideEffect -Report $report -TestId $definition.id) -DefaultPatterns @("^<free text>$") -StubResult $stubResult
    $content = Set-PlaceholderField -Content $content -FieldName "pnp_output_path" -Value $SpSideEffectsReport -DefaultPatterns @("^<relative path under \.planning/comms/\.\.\. or `"N/A`">$", "^<.*>$") -StubResult $stubResult

    Write-Utf8NoBom -Path $stubPath -Content $content
    $stubResults.Add($stubResult) | Out-Null
}

$manifest = [ordered]@{
    generatedAtBrt = $generatedAtBrt
    smokeWindow = [ordered]@{
        startUtc = $startUtc.ToString("o")
        endUtc = $endUtc.ToString("o")
    }
    executor = $Executor
    sideEffectsReport = $SpSideEffectsReport
    evidenceDir = $EvidenceDir
    flowRunLookup = [ordered]@{
        enabled = (-not [bool]$SkipFlowRunLookup)
        environmentName = $EnvironmentName
        available = $flowLookup.available
        note = $flowLookup.reason
    }
    stubs = $stubResults
}

$manifestPath = Join-Path $EvidenceDir ".prepop_manifest.json"
$manifestJson = ConvertTo-Json -InputObject $manifest -Depth 20
Write-Utf8NoBom -Path $manifestPath -Content $manifestJson
$manifestJson
