# CODEX 5.5 #2 LEAD — M2 Phase 1 — Track D batch 1 (flows 1-6)

**Agent ID:** CODEX-2-LEAD
**Date:** 2026-05-20
**Milestone:** M2
**Phase:** 1 — Discovery
**Tenant:** ColOfertasBrasilPro

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project — DISCARD IT. Use ONLY:
1. This prompt
2. Files in `Mandatory Read-Before-Start`
3. Live tenant state via PAC CLI

---

## Governance — MANDATORY

Before doing ANYTHING else, perform these 3 operations in order:

1. Read `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md` (full file).
2. CHECK-IN: append entry to `governance/ACTIVITY_LOG.md` and update `governance/CHECKIN_BOARD.md` Active Agents row.
3. Set yourself to `IN_PROGRESS`, status visible to other agents.

Throughout the task, emit HEARTBEAT every 5 minutes to ACTIVITY_LOG.

When done, CHECK-OUT (status DONE/BLOCKED) + log HANDOFF to next dependent agent in `governance/HANDOFF_LOG.md`.

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/milestones/M2_card_first_revision_v2/decisions/ADR-M2-001-routing-matrix.md
.planning/comms/aq07_power_automate_build_20260515/execution_evidence/
.planning/AGENT_CONTRACT.md
```

Confirm in CHECK-IN entry: "references read: 6/6"

---

## Hard Constraints

- Read-only PAC CLI + Power Apps PowerShell (if available).
- No flow modifications, no enable/disable.
- Output to `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/D_flow_definitions/`.
- Acquire FILE LOCK before any write to that folder.
- No `m365`, no Graph, no Premium connectors.

---

## Tasks — Flow Definitions Extract (batch 1: 6 of 18)

For each of these 6 flows, extract: trigger schema, action graph, connections, output schema, run history (last 30 days).

| # | Flow name | Workflow ID | Type |
|---:|---|---|---|
| D.1 | PMO_PA_AtualizarStatus | c11a165b-c64c-f111-bec7-7ced8d9559c1 | legacy |
| D.2 | PMO_PA_AtualizarTarefa | 98408d55-3748-f111-bec7-000d3abc5cc6 | legacy |
| D.3 | PMO_PA_ConsultarPortfolio | 39cf292d-c64c-f111-bec7-7ced8d955c6c | legacy |
| D.4 | PMO_PA_ConsultarProjeto | 4a33b53e-c64c-f111-bec7-000d3abc5cc6 | legacy |
| D.5 | PMO_PA_CriarProjeto | 3104124d-364a-f111-bec7-7ced8d955c6c | legacy |
| D.6 | PMO_PA_CriarTarefa | 0a5d2a41-24c0-4d5e-9f6d-000000000241 | legacy |

### Per-flow extraction commands

```powershell
# Extract definition via PAC org fetch on workflow entity, parse clientdata field
pac org fetch --xml @"
<fetch>
  <entity name='workflow'>
    <attribute name='workflowid' />
    <attribute name='name' />
    <attribute name='clientdata' />
    <attribute name='inputparameters' />
    <attribute name='outputparameters' />
    <filter>
      <condition attribute='workflowid' operator='eq' value='<WORKFLOW_GUID>' />
    </filter>
  </entity>
</fetch>
"@

# clientdata field contains the flow JSON definition
# Parse it and write to definition_<flow_name>.json
```

For each flow, also extract:
- `triggerSchema_<flow_name>.json` — input schema only
- `outputSchema_<flow_name>.json` — output schema only

### Run history

```powershell
# Last 30 days run summary per flow
# Use Get-FlowRun if available, else parse processsimple if accessible read-only
```

Store as `flow_run_history_30d_<flow_name>.json` (or aggregate at end into `flow_run_history_30d.json`).

### Coordination with peer agents

CODEX-2-SUB-A handles flows D.7-D.12 (legacy other 6).
CODEX-2-SUB-B handles flows D.13-D.18 (PM0_PA_Card_* + ops handler).

You are the CODEX-2 LEAD: monitor the 2 sub-agents in CHECKIN_BOARD. When all 18 are extracted, you compile `INVENTORY_FLOW_DEFINITIONS.md` (master matrix).

---

## Deliverables

Per your batch:
- 6 × `definition_<flow_name>.json`
- 6 × `triggerSchema_<flow_name>.json`
- 6 × `outputSchema_<flow_name>.json`
- 6 × `flow_run_history_30d_<flow_name>.json`

Final consolidated:
- `flow_run_history_30d.json` (aggregated all 18 from all sub-agents)
- `INVENTORY_FLOW_DEFINITIONS.md` (master matrix all 18 flows)

---

## Time Budget

60 min for your batch (6 flows). Plus ~15 min for consolidation when sub-agents finish.

---

## CHECK-OUT Requirement

Your CHECKOUT entry MUST include:
```
[TIMESTAMP] CHECKOUT | CODEX-2-LEAD | task D.1-D.6 + consolidation | status: DONE | deliverables: <paths> | consolidated INVENTORY_FLOW_DEFINITIONS.md: <path> | next agent: OPUS-LEAD (Phase 2 spec author)
```

And HANDOFF_LOG entry confirming Phase 2 unblocked for OPUS-LEAD.

---

## Begin

1. Perform CHECK-IN per protocol
2. Read 6 references
3. Extract 6 flows in your batch
4. Monitor sub-agents
5. Consolidate when all 18 done
6. CHECK-OUT + HANDOFF
