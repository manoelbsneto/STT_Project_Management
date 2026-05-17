[CmdletBinding()]
param([string]$Path = "deploy\PA_PedirDecisaoBot_Flow.ps1")

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "PMOFlowDefinition.TestHelpers.ps1")

$build = Invoke-PMOFlowBuildOnly -ScriptPath $Path -Prefix "pa_pedirdecisaobot"
$text = $build.text
$checks = [System.Collections.Generic.List[object]]::new()

Add-PMOCommonFlowChecks $checks $text "PMO_PA_PedirDecisaoBot"
Add-PMOCheck $checks "Has decision inputs" (($text -match "projectName") -and ($text -match "descricao") -and ($text -match "impacto") -and ($text -match "prazo") -and ($text -match "aprovador")) "Required bot inputs."
Add-PMOCheck $checks "Guards project lookup" (($text -match "Condition_Projeto_Encontrado") -and ($text -match "PROJECT_NOT_FOUND")) "Must not create orphan decision."
Add-PMOCheck $checks "Creates Decisoes do Board item" (($text -match '"table"\s*:\s*"Decisoes do Board"') -and ($text -match "Create_Decisao_SharePoint")) "Must write decisions list."
Add-PMOCheck $checks "Sets decision fields" (($text -match "DecisionID") -and ($text -match '"item/StatusDecisao/Value"\s*:\s*"Pendente"') -and ($text -match '"item/Impacto/Value"')) "Must set decision choices."
Add-PMOCheck $checks "Sets person claims" (($text -match '"item/Solicitante/Claims"') -and ($text -match '"item/Aprovador/Claims"') -and ($text -match "i:0#.f\\|membership\\|")) "Person fields must use claims."
Add-PMOCheck $checks "Trims approver UPN before writing SharePoint person fields" (($text -match "trim\(triggerBody\(\)\?\[(?:'|\\u0027)aprovador(?:'|\\u0027)\]\)") -and ($text -match '"item/ApproverUPN"\s*:\s*"@trim')) "Topic validation blocks malformed UPNs; the flow must still normalize leading/trailing spaces."
Add-PMOCheck $checks "Normalizes prazo without padLeft" ($text -match "Compose_Prazo" -and $text -notmatch "padLeft") "Date parser must be tenant-safe."
Add-PMOCheck $checks "Has write failure response" ($text -match "SP_WRITE_FAILED") "Must handle SharePoint write failure."

Complete-PMOChecks $checks @{ buildPath = $build.path }
