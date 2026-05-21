$ErrorActionPreference = 'Stop'
$asIsPath = 'D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\F_topic_yamls\CriarTarefa.yaml'
$fixedPath = 'D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq08_topic_routing_verification_20260520\post_remediation_reverify\fixed_topic_yamls\CriarTarefa.yaml'

$asIs = Get-Content -Path $asIsPath -Encoding UTF8
$fixed = Get-Content -Path $fixedPath -Encoding UTF8

Write-Host "=== Line counts ==="
Write-Host ("AS-IS lines: " + $asIs.Count)
Write-Host ("Fixed lines: " + $fixed.Count)
Write-Host ""

Write-Host "=== Diff (line by line, only differences) ==="
$max = [Math]::Max($asIs.Count, $fixed.Count)
for ($i = 0; $i -lt $max; $i++) {
    $a = if ($i -lt $asIs.Count) { $asIs[$i] } else { '<MISSING>' }
    $f = if ($i -lt $fixed.Count) { $fixed[$i] } else { '<MISSING>' }
    if ($a -ne $f) {
        Write-Host ("Line " + ($i+1) + ":")
        Write-Host ("  AS-IS:  |" + $a + "|")
        Write-Host ("  FIXED:  |" + $f + "|")
    }
}

Write-Host ""
Write-Host "=== File encoding/BOM check ==="
$asIsBytes = [System.IO.File]::ReadAllBytes($asIsPath)
$fixedBytes = [System.IO.File]::ReadAllBytes($fixedPath)
$asIsHasBOM = $asIsBytes.Length -ge 3 -and $asIsBytes[0] -eq 0xEF -and $asIsBytes[1] -eq 0xBB -and $asIsBytes[2] -eq 0xBF
$fixedHasBOM = $fixedBytes.Length -ge 3 -and $fixedBytes[0] -eq 0xEF -and $fixedBytes[1] -eq 0xBB -and $fixedBytes[2] -eq 0xBF
Write-Host ("AS-IS BOM: " + $asIsHasBOM + " | first 4 bytes: " + ($asIsBytes[0..3] | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')
Write-Host ("FIXED BOM: " + $fixedHasBOM + " | first 4 bytes: " + ($fixedBytes[0..3] | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')

Write-Host ""
Write-Host "=== Line ending check (first 200 bytes) ==="
$asIsContent = [System.Text.Encoding]::UTF8.GetString($asIsBytes[0..[Math]::Min(199, $asIsBytes.Length-1)])
$fixedContent = [System.Text.Encoding]::UTF8.GetString($fixedBytes[0..[Math]::Min(199, $fixedBytes.Length-1)])
$asIsCRLF = ($asIsContent -split "`r`n").Count - 1
$asIsLF = ($asIsContent -replace "`r`n", "" -split "`n").Count - 1
$fixedCRLF = ($fixedContent -split "`r`n").Count - 1
$fixedLF = ($fixedContent -replace "`r`n", "" -split "`n").Count - 1
Write-Host ("AS-IS:  CRLF=" + $asIsCRLF + " LF-only=" + $asIsLF)
Write-Host ("FIXED:  CRLF=" + $fixedCRLF + " LF-only=" + $fixedLF)
