# CODEX 5.5 #2 SUB-C — M2 Phase 1 — Track G: Cleanup Script Generation

**Agent ID:** CODEX-2-SUB-C
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT.

---

## Governance — MANDATORY

1. Read `governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN as `CODEX-2-SUB-C`
3. HEARTBEAT every 5 min
4. CHECK-OUT + HANDOFF when done

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/cleanup/sharepoint_test_data_candidates_20260510_105502.md
.planning/SHAREPOINT_ACCESS_RUNBOOK.md
.planning/AGENT_CONTRACT.md
```

---

## Hard Constraints

- READ-ONLY operations only — generate the cleanup script but DO NOT EXECUTE IT.
- Output to `phases/01_discovery/G_test_data_cleanup/`.
- FILE LOCK before write.
- The script must default to `-WhatIf` mode (dry run). Owner runs `-Confirm` later.

---

## Dependencies

This task depends on CODEX-1-SUB-B Track B.3 output (`test_data_residual_candidates.json`). Wait for B.3 DONE in HANDOFF_LOG before starting.

---

## Tasks

### Task G.1 — Cleanup Candidates Final List

After B.3 DONE:
1. Read `phases/01_discovery/B_sharepoint_inventory/test_data_residual_candidates.json`
2. Cross-reference with `.planning/cleanup/sharepoint_test_data_candidates_20260510_105502.md` (M1 baseline cleanup record)
3. Identify NEW candidates (created/modified post-2026-05-13) that need cleanup before M2 publish
4. Output `cleanup_candidates_final.json` with explicit owner-confirm list

```json
{
  "total_candidates": 47,
  "by_list": {
    "Projetos": [
      {
        "Id": 33,
        "Title": "QA Robust 20260513 F",
        "ProjectID": "PRJ-274E5ACC",
        "Modified": "2026-05-13T17:35:00Z",
        "match_pattern": "QA in title",
        "owner_confirm_status": "pre_approved (M1 active QA project, expected cleanup target)"
      }
    ],
    "Tarefas": [...],
    "Status Diario": [...],
    "Riscos e Bloqueios": [...],
    "Decisoes do Board": [...]
  },
  "exclusions": [
    {
      "list": "Projetos",
      "rule": "Title contains 'PROD' OR ProjectID starts with 'LIVE-'",
      "reason": "production data — never auto-clean"
    }
  ]
}
```

### Task G.2 — Generate Cleanup PowerShell Script

Generate `Cleanup-TestData-M2.ps1` with these properties:

**Default behavior:**
- Runs in `-WhatIf` mode unless `-Confirm` passed
- Logs every candidate to `cleanup_log_<timestamp>.txt`
- Soft-delete only (`Set-PnPListItem -Values @{Deleted=1; DeletedAt=...; DeletedReason=...; DeletedByUPN=...}`)
- NEVER physical delete (no `Remove-PnPListItem`)
- Dry-run output shows exact items that WOULD be soft-deleted

**Script structure:**

```powershell
<#
.SYNOPSIS
    M2 cleanup — soft-delete test data residuals before M2 publish.

.DESCRIPTION
    Reads cleanup_candidates_final.json and applies Deleted=Yes to each item.
    Default: dry-run (-WhatIf). Use -Confirm to execute writes.

.PARAMETER Confirm
    Switch. If present, executes actual SharePoint writes. Otherwise dry-run.

.PARAMETER CandidatesFile
    Path to cleanup_candidates_final.json. Default: ./cleanup_candidates_final.json

.PARAMETER LogFile
    Path to log output. Default: ./cleanup_log_<timestamp>.txt

.EXAMPLE
    .\Cleanup-TestData-M2.ps1 -WhatIf
    .\Cleanup-TestData-M2.ps1 -Confirm
#>
param(
    [switch]$Confirm,
    [string]$CandidatesFile = ".\cleanup_candidates_final.json",
    [string]$LogFile = ".\cleanup_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
)

# 1. Load candidates
# 2. Connect-PnPOnline -Url $siteUrl -UseWebLogin
# 3. For each candidate:
#    - If -Confirm: Set-PnPListItem with Deleted=1 + audit fields + log
#    - Else: log "[DRY-RUN] Would soft-delete <list> item <Id>: <Title>"
# 4. Summary: total processed, total soft-deleted (or would-soft-delete), errors
# 5. Exit code 0 on success
```

Include:
- Robust error handling (per-item try/catch, continue on error)
- DeletedReason auto-populated: "M2 cleanup pre-publish — test data residual"
- DeletedByUPN auto-populated from `pnpconnection.Url` resolution

### Task G.3 — Cleanup Plan Documentation

Write `INVENTORY_CLEANUP_PLAN.md` containing:
- Per-list strategy
- Risk assessment (any item that should NOT be cleaned even if matches pattern)
- Expected cleanup timing (Phase 6)
- Owner approval required: yes (must run `-Confirm` manually)
- Rollback: items have `Deleted=No` → can be restored by removing the Deleted flag

---

## Deliverables

```
phases/01_discovery/G_test_data_cleanup/
├── cleanup_candidates_final.json
├── Cleanup-TestData-M2.ps1
└── INVENTORY_CLEANUP_PLAN.md
```

---

## Time Budget

45 min total. Wait for Track B.3 DONE before starting (estimated ~30 min into Phase 1).

---

## Coordination

- Wait for HANDOFF from CODEX-1-SUB-B (Track B DONE)
- After your DONE, post HANDOFF_LOG entry: cleanup kit ready for Phase 6 use

---

## Begin

1. CHECK-IN per protocol
2. Read 7 references
3. Wait for Track B HANDOFF
4. Execute G.1 → G.2 → G.3
5. CHECK-OUT + HANDOFF
