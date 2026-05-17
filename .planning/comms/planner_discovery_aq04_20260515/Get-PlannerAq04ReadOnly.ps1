param(
    [string]$GroupId = "96c5b0c4-46cc-46cd-8695-50451db74994",
    [string]$CandidatePlanId = "-1kBj1PLv0qQM-R4PwkqbpcABv_P",
    [string]$OutputDir = ".planning\comms\planner_discovery_aq04_20260515"
)

$ErrorActionPreference = "Stop"

Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

$context = Get-MgContext
if (-not $context) {
    throw "No Microsoft.Graph context found. Run Connect-MgGraph first in this same PowerShell session."
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

function Save-Json {
    param(
        [Parameter(Mandatory = $true)]
        [object]$Data,
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [int]$Depth = 20
    )

    $Data |
        ConvertTo-Json -Depth $Depth |
        Set-Content -LiteralPath $Path -Encoding UTF8
}

function Invoke-GraphGetAll {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Uri
    )

    $items = New-Object System.Collections.Generic.List[object]
    $next = $Uri

    while ($next) {
        $response = Invoke-MgGraphRequest -Method GET -Uri $next
        if ($response.value) {
            foreach ($item in $response.value) {
                $items.Add($item) | Out-Null
            }
        }
        else {
            $items.Add($response) | Out-Null
        }

        $next = $response.'@odata.nextLink'
    }

    return @($items)
}

$plans = Invoke-GraphGetAll -Uri "https://graph.microsoft.com/v1.0/groups/$GroupId/planner/plans"
$selectedPlan = $plans | Where-Object { $_.id -eq $CandidatePlanId } | Select-Object -First 1
if (-not $selectedPlan -and @($plans).Count -eq 1) {
    $selectedPlan = $plans[0]
}

$planIdForBucketRead = if ($selectedPlan) { $selectedPlan.id } else { $CandidatePlanId }

$buckets = Invoke-GraphGetAll -Uri "https://graph.microsoft.com/v1.0/planner/plans/$planIdForBucketRead/buckets"
$tasks = Invoke-GraphGetAll -Uri "https://graph.microsoft.com/v1.0/planner/plans/$planIdForBucketRead/tasks"

$bucketRows = foreach ($bucket in $buckets) {
    $bucketTasks = @($tasks | Where-Object { $_.bucketId -eq $bucket.id })
    [pscustomobject]@{
        groupId = $GroupId
        planId = $planIdForBucketRead
        planTitle = if ($selectedPlan) { $selectedPlan.title } else { $null }
        bucketName = $bucket.name
        bucketId = $bucket.id
        orderHint = $bucket.orderHint
        taskCount = $bucketTasks.Count
    }
}

$taskRows = foreach ($task in $tasks) {
    $bucket = $buckets | Where-Object { $_.id -eq $task.bucketId } | Select-Object -First 1
    [pscustomobject]@{
        groupId = $GroupId
        planId = $planIdForBucketRead
        planTitle = if ($selectedPlan) { $selectedPlan.title } else { $null }
        bucketName = if ($bucket) { $bucket.name } else { $null }
        bucketId = $task.bucketId
        taskTitle = $task.title
        taskId = $task.id
        percentComplete = $task.percentComplete
        dueDateTime = $task.dueDateTime
    }
}

$summary = [pscustomobject]@{
    timestamp = (Get-Date).ToString("o")
    account = $context.Account
    tenantId = $context.TenantId
    scopes = $context.Scopes
    authType = $context.AuthType
    groupId = $GroupId
    candidatePlanId = $CandidatePlanId
    selectedPlanId = $planIdForBucketRead
    selectedPlanTitle = if ($selectedPlan) { $selectedPlan.title } else { $null }
    planCount = @($plans).Count
    bucketCount = @($buckets).Count
    taskCount = @($tasks).Count
    accessType = "Microsoft.Graph PowerShell read-only"
    tenantWrites = $false
}

Save-Json -Data $summary -Path (Join-Path $OutputDir "graph_planner_summary.json")
Save-Json -Data $plans -Path (Join-Path $OutputDir "graph_planner_plans.json")
Save-Json -Data $buckets -Path (Join-Path $OutputDir "graph_planner_buckets.json")
Save-Json -Data $tasks -Path (Join-Path $OutputDir "graph_planner_tasks.json")

$bucketRows |
    Export-Csv -LiteralPath (Join-Path $OutputDir "graph_planner_bucket_mapping.csv") -NoTypeInformation -Encoding UTF8

$taskRows |
    Export-Csv -LiteralPath (Join-Path $OutputDir "graph_planner_tasks.csv") -NoTypeInformation -Encoding UTF8

$summary
