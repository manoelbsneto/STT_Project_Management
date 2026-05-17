[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_powerfx_regex_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

function Get-UnsafeHyphenClasses {
    param([string]$Text)

    $unsafe = [System.Collections.Generic.List[string]]::new()
    foreach ($classMatch in [regex]::Matches($Text, "\[[^\]\r\n]+\]")) {
        $class = $classMatch.Value
        $inner = $class.Substring(1, $class.Length - 2)

        for ($i = 0; $i -lt $inner.Length; $i++) {
            if ($inner[$i] -ne '-') {
                continue
            }

            $previous = if ($i -gt 0) { $inner[$i - 1] } else { [char]0 }
            $next = if ($i -lt ($inner.Length - 1)) { $inner[$i + 1] } else { [char]0 }
            $escaped = ($i -gt 0 -and $inner[$i - 1] -eq '\')
            $range = ([char]::IsLetterOrDigit($previous) -and [char]::IsLetterOrDigit($next))

            if (-not $escaped -and -not $range) {
                $unsafe.Add($class) | Out-Null
                break
            }
        }
    }

    return @($unsafe)
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)

    $botFiles = @(Get-ChildItem -LiteralPath (Join-Path $tempRoot "botcomponents") -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -eq "data" })

    $findings = New-Object System.Collections.Generic.List[object]
    foreach ($file in $botFiles) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        if ($text -notmatch "\b(?:IsMatch|Match)\(") {
            continue
        }

        $unsafeClasses = Get-UnsafeHyphenClasses -Text $text
        if ($unsafeClasses.Count -gt 0) {
            $relative = $file.FullName.Substring($tempRoot.Length + 1)
            $findings.Add([ordered]@{
                path = $relative
                unsafeClasses = $unsafeClasses
            }) | Out-Null
        }
    }

    Add-Check "All Power Fx regex literal hyphens are escaped" ($findings.Count -eq 0) (($findings | ConvertTo-Json -Depth 6 -Compress))
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = (Resolve-Path -LiteralPath $tempRoot).Path
        $resolvedBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
        if ($resolvedTemp.StartsWith($resolvedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
        }
    }
}

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    packagePath = $resolvedPackagePath
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10
if ($failed.Count -gt 0) {
    throw "Copilot Power Fx regex safety test failed: $($failed.name -join '; ')"
}
