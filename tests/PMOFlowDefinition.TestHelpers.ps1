function Add-PMOCheck {
    param(
        [System.Collections.Generic.List[object]]$Checks,
        [string]$Name,
        [bool]$Passed,
        [string]$Evidence
    )

    $Checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

function Invoke-PMOFlowBuildOnly {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptPath,

        [Parameter(Mandatory)]
        [string]$Prefix
    )

    $repoRoot = (Resolve-Path ".").Path
    $evidenceDir = ".planning\comms\test_builds"
    $fullEvidenceDir = Join-Path $repoRoot $evidenceDir
    New-Item -ItemType Directory -Force -Path $fullEvidenceDir | Out-Null

    & powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath -BuildOnly -EvidenceDir $evidenceDir | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "BuildOnly failed for $ScriptPath with exit code $LASTEXITCODE."
    }

    $file = Get-ChildItem -LiteralPath $fullEvidenceDir -Filter "$($Prefix)_buildonly_*.json" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $file) {
        throw "BuildOnly evidence not found for prefix $Prefix."
    }

    [ordered]@{
        path = $file.FullName
        text = Get-Content -LiteralPath $file.FullName -Raw
        json = Get-Content -LiteralPath $file.FullName -Raw | ConvertFrom-Json
    }
}

function Complete-PMOChecks {
    param(
        [System.Collections.Generic.List[object]]$Checks,
        [hashtable]$Metadata
    )

    $failed = @($Checks | Where-Object { -not $_.passed })
    $result = [ordered]@{
        passed = ($failed.Count -eq 0)
        failedCheckCount = $failed.Count
        checks = $Checks
    }

    foreach ($key in $Metadata.Keys) {
        $result[$key] = $Metadata[$key]
    }

    $result | ConvertTo-Json -Depth 20

    if ($failed.Count -gt 0) {
        throw "Flow definition test failed: $($failed.name -join '; ')"
    }
}

function Add-PMOCommonFlowChecks {
    param(
        [System.Collections.Generic.List[object]]$Checks,
        [string]$Text,
        [string]$DisplayName
    )

    Add-PMOCheck $Checks "Flow display name is $DisplayName" ($Text -match [regex]::Escape($DisplayName)) "Expected display name in build output."
    Add-PMOCheck $Checks "Flow uses Skills trigger" ($Text -match '"kind"\s*:\s*"Skills"') "All bot flows must use Run a flow from Copilot / Skills trigger."
    Add-PMOCheck $Checks "Flow uses SharePoint Standard connector" ($Text -match "shared_sharepointonline") "Only SharePoint Standard connector expected."
    Add-PMOCheck $Checks "Flow has no padLeft" ($Text -notmatch "padLeft") "padLeft is unsupported in this tenant."
    Add-PMOCheck $Checks "Flow text is ASCII-only" ($Text -notmatch "[^\x00-\x7F]") "Operational flow text must be ASCII-only."
    Add-PMOCheck $Checks "Flow has no mojibake" ($Text -notmatch "$([char]0x00F0)|$([char]0x00C3)|$([char]0x00E2)|$([char]0x00C2)|$([char]0xFFFD)") "No corrupt UTF-8 sequences."
}
