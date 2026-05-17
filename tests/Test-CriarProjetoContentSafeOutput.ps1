[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_criarprojeto_output_safe_" + [guid]::NewGuid().ToString("N"))
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)
    $topicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.CriarProjeto\data"
    Add-Check "CriarProjeto topic exists" (Test-Path -LiteralPath $topicPath) "Expected pmo_AssistentePMO_V2.topic.CriarProjeto/data."

    $topicText = if (Test-Path -LiteralPath $topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }

    Add-Check "CriarProjeto does not echo raw action output" ($topicText -notmatch 'activity:\s*"\{Topic\.Result\}"') "Raw Topic.Result echo triggered Responsible AI filtering in runtime."
    Add-Check "CriarProjeto maps action output through ConditionGroup" (($topicText -match 'id:\s*send_safe_result') -and ($topicText -match 'kind:\s*ConditionGroup')) "Known flow results must be mapped to controlled bot text."
    Add-Check "Success message is static" (($topicText -match 'condition:\s*=Topic\.Result = "Projeto criado com sucesso!"') -and ($topicText -match 'activity:\s*Projeto criado com sucesso\.')) "Success response must not include raw action payload."
    Add-Check "Duplicate message is static" (($topicText -match 'result_duplicate') -and ($topicText -match 'Nenhum item duplicado foi criado\.')) "Duplicate response must remain user-safe and controlled."
    Add-Check "Invalid date message is static" (($topicText -match 'StartsWith\(Topic\.Result, "Prazo invalido\."\)') -and ($topicText -match 'activity:\s*Prazo invalido\. Use dd/MM/aaaa\.')) "Validation response must remain concise and controlled."
    Add-Check "Fallback message is static" (($topicText -match 'id:\s*result_generic') -and ($topicText -match 'activity:\s*Operacao concluida\. Verifique o resultado no SharePoint\.')) "Unexpected action text must not be echoed back to the model."
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
    throw "CriarProjeto content-safe output test failed: $($failed.name -join '; ')"
}
