# CODEX-PA + Gemini-PA Track I — Solution Hotfix Build (3.15 Topics + Flows Bundled)

Date BRT: 2026-05-21T12:30:00-03:00
Owner: Manoel Benicio
Author: Opus 4.7
Targets: CODEX-PA (Phases A-B, E), Gemini-PA (Phase C)
Severity: SEV-0 — replaces failed Code Editor paste delivery mechanism

## Why This Track Exists

Two independent Code Editor paste-and-save attempts produced regressions on different topics each time. The mechanism is fundamentally unreliable for this delivery. Owner experience confirms solution-import-via-portal/PAC is the reliable path. We rebuild a single ZIP that contains:

- The six flow file changes already in `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` (Gemini-certified PUBLISH_GO at artifact layer).
- The five corrected topic `botcomponent` rows derived from `fixed_topic_yamls/*.yaml` (CODEX-PA's v2 builder output, all 8 gates PASS, Track D-validated `result` binding key).

Owner imports once. All five topics + six flows land atomically in one transaction. No Copilot Studio Code Editor draft cache to fight.

## Mandatory References

| Reference | Purpose |
|---|---|
| `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` | Base ZIP. Contains six flow file changes vs 3.10. SHA256 `0A68BB03F9C79440EA9AA09F7E5EE067681FCBDE0241F51F4C27BEB8EA61A9A6`. |
| `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` | Rollback baseline. SHA256 `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`. |
| `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/*.yaml` | Five corrected topic YAMLs. v2 builder output, 8 gates PASS, Track D validated. |
| `.planning/comms/aq08_topic_routing_verification_20260520/post_remediation_reverify/fixed_topic_yamls/QA_EVIDENCE_v2.md` | Builder gate evidence. |
| `.planning/comms/aq08_flow_output_schemas_20260521/FLOW_OUTPUT_SCHEMA_AUDIT.md` | Authoritative `result` binding key for all five flows. |
| `.planning/comms/aq08_topic_routing_verification_20260520/anomaly_20260521_0457/topic_data_full_5/*.botcomponent_data.yaml` | Live tenant topic GUIDs (extract `botcomponentid`/topic schema names from these for the rebuild). |
| `.planning/comms/AGENTIC_DISPATCH_PROMPTS_ADAPTIVE_CARDS_PLANNER_20260514.md` | Past experience injecting components into solution zips. |
| Gemini-PA Track E audit at `.planning/comms/gemini_pa_pre_publish_audit_3_15_20260521/AUDIT_REPORT.md` | Audit baseline for the unmodified 3.15 zip. The new zip's audit is incremental against this. |

## Output Artifact

`Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`

Naming rationale: `3_15_1` = patch version increment over 3.15. `HOTFIX_TOPICS` makes scope explicit for the audit trail.

## Phase A — CODEX-PA: Solution Rebuild

1. Working dir: `.planning/comms/solution_3_15_1_hotfix_topics_20260521/build/`. Unpack `PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` into `unpacked_base/`.
2. From `topic_data_full_5/`, extract the existing topic `botcomponentid` GUIDs and `schemaName` for each of the five in-scope topics. These are the tenant identifiers that must be preserved so the import updates existing rows rather than creating new ones.
3. For each of the five topics, locate the corresponding `botcomponent` XML file inside `unpacked_base/`. If it does not exist (likely, since Gemini's audit said the base 3.15 contains only flow changes), generate it using the same XML structure as a tenant export: GUID, schemaName, content type, and `botcomponentdata` field whose value is the YAML from `fixed_topic_yamls/<topic>.yaml`.
4. Update `unpacked_base/solution.xml`:
   - Add five `RootComponent` entries of type `botcomponent` with the GUIDs from §2.
   - Bump `Version` from 3.15.x to 3.15.1.x (use existing minor counter +1).
   - Preserve all other manifest contents byte-for-byte.
5. Verify the 12 workflow components (Type 29) from the original 3.15 zip are unchanged byte-for-byte in the rebuild.
6. Repack into `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip` with the same compression and structure as the base.
7. Compute SHA256 of the new zip. Save under `build/sha256.txt`.

## Phase B — CODEX-PA: Gates G1-G9

Run gates against the rebuilt artifact. Gates G1-G8 mirror the existing `Build-Aq08FixedTopicYamls.py` gate set. New G9 enforces binding-variable consistency.

| Gate | Check |
|---|---|
| G1 | Zip parses; `solution.xml` valid XML; manifest counts match unpacked file counts. |
| G2 | All six flow workflow files byte-equal to base 3.15. |
| G3 | Five topic `botcomponent.data` YAMLs match `fixed_topic_yamls/<topic>.yaml` byte-for-byte. |
| G4 | All five topics carry GUIDs matching live tenant (from `topic_data_full_5/`). |
| G5 | All five topic YAMLs use `result:` binding key (Track D requirement). |
| G6 | Binding variable `Topic.<X>` matches `{Topic.<X>}` reference in same topic's `SendActivity`. |
| G7 | No legacy `PMO_PA_*` action references in any topic YAML. |
| G8 | ASCII-only check on all app-facing strings (extends from gated builder). |
| G9 | Power Automate workflow IDs referenced in topic YAMLs (`PM0_PA_Card_*`) match Track D's authoritative list. |

Capture per-gate evidence under `build/QA_EVIDENCE_HOTFIX_TOPICS.md`. Any FAIL = STOP and report.

## Phase C — Gemini-PA: Incremental Pre-Publish Audit

1. Run the same audit checks as the original Track E against `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`.
2. Specifically reconfirm:
   - No premium connectors introduced.
   - No ghost components.
   - ASCII compliance.
   - Diff vs `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` shows ONLY: (a) five new topic `botcomponent` rows, (b) `solution.xml` Version bump and RootComponents additions. No other changes.
3. Output: `.planning/comms/gemini_pa_audit_3_15_1_hotfix_topics_20260521/AUDIT_REPORT.md` with PUBLISH_GO/NO_GO and new SHA256.
4. Estimated 15-20 min (incremental on top of existing Track E audit).

## Phase D — Owner: Single Import

Owner imports `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip` via the preferred path. Two options:

- **PAC (recommended for audit trail):**
  ```powershell
  pac solution import --path "D:\VMs\Projetos\STT_Project_Management\Solution\PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip" --activate-plugins --force-overwrite --publish-changes
  ```
  Captures import log; supports rollback via `pac solution online-version`.
- **Power Automate / Power Platform portal:** upload the ZIP via Solutions tab, Import. Visual but no log unless you save the import notification.

`--publish-changes` triggers Copilot Studio bot publish as part of import for solution-aware bots. If this flag does not work for the bot, Owner manually clicks Publish in Copilot Studio after import.

## Phase E — CODEX-PA: Post-Import Verify

Run `tests/Test-Aq08PostRemediationReverify.ps1` immediately after Owner confirms import complete.

- Required: `OverallDecision: PASS`, exit 0, all five topics PASS, all five with `result:` binding key, all five with binding-variable consistency.
- Capture under `.planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/post_hotfix_import_<timestamp>/`.
- If PASS, run again 120 seconds later. Same evidence dir, suffix `_run2`.
- If both PASS with no per-topic content drift, recommend Owner publish complete; trigger drift monitoring per `.planning/comms/CODEX_PA_P0_W2_TRACK_B_ANOMALY_REMEDIATION_v2_20260521.md` Section F (+5 min, +1 h, +6 h reverifies).

## Hard Prohibitions

No tenant writes from any agent. No `pac solution import/publish` from any agent (Owner-only). No git commit. No modification of `tests/*` outside CODEX-QA's Track H scope. No edits to `Solution/PMO_v11_Tarefas_3_10_*` (rollback target). No edits to other agents' registry rows.

## Coordination

- CODEX-QA is finishing Track H. Their work writes to disjoint paths (`tests/Test-Aq08PublishDriftMonitor.ps1`, `tests/Build-Aq09EvidenceFromArtifacts.ps1`). No collision.
- CODEX-PA Phase A starts immediately. Owner waits.
- Gemini-PA Phase C waits for CODEX-PA Phase B PASS signal.
- Owner Phase D waits for Gemini-PA PUBLISH_GO.
- CODEX-PA Phase E waits for Owner import-complete signal.

## Acceptance Gate

Track I closed when:
1. Phase B: all 9 gates PASS.
2. Phase C: PUBLISH_GO with correct diff (only topic botcomponent additions + manifest version bump).
3. Phase E: two reverify PASS results 120 s apart with stable per-topic content.
4. Drift monitoring (+5 min / +1 h / +6 h) confirms no regression.

End of dispatch.
