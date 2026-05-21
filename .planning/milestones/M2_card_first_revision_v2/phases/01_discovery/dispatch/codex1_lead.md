# CODEX 5.5 #1 LEAD — M2 Phase 1 Discovery

**Agent ID:** CODEX-1-LEAD
**Date:** 2026-05-20
**Milestone:** M2 — Hybrid Card-First Revision
**Phase:** 1 — Discovery
**Tenant:** ColOfertasBrasilPro (env id `e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
**Bot:** Assistente PMO V2

---

## CONTEXT RESET DIRECTIVE

If you have any prior memory of this project, codebase, or related work — DISCARD IT. This prompt is self-contained. The ONLY context you should use is:

1. This prompt (full content below)
2. The files explicitly listed in `Mandatory Read-Before-Start`
3. Live tenant state queried via PAC CLI (read-only)

Do NOT pull from training cache, prior sessions, or implicit assumptions. Treat this as encountering the project for the first time, with the documents listed below as your sole source of truth.

---

## Governance — MANDATORY (governance kit added 2026-05-20 18:14)

Before doing ANYTHING else, perform these 3 operations in order:

1. Read `.planning/milestones/M2_card_first_revision_v2/governance/CHECKIN_CHECKOUT_PROTOCOL.md` (full file).
2. CHECK-IN: append entry to `governance/ACTIVITY_LOG.md` and update `governance/CHECKIN_BOARD.md` Active Agents row as `CODEX-1-LEAD`.
3. Set yourself to `IN_PROGRESS`, status visible to other agents.

Throughout the task, emit HEARTBEAT every 5 minutes to ACTIVITY_LOG.

Acquire FILE LOCK in `governance/FILE_LOCK_TABLE.md` before any file write.

When done, CHECK-OUT (status DONE/BLOCKED) + log HANDOFF to next dependent agent in `governance/HANDOFF_LOG.md`.

**Wherever the prompt below mentions `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`, REPLACE with `governance/CHECKIN_BOARD.md` + `governance/ACTIVITY_LOG.md` per the protocol.**

---

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/ROADMAP.md
.planning/milestones/M2_card_first_revision_v2/STATE.md
.planning/milestones/M2_card_first_revision_v2/decisions/ADR-M2-001-routing-matrix.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/AGENT_CONTRACT.md
.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md
.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md
```

In your first response, confirm each of those 9 files was read.

---

## Hard Constraints (NO EXCEPTIONS)

- Read-only operations ONLY. No tenant writes, no imports, no publishes, no flow saves, no topic edits, no SP writes, no Planner writes, no chat tests.
- Use Windows PowerShell 5.1 + PAC CLI exclusively for Dataverse queries.
- No Microsoft 365 CLI / `m365`. No direct Microsoft Graph. No HTTP Premium. No service principals.
- Update `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` every 5 minutes while active.
- All output goes to `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/`.

---

## Your Tasks

### Task A.1 — All Topics Inventory

```powershell
pac env who > .planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/pac_env_who.txt

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
```

Parse the result and produce `topic_inventory.json` with this schema:

```json
[
  {
    "schemaname": "pmo_AssistentePMO_V2.topic.AtualizarStatus",
    "name": "AtualizarStatus",
    "componenttype": 9,
    "statecode": "Activo",
    "statuscode": "Activo",
    "modifiedon": "2026-05-14T15:04:00Z",
    "has_yaml_data": true,
    "yaml_size_bytes": 12345,
    "kind": "user-facing"
  },
  ...
]
```

Then write `INVENTORY_TOPICS.md` summarizing:
- 12 user-facing topics (CriarProjeto, ConsultarProjeto, ExcluirProjeto, CriarTarefa, ListarTarefas, AtualizarTarefa, ExcluirTarefa, AtualizarStatus, RegistrarRisco, RegistrarBloqueio, PedirDecisao, ConsultarPortfolio)
- 4 system topics (Greeting, LowConfidence, SeHouverErro, Gerar_Multiplos_Projetos)
- Their state, last modified, YAML size

### Task A.2 — All Workflows Inventory

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
    <filter type='or'>
      <condition attribute='name' operator='like' value='PMO_PA_%' />
      <condition attribute='name' operator='like' value='PM0_PA_%' />
    </filter>
  </entity>
</fetch>
"@ > all_workflows_inventory.txt
```

Parse to `workflow_inventory.json`:

```json
{
  "legacy_pmo_pa": [
    { "workflowid": "...", "name": "PMO_PA_AtualizarStatus", "state": "Activado", "modifiedon": "..." },
    ...
  ],
  "new_pm0_pa_card": [
    { "workflowid": "...", "name": "PM0_PA_Card_AtualizarStatus", "state": "Activado", "modifiedon": "..." },
    ...
  ]
}
```

Write `INVENTORY_WORKFLOWS.md`:
- 12 PMO_PA_* legacy listed with state
- 6 PM0_PA_* new listed with state
- Identify any workflow in either list that is NOT in `Activado` state — flag it

### Integrator Role

You are also the Phase 1 integrator. Responsibilities:

1. **Monitor** the check-in board (`AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md`) for the other 9 agents.
2. **Validate** each track's output as agents declare DONE:
   - CODEX-1-SUB-A → Tracks A.3, A.4 (bindings, connections)
   - CODEX-1-SUB-B → Track B (SharePoint inventory)
   - CODEX-1-SUB-C → Tracks A.5 (topic errors RCA), H (risks)
   - CODEX-2-LEAD, CODEX-2-SUB-A, CODEX-2-SUB-B → Track D (18 flow definitions split 3-way)
   - CODEX-2-SUB-C → Track G (cleanup script)
   - OPUS-2 → Tracks E (routing), F (topic YAMLs)
   - GEMINI-FLASH → Track C (cards catalog)
3. **Block** any track that produces incomplete or non-schema-compliant output until corrected.
4. **Produce** final `phases/01_discovery/HANDOFF.md` consolidating all 10 tracks.

### HANDOFF.md content (your final deliverable)

After all 10 tracks DONE + validated:

1. PASS/FAIL per track (10 rows table)
2. Confirmed inventory summary (one paragraph per track)
3. **Gap list** (current → M2 target):
   - Topics: how many need binding change (12 expected)
   - Flows: how many need to be created (7 expected) + refactored (5 expected) + reusable (1)
   - Cards: how many to create from scratch + refactor
   - Schema: list of fields to add per list
   - Test data: count of records to clean
4. **Risks discovered**:
   - Copilot Studio "1 error per topic" root cause (from Track A.5 RCA)
   - Connector quota risks (from Track H)
   - Connection reference orphans (from Track A.4)
   - Tenant policy concerns (from Track H)
5. Phase 2 readiness: GREEN / YELLOW / RED
6. Owner action required (if any blocker)

---

## Time Budget

Hard limit:
- Tasks A.1 + A.2 = 60 minutes
- Integrator role: continues until all 10 tracks produce HANDOFF (additional ~30-60 min)

If you exceed 90 min on A.1+A.2, raise flag in check-in board.

---

## Coordination Rules

1. PAC auth issue → document in check-in board + STOP (Owner refreshes credentials).
2. FetchXML returning >50000 rows → paginate + document strategy.
3. Any tenant write attempt or unsanctioned tool use = automatic FAIL + escalate to Owner.

---

## Begin

1. Confirm 9 mandatory references read.
2. Claim Track A.1 + A.2 + integrator in check-in board.
3. Execute A.1 → A.2 → start integrator monitoring.
4. Final: produce HANDOFF.md when all tracks done.
