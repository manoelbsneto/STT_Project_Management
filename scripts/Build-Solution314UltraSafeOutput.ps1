[CmdletBinding()]
param(
    [string]$SourceUnpacked = ".planning/comms/solution_3_13_contentfilter_deterministic_output_20260514/unpacked",
    [string]$WorkingDir = ".planning/comms/solution_3_14_ultra_safe_output_20260514/unpacked",
    [string]$OutputZip = "Solution/PMO_v11_Tarefas_3_14_ULTRA_SAFE_OUTPUT_FIX.zip",
    [string]$PackageVersion = "3.14"
)

$ErrorActionPreference = "Stop"

function Write-TextFile {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if ($dir) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText((Resolve-Path -LiteralPath (Split-Path -Parent $Path)).Path + [System.IO.Path]::DirectorySeparatorChar + (Split-Path -Leaf $Path), $Content, $encoding)
}

function New-DataverseSolutionZip {
    param([string]$SourceDir, [string]$DestinationPath)

    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $resolvedSource = (Resolve-Path -LiteralPath $SourceDir).Path
    $sourcePrefix = $resolvedSource.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    if (Test-Path -LiteralPath $DestinationPath) {
        Remove-Item -LiteralPath $DestinationPath -Force
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $DestinationPath) | Out-Null

    $zip = [System.IO.Compression.ZipFile]::Open($DestinationPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        Get-ChildItem -LiteralPath $resolvedSource -Recurse -File |
            Sort-Object FullName |
            ForEach-Object {
                $relative = $_.FullName.Substring($sourcePrefix.Length)
                $entryName = $relative -replace '\\', '/'
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $zip,
                    $_.FullName,
                    $entryName,
                    [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
            }
    }
    finally {
        $zip.Dispose()
    }
}

$repoRoot = (Resolve-Path ".").Path
$resolvedSource = (Resolve-Path -LiteralPath $SourceUnpacked).Path
$workingFullPath = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $WorkingDir))
if (-not $workingFullPath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to write working directory outside repo: $workingFullPath"
}

if (Test-Path -LiteralPath $workingFullPath) {
    Remove-Item -LiteralPath $workingFullPath -Recurse -Force
}
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $workingFullPath) | Out-Null
Copy-Item -LiteralPath $resolvedSource -Destination $workingFullPath -Recurse

$solutionXmlPath = Join-Path $workingFullPath "solution.xml"
$solutionXml = Get-Content -LiteralPath $solutionXmlPath -Raw
$solutionXml = $solutionXml -replace "<Version>[0-9]+\.[0-9]+</Version>", "<Version>$PackageVersion</Version>"
Write-TextFile -Path $solutionXmlPath -Content $solutionXml

$listarPath = Get-ChildItem -LiteralPath (Join-Path $workingFullPath "Workflows") -Filter "PMO_PA_ListarTarefas*.json" |
    Select-Object -First 1 -ExpandProperty FullName
if (-not $listarPath) {
    throw "PMO_PA_ListarTarefas workflow not found."
}
$listar = Get-Content -LiteralPath $listarPath -Raw | ConvertFrom-Json
$listarBranch = $listar.properties.definition.actions.Condition_Projeto_Encontrado.actions.Check_Tarefas_Exist.else.actions
$listarBranch.Select_Tarefas.inputs.select = "@string(item()?['ID'])"
$listarBranch.Compose_Lista.inputs = "@concat('Projeto ', body('Get_Projeto')?['value']?[0]?['ProjectID'], '. Total ', string(outputs('Count_Total')), '. Concluidas ', string(outputs('Count_Concluidas')), '. IDs ', join(body('Select_Tarefas'), ', '), '.')"
$listar.properties.definition.actions.Condition_Projeto_Encontrado.actions.Check_Tarefas_Exist.actions.Respond_Empty.inputs.body.result = "@{concat('Projeto ', body('Get_Projeto')?['value']?[0]?['ProjectID'], '. Total 0. IDs nenhum.')}"
$listar.properties.definition.actions.Condition_Projeto_Encontrado.else.actions.Response_Project_Not_Found.inputs.body.result = "Projeto nao encontrado. Codigo PROJECT_NOT_FOUND."
Write-TextFile -Path $listarPath -Content ($listar | ConvertTo-Json -Depth 100)

$atualizarPath = Get-ChildItem -LiteralPath (Join-Path $workingFullPath "Workflows") -Filter "PMO_PA_AtualizarTarefa*.json" |
    Select-Object -First 1 -ExpandProperty FullName
if (-not $atualizarPath) {
    throw "PMO_PA_AtualizarTarefa workflow not found."
}
$atualizar = Get-Content -LiteralPath $atualizarPath -Raw | ConvertFrom-Json
$atualizar.properties.definition.actions.Respond_Success.inputs.body.result = "Tarefa atualizada com sucesso. Dados gravados no SharePoint. Use listar tarefas para conferir os IDs ativos."
$atualizar.properties.definition.actions.Condition_Projeto_Encontrado.else.actions.Response_Project_Not_Found.inputs.body.result = "Tarefa atualizada. Projeto vinculado nao encontrado para recalculo."
Write-TextFile -Path $atualizarPath -Content ($atualizar | ConvertTo-Json -Depth 100)

$atualizarTopicPath = Join-Path $workingFullPath "botcomponents/pmo_AssistentePMO_V2.topic.AtualizarTarefa/data"
$atualizarTopic = Get-Content -LiteralPath $atualizarTopicPath -Raw
$atualizarTopic = $atualizarTopic -replace 'activity: "\{Topic\.message\}"', 'activity: Tarefa atualizada com sucesso. Dados gravados no SharePoint. Use listar tarefas para conferir os IDs ativos.'
Write-TextFile -Path $atualizarTopicPath -Content $atualizarTopic

New-DataverseSolutionZip -SourceDir $workingFullPath -DestinationPath $OutputZip
Get-FileHash -Algorithm SHA256 -LiteralPath $OutputZip
