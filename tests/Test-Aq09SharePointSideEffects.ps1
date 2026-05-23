[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SmokeStartUtc,

    [Parameter(Mandatory = $true)]
    [string]$SmokeEndUtc,

    [string]$OutputDir = ".planning\comms\aq09_smoke_runbook_20260520\sp_side_effects\dry_run",
    [string]$ProjectScope = "QA Robust 20260513 F",
    [string]$ExpectedProjectId = "PRJ-274E5ACC",
    [int]$TaskUpdateItemId = 15,
    [string]$SiteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital",
    [string]$ExpectedEnvironmentName = "ColOfertasBrasilPro",
    [switch]$SkipPacEnvironmentCheck
)

$ErrorActionPreference = "Stop"

$forbiddenCommands = @(
    "Set-PnPListItem",
    "Add-PnPListItem",
    "Remove-PnPListItem",
    "Update-PnP*",
    "Set-PnP*",
    "Add-PnP*",
    "Remove-PnP*"
)

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Content
    )

    $resolvedParent = Split-Path -Parent $Path
    if ($resolvedParent) {
        New-Item -ItemType Directory -Force -Path $resolvedParent | Out-Null
    }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Join-Path (Get-Location).Path $Path), $Content, $encoding)
}

function ConvertTo-JsonText {
    param(
        [Parameter(Mandatory = $false)][AllowNull()][object]$Value,
        [int]$Depth = 50
    )

    if ($null -eq $Value) {
        return "null"
    }

    return ConvertTo-Json -InputObject $Value -Depth $Depth
}

function Assert-ReadOnlyHarness {
    $scriptText = Get-Content -LiteralPath $PSCommandPath -Raw
    foreach ($command in $forbiddenCommands) {
        $pattern = [regex]::Escape($command).Replace("\*", ".*")
        if ($scriptText -match "(?im)^\s*$pattern\b") {
            throw "Read-only guard failed: forbidden PnP write command appears in executable position: $command"
        }
    }
}

function ConvertTo-IsoBrt {
    param([datetime]$Date)
    if ($null -eq $Date) { return $null }
    $offset = New-Object System.TimeSpan -ArgumentList -3, 0, 0
    $dto = New-Object System.DateTimeOffset -ArgumentList $Date.ToUniversalTime(), ([System.TimeSpan]::Zero)
    return $dto.ToOffset($offset).ToString("yyyy-MM-ddTHH:mm:sszzz")
}

function Parse-UtcDate {
    param([string]$Value, [string]$Name)
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    $parsed = [datetime]::MinValue
    if (-not [datetime]::TryParse($Value, [System.Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$parsed)) {
        throw "Invalid $Name. Use ISO UTC, e.g. 2026-05-21T18:00:00Z"
    }
    return $parsed.ToUniversalTime()
}

function Convert-FieldValue {
    param([object]$Value)

    if ($null -eq $Value) { return $null }
    if ($Value -is [datetime]) { return $Value.ToUniversalTime().ToString("o") }
    if ($Value -is [bool]) { return $Value }
    if ($Value -is [int] -or $Value -is [long] -or $Value -is [double] -or $Value -is [decimal]) { return $Value }

    $propNames = @($Value.PSObject.Properties.Name)
    if ($propNames -contains "LookupValue") { return $Value.LookupValue }
    if ($propNames -contains "Email") { return $Value.Email }
    if ($propNames -contains "UserPrincipalName") { return $Value.UserPrincipalName }

    if ($Value -is [array]) {
        return @($Value | ForEach-Object { Convert-FieldValue $_ })
    }

    return [string]$Value
}

function Get-ItemField {
    param([object]$Item, [string]$FieldName)
    if ($null -eq $Item) { return $null }
    try {
        return Convert-FieldValue $Item[$FieldName]
    }
    catch {
        return $null
    }
}

function Convert-PnPItem {
    param(
        [object]$Item,
        [string[]]$Fields
    )

    $row = [ordered]@{ Id = $Item.Id }
    foreach ($field in $Fields) {
        $row[$field] = Get-ItemField -Item $Item -FieldName $field
    }
    return $row
}

function ConvertTo-CamlUtc {
    param([datetime]$Date)
    return $Date.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function New-DeletedNeqCaml {
    return "<Neq><FieldRef Name='Deleted' /><Value Type='Boolean'>1</Value></Neq>"
}

function New-WindowCaml {
    param([datetime]$StartUtc, [datetime]$EndUtc)
    $startText = ConvertTo-CamlUtc $StartUtc
    $endText = ConvertTo-CamlUtc $EndUtc
    $deleted = New-DeletedNeqCaml
    return @"
<View>
  <Query>
    <Where>
      <And>
        $deleted
        <And>
          <Geq><FieldRef Name='Modified' /><Value IncludeTimeValue='TRUE' Type='DateTime'>$startText</Value></Geq>
          <Leq><FieldRef Name='Modified' /><Value IncludeTimeValue='TRUE' Type='DateTime'>$endText</Value></Leq>
        </And>
      </And>
    </Where>
    <OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy>
  </Query>
</View>
"@
}

function New-DeletedOnlyCaml {
    return @"
<View>
  <Query>
    <Where>
      $(New-DeletedNeqCaml)
    </Where>
  </Query>
</View>
"@
}

function Import-PnPReadOnlyModule {
    $env:PNPLEGACYMESSAGE = "false"
    Remove-Module PnP.PowerShell, SharePointPnPPowerShellOnline -ErrorAction SilentlyContinue
    Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking -ErrorAction Stop
}

function Assert-PacEnvironment {
    param([string]$ExpectedName)
    if ($SkipPacEnvironmentCheck) { return }

    $pac = Get-Command pac -ErrorAction Stop
    $text = & $pac.Source env who 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "PAC environment check failed: $text"
    }
    if ($text -notmatch [regex]::Escape($ExpectedName)) {
        throw "Environment mismatch. Expected '$ExpectedName' from 'pac env who'. Actual output: $text"
    }
}

function Connect-SharePointReadOnly {
    param([string]$Url)
    Import-PnPReadOnlyModule
    Connect-PnPOnline -Url $Url -UseWebLogin
    $web = Get-PnPWeb -ErrorAction Stop
    if ($web.Url.TrimEnd("/") -ne $Url.TrimEnd("/")) {
        throw "SharePoint site mismatch. Expected '$Url', got '$($web.Url)'."
    }
    return [ordered]@{
        title = $web.Title
        url = $web.Url
    }
}

function Get-ReadOnlyRows {
    param(
        [string]$ListName,
        [string[]]$Fields,
        [string]$Query
    )

    if ($Query -notmatch "FieldRef Name='Deleted'|FieldRef Name=`"Deleted`"") {
        throw "Read-only query for '$ListName' is missing Deleted ne 1 filter."
    }

    $items = Get-PnPListItem -List $ListName -PageSize 500 -Query $Query -ErrorAction Stop
    return @($items | ForEach-Object { Convert-PnPItem -Item $_ -Fields $Fields })
}

function Get-ReadOnlyItemById {
    param(
        [string]$ListName,
        [int]$Id,
        [string[]]$Fields
    )

    $query = @"
<View>
  <Query>
    <Where>
      <And>
        $(New-DeletedNeqCaml)
        <Eq><FieldRef Name='ID' /><Value Type='Counter'>$Id</Value></Eq>
      </And>
    </Where>
  </Query>
</View>
"@
    $rows = @(Get-ReadOnlyRows -ListName $ListName -Fields $Fields -Query $query)
    if ($rows.Count -eq 0) { return $null }
    return $rows[0]
}

function Test-DateInWindow {
    param([object]$Value, [datetime]$StartUtc, [datetime]$EndUtc)
    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) { return $false }
    $date = ([datetime]$Value).ToUniversalTime()
    return ($date -ge $StartUtc -and $date -le $EndUtc)
}

function Test-NonBlank {
    param([object]$Value)
    return ($null -ne $Value -and -not [string]::IsNullOrWhiteSpace([string]$Value))
}

function Normalize-Text {
    param([object]$Value)
    if ($null -eq $Value) { return "" }
    return ([string]$Value).Trim()
}

function New-TestResult {
    param(
        [string]$Status,
        [string]$Details,
        [object]$Evidence
    )
    [ordered]@{
        status = $Status
        details = $Details
        evidence = $Evidence
    }
}

Assert-ReadOnlyHarness
$startUtc = Parse-UtcDate -Value $SmokeStartUtc -Name "SmokeStartUtc"
$endUtc = Parse-UtcDate -Value $SmokeEndUtc -Name "SmokeEndUtc"
if ($endUtc -lt $startUtc) {
    throw "SmokeEndUtc must be greater than or equal to SmokeStartUtc."
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
Assert-PacEnvironment -ExpectedName $ExpectedEnvironmentName
$site = Connect-SharePointReadOnly -Url $SiteUrl

$projectFields = @("ID","Title","NomeProjeto","ProjectID","StatusRAG","Ativo","Deleted","UltimaAtualizacao","Created","Modified")
$taskFields = @("ID","Title","ProjectID","Status","Responsavel","DataFim","Prioridade","HorasEstimadas","HorasRealizadas","Deleted","Created","Modified")
$statusFields = @("ID","Title","StatusID","ProjectID","DataRegistro","RAG","Resumo","Percentual","Risco","Bloqueio","ProximaAcao","OrigemEntrada","Deleted","Created","Modified")
$riskFields = @("ID","Title","RiskID","ProjectID","Tipo","Severidade","Descricao","Impacto","StatusRisco","Deleted","Created","Modified")
$decisionFields = @("ID","Title","DecisionID","ProjectID","Descricao","StatusDecisao","Impacto","ApproverUPN","Deleted","Created","Modified")

$windowQuery = New-WindowCaml -StartUtc $startUtc -EndUtc $endUtc
$deletedOnlyQuery = New-DeletedOnlyCaml

$projectRows = Get-ReadOnlyRows -ListName "Projetos" -Fields $projectFields -Query $deletedOnlyQuery
$taskRows = Get-ReadOnlyRows -ListName "Tarefas" -Fields $taskFields -Query $deletedOnlyQuery
$projectRowsInWindow = Get-ReadOnlyRows -ListName "Projetos" -Fields $projectFields -Query $windowQuery
$taskRowsInWindow = Get-ReadOnlyRows -ListName "Tarefas" -Fields $taskFields -Query $windowQuery
$statusRowsInWindow = Get-ReadOnlyRows -ListName "Status Diario" -Fields $statusFields -Query $windowQuery
$riskRowsInWindow = Get-ReadOnlyRows -ListName "Riscos e Bloqueios" -Fields $riskFields -Query $windowQuery
$decisionRowsInWindow = Get-ReadOnlyRows -ListName "Decisoes do Board" -Fields $decisionFields -Query $windowQuery

$rawFiles = [ordered]@{
    Projetos = "Projetos_rows_in_window.json"
    Tarefas = "Tarefas_rows_in_window.json"
    StatusDiario = "StatusDiario_rows_in_window.json"
    RiscosBloqueios = "RiscosBloqueios_rows_in_window.json"
    DecisoesBoard = "DecisoesBoard_rows_in_window.json"
}

Write-Utf8NoBom -Path (Join-Path $OutputDir $rawFiles.Projetos) -Content (ConvertTo-JsonText -Value @($projectRowsInWindow) -Depth 20)
Write-Utf8NoBom -Path (Join-Path $OutputDir $rawFiles.Tarefas) -Content (ConvertTo-JsonText -Value @($taskRowsInWindow) -Depth 20)
Write-Utf8NoBom -Path (Join-Path $OutputDir $rawFiles.StatusDiario) -Content (ConvertTo-JsonText -Value @($statusRowsInWindow) -Depth 20)
Write-Utf8NoBom -Path (Join-Path $OutputDir $rawFiles.RiscosBloqueios) -Content (ConvertTo-JsonText -Value @($riskRowsInWindow) -Depth 20)
Write-Utf8NoBom -Path (Join-Path $OutputDir $rawFiles.DecisoesBoard) -Content (ConvertTo-JsonText -Value @($decisionRowsInWindow) -Depth 20)

$scopeProjects = @($projectRows | Where-Object {
    $_.ProjectID -eq $ExpectedProjectId -or $_.Title -eq $ProjectScope -or $_.NomeProjeto -eq $ProjectScope
})
$scopeProject = @($scopeProjects | Select-Object -First 1)[0]
$scopeTasks = @($taskRows | Where-Object { $_.ProjectID -eq $ExpectedProjectId })
$scopeTasksFirst5 = @($scopeTasks | Select-Object -First 5 | ForEach-Object {
    [ordered]@{
        Id = $_.Id
        Title = $_.Title
        Responsavel = $_.Responsavel
        Prazo = $_.DataFim
        Status = $_.Status
    }
})

$activeProjects = @($projectRows | Where-Object {
    ($_.Ativo -eq $true -or [string]$_.Ativo -eq "1" -or [string]$_.Ativo -match "(?i)^true$") -and
    ($_.Deleted -ne $true -and [string]$_.Deleted -ne "1")
})
$recentProjects = @($activeProjects | Sort-Object { if ($_.Modified) { [datetime]$_.Modified } else { [datetime]::MinValue } } -Descending | Select-Object -First 10)

$a3Marker = "QA CriarTarefa Smoke 315 20260520"
$a3Matches = @($taskRowsInWindow | Where-Object {
    $_.ProjectID -eq $ExpectedProjectId -and (Normalize-Text $_.Title) -like "*$a3Marker*"
})
$a3FieldChecks = [ordered]@{
    expectedTitle = $a3Marker
    expectedResponsavel = "mbenicios@minsait.com"
    expectedPrazo = "2026-06-30"
    expectedHoras = 2
    expectedPrioridade = "Media"
    expectedDeleted = $false
    actual = if ($a3Matches.Count -eq 1) { $a3Matches[0] } else { "NO_MATCH" }
}
if ($a3Matches.Count -eq 1) {
    $a3 = $a3Matches[0]
    $a3FieldChecks.matches = [ordered]@{
        title = ((Normalize-Text $a3.Title) -like "*$a3Marker*")
        responsavel = ((Normalize-Text $a3.Responsavel) -eq "mbenicios@minsait.com")
        prazo = if ($a3.DataFim) { ([datetime]$a3.DataFim).ToUniversalTime().ToString("yyyy-MM-dd") -eq "2026-06-30" } else { $false }
        horas = ([double]$a3.HorasEstimadas -eq 2)
        prioridade = ((Normalize-Text $a3.Prioridade) -eq "Media")
        deleted = ($a3.Deleted -ne $true -and [string]$a3.Deleted -ne "1")
    }
}

$a4Row = Get-ReadOnlyItemById -ListName "Tarefas" -Id $TaskUpdateItemId -Fields $taskFields
$a4ModifiedInWindow = if ($a4Row) { Test-DateInWindow -Value $a4Row.Modified -StartUtc $startUtc -EndUtc $endUtc } else { $false }
$a4Checks = [ordered]@{
    itemId = $TaskUpdateItemId
    modifiedInWindow = $a4ModifiedInWindow
    expectedStatus = "Em andamento"
    actual = if ($a4Row) { $a4Row } else { "NO_MATCH" }
    optionalFieldChecks = if ($a4Row) {
        [ordered]@{
            responsavelPreserved = Test-NonBlank $a4Row.Responsavel
            prazoPreserved = Test-NonBlank $a4Row.DataFim
            horasNonBlank = Test-NonBlank $a4Row.HorasRealizadas
            statusChanged = ((Normalize-Text $a4Row.Status) -match "(?i)^Em andamento$")
        }
    } else { $null }
}

$a5Marker = "Smoke 3.15 multilinha"
$a5Matches = @($statusRowsInWindow | Where-Object {
    $_.ProjectID -eq $ExpectedProjectId -and
    (Normalize-Text $_.Resumo) -like "*$a5Marker*" -and
    (Normalize-Text $_.RAG) -eq "Amarelo" -and
    ([double]$_.Percentual -eq 45)
})
$a5FieldChecks = [ordered]@{
    expectedProjectId = $ExpectedProjectId
    expectedRag = "Amarelo"
    expectedPercentual = 45
    expectedResumoContains = $a5Marker
    actual = if ($a5Matches.Count -eq 1) { $a5Matches[0] } else { "NO_MATCH" }
}
if ($a5Matches.Count -eq 1) {
    $a5 = $a5Matches[0]
    $a5FieldChecks.matches = [ordered]@{
        projectId = ($a5.ProjectID -eq $ExpectedProjectId)
        rag = ((Normalize-Text $a5.RAG) -eq "Amarelo")
        percentual = ([double]$a5.Percentual -eq 45)
        resumo = ((Normalize-Text $a5.Resumo) -like "*$a5Marker*")
        deleted = ($a5.Deleted -ne $true -and [string]$a5.Deleted -ne "1")
    }
}

$tests = [ordered]@{
    "A1_CMD-12-H" = if ($scopeProject -and $scopeTasks.Count -ge 1) {
        New-TestResult -Status "PASS" -Details "Project exists and has at least one active non-deleted task." -Evidence ([ordered]@{
            project = $scopeProject
            taskCount = $scopeTasks.Count
            first5Tasks = $scopeTasksFirst5
        })
    } else {
        New-TestResult -Status "NO_DATA" -Details "Scope project or active task baseline was not found." -Evidence ([ordered]@{
            project = if ($scopeProject) { $scopeProject } else { "NO_MATCH" }
            taskCount = $scopeTasks.Count
            first5Tasks = $scopeTasksFirst5
        })
    }

    "A2_CMD-15" = if ($activeProjects.Count -gt 0) {
        New-TestResult -Status "PASS" -Details "Portfolio baseline query returned active non-deleted projects." -Evidence ([ordered]@{
            activeProjectCount = $activeProjects.Count
            tenMostRecentProjects = $recentProjects
        })
    } else {
        New-TestResult -Status "NO_DATA" -Details "No active non-deleted projects found." -Evidence ([ordered]@{
            activeProjectCount = 0
            tenMostRecentProjects = @()
        })
    }

    "A3_CMD-11-P0" = if ($a3Matches.Count -eq 0) {
        New-TestResult -Status "NO_DATA" -Details "No CriarTarefa smoke row matched in the supplied window." -Evidence $a3FieldChecks
    } elseif ($a3Matches.Count -eq 1 -and -not (@($a3FieldChecks.matches.PSObject.Properties.Value | Where-Object { $_ -ne $true }).Count)) {
        New-TestResult -Status "PASS" -Details "Exactly one CriarTarefa smoke row matched expected fields." -Evidence $a3FieldChecks
    } else {
        New-TestResult -Status "FAIL" -Details "CriarTarefa matched unexpected count or field values." -Evidence ([ordered]@{
            matchCount = $a3Matches.Count
            matches = $a3Matches
            expectedVsActual = $a3FieldChecks
        })
    }

    "A4_CMD-13A" = if (-not $a4Row) {
        New-TestResult -Status "NO_DATA" -Details "Task item was not found or is logically deleted." -Evidence $a4Checks
    } elseif (-not $a4ModifiedInWindow) {
        New-TestResult -Status "NO_DATA" -Details "Task item exists, but was not modified in the supplied smoke window." -Evidence $a4Checks
    } elseif (-not (@($a4Checks.optionalFieldChecks.PSObject.Properties.Value | Where-Object { $_ -ne $true }).Count)) {
        New-TestResult -Status "PASS" -Details "Task item was modified in-window and expected current fields are present." -Evidence $a4Checks
    } else {
        New-TestResult -Status "FAIL" -Details "Task item was modified in-window but one or more preservation/status checks failed." -Evidence $a4Checks
    }

    "A5_CMD-10" = if ($a5Matches.Count -eq 0) {
        New-TestResult -Status "NO_DATA" -Details "No AtualizarStatus smoke row matched in the supplied window." -Evidence $a5FieldChecks
    } elseif ($a5Matches.Count -eq 1 -and -not (@($a5FieldChecks.matches.PSObject.Properties.Value | Where-Object { $_ -ne $true }).Count)) {
        New-TestResult -Status "PASS" -Details "Exactly one AtualizarStatus row matched expected values." -Evidence $a5FieldChecks
    } else {
        New-TestResult -Status "FAIL" -Details "AtualizarStatus matched unexpected count or field values." -Evidence ([ordered]@{
            matchCount = $a5Matches.Count
            matches = $a5Matches
            expectedVsActual = $a5FieldChecks
        })
    }
}

$statusValues = @($tests.GetEnumerator() | ForEach-Object { $_.Value.status })
$decision = if (@($statusValues | Where-Object { $_ -ne "PASS" }).Count -eq 0) {
    "PASS_ALL"
} elseif (@($statusValues | Where-Object { $_ -eq "FAIL" }).Count -eq $statusValues.Count) {
    "FAIL_ALL"
} else {
    "MIXED"
}

$report = [ordered]@{
    generatedAt = ConvertTo-IsoBrt (Get-Date).ToUniversalTime()
    environment = [ordered]@{
        expectedName = $ExpectedEnvironmentName
        sharePointSite = $site
        pacCheckSkipped = [bool]$SkipPacEnvironmentCheck
    }
    smokeWindow = [ordered]@{
        startUtc = $startUtc.ToString("o")
        endUtc = $endUtc.ToString("o")
        startBrt = ConvertTo-IsoBrt $startUtc
        endBrt = ConvertTo-IsoBrt $endUtc
    }
    projectScope = $ProjectScope
    expectedProjectId = $ExpectedProjectId
    lists = [ordered]@{
        Projetos = [ordered]@{
            totalActive = $activeProjects.Count
            rowsInWindowPath = $rawFiles.Projetos
            rowsInWindow = $projectRowsInWindow
            sampleRows = $recentProjects
        }
        Tarefas = [ordered]@{
            rowsInWindowPath = $rawFiles.Tarefas
            rowsInWindow = $taskRowsInWindow
        }
        StatusDiario = [ordered]@{
            rowsInWindowPath = $rawFiles.StatusDiario
            rowsInWindow = $statusRowsInWindow
        }
        RiscosBloqueios = [ordered]@{
            rowsInWindowPath = $rawFiles.RiscosBloqueios
            rowsInWindow = $riskRowsInWindow
        }
        DecisoesBoard = [ordered]@{
            rowsInWindowPath = $rawFiles.DecisoesBoard
            rowsInWindow = $decisionRowsInWindow
        }
    }
    tests = $tests
    decision = $decision
    readOnly = [ordered]@{
        pnpCommandsUsed = @("Import-Module", "Connect-PnPOnline", "Get-PnPWeb", "Get-PnPListItem")
        forbiddenWriteCommands = $forbiddenCommands
        deletedFilterApplied = $true
    }
}

$reportPath = Join-Path $OutputDir "aq09_sp_side_effects_report.json"
Write-Utf8NoBom -Path $reportPath -Content (ConvertTo-JsonText -Value $report -Depth 50)

$summary = [ordered]@{
    reportPath = $reportPath
    decision = $decision
    tests = $tests
}

$summary | ConvertTo-Json -Depth 20

if (@($statusValues | Where-Object { $_ -eq "FAIL" }).Count -gt 0) {
    exit 1
}
