param(
    [string]$OutputDir = ".planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions",
    [string]$WorkflowInventoryPath = ".planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/workflow_inventory.json"
)

$ErrorActionPreference = "Stop"

$workflowInv = Get-Content -Raw -LiteralPath $WorkflowInventoryPath | ConvertFrom-Json
$flowOrder = @(
    @{ Index = "D.1"; Name = "PMO_PA_AtualizarStatus"; Type = "legacy" },
    @{ Index = "D.2"; Name = "PMO_PA_AtualizarTarefa"; Type = "legacy" },
    @{ Index = "D.3"; Name = "PMO_PA_ConsultarPortfolio"; Type = "legacy" },
    @{ Index = "D.4"; Name = "PMO_PA_ConsultarProjeto"; Type = "legacy" },
    @{ Index = "D.5"; Name = "PMO_PA_CriarProjeto"; Type = "legacy" },
    @{ Index = "D.6"; Name = "PMO_PA_CriarTarefa"; Type = "legacy" },
    @{ Index = "D.7"; Name = "PMO_PA_ExcluirProjeto"; Type = "legacy" },
    @{ Index = "D.8"; Name = "PMO_PA_ExcluirTarefa"; Type = "legacy" },
    @{ Index = "D.9"; Name = "PMO_PA_ListarTarefas"; Type = "legacy" },
    @{ Index = "D.10"; Name = "PMO_PA_PedirDecisaoBot"; Type = "legacy" },
    @{ Index = "D.11"; Name = "PMO_PA_RegistrarBloqueioBot"; Type = "legacy" },
    @{ Index = "D.12"; Name = "PMO_PA_RegistrarRiscoBot"; Type = "legacy" },
    @{ Index = "D.13"; Name = "PM0_PA_Card_AtualizarStatus"; Type = "new" },
    @{ Index = "D.14"; Name = "PM0_PA_Card_AtualizarTarefa"; Type = "new" },
    @{ Index = "D.15"; Name = "PM0_PA_Card_CriarTarefa"; Type = "new" },
    @{ Index = "D.16"; Name = "PM0_PA_Card_ListarTarefas"; Type = "new" },
    @{ Index = "D.17"; Name = "PM0_PA_Card_ResumoExecutivoPortfolio"; Type = "new" },
    @{ Index = "D.18"; Name = "PM0_PA_OpsFailureHandling"; Type = "new" }
)

$allInv = @($workflowInv.legacy_pmo_pa) + @($workflowInv.new_pm0_pa_card)
$runHistories = @()
$rows = @()

foreach ($flow in $flowOrder) {
    $inv = $allInv | Where-Object { $_.name -eq $flow.Name } | Select-Object -First 1
    $defPath = Join-Path $OutputDir "definition_$($flow.Name).json"
    $triggerPath = Join-Path $OutputDir "triggerSchema_$($flow.Name).json"
    $outputPath = Join-Path $OutputDir "outputSchema_$($flow.Name).json"
    $runPath = Join-Path $OutputDir "flow_run_history_30d_$($flow.Name).json"

    foreach ($path in @($defPath, $triggerPath, $outputPath, $runPath)) {
        if (!(Test-Path -LiteralPath $path)) {
            throw "Missing required deliverable: $path"
        }
    }

    $definition = Get-Content -Raw -LiteralPath $defPath | ConvertFrom-Json
    $trigger = Get-Content -Raw -LiteralPath $triggerPath | ConvertFrom-Json
    $outputs = @(Get-Content -Raw -LiteralPath $outputPath | ConvertFrom-Json)
    $run = Get-Content -Raw -LiteralPath $runPath | ConvertFrom-Json
    $runHistories += $run

    $actions = $definition.properties.definition.actions
    $actionProps = @()
    if ($actions) {
        $actionProps = @($actions.PSObject.Properties)
    }

    $connections = @()
    if ($definition.properties.connectionReferences) {
        $connections = @($definition.properties.connectionReferences.PSObject.Properties | ForEach-Object {
            if ($_.Value.api -and $_.Value.api.name) {
                $_.Value.api.name
            }
            else {
                $_.Name
            }
        } | Sort-Object -Unique)
    }

    if ($trigger -is [array]) {
        $triggerOne = $trigger[0]
    }
    else {
        $triggerOne = $trigger
    }

    $required = @()
    if ($triggerOne.schema -and $triggerOne.schema.required) {
        $required = @($triggerOne.schema.required)
    }

    $responseNames = @($outputs | ForEach-Object { $_.responseActionName } | Where-Object { $_ })
    $rows += [pscustomobject]@{
        Index = $flow.Index
        Name = $flow.Name
        WorkflowId = if ($inv) { $inv.workflowid } else { $definition.name }
        Type = $flow.Type
        State = if ($inv) { $inv.state } else { "" }
        Status = if ($inv) { $inv.status } else { "" }
        ModifiedOn = if ($inv) { $inv.modifiedon } else { "" }
        Trigger = @($triggerOne.triggerName, $triggerOne.type, $triggerOne.kind | Where-Object { $_ }) -join " / "
        RequiredInputs = if ($required.Count) { $required -join ", " } else { "-" }
        TopLevelActions = $actionProps.Count
        Connections = if ($connections.Count) { $connections -join ", " } else { "-" }
        Responses = if ($responseNames.Count) { $responseNames -join ", " } else { "-" }
        Runs30d = $run.totalRuns
        Succeeded30d = $run.succeeded
        Failed30d = $run.failed
        DefinitionFile = "definition_$($flow.Name).json"
        TriggerFile = "triggerSchema_$($flow.Name).json"
        OutputFile = "outputSchema_$($flow.Name).json"
        RunHistoryFile = "flow_run_history_30d_$($flow.Name).json"
    }
}

$runHistories | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath (Join-Path $OutputDir "flow_run_history_30d.json") -Encoding UTF8

$definitionCount = (Get-ChildItem -LiteralPath $OutputDir -Filter "definition_*.json").Count
$triggerCount = (Get-ChildItem -LiteralPath $OutputDir -Filter "triggerSchema_*.json").Count
$outputCount = (Get-ChildItem -LiteralPath $OutputDir -Filter "outputSchema_*.json").Count
$runHistoryCount = (Get-ChildItem -LiteralPath $OutputDir -Filter "flow_run_history_30d_*.json" |
    Where-Object { $_.Name -notin @("flow_run_history_30d_CODEX-2-LEAD_batch1.json", "flow_run_history_30d_PM0_batch3.json") }).Count

$md = New-Object System.Collections.Generic.List[string]
$md.Add("# Inventory - Power Automate Flow Definitions")
$md.Add("")
$md.Add("**Agent:** CODEX-2-LEAD")
$md.Add("**Generated:** 2026-05-20T20:10:30-03:00")
$md.Add("**Scope:** Track D, 18 Power Automate flows (12 legacy PMO_PA_* + 6 PM0_PA_*)")
$md.Add('**Tenant:** ColOfertasBrasilPro (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)')
$md.Add("")
$md.Add("## Summary")
$md.Add("")
$md.Add("- Flow definition files: $definitionCount/18")
$md.Add("- Trigger schema files: $triggerCount/18")
$md.Add("- Output schema files: $outputCount/18")
$md.Add("- Per-flow run history files: $runHistoryCount/18")
$md.Add('- Aggregate run history: `flow_run_history_30d.json`')
$md.Add('- PM0 refactor analysis: `PM0_REFACTOR_ANALYSIS.md`')
$md.Add("")
$md.Add("## Master Matrix")
$md.Add("")
$md.Add("| # | Flow | Workflow ID | Type | State | Modified | Trigger | Required inputs | Actions | Connections | Responses | Runs 30d | OK | Fail |")
$md.Add("|---|---|---|---|---|---|---|---|---:|---|---|---:|---:|---:|")

foreach ($row in $rows) {
    $values = @(
        $row.Index, $row.Name, $row.WorkflowId, $row.Type, $row.State, $row.ModifiedOn,
        $row.Trigger, $row.RequiredInputs, [string]$row.TopLevelActions, $row.Connections,
        $row.Responses, [string]$row.Runs30d, [string]$row.Succeeded30d, [string]$row.Failed30d
    ) | ForEach-Object { $_ -replace "\|", "/" }

    $md.Add("| $($values[0]) | ``$($values[1])`` | ``$($values[2])`` | $($values[3]) | $($values[4]) | $($values[5]) | $($values[6]) | $($values[7]) | $($values[8]) | $($values[9]) | $($values[10]) | $($values[11]) | $($values[12]) | $($values[13]) |")
}

$md.Add("")
$md.Add("## Deliverable Files")
$md.Add("")
$md.Add("| # | Definition | Trigger schema | Output schema | Run history |")
$md.Add("|---|---|---|---|---|")

foreach ($row in $rows) {
    $md.Add(('| {0} | `{1}` | `{2}` | `{3}` | `{4}` |' -f $row.Index, $row.DefinitionFile, $row.TriggerFile, $row.OutputFile, $row.RunHistoryFile))
}

$md.Add("")
$md.Add("## Notes")
$md.Add("")
$md.Add('- `pac org fetch --xml` raised `System.Xml.XmlException`; extraction used read-only `pac org fetch --xmlFile` instead.')
$md.Add('- `workflow.outputparameters` is not available on the Dataverse `workflow` entity in this tenant; output schemas were extracted from Response actions inside `clientdata.properties.definition.actions`.')
$md.Add('- Run histories were captured with `Get-FlowRun` using workflow GUIDs and summarized without signed content links.')
$md.Add("- CODEX-2-SUB-C Track G is separate from Track D and is blocked on CODEX-1-SUB-B B.3; this does not block the flow definition inventory.")

($md -join "`r`n") | Set-Content -LiteralPath (Join-Path $OutputDir "INVENTORY_FLOW_DEFINITIONS.md") -Encoding UTF8

"Consolidated $($rows.Count) flows"
