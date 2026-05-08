[CmdletBinding()]
param([string]$Path = "deploy\PA_ConsultarPortfolio_Flow.ps1")

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "PMOFlowDefinition.TestHelpers.ps1")

$build = Invoke-PMOFlowBuildOnly -ScriptPath $Path -Prefix "pa_consultarportfolio"
$text = $build.text
$checks = [System.Collections.Generic.List[object]]::new()

Add-PMOCommonFlowChecks $checks $text "PMO_PA_ConsultarPortfolio"
Add-PMOCheck $checks "Targets Projetos list" ($text -match '"table"\s*:\s*"Projetos"') "Portfolio must read Projetos."
Add-PMOCheck $checks "Filters active projects" ($text -match "Ativo eq 1") "Portfolio must only count active projects."
Add-PMOCheck $checks "Counts RAG values" (($text -match "varVerde") -and ($text -match "varAmarelo") -and ($text -match "varVermelho")) "Must count Verde/Amarelo/Vermelho."
Add-PMOCheck $checks "Counts stale updates" (($text -match "varSemUpdate") -and ($text -match "UltimaAtualizacao") -and ($text -match "addDays\(utcNow\(\), -1\)")) "Must count projects without update in last 24h."
Add-PMOCheck $checks "Responds with portfolio summary" ($text -match "Portfolio PMO" -and $text -match "Sem update") "Response must include summary string."

Complete-PMOChecks $checks @{ buildPath = $build.path }
