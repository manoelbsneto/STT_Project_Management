$ErrorActionPreference = 'Stop'

$asIsDir = 'D:\VMs\Projetos\STT_Project_Management\.planning\comms\topic_remediation_20260520\as_is'
$liveDir = 'D:\VMs\Projetos\STT_Project_Management\.planning\milestones\M2_card_first_revision_v2\phases\01_discovery\F_topic_yamls'

# Map (legacy lowercase) → live capitalized
$pairs = @(
    @{asIs='atualizarstatus.yml';     live='AtualizarStatus.yaml'},
    @{asIs='atualizartarefa.yml';     live='AtualizarTarefa.yaml'},
    @{asIs='consultarportfolio.yml';  live='ConsultarPortfolio.yaml'},
    @{asIs='criartarefa.yml';         live='CriarTarefa.yaml'},
    @{asIs='listartarefas.yml';       live='ListarTarefas.yaml'}
)

foreach ($p in $pairs) {
    $a = Join-Path $asIsDir $p.asIs
    $b = Join-Path $liveDir $p.live
    if (-not (Test-Path $a)) { Write-Host ("MISSING_AS_IS: {0}" -f $a); continue }
    if (-not (Test-Path $b)) { Write-Host ("MISSING_LIVE: {0}" -f $b); continue }

    $aBytes = [System.IO.File]::ReadAllBytes($a)
    $bBytes = [System.IO.File]::ReadAllBytes($b)
    $aLen = $aBytes.Length
    $bLen = $bBytes.Length

    $aHash = (Get-FileHash -Path $a -Algorithm SHA256).Hash
    $bHash = (Get-FileHash -Path $b -Algorithm SHA256).Hash

    # Also compare normalized (strip BOM + trailing whitespace + LF normalize)
    $aText = [System.IO.File]::ReadAllText($a) -replace "`r`n", "`n"
    $bText = [System.IO.File]::ReadAllText($b) -replace "`r`n", "`n"
    $aText = $aText.TrimStart([char]0xFEFF).TrimEnd()
    $bText = $bText.TrimStart([char]0xFEFF).TrimEnd()
    $contentMatch = ($aText -eq $bText)

    Write-Host ("---- {0} vs {1} ----" -f $p.asIs, $p.live)
    Write-Host ("  bytes:    asIs={0}  live={1}  byteEqual={2}" -f $aLen, $bLen, ($aLen -eq $bLen))
    Write-Host ("  sha256:   asIs={0}" -f $aHash)
    Write-Host ("  sha256:   live={0}" -f $bHash)
    Write-Host ("  hashEq:   {0}" -f ($aHash -eq $bHash))
    Write-Host ("  contentEq (LF-norm, BOM-stripped, trim): {0}" -f $contentMatch)
}
