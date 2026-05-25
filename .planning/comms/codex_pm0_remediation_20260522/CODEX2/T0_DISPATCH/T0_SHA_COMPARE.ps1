[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Fa-f0-9]{64}$')]
    [string]$ExpectedSha256,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$SolutionName,

    [string]$EnvironmentId = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",

    [string]$OutputDirectory
)

$ErrorActionPreference = "Stop"

$PinnedPacExe = "C:\Users\dataops-lab\AppData\Local\Microsoft\PowerAppsCli\Microsoft.PowerApps.CLI.2.6.4\tools\pac.exe"
$PacCommand = (Get-Command pac -ErrorAction SilentlyContinue | Select-Object -First 1).Source
if ([string]::IsNullOrWhiteSpace($PacCommand) -and (Test-Path -LiteralPath $PinnedPacExe)) {
    $PacCommand = $PinnedPacExe
}
if ([string]::IsNullOrWhiteSpace($PacCommand)) {
    throw "PAC CLI not found on PATH and pinned PAC executable missing: $PinnedPacExe"
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $PSScriptRoot "post_import_sha_compare"
}

function Convert-ToSafeFileName {
    param([Parameter(Mandatory)][string]$Value)
    return ($Value -replace '[^A-Za-z0-9_.-]', '_')
}

function Write-CompareResult {
    param(
        [Parameter(Mandatory)][hashtable]$Result,
        [Parameter(Mandatory)][string]$Path
    )

    $Result | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $Path -Encoding UTF8
}

$timestampUtc = [DateTimeOffset]::UtcNow.ToString("yyyyMMdd_HHmmss")
$safeSolutionName = Convert-ToSafeFileName -Value $SolutionName
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$exportZipPath = Join-Path $OutputDirectory "$($safeSolutionName)_post_import_export_$timestampUtc.zip"
$jsonResultPath = Join-Path $OutputDirectory "$($safeSolutionName)_sha_compare_result_$timestampUtc.json"
$stdoutPath = Join-Path $OutputDirectory "$($safeSolutionName)_pac_solution_export_$timestampUtc.stdout.txt"
$stderrPath = Join-Path $OutputDirectory "$($safeSolutionName)_pac_solution_export_$timestampUtc.stderr.txt"

$normalizedExpected = $ExpectedSha256.ToUpperInvariant()
$pacArgs = @(
    "solution", "export",
    "--environment", $EnvironmentId,
    "--name", $SolutionName,
    "--path", $exportZipPath,
    "--overwrite"
)

$commandLine = $PacCommand + " " + (($pacArgs | ForEach-Object {
    if ($_ -match '\s') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ }
}) -join " ")

Write-Host "Post-import SHA compare" -ForegroundColor Cyan
Write-Host "Environment : $EnvironmentId"
Write-Host "Solution    : $SolutionName"
Write-Host "Export path : $exportZipPath"
Write-Host "Command     : $commandLine"
Write-Host ""

$pacExitCode = $null
try {
    & $PacCommand @pacArgs > $stdoutPath 2> $stderrPath
    $pacExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
}
catch {
    $pacExitCode = -1
    $_ | Out-String | Set-Content -LiteralPath $stderrPath -Encoding UTF8
}

$exportExists = Test-Path -LiteralPath $exportZipPath -PathType Leaf
if ($pacExitCode -ne 0 -or -not $exportExists) {
    $result = [ordered]@{
        status = "FAIL_EXPORT"
        generatedUtc = [DateTimeOffset]::UtcNow.ToString("o")
        environmentId = $EnvironmentId
        solutionName = $SolutionName
        expectedSha256 = $normalizedExpected
        actualSha256 = $null
        match = $false
        pacExitCode = $pacExitCode
        exportedZipPath = $exportZipPath
        exportedZipExists = $exportExists
        commandLine = $commandLine
        stdoutPath = $stdoutPath
        stderrPath = $stderrPath
        jsonResultPath = $jsonResultPath
    }

    Write-CompareResult -Result $result -Path $jsonResultPath

    Write-Host "Result      : FAIL_EXPORT" -ForegroundColor Red
    Write-Host "Expected    : $normalizedExpected"
    Write-Host "Exported    : <not computed>"
    Write-Host "PAC exit    : $pacExitCode"
    Write-Host "JSON result : $jsonResultPath"
    Write-Host "Stdout      : $stdoutPath"
    Write-Host "Stderr      : $stderrPath"
    exit 2
}

$actualSha256 = (Get-FileHash -LiteralPath $exportZipPath -Algorithm SHA256).Hash.ToUpperInvariant()
$isMatch = [string]::Equals($normalizedExpected, $actualSha256, [System.StringComparison]::OrdinalIgnoreCase)
$status = if ($isMatch) { "PASS" } else { "FAIL" }

$result = [ordered]@{
    status = $status
    generatedUtc = [DateTimeOffset]::UtcNow.ToString("o")
    environmentId = $EnvironmentId
    solutionName = $SolutionName
    expectedSha256 = $normalizedExpected
    actualSha256 = $actualSha256
    match = $isMatch
    pacExitCode = $pacExitCode
    exportedZipPath = $exportZipPath
    exportedZipExists = $true
    commandLine = $commandLine
    stdoutPath = $stdoutPath
    stderrPath = $stderrPath
    jsonResultPath = $jsonResultPath
}

Write-CompareResult -Result $result -Path $jsonResultPath

$color = if ($isMatch) { "Green" } else { "Red" }
Write-Host "Result      : $status" -ForegroundColor $color
Write-Host "Expected    : $normalizedExpected"
Write-Host "Exported    : $actualSha256"
Write-Host "PAC exit    : $pacExitCode"
Write-Host "Exported ZIP: $exportZipPath"
Write-Host "JSON result : $jsonResultPath"
Write-Host "Stdout      : $stdoutPath"
Write-Host "Stderr      : $stderrPath"

if ($isMatch) {
    exit 0
}

exit 1
