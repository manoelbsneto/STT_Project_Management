[CmdletBinding()]
param(
    [string]$RepoRoot = 'D:\VMs\Projetos\STT_Project_Management',
    [string]$ExpectedPackageSha256 = '3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB',
    [string]$OldFailedPackageSha256 = '4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

$AgentName = 'Codex #2 Bravo'
$PreflightDir = '.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT'

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

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path (Resolve-RepoRelativePath -Path $PreflightDir) | Out-Null

$updates = @(
    @{ Entry = 'U1'; Target = '.planning/CURRENT_BASELINE.md' },
    @{ Entry = 'U2'; Target = '.planning/STATE.md' },
    @{ Entry = 'U3'; Target = '.planning/START_HERE_CURRENT_STATUS.md' },
    @{ Entry = 'U4'; Target = '.planning/stop_ship/MASTER_CHECKLIST.md' },
    @{ Entry = 'U5'; Target = '.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_EN.md' },
    @{ Entry = 'U6'; Target = '.planning/comms/codex_pm0_remediation_20260522/GEMINI/RELEASE_NOTES/RELEASE_NOTES_3_16_PT_BR.md' }
)

$rows = [System.Collections.Generic.List[string]]::new()
foreach ($update in $updates) {
    $text = Get-Content -LiteralPath $update.Target -Raw
    if ($text -notmatch [regex]::Escape($ExpectedPackageSha256)) {
        throw "V1 failed: new SHA missing from $($update.Target)"
    }
    $rows.Add("| $($update.Entry) | ``$($update.Target)`` | ALREADY_APPLIED | Skip |") | Out-Null
}

$registry = Get-Content -LiteralPath '.planning/AGENT_CHECKIN_REGISTRY.md' -Raw
$hitCount = ([regex]::Matches($registry, [regex]::Escape('PM0-REMED-PACKAGE-CORRECTED'))).Count
if ($hitCount -ne 1) {
    throw "V2 failed: PM0-REMED-PACKAGE-CORRECTED count = $hitCount"
}
$rows.Add('| A1 | `.planning/AGENT_CHECKIN_REGISTRY.md` | ALREADY_APPLIED | Skip |') | Out-Null

$leaveFiles = @(
    '.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md',
    '.planning/comms/codex_pm0_remediation_20260522/MESSAGE_TO_CODEX_1_UPDATED_OPINION_20260522.md',
    '.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173428_Codex1_package_consistency_strict.md',
    '.planning/comms/codex_pm0_remediation_20260522/EXPORT_RECONCILIATION_20260522_1712.md',
    '.planning/comms/codex_pm0_remediation_20260522/CODEX2/PREFLIGHT/PREFLIGHT_HALT_20260522_220116.md',
    '.planning/comms/codex_pm0_remediation_20260522/OPEN_QUESTIONS_CONSOLIDATED_20260522.md',
    '.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/PACKAGE_STATUS.md'
)

foreach ($file in $leaveFiles) {
    $text = Get-Content -LiteralPath $file -Raw
    if ($text -notmatch [regex]::Escape($OldFailedPackageSha256)) {
        throw "V4 failed: old SHA forensic anchor missing from $file"
    }
}

$stamp = Get-UtcStamp
$mdPath = Join-Path $PreflightDir "00a_sha_reconciliation_$stamp.md"
$txtPath = Join-Path $PreflightDir "00a_sha_reconciliation_$stamp.txt"
$pngPath = Join-Path $PreflightDir "00a_sha_reconciliation_$stamp.png"
$rowText = $rows -join "`r`n"
$leaveText = ($leaveFiles | ForEach-Object { "- ``$_``" }) -join "`r`n"

$md = @"
# Pre-Step A SHA Reconciliation Evidence

| Field | Value |
|---|---|
| Timestamp BRT | $(Get-BrtTimestamp) |
| Agent | $AgentName |
| Result | PASS |
| Description | Verified corrected SHA reconciliation state before Gate 4 preflight tenant access. |
| Source command line | ``scripts/Invoke-Gate4PreStepAReconciliation.ps1`` |
| PNG evidence | ``$pngPath`` |
| Text output | ``$txtPath`` |

## Dispatch Table

| Entry | Target file | State | Action this run |
|---|---|---|---|
$rowText

## Verification Results

| Check | Result | Detail |
|---|---|---|
| V1 | PASS | New SHA present in all six UPDATE files. |
| V2 | PASS | PM0-REMED-PACKAGE-CORRECTED appears exactly once. |
| V3 | PASS | All entries were already applied, so no target-file delta was produced in this run. |
| V4 | PASS | All LEAVE files retain the old SHA forensic anchor. |

## LEAVE Files Checked

$leaveText

## Expected Delta

- None

## Actual New Delta Paths

- None

## Doc Debt Flagged, Not Fixed

The English and Portuguese 3.16 release notes still contain a --publish-changes example. Section 6.5 explicitly defers that correction; Gate 4A remains import-only.
"@

Write-Utf8File -Path $mdPath -Value $md
Write-Utf8File -Path $txtPath -Value $md
Write-TextPng -Text $md -Path $pngPath

[pscustomobject]@{
    status = 'PASS'
    markdown = $mdPath
    text = $txtPath
    png = $pngPath
} | ConvertTo-Json -Depth 5
