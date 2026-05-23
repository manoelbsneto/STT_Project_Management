# EVIDENCE_LOG — Incident 3.15.1 Import Failure

| Item | Evidence Type | Link / Path | Command | Output Snippet | Notes |
|------|---------------|-------------|---------|----------------|------|
| E-001 | Failure log (Power Automate) | `C:\Users\dataops-lab\Downloads\PMO v1.1 - Task Management Topics_import (36).xml` | UI download from import dialog | `Status: Error; Mensaje: Import failed: Input string was not in a correct format.; Progreso: 54.05%; Duration: 71.6s; ErrorCode at Inserciones de componentes raíz: 0x80044150` | Authoritative failure log from tenant |
| E-002 | Hotfix solution.xml content | `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip` (extracted) | Compressed read | `<RootComponent type="botcomponent" id="{ec4416d0-...}" behavior="0" />` (×5) | Confirms hand-crafted RootComponent entries with non-integer type attribute |
| E-003 | Base 3.15 solution.xml | `Solution/PMO_v11_Tarefas_3_15_LIST_STATIC_RUNTIME_BYPASS.zip` (extracted) | Compressed read | All 12 RootComponents have `type="29"` (integer) | Establishes canonical pattern: integer-only types in working ZIPs |
| E-004 | PROD_EXPORT solution.xml (real tenant export) | `.planning/comms/prod_compare_20260511_1914/PMO_v11_Tarefas_PROD_EXPORT.zip` | Compressed read | All 14 RootComponents `type="29"`. Zero `type="botcomponent"` entries. MissingDependencies uses `type="connectionreference"` (string) — separate context | Tenant's own export confirms RootComponents use integer types only |
| E-005 | **Tenant runtime state of 12 PMO_PA_* workflows** | **PENDING** — Owner to capture | Power Automate UI → Soluções → PMO_v11_Tarefas → Componentes → Fluxos da nuvem | **NOT YET CAPTURED** | Critical evidence for CA-001 |
| E-006 | Track I original dispatch | `.planning/comms/CODEX_PA_GEMINI_PA_TRACK_I_SOLUTION_HOTFIX_BUILD_20260521.md` | File read | "Add five RootComponent entries of type botcomponent with the GUIDs from §2." | Source of the bug-introducing instruction |
| E-007 | Phase A independent review verdict | `.planning/comms/independent_review_3_15_1_20260521/CONSOLIDATED_VERDICT.md` | File read | 4/4 leads verdict PUBLISH_GO; none validated Dataverse type-code | Documents the audit gap |
| E-008 | GOLDEN_RULES Microsoft Docs Rule | `.planning/GOLDEN_RULES.md` lines ~52-65 | File read | "Microsoft behavior is inferred from memory, blogs, or guesses instead of official Microsoft documentation." | Rule that was violated |
| E-009 | Live workflow baseline pre-publish | `.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/workflows/` | File listing | 12 .clientdata.live.json files with SHA256 each | Codex #1 captured pre-publish state — useful as drift reference |
| E-010 | Live topic baseline pre-publish | `.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/topics/` | File listing | 5 .botcomponent_data.live.yaml files with SHA256 each | Codex #1 captured pre-publish state — confirms topics were NOT modified by failed import |
| E-011 | Rollback ZIP integrity | `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip` | Get-FileHash | `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691` | Codex #1 confirmed match. Rollback artifact intact and ready. |
| E-012 | Staged rollback script | `.planning/comms/independent_review_3_15_1_20260521/pre_publish_live_baseline/rollback_ready.ps1` | PowerShell parser validation | Parser PASS; marker `DO NOT EXECUTE WITHOUT OWNER APPROVAL` present; import command commented out | Codex #1 staged. NOT YET EXECUTED. |

## Pending evidence (NO-SHIP gates depend on these)

- **E-005**: Tenant workflow runtime state. Owner to capture from Power Automate UI. Without this, we cannot decide between (a) replan from stable tenant or (b) execute rollback. **HIGHEST PRIORITY.**
- **E-013** (future): If rollback executed → post-rollback tenant state evidence
- **E-014** (future): Owner-specified canonical project method for shipping bot/topic changes via solution

## Notes
- All evidence captured here is read-only or owner-supplied. No tenant writes have been performed by any agent during this incident response.
- Quarantine: the failed hotfix ZIP must NOT be re-imported in any form. It is preserved as evidence E-002 only.
