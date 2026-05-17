# AQ-04 Graph Planner Discovery Attempt

Date: 2026-05-15
Owner: CODEX-LEAD
Scope: Read-only Planner plan/bucket discovery using Microsoft.Graph PowerShell
Release decision: NO-SHIP
Tenant writes: None

## 1. Owner Approval Context

Owner provided:

```text
C:\Users\dataops-lab\Downloads\Guia_Consolidado_PowerPlatform_Planner_Graph_2026.md
```

Owner then approved trying:

```text
Graph / Microsoft.Graph PowerShell
```

This supersedes the previous local P0 access restriction for this AQ-04 read-only discovery attempt only. No Planner writes, bucket changes, SharePoint writes, flow saves, imports, publishes, or Teams posts were authorized.

## 2. Intended Read-Only Queries

Target tenant:

```text
7808e005-1489-4374-954b-d3b08f193920
```

Target group:

```text
96c5b0c4-46cc-46cd-8695-50451db74994
```

Candidate plan:

```text
-1kBj1PLv0qQM-R4PwkqbpcABv_P
```

Intended Graph calls after authentication:

```http
GET https://graph.microsoft.com/v1.0/groups/96c5b0c4-46cc-46cd-8695-50451db74994/planner/plans
GET https://graph.microsoft.com/v1.0/planner/plans/-1kBj1PLv0qQM-R4PwkqbpcABv_P/buckets
GET https://graph.microsoft.com/v1.0/planner/plans/-1kBj1PLv0qQM-R4PwkqbpcABv_P/tasks
```

Required delegated scopes:

```text
Group.Read.All
Tasks.Read
```

## 3. Attempts and Results

| Step | Command / Path | Result |
|---|---|---|
| Microsoft.Graph module check | `Get-Module Microsoft.Graph.Authentication -ListAvailable` | PASS: version `2.34.0` installed |
| Existing Graph context | `Get-MgContext` | No active context |
| Azure CLI Graph token | `az account get-access-token --tenant 7808e005-1489-4374-954b-d3b08f193920 --resource https://graph.microsoft.com/` | FAIL: refresh token expired or invalid due to conditional access sign-in frequency |
| Microsoft.Graph device code | `Connect-MgGraph -TenantId ... -Scopes Group.Read.All,Tasks.Read -UseDeviceCode -ContextScope Process` | BLOCKED: device-code prompt produced a code, but no owner authentication completed before timeout |
| Microsoft.Graph browser/WAM | `Connect-MgGraph -TenantId ... -Scopes Group.Read.All,Tasks.Read -ContextScope Process` | FAIL: `InteractiveBrowserCredential authentication failed: A window handle must be configured` |

## 4. Outcome

No Planner IDs were retrieved in this attempt because no valid delegated Graph authentication context was available inside the Codex shell.

This is an authentication/session blocker, not a Planner API design blocker.

The Graph path remains viable once the owner establishes an authenticated Microsoft.Graph context or Azure CLI Graph token for tenant `7808e005-1489-4374-954b-d3b08f193920`.

## 5. Owner-Side Unblock Options

Option A: owner runs this locally in an interactive PowerShell session:

```powershell
Import-Module Microsoft.Graph.Authentication
Connect-MgGraph -TenantId "7808e005-1489-4374-954b-d3b08f193920" -Scopes "Group.Read.All","Tasks.Read" -ContextScope CurrentUser
```

Then CODEX can retry the read-only Graph queries.

Option B: owner refreshes Azure CLI auth for Graph:

```powershell
az login --tenant "7808e005-1489-4374-954b-d3b08f193920" --scope "https://graph.microsoft.com//.default"
```

Then CODEX can request a Graph token and run the read-only queries.

Option C: owner runs the prepared read-only AQ-04 script in the same PowerShell session where `Connect-MgGraph` succeeded:

```powershell
Get-MgContext
.\.planning\comms\planner_discovery_aq04_20260515\Get-PlannerAq04ReadOnly.ps1
```

Expected evidence outputs:

```text
.planning/comms/planner_discovery_aq04_20260515/graph_planner_summary.json
.planning/comms/planner_discovery_aq04_20260515/graph_planner_plans.json
.planning/comms/planner_discovery_aq04_20260515/graph_planner_buckets.json
.planning/comms/planner_discovery_aq04_20260515/graph_planner_tasks.json
.planning/comms/planner_discovery_aq04_20260515/graph_planner_bucket_mapping.csv
.planning/comms/planner_discovery_aq04_20260515/graph_planner_tasks.csv
```

CODEX attempted to run the prepared script in its own shell after owner login, but `Get-MgContext` still returned no context in the Codex process. This indicates the owner-authenticated session is not shared with Codex's separate command process.

## 6. Current AQ-04 Status

```text
BLOCKED_ON_INTERACTIVE_GRAPH_AUTH
```

No tenant writes were performed.
