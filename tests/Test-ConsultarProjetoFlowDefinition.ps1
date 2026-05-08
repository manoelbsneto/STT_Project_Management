[CmdletBinding()]
param([string]$Path = "deploy\PA_ConsultarProjeto_Flow.ps1")

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "PMOFlowDefinition.TestHelpers.ps1")

$build = Invoke-PMOFlowBuildOnly -ScriptPath $Path -Prefix "pa_consultarprojeto"
$text = $build.text
$checks = [System.Collections.Generic.List[object]]::new()

Add-PMOCommonFlowChecks $checks $text "PMO_PA_ConsultarProjeto"
Add-PMOCheck $checks "Has nomeProjeto input" ($text -match '"nomeProjeto"') "ConsultarProjeto requires nomeProjeto."
Add-PMOCheck $checks "Looks up project with guard" (($text -match "Get_Projeto") -and ($text -match "Condition_Projeto_Encontrado") -and ($text -match "PROJECT_NOT_FOUND")) "Must guard empty project lookup."
Add-PMOCheck $checks "Reads Riscos e Bloqueios" ($text -match '"table"\s*:\s*"Riscos e Bloqueios"') "Must count open risks."
Add-PMOCheck $checks "Filters open risks" ($text -match "StatusRisco eq .*Aberto") "Must only count open risks."
Add-PMOCheck $checks "Returns project details" (($text -match "StatusRAG") -and ($text -match "Percentual") -and ($text -match "DataAlvo") -and ($text -match "UltimaAtualizacao")) "Must return expected project fields."

Complete-PMOChecks $checks @{ buildPath = $build.path }
