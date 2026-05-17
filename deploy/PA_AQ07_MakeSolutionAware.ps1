[CmdletBinding()]
param(
    [string]$EnvironmentName = "e2d10003-4d8e-e007-9d63-76d5fe89ef56",
    [string]$SolutionId = "fd140aaf-4df4-11dd-bd17-0019b9312238",
    [string]$EvidenceDir = ".planning\comms"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $repoRoot

$adminModule = "C:\Users\dataops-lab\Documents\WindowsPowerShell\Modules\Microsoft.PowerApps.Administration.PowerShell\2.0.217\Microsoft.PowerApps.Administration.PowerShell.psd1"
$powerAppsModule = "C:\Users\dataops-lab\Documents\PowerShell\Modules\Microsoft.PowerApps.PowerShell\1.0.45\Microsoft.PowerApps.PowerShell.psd1"

Import-Module $adminModule -ErrorAction Stop
Import-Module $powerAppsModule -ErrorAction Stop

$evidenceRoot = Join-Path $repoRoot $EvidenceDir
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$flows = @(
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_ResumoExecutivoPortfolio"; FlowName = "b4df90ec-a721-44cf-adbd-a5ced1d7f9f7" },
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_AtualizarStatus"; FlowName = "b7678a81-df01-4070-b6db-3c0dbcc7f924" },
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_ListarTarefas"; FlowName = "c9e44878-77ed-4b17-9b6f-0bab008a0587" },
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_CriarTarefa"; FlowName = "76146280-a6c2-4068-8a3f-3310e3e9210f" },
    [pscustomobject]@{ DisplayName = "PM0_PA_Card_AtualizarTarefa"; FlowName = "36142fd3-9f83-4d4f-81e2-748ded919a92" },
    [pscustomobject]@{ DisplayName = "PM0_PA_OpsFailureHandling"; FlowName = "2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441" }
)

$results = @()
foreach ($flowRef in $flows) {
    Write-Host "Making flow solution-aware: $($flowRef.DisplayName) ($($flowRef.FlowName))"
    
    $setOutput = $null
    try {
        $setOutput = Set-FlowAsSolutionAware -EnvironmentName $EnvironmentName -FlowName $flowRef.FlowName -SolutionId $SolutionId *>&1 | Out-String
    }
    catch {
        $setOutput = $_.Exception.Message
    }

    Start-Sleep -Seconds 4
    $flow = Get-Flow -EnvironmentName $EnvironmentName -FlowName $flowRef.FlowName -ErrorAction Stop
    
    $obj = [pscustomobject]@{
        DisplayName = $flowRef.DisplayName
        FlowName = $flowRef.FlowName
        Enabled = $flow.Enabled
        State = $flow.Internal.properties.state
        WorkflowEntityId = $flow.Internal.properties.workflowEntityId
        SolutionAwareOutput = if ($setOutput) { $setOutput.Trim() } else { "" }
    }
    $results += $obj
}

$evidenceFile = Join-Path $evidenceRoot "aq07_solutionaware_workflowids_$timestamp.json"
$results | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $evidenceFile -Encoding UTF8

Write-Host "Evidence written to $evidenceFile"
$results | Format-Table DisplayName, FlowName, WorkflowEntityId
