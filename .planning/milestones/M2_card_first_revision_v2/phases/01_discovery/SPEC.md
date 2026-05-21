# Phase 1 — Discovery Specification

**Milestone:** M2
**Phase:** 1
**Status:** READY FOR DISPATCH
**Owner gate:** None (read-only, fully agent-driven)
**Estimated effort:** 4-6h bruto / 4h calendar with 8 parallel agents
**Time budget hard limit:** 6h calendar

---

## Goal

Lock 100% complete inventory of current tenant state. Zero assumptions. Every claim backed by read-only evidence file.

After Phase 1, the M2 architecture spec (Phase 2) can be authored without any "let me check first" interruptions.

---

## Hard Constraints (apply to ALL agents in this phase)

- DO NOT execute any tenant write (no import, no publish, no save, no delete, no schema change, no Planner write).
- DO NOT modify any topic in Copilot Studio UI.
- DO NOT use Microsoft 365 CLI / `m365`.
- DO NOT use direct Microsoft Graph, HTTP Premium, client credentials, app registrations, or service principals.
- DO NOT execute Copilot chat tests.
- All operations are READ-ONLY via PAC CLI (Windows PowerShell 5.1) or PnP read-only.
- Use `Connect-PnPOnline -UseWebLogin` for SharePoint discovery.
- Update `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` every 5 minutes while active.
- All deliverables go to `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/<task_folder>/`.

---

## Mandatory Read-Before-Start (all agents)

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/ROADMAP.md
.planning/milestones/M2_card_first_revision_v2/STATE.md
.planning/milestones/M2_card_first_revision_v2/decisions/ADR-M2-001-routing-matrix.md
.planning/AGENT_CONTRACT.md
.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
```

---

## Task Allocation (8 parallel tracks)

### Track A — Dataverse Inventory (Codex 5.5 lead)

**Output folder:** `phases/01_discovery/A_dataverse_inventory/`

#### Task A.1 — All topics inventory

```powershell
pac env who > pac_env_who.txt

# All botcomponent rows for pmo_AssistentePMO_V2
# Use FetchXML returning topic kind only
pac org fetch --xml @"
<fetch>
  <entity name='botcomponent'>
    <attribute name='botcomponentid' />
    <attribute name='schemaname' />
    <attribute name='name' />
    <attribute name='componenttype' />
    <attribute name='statecode' />
    <attribute name='statuscode' />
    <attribute name='modifiedon' />
    <attribute name='data' />
    <filter>
      <condition attribute='componenttype' operator='eq' value='9' />
    </filter>
    <link-entity name='bot' from='botid' to='parentbotid' alias='bot'>
      <attribute name='name' />
      <attribute name='schemaname' />
      <filter>
        <condition attribute='schemaname' operator='eq' value='pmo_AssistentePMO_V2' />
      </filter>
    </link-entity>
  </entity>
</fetch>
"@ > all_topics_inventory.txt

# Output structured: topic_inventory.json (parse the .txt)
```

Deliverables:
- `pac_env_who.txt`
- `all_topics_inventory.txt` (raw)
- `topic_inventory.json` (parsed: name, schemaname, status, modifiedon, has_yaml_data)
- `INVENTORY_TOPICS.md` summarizing what's there

#### Task A.2 — All workflows inventory

```powershell
pac org fetch --xml @"
<fetch>
  <entity name='workflow'>
    <attribute name='workflowid' />
    <attribute name='name' />
    <attribute name='statecode' />
    <attribute name='statuscode' />
    <attribute name='category' />
    <attribute name='type' />
    <attribute name='modifiedon' />
    <filter>
      <condition attribute='name' operator='like' value='PM%PA%' />
    </filter>
  </entity>
</fetch>
"@ > all_workflows_inventory.txt
```

Deliverables:
- `all_workflows_inventory.txt`
- `workflow_inventory.json` (parsed)
- `INVENTORY_WORKFLOWS.md` listing 12 PMO_PA_* + 6 PM0_PA_*  with state/status/lastModified

#### Task A.3 — botcomponent_workflow bindings

```powershell
pac org fetch --xml @"
<fetch>
  <entity name='botcomponent_workflow'>
    <attribute name='botcomponent_workflowid' />
    <attribute name='botcomponentid' />
    <attribute name='workflowid' />
    <link-entity name='botcomponent' from='botcomponentid' to='botcomponentid' alias='bc'>
      <attribute name='schemaname' />
      <attribute name='name' />
    </link-entity>
    <link-entity name='workflow' from='workflowid' to='workflowid' alias='wf'>
      <attribute name='name' />
      <attribute name='statecode' />
      <attribute name='statuscode' />
    </link-entity>
  </entity>
</fetch>
"@ > all_bindings_inventory.txt
```

Deliverables:
- `all_bindings_inventory.txt`
- `binding_inventory.json`
- `INVENTORY_BINDINGS.md` matrix: which topic refs which workflow

#### Task A.4 — Connection references audit

```powershell
pac connection list > all_connections.txt

pac org fetch --xml @"
<fetch>
  <entity name='connectionreference'>
    <attribute name='connectionreferenceid' />
    <attribute name='connectionreferencelogicalname' />
    <attribute name='connectionreferencedisplayname' />
    <attribute name='connectorid' />
    <attribute name='connectionid' />
    <attribute name='statecode' />
  </entity>
</fetch>
"@ > all_connection_references.txt
```

Deliverables:
- `all_connections.txt`
- `all_connection_references.txt`
- `connection_audit.json`
- `INVENTORY_CONNECTIONS.md` listing every connector + status + which flows depend on it

#### Task A.5 — Copilot Studio errors RCA

For each of the 12 user-facing topics that show "1 error" (and CriarProjeto with "5 errors") in the Copilot Studio UI screenshot:

1. Read the topic YAML from `topic_inventory.json`
2. Run static parse — Power Fx expressions, regex syntax, condition group structure
3. Identify pattern of error (likely SP connection ref orphan after 3.15 import — but verify)
4. Document each topic's specific issue

Deliverables:
- `INVENTORY_TOPIC_ERRORS_RCA.md` per-topic error breakdown + suspected root cause + proposed fix

---

### Track B — SharePoint Schema Inventory (Codex sub-1)

**Output folder:** `phases/01_discovery/B_sharepoint_inventory/`

#### Task B.1 — All 5 list schemas

```powershell
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
Connect-PnPOnline -Url $siteUrl -UseWebLogin

$lists = @("Projetos", "Tarefas", "Status Diario", "Riscos e Bloqueios", "Decisoes do Board")
foreach ($listName in $lists) {
  $list = Get-PnPList -Identity $listName -Includes Fields,Views
  # Export each field with: name, type, required, default, choices (if any)
  # Export each view with: name, JSLink, ViewQuery
  $list.Fields | ForEach-Object { ... } | ConvertTo-Json -Depth 5 | Out-File "$listName.fields.json"
  $list.Views | ForEach-Object { ... } | ConvertTo-Json -Depth 5 | Out-File "$listName.views.json"
}
```

Deliverables:
- 5 × `<ListName>.fields.json`
- 5 × `<ListName>.views.json`
- `INVENTORY_SP_SCHEMA.md` table per list: fields with type/required/default

#### Task B.2 — Item count + soft-delete state per list

```powershell
foreach ($listName in $lists) {
  $totalItems = (Get-PnPListItem -List $listName -PageSize 5000).Count
  $deletedItems = (Get-PnPListItem -List $listName -Query "<View><Query><Where><Eq><FieldRef Name='Deleted'/><Value Type='Boolean'>1</Value></Eq></Where></Query></View>").Count
  # ...
}
```

Deliverables:
- `list_counts.json` (per list: totalActive, totalDeleted, lastWrite)
- `INVENTORY_SP_DATA_STATE.md` summary

#### Task B.3 — Test data residual identification

For dates 2026-05-10 and 2026-05-13, identify all items that look like test data (titles containing "QA", "Teste", "test", or matching test naming patterns).

Deliverables:
- `test_data_residual_candidates.json`
- `INVENTORY_TEST_RESIDUALS.md` per-list list of candidates for cleanup in Phase 6

---

### Track C — Adaptive Cards Catalog (Gemini Flash 3.5 lead)

**Output folder:** `phases/01_discovery/C_cards_catalog/`

#### Task C.1 — Existing cards inventory

Walk these directories and catalog every JSON file that's an Adaptive Card:
- `deploy/cards/`
- `frontend/dss-showcase/UI_UX/`
- `frontend/pmo-executive-viewer/`

For each card:
- File path
- Card version (Adaptive Cards 1.x)
- File size (bytes)
- Schema-valid? (yes/no)
- Operation it supports (inferred)
- Usage status: in use / orphan / draft

Deliverables:
- `cards_catalog.json`
- `INVENTORY_CARDS_CURRENT.md` table with all of the above

#### Task C.2 — Cards needed for M2 (gap analysis)

Cross-reference:
- M2 REQUIREMENTS.md REQ-M2-02, REQ-M2-03, REQ-M2-04
- ADR-M2-001 (variants per route)

Output a gap list: for each of the 13 cards target, indicate:
- Existing JSON to refactor (path) OR
- New from scratch (TBD in Phase 3)

Deliverables:
- `INVENTORY_CARDS_GAP.md`

---

### Track D — Power Automate Flow Definitions Extract (Codex sub-2)

**Output folder:** `phases/01_discovery/D_flow_definitions/`

#### Task D.1 — Extract definition JSON per flow

For each of the 12 PMO_PA_* and 6 PM0_PA_* flows, extract:
- Trigger schema (input contract)
- Action graph (sequence of actions)
- Connections used
- Output schema
- Run history (last 30 days, count of success/fail)

```powershell
$flows = @(
  "PMO_PA_AtualizarStatus", "PMO_PA_AtualizarTarefa", "PMO_PA_ConsultarPortfolio",
  "PMO_PA_ConsultarProjeto", "PMO_PA_CriarProjeto", "PMO_PA_CriarTarefa",
  "PMO_PA_ExcluirProjeto", "PMO_PA_ExcluirTarefa", "PMO_PA_ListarTarefas",
  "PMO_PA_PedirDecisaoBot", "PMO_PA_RegistrarBloqueioBot", "PMO_PA_RegistrarRiscoBot",
  "PM0_PA_Card_AtualizarStatus", "PM0_PA_Card_AtualizarTarefa", "PM0_PA_Card_CriarTarefa",
  "PM0_PA_Card_ListarTarefas", "PM0_PA_Card_ResumoExecutivoPortfolio", "PM0_PA_OpsFailureHandling"
)
foreach ($flowName in $flows) {
  # Use pac org fetch to get the workflow row, then parse clientdata field for definition JSON
  # Or use Get-Flow from Power Apps PowerShell module if available
}
```

Deliverables:
- 18 × `definition_<flow_name>.json`
- 18 × `triggerSchema_<flow_name>.json` (input)
- 18 × `outputSchema_<flow_name>.json` (output)
- `flow_run_history_30d.json` (success/fail count per flow)
- `INVENTORY_FLOW_DEFINITIONS.md` matrix

---

### Track E — Routing & Channels Inventory (Opus 4.7 #2)

**Output folder:** `phases/01_discovery/E_routing_inventory/`

#### Task E.1 — Validate channel/group IDs in tenant

Verify these IDs are still valid and correctly resolve:
- Group `96c5b0c4-46cc-46cd-8695-50451db74994`
- Channel `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` (Projetos_Transformacao_Digital)
- Channel `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` (QA_Projetos)
- Owner UPN `mbenicios@minsait.com`

Use Teams Standard connector test calls (read-only).

Deliverables:
- `channel_validation.json`
- `INVENTORY_CHANNELS.md` confirming each ID is live + accessible from tenant connections

#### Task E.2 — Per-flow routing inspection

For each of the 6 existing PM0_PA_Card_* flows, extract from the definition JSON the actual channel/group IDs hard-coded in their Teams "Post adaptive card" action. Compare with ADR-M2-001 expected values.

Deliverables:
- `INVENTORY_ROUTING_PER_FLOW.md` matrix

---

### Track F — Topic YAML Extraction (Opus 4.7 #2 — same agent as Track E)

**Output folder:** `phases/01_discovery/F_topic_yamls/`

For each of 12 user-facing topics + 4 system topics (Greeting, LowConfidence, SeHouverErro, Gerar_Multiplos_Projetos):

Extract the full YAML body from `botcomponent.data` field (already captured in Track A.1, but produce clean per-file output here).

Deliverables:
- 16 × `<TopicName>.yaml`
- `INVENTORY_TOPIC_YAMLS.md` summary

(Note: 5 topics already extracted in M1 work at `.planning/comms/topic_remediation_20260520/as_is/`. Reuse those if identical.)

---

### Track G — Test Data + Cleanup Spec (Codex sub-3)

**Output folder:** `phases/01_discovery/G_test_data_cleanup/`

#### Task G.1 — Test data candidates per list

Cross-reference Track B.3 output with M1 evidence packs (`.planning/comms/sharepoint_schema_xml_20260513/`, `.planning/cleanup/`).

Output per-list final list of candidates for cleanup in Phase 6.

Deliverables:
- `cleanup_candidates_final.json`
- `INVENTORY_CLEANUP_PLAN.md` per-list strategy

#### Task G.2 — Cleanup PnP script (DO NOT EXECUTE)

Generate `Cleanup-TestData-M2.ps1` with:
- `-WhatIf` mode default
- `-Confirm` switch for execution
- Logging
- Per-list dry-run output

Deliverables:
- `Cleanup-TestData-M2.ps1` (delivered, not executed)

---

### Track H — Risk & Constraint Inventory (Codex sub-3 — same agent)

**Output folder:** `phases/01_discovery/H_risks_constraints/`

#### Task H.1 — Microsoft Standard connector quotas

Document current limits for:
- SharePoint Standard
- Teams Standard
- Planner Standard
- Power Virtual Agents Standard

Per-flow estimated call frequency (posts per day in production).

Identify any quota that could become a bottleneck.

Deliverables:
- `connector_quota_analysis.json`
- `INVENTORY_QUOTA_RISKS.md`

#### Task H.2 — Tenant policy review

Review last 60 days of any tenant-level changes (governance policies, conditional access changes, retention policies) that could affect M2.

Deliverables:
- `INVENTORY_TENANT_CHANGES.md`

---

## Deliverable Structure

```
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/
├── A_dataverse_inventory/
│   ├── pac_env_who.txt
│   ├── all_topics_inventory.txt
│   ├── all_workflows_inventory.txt
│   ├── all_bindings_inventory.txt
│   ├── all_connections.txt
│   ├── all_connection_references.txt
│   ├── topic_inventory.json
│   ├── workflow_inventory.json
│   ├── binding_inventory.json
│   ├── connection_audit.json
│   ├── INVENTORY_TOPICS.md
│   ├── INVENTORY_WORKFLOWS.md
│   ├── INVENTORY_BINDINGS.md
│   ├── INVENTORY_CONNECTIONS.md
│   └── INVENTORY_TOPIC_ERRORS_RCA.md
├── B_sharepoint_inventory/
│   ├── Projetos.fields.json
│   ├── Projetos.views.json
│   ├── (+ same for 4 other lists)
│   ├── list_counts.json
│   ├── test_data_residual_candidates.json
│   ├── INVENTORY_SP_SCHEMA.md
│   ├── INVENTORY_SP_DATA_STATE.md
│   └── INVENTORY_TEST_RESIDUALS.md
├── C_cards_catalog/
│   ├── cards_catalog.json
│   ├── INVENTORY_CARDS_CURRENT.md
│   └── INVENTORY_CARDS_GAP.md
├── D_flow_definitions/
│   ├── definition_<flow>.json (×18)
│   ├── triggerSchema_<flow>.json (×18)
│   ├── outputSchema_<flow>.json (×18)
│   ├── flow_run_history_30d.json
│   └── INVENTORY_FLOW_DEFINITIONS.md
├── E_routing_inventory/
│   ├── channel_validation.json
│   ├── INVENTORY_CHANNELS.md
│   └── INVENTORY_ROUTING_PER_FLOW.md
├── F_topic_yamls/
│   ├── <TopicName>.yaml (×16)
│   └── INVENTORY_TOPIC_YAMLS.md
├── G_test_data_cleanup/
│   ├── cleanup_candidates_final.json
│   ├── Cleanup-TestData-M2.ps1
│   └── INVENTORY_CLEANUP_PLAN.md
├── H_risks_constraints/
│   ├── connector_quota_analysis.json
│   ├── INVENTORY_QUOTA_RISKS.md
│   └── INVENTORY_TENANT_CHANGES.md
└── HANDOFF.md
```

---

## HANDOFF.md (Final Phase Output)

After all 8 tracks complete, the lead Codex agent produces `HANDOFF.md` containing:

1. PASS/FAIL per track (8 rows)
2. Confirmed inventory summary (one paragraph per track)
3. **Gap list** (current → M2 target):
   - Topics: how many need binding change (12)
   - Flows: how many need to be created (7) + refactored (5)
   - Cards: how many need to be created from scratch + how many to refactor
   - Schema: list of fields to add per list
   - Test data: count to clean
4. **Risks discovered**:
   - Copilot Studio "1 error per topic" root cause + proposed fix
   - Connector quota risks
   - Connection reference orphans (if any)
   - Tenant policy concerns (if any)
5. Phase 2 readiness: green/yellow/red
6. Owner action required (if any blocker)

---

## Coordination

- All agents update `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` every 5 minutes.
- If two agents need the same PAC session, serialize via check-in board.
- Codex 5.5 lead is the integrator: validates other tracks' outputs against expected schema before they're declared DONE.
- Time budget hard limit: 6 hours. If any track exceeds 90 min beyond its individual estimate, raise flag in check-in board immediately.

---

## Phase 1 Exit Criteria

- ✅ All 8 deliverable folders populated
- ✅ HANDOFF.md complete with PASS/FAIL per track + gap list + risks
- ✅ Codex 5.5 lead signs off on integrated handoff
- ✅ Auto-advance to Phase 2 triggered

---

*Last updated: 2026-05-20 17:46 BRT*
