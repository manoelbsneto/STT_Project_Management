[CmdletBinding()]
param(
    [string]$EnvironmentId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$NameFilter = "pmo_AssistentePMO",
    [string]$EvidenceDir = ".planning\comms",
    [int]$TimeoutSeconds = 120,
    [switch]$SkipPacExecution
)

$ErrorActionPreference = "Stop"

function New-EvidenceFileName {
    param(
        [string]$Prefix,
        [string]$Extension
    )

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Join-Path $EvidenceDir "$Prefix`_$stamp.$Extension"
}

function Invoke-ProcessWithTimeout {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string[]]$ArgumentList,

        [Parameter(Mandatory)]
        [string]$StdOutPath,

        [Parameter(Mandatory)]
        [string]$StdErrPath,

        [int]$TimeoutSeconds = 120
    )

    $process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait:$false -RedirectStandardOutput $StdOutPath -RedirectStandardError $StdErrPath
    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        try {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
        catch {
        }
        throw "Command timed out after $TimeoutSeconds seconds: $FilePath $($ArgumentList -join ' ')"
    }

    $process.ExitCode
}

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

$fetchPath = New-EvidenceFileName -Prefix "ghost_botcomponents_fetchxml" -Extension "xml"
$stdoutPath = New-EvidenceFileName -Prefix "ghost_botcomponents_stdout" -Extension "txt"
$stderrPath = New-EvidenceFileName -Prefix "ghost_botcomponents_stderr" -Extension "txt"
$reportPath = New-EvidenceFileName -Prefix "ghost_botcomponents_report" -Extension "md"

$escapedFilter = [System.Security.SecurityElement]::Escape($NameFilter)
$fetchXml = @"
<fetch version="1.0" output-format="xml-platform" mapping="logical" distinct="false">
  <entity name="botcomponent">
    <attribute name="botcomponentid" />
    <attribute name="name" />
    <attribute name="schemaname" />
    <attribute name="componenttype" />
    <attribute name="statecode" />
    <attribute name="statuscode" />
    <attribute name="modifiedon" />
    <filter type="or">
      <condition attribute="name" operator="like" value="%$escapedFilter%" />
      <condition attribute="schemaname" operator="like" value="%$escapedFilter%" />
    </filter>
    <order attribute="modifiedon" descending="true" />
  </entity>
</fetch>
"@

Set-Content -LiteralPath $fetchPath -Value $fetchXml -Encoding UTF8

$pacCommand = Get-Command pac -ErrorAction SilentlyContinue
$status = "NotRun"
$exitCode = $null
$errorText = $null

if ($SkipPacExecution) {
    $status = "Skipped"
    Set-Content -LiteralPath $stdoutPath -Value "PAC execution skipped by -SkipPacExecution." -Encoding UTF8
    Set-Content -LiteralPath $stderrPath -Value "" -Encoding UTF8
}
elseif (-not $pacCommand) {
    $status = "PacMissing"
    Set-Content -LiteralPath $stdoutPath -Value "" -Encoding UTF8
    Set-Content -LiteralPath $stderrPath -Value "pac CLI was not found in PATH." -Encoding UTF8
}
else {
    $arguments = @(
        "org",
        "fetch",
        "--environment",
        $EnvironmentId,
        "--xmlFile",
        $fetchPath
    )

    try {
        $exitCode = Invoke-ProcessWithTimeout -FilePath $pacCommand.Source -ArgumentList $arguments -StdOutPath $stdoutPath -StdErrPath $stderrPath -TimeoutSeconds $TimeoutSeconds
        $status = if ($exitCode -eq 0) { "Completed" } else { "Failed" }
    }
    catch {
        $status = "TimedOutOrFailed"
        $errorText = $_.Exception.Message
        if (-not (Test-Path -LiteralPath $stderrPath)) {
            Set-Content -LiteralPath $stderrPath -Value $errorText -Encoding UTF8
        }
        else {
            Add-Content -LiteralPath $stderrPath -Value $errorText -Encoding UTF8
        }
    }
}

$report = @"
# Ghost Bot Component Discovery

Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Environment: $EnvironmentId
Name filter: $NameFilter
Status: $status
Exit code: $exitCode

## Files

| Artifact | Path |
|---|---|
| FetchXML | `$fetchPath` |
| Stdout | `$stdoutPath` |
| Stderr | `$stderrPath` |

## Safety

This script is read-only. It only creates FetchXML, executes a Dataverse fetch when `pac` is available, and writes evidence files.
It does not delete, deactivate, update, or publish any Dataverse component.

## Human/Admin Gate

Any deletion of orphaned `botcomponent` rows requires explicit Human/Admin approval after reviewing the stdout evidence.
"@

if ($errorText) {
    $report += "`n## Error`n`n"
    $report += "``````text`n"
    $report += $errorText
    $report += "`n```````n"
}

Set-Content -LiteralPath $reportPath -Value $report -Encoding UTF8

[ordered]@{
    environmentId = $EnvironmentId
    nameFilter = $NameFilter
    status = $status
    exitCode = $exitCode
    fetchXml = (Resolve-Path -LiteralPath $fetchPath).Path
    stdout = (Resolve-Path -LiteralPath $stdoutPath).Path
    stderr = (Resolve-Path -LiteralPath $stderrPath).Path
    report = (Resolve-Path -LiteralPath $reportPath).Path
} | ConvertTo-Json -Depth 5

if ($status -in @("Failed", "TimedOutOrFailed")) {
    exit 2
}
