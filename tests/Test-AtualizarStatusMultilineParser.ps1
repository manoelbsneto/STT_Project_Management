[CmdletBinding()]
param(
    [string]$TopicPath = ".planning\comms\solution_3_4_task_status_upn_validation_20260513\unpacked\botcomponents\pmo_AssistentePMO_V2.topic.AtualizarStatus\data"
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot\PMOFlowDefinition.TestHelpers.ps1"

$resolvedTopicPath = (Resolve-Path -LiteralPath $TopicPath).Path
$topic = Get-Content -LiteralPath $resolvedTopicPath -Raw
$checks = [System.Collections.Generic.List[object]]::new()

function Get-TopicVariableExpression {
    param(
        [string]$Yaml,
        [string]$VariableName
    )

    $pattern = "(?ms)variable:\s*Topic\.$([regex]::Escape($VariableName))\s*\r?\n\s*value:\s*(?<value>.+?)(?=\r?\n\r?\n\s*- kind:|\r?\n\r?\n\s*- id:|$)"
    $match = [regex]::Match($Yaml, $pattern)
    if (-not $match.Success) {
        return ""
    }

    $match.Groups["value"].Value.Trim()
}

$summaryExpression = Get-TopicVariableExpression -Yaml $topic -VariableName "Resumo"
$riskExpression = Get-TopicVariableExpression -Yaml $topic -VariableName "Risco"
$blockExpression = Get-TopicVariableExpression -Yaml $topic -VariableName "Bloqueio"
$nextActionExpression = Get-TopicVariableExpression -Yaml $topic -VariableName "ProximaAcao"

Add-PMOCheck $checks "Resumo parser accepts Resumo executivo label" ($summaryExpression -match "resumo\(\?:\\s\+executivo\)\?") "Homologation input uses 'Resumo executivo:'."
Add-PMOCheck $checks "Resumo parser captures multiline until next section" (($summaryExpression -match "\[\\s\\S\]\*\?") -and ($summaryExpression -match "\(\?=\\r\?\\n\\s\*\(\?:riscos\?\|bloqueios\?")) "Summary must not stop at the first newline or consume Riscos/Bloqueios."
Add-PMOCheck $checks "Risco parser accepts singular and plural labels" ($riskExpression -match "riscos\?\\s\*\[:=\]") "Homologation input uses 'Riscos:'."
Add-PMOCheck $checks "Bloqueio parser accepts singular and plural labels" ($blockExpression -match "bloqueios\?\\s\*\[:=\]") "Homologation input uses 'Bloqueios:'."
Add-PMOCheck $checks "ProximaAcao parser accepts no-accent and accented action labels" (($nextActionExpression.Contains("pr[o\u00f3]xim[ao]")) -and ($nextActionExpression.Contains("a[c\u00e7][a\u00e3]o"))) "Homologation input uses 'Proxima acao:' while users may type accents."
Add-PMOCheck $checks "Structured field parsers use multiline captures" (($riskExpression -match "\[\\s\\S\]\*\?") -and ($blockExpression -match "\[\\s\\S\]\*\?") -and ($nextActionExpression -match "\[\\s\\S\]\*\?")) "Structured sections may contain wrapped STT text."
Add-PMOCheck $checks "Flow binding still sends structured fields" (($topic -match "risco:\s*=Global\.PMO_Status_Risco") -and ($topic -match "bloqueio:\s*=Global\.PMO_Status_Bloqueio") -and ($topic -match "proximaAcao:\s*=Global\.PMO_Status_ProximaAcao") -and ($topic -match "percentual:\s*=Global\.PMO_Status_Percentual")) "Parser output must still be passed to PMO_PA_AtualizarStatus."

Complete-PMOChecks $checks @{
    topicPath = $resolvedTopicPath
    scope = "AtualizarStatus multiline parser"
}
