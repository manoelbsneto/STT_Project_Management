[CmdletBinding()]
param(
    [string]$SolutionZip = "Solution\PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip",
    [string]$RawFetchPath = ".planning\comms\independent_review_3_15_1_20260521\pre_publish_live_baseline\workflows\pac_fetch_workflow_clientdata_live.txt",
    [string]$OutputDir = ".planning\comms\independent_review_3_15_1_20260521\pre_publish_live_baseline\workflows"
)

$ErrorActionPreference = "Stop"

function Get-BalancedJsonAt {
    param(
        [string]$Text,
        [int]$StartIndex
    )

    $depth = 0
    $inString = $false
    $escaped = $false

    for ($i = $StartIndex; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        if ($inString) {
            if ($escaped) {
                $escaped = $false
                continue
            }
            if ($ch -eq "\") {
                $escaped = $true
                continue
            }
            if ($ch -eq '"') {
                $inString = $false
                continue
            }
            continue
        }

        if ($ch -eq '"') {
            $inString = $true
            continue
        }
        if ($ch -eq "{") {
            $depth++
            continue
        }
        if ($ch -eq "}") {
            $depth--
            if ($depth -eq 0) {
                return $Text.Substring($StartIndex, $i - $StartIndex + 1)
            }
        }
    }

    throw "Could not find balanced JSON object from offset $StartIndex."
}

function Get-Type29WorkflowIds {
    param([string]$ZipPath)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $resolvedZip = (Resolve-Path -LiteralPath $ZipPath).Path
    $zip = [System.IO.Compression.ZipFile]::OpenRead($resolvedZip)
    try {
        $entry = $zip.Entries | Where-Object { $_.FullName -eq "solution.xml" }
        if (-not $entry) {
            throw "solution.xml not found in $resolvedZip."
        }

        $reader = [System.IO.StreamReader]::new($entry.Open())
        try {
            [xml]$solutionXml = $reader.ReadToEnd()
        }
        finally {
            $reader.Dispose()
        }
    }
    finally {
        $zip.Dispose()
    }

    @($solutionXml.SelectNodes('//RootComponent[@type="29"]') | ForEach-Object {
        $_.id.Trim("{}").ToLowerInvariant()
    })
}

function Get-WorkflowRow {
    param(
        [string]$FetchText,
        [string]$WorkflowId
    )

    $idIndex = $FetchText.IndexOf($WorkflowId, [System.StringComparison]::OrdinalIgnoreCase)
    if ($idIndex -lt 0) {
        throw "Workflow ID not found in PAC fetch output: $WorkflowId"
    }

    $jsonIndex = $FetchText.IndexOf('{"properties":', $idIndex, [System.StringComparison]::Ordinal)
    if ($jsonIndex -lt 0) {
        throw "workflow.clientdata JSON not found after workflow ID: $WorkflowId"
    }

    $nameSegment = $FetchText.Substring($idIndex + $WorkflowId.Length, $jsonIndex - $idIndex - $WorkflowId.Length).Trim()
    $nameMatch = [regex]::Match($nameSegment, '^(?<name>.+?)\s*$')
    if (-not $nameMatch.Success) {
        throw "Workflow name not found before clientdata for ID: $WorkflowId"
    }

    [ordered]@{
        workflowId = $WorkflowId
        workflowName = $nameMatch.Groups["name"].Value.Trim()
        clientdata = Get-BalancedJsonAt -Text $FetchText -StartIndex $jsonIndex
    }
}

function Get-WorkflowFileName {
    param([string]$WorkflowName)

    $fileName = $WorkflowName
    foreach ($invalidChar in [System.IO.Path]::GetInvalidFileNameChars()) {
        $fileName = $fileName.Replace([string]$invalidChar, "_")
    }

    "$fileName.clientdata.live.json"
}

$resolvedOutputDir = (Resolve-Path -LiteralPath $OutputDir).Path
$fetchText = Get-Content -LiteralPath $RawFetchPath -Raw
$workflowIds = @(Get-Type29WorkflowIds -ZipPath $SolutionZip)
if ($workflowIds.Count -ne 12) {
    throw "Expected 12 Type 29 workflows from hotfix manifest, found $($workflowIds.Count)."
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$rows = foreach ($workflowId in $workflowIds) {
    $row = Get-WorkflowRow -FetchText $fetchText -WorkflowId $workflowId
    $fileName = Get-WorkflowFileName -WorkflowName $row.workflowName
    $filePath = Join-Path $resolvedOutputDir $fileName
    [System.IO.File]::WriteAllText($filePath, $row.clientdata, $utf8NoBom)
    $hash = (Get-FileHash -LiteralPath $filePath -Algorithm SHA256).Hash

    [ordered]@{
        workflowName = $row.workflowName
        workflowId = $row.workflowId
        clientdataFile = $fileName
        sha256 = $hash
        byteLength = ([System.IO.FileInfo]$filePath).Length
    }
}

$manifest = [ordered]@{
    generatedAtUtc = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
    solutionZip = (Resolve-Path -LiteralPath $SolutionZip).Path
    rawFetchPath = (Resolve-Path -LiteralPath $RawFetchPath).Path
    workflowCount = @($rows).Count
    workflows = @($rows | Sort-Object workflowName)
}

$manifestPath = Join-Path $resolvedOutputDir "workflow_clientdata_live_manifest.json"
$manifestJson = $manifest | ConvertTo-Json -Depth 8
[System.IO.File]::WriteAllText($manifestPath, $manifestJson + [Environment]::NewLine, $utf8NoBom)
$manifest
