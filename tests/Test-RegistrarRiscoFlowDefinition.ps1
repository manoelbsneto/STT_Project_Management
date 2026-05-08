[CmdletBinding()]
param([string]$Path = "deploy\PA_RegistrarRiscoBot_Flow.ps1")

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "PMOFlowDefinition.TestHelpers.ps1")

$build = Invoke-PMOFlowBuildOnly -ScriptPath $Path -Prefix "pa_registrarriscobot"
$text = $build.text
$checks = [System.Collections.Generic.List[object]]::new()

Add-PMOCommonFlowChecks $checks $text "PMO_PA_RegistrarRiscoBot"
Add-PMOCheck $checks "Has risk inputs" (($text -match "projectName") -and ($text -match "descricao") -and ($text -match "severidade")) "Required bot inputs."
Add-PMOCheck $checks "Guards project lookup" (($text -match "Condition_Projeto_Encontrado") -and ($text -match "PROJECT_NOT_FOUND")) "Must not create orphan risk."
Add-PMOCheck $checks "Creates Riscos e Bloqueios item" (($text -match '"table"\s*:\s*"Riscos e Bloqueios"') -and ($text -match "Create_Risco_SharePoint")) "Must write risk list."
Add-PMOCheck $checks "Sets risk fields" (($text -match '"item/Tipo/Value"\s*:\s*"Risco"') -and ($text -match '"item/Severidade/Value"') -and ($text -match '"item/StatusRisco/Value"\s*:\s*"Aberto"')) "Must set choice fields with /Value."
Add-PMOCheck $checks "Generates RiskID" ($text -match "RISK-" -and $text -match "guid\(\)") "RiskID must be generated."
Add-PMOCheck $checks "Has write failure response" ($text -match "SP_WRITE_FAILED") "Must handle SharePoint write failure."

Complete-PMOChecks $checks @{ buildPath = $build.path }
