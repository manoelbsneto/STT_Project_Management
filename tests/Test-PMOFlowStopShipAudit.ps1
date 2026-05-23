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
        $file = Get-ChildItem -LiteralPath $workflowRoot -Filter "Clean_$NamePrefix*.json" | Select-Object -First 1
    }
    if (-not $file) {
        throw "Workflow not found: $NamePrefix"
    }
    (Get-Content -LiteralPath $file.FullName -Raw) -replace '\\u0027', "'" -replace '\\/', '/'
}

function Find-WorkflowFile {
    param([string]$NamePrefix)
    $file = Get-ChildItem -LiteralPath $workflowRoot -Filter "$NamePrefix*.json" | Select-Object -First 1
    if (-not $file) {
        $file = Get-ChildItem -LiteralPath $workflowRoot -Filter "Clean_$NamePrefix*.json" | Select-Object -First 1
    }
    $file
}

function Get-BotComponentData {
    param([string]$NamePattern)
    $botcompRoot = Join-Path $resolvedRoot "botcomponents"
    $dir = Get-ChildItem -LiteralPath $botcompRoot -Directory |
        Where-Object { $_.Name -like $NamePattern } |
        Select-Object -First 1
    if (-not $dir) {
        throw "Bot component not found: $NamePattern"
    }
    Get-Content -LiteralPath (Join-Path $dir.FullName "data") -Raw
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
    Add-Check "No invoker runtime source: $($file.Name)" ($workflowText -notmatch '"runtimeSource"\s*:\s*"invoker"') "Solution package must not force per-user connector consent for PMO flows."
    Add-Check "No raw APIM token auth: $($file.Name)" ($workflowText -notmatch "X-MS-APIM-Tokens|ConnectionKey") "Solution package must use connection reference authentication."
    Add-Check "ASCII-only workflow text: $($file.Name)" ($workflowText -notmatch "[^\x00-\x7F]") "Flow text must avoid accents, emoji, cedilla, and special punctuation."
}

$solutionTextFiles = Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File | Where-Object {
    $_.Extension -in @(".json", ".xml", ".txt") -or $_.Name -eq "data"
}
$allSolutionTextParts = [System.Collections.Generic.List[string]]::new()
$nonAsciiFiles = @()
$mojibakeFiles = @()
$oldBotSchemaFiles = @()
foreach ($file in $solutionTextFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw
    $allSolutionTextParts.Add($text) | Out-Null
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
$allSolutionText = $allSolutionTextParts -join "`n"
Add-Check "Solution text is ASCII-only" ($nonAsciiFiles.Count -eq 0) ($nonAsciiFiles -join "; ")
Add-Check "Solution text has no mojibake" ($mojibakeFiles.Count -eq 0) ($mojibakeFiles -join "; ")
Add-Check "Solution has no deleted original bot schema references" ($oldBotSchemaFiles.Count -eq 0) ($oldBotSchemaFiles -join "; ")

$criar = Get-WorkflowText "PMO_PA_CriarTarefa"
$criarProjeto = $null
try {
    $criarProjeto = Get-WorkflowText "PMO_PA_CriarProjeto"
}
catch {
    $criarProjeto = $null
}

if ($criarProjeto) {
    Add-Check "CriarProjeto has no padLeft" ($criarProjeto -notmatch "padLeft") "Power Automate template language does not support padLeft in this tenant."
    Add-Check "CriarProjeto duplicate lookup uses DateTime day range" (($criarProjeto -match "DataAlvo ge datetime") -and ($criarProjeto -match "DataAlvo lt datetime")) "Avoid SharePoint DateTime eq string comparison."
    Add-Check "CriarProjeto maps required PM person field" ($criarProjeto -match '"item/PM/Claims"') "Projetos.PM is required by provisioning."
    Add-Check "CriarProjeto supports critical priority choice" ($criarProjeto -match "'Critica'") "Projetos.Prioridade uses ASCII Critica choice."
    Add-Check "CriarProjeto writes Projetos only" (($criarProjeto -match "0271c9e8-c184-4b91-99f9-5b71f9b08826") -and ($criarProjeto -notmatch "36d78ca1-1f60-4dd3-a4d5-5c94b89969e9")) "REQ-14: project creation must not write Tarefas."
    Add-Check "CriarTarefa writes Tarefas only" (($criar -match "36d78ca1-1f60-4dd3-a4d5-5c94b89969e9") -and ($criar -notmatch "Create_Projeto_SharePoint") -and ($criar -notmatch '"item/PM/Claims"')) "REQ-15: task creation must not create/update Projetos."
    Add-Check "CriarTarefa resolves active project" (($criar -match "0271c9e8-c184-4b91-99f9-5b71f9b08826") -and ($criar -match "Ativo eq 1") -and ($criar -match "Deleted ne 1") -and ($criar -match "PROJECT_NOT_FOUND")) "REQ-15: task creation requires active non-deleted project."
} else {
    Add-Check "CriarTarefa has no padLeft" ($criar -notmatch "padLeft") "Power Automate template language does not support padLeft in this tenant."
    Add-Check "CriarTarefa duplicate lookup uses DateTime day range" (($criar -match "DataAlvo ge datetime") -and ($criar -match "DataAlvo lt datetime")) "Avoid SharePoint DateTime eq string comparison."
    Add-Check "CriarTarefa maps required PM person field" ($criar -match '"item/PM/Claims"') "Projetos.PM is required by provisioning."
    Add-Check "CriarTarefa supports critical priority choice" ($criar -match "'Critica'") "Projetos.Prioridade uses ASCII Critica choice."
}

$listar = Get-WorkflowText "PMO_PA_ListarTarefas"
Add-Check "ListarTarefas targets Tarefas list" (($listar -match [regex]::Escape("36d78ca1-1f60-4dd3-a4d5-5c94b89969e9")) -or ($listar -match '"table"\s*:\s*"Tarefas"')) "Flow must query the provisioned task list."
Add-Check "ListarTarefas completed filter uses ASCII choice" ($listar -match "Concluida") "Completed count must use ASCII SharePoint choice value."
Add-Check "ListarTarefas accepts NomeProjeto input" ($listar -match '"NomeProjeto"' -and $listar -match "Compose_ProjectInput") "Flow must accept a human project name, not only ProjectID."
Add-Check "ListarTarefas resolves NomeProjeto to ProjectID" (((($listar -match [regex]::Escape("0271c9e8-c184-4b91-99f9-5b71f9b08826")) -or ($listar -match '"table"\s*:\s*"Projetos"')) -and ($listar -match "Get_Projeto") -and ($listar -match "ProjectID"))) "Flow must lookup Projetos by NomeProjeto/ProjectID before querying Tarefas."
Add-Check "ListarTarefas handles project not found" ($listar -match "PROJECT_NOT_FOUND" -and $listar -match "Condition_Projeto_Encontrado") "Avoid listing empty tasks when the project name is invalid."
Add-Check "ListarTarefas response is deterministic ultra-safe plain text" (($listar -notmatch "\*\*") -and ($listar -notmatch "---") -and ($listar -notmatch '```') -and ($listar -match "Consulta concluida") -and ($listar -match "Dados lidos no SharePoint")) "Avoid Markdown-heavy or verbose dynamic output that can trigger Copilot Studio Responsible AI filters."
Add-Check "ListarTarefas suppresses SharePoint free-text and verbose task fields before response" (($listar -notmatch "item\(\)\?\['Title'\]") -and ($listar -notmatch "item\(\)\?\['Responsavel'\]") -and ($listar -notmatch "Horas realizadas") -and ($listar -notmatch "Horas estimadas")) "Live runtime showed even verbose deterministic rows can be blocked; bot-visible response keeps a static confirmation only."
Add-Check "ListarTarefas uses single-line output instead of literal or dynamic line breaks" (($listar -notmatch "decodeUriComponent\('%0A'\)") -and ($listar -notmatch "'\\\\n'")) "Avoid raw or dynamic line-break patterns in bot-visible output."
Add-Check "ListarTarefas keeps response schema stable" (($listar -match '"result"\s*:\s*"Consulta concluida') -and ($listar -match '"properties"\s*:\s*\{[^}]*"result"')) "Copilot action contract remains a single result string with static runtime-safe content."

$portfolio = Get-WorkflowText "PMO_PA_ConsultarPortfolio"
Add-Check "ConsultarPortfolio returns active project names" (($portfolio -match "Select_Projetos_Nomes") -and ($portfolio -match "Compose_Projetos_Nomes") -and ($portfolio -match "Projetos:")) "listar projetos ativos must return project names, not only counts."

$listarAction = Get-BotComponentData "*action.PMO_PA_ListarTarefas"
$listarTopic = Get-BotComponentData "*topic.ListarTarefas"
Add-Check "ListarTarefas action binds NomeProjeto" ($listarAction -match "propertyName:\s*NomeProjeto") "Copilot action must pass NomeProjeto into the flow trigger contract."
Add-Check "ListarTarefas topic asks for name or code" (($listarTopic -match "Topic\.NomeProjeto") -and ($listarTopic -match "nome ou codigo")) "Topic must collect a project name as a first-class input."
Add-Check "ListarTarefas topic parses inline project input" (($listarTopic -match "parse_nome_projeto") -and ($listarTopic -match "listar\\s\+tarefas") -and ($listarTopic -match "tarefas\\s\+do\\s\+projeto")) "Topic must parse inline commands such as listar tarefas PRJ-001."

$atualizar = Get-WorkflowText "PMO_PA_AtualizarTarefa"
Add-Check "AtualizarTarefa targets Tarefas list" ($atualizar -match '"table"\s*:\s*"Tarefas"') "Flow must update the provisioned task list."
Add-Check "AtualizarTarefa uses SharePoint choice path for Status" ($atualizar -match '"item/Status/Value"') "PatchItem choice fields must use /Value parameter paths."
Add-Check "AtualizarTarefa uses SharePoint choice path for Prioridade" ($atualizar -match '"item/Prioridade/Value"') "PatchItem choice fields must use /Value parameter paths."
Add-Check "AtualizarTarefa preserves required PM as claims" (($atualizar -match '"item/PM/Claims"') -and ($atualizar -notmatch '"item/PM":')) "Projeto updates must not patch raw person objects."
Add-Check "AtualizarTarefa normalizes critical priority" ($atualizar -match "'Critica'") "Tarefas.Prioridade uses ASCII Critica choice."
Add-Check "AtualizarTarefa has project lookup guard" ($atualizar -match "Condition_Projeto_Encontrado" -and $atualizar -match "PROJECT_NOT_FOUND") "Avoid unguarded first() when ProjectID is missing."
Add-Check "AtualizarTarefa overdue comparison is date-normalized" ($atualizar -match "formatDateTime\(item\(\)\?\['DataFim'\], 'yyyy-MM-dd'\)") "Avoid treating today's date as overdue due to UTC time."
Add-Check "AtualizarTarefa skip tokens preserve optional fields" (
    ($atualizar -match "equals\(triggerBody\(\)\?\['number_1'\], 0\)") -and
    ($atualizar -match "equals\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['text_1'\], ''\)\)\), 'nao'\)") -and
    ($atualizar -match "equals\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['text_2'\], ''\)\)\), 'nao'\)") -and
    ($atualizar -match "equals\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['text_3'\], ''\)\)\), 'nao'\)") -and
    ($atualizar -match "lessOrEquals\(length\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['text_1'\], ''\)\)\)\), 3\)") -and
    ($atualizar -match "lessOrEquals\(length\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['text_2'\], ''\)\)\)\), 3\)") -and
    ($atualizar -match "lessOrEquals\(length\(toLower\(trim\(coalesce\(triggerBody\(\)\?\['text_3'\], ''\)\)\)\), 3\)")
) "Optional AtualizarTarefa inputs must treat 0/nao/n/short n-token as keep-current instead of patching invalid SharePoint values."

$checkinFile = Find-WorkflowFile "PMO_PA_CheckInOnDemand"
if ($checkinFile) {
    $checkin = Get-WorkflowText "PMO_PA_CheckInOnDemand"
    Add-Check "CheckIn has project lookup guard" ($checkin -match "Condition_Projeto_Encontrado" -and $checkin -match "PROJECT_NOT_FOUND") "Unknown ProjectID must not create orphan status records."
    Add-Check "CheckIn percent supports comma decimal" ($checkin -match "float\(replace\(string\(outputs\('Normalize_Percentual'\)\), ',', '.'\)\)") "Adaptive Card numeric values can arrive as decimal strings."
    Add-Check "CheckIn percent does not force integer" ($checkin -notmatch "int\(float\(replace\(string\(outputs\('Normalize_Percentual'\)\), ',', '.'\)\)\)") "SharePoint Number fields must accept decimal percent values such as 10.5."
    Add-Check "CheckIn preserves required PM as claims" ($checkin -match '"item/PM/Claims"') "Projeto updates must include required person field."
} else {
    Add-Check "CheckIn adaptive-card flow excluded cleanly" ($allSolutionText -notmatch "PMO_PA_CheckInOnDemand") "Core release may exclude unrouted adaptive-card flows only when no workflow, bot action, binding, dependency, or solution component remains."
}

$riscoFile = Find-WorkflowFile "PMO_PA_EscalarRiscoCritico"
if ($riscoFile) {
    $risco = Get-WorkflowText "PMO_PA_EscalarRiscoCritico"
    Add-Check "EscalarRiscoCritico accepts ASCII critical value" ($risco -match "Critica") "Portuguese choice values must be ASCII-safe."
    Add-Check "EscalarRiscoCritico avoids unsafe first project lookup" ($risco -notmatch "first\(body\('Get_Projeto'\)") "Risk escalation must not fail when project lookup is empty."
} else {
    Add-Check "EscalarRiscoCritico adaptive-card flow excluded cleanly" ($allSolutionText -notmatch "PMO_PA_EscalarRiscoCritico") "Core release may exclude unrouted adaptive-card flows only when no workflow, bot action, binding, dependency, or solution component remains."
}

$decisaoFile = Find-WorkflowFile "PMO_PA_RegistrarDecisaoBoard"
if ($decisaoFile) {
    $decisao = Get-WorkflowText "PMO_PA_RegistrarDecisaoBoard"
    Add-Check "RegistrarDecisaoBoard stores response status in Resposta" ($decisao -match '"item/Resposta": "@outputs\(''Normalize_Decision_Status''\)"') "Resposta must not duplicate Justificativa."
} else {
    Add-Check "RegistrarDecisaoBoard adaptive-card flow excluded cleanly" ($allSolutionText -notmatch "PMO_PA_RegistrarDecisaoBoard") "Core release may exclude unrouted adaptive-card flows only when no workflow, bot action, binding, dependency, or solution component remains."
}

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
    Add-Check "Bot workflow bindings target active V2 components only" (($workflowSet -notmatch "pmo_AssistentePMO\.") -and ($workflowSet -notmatch "pmo_AssistentePMO_Clean\.") -and ($workflowSet -match "pmo_AssistentePMO_V2\.action\.PMO_PA_CriarTarefa") -and ($workflowSet -match "0a5d2a41-24c0-4d5e-9f6d-000000000241") -and ($workflowSet -match "pmo_AssistentePMO_V2\.action\.PMO_PA_CriarProjeto") -and ($workflowSet -match "3104124d-364a-f111-bec7-7ced8d955c6c") -and ($workflowSet -notmatch 'pmo_AssistentePMO_V2\.topic\.CriarTarefa" workflowid\.workflowid="3104124d-364a-f111-bec7-7ced8d955c6c')) "Workflow bindings must target active V2 action components and not stale direct topic bindings."
    Add-Check "No unrouted adaptive action workflow bindings" ($workflowSet -notmatch "pmo_AssistentePMO_V2\.action\.PMO_PA_(CheckInOnDemand|EscalarRiscoCritico|RegistrarDecisaoBoard)") "Teams/Outlook adaptive-card action bindings must stay out of the core release until routed and dependency-clean."
}

Add-Check "No unresolved solution dependencies" ($allSolutionText -notmatch "<MissingDependency>") "Release package must not contain unresolved solution dependencies."
$hasPm0TeamsCardReference = (
    ($allSolutionText -match "PM0_PA_Card_AtualizarStatus") -and
    ($allSolutionText -match "cat_sharedteams_1ef7e") -and
    ($allSolutionText -match '<connectionreference connectionreferencelogicalname="cat_sharedteams_1ef7e"')
)
Add-Check "No unresolved Teams/Outlook kit connection references" ((($allSolutionText -notmatch "cat_sharedteams_1ef7e|cat_CopilotStudioKitOutlook") -or $hasPm0TeamsCardReference) -and ($allSolutionText -notmatch "cat_CopilotStudioKitOutlook")) "Teams/Outlook kit references require explicit connection references or removal from the core package; PM0 AtualizarStatus may include the Teams card connector when declared."
Add-Check "No unused gstf SharePoint connection reference" ($allSolutionText -notmatch "gstf_sharepoint") "Remove unused legacy SharePoint connection reference noise."
Add-Check "Preview-only batch has no orphan workflow" (($allSolutionText -notmatch 'Name="PMO_PA_Gerar_Multiplos_Projetos"') -and ($allSolutionText -notmatch "PMO_PA_Gerar_Multiplos_Projetos-0A5D2A42")) "Preview-only batch topic must not ship an unused workflow root component."

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
