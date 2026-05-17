[CmdletBinding()]
param(
    [string]$SolutionSourcePath = ".planning\comms\solution_1_14_soft_delete_20260511\unpacked",

    [string]$PackagePath
)

$ErrorActionPreference = "Stop"

$tempRoot = $null

function Add-Check {
    param(
        [System.Collections.Generic.List[object]]$Checks,
        [string]$Name,
        [bool]$Passed,
        [string]$Evidence
    )

    $Checks.Add([ordered]@{
        name = $Name
        passed = $Passed
        evidence = $Evidence
    }) | Out-Null
}

function Resolve-SolutionSourceRoot {
    param(
        [string]$SourcePath,
        [string]$ZipPath
    )

    if (-not [string]::IsNullOrWhiteSpace($ZipPath)) {
        $script:tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("pmo-excluir-soft-delete-" + [System.Guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $script:tempRoot -Force | Out-Null
        Expand-Archive -LiteralPath (Resolve-Path -LiteralPath $ZipPath).Path -DestinationPath $script:tempRoot -Force

        $candidateRoots = @(
            $script:tempRoot,
            (Join-Path $script:tempRoot "unpacked")
        )

        $nested = Get-ChildItem -LiteralPath $script:tempRoot -Directory -Recurse -ErrorAction SilentlyContinue |
            Where-Object { (Test-Path (Join-Path $_.FullName "Workflows")) -and (Test-Path (Join-Path $_.FullName "botcomponents")) } |
            Select-Object -ExpandProperty FullName
        $candidateRoots += $nested

        foreach ($candidate in $candidateRoots) {
            if ((Test-Path (Join-Path $candidate "Workflows")) -and (Test-Path (Join-Path $candidate "botcomponents"))) {
                return (Resolve-Path -LiteralPath $candidate).Path
            }
        }

        throw "Could not find Workflows and botcomponents folders after unpacking $ZipPath."
    }

    $resolved = (Resolve-Path -LiteralPath $SourcePath).Path
    if (-not (Test-Path (Join-Path $resolved "Workflows"))) {
        throw "Solution source root must contain a Workflows folder: $resolved"
    }
    if (-not (Test-Path (Join-Path $resolved "botcomponents"))) {
        throw "Solution source root must contain a botcomponents folder: $resolved"
    }

    return $resolved
}

function Get-NamedWorkflow {
    param(
        [System.IO.FileInfo[]]$WorkflowFiles,
        [string]$CapabilityName
    )

    $matches = foreach ($file in $WorkflowFiles) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        if (($file.Name -match "(?i)$([regex]::Escape($CapabilityName))") -or ($text -match "(?i)PMO_PA_$([regex]::Escape($CapabilityName))|$([regex]::Escape($CapabilityName))")) {
            [pscustomobject]@{
                File = $file
                Text = $text
            }
        }
    }

    @($matches)
}

function Get-NamedTopic {
    param(
        [string]$BotComponentRoot,
        [string]$CapabilityName
    )

    $topicDirs = Get-ChildItem -LiteralPath $BotComponentRoot -Directory -ErrorAction Stop |
        Where-Object { $_.Name -match "(?i)\.topic\.$([regex]::Escape($CapabilityName))$" }

    $matches = foreach ($dir in $topicDirs) {
        $dataPath = Join-Path $dir.FullName "data"
        if (Test-Path -LiteralPath $dataPath) {
            [pscustomobject]@{
                Directory = $dir
                DataPath = $dataPath
                Text = Get-Content -LiteralPath $dataPath -Raw
            }
        }
    }

    if (@($matches).Count -eq 0) {
        $dataFiles = Get-ChildItem -LiteralPath $BotComponentRoot -Recurse -File -Filter "data" -ErrorAction Stop
        $matches = foreach ($file in $dataFiles) {
            $text = Get-Content -LiteralPath $file.FullName -Raw
            if ($text -match "(?m)^\s*displayName:\s*$([regex]::Escape($CapabilityName))\s*$") {
                [pscustomobject]@{
                    Directory = $file.Directory
                    DataPath = $file.FullName
                    Text = $text
                }
            }
        }
    }

    @($matches)
}

function Get-SharePointTables {
    param([string]$Text)

    @([regex]::Matches($Text, '"table"\s*:\s*"([^"]+)"') |
        ForEach-Object { $_.Groups[1].Value } |
        Select-Object -Unique)
}

function Test-SoftDeleteWorkflow {
    param(
        [System.Collections.Generic.List[object]]$Checks,
        [string]$CapabilityName,
        [string]$ExpectedList,
        [pscustomobject]$Workflow
    )

    $text = $Workflow.Text
    $tables = Get-SharePointTables -Text $text
    $unexpectedTables = @($tables | Where-Object { $_ -notin @("Projetos", "Tarefas") })

    Add-Check $Checks "$CapabilityName workflow uses SharePoint Standard connector" (($text -match 'shared_sharepointonline') -and ($text -match '/providers/Microsoft\.PowerApps/apis/shared_sharepointonline')) $Workflow.File.FullName
    Add-Check $Checks "$CapabilityName workflow uses PatchItem update semantics" ($text -match '"operationId"\s*:\s*"PatchItem"') "SharePoint Update item uses the PatchItem operationId in exported workflow JSON."
    Add-Check $Checks "$CapabilityName workflow has no physical SharePoint delete" ($text -notmatch '(?i)"operationId"\s*:\s*"DeleteItem"|"\s*method\s*"\s*:\s*"DELETE"|deleteobject|recycle|Remove-PnPListItem') "Soft delete must never call DeleteItem, raw DELETE, recycle, or Remove-PnPListItem."
    Add-Check $Checks "$CapabilityName workflow has no raw HTTP delete path" ($text -notmatch '(?i)"type"\s*:\s*"Http"|shared_http|_api/web/lists') "Use the supported SharePoint connector, not raw REST/HTTP."
    Add-Check $Checks "$CapabilityName workflow targets $ExpectedList" ($tables -contains $ExpectedList) ("Tables found: " + ($tables -join ", "))
    Add-Check $Checks "$CapabilityName workflow targets only Projetos/Tarefas lists" ($unexpectedTables.Count -eq 0) ("Tables found: " + ($tables -join ", "))
    Add-Check $Checks "$CapabilityName workflow writes Deleted true" ($text -match '"item/Deleted"\s*:\s*(true|"true"|"@true")') "PatchItem must set item/Deleted to true."
    Add-Check $Checks "$CapabilityName workflow writes DeletedAt" (($text -match '"item/DeletedAt"\s*:') -and ($text -match 'utcNow\(')) "PatchItem must stamp DeletedAt with current time."
    Add-Check $Checks "$CapabilityName workflow writes DeletedReason" ($text -match '"item/DeletedReason"\s*:') "PatchItem must persist the user-supplied reason."
    Add-Check $Checks "$CapabilityName workflow writes DeletedByUPN" ($text -match '"item/DeletedByUPN"\s*:') "PatchItem must persist the deleting user's UPN."

    if ($CapabilityName -eq "ExcluirTarefa") {
        $hasProjectInput = ($text -match '"text_2"\s*:') -and ($text -match '"title"\s*:\s*"NomeProjeto"')
        $looksUpRequestedProject = ($text -match "Get_Projeto_Solicitado") -and ($text -match '"table"\s*:\s*"Projetos"') -and ($text -match "NomeProjeto eq") -and ($text -match "ProjectID eq")
        $validatesTaskProjectScope = ($text -match "Condition_Tarefa_Ativa") -and ($text -match [regex]::Escape("body('Get_Tarefa_Atual')?['ProjectID']")) -and ($text -match [regex]::Escape("body('Get_Projeto_Solicitado')?['value']?[0]?['ProjectID']"))
        $hasMismatchBusinessResponse = ($text -match "TASK_PROJECT_MISMATCH_OR_INACTIVE") -and ($text -match "Response_Task_Project_Mismatch")
        $taskNotFoundIsBusinessResponse = ($text -match '(?s)Response_Task_Not_Found.*?"statusCode"\s*:\s*200')
        $mismatchIsBusinessResponse = ($text -match '(?s)Response_Task_Project_Mismatch.*?"statusCode"\s*:\s*200')

        Add-Check $Checks "$CapabilityName workflow accepts project scope input" $hasProjectInput "Flow trigger must receive NomeProjeto/ProjectID from the topic."
        Add-Check $Checks "$CapabilityName workflow looks up requested project" $looksUpRequestedProject "Flow must resolve the user-provided project before updating any task."
        Add-Check $Checks "$CapabilityName workflow validates task belongs to project" $validatesTaskProjectScope "Flow must compare Tarefas.ProjectID against the resolved Projetos.ProjectID."
        Add-Check $Checks "$CapabilityName workflow has scope mismatch business response" $hasMismatchBusinessResponse "Mismatched, deleted, or inactive task/project pairs must not soft-delete."
        Add-Check $Checks "$CapabilityName workflow returns 200 for task-not-found business block" $taskNotFoundIsBusinessResponse "Controlled business blocks should reach Copilot as messages, not FlowRequestFailure."
        Add-Check $Checks "$CapabilityName workflow returns 200 for scope mismatch business block" $mismatchIsBusinessResponse "Controlled scope blocks should reach Copilot as messages, not FlowRequestFailure."
    }
}

function Test-ConfirmationTopic {
    param(
        [System.Collections.Generic.List[object]]$Checks,
        [string]$CapabilityName,
        [pscustomobject]$Topic
    )

    $text = $Topic.Text
    $hasConfirmationQuestion = ($text -match '(?ms)kind:\s*Question.*?(Confirmacao|Confirmar|confirm_)') -and ($text -match '(?i)confirma|confirmar|confirmo')
    $hasAffirmativeBranch = ($text -match '(?i)confirm_branch|confirmed|confirmado') -and ($text -match '"sim"') -and ($text -match '"confirmo"')
    $hasActionCall = ($text -match "(?ms)dialog:\s*pmo_AssistentePMO(?:_V2|_Clean)?\.action\.PMO_PA_$([regex]::Escape($CapabilityName))") -or ($text -match "(?ms)kind:\s*InvokeFlowAction.*?flowId:")
    $hasMessageOutputBinding = $text -match "(?ms)kind:\s*InvokeFlowAction.*?output:\s*\r?\n\s*binding:\s*\r?\n\s*message:\s*Topic\.([A-Za-z0-9_]+)"
    $messageOutputVariable = if ($hasMessageOutputBinding) { [regex]::Match($text, "(?ms)kind:\s*InvokeFlowAction.*?output:\s*\r?\n\s*binding:\s*\r?\n\s*message:\s*Topic\.([A-Za-z0-9_]+)").Groups[1].Value } else { "" }
    $sendsBoundFlowMessage = $hasMessageOutputBinding -and ($text -match [regex]::Escape("activity: ""{Topic.$messageOutputVariable}"""))
    $hasStaleResultReference = $text -match "Topic\.$([regex]::Escape($CapabilityName))Result"

    Add-Check $Checks "$CapabilityName topic exists" $true $Topic.DataPath
    Add-Check $Checks "$CapabilityName topic asks explicit confirmation" $hasConfirmationQuestion "Topic must ask for confirmation before invoking the delete flow."
    Add-Check $Checks "$CapabilityName topic gates action behind affirmative branch" $hasAffirmativeBranch "Topic must require explicit affirmative text such as sim/confirmo."
    Add-Check $Checks "$CapabilityName topic calls PMO_PA_$CapabilityName action or bound flow" $hasActionCall "Confirmed branch must call the capability action component or direct bound workflow."
    Add-Check $Checks "$CapabilityName topic has valid message output binding when present" ((-not $hasMessageOutputBinding) -or $sendsBoundFlowMessage) "If a delete topic binds output.message, it must send that exact bound variable so business-rule blocks are visible to the user."
    Add-Check $Checks "$CapabilityName topic has no stale Topic result reference" (-not $hasStaleResultReference) "Delete topics must send a stable confirmation message instead of referencing a removed flow output variable."
    Add-Check $Checks "$CapabilityName topic does not expose physical delete wording as implementation" ($text -notmatch '(?i)DeleteItem|Remove-PnPListItem|"\s*method\s*:\s*"DELETE"') "Topic must route to soft-delete action only."

    if ($CapabilityName -eq "ExcluirTarefa") {
        $hasDelimitedMotivoParser = $text -match 'motivo\\s\*\[:=\]\\s\*'
        $hasInlineMotivoLabelParser = $text -match 'motivo\\s\+'
        $hasTrailingReasonParser = ($text -match '\(\?:excluir\|remover\|apagar\|cancelar\|arquivar\)') -and
            ($text -match '\(\?:tarefa\|linha\)') -and
            ($text -match '\(\?<v>\.\+\?\)')

        Add-Check $Checks "$CapabilityName topic parses motivo with colon or equals" $hasDelimitedMotivoParser "Parser must keep support for motivo: texto and motivo=texto."
        Add-Check $Checks "$CapabilityName topic parses inline motivo label" $hasInlineMotivoLabelParser "Parser must support commands like excluir tarefa 5 motivo registro duplicado."
        Add-Check $Checks "$CapabilityName topic parses trailing inline reason" $hasTrailingReasonParser "Parser must support commands like excluir tarefa 5 registro duplicado without asking for motivo again."

        $hasProjectParser = $text -match "parse_project_name" -and $text -match "Topic\.ProjectName"
        $passesProjectToFlow = $text -match "text_2:\s*=Topic\.ProjectName"
        $showsAuthoritativeFlowMessage = $hasMessageOutputBinding -and $sendsBoundFlowMessage

        Add-Check $Checks "$CapabilityName topic parses project scope" $hasProjectParser "Topic must collect the project name so the flow can validate task scope."
        Add-Check $Checks "$CapabilityName topic passes project scope to flow" $passesProjectToFlow "ExcluirTarefa must pass project name or ProjectID to the flow."
        Add-Check $Checks "$CapabilityName topic shows authoritative flow result" $showsAuthoritativeFlowMessage "Topic must show the flow result instead of always saying the task was removed."
    }
}

try {
    $resolvedRoot = Resolve-SolutionSourceRoot -SourcePath $SolutionSourcePath -ZipPath $PackagePath
    $workflowRoot = Join-Path $resolvedRoot "Workflows"
    $botComponentRoot = Join-Path $resolvedRoot "botcomponents"

    $checks = [System.Collections.Generic.List[object]]::new()
    $workflowFiles = @(Get-ChildItem -LiteralPath $workflowRoot -Filter "*.json" -File)
    $solutionTextFiles = @(Get-ChildItem -LiteralPath $resolvedRoot -Recurse -File | Where-Object {
            $_.Extension -in @(".json", ".xml", ".txt", ".yaml", ".yml") -or $_.Name -eq "data"
        })

    $destructiveFiles = @()
    foreach ($file in $solutionTextFiles) {
        $text = Get-Content -LiteralPath $file.FullName -Raw
        if ($text -match '(?i)"operationId"\s*:\s*"DeleteItem"|"\s*method\s*:\s*"DELETE"|deleteobject|recycle|Remove-PnPListItem') {
            $destructiveFiles += $file.FullName
        }
    }
    Add-Check $checks "Solution has no physical DeleteItem/DELETE implementation" ($destructiveFiles.Count -eq 0) ($destructiveFiles -join "; ")

    $capabilities = @(
        @{ Name = "ExcluirProjeto"; List = "Projetos" },
        @{ Name = "ExcluirTarefa"; List = "Tarefas" }
    )

    foreach ($capability in $capabilities) {
        $name = $capability.Name
        $workflows = @(Get-NamedWorkflow -WorkflowFiles $workflowFiles -CapabilityName $name)
        Add-Check $checks "$name workflow exists" ($workflows.Count -eq 1) ("Matches: " + (($workflows | ForEach-Object { $_.File.FullName }) -join "; "))

        if ($workflows.Count -eq 1) {
            Test-SoftDeleteWorkflow -Checks $checks -CapabilityName $name -ExpectedList $capability.List -Workflow $workflows[0]
        }

        $topics = @(Get-NamedTopic -BotComponentRoot $botComponentRoot -CapabilityName $name)
        Add-Check $checks "$name topic has one component" ($topics.Count -eq 1) ("Matches: " + (($topics | ForEach-Object { $_.DataPath }) -join "; "))

        if ($topics.Count -eq 1) {
            Test-ConfirmationTopic -Checks $checks -CapabilityName $name -Topic $topics[0]
        }
    }

    $failed = @($checks | Where-Object { -not $_.passed })
    $result = [ordered]@{
        solutionSourcePath = $resolvedRoot
        packagePath = $PackagePath
        passed = ($failed.Count -eq 0)
        failedCheckCount = $failed.Count
        checks = $checks
    }

    $result | ConvertTo-Json -Depth 10

    if ($failed.Count -gt 0) {
        throw "Excluir soft-delete capability test failed: $($failed.name -join '; ')"
    }
}
finally {
    if ($tempRoot -and (Test-Path -LiteralPath $tempRoot)) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
