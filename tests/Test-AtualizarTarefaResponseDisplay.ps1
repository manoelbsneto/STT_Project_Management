[CmdletBinding(DefaultParameterSetName = "Package")]
param(
    [Parameter(ParameterSetName = "Package")]
    [string]$PackagePath = ".\Solution\PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip",

    [Parameter(ParameterSetName = "Source")]
    [string]$SourceRoot
)

$ErrorActionPreference = "Stop"
$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Evidence
    )

    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

function Resolve-SolutionRoot {
    if ($PSCmdlet.ParameterSetName -eq "Source") {
        $resolved = (Resolve-Path -LiteralPath $SourceRoot).Path
        if (-not (Test-Path -LiteralPath (Join-Path $resolved "botcomponents"))) {
            throw "SourceRoot must contain botcomponents: $resolved"
        }
        return [ordered]@{
            Root = $resolved
            Temp = $null
            Input = $resolved
        }
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $resolvedPackage = (Resolve-Path -LiteralPath $PackagePath).Path
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_at_display_" + [guid]::NewGuid().ToString("N"))
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackage, $tempRoot)
    return [ordered]@{
        Root = $tempRoot
        Temp = $tempRoot
        Input = $resolvedPackage
    }
}

$solution = Resolve-SolutionRoot

try {
    $topicPath = Join-Path $solution.Root "botcomponents\pmo_AssistentePMO_V2.topic.AtualizarTarefa\data"
    Add-Check "AtualizarTarefa topic exists" (Test-Path -LiteralPath $topicPath) $topicPath

    $topicText = if (Test-Path -LiteralPath $topicPath) { Get-Content -LiteralPath $topicPath -Raw } else { "" }
    $finalBlock = if ($topicText -match "(?s)- kind:\s*SendActivity\s*\r?\n\s*id:\s*atualizar_done.*?(?=\r?\n\s*elseActions:|\r?\n\s*- kind:\s*EndDialog|\z)") {
        $matches[0]
    }
    elseif ($topicText -match "(?s)id:\s*atualizar_done.*?(?=\r?\n\s*elseActions:|\z)") {
        $matches[0]
    }
    else {
        ""
    }

    $accentedNao = "n$([char]0x00E3)o"
    $fields = @(
        @{ Label = "Responsavel"; Variable = "Topic.Responsavel" },
        @{ Label = "Prazo"; Variable = "Topic.DataFim" },
        @{ Label = "Prioridade"; Variable = "Topic.Prioridade" },
        @{ Label = "Horas realizadas"; Variable = "Topic.HorasRealizadas" }
    )

    Add-Check "Final response activity found" ($finalBlock -match "id:\s*atualizar_done") $finalBlock
    Add-Check "Final response is field-level display, not static-only" (
        ($finalBlock -match "Responsavel:") -and
        ($finalBlock -match "Prazo:") -and
        ($finalBlock -match "Prioridade:") -and
        ($finalBlock -match "Horas realizadas:")
    ) $finalBlock

    foreach ($field in $fields) {
        $label = [regex]::Escape($field.Label)
        $variable = [regex]::Escape($field.Variable)
        Add-Check "$($field.Label) does not echo raw variable directly" (
            $finalBlock -notmatch "$label\s*:\s*\{$variable\}"
        ) $finalBlock
    }

    Add-Check "Display uses mantido placeholder" ($finalBlock -match "\(mantido\)") $finalBlock
    Add-Check "Display uses Power Fx If expression" ($finalBlock -match "\{\s*If\s*\(") $finalBlock
    Add-Check "Display checks blank values" ($finalBlock -match "IsBlank\s*\(") $finalBlock
    Add-Check "Display normalizes lower/trim text" (($finalBlock -match "Lower\s*\(") -and ($finalBlock -match "Trim\s*\(")) $finalBlock
    Add-Check "Display recognizes ascii skip tokens" (
        ($finalBlock -match '"n"') -and
        ($finalBlock -match '"no"') -and
        ($finalBlock -match '"nao"')
    ) $finalBlock
    Add-Check "Display recognizes accented nao skip token" ($finalBlock.Contains($accentedNao)) $finalBlock

    $failed = @($checks | Where-Object { -not $_.passed })
    $result = [ordered]@{
        input = $solution.Input
        topicPath = $topicPath
        passed = ($failed.Count -eq 0)
        failedCheckCount = $failed.Count
        checks = $checks
    }

    $result | ConvertTo-Json -Depth 8

    if ($failed.Count -gt 0) {
        throw "AtualizarTarefa response display regression failed: $($failed.name -join '; ')"
    }
}
finally {
    if ($solution.Temp -and (Test-Path -LiteralPath $solution.Temp)) {
        $resolvedTemp = (Resolve-Path -LiteralPath $solution.Temp).Path
        $resolvedBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
        if ($resolvedTemp.StartsWith($resolvedBase, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTemp -Recurse -Force
        }
    }
}
