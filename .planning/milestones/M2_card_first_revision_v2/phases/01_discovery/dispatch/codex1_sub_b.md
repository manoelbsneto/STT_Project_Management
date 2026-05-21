# CODEX 5.5 #1 SUB-B — M2 Phase 1 — Track B: SharePoint Inventory

**Agent ID:** CODEX-1-SUB-B
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery
**SP site:** https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT. Use ONLY:
1. This prompt
2. Files in `Mandatory Read-Before-Start`
3. Live SharePoint site via PnP read-only

---

## Governance — MANDATORY (governance kit added 2026-05-20 18:14)

1. Read `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN to `governance/ACTIVITY_LOG.md` + `governance/CHECKIN_BOARD.md` as `CODEX-1-SUB-B`
3. HEARTBEAT every 5 min
4. FILE LOCK before writes (in `governance/FILE_LOCK_TABLE.md`)
5. CHECK-OUT + HANDOFF when done (notify CODEX-2-SUB-C that B.3 is ready for G dependency)

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/SHAREPOINT_ACCESS_RUNBOOK.md
.planning/AGENT_CONTRACT.md
docs/SCHEMA_SHAREPOINT_PMO.md
```

Confirm in first response that all 6 were read.

---

## Hard Constraints

- Read-only via PnP. Use **Windows PowerShell 5.1 + SharePointPnPPowerShellOnline 3.29.2101.0 + Connect-PnPOnline -UseWebLogin**.
- No item writes, no schema mutations, no view changes.
- Login + queries must run in the same PowerShell process.
- Output to `phases/01_discovery/B_sharepoint_inventory/`.
- Update check-in board every 5 minutes.

---

## Tasks

### Task B.1 — All 5 List Schemas

```powershell
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
Connect-PnPOnline -Url $siteUrl -UseWebLogin

$lists = @("Projetos", "Tarefas", "Status Diario", "Riscos e Bloqueios", "Decisoes do Board")

foreach ($listName in $lists) {
  $list = Get-PnPList -Identity $listName -Includes Fields,Views

  $fieldsExport = $list.Fields | Where-Object { -not $_.Hidden } | Select-Object @{
    n="InternalName"; e={$_.InternalName}
  }, @{
    n="Title"; e={$_.Title}
  }, @{
    n="TypeAsString"; e={$_.TypeAsString}
  }, @{
    n="Required"; e={$_.Required}
  }, @{
    n="DefaultValue"; e={$_.DefaultValue}
  }, @{
    n="Choices"; e={ if ($_.Choices) { $_.Choices } else { @() } }
  }, @{
    n="ReadOnly"; e={$_.ReadOnlyField}
  }

  $viewsExport = $list.Views | Select-Object @{
    n="Title"; e={$_.Title}
  }, @{
    n="ViewQuery"; e={$_.ViewQuery}
  }, @{
    n="ViewFields"; e={ $_.ViewFields }
  }

  $fieldsExport | ConvertTo-Json -Depth 5 | Out-File "phases/01_discovery/B_sharepoint_inventory/$($listName.Replace(' ','_')).fields.json"
  $viewsExport | ConvertTo-Json -Depth 5 | Out-File "phases/01_discovery/B_sharepoint_inventory/$($listName.Replace(' ','_')).views.json"
}
```

Then write `INVENTORY_SP_SCHEMA.md` containing one section per list with:
- Total fields (visible)
- Required fields
- Choice fields with options
- Lookup fields with target list
- Calculated fields with formula
- Views count + names

### Task B.2 — Item Counts + Soft-Delete State

```powershell
$counts = @{}

foreach ($listName in $lists) {
  $totalItems = (Get-PnPListItem -List $listName -PageSize 5000 -Fields Id).Count
  $deletedItems = (Get-PnPListItem -List $listName -Query "<View><Query><Where><Eq><FieldRef Name='Deleted'/><Value Type='Boolean'>1</Value></Eq></Where></Query></View>").Count
  $activeItems = $totalItems - $deletedItems

  $lastWriteCAML = "<View><Query><OrderBy><FieldRef Name='Modified' Ascending='FALSE'/></OrderBy></Query><RowLimit>1</RowLimit></View>"
  $lastItem = Get-PnPListItem -List $listName -Query $lastWriteCAML
  $lastWrite = $lastItem[0]["Modified"]

  $counts[$listName] = @{
    total = $totalItems
    active = $activeItems
    deleted = $deletedItems
    last_write = $lastWrite
  }
}

$counts | ConvertTo-Json -Depth 3 | Out-File "phases/01_discovery/B_sharepoint_inventory/list_counts.json"
```

Write `INVENTORY_SP_DATA_STATE.md` with the table and analysis.

### Task B.3 — Test Data Residual Identification

For dates 2026-05-10 and 2026-05-13, identify all items that look like test data.

Patterns to scan (case-insensitive):
- Title contains "QA"
- Title contains "Teste"
- Title contains "test"
- Title contains "Validar status choice"
- Title contains "Mobile App Corporativo"
- ProjectID matches `PRJ-274E5ACC` (known QA project)
- Modified date between 2026-05-10 and 2026-05-13
- Deleted=No (active items)

```powershell
foreach ($listName in $lists) {
  $candidates = Get-PnPListItem -List $listName -Query @"
<View>
  <Query>
    <Where>
      <And>
        <Eq><FieldRef Name='Deleted'/><Value Type='Boolean'>0</Value></Eq>
        <Or>
          <Contains><FieldRef Name='Title'/><Value Type='Text'>QA</Value></Contains>
          <Contains><FieldRef Name='Title'/><Value Type='Text'>Teste</Value></Contains>
          <Contains><FieldRef Name='Title'/><Value Type='Text'>test</Value></Contains>
        </Or>
      </And>
    </Where>
  </Query>
</View>
"@

  # Save as test_data_residual_<list>.json
}
```

Output `test_data_residual_candidates.json`:

```json
{
  "Projetos": [
    { "Id": 33, "Title": "QA Robust 20260513 F", "Modified": "...", "Created": "..." },
    ...
  ],
  "Tarefas": [...],
  "Status Diario": [...],
  "Riscos e Bloqueios": [...],
  "Decisoes do Board": [...]
}
```

Write `INVENTORY_TEST_RESIDUALS.md` summarizing:
- Total residual count per list
- Strategy for cleanup (soft-delete via Deleted=Yes, never physical delete)
- Owner-confirmed candidates highlighted

---

## Deliverables

```
phases/01_discovery/B_sharepoint_inventory/
├── Projetos.fields.json
├── Projetos.views.json
├── Tarefas.fields.json
├── Tarefas.views.json
├── Status_Diario.fields.json
├── Status_Diario.views.json
├── Riscos_e_Bloqueios.fields.json
├── Riscos_e_Bloqueios.views.json
├── Decisoes_do_Board.fields.json
├── Decisoes_do_Board.views.json
├── list_counts.json
├── test_data_residual_candidates.json
├── INVENTORY_SP_SCHEMA.md
├── INVENTORY_SP_DATA_STATE.md
└── INVENTORY_TEST_RESIDUALS.md
```

---

## Time Budget

60 minutes hard limit.

---

## Coordination

When DONE, post in check-in board: "Track B DONE — [link]". CODEX-1-LEAD validates.

CODEX-1-SUB-C (handling Track G cleanup) depends on your B.3 output. Notify them in check-in board when B.3 complete.

---

## Begin

1. Confirm 6 mandatory references read.
2. Claim Track B in check-in board.
3. Execute B.1 → B.2 → B.3 sequentially (each writes to disk before next).
4. Submit deliverables + notify CODEX-1-LEAD + CODEX-1-SUB-C.
