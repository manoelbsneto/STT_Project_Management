[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PackagePath
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression.FileSystem

$resolvedPackagePath = (Resolve-Path -LiteralPath $PackagePath).Path
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo_zip_p0_contracts_" + [guid]::NewGuid().ToString("N"))

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($resolvedPackagePath, $tempRoot)

    $portfolioPath = Get-ChildItem -LiteralPath (Join-Path $tempRoot "Workflows") -Filter "*ConsultarPortfolio*.json" | Select-Object -First 1 -ExpandProperty FullName
    $listarPath = Get-ChildItem -LiteralPath (Join-Path $tempRoot "Workflows") -Filter "*PM0_PA_Card_ListarTarefas*.json" | Select-Object -First 1 -ExpandProperty FullName
    if (-not $listarPath) {
        $listarPath = Get-ChildItem -LiteralPath (Join-Path $tempRoot "Workflows") -Filter "*ListarTarefas*.json" | Select-Object -First 1 -ExpandProperty FullName
    }
    $portfolioTopicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.ConsultarPortfolio\data"
    $listarTopicPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.topic.ListarTarefas\data"
    $listarActionPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas\data"
    if (-not (Test-Path -LiteralPath $listarActionPath)) {
        $listarActionPath = Join-Path $tempRoot "botcomponents\pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas\data"
    }

    $portfolio = Get-Content -LiteralPath $portfolioPath -Raw
    $listar = Get-Content -LiteralPath $listarPath -Raw
    $portfolioTopic = Get-Content -LiteralPath $portfolioTopicPath -Raw
    $listarTopic = Get-Content -LiteralPath $listarTopicPath -Raw
    $listarAction = Get-Content -LiteralPath $listarActionPath -Raw

    Add-Check "Zip has solution.xml" (Test-Path -LiteralPath (Join-Path $tempRoot "solution.xml")) "Package must be a valid Dataverse solution zip."
    Add-Check "Zip has [Content_Types].xml" (Test-Path -LiteralPath (Join-Path $tempRoot "[Content_Types].xml")) "Required by Dataverse solution package format."
    Add-Check "ConsultarPortfolio returns project names" (($portfolio -match "Select_Projetos_Nomes") -and ($portfolio -match "Compose_Projetos_Nomes") -and ($portfolio -match "NomeProjeto") -and ($portfolio -match "Projetos:")) "P0: listar projetos ativos must return names."
    Add-Check "ConsultarPortfolio topic routes listar projetos ativos" ($portfolioTopic -match "listar projetos ativos") "P0: user phrase must be reachable."
    $isPm0Listar = $listar -match "Get_Project_By_Name"
    Add-Check "ListarTarefas accepts NomeProjeto" ((($listar -match '"NomeProjeto"') -and ($listar -match "Compose_ProjectInput")) -or (($listar -match '"projectId"') -and $isPm0Listar)) "P0: flow trigger must accept a project name or code; PM0 carries it in projectId and resolves it before task lookup."
    $usesCanonicalProjectId = $listar.Contains("body('Get_Projeto')?['value']?[0]?['ProjectID']") -or $listar.Contains("body(\u0027Get_Projeto\u0027)?[\u0027value\u0027]?[0]?[\u0027ProjectID\u0027]") -or $listar.Contains("body('Get_Project_By_Name')?['value']?[0]?['ProjectID']") -or $listar.Contains("body(\u0027Get_Project_By_Name\u0027)?[\u0027value\u0027]?[0]?[\u0027ProjectID\u0027]")
    Add-Check "ListarTarefas resolves project before tasks" (($listar -match '"table":\s*"Projetos"') -and $usesCanonicalProjectId) "P0: resolve NomeProjeto/ProjectID to canonical ProjectID."
    Add-Check "ListarTarefas has not-found guard" ((($listar -match "Condition_Projeto_Encontrado") -and ($listar -match "PROJECT_NOT_FOUND")) -or ($isPm0Listar -and ($listar -match "Projeto nao encontrado"))) "P0: invalid or empty project lookups must not return placeholder success."
    Add-Check "ListarTarefas topic asks name or code" (($listarTopic -match "Topic\.NomeProjeto") -and ($listarTopic -match "nome ou codigo")) "Copilot topic must collect a human-friendly input."
    Add-Check "ListarTarefas topic parses inline project input" (($listarTopic -match "parse_nome_projeto") -and ($listarTopic -match "listar\\s\+tarefas") -and ($listarTopic -match "tarefas\\s\+do\\s\+projeto")) "Copilot topic must handle commands such as listar tarefas PRJ-001 without a second prompt."
    Add-Check "ListarTarefas action binds NomeProjeto" (($listarAction -match "propertyName:\s*NomeProjeto") -or (($listarAction -match "propertyName:\s*projectId") -and ($listarAction -match "Global\.PMO_Listar_NomeProjeto"))) "Action must pass the collected project name/code into the flow."
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
    throw "Solution ZIP P0 contract test failed: $($failed.name -join '; ')"
}
