[CmdletBinding()]
param([string]$Path = "deploy\PA_RegistrarBloqueioBot_Flow.ps1")

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "PMOFlowDefinition.TestHelpers.ps1")

$build = Invoke-PMOFlowBuildOnly -ScriptPath $Path -Prefix "pa_registrarbloqueiobot"
$text = $build.text
$checks = [System.Collections.Generic.List[object]]::new()

Add-PMOCommonFlowChecks $checks $text "PMO_PA_RegistrarBloqueioBot"
Add-PMOCheck $checks "Has block inputs" (($text -match "projectName") -and ($text -match "descricao") -and ($text -match "impacto")) "Required bot inputs."
Add-PMOCheck $checks "Guards project lookup" (($text -match "Condition_Projeto_Encontrado") -and ($text -match "PROJECT_NOT_FOUND")) "Must not create orphan block."
Add-PMOCheck $checks "Creates Riscos e Bloqueios item" (($text -match '"table"\s*:\s*"Riscos e Bloqueios"') -and ($text -match "Create_Bloqueio_SharePoint")) "Must write risk/block list."
Add-PMOCheck $checks "Sets block fields" (($text -match '"item/Tipo/Value"\s*:\s*"Bloqueio"') -and ($text -match '"item/Impacto/Value"') -and ($text -match '"item/StatusRisco/Value"\s*:\s*"Aberto"')) "Must set block choices."
Add-PMOCheck $checks "Sets required severity" ($text -match '"item/Severidade/Value"') "Provisioning marks Severidade required."
Add-PMOCheck $checks "Has write failure response" ($text -match "SP_WRITE_FAILED") "Must handle SharePoint write failure."

Complete-PMOChecks $checks @{ buildPath = $build.path }
