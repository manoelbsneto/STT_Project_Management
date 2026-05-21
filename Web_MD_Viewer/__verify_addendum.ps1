$f = 'D:\VMs\Projetos\STT_Project_Management\Web_MD_Viewer\UI-REVIEW.md'
$bytes = (Get-Item $f).Length
$lines = (Get-Content $f).Count
Write-Host ("UI-REVIEW.md bytes={0} lines={1}" -f $bytes, $lines)
$c = Get-Content $f -Raw
$kws = @('Addendum','view-header-hero','mission-progress-bar','Before / After','redesign rationale','Hybrid Card-First','28px','18px 22px','25/25 passing','313 opens : 313 closes')
foreach ($kw in $kws) {
  if ($c -match [regex]::Escape($kw)) { Write-Host ("  OK   {0}" -f $kw) }
  else { Write-Host ("  MISS {0}" -f $kw) }
}
