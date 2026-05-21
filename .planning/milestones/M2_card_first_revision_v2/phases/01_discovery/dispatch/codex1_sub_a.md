# CODEX 5.5 #1 SUB-A — M2 Phase 1 — Tracks A.3 + A.4

**Agent ID:** CODEX-1-SUB-A
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery
**Tenant:** ColOfertasBrasilPro

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT. Use ONLY:
1. This prompt
2. Files in `Mandatory Read-Before-Start`
3. Live tenant state via PAC CLI (read-only)

---

## Governance — MANDATORY (governance kit added 2026-05-20 18:14)

1. Read `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md`
2. CHECK-IN to `governance/ACTIVITY_LOG.md` + `governance/CHECKIN_BOARD.md` as `CODEX-1-SUB-A`
3. HEARTBEAT every 5 min
4. FILE LOCK before writes (in `governance/FILE_LOCK_TABLE.md`)
5. CHECK-OUT + HANDOFF when done

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/decisions/ADR-M2-001-routing-matrix.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/AGENT_CONTRACT.md
.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
```

Confirm in first response that all 5 were read.

---

## Hard Constraints

- Read-only PAC CLI only. Windows PowerShell 5.1.
- No tenant writes. No `m365`, no Graph, no Premium.
- Output to `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/`.
- Update check-in board every 5 minutes.

---

## Tasks

### Task A.3 — botcomponent_workflow Bindings Matrix

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
      <attribute name='componenttype' />
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

Parse to `binding_inventory.json`:

```json
[
  {
    "topic_or_action": "pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa",
    "topic_componenttype": "Action",
    "workflow_name": "PMO_PA_AtualizarTarefa",
    "workflow_id": "98408d55-3748-f111-bec7-000d3abc5cc6",
    "workflow_state": "Activado"
  },
  ...
]
```

Then write `INVENTORY_BINDINGS.md` matrix showing:
- Which botcomponent (topic or action) → which workflow
- Highlight any orphan binding (workflow not in Activado state)

### Task A.4 — Connection References Audit

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

Parse to `connection_audit.json`:

```json
{
  "active_connections": [
    {
      "name": "shared_sharepointonline",
      "displayname": "SharePoint",
      "connectionid": "...",
      "state": "Activo"
    },
    ...
  ],
  "connection_references": [
    {
      "logicalname": "...",
      "displayname": "...",
      "connectorid": "shared_sharepointonline",
      "connectionid": "...",
      "state": "Activo"
    },
    ...
  ],
  "orphans": [
    {
      "logicalname": "gstf_sharepoint",
      "reason": "no active connection bound"
    }
  ]
}
```

Write `INVENTORY_CONNECTIONS.md`:
- All active connectors (SharePoint, Teams, Planner Standard, PVA, etc.)
- Each connection reference + its state + which flows depend on it (cross-reference workflow definitions if available)
- Flag any orphan or dangling reference

---

## Deliverables

```
phases/01_discovery/A_dataverse_inventory/
├── all_bindings_inventory.txt
├── all_connections.txt
├── all_connection_references.txt
├── binding_inventory.json
├── connection_audit.json
├── INVENTORY_BINDINGS.md
└── INVENTORY_CONNECTIONS.md
```

---

## Time Budget

45 minutes hard limit.

---

## Coordination

Post in check-in board when DONE. Wait for CODEX-1-LEAD validation.

If any data inconsistency between A.3 (bindings) and A.4 (connections) — flag immediately, do not silently resolve.

---

## Begin

1. Confirm 5 mandatory references read.
2. Claim Tracks A.3 + A.4 in check-in board.
3. Execute A.3 → A.4 → submit deliverables.
