[CmdletBinding()]
param(
    [string]$SourceRoot = "Local_Repo\Assistente PMO V2",
    [string]$ReportPath = ""
)

$ErrorActionPreference = "Stop"

$resolvedRoot = (Resolve-Path -LiteralPath $SourceRoot).Path
$workflowsRoot = Join-Path $resolvedRoot "workflows"

$targets = @(
    [ordered]@{ action = "PM0_PA_Card_AtualizarStatus"; workflowId = "1721e0a3-a250-f111-bec7-000d3abc5cc6"; placeholder = "Status update card posted successfully."; requiresBackendData = $true },
    [ordered]@{ action = "PM0_PA_Card_AtualizarTarefa"; workflowId = "7c6300c2-a250-f111-bec7-000d3abc5cc6"; placeholder = "Task updated successfully."; requiresBackendData = $true },
    [ordered]@{ action = "PM0_PA_Card_ResumoExecutivoPortfolio"; workflowId = "8333bd91-a250-f111-bec7-000d3abc5cc6"; placeholder = "Executive portfolio retrieved successfully."; requiresBackendData = $true },
    [ordered]@{ action = "PM0_PA_Card_CriarTarefa"; workflowId = "7f662db7-a250-f111-bec7-000d3abc5cc6"; placeholder = "Task created successfully."; requiresBackendData = $true },
    [ordered]@{ action = "PM0_PA_Card_ListarTarefas"; workflowId = "e0e3c6b0-a250-f111-bec7-000d3abc5cc6"; placeholder = "Tasks retrieved successfully."; requiresBackendData = $true }
)

$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param([string]$Name, [bool]$Passed, [string]$Evidence)
    $checks.Add([ordered]@{ name = $Name; passed = $Passed; evidence = $Evidence }) | Out-Null
}

function Get-WorkflowFile {
    param([string]$ActionName, [string]$WorkflowId)
    $path = Join-Path $workflowsRoot "$ActionName-$WorkflowId\workflow.json"
    if (Test-Path -LiteralPath $path) {
        return Get-Item -LiteralPath $path
    }

    @(Get-ChildItem -LiteralPath $workflowsRoot -Directory -Filter "$ActionName-*") |
        Select-Object -First 1 |
        ForEach-Object { Get-Item -LiteralPath (Join-Path $_.FullName "workflow.json") }
}

function Get-WorkflowActionObjects {
    param([object]$Actions)

    $found = [System.Collections.Generic.List[object]]::new()
    if (-not $Actions) {
        return @()
    }

    foreach ($property in $Actions.PSObject.Properties) {
        $action = $property.Value
        $found.Add([ordered]@{ name = $property.Name; action = $action }) | Out-Null

        if ($action.actions) {
            foreach ($child in Get-WorkflowActionObjects -Actions $action.actions) {
                $found.Add($child) | Out-Null
            }
        }

        if ($action.else -and $action.else.actions) {
            foreach ($child in Get-WorkflowActionObjects -Actions $action.else.actions) {
                $found.Add($child) | Out-Null
            }
        }

        if ($action.cases) {
            foreach ($case in $action.cases.PSObject.Properties) {
                if ($case.Value.actions) {
                    foreach ($child in Get-WorkflowActionObjects -Actions $case.Value.actions) {
                        $found.Add($child) | Out-Null
                    }
                }
            }
        }
    }

    @($found)
}

function Test-DynamicResult {
    param([string]$Result)

    if ([string]::IsNullOrWhiteSpace($Result)) {
        return $false
    }

    return ($Result -match "@\{|outputs\(|body\(|triggerBody\(|items\(|variables\(|concat\(")
}

foreach ($target in $targets) {
    $workflowFile = Get-WorkflowFile -ActionName $target.action -WorkflowId $target.workflowId
    Add-Check "$($target.action) workflow file exists" ($null -ne $workflowFile) ($workflowFile.FullName)
    if ($null -eq $workflowFile) {
        continue
    }

    $workflowText = Get-Content -LiteralPath $workflowFile.FullName -Raw -Encoding UTF8
    $workflow = $null
    try {
        $workflow = $workflowText | ConvertFrom-Json
        Add-Check "$($target.action) workflow JSON parses" $true $workflowFile.FullName
    }
    catch {
        Add-Check "$($target.action) workflow JSON parses" $false $_.Exception.Message
        continue
    }

    $allActions = @(Get-WorkflowActionObjects -Actions $workflow.properties.definition.actions)
    $responseActions = @($allActions | Where-Object { $_.action.type -eq "Response" -or $_.action.kind -eq "Skills" })
    $backendActions = @($allActions | Where-Object {
        $serialized = $_.action | ConvertTo-Json -Depth 20 -Compress
        $serialized -match "shared_sharepointonline|shared_planner"
    })

    Add-Check "$($target.action) has a Skills response action" ($responseActions.Count -gt 0) "At least one Response action must return output to Copilot Studio."
    if ($target.requiresBackendData) {
        Add-Check "$($target.action) has SharePoint or Planner lineage" ($backendActions.Count -gt 0) "Release-scoped PM0 flow must derive caller-visible result from PMO backend data or side effect."
    }

    foreach ($response in $responseActions) {
        $result = [string]$response.action.inputs.body.result
        $isPlaceholder = $result -eq $target.placeholder
        Add-Check "$($target.action) response $($response.name) is not audited placeholder" (-not $isPlaceholder) "Observed result: $result"
        Add-Check "$($target.action) response $($response.name) is dynamic or feature-derived" (Test-DynamicResult -Result $result) "Static success-only text cannot prove PMO data/output semantics: $result"
    }
}

$failed = @($checks | Where-Object { -not $_.passed })
$result = [ordered]@{
    sourceRoot = $resolvedRoot
    generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss zzz")
    passed = ($failed.Count -eq 0)
    failedCheckCount = $failed.Count
    checks = $checks
}

$json = $result | ConvertTo-Json -Depth 12
if ($ReportPath) {
    $parent = Split-Path -Parent $ReportPath
    if ($parent) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $ReportPath -Value $json -Encoding UTF8
}

$json

if ($failed.Count -gt 0) {
    throw "PM0 workflow response semantics test failed: $($failed.name -join '; ')"
}
