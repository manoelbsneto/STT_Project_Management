$ErrorActionPreference = 'Continue'
$aq07 = 'C:\Users\dataops-lab\Downloads\PMO_AQ07_CopilotBinding_1_0_0_1.zip'
$pmov11 = 'C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_3_16.zip'
$baseDir = 'D:\VMs\Projetos\STT_Project_Management\.planning\comms\codex_pm0_remediation_20260522\OPUS46\T0_DISPATCH'

$aq07Dir = Join-Path $baseDir 'aq07_expanded'
$pmov11Dir = Join-Path $baseDir 'pmov11_expanded'

# Clean and expand
foreach ($d in @($aq07Dir, $pmov11Dir)) {
    if (Test-Path $d) { Remove-Item $d -Recurse -Force }
    New-Item $d -ItemType Directory -Force | Out-Null
}

Expand-Archive -Path $aq07 -DestinationPath $aq07Dir -Force
Expand-Archive -Path $pmov11 -DestinationPath $pmov11Dir -Force

# AQ07
Write-Output "=== AQ07 solution.xml ==="
[xml]$aq07xml = Get-Content (Join-Path $aq07Dir 'solution.xml')
Write-Output "UniqueName: $($aq07xml.ImportExportXml.SolutionManifest.UniqueName)"
Write-Output "Version: $($aq07xml.ImportExportXml.SolutionManifest.Version)"
Write-Output "Managed: $($aq07xml.ImportExportXml.SolutionManifest.Managed)"
Write-Output "--- RootComponents ---"
$aq07xml.ImportExportXml.SolutionManifest.RootComponents.RootComponent | ForEach-Object {
    Write-Output "  id=$($_.id) type=$($_.type) schema=$($_.schemaName)"
}

Write-Output "`n=== AQ07 botcomponents ==="
Get-ChildItem (Join-Path $aq07Dir 'botcomponents') -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "  $($_.Name)" }

Write-Output "`n=== AQ07 Workflows ==="
$wfPath = Join-Path $aq07Dir 'Workflows'
if (Test-Path $wfPath) {
    Get-ChildItem $wfPath -File | ForEach-Object { Write-Output "  $($_.Name) ($($_.Length) bytes)" }
} else { Write-Output "  (none)" }

Write-Output "`n=== AQ07 Assets/botcomponent_workflowset.xml ==="
$wfsetPath = Join-Path $aq07Dir 'Assets\botcomponent_workflowset.xml'
if (Test-Path $wfsetPath) {
    Get-Content $wfsetPath
} else { Write-Output "  (none)" }

Write-Output "`n================================================================="
Write-Output "=== PMO_v11_Tarefas solution.xml ==="
[xml]$pmov11xml = Get-Content (Join-Path $pmov11Dir 'solution.xml')
Write-Output "UniqueName: $($pmov11xml.ImportExportXml.SolutionManifest.UniqueName)"
Write-Output "Version: $($pmov11xml.ImportExportXml.SolutionManifest.Version)"
Write-Output "Managed: $($pmov11xml.ImportExportXml.SolutionManifest.Managed)"
Write-Output "--- RootComponents ---"
$pmov11xml.ImportExportXml.SolutionManifest.RootComponents.RootComponent | ForEach-Object {
    Write-Output "  id=$($_.id) type=$($_.type) schema=$($_.schemaName)"
}

Write-Output "`n=== PMOv11 botcomponents ==="
$bcPath = Join-Path $pmov11Dir 'botcomponents'
if (Test-Path $bcPath) {
    Get-ChildItem $bcPath -Directory | ForEach-Object { Write-Output "  $($_.Name)" }
} else { Write-Output "  (none)" }

Write-Output "`n=== PMOv11 Workflows ==="
$wfPath2 = Join-Path $pmov11Dir 'Workflows'
if (Test-Path $wfPath2) {
    Get-ChildItem $wfPath2 -File | ForEach-Object { Write-Output "  $($_.Name) ($($_.Length) bytes)" }
} else { Write-Output "  (none)" }

Write-Output "`n=== PMOv11 Assets/botcomponent_workflowset.xml ==="
$wfsetPath2 = Join-Path $pmov11Dir 'Assets\botcomponent_workflowset.xml'
if (Test-Path $wfsetPath2) {
    Get-Content $wfsetPath2
} else { Write-Output "  (none)" }

# Cross-compare
Write-Output "`n================================================================="
Write-Output "=== CROSS-COMPARE ==="
$aq07bc = @(Get-ChildItem (Join-Path $aq07Dir 'botcomponents') -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name)
$pmov11bc = @()
if (Test-Path $bcPath) {
    $pmov11bc = @(Get-ChildItem $bcPath -Directory | Select-Object -ExpandProperty Name)
}
$inBoth = @($aq07bc | Where-Object { $_ -in $pmov11bc })
$aq07Only = @($aq07bc | Where-Object { $_ -notin $pmov11bc })
$pmov11Only = @($pmov11bc | Where-Object { $_ -notin $aq07bc })

Write-Output "--- Dual-owned (in BOTH) count=$($inBoth.Count) ---"
$inBoth | ForEach-Object { Write-Output "  $_" }
Write-Output "--- AQ07-only count=$($aq07Only.Count) ---"
$aq07Only | ForEach-Object { Write-Output "  $_" }
Write-Output "--- PMOv11-only count=$($pmov11Only.Count) ---"
$pmov11Only | ForEach-Object { Write-Output "  $_" }
