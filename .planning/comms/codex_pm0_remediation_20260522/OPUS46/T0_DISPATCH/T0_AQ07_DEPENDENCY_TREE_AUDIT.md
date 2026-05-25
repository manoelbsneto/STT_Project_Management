# T0 AQ07 Dependency Tree Audit — Read-Only

| Field | Value |
|---|---|
| Author | Opus 4.6 (Track Γ — Architecture + Risk) |
| Created | 2026-05-23 16:33:00 BRT |
| Last updated | 2026-05-23 16:33:00 BRT |
| Scope | Read-only analysis of `PMO_AQ07_CopilotBinding` solution (exported v1.0.0.1) vs `PMO_v11_Tarefas` solution (exported v3.16) |
| Source exports | `C:\Users\dataops-lab\Downloads\PMO_AQ07_CopilotBinding_1_0_0_1.zip` (SHA256 `9171EF1A605A66EF4580033A2662DC864069428105208355047DEB9D80E87F44`, 76,819 bytes) and `C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_3_16.zip` (SHA256 `28508055F5A22F96DC998AE8F3B8F0EC77AEEE1F9C51D5AECFCA78A1898EC598`, 71,806 bytes) |
| Corrected local package | `.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` (SHA256 `3327BD0F2E7FB3805BEA9C70D23F564F15714DAC5B6CD8451958D430F991E7EB`) — this is the Gate 4A import candidate, NOT the raw export |
| Tenant writes | NONE — this is a read-only audit |

---

## 1. AQ07 Solution Manifest

| Property | Value |
|---|---|
| UniqueName | `PMO_AQ07_CopilotBinding` |
| Display Name | `PMO AQ07 Copilot Binding` |
| Version | `1.0.0.1` |
| Managed | `0` (unmanaged) |
| Publisher | `DefaultPublishercolofertasbrasilpro` (prefix: `pmo`) |

### 1.1 Root Components (type=29 = Workflow)

AQ07 declares **16 root components**, all type `29` (Workflow/Process):

| Root Component ID | Workflow Name | Category |
|---|---|---|
| `{1721e0a3-a250-f111-bec7-000d3abc5cc6}` | PM0_PA_Card_AtualizarStatus | **PM0 card-first** |
| `{7c6300c2-a250-f111-bec7-000d3abc5cc6}` | PM0_PA_Card_AtualizarTarefa | **PM0 card-first** |
| `{7f662db7-a250-f111-bec7-000d3abc5cc6}` | PM0_PA_Card_CriarTarefa | **PM0 card-first** |
| `{8333bd91-a250-f111-bec7-000d3abc5cc6}` | PM0_PA_Card_ResumoExecutivoPortfolio | **PM0 card-first** |
| `{9531fbc7-a250-f111-bec7-000d3abc5cc6}` | PM0_PA_OpsFailureHandling | **PM0 shared error handler** |
| `{e0e3c6b0-a250-f111-bec7-000d3abc5cc6}` | PM0_PA_Card_ListarTarefas | **PM0 card-first** |
| `{0a5d2a41-24c0-4d5e-9f6d-000000000241}` | PMO_PA_CriarTarefa | Legacy |
| `{16fbe313-2edc-406e-ad7f-d08cee0edc43}` | PMO_PA_ExcluirProjeto | Legacy |
| `{3104124d-364a-f111-bec7-7ced8d955c6c}` | PMO_PA_CriarProjeto | Legacy |
| `{3ec37952-c64c-f111-bec7-000d3abc5cc6}` | PMO_PA_RegistrarBloqueioBot | Legacy |
| `{4a33b53e-c64c-f111-bec7-000d3abc5cc6}` | PMO_PA_ConsultarProjeto | Legacy |
| `{70b39334-5926-4fb1-bd22-f10bd99f0f6d}` | PMO_PA_ExcluirTarefa | Legacy |
| `{9544f14b-3748-f111-bec7-6045bdf42cae}` | PMO_PA_ListarTarefas | Legacy |
| `{98408d55-3748-f111-bec7-000d3abc5cc6}` | PMO_PA_AtualizarTarefa | Legacy |
| `{ee732d46-c64c-f111-bec7-7ced8d955c6c}` | PMO_PA_RegistrarRiscoBot | Legacy |
| `{feb79d54-c64c-f111-bec7-7ced8d955c6c}` | PMO_PA_PedirDecisaoBot | Legacy |

### 1.2 Missing Dependencies

AQ07 declares one `MissingDependency`:

| Dependent Component | Required Component | Required Solution |
|---|---|---|
| PM0_PA_Card_ListarTarefas (`{e0e3c6b0-...}`) | `cat_DataverseIndexerSharePoint` (connection reference) | CopilotStudioAccelerator (20260313.2) |

This means `PM0_PA_Card_ListarTarefas` depends on a SharePoint connection reference from the Copilot Studio Accelerator solution. This dependency must exist in the tenant before the workflow can function.

---

## 2. AQ07 Botcomponents (27 folders)

AQ07 carries the **exact same 27 botcomponent folders** as `PMO_v11_Tarefas` v3.16 export:

### 2.1 PM0 Card-First Action Components (5 + 1 error handler)

| Component Schema Name | PM0 Workflow ID | Workflowset Entry in AQ07? | Workflowset Entry in PMOv11? |
|---|---|---|---|
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-...` | **YES** | **NO** |
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-...` | **YES** | **NO** |
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-...` | **YES** | **NO** |
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-...` | **YES** | **NO** |
| `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-...` | **YES** | **NO** |
| `pmo_AssistentePMO_V2.action.PM0_PA_OpsFailureHandling` | `9531fbc7-...` | **YES** | **NO** |

### 2.2 Legacy Action Components (4)

| Component Schema Name | Legacy Workflow ID | Workflowset Entry in AQ07? | Workflowset Entry in PMOv11? |
|---|---|---|---|
| `pmo_AssistentePMO_V2.action.PMO_PA_AtualizarTarefa` | `98408d55-...` | **YES** | **YES** |
| `pmo_AssistentePMO_V2.action.PMO_PA_CriarProjeto` | `3104124d-...` | **YES** | **YES** |
| `pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa` | `0a5d2a41-...` | **YES** | **YES** |
| `pmo_AssistentePMO_V2.action.PMO_PA_ListarTarefas` | `9544f14b-...` | **YES** | **YES** |

### 2.3 Topic Components (16)

All 16 topics exist in both solutions — including the 5 in-scope PM0 topics, 7 legacy topics, and 4 non-routed topics.

### 2.4 Other Components (1)

| Component | In AQ07? | In PMOv11? |
|---|---|---|
| `pmo_AssistentePMO_V2.gpt.default` | YES | YES |

---

## 3. Workflow File Ownership

| Workflow JSON | In AQ07 Package? | In PMOv11 Export? | In PMOv11 Root Components? |
|---|---|---|---|
| PM0_PA_Card_AtualizarStatus (`1721e0a3-...`) | **YES** | **NO** | **NO** |
| PM0_PA_Card_AtualizarTarefa (`7c6300c2-...`) | **YES** | **NO** | **NO** |
| PM0_PA_Card_CriarTarefa (`7f662db7-...`) | **YES** | **NO** | **NO** |
| PM0_PA_Card_ListarTarefas (`e0e3c6b0-...`) | **YES** | **NO** | **NO** |
| PM0_PA_Card_ResumoExecutivoPortfolio (`8333bd91-...`) | **YES** | **NO** | **NO** |
| PM0_PA_OpsFailureHandling (`9531fbc7-...`) | **YES** | **NO** | **NO** |
| PMO_PA_AtualizarStatus (legacy, `c11a165b-...`) | **NO** | **YES** | **YES** |
| PMO_PA_AtualizarTarefa (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_ConsultarPortfolio (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_ConsultarProjeto (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_CriarProjeto (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_CriarTarefa (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_ExcluirProjeto (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_ExcluirTarefa (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_ListarTarefas (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_PedirDecisaoBot (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_RegistrarBloqueioBot (legacy) | **NO** | **YES** | **YES** |
| PMO_PA_RegistrarRiscoBot (legacy) | **NO** | **YES** | **YES** |

**Key Finding:** The 6 PM0 card-first workflow JSON files exist **only** in AQ07. PMOv11 v3.16 raw export has **zero** PM0 workflow files.

---

## 4. Workflowset Binding Analysis

### 4.1 AQ07 `botcomponent_workflowset.xml` — 17 entries

**PM0 card-first action→workflow bindings (6):**
1. `PM0_PA_Card_AtualizarStatus` → `1721e0a3-...` ✅
2. `PM0_PA_Card_AtualizarTarefa` → `7c6300c2-...` ✅
3. `PM0_PA_Card_CriarTarefa` → `7f662db7-...` ✅
4. `PM0_PA_Card_ListarTarefas` → `e0e3c6b0-...` ✅
5. `PM0_PA_Card_ResumoExecutivoPortfolio` → `8333bd91-...` ✅
6. `PM0_PA_OpsFailureHandling` → `9531fbc7-...` ✅

**Legacy action→workflow bindings (4):**
7. `PMO_PA_AtualizarTarefa` → `98408d55-...`
8. `PMO_PA_CriarProjeto` → `3104124d-...`
9. `PMO_PA_CriarTarefa` → `0a5d2a41-...`
10. `PMO_PA_ListarTarefas` → `9544f14b-...`

**Legacy topic→workflow bindings (7):**
11. `topic.ConsultarProjeto` → `4a33b53e-...`
12. `topic.ExcluirProjeto` → `16fbe313-...`
13. `topic.ExcluirTarefa` → `70b39334-...`
14. `topic.PedirDecisao` → `feb79d54-...`
15. `topic.RegistrarBloqueio` → `3ec37952-...`
16. `topic.RegistrarRisco` → `ee732d46-...`

*(Missing from list but noted: PMO_PA_AtualizarStatus legacy `c11a165b-...` is NOT in AQ07 workflowset; its workflow file is only in PMOv11.)*

### 4.2 PMOv11 `botcomponent_workflowset.xml` — 10 entries

**Legacy action→workflow bindings (4):**
1. `PMO_PA_AtualizarTarefa` → `98408d55-...`
2. `PMO_PA_CriarProjeto` → `3104124d-...`
3. `PMO_PA_CriarTarefa` → `0a5d2a41-...`
4. `PMO_PA_ListarTarefas` → `9544f14b-...`

**Legacy topic→workflow bindings (6):**
5. `topic.ConsultarProjeto` → `4a33b53e-...`
6. `topic.ExcluirProjeto` → `16fbe313-...`
7. `topic.ExcluirTarefa` → `70b39334-...`
8. `topic.PedirDecisao` → `feb79d54-...`
9. `topic.RegistrarBloqueio` → `3ec37952-...`
10. `topic.RegistrarRisco` → `ee732d46-...`

**ZERO PM0 card-first bindings.** This confirms EXPORT_RECONCILIATION Finding 3.

---

## 5. Dual-Ownership / Duplicate-Component Anti-Pattern Analysis

### 5.1 Scope of Duplication

**All 27 botcomponent folders are identical between both solutions.** Both exports carry the exact same set of:
- 5 PM0 card-first action components
- 1 PM0 shared error handler action
- 4 legacy action components
- 16 topic components (5 in-scope PM0 + 7 legacy + 4 non-routed)
- 1 GPT default component

### 5.2 Microsoft Learn Violation

> **"Don't include the same unmanaged component in more than one solution."**
> — Microsoft Learn, *Organize your solutions*, `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions`

Both `PMO_AQ07_CopilotBinding` and `PMO_v11_Tarefas` are **unmanaged** (`Managed=0`). Having all 27 botcomponents appear in both solutions is a direct violation of Microsoft's stated best practice for unmanaged solution ALM.

### 5.3 Risk Assessment of Dual Ownership

| Risk | Severity | Description |
|---|---|---|
| **Import-order ambiguity** | HIGH | For unmanaged solutions, the last import determines runtime behavior. If AQ07 is imported after a corrected PMOv11 3.16, the AQ07 workflowset (which contains the PM0 bindings) would layer on top. If PMOv11 3.16 is imported after AQ07, PMOv11's workflowset (which lacks PM0 bindings) could overwrite AQ07's PM0 bindings. |
| **Rollback confusion** | HIGH | Rolling back PMOv11 to 3.10 or 3.15.1 does not roll back AQ07-owned PM0 workflows. Rolling back AQ07 alone removes the PM0 workflow JSON files but leaves PM0 botcomponents orphaned in PMOv11. |
| **Audit opacity** | MEDIUM | Two solutions claim the same components, making it impossible to determine from solution list alone which solution "owns" runtime behavior for a given component. |
| **Future cleanup cost** | MEDIUM | Every future import of either solution must be validated against the other to prevent unintended overwrites. |

---

## 6. Runtime Reference Map (from merged RCA + ADR)

### 6.1 In-Scope PM0 Topics → Actions → Workflows

| Topic | Calls Action | Action Calls Workflow | Workflow ID |
|---|---|---|---|
| AtualizarStatus | PM0_PA_Card_AtualizarStatus | PM0_PA_Card_AtualizarStatus | `1721e0a3-...` |
| AtualizarTarefa | PM0_PA_Card_AtualizarTarefa | PM0_PA_Card_AtualizarTarefa | `7c6300c2-...` |
| ConsultarPortfolio | PM0_PA_Card_ResumoExecutivoPortfolio | PM0_PA_Card_ResumoExecutivoPortfolio | `8333bd91-...` |
| CriarTarefa | PM0_PA_Card_CriarTarefa | PM0_PA_Card_CriarTarefa | `7f662db7-...` |
| ListarTarefas | PM0_PA_Card_ListarTarefas | PM0_PA_Card_ListarTarefas | `e0e3c6b0-...` |

**All 5 PM0 workflows are owned by AQ07 in the exported state.** The corrected 3.16 local package `3327BD0F...` was built to consolidate these into PMOv11 (Option A), but the tenant has not been updated yet.

### 6.2 Legacy Topics → Workflows (unchanged, PMOv11-owned)

| Topic | Direct Workflow | Workflow ID | Solution Owner |
|---|---|---|---|
| ConsultarProjeto | PMO_PA_ConsultarProjeto | `4a33b53e-...` | PMOv11 (workflow JSON) + both (workflowset) |
| CriarProjeto | PMO_PA_CriarProjeto | `3104124d-...` | PMOv11 (workflow JSON) + both (workflowset) |
| ExcluirProjeto | PMO_PA_ExcluirProjeto | `16fbe313-...` | PMOv11 (workflow JSON) + both (workflowset) |
| ExcluirTarefa | PMO_PA_ExcluirTarefa | `70b39334-...` | PMOv11 (workflow JSON) + both (workflowset) |
| PedirDecisao | PMO_PA_PedirDecisaoBot | `feb79d54-...` | PMOv11 (workflow JSON) + both (workflowset) |
| RegistrarBloqueio | PMO_PA_RegistrarBloqueioBot | `3ec37952-...` | PMOv11 (workflow JSON) + both (workflowset) |
| RegistrarRisco | PMO_PA_RegistrarRiscoBot | `ee732d46-...` | PMOv11 (workflow JSON) + both (workflowset) |

---

## 7. Gate 4C Cleanup Recommendations

### 7.1 HALT CONDITION TRIGGERED

> **⚠️ The AQ07 dependency tree shows components dual-owned with PMOv11 PM0 entries.**

Per the dispatch stop condition: "AQ07 dependency tree shows any component dual-owned with PMO_v11_Tarefas PM0 entries → halt + write recommendation that delays Gate 4C until further investigation."

**All 27 botcomponents** in AQ07 are dual-owned — they exist identically in both solutions. This includes the 5 PM0 card-first action components and all 16 topics.

### 7.2 Recommendation: Delay Gate 4C Until Post-Import Tenant Inventory

Gate 4C cleanup of `PMO_AQ07_CopilotBinding` **must not proceed** until:

1. **The corrected 3.16 package (`3327BD0F...`) is successfully imported into PMOv11** (Gate 4A) and published (Gate 4B). This package includes the PM0 workflow files and workflowset bindings that currently exist only in AQ07.

2. **A read-only tenant `solutioncomponent` query** confirms that after import, `PMO_v11_Tarefas` now owns all 6 PM0 workflow root components in the environment. Without this, deleting AQ07 could remove the **only** solution-level ownership record for those workflows.

3. **AQ-09 Section A runtime smoke passes** (A1–A5), confirming the PM0 card-first paths work correctly through `PMO_v11_Tarefas` alone.

4. **A read-only dependency inventory** of `PMO_AQ07_CopilotBinding` in tenant confirms it has no unique live dependencies beyond what PMOv11 now provides.

### 7.3 Component Safety Classification

| Component Category | Count | Safe to Remove in Gate 4C? | Rationale |
|---|---|---|---|
| PM0 card-first workflows (JSON files) | 6 | **RISKY until post-import** — Only after corrected PMOv11 3.16 is imported and carries these workflows | Currently AQ07 is the ONLY package that exports these workflow definitions |
| PM0 card-first workflowset bindings | 6 | **RISKY until post-import** — Same as above; PMOv11 raw export has 0 PM0 bindings | The corrected 3.16 local package adds these, but tenant has not been written yet |
| Legacy workflow root components | 10 | **SAFE** — These workflows exist in PMOv11 with both JSON files and workflowset entries | Both solutions have these; removing from AQ07 reduces duplication |
| All 27 botcomponent folders | 27 | **RISKY until post-import verification** — Botcomponents are dual-owned; removing AQ07's copy before confirming PMOv11's copy is authoritative risks runtime behavior change | Microsoft Learn warns against import-order dependency for same components in multiple unmanaged solutions |

### 7.4 Recommended Gate 4C Approach (post-import, post-AQ-09)

**Option (d) from EXPORT_RECONCILIATION — staged cleanup:**

1. After corrected 3.16 import + publish + AQ-09 PASS:
   - Run `pac env fetch` with FetchXML for `solutioncomponent` table, filtered by `PMO_AQ07_CopilotBinding` solution ID.
   - Verify each AQ07 root component also exists as a root or dependent component in `PMO_v11_Tarefas`.
   - If AQ07 has **zero unique dependencies** not covered by PMOv11: recommend `pac solution delete --solution-name PMO_AQ07_CopilotBinding` under explicit Owner per-step approval.
   - If AQ07 has any unique dependency: document it, do NOT delete, escalate for architecture review.

2. After deletion: re-run AQ-08 structural verifier to confirm all routes still resolve, then AQ-09 A1 quick-check.

---

## 8. Microsoft Learn Citations

| # | Claim | Source | Accessed |
|---|---|---|---|
| 1 | Multiple unmanaged solutions in one development environment are for distinct independent functional areas that do not share components. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | 2026-05-22 17:18 BRT (Codex #1) |
| 2 | "Don't include the same unmanaged component in more than one solution." | Same URL | Same |
| 3 | Dependencies between solutions are allowed but create import-order and target-environment availability requirements. | Same URL | Same |
| 4 | If components are missing in the target environment, solution import can fail. | `https://learn.microsoft.com/en-us/troubleshoot/power-platform/dataverse/working-with-solutions/missing-dependency-on-solution-import` | 2026-05-22 17:18 BRT (Codex #1) |
| 5 | Solution layering is component-level; for most components other than model-driven app/form/site map, top layer wins. | `https://learn.microsoft.com/en-us/power-platform/alm/solution-layers-alm` | 2026-05-22 17:18 BRT (Codex #1) |
| 6 | `pac solution delete` is an official command for deleting a solution from Dataverse. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` | 2026-05-22 17:36 BRT (Codex #1) |

---

## 9. Summary Findings

| Finding | Severity | Impact on Gate 4C |
|---|---|---|
| **F1:** All 27 botcomponents dual-owned across both unmanaged solutions | SEV-0 (anti-pattern) | Cleanup must be sequenced AFTER import, not before |
| **F2:** 6 PM0 workflow JSON files exist ONLY in AQ07 export | SEV-0 (single point of failure) | Cannot delete AQ07 until corrected PMOv11 carries these workflows |
| **F3:** 6 PM0 workflowset bindings exist ONLY in AQ07 export | SEV-0 (binding gap) | Corrected 3.16 package (`3327BD0F...`) adds these; must verify post-import |
| **F4:** AQ07 PM0 workflows contain placeholder responses (pre-Alpha-fix) | HIGH | Irrelevant to cleanup if corrected 3.16 overwrites them, but tenant state must be verified |
| **F5:** AQ07 has 1 MissingDependency (SharePoint connection ref from CopilotStudioAccelerator) | MEDIUM | This dependency must exist in tenant; it is on `ListarTarefas` workflow |
| **F6:** PMOv11 v3.16 root components do NOT include any PM0 workflow IDs | HIGH | Corrected local package must add PM0 root components; needs post-import verification |

---

## 10. Architectural Verdict

**Gate 4C is BLOCKED** pending:
1. Gate 4A (import corrected 3.16) — transfers PM0 workflow ownership to PMOv11
2. Gate 4B (publish) — activates new bindings
3. AQ-09 Section A PASS — confirms runtime correctness
4. Post-import tenant solutioncomponent inventory — confirms dual ownership resolved
5. Explicit Owner per-step approval for AQ07 deletion or component removal

This audit unblocks Sub 1C's Gate 4C ASK draft by providing the component list and dependency analysis. Sub 1C should use Sections 7.3 and 7.4 for the cleanup component list and verification commands.

---

Last updated: 2026-05-23 16:35:00 BRT | Opus 4.6 | Initial audit complete.
