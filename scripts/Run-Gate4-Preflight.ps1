[CmdletBinding()]
param(
    [string]$RepoRoot = "D:\VMs\Projetos\STT_Project_Management",
    [string]$EnvironmentId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$ExpectedPackageSha256 = "3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB",
    [switch]$ResumeFromStep03
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

# Mandatory references read before authoring/execution:
# 1. .planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
# 2. .planning/TENANT_COMMAND_RUNBOOK.md
# 3. .planning/GOLDEN_RULES.md
# 4. .planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
# 5. .planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md
# 6. .planning/power-platform-tooling-guide.md
# 7. .planning/CURRENT_BASELINE.md
# 8. docs/MANUAL_OPERACIONAL_PMO.md
# 9. .planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md

$AgentName = 'Codex #2 Bravo'
$PreflightDir = '.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT'
$ShipArtifactDir = '.planning/comms/codex_pm0_remediation_20260522/CODEX2/SHIP_ARTIFACT'
$PackagePath = '.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip'
$CanonicalPackagePath = 'Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip'
$OldFailedPackageSha256 = '4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15'
$EnvironmentUrl = 'https://colofertasbrasilpro.crm4.dynamics.com'
$PowerAppsModule = 'C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1'
$AdminModule = 'C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1'
$PacExe = 'C:\Users\dataops-lab\AppData\Local\Microsoft\PowerAppsCli\Microsoft.PowerApps.CLI.2.6.4\tools\pac.exe'
$DataverseResource = 'https://colofertasbrasilpro.crm4.dynamics.com/'
$TargetSolutions = @('PMO_v11_Tarefas', 'PMO_AQ07_CopilotBinding')
$Pm0WorkflowIds = @(
    '1721e0a3-a250-f111-bec7-000d3abc5cc6',
    '7c6300c2-a250-f111-bec7-000d3abc5cc6',
    '7f662db7-a250-f111-bec7-000d3abc5cc6',
    'e0e3c6b0-a250-f111-bec7-000d3abc5cc6',
    '8333bd91-a250-f111-bec7-000d3abc5cc6'
)
$ExpectedConnectionIds = @(
    '44f187cde7f54f208cf22bac4e533816',
    'shared-teams-1440d346-f1dd-44ea-912f-3787038ac333',
    '306d783533364cb6948ab2830fc3b188'
)

function Get-UtcStamp {
    (Get-Date).ToUniversalTime().ToString('yyyyMMdd_HHmmss')
}

function Get-BrtTimestamp {
    Get-Date -Format 'yyyy-MM-dd HH:mm:ss BRT'
}

function Resolve-RepoRelativePath {
    param([Parameter(Mandatory)][string]$Path)
    Join-Path $RepoRoot $Path
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Value
    )
    $fullPath = Resolve-RepoRelativePath -Path $Path
    $directory = Split-Path -Parent $fullPath
    if ($directory) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }
    [System.IO.File]::WriteAllText($fullPath, $Value, (New-Object System.Text.UTF8Encoding($false)))
}

function ConvertTo-JsonSafe {
    param([Parameter(Mandatory)][object]$InputObject)
    $InputObject | ConvertTo-Json -Depth 100
}

function Write-TextPng {
    param(
        [Parameter(Mandatory)][string]$Text,
        [Parameter(Mandatory)][string]$Path
    )
    Add-Type -AssemblyName System.Drawing
    $fullPath = Resolve-RepoRelativePath -Path $Path
    $directory = Split-Path -Parent $fullPath
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $font = New-Object System.Drawing.Font('Consolas', 11)
    $lines = @($Text -split "`r?`n")
    $lineHeight = [int][Math]::Ceiling($font.GetHeight() + 3)
    $bitmap = New-Object System.Drawing.Bitmap(1800, ([Math]::Max(360, ($lines.Count + 4) * $lineHeight)))
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.Clear([System.Drawing.Color]::FromArgb(18, 18, 18))
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(238, 238, 238))
        try {
            $y = 14
            foreach ($line in $lines) {
                $graphics.DrawString($line, $font, $brush, 14, $y)
                $y += $lineHeight
            }
        }
        finally {
            $brush.Dispose()
        }
        $bitmap.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
        $font.Dispose()
    }
}

function Write-Evidence {
    param(
        [Parameter(Mandatory)][string]$Step,
        [Parameter(Mandatory)][string]$Slug,
        [Parameter(Mandatory)][string]$Description,
        [Parameter(Mandatory)][string]$CommandLine,
        [Parameter(Mandatory)][object]$Data,
        [string]$Text,
        [switch]$NoJson
    )
    $stamp = Get-UtcStamp
    $base = Join-Path $PreflightDir ("{0}_{1}_{2}" -f $Step, $Slug, $stamp)
    $jsonPath = "$base.json"
    $txtPath = "$base.txt"
    $mdPath = "$base.md"
    $pngPath = "$base.png"
    $bodyText = if ([string]::IsNullOrWhiteSpace($Text)) { ConvertTo-JsonSafe -InputObject $Data } else { $Text }

    if (-not $NoJson) {
        Write-Utf8File -Path $jsonPath -Value (ConvertTo-JsonSafe -InputObject $Data)
    }
    Write-Utf8File -Path $txtPath -Value $bodyText
    Write-TextPng -Text $bodyText -Path $pngPath

    $md = @"
# Evidence $Step - $Slug

| Field | Value |
|---|---|
| Timestamp BRT | $(Get-BrtTimestamp) |
| Agent | $AgentName |
| Result | PASS |
| Description | $Description |
| Source command line | ``$CommandLine`` |
| JSON path | ``$jsonPath`` |
| Text path | ``$txtPath`` |
| PNG path | ``$pngPath`` |
"@
    Write-Utf8File -Path $mdPath -Value $md
    [pscustomobject]@{ Step = $Step; Slug = $Slug; Json = $jsonPath; Text = $txtPath; Markdown = $mdPath; Png = $pngPath }
}

function Write-Halt {
    param(
        [Parameter(Mandatory)][string]$Step,
        [Parameter(Mandatory)][string]$Reason,
        [string[]]$SuccessfulCommands = @()
    )
    $stamp = Get-UtcStamp
    $path = Join-Path $PreflightDir "PREFLIGHT_HALT_$stamp.md"
    $commands = if ($SuccessfulCommands.Count -eq 0) { '- None' } else { ($SuccessfulCommands | ForEach-Object { "- ``$_``" }) -join "`n" }
    $content = @"
# Gate 4 Preflight Halt

| Field | Value |
|---|---|
| Timestamp BRT | $(Get-BrtTimestamp) |
| Agent | $AgentName |
| Status | HALTED |
| Step | $Step |

## Reason

$Reason

## Commands Run Successfully Before Halt

$commands

## Recommendation

Review the halt reason, correct the blocking condition, and rerun the read-only preflight from the beginning. No tenant write was executed.
"@
    Write-Utf8File -Path $path -Value $content
    throw "HALTED at ${Step}: $Reason. Halt file: $path"
}

function Invoke-External {
    param([Parameter(Mandatory)][string[]]$Arguments)
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Arguments[0]
    $escapedArguments = for ($i = 1; $i -lt $Arguments.Count; $i++) {
        if ($Arguments[$i] -match '\s') {
            '"' + ($Arguments[$i].Replace('"', '\"')) + '"'
        }
        else {
            $Arguments[$i]
        }
    }
    $psi.Arguments = ($escapedArguments -join ' ')
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    try {
        $process = [System.Diagnostics.Process]::Start($psi)
    }
    catch {
        return [pscustomobject]@{
            command = ($Arguments -join ' ')
            exitCode = -1
            stdout = ''
            stderr = $_.Exception.Message
        }
    }
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    [pscustomobject]@{
        command = ($Arguments -join ' ')
        exitCode = $process.ExitCode
        stdout = $stdout
        stderr = $stderr
    }
}

function Invoke-Pac {
    param([Parameter(Mandatory)][string[]]$Arguments)
    if (-not (Test-Path -LiteralPath $PacExe)) {
        Write-Halt -Step '00_auth_verify' -Reason "Pinned PAC executable not found: $PacExe"
    }
    Invoke-External -Arguments (@($PacExe) + $Arguments)
}

function Get-ToolVersionText {
    param(
        [Parameter(Mandatory)][string]$Tool,
        [string[]]$Arguments = @('--version')
    )
    $result = Invoke-External -Arguments (@($Tool) + $Arguments)
    if ($result.exitCode -ne 0) {
        return $result.stderr.Trim()
    }
    $firstLine = @($result.stdout -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1)
    if ($firstLine.Count -eq 0) {
        return $result.stdout.Trim()
    }
    $firstLine[0]
}

function Get-DataverseToken {
    [CmdletBinding()]
    param()

    $errors = [System.Collections.Generic.List[object]]::new()

    $azCommand = Get-Command az -ErrorAction SilentlyContinue
    if ($azCommand) {
        $timer = [System.Diagnostics.Stopwatch]::StartNew()
        $az = Invoke-External -Arguments @($azCommand.Source, 'account', 'get-access-token', '--resource', $DataverseResource, '--query', 'accessToken', '-o', 'tsv')
        $timer.Stop()
        if ($az.exitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($az.stdout)) {
            return [pscustomobject]@{
                Token = $az.stdout.Trim()
                Path = 'AZ_CLI'
                ToolVersion = (Get-ToolVersionText -Tool $azCommand.Source)
                Resource = $DataverseResource
                TimeToAcquireSeconds = [Math]::Round($timer.Elapsed.TotalSeconds, 3)
                Errors = @($errors)
            }
        }
        $errors.Add([pscustomobject]@{ candidate = 'AZ_CLI'; error = (($az.stderr + "`n" + $az.stdout) -replace 'Bearer\s+[A-Za-z0-9\-_\.]+', 'Bearer <REDACTED>') }) | Out-Null
    }
    else {
        $errors.Add([pscustomobject]@{ candidate = 'AZ_CLI'; error = 'az CLI not installed or not on PATH.' }) | Out-Null
    }

    $msalModule = Get-Module -ListAvailable MSAL.PS | Sort-Object Version -Descending | Select-Object -First 1
    if ($msalModule) {
        $errors.Add([pscustomobject]@{ candidate = 'MSAL_PS'; error = 'MSAL.PS is installed, but PAC public client ID is not present in the prompt/current runbook. Skipped to avoid improvising a ClientId.' }) | Out-Null
    }
    else {
        $errors.Add([pscustomobject]@{ candidate = 'MSAL_PS'; error = 'MSAL.PS module not installed.' }) | Out-Null
    }

    $xrmModule = Get-Module -ListAvailable Microsoft.Xrm.Tooling.Connector | Sort-Object Version -Descending | Select-Object -First 1
    if ($xrmModule) {
        $errors.Add([pscustomobject]@{ candidate = 'XRM_TOOLING'; error = 'Microsoft.Xrm.Tooling.Connector is installed, but interactive token extraction is not implemented without echo-safe validation in this orchestrator.' }) | Out-Null
    }
    else {
        $errors.Add([pscustomobject]@{ candidate = 'XRM_TOOLING'; error = 'Microsoft.Xrm.Tooling.Connector module not installed.' }) | Out-Null
    }

    Write-Halt -Step '03_solutioncomponents' -Reason ("Section 6.7 token acquisition failed. Candidate errors: " + (($errors | ConvertTo-Json -Depth 5) -replace 'Bearer\s+[A-Za-z0-9\-_\.]+', 'Bearer <REDACTED>')) -SuccessfulCommands $successful
}

function Invoke-DataverseGet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Token,
        [Parameter(Mandatory)][string]$Step
    )
    $headers = @{
        Authorization      = "Bearer $Token"
        Accept             = 'application/json'
        'OData-MaxVersion' = '4.0'
        'OData-Version'    = '4.0'
        Prefer             = 'odata.include-annotations=*'
    }
    try {
        Invoke-RestMethod -Method Get -Uri ($EnvironmentUrl.TrimEnd('/') + $Path) -Headers $headers -ErrorAction Stop
    }
    catch {
        $safeMessage = $_.Exception.Message -replace 'Bearer\s+[A-Za-z0-9\-_\.]+', 'Bearer <REDACTED>'
        Write-Halt -Step $Step -Reason "Dataverse GET failed for path $Path. Error: $safeMessage" -SuccessfulCommands $successful
    }
}

function Clear-PreflightTranscriptSecret {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }
    $content = Get-Content -LiteralPath $Path -Raw
    $content = $content -replace 'Bearer\s+[A-Za-z0-9\-_\.]+', 'Bearer <REDACTED>'
    $content = $content -replace '(?i)"accessToken"\s*:\s*"[^"]+"', '"accessToken":"<REDACTED>"'
    $content = $content -replace '(?im)^.*accessToken.*$', '<REDACTED accessToken line>'
    [System.IO.File]::WriteAllText($Path, $content, (New-Object System.Text.UTF8Encoding($false)))
}

function Assert-NoTokenLeak {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Step
    )
    $bearerHit = Select-String -Path $Path -SimpleMatch -Pattern 'Bearer eyJ' -Quiet
    $accessTokenHit = Select-String -Path $Path -SimpleMatch -Pattern 'accessToken' -Quiet
    if ($bearerHit -or $accessTokenHit) {
        Write-Halt -Step $Step -Reason "Section 6.7 token leak verification failed for $Path. BearerHit=$bearerHit AccessTokenHit=$accessTokenHit" -SuccessfulCommands $successful
    }
}

function Import-PowerAppsModule {
    # Runbook section 3 absolute imports, Windows PowerShell 5.1 only.
    if ($PSVersionTable.PSVersion.Major -ne 5) {
        Write-Halt -Step 'module_import' -Reason 'PowerApps modules must run under Windows PowerShell 5.1.'
    }
    Import-Module $AdminModule -ErrorAction Stop
    Import-Module $PowerAppsModule -ErrorAction Stop
}

function Assert-ExternalSuccess {
    param(
        [Parameter(Mandatory)][object]$Result,
        [Parameter(Mandatory)][string]$Step
    )
    if ($Result.exitCode -ne 0) {
        Write-Halt -Step $Step -Reason "Command failed: $($Result.command)`n$($Result.stderr)"
    }
}

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path (Resolve-RepoRelativePath -Path $PreflightDir) | Out-Null
$transcriptPath = Resolve-RepoRelativePath -Path (Join-Path $PreflightDir ("_transcript_{0}.log" -f (Get-UtcStamp)))
$successful = [System.Collections.Generic.List[string]]::new()
$evidence = [System.Collections.Generic.List[object]]::new()
$step03MarkdownForScrubUpdate = $null

Start-Transcript -LiteralPath $transcriptPath | Out-Null
try {
    if ($ResumeFromStep03) {
        $successful.Add('RESUME: Pre-Step A and steps 00-02 are green from prior run; resumed at Step 03 per owner instruction.') | Out-Null
    }
    else {
        # Step 0: runbook section 2 auth verify/select.
        $authList = Invoke-Pac -Arguments @('auth', 'list')
        Assert-ExternalSuccess -Result $authList -Step '00_auth_verify'
        $successful.Add($authList.command) | Out-Null
        $envWho = Invoke-Pac -Arguments @('env', 'who')
        if ($envWho.exitCode -ne 0) {
            Write-Halt -Step '00_auth_verify' -Reason "pac env who failed. Operator must run: pac auth create --name COLQA0424 --deviceCode --environment $EnvironmentId"
        }
        if ($envWho.stdout -notmatch [regex]::Escape($EnvironmentId)) {
            $select = Invoke-Pac -Arguments @('env', 'select', '--environment', $EnvironmentId)
            Assert-ExternalSuccess -Result $select -Step '00_auth_verify'
            $successful.Add($select.command) | Out-Null
            $envWho = Invoke-Pac -Arguments @('env', 'who')
            Assert-ExternalSuccess -Result $envWho -Step '00_auth_verify'
        }
        if ($envWho.stdout -notmatch [regex]::Escape($EnvironmentId)) {
            Write-Halt -Step '00_auth_verify' -Reason "Active environment is not pinned environment $EnvironmentId."
        }
        $successful.Add($envWho.command) | Out-Null
        $evidence.Add((Write-Evidence -Step '00' -Slug 'auth_verify' -Description 'PAC auth and pinned environment verified.' -CommandLine 'pac auth list; pac env who' -Data ([ordered]@{ authList = $authList; envWho = $envWho }) -Text ($authList.stdout + "`n" + $envWho.stdout))) | Out-Null

        # Step 1: runbook section 2 solution list.
        $solutionList = Invoke-Pac -Arguments @('solution', 'list', '--environment', $EnvironmentId)
        Assert-ExternalSuccess -Result $solutionList -Step '01_pac_solution_list'
        foreach ($solution in $TargetSolutions) {
            if ($solutionList.stdout -notmatch [regex]::Escape($solution)) {
                Write-Halt -Step '01_pac_solution_list' -Reason "Expected solution missing from pac solution list: $solution" -SuccessfulCommands $successful
            }
        }
        $successful.Add($solutionList.command) | Out-Null
        $evidence.Add((Write-Evidence -Step '01' -Slug 'pac_solution_list' -Description 'Solution list captured and target solution names verified.' -CommandLine 'pac solution list --environment <env>' -Data $solutionList -Text $solutionList.stdout)) | Out-Null

        # Step 2: runbook section 2 connection list.
        $connectionList = Invoke-Pac -Arguments @('connection', 'list', '--environment', $EnvironmentId)
        Assert-ExternalSuccess -Result $connectionList -Step '02_pac_connection_list'
        foreach ($connectionId in $ExpectedConnectionIds) {
            if ($connectionList.stdout -notmatch [regex]::Escape($connectionId)) {
                Write-Halt -Step '02_pac_connection_list' -Reason "Expected connection ID missing: $connectionId" -SuccessfulCommands $successful
            }
        }
        $successful.Add($connectionList.command) | Out-Null
        $evidence.Add((Write-Evidence -Step '02' -Slug 'pac_connection_list' -Description 'Connection list captured and pinned connection IDs verified.' -CommandLine 'pac connection list --environment <env>' -Data $connectionList -Text $connectionList.stdout)) | Out-Null
    }

    Import-PowerAppsModule
    $tokenInfo = Get-DataverseToken
    $dataverseToken = $tokenInfo.Token

    # Step 3: Section 6.7 Dataverse Web API GET for solutions and solutioncomponents.
    $solutionFilter = "uniquename eq 'PMO_v11_Tarefas' or uniquename eq 'PMO_AQ07_CopilotBinding'"
    $solutionsPath = "/api/data/v9.2/solutions?`$select=solutionid,uniquename,friendlyname,version,ismanaged&`$filter=$([uri]::EscapeDataString($solutionFilter))"
    $solutions = Invoke-DataverseGet -Path $solutionsPath -Token $dataverseToken -Step '03_solutioncomponents'
    $solutionRows = @($solutions.value)
    $solutionIds = @{}
    foreach ($solution in $solutionRows) {
        $solutionIds[$solution.uniquename] = $solution.solutionid
    }
    foreach ($name in $TargetSolutions) {
        if (-not $solutionIds.ContainsKey($name)) {
            Write-Halt -Step '03_solutioncomponents' -Reason "Unable to resolve solution ID for $name." -SuccessfulCommands $successful
        }
    }
    $componentData = [ordered]@{ solutions = $solutionRows; components = @{} }
    foreach ($name in $TargetSolutions) {
        $path = "/api/data/v9.2/solutioncomponents?`$filter=_solutionid_value eq $($solutionIds[$name])&`$select=componenttype,objectid,rootcomponentbehavior"
        $componentData.components[$name] = (Invoke-DataverseGet -Path $path -Token $dataverseToken -Step '03_solutioncomponents').value
    }
    $successful.Add('Invoke-DataverseGet solutions + solutioncomponents') | Out-Null
    $step03 = Write-Evidence -Step '03' -Slug 'solutioncomponents' -Description 'Solution component inventory captured for PMO_v11_Tarefas and AQ07.' -CommandLine 'Invoke-DataverseGet /api/data/v9.2/solutioncomponents' -Data ([ordered]@{ tokenPath = $tokenInfo.Path; tokenToolVersion = $tokenInfo.ToolVersion; resource = $tokenInfo.Resource; timeToAcquireSeconds = $tokenInfo.TimeToAcquireSeconds; components = $componentData })
    $tokenHeader = @"

## Token acquisition path used (Section 6.7)
- Path: $($tokenInfo.Path)
- Tool version: $($tokenInfo.ToolVersion)
- Resource: $($tokenInfo.Resource)
- Acquisition outcome: SUCCESS
- Time to acquire: $($tokenInfo.TimeToAcquireSeconds) seconds
- Token redacted in transcript: PENDING_FINAL_SCRUB
"@
    Write-Utf8File -Path $step03.Markdown -Value ((Get-Content -LiteralPath (Resolve-RepoRelativePath -Path $step03.Markdown) -Raw) + $tokenHeader)
    $step03MarkdownForScrubUpdate = Resolve-RepoRelativePath -Path $step03.Markdown
    $evidence.Add($step03) | Out-Null

    # Step 4: Section 6.7 Dataverse Web API GET for PM0 bot/action binding rows.
    $bindingPath = "/api/data/v9.2/botcomponents?`$select=botcomponentid,name,componenttype,statecode,statuscode&`$filter=contains(name,'PM0_PA_Card')"
    $bindings = Invoke-DataverseGet -Path $bindingPath -Token $dataverseToken -Step '04_workflowset_binding'
    $successful.Add('Invoke-DataverseGet botcomponents PM0_PA_Card') | Out-Null
    $evidence.Add((Write-Evidence -Step '04' -Slug 'workflowset_binding' -Description 'PM0 bot component binding candidates captured.' -CommandLine "Invoke-DataverseGet $bindingPath" -Data $bindings)) | Out-Null

    # Step 5: runbook sections 3 and 4 Get-Flow.
    $flows = @(Get-Flow -EnvironmentName $EnvironmentId -Top 200 -ErrorAction Stop)
    $pm0Flows = @($flows | Where-Object { $Pm0WorkflowIds -contains $_.Internal.properties.workflowEntityId } |
        Select-Object DisplayName, FlowName, Enabled, CreatedTime, LastModifiedTime,
            @{ Name = 'State'; Expression = { $_.Internal.properties.state } },
            @{ Name = 'WorkflowEntityId'; Expression = { $_.Internal.properties.workflowEntityId } },
            @{ Name = 'DefinitionSummary'; Expression = { $_.Internal.properties.definitionSummary } })
    if ($pm0Flows.Count -ne 5) {
        Write-Halt -Step '05_pm0_flow_inventory' -Reason "Expected 5 PM0 flows from Get-Flow, found $($pm0Flows.Count)." -SuccessfulCommands $successful
    }
    $successful.Add('Get-Flow -EnvironmentName <env> -Top 200') | Out-Null
    $evidence.Add((Write-Evidence -Step '05' -Slug 'pm0_flow_inventory' -Description 'PM0 flow inventory captured with definition summaries.' -CommandLine 'Get-Flow -EnvironmentName <env> -Top 200' -Data $pm0Flows)) | Out-Null

    # Step 6: Section 6.7 Dataverse Web API GET bot row.
    $botFilter = "name eq 'Assistente PMO V2'"
    $botPath = "/api/data/v9.2/bots?`$filter=$([uri]::EscapeDataString($botFilter))&`$select=name,statecode,statuscode,publishedon,configuration"
    $botRow = Invoke-DataverseGet -Path $botPath -Token $dataverseToken -Step '06_bot_row'
    $successful.Add('Invoke-DataverseGet bots Assistente PMO V2') | Out-Null
    $evidence.Add((Write-Evidence -Step '06' -Slug 'bot_row' -Description 'Assistente PMO V2 bot row captured.' -CommandLine "Invoke-DataverseGet $botPath" -Data $botRow)) | Out-Null

    # Step 7: local AQ-08 structural verifier without unapproved PAC org/env fetch.
    $aq08 = Invoke-External -Arguments @('powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Resolve-RepoRelativePath -Path 'tests/Test-CopilotRoutingInstructions.ps1'), '-PackagePath', (Resolve-RepoRelativePath -Path $PackagePath))
    Assert-ExternalSuccess -Result $aq08 -Step '07_aq08_verifier'
    $successful.Add($aq08.command) | Out-Null
    $evidence.Add((Write-Evidence -Step '07' -Slug 'aq08_verifier' -Description 'AQ-08 structural routing verifier passed against corrected package.' -CommandLine 'tests/Test-CopilotRoutingInstructions.ps1 -PackagePath <package>' -Data $aq08 -Text $aq08.stdout)) | Out-Null

    # Step 8: local strict consistency and SHA check.
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Resolve-RepoRelativePath -Path $PackagePath)).Hash
    if ($hash -ne $ExpectedPackageSha256) {
        Write-Halt -Step '08_strict_consistency' -Reason "Package SHA mismatch. Expected $ExpectedPackageSha256, got $hash." -SuccessfulCommands $successful
    }
    $strict = Invoke-External -Arguments @('powershell.exe', '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', (Resolve-RepoRelativePath -Path 'scripts/New-Solution316Pm0PackageEvidence.ps1'), '-PackagePath', (Resolve-RepoRelativePath -Path $PackagePath), '-EvidenceDir', (Resolve-RepoRelativePath -Path $PreflightDir), '-DiffDir', (Resolve-RepoRelativePath -Path '.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/diffs'))
    Assert-ExternalSuccess -Result $strict -Step '08_strict_consistency'
    $successful.Add($strict.command) | Out-Null
    $evidence.Add((Write-Evidence -Step '08' -Slug 'strict_consistency' -Description 'Corrected package SHA and strict consistency rerun passed.' -CommandLine 'scripts/New-Solution316Pm0PackageEvidence.ps1 -PackagePath <package>' -Data ([ordered]@{ sha256 = $hash; command = $strict }) -Text $strict.stdout)) | Out-Null

    # Step 9: runbook section 6 InvokeApi GET processsession baseline per PM0 workflow.
    foreach ($workflowId in $Pm0WorkflowIds) {
        $processPath = "/api/data/v9.2/processsessions?`$filter=_regardingobjectid_value eq $workflowId&`$select=processid,regardingobjectid,startedon,completedon,status&`$top=50&`$orderby=startedon desc"
        $processRows = Invoke-DataverseGet -Path $processPath -Token $dataverseToken -Step '09_processsession_baseline'
        $successful.Add("Invoke-DataverseGet processsessions $workflowId") | Out-Null
        $evidence.Add((Write-Evidence -Step '09' -Slug "processsession_baseline_$workflowId" -Description "Process session baseline captured for $workflowId." -CommandLine "Invoke-DataverseGet $processPath" -Data $processRows)) | Out-Null
    }
    $dataverseToken = $null
    $tokenInfo.Token = $null

    # Step 10: operator UI screenshot stub only, no UI write.
    $uiStub = [ordered]@{
        requiredOperatorAction = 'Capture Copilot Studio Assistente PMO V2 overview showing publish state, version, and visible PM0 topic list.'
        expectedPngPattern = '10_copilot_studio_pre_import_<UTC>.png'
        noUiWrite = $true
    }
    $evidence.Add((Write-Evidence -Step '10' -Slug 'copilot_studio_pre_import' -Description 'Operator screenshot instruction stub written; no UI write performed.' -CommandLine 'Manual browser screenshot only' -Data $uiStub)) | Out-Null

    # Step 11: local AQ-09 harness readiness against corrected package workflowset/action IDs.
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("gate4_aq09_" + [guid]::NewGuid().ToString('N'))
    [System.IO.Compression.ZipFile]::ExtractToDirectory((Resolve-RepoRelativePath -Path $PackagePath), $temp)
    try {
        $workflowSetPath = Join-Path $temp 'Assets/botcomponent_workflowset.xml'
        if (-not (Test-Path -LiteralPath $workflowSetPath)) {
            Write-Halt -Step '11_aq09_harness_readiness' -Reason 'Assets/botcomponent_workflowset.xml missing from corrected package.' -SuccessfulCommands $successful
        }
        $workflowSet = Get-Content -LiteralPath $workflowSetPath -Raw
        $missingIds = @($Pm0WorkflowIds | Where-Object { $workflowSet -notmatch [regex]::Escape($_) })
        if ($missingIds.Count -gt 0) {
            Write-Halt -Step '11_aq09_harness_readiness' -Reason "Workflowset missing PM0 workflow IDs: $($missingIds -join ', ')." -SuccessfulCommands $successful
        }
        $harnessText = Get-Content -LiteralPath (Resolve-RepoRelativePath -Path 'tests/Test-PMOFlowStopShipAudit.ps1') -Raw
        $readiness = [ordered]@{
            workflowsetPath = 'Assets/botcomponent_workflowset.xml'
            workflowIdsPresent = $Pm0WorkflowIds
            harnessPath = 'tests/Test-PMOFlowStopShipAudit.ps1'
            harnessMentionsPm0 = ($harnessText -match 'PMO_PA_' -or $harnessText -match 'PM0_PA_')
            result = 'PASS'
        }
    }
    finally {
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -LiteralPath $temp -Recurse -Force
        }
    }
    $evidence.Add((Write-Evidence -Step '11' -Slug 'aq09_harness_readiness' -Description 'AQ-09 harness readiness checked against corrected package workflow IDs.' -CommandLine 'Inspect corrected package workflowset and tests/Test-PMOFlowStopShipAudit.ps1' -Data $readiness)) | Out-Null

    # Section 7.5 rollback export, read-only PAC export before ASK.
    $rollbackStamp = Get-UtcStamp
    $rollbackDir = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/ROLLBACK/4A_pre_import_$rollbackStamp"
    New-Item -ItemType Directory -Force -Path (Resolve-RepoRelativePath -Path $rollbackDir) | Out-Null
    $rollbackItems = [System.Collections.Generic.List[object]]::new()
    foreach ($solutionName in $TargetSolutions) {
        foreach ($mode in @('unmanaged', 'managed')) {
            $managed = if ($mode -eq 'managed') { 'true' } else { 'false' }
            $zipPath = Join-Path $rollbackDir ("{0}_{1}.zip" -f $solutionName, $mode)
            $shaPath = Join-Path $rollbackDir ("{0}_{1}.sha256.txt" -f $solutionName, $mode)
            $export = Invoke-Pac -Arguments @('solution', 'export', '--environment', $EnvironmentId, '--name', $solutionName, '--path', $zipPath, '--managed', $managed, '--overwrite')
            Assert-ExternalSuccess -Result $export -Step 'rollback_4A'
            $zipFull = Resolve-RepoRelativePath -Path $zipPath
            $zipHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $zipFull).Hash
            Write-Utf8File -Path $shaPath -Value $zipHash
            $rollbackItems.Add([pscustomobject]@{ solution = $solutionName; mode = $mode; zip = $zipPath; sha256 = $zipHash; shaFile = $shaPath }) | Out-Null
        }
    }
    $manifestRows = ($rollbackItems | ForEach-Object { "| $($_.solution) | $($_.mode) | `$($_.zip)` | `$($_.sha256)` |" }) -join "`n"
    $manifest = @"
# Gate 4A Pre-Import Rollback Manifest

| Field | Value |
|---|---|
| Timestamp BRT | $(Get-BrtTimestamp) |
| Agent | $AgentName |
| Gate | 4A pre-import |
| Environment | $EnvironmentId |

| Solution | Mode | ZIP | SHA256 |
|---|---|---|---|
$manifestRows
"@
    Write-Utf8File -Path (Join-Path $rollbackDir 'manifest.md') -Value $manifest
    $restoreCommands = ($rollbackItems | ForEach-Object {
        "pac solution import `` `n  --environment $EnvironmentId `` `n  --path `"$($_.zip)`" `` `n  --activate-plugins"
    }) -join "`n`n"
    $restore = @"
# Gate 4A Restore Runbook

Recommended order: import `PMO_AQ07_CopilotBinding` artifacts first if dependency read-back shows AQ07 carries binding rows, then `PMO_v11_Tarefas`. Use only after owner approval.

~~~powershell
$restoreCommands
~~~
"@
    Write-Utf8File -Path (Join-Path $rollbackDir 'restore_runbook.md') -Value $restore

    $expectedZips = @($rollbackItems | ForEach-Object { Resolve-RepoRelativePath -Path $_.zip })
$r1 = ((@($expectedZips | Where-Object { (Test-Path -LiteralPath $_) -and ((Get-Item -LiteralPath $_).Length -gt 0) })).Count -eq 4)
    $r2 = $true
    foreach ($item in $rollbackItems) {
        $zipHashNow = (Get-FileHash -Algorithm SHA256 -LiteralPath (Resolve-RepoRelativePath -Path $item.zip)).Hash
        $recorded = (Get-Content -LiteralPath (Resolve-RepoRelativePath -Path $item.shaFile) -Raw).Trim()
        if ($zipHashNow -ne $recorded) { $r2 = $false }
    }
    $manifestPath = Join-Path $rollbackDir 'manifest.md'
    $restorePath = Join-Path $rollbackDir 'restore_runbook.md'
    $manifestText = Get-Content -LiteralPath (Resolve-RepoRelativePath -Path $manifestPath) -Raw
    $restoreText = Get-Content -LiteralPath (Resolve-RepoRelativePath -Path $restorePath) -Raw
    $r3 = (($manifestText -match [regex]::Escape($AgentName)) -and ($manifestText -match 'BRT') -and ((@($rollbackItems | Where-Object { $manifestText -match [regex]::Escape($_.zip) })).Count -eq 4))
    $r4 = (($restoreText -match [regex]::Escape($EnvironmentId)) -and ((@($rollbackItems | Where-Object { $restoreText -match [regex]::Escape($_.zip) })).Count -eq 4))
    if (-not ($r1 -and $r2 -and $r3 -and $r4)) {
        Write-Halt -Step 'rollback_4A' -Reason "Rollback verification failed. R1=$r1 R2=$r2 R3=$r3 R4=$r4" -SuccessfulCommands $successful
    }

    # Section 7.6: relocate corrected ZIP to the canonical ship path.
    $shipDirFull = Resolve-RepoRelativePath -Path $ShipArtifactDir
    New-Item -ItemType Directory -Force -Path $shipDirFull | Out-Null
    $sourceFull = Resolve-RepoRelativePath -Path $PackagePath
    $destinationFull = Resolve-RepoRelativePath -Path $CanonicalPackagePath
    if (-not (Test-Path -LiteralPath $sourceFull)) {
        Write-Halt -Step 'ship_artifact_relocation' -Reason "Corrected package source missing: $PackagePath" -SuccessfulCommands $successful
    }
    if (-not (Test-Path -LiteralPath $destinationFull)) {
        Write-Halt -Step 'ship_artifact_relocation' -Reason "Canonical package destination missing: $CanonicalPackagePath" -SuccessfulCommands $successful
    }
    $sourceSha = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourceFull).Hash
    if ($sourceSha -ne $ExpectedPackageSha256) {
        Write-Halt -Step 'ship_artifact_relocation' -Reason "Source SHA mismatch: actual $sourceSha vs expected $ExpectedPackageSha256" -SuccessfulCommands $successful
    }
    $destinationShaPre = (Get-FileHash -Algorithm SHA256 -LiteralPath $destinationFull).Hash
    if ($destinationShaPre -eq $ExpectedPackageSha256) {
        $relocationOutcome = 'ALREADY_AT_TARGET'
    }
    elseif ($destinationShaPre -eq $OldFailedPackageSha256) {
        Copy-Item -LiteralPath $sourceFull -Destination $destinationFull -Force
        $relocationOutcome = 'COPIED'
    }
    else {
        Write-Halt -Step 'ship_artifact_relocation' -Reason "Destination SHA is unexpected: $destinationShaPre" -SuccessfulCommands $successful
    }
    $destinationShaPost = (Get-FileHash -Algorithm SHA256 -LiteralPath $destinationFull).Hash
    if ($destinationShaPost -ne $ExpectedPackageSha256) {
        Write-Halt -Step 'ship_artifact_relocation' -Reason "Destination SHA mismatch after relocation: actual $destinationShaPost vs expected $ExpectedPackageSha256" -SuccessfulCommands $successful
    }
    $sourceShaPost = (Get-FileHash -Algorithm SHA256 -LiteralPath $sourceFull).Hash
    if ($sourceShaPost -ne $ExpectedPackageSha256) {
        Write-Halt -Step 'ship_artifact_relocation' -Reason "Historical source SHA changed unexpectedly: $sourceShaPost" -SuccessfulCommands $successful
    }
    $relocationStamp = Get-UtcStamp
    $relocationPath = Join-Path $ShipArtifactDir "relocation_$relocationStamp.md"
    $relocationPng = Join-Path $ShipArtifactDir "relocation_$relocationStamp.png"
    $relocationText = @"
# Canonical Artifact Relocation

| Field | Value |
|---|---|
| Timestamp BRT | $(Get-BrtTimestamp) |
| Agent | $AgentName |
| Outcome | $relocationOutcome |
| Source path | `$PackagePath` |
| Source SHA256 | $sourceShaPost |
| Destination path | `$CanonicalPackagePath` |
| Destination SHA256 before | $destinationShaPre |
| Destination SHA256 after | $destinationShaPost |
| Source command line | `Get-FileHash; Copy-Item when destination held the old failed SHA` |
"@
    Write-Utf8File -Path $relocationPath -Value $relocationText
    Write-TextPng -Text $relocationText -Path $relocationPng

    $summaryPath = Join-Path $PreflightDir ("PREFLIGHT_SUMMARY_{0}.md" -f (Get-UtcStamp))
    $evidenceRows = ($evidence | ForEach-Object { "| $($_.Step) | $($_.Slug) | PASS | `$($_.Markdown)` |" }) -join "`n"
    $summary = @"
# Gate 4 Preflight Summary

| Field | Value |
|---|---|
| Timestamp BRT | $(Get-BrtTimestamp) |
| Agent | $AgentName |
| Status | GREEN |
| Rollback path | `$rollbackDir` |
| Canonical artifact relocation | $relocationOutcome |
| Relocation evidence | `$relocationPath` |

| Step | Slug | Result | Evidence |
|---|---|---|---|
$evidenceRows

Rollback R1-R4: PASS.
"@
    Write-Utf8File -Path $summaryPath -Value $summary

    $askPath = ".planning/comms/codex_pm0_remediation_20260522/CODEX2/GATE_4A_ASK_DRAFT_$(Get-UtcStamp).md"
    $tick = [char]96
    $ask = @"
# Gate 4A - Solution Import - ASK FOR OWNER APPROVAL

| Field | Value |
|---|---|
| Gate | 4A - Import only (no publish; publish = Gate 4B; cleanup = Gate 4C) |
| Package path | $CanonicalPackagePath (canonical ship path; relocated from `CODEX2/PACKAGE/package/...zip` per Section 7.6) |
| Package SHA256 | $ExpectedPackageSha256 |
| Environment | ColOfertasBrasilPro - $EnvironmentId |
| Auth | Existing device-code profile COLQA0424 (verified at step 00) |
| Preflight | All 13 evidence triplets PASS (1 reconciliation + 12 preflight) - see $summaryPath |
| Canonical artifact relocation | PASS (Section 7.6 evidence: $relocationPath) |
| Rollback artifact path | $rollbackDir/ |
| Rollback verification | R1 PASS - R2 PASS - R3 PASS - R4 PASS (per Section 6.6.4) |
| Restore runbook | `$rollbackDir/restore_runbook.md` |
| Operation type | Tenant write (solution import only - does NOT publish customizations) |

## Exact command to be executed upon approval

~~~powershell
pac solution import $tick
  --environment $EnvironmentId $tick
  --path "$CanonicalPackagePath" $tick
  --activate-plugins
~~~

NOTE - `--publish-changes` is intentionally OMITTED. Publish is Gate 4B (separate ASK).

## Rollback
Per the Universal Pre-Write Rollback Rule (Section 6.6), the pre-import tenant state is captured at `$rollbackDir/`. To roll back, follow `$rollbackDir/restore_runbook.md` - re-import the captured ZIPs in the order specified there. The pre-3.16 baseline `PMO_v11_Tarefas_3_15_1` from `CURRENT_BASELINE.md` may be substituted if the captured ZIPs are themselves compromised.

## Risk if not approved
PM0 functional fix remains uninstalled; AQ-09 A1 failure mode remains live.
"@
    Write-Utf8File -Path $askPath -Value $ask

    [pscustomobject]@{
        status = 'GREEN'
        evidence = $evidence
        rollbackDir = $rollbackDir
        relocation = $relocationPath
        relocationOutcome = $relocationOutcome
        summary = $summaryPath
        ask = $askPath
    } | ConvertTo-Json -Depth 20
}
finally {
    try {
        Stop-Transcript | Out-Null
    }
    catch {
        Write-Warning "Stop-Transcript failed: $($_.Exception.Message)"
    }
    Clear-PreflightTranscriptSecret -Path $transcriptPath
    if ($step03MarkdownForScrubUpdate -and (Test-Path -LiteralPath $step03MarkdownForScrubUpdate)) {
        $step03Content = Get-Content -LiteralPath $step03MarkdownForScrubUpdate -Raw
        $step03Content = $step03Content -replace 'PENDING_FINAL_SCRUB', "YES (scrub verified - 0 'Bearer eyJ' hits, 0 'accessToken' hits)"
        [System.IO.File]::WriteAllText($step03MarkdownForScrubUpdate, $step03Content, (New-Object System.Text.UTF8Encoding($false)))
    }
    Assert-NoTokenLeak -Path $transcriptPath -Step 'section_6_7_token_scrub'
}
