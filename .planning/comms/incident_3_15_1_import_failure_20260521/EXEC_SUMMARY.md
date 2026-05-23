# EXEC_SUMMARY — Incident: Solution Import Failure 3.15.1 (v3 — Topology Confirmed)

## Current Status: **NO-SHIP** (replan path approved; ready to execute when ZIP available)

> **v3 update (2026-05-21T20:25:00Z):** Topology mapping confirmed Cenário 1 — all 18 in-scope components already in `PMO_v11_Tarefas`. No consolidation required. Replan path D-1 = Option A (Copilot Studio authoring + Microsoft-generated solution export/import). D-2 workflow re-import accepted as Microsoft-documented design.

## Incident
ISSUE-001: Solution import of `PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip` failed at 54.05% in phase "Inserciones de componentes raíz" with `0x80044150 Input string was not in a correct format`. Hand-crafted RootComponent entries with non-integer `type="botcomponent"` violated the Dataverse `componenttype` schema.

## Tenant State (validated)

| Item | State | Status |
|---|---|---|
| Solution version | `3.15` (auto-rolled-back) | Stable |
| 12 workflows statecode/statuscode | All `Activado/Activado` | Stable |
| 12 workflow `clientdata` SHA256 | All == pre-publish baseline | Zero drift |
| 5 topics `data` SHA256 | All == pre-publish baseline | Untouched |
| Solutioncomponent for 5 topics | 10 rows, `componenttype=10163` (Microsoft-validated) | Healthy |

## Topology (Cenário 1 — confirmed via Codex `TOPOLOGY_MAP.md`)

| Component class | Solution membership |
|---|---|
| 5 in-scope topics | `PMO_v11_Tarefas` ✅ |
| 12 in-scope workflows | `PMO_v11_Tarefas` ✅ |
| Bot `pmo_AssistentePMO_V2` | `PMO_v11_Tarefas` ✅ |
| `PMO_AQ07_CopilotBinding` | Separate AQ-07 action wrapper layer (19 components, all `PM0_*`) — out of scope for this incident |

**Conclusion: no consolidation needed. `PMO_v11_Tarefas` already contains everything required to ship the hotfix via Microsoft-supported export/import.**

## Validated Root Cause (unchanged from v2)
- Hand-crafted `solution.xml` declared `<RootComponent type="botcomponent" .../>`
- Dataverse `solutioncomponent.componenttype` is integer choice (live value `10163` for botcomponent)
- String → int parse failed → `FormatException` → `0x80044150`
- Microsoft Learn explicitly forbids the pattern: *"Removing or changing an agent's components directly from the solution causes the export and import to fail."*

## Approved Replan Path (D-1 = Option A)

### Step 1 — Owner: Edit 5 topics via Copilot Studio UI
- Open `PMO_v11_Tarefas` solution context in Copilot Studio
- Apply the 5 topic content changes (per `fixed_topic_yamls/*.yaml` source-of-truth)
- Save each topic in the UI (no Code Editor paste — use the standard authoring surface)

### Step 2 — Owner: Export solution from Copilot Studio
- Inside Copilot Studio solution explorer → `PMO_v11_Tarefas` → **Export solution**
- Increment to version `3.15.1`
- Save Microsoft-generated ZIP at `Solution/PMO_v11_Tarefas_3_15_1_FROM_COPILOT_STUDIO.zip` (new path; preserves quarantined hand-crafted ZIP for audit)

### Step 3 — Codex: Local pre-import validation
- `Test-SolutionXmlSchemaValidity.ps1` (must PASS — recurrence guard)
- `pac solution check --path <new-zip>` (Microsoft official validator)
- Byte-diff vs base 3.15 to confirm scope (expect: `solution.xml` version + 5 topic `data` files modified; everything else byte-equal)
- ASCII compliance scan on 5 topic data files
- SHA256 capture
- Pre-publish tenant snapshot refresh (re-baseline if drift detected since 19:50:32 BRT)

### Step 4 — Owner: Import to ColOfertasBrasilPro
- Capture `$publishUtc` BEFORE clicking Import
- `pac solution import --environment <env> --path <new-zip> --publish-changes` OR Power Automate UI Import
- Confirm import success
- Hard-refresh Copilot Studio + manual Publish do bot if needed

### Step 5 — Codex: Drift monitor (background, T+5/+1h/+6h)
- `Test-Aq08PublishDriftMonitor.ps1 -PublishUtc <captured-value>` running unattended in background

### Step 6 — Owner+Codex: AQ-09 smoke + evidence
- Owner runs AQ-09 chat smoke per runbook
- Codex runs Track G SP harness + Track H prepop + V2 validator on stubs

## Top Risks (v3 — narrowed)

1. **Workflow re-import cycle (MEDIUM, mitigated)** — 12 workflows will go through deactivate→replace→reactivate again. Per Microsoft docs this is by design when bot has flows as required objects. Mitigations active:
   - Schema guard blocks malformed ZIP before import
   - `pac solution check` runs before import
   - Drift monitor T+5/+1h/+6h confirms stability post-import
   - Workflow content unchanged → reactivation should succeed

2. **Topic period in name (LOW)** — Microsoft warns: *"You can't export a solution that contains an agent with periods (`.`) in the name of any of its topics."* The 5 in-scope topics use `pmo_AssistentePMO_V2.topic.<Name>` schema names. **The dot is in the schema name namespace, not the topic display name.** Risk: needs validation that Copilot Studio export accepts this. **Codex Step 3 will catch via `pac solution check`.**

3. **Owner UI execution risk (MEDIUM)** — Step 1 requires manual edits in Copilot Studio. Source-of-truth YAMLs are in `fixed_topic_yamls/`. Owner must replicate exactly. Mitigation: Codex Step 3 byte-diff vs source YAMLs flags any deviation before import.

4. **AQ-07 unaffected (LOW, confirmed)** — `PMO_AQ07_CopilotBinding` doesn't contain in-scope components. Will not be touched by this hotfix.

## Authorization status

- ✅ Phase A approval (4 leads + 10 subagents): SPENT (gap closed by recurrence guard)
- ❌ Phase D import attempt #1: FAILED (auto-rolled back)
- ✅ Codex PhD forensic: COMPLETE
- ✅ Codex topology mapping: COMPLETE
- ⏳ **Replan execution: REQUIRES OWNER step 1 + step 2 (Copilot Studio UI work) before Codex can dispatch step 3**
- ⏳ Drift monitor + AQ-09 smoke: contingent on successful step 4 import

## Sign-off (v3)
- **Incident Commander:** Kiro / Opus 4.7
- **Forensics + Topology:** Codex (PhD persona)
- **UTC v3:** 2026-05-21T20:25:00Z
- **Decision:** NO-SHIP — replan path D-1=A approved. Awaiting Owner UI execution (steps 1–2).
