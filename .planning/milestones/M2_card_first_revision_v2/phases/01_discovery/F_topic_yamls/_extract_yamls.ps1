$ErrorActionPreference = 'Stop'

$src = 'D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\A_dataverse_inventory\topic_inventory.json'
$outDir = 'D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\F_topic_yamls'

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

$topics = Get-Content $src -Raw -Encoding UTF8 | ConvertFrom-Json

$results = @()

foreach ($t in $topics) {
    $name = $t.name
    $data = $t.data
    if ([string]::IsNullOrEmpty($data)) {
        Write-Host ("SKIP {0}: empty data" -f $name)
        continue
    }
    $outFile = Join-Path $outDir ($name + '.yaml')
    # Write with UTF8 no BOM, preserve exact bytes; YAML uses \n typically
    [System.IO.File]::WriteAllText($outFile, $data, (New-Object System.Text.UTF8Encoding($false)))
    $bytes = (Get-Item $outFile).Length
    $lines = ($data -split "`n").Count
    $results += [PSCustomObject]@{
        name = $name
        kind = $t.kind
        modifiedon = $t.modifiedon
        yaml_size_bytes_in_inventory = $t.yaml_size_bytes
        bytes_on_disk = $bytes
        line_count = $lines
        out_path = $outFile
    }
    Write-Host ("WROTE {0} ({1} bytes, {2} lines, kind={3})" -f $name, $bytes, $lines, $t.kind)
}

$results | ConvertTo-Json -Depth 4 | Out-File -FilePath (Join-Path $outDir '_extraction_summary.json') -Encoding UTF8
Write-Host '---'
Write-Host ('Total YAMLs written: ' + $results.Count)
