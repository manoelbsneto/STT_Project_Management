[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$SolutionSourcePath
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $SolutionSourcePath).Path
$workflowRoot = Join-Path $resolvedRoot "Workflows"

$checks = [System.Collections.Generic.List[object]]::new()
function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

function Get-WorkflowText {
    param([string]$NamePrefix)
    $file = Get-ChildItem -LiteralPath $workflowRoot -Filter "$NamePrefix*.json" | Select-Object -First 1
    if (-not $file) {
        throw "Workflow not found: $NamePrefix"
    }
    Get-Content -LiteralPath $file.FullName -Raw
}

$workflowFiles = Get-ChildItem -LiteralPath $workflowRoot -Filter "*.json"
$mojibakePattern = "$([char]0x00F0)|$([char]0x00C3)|$([char]0x00E2)|$([char]0x00C2)|$([char]0xFFFD)"
foreach ($file in $workflowFiles) {
    $workflowText = Get-Content -LiteralPath $file.FullName -Raw
    try {
        $workflowText | ConvertFrom-Json | Out-Null
        Add-Check "JSON parse: $($file.Name)" $true $file.FullName
    }
    catch {
        Add-Check "JSON parse: $($file.Name)" $false $_.Exception.Message
    }
    Add-Check "No user-visible mojibake: $($file.Name)" ($workflowText -notmatch $mojibakePattern) "Flow text must not contain corrupted UTF-8 sequences that render as trash in Teams/Power Automate."
    Add-Check "ASCII-only workflow text: $($file.Name)" ($workflowText -notmatch "[^\x00-\x7F]") "Flow text must avoid accents, emoji, cedilla, and special punctuation."
}

$solutionTextFiles = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File | Where-Object {
    $_.Extension -in @(".json", ".xml", ".txt") -or $_.Name -eq "data"
}
$nonAsciiFiles = @()
$mojibakeFiles = @()
$oldBotSchemaFiles = @()
foreach ($file in $solutionTextFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    if ($text -match "[^\x00-\x7F]") {
        $nonAsciiFiles += $file.FullName
    }
    if ($text -match $mojibakePattern) {
        $mojibakeFiles += $file.FullName
    }
    if ($text -match "pmo_AssistentePMO(?!_Clean)\.") {
        $oldBotSchemaFiles += $file.FullName
    }
}
Add-Check "Solution text is ASCII-only" ($nonAsciiFiles.Count -eq 0) ($nonAsciiFiles -join "; ")
Add-Check "Solution text has no mojibake" ($mojibakeFiles.Count -eq 0) ($mojibakeFiles -join "; ")
Add-Check "Solution has no deleted original bot schema references" ($oldBotSchemaFiles.Count -eq 0) ($oldBotSchemaFiles -join "; ")

$criar = Get-WorkflowText "PMO_PA_CriarTarefa"
Add-Check "CriarTarefa has no padLeft" ($criar -notmatch "padLeft") "Power Automate template language does not support padLeft in this tenant."
Add-Check "CriarTarefa duplicate lookup uses DateTime day range" (($criar -match "DataAlvo ge datetime") -and ($criar -match "DataAlvo lt datetime")) "Avoid SharePoint DateTime eq string comparison."
Add-Check "CriarTarefa maps required PM person field" ($criar -match '"item/PM/Claims"') "Projetos.PM is required by provisioning."
Add-Check "CriarTarefa supports critical priority choice" ($criar -match "'Critica'") "Projetos.Prioridade uses ASCII Critica choice."

$listar = Get-WorkflowText "PMO_PA_ListarTarefas"
Add-Check "ListarTarefas targets Tarefas list" ($listar -match '"table": "Tarefas"') "Flow must query the provisioned task list."
Add-Check "ListarTarefas completed filter uses ASCII choice" ($listar -match "Concluida") "Completed count must use ASCII SharePoint choice value."

$atualizar = Get-WorkflowText "PMO_PA_AtualizarTarefa"
Add-Check "AtualizarTarefa targets Tarefas list" ($atualizar -match '"table": "Tarefas"') "Flow must update the provisioned task list."
Add-Check "AtualizarTarefa uses SharePoint choice path for Status" ($atualizar -match '"item/Status/Value"') "PatchItem choice fields must use /Value parameter paths."
Add-Check "AtualizarTarefa uses SharePoint choice path for Prioridade" ($atualizar -match '"item/Prioridade/Value"') "PatchItem choice fields must use /Value parameter paths."
Add-Check "AtualizarTarefa preserves required PM as claims" (($atualizar -match '"item/PM/Claims"') -and ($atualizar -notmatch '"item/PM":')) "Projeto updates must not patch raw person objects."
Add-Check "AtualizarTarefa normalizes critical priority" ($atualizar -match "'Critica'") "Tarefas.Prioridade uses ASCII Critica choice."
Add-Check "AtualizarTarefa has project lookup guard" ($atualizar -match "Condition_Projeto_Encontrado" -and $atualizar -match "PROJECT_NOT_FOUND") "Avoid unguarded first() when ProjectID is missing."
Add-Check "AtualizarTarefa overdue comparison is date-normalized" ($atualizar -match "formatDateTime\(item\(\)\?\['DataFim'\], 'yyyy-MM-dd'\)") "Avoid treating today's date as overdue due to UTC time."

$checkin = Get-WorkflowText "PMO_PA_CheckInOnDemand"
Add-Check "CheckIn has project lookup guard" ($checkin -match "Condition_Projeto_Encontrado" -and $checkin -match "PROJECT_NOT_FOUND") "Unknown ProjectID must not create orphan status records."
Add-Check "CheckIn percent supports comma decimal" ($checkin -match "float\(replace\(string\(outputs\('Normalize_Percentual'\)\), ',', '.'\)\)") "Adaptive Card numeric values can arrive as decimal strings."
Add-Check "CheckIn percent does not force integer" ($checkin -notmatch "int\(float\(replace\(string\(outputs\('Normalize_Percentual'\)\), ',', '.'\)\)\)") "SharePoint Number fields must accept decimal percent values such as 10.5."
Add-Check "CheckIn preserves required PM as claims" ($checkin -match '"item/PM/Claims"') "Projeto updates must include required person field."

$risco = Get-WorkflowText "PMO_PA_EscalarRiscoCritico"
Add-Check "EscalarRiscoCritico accepts ASCII critical value" ($risco -match "Critica") "Portuguese choice values must be ASCII-safe."
Add-Check "EscalarRiscoCritico avoids unsafe first project lookup" ($risco -notmatch "first\(body\('Get_Projeto'\)") "Risk escalation must not fail when project lookup is empty."

$decisao = Get-WorkflowText "PMO_PA_RegistrarDecisaoBoard"
Add-Check "RegistrarDecisaoBoard stores response status in Resposta" ($decisao -match '"item/Resposta": "@outputs\(''Normalize_Decision_Status''\)"') "Resposta must not duplicate Justificativa."

$provisioningPath = Resolve-Path -LiteralPath (Join-Path (Get-Location) "deploy\SP_Provisioning.ps1")
$provisioning = Get-Content -LiteralPath $provisioningPath.Path -Raw
Add-Check "Provisioning creates Tarefas list" ($provisioning -match 'New-PnPList -Title "Tarefas"') "ListarTarefas and AtualizarTarefa depend on this list."
Add-Check "Provisioning pilot projects include PM" ($provisioning -match 'PM=\$DefaultPM') "Projetos.PM is required."

$botcompRoot = Join-Path $resolvedRoot "botcomponents"
if (Test-Path $botcompRoot) {
    $ghostDirs = @(Get-ChildItem -LiteralPath $botcompRoot -Directory |
        Where-Object { $_.Name -match '^pmo_AssistentePMO\.' -and $_.Name -notmatch '^pmo_AssistentePMO_Clean\.' })
    Add-Check "No orphaned pmo_AssistentePMO ghost bot components" ($ghostDirs.Count -eq 0) ($ghostDirs.Name -join "; ")
} else {
    Add-Check "No orphaned pmo_AssistentePMO ghost bot components" $true "No botcomponents directory in solution export."
}

$workflowSetPath = Join-Path $resolvedRoot "Assets\botcomponent_workflowset.xml"
if (Test-Path $workflowSetPath) {
    $workflowSet = Get-Content -LiteralPath $workflowSetPath -Raw
    Add-Check "Bot workflow bindings use only Clean action components" (($workflowSet -notmatch "pmo_AssistentePMO(?!_Clean)\.") -and ($workflowSet -notmatch "\.topic\.CriarTarefa")) "Workflow bindings must not target the deleted original bot or bind topic.CriarTarefa directly to the cloud flow."
}

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    solutionSourcePath = $resolvedRoot
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$result | ConvertTo-Json -Depth 10

if ($failed.Count -gt 0) {
    throw "PMO flow stop-ship audit failed: $($failed.name -join '; ')"
}
