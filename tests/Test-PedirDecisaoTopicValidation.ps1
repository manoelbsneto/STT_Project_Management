[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_pedirdecisao_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)
    $topicPath = Get-ChildItem -LiteralPath (Join-Path $tempRoot "botcomponents") -Recurse -File |
        Where-Object { $_.FullName -match "topic\.PedirDecisao[\\/]+data$" } |
        Select-Object -First 1 -ExpandProperty FullName

    $text = if ($topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }
    $validationIndex = if ($text) { $text.IndexOf("validate_approver_upn", [StringComparison]::Ordinal) } else { -1 }
    $flowIndex = if ($text) { $text.IndexOf("InvokeFlowAction", [StringComparison]::Ordinal) } else { -1 }

    Add-Check "PedirDecisao topic exists" (-not [string]::IsNullOrWhiteSpace($topicPath)) "Expected botcomponents/*topic.PedirDecisao/data."
    Add-Check "Validates approver UPN" (($text -match "validate_approver_upn") -and ($text -match "IsMatch\(Trim\(Topic\.Aprovador\)") -and ($text -match "\[A-Za-z0-9\._%\+\\-\]\+@") -and ($text -match "\[A-Za-z0-9\.\\-\]\+")) "Topic must validate approver before calling Power Automate."
    Add-Check "UPN regex escapes literal hyphen for Copilot Power Fx" (($text -notmatch "\[A-Za-z0-9\._%\+-\]") -and ($text -notmatch "\[A-Za-z0-9\.-\]")) "Copilot Studio rejects unescaped literal hyphen inside regex character classes."
    Add-Check "Validation happens before flow invoke" (($validationIndex -ge 0) -and ($flowIndex -gt $validationIndex)) "Invalid UPN must be blocked before InvokeFlowAction."
    Add-Check "Invalid UPN returns user-facing message" ($text -match "UPN do aprovador invalido") "Runtime should not show FlowActionInternalServerError for malformed approver input."
    Add-Check "Invalid UPN ends dialog" (($text -match "end_invalid_approver") -and ($text -match "clearTopicQueue:\s*true")) "Invalid input should stop the write path."
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
    throw "PedirDecisao topic validation test failed: $($failed.name -join '; ')"
}
