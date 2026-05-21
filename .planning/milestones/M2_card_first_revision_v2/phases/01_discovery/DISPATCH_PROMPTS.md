# Phase 1 Discovery — Dispatch Prompts (6 agents)

**Date:** 2026-05-20 17:46 BRT
**Phase:** M2 Phase 1 — Discovery
**Mode:** Parallel execution, 6 agents simultaneously

Copy each prompt block into its target agent IDE. Each prompt is self-contained.

---

## PROMPT 1 — Codex 5.5 (LEAD) — Tracks A + integrator

Cole este no IDE principal do Codex 5.5:

````markdown
# CODEX 5.5 LEAD — M2 Phase 1 Discovery — Track A + Integrator

Date: 2026-05-20
Milestone: M2 — Hybrid Card-First Revision
Phase: 1 — Discovery
Role: CODEX-LEAD (Track A Dataverse + integration owner across 8 parallel tracks)
Tenant: ColOfertasBrasilPro (env e2d10003-4d8e-e007-9d63-76d5fe89ef56)
Bot: Assistente PMO V2

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

Confirm in your first response that all files were read.

## Hard Constraints

- Read-only operations ONLY. No tenant writes, no imports, no publishes, no flow saves, no topic edits, no SP writes, no Planner writes, no chat tests.
- Use Windows PowerShell 5.1 + PAC CLI exclusively.
- No Microsoft 365 CLI / `m365`. No direct Graph. No HTTP Premium. No service principals.
- Update `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` every 5 minutes.
- All output goes to `.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/A_dataverse_inventory/`.

## Tasks

Execute Track A (Dataverse Inventory) in `phases/01_discovery/SPEC.md` Track A:

- A.1 — All topics inventory + parsed JSON + INVENTORY_TOPICS.md
- A.2 — All workflows inventory (PMO_PA_*, PM0_PA_*) + INVENTORY_WORKFLOWS.md
- A.3 — botcomponent_workflow bindings matrix + INVENTORY_BINDINGS.md
- A.4 — Connection references audit + INVENTORY_CONNECTIONS.md
- A.5 — Copilot Studio errors RCA per topic + INVENTORY_TOPIC_ERRORS_RCA.md

## Integrator Role

You are also responsible for cross-track integration:

1. Monitor check-in board for all 6 parallel agents (yourself + 5 others).
2. When other tracks declare DONE, validate their output against the schemas/contracts in SPEC.md.
3. Block any track that produces incomplete or non-schema-compliant output until corrected.
4. Produce final `phases/01_discovery/HANDOFF.md` consolidating all 8 tracks' output.

## Deliverables

- 5 raw .txt files (PAC FetchXML output)
- 4 parsed .json files (topic_inventory, workflow_inventory, binding_inventory, connection_audit)
- 5 INVENTORY_*.md files
- HANDOFF.md (after all tracks complete)

## Acceptance

- All 12 user-facing topics + 4 system topics inventoried
- All 12 PMO_PA_* + 6 PM0_PA_* workflows inventoried with state/status
- All bindings mapped (which topic ↔ which workflow)
- All connection references audited
- Every "1 error" / "5 errors" topic from Copilot Studio screenshot has root cause documented

## Time Budget

Hard limit: 90 minutes for Track A. After that, raise flag if not complete.
Integrator role continues until all 8 tracks produce HANDOFF.

## Coordination Rules

1. If you hit a PAC auth issue, document in check-in board and STOP — Owner will refresh credentials.
2. If FetchXML returns >50000 rows for any query, paginate and document strategy.
3. Any tenant write attempt or unsanctioned tool use = automatic FAIL.

Begin by confirming references read, then claim Track A in check-in board, then execute.
````

---

## PROMPT 2 — Codex sub-1 — Track B SharePoint

Cole este no segundo IDE (sub-agente do Codex):

````markdown
# CODEX SUB-1 — M2 Phase 1 — Track B: SharePoint Inventory

Date: 2026-05-20
Milestone: M2
Phase: 1 (Discovery)
Role: SP specialist
Tenant: ColOfertasBrasilPro
SP site: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/SHAREPOINT_ACCESS_RUNBOOK.md
.planning/AGENT_CONTRACT.md
docs/SCHEMA_SHAREPOINT_PMO.md
```

## Hard Constraints

- Read-only via PnP. Use Windows PowerShell 5.1 + SharePointPnPPowerShellOnline 3.29.2101.0 + Connect-PnPOnline -UseWebLogin.
- No writes, no item changes, no schema mutations.
- Output to `phases/01_discovery/B_sharepoint_inventory/`.
- Update check-in board every 5 minutes.

## Tasks

Per SPEC.md Track B:

- B.1 — All 5 list schemas (Projetos, Tarefas, Status Diario, Riscos e Bloqueios, Decisoes do Board)
- B.2 — Item count + soft-delete state per list
- B.3 — Test data residual identification (2026-05-10 + 2026-05-13 patterns)

## Deliverables

- 5 × `<ListName>.fields.json`
- 5 × `<ListName>.views.json`
- `list_counts.json`
- `test_data_residual_candidates.json`
- INVENTORY_SP_SCHEMA.md
- INVENTORY_SP_DATA_STATE.md
- INVENTORY_TEST_RESIDUALS.md

## Time Budget

90 minutes hard limit.

## Reporting

When done, post in check-in board: "Track B DONE — [link to deliverables]". Wait for CODEX-LEAD validation.

Begin.
````

---

## PROMPT 3 — Codex sub-2 — Track D Flow Definitions

Cole este no terceiro IDE:

````markdown
# CODEX SUB-2 — M2 Phase 1 — Track D: Flow Definitions Extract

Date: 2026-05-20
Milestone: M2
Phase: 1
Role: Power Automate specialist
Tenant: ColOfertasBrasilPro

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/comms/aq07_power_automate_build_20260515/execution_evidence/
.planning/AGENT_CONTRACT.md
```

## Hard Constraints

- Read-only. PAC + Power Apps PowerShell module if available.
- No flow modifications, no enable/disable, no save.
- Output to `phases/01_discovery/D_flow_definitions/`.

## Tasks

Per SPEC.md Track D — extract for these 18 flows:

PMO_PA_* legacy (12):
PMO_PA_AtualizarStatus, PMO_PA_AtualizarTarefa, PMO_PA_ConsultarPortfolio, PMO_PA_ConsultarProjeto, PMO_PA_CriarProjeto, PMO_PA_CriarTarefa, PMO_PA_ExcluirProjeto, PMO_PA_ExcluirTarefa, PMO_PA_ListarTarefas, PMO_PA_PedirDecisaoBot, PMO_PA_RegistrarBloqueioBot, PMO_PA_RegistrarRiscoBot

PM0_PA_Card_* new (6):
PM0_PA_Card_AtualizarStatus, PM0_PA_Card_AtualizarTarefa, PM0_PA_Card_CriarTarefa, PM0_PA_Card_ListarTarefas, PM0_PA_Card_ResumoExecutivoPortfolio, PM0_PA_OpsFailureHandling

Per flow, extract:
- Trigger schema (input contract)
- Action graph (sequence)
- Connections used
- Output schema
- Run history (last 30 days, success/fail count)

## Deliverables

- 18 × `definition_<flow>.json`
- 18 × `triggerSchema_<flow>.json`
- 18 × `outputSchema_<flow>.json`
- `flow_run_history_30d.json`
- INVENTORY_FLOW_DEFINITIONS.md

## Time Budget

90 minutes hard limit.

Begin.
````

---

## PROMPT 4 — Codex sub-3 — Tracks G + H

Cole este no quarto IDE:

````markdown
# CODEX SUB-3 — M2 Phase 1 — Tracks G + H: Cleanup + Risks

Date: 2026-05-20
Milestone: M2
Phase: 1
Role: QA + risk analyst

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/cleanup/
.planning/comms/sharepoint_schema_xml_20260513/
```

## Hard Constraints

- Read-only.
- Generate the cleanup PowerShell script but DO NOT execute it.
- Output to `phases/01_discovery/G_test_data_cleanup/` and `phases/01_discovery/H_risks_constraints/`.

## Tasks

### Track G — Test Data + Cleanup Spec

- G.1 — Cross-reference test data candidates per list (use Track B output via check-in board after B is DONE)
- G.2 — Generate `Cleanup-TestData-M2.ps1` with -WhatIf + -Confirm

### Track H — Risk & Constraint Inventory

- H.1 — Connector quotas (SharePoint, Teams, Planner, PVA Standard)
- H.2 — Tenant policy review last 60 days

## Deliverables

- `cleanup_candidates_final.json`
- `Cleanup-TestData-M2.ps1`
- INVENTORY_CLEANUP_PLAN.md
- `connector_quota_analysis.json`
- INVENTORY_QUOTA_RISKS.md
- INVENTORY_TENANT_CHANGES.md

## Time Budget

90 minutes total for both tracks. G depends on B, so start with H first.

Begin.
````

---

## PROMPT 5 — Opus 4.7 #2 — Tracks E + F

Cole este no IDE da segunda instância Opus:

````markdown
# OPUS 4.7 #2 — M2 Phase 1 — Tracks E + F: Routing + Topic YAMLs

Date: 2026-05-20
Milestone: M2
Phase: 1
Role: Architecture support — routing/topics analyst
Coordination: you are the second Opus 4.7 instance. Lead Opus 4.7 is in the main owner chat orchestrating the project.

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/decisions/ADR-M2-001-routing-matrix.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
.planning/comms/aq08_topic_routing_verification_20260520/
.planning/comms/topic_remediation_20260520/as_is/
.planning/STATE.md (look for Teams Channel deep link config)
```

## Hard Constraints

- Read-only. PAC for Dataverse, Teams Standard connector test calls only for channel validation.
- No writes anywhere.
- Output to `phases/01_discovery/E_routing_inventory/` and `phases/01_discovery/F_topic_yamls/`.

## Tasks

### Track E — Routing & Channels Inventory

- E.1 — Validate channel/group IDs are live and accessible
  - Group `96c5b0c4-46cc-46cd-8695-50451db74994`
  - Channel `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` (Projetos_Transformacao_Digital)
  - Channel `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` (QA_Projetos)
  - Owner UPN `mbenicios@minsait.com`
- E.2 — Per-flow routing inspection (extract hard-coded channel/group IDs from existing PM0 flow definitions; cross-check with ADR-M2-001 expected values)

### Track F — Topic YAML Extraction

For 16 topics (12 user + 4 system), extract clean YAML body from `botcomponent.data` field.

5 topics already in `.planning/comms/topic_remediation_20260520/as_is/` — verify identical and reuse if so. Extract the missing 11.

## Deliverables

- `channel_validation.json`
- INVENTORY_CHANNELS.md
- INVENTORY_ROUTING_PER_FLOW.md
- 16 × `<TopicName>.yaml`
- INVENTORY_TOPIC_YAMLS.md

## Time Budget

90 minutes hard limit.

Begin by confirming references read.
````

---

## PROMPT 6 — Gemini Flash 3.5 — Track C Cards Catalog

Cole este no IDE do Gemini Flash:

````markdown
# GEMINI FLASH 3.5 — M2 Phase 1 — Track C: Adaptive Cards Catalog

Date: 2026-05-20
Milestone: M2
Phase: 1
Role: Card design + UX inventory

## Mandatory Read-Before-Start

```text
.planning/milestones/M2_card_first_revision_v2/PROJECT.md
.planning/milestones/M2_card_first_revision_v2/REQUIREMENTS.md
.planning/milestones/M2_card_first_revision_v2/decisions/ADR-M2-001-routing-matrix.md
.planning/milestones/M2_card_first_revision_v2/phases/01_discovery/SPEC.md
deploy/cards/
frontend/dss-showcase/UI_UX/
frontend/pmo-executive-viewer/
```

## Hard Constraints

- Read-only file inspection. No JSON file modifications.
- Output to `phases/01_discovery/C_cards_catalog/`.

## Tasks

### Track C — Cards Catalog

- C.1 — Walk the 3 directories above + any other location with `.json` Adaptive Cards. For each card:
  - File path (relative)
  - Adaptive Card schema version
  - File size (bytes)
  - Schema-valid? (use Adaptive Cards 1.4+ schema)
  - Operation it supports (inferred from card actions/data fields)
  - Usage status: in use / orphan / draft
  - Visual quality: complete / incomplete / placeholder

- C.2 — Gap analysis vs M2 REQUIREMENTS.md REQ-M2-02 (9 confirmation cards), REQ-M2-03 (4 result cards), REQ-M2-04 (1 ops failure card). For each of the 14 target cards, indicate:
  - Existing JSON to refactor (path) OR
  - New from scratch (TBD in Phase 3)

## Deliverables

- `cards_catalog.json` (full machine-readable inventory)
- INVENTORY_CARDS_CURRENT.md (human-readable)
- INVENTORY_CARDS_GAP.md (M2 build-list)

## Time Budget

60 minutes hard limit.

Begin.
````

---

## Coordination Rules (apply to all 6 agents)

1. Each agent **claims its track** in `.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md` before starting work.
2. Updates every 5 minutes while active.
3. When DONE, post: "Track [X] DONE" + path to HANDOFF.
4. Codex 5.5 LEAD validates each track's output before declaring it accepted.
5. After all 6 tracks DONE + validated, Codex 5.5 LEAD produces `phases/01_discovery/HANDOFF.md` and triggers Phase 2 auto-advance.

## Time Budget

- Phase 1 hard limit: 6 hours calendar from dispatch.
- If any track exceeds 90 min beyond its individual estimate, raise flag to Owner.

---

## Owner Action Required NOW

**You (Manoel) need to:**

1. Open 6 IDE sessions (or 5 if Codex shares one main + sub agents in same workspace).
2. Paste each prompt above into respective agent.
3. Confirm here when all 6 are dispatched.

After dispatch, agents work in parallel. Monitor progress in:
```
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
```

Estimated complete time: 4-6 hours from dispatch (depending on tenant API latency and parallelism efficiency).

When all 6 tracks PASS and HANDOFF.md is produced, Phase 2 auto-advances. I (Opus 4.7 lead) will write Phase 2 dispatch prompts at that point.

---

*Last updated: 2026-05-20 17:46 BRT*
