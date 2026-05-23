# Export Reconciliation - PMO 3.16 / AQ07 Binding

Last updated: 2026-05-22 17:36:06 BRT | Codex #1 | Added updated opinion after Codex #2 rebuilt package consistency check.

## Source Exports

| Package | SHA256 | Size | LastWriteTime |
|---|---:|---:|---|
| `C:\Users\dataops-lab\Downloads\PMO_AQ07_CopilotBinding_1_0_0_1.zip` | `9171EF1A605A66EF4580033A2662DC864069428105208355047DEB9D80E87F44` | 76819 | 2026-05-22 17:03:13 |
| `C:\Users\dataops-lab\Downloads\PMO_v11_Tarefas_3_16.zip` | `28508055F5A22F96DC998AE8F3B8F0EC77AEEE1F9C51D5AECFCA78A1898EC598` | 71806 | 2026-05-22 17:04:56 |

## Finding 1 - Same Bot Components Exist in Both Solutions

Both ZIPs contain the exact same 27 `botcomponents/*` folders. Relevant overlaps include:

- `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus`
- `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa`
- `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa`
- `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas`
- `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio`
- `pmo_AssistentePMO_V2.topic.AtualizarStatus`
- `pmo_AssistentePMO_V2.topic.AtualizarTarefa`
- `pmo_AssistentePMO_V2.topic.ConsultarPortfolio`
- `pmo_AssistentePMO_V2.topic.CriarTarefa`
- `pmo_AssistentePMO_V2.topic.ListarTarefas`

This is not a clean ownership boundary for these two unmanaged exports. Microsoft does allow multiple-solution strategies, but its Power Platform ALM guidance says multiple unmanaged solutions in the same development environment should be used for distinct independent functional areas that do not share components, and explicitly says: "Don't include the same unmanaged component in more than one solution."

Vendor basis:

- Microsoft Learn, `Organize your solutions`, accessed 2026-05-22 17:18:00 BRT: multiple unmanaged solutions are recommended for distinct independent functional areas that do not share components.
- Microsoft Learn, `Organize your solutions`, accessed 2026-05-22 17:18:00 BRT: "Don't include the same unmanaged component in more than one solution."
- Microsoft Learn, `Missing dependencies error during solution import`, accessed 2026-05-22 17:18:00 BRT: reusing existing components is supported, but dependencies must exist in target environments and only necessary components should be included.

## Finding 2 - PM0 Workflows Are Only in AQ07 Binding Export

`PMO_AQ07_CopilotBinding_1_0_0_1.zip` contains all five PM0 workflow JSON files and solution root components:

- `Workflows/PM0_PA_Card_AtualizarStatus-1721E0A3-A250-F111-BEC7-000D3ABC5CC6.json`
- `Workflows/PM0_PA_Card_AtualizarTarefa-7C6300C2-A250-F111-BEC7-000D3ABC5CC6.json`
- `Workflows/PM0_PA_Card_CriarTarefa-7F662DB7-A250-F111-BEC7-000D3ABC5CC6.json`
- `Workflows/PM0_PA_Card_ListarTarefas-E0E3C6B0-A250-F111-BEC7-000D3ABC5CC6.json`
- `Workflows/PM0_PA_Card_ResumoExecutivoPortfolio-8333BD91-A250-F111-BEC7-000D3ABC5CC6.json`

`PMO_v11_Tarefas_3_16.zip` does not contain those five workflow JSON files and does not include those five workflow root components.

## Finding 3 - PM0 Workflowset Bindings Are Only in AQ07 Binding Export

`PMO_AQ07_CopilotBinding_1_0_0_1.zip` maps each PM0 action component to its PM0 workflow in `Assets/botcomponent_workflowset.xml`.

`PMO_v11_Tarefas_3_16.zip` contains the same PM0 action components with `flowId` values in action data, but its `Assets/botcomponent_workflowset.xml` omits all five PM0 action-to-workflow mappings.

## Finding 4 - AQ07 PM0 Workflow Bodies Do Not Match Local Alpha Fixes

The five PM0 workflows in `PMO_AQ07_CopilotBinding_1_0_0_1.zip` do not match local Alpha SHA256 values.

| Flow | AQ07 workflow present | PMO_v11 workflow present | AQ07 matches local Alpha | AQ07 placeholder response |
|---|---:|---:|---:|---:|
| AtualizarStatus | YES | NO | NO | YES: `Status update card posted successfully.` |
| AtualizarTarefa | YES | NO | NO | YES: `Task updated successfully.` |
| CriarTarefa | YES | NO | NO | YES: `Task created successfully.` |
| ListarTarefas | YES | NO | NO | YES: `Tasks retrieved successfully.` |
| ResumoExecutivoPortfolio | YES | NO | NO | YES: `Executive portfolio retrieved successfully.` |

## Alignment With Previous Codex Analysis

The earlier Codex statement that active `PMO_v11_Tarefas_3_16.zip` lacked `PM0_PA_Card_*` workflow entries is confirmed.

The new export evidence adds a stronger blocker: the PM0 action/topic components are duplicated across both solution exports, while the actual PM0 workflow bodies and workflowset mappings live only in `PMO_AQ07_CopilotBinding_1_0_0_1.zip`, and those workflow bodies still contain placeholder responses.

## Microsoft Learn Interpretation

Microsoft does not say "all releases must be one solution." A consolidated solution and a split solution can both be valid ALM designs.

Microsoft does say the following constraints matter here:

1. Multiple unmanaged solutions in the same development environment are intended for distinct independent modules that do not share components.
2. The same unmanaged component should not be included in more than one solution.
3. Dependencies between solutions are allowed, but they impose import-order and target-environment availability requirements.
4. If components are missing in the target environment, solution import can fail.
5. Multiple managed solution layers can use top-layer behavior where the upper layer determines runtime behavior for most components.

Therefore, this export set is not blocked because it is split. It is blocked because it is split while duplicating the same unmanaged bot components across both packages, and because the package containing the PM0 workflows still contains placeholder responses.

## Codex #1 Recommendation

### Recommendation Summary

**Choose Option A: `PMO_v11_Tarefas` owns the PM0 3.16 runtime bundle.**

For 3.16, `PMO_v11_Tarefas` should own the five PM0 topics, five PM0 action components, five PM0 workflow JSON files, and the PM0 `botcomponent_workflowset.xml` mappings. `PMO_AQ07_CopilotBinding` should not ship duplicate PM0 bot components in the 3.16 release path. If it remains in the environment, treat it as historical/transition evidence or a retired binding patch, not as the ongoing owner of PM0 runtime components.

### Microsoft Learn Basis

| Claim | Microsoft Learn citation |
|---|---|
| Multiple solutions are allowed when planned as part of solution strategy. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:18:00 BRT | Microsoft asks teams to plan solution architecture, including how many solutions are managed and whether solutions share components or depend on each other. |
| Single solution is recommended for small-medium implementations where future modularization is unlikely; advantages include simpler deployment and easier audit/change management. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:18:00 BRT | The single solution strategy groups customizations into one unmanaged development solution and exports one managed deployment solution; listed advantages are simplified deployment and easier locate/audit/manage changes. |
| Multiple unmanaged solutions in one development environment are recommended for distinct independent functional areas that do not share components. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:18:00 BRT | Microsoft describes this strategy as for unrelated features/modules and explicitly says these areas do not share components. |
| Microsoft explicitly says not to include the same unmanaged component in more than one solution. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:18:00 BRT | Microsoft lists as an important rule: "Don't include the same unmanaged component in more than one solution." |
| Cross-solution dependencies are allowed but create deployment/order risk. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:18:00 BRT | Microsoft says dependencies enforce an import order and can cause issues; its example says a flow may install successfully but not work if the needed dependent component is not recognized/imported. |
| Dependencies must exist in the target environment or import can fail. | `https://learn.microsoft.com/en-us/troubleshoot/power-platform/dataverse/working-with-solutions/missing-dependency-on-solution-import` | accessed 2026-05-22 17:18:00 BRT | Microsoft says if a solution has dependencies on components in the source environment, those components must exist in the target environment for manual import or pipeline deployment. |
| Solution layering is component-level and top layer can determine runtime behavior for most component types. | `https://learn.microsoft.com/en-us/power-platform/alm/solution-layers-alm` | accessed 2026-05-22 17:18:00 BRT | Microsoft says solution layering is implemented at component level; for most components other than model-driven app/form/site map, top layer wins. |

### Option A - `PMO_v11_Tarefas` Owns PM0

**Shape:** `PMO_v11_Tarefas_3_16` contains the PM0 topics, PM0 actions, PM0 workflows, and PM0 action-to-workflow mappings. `PMO_AQ07_CopilotBinding` does not contain duplicate PM0 bot components in the active release path.

| Dimension | Trade-off |
|---|---|
| Microsoft Learn alignment | Strongest fit. PM0 is part of the same PMO application/release scope, not an unrelated module. This avoids the documented anti-pattern of the same unmanaged component appearing in more than one solution. |
| Rollback path | Cleaner. Rollback can target the main PMO release package lineage (`PMO_v11_Tarefas` and the known 3.10 rollback target) instead of coordinating a second binding solution rollback. |
| Dependency tree | Smaller. The bot topics/actions/workflows are in the same app solution, reducing cross-solution dependency and import-order risk. |
| Future maintenance | Easier for owner and future agents. One package represents PMO 3.16 runtime state, so audits, diffs, package gates, and smoke evidence map to one artifact. |
| Owner UI complexity | Lower. Owner validates one main PMO package and one publish path rather than reasoning about a separate binding package that carries overlapping bot components. |
| Cost/risk | Requires rebuilding `PMO_v11_Tarefas_3_16` to include PM0 workflows and workflowset bindings, and cleaning/retiring `PMO_AQ07_CopilotBinding` as an active owner. |

### Option B - `PMO_AQ07_CopilotBinding` Owns PM0

**Shape:** `PMO_AQ07_CopilotBinding` contains the PM0 topics, actions, workflows, and workflowset mappings. `PMO_v11_Tarefas` removes duplicate PM0 bot components and depends on the binding solution for PM0 runtime.

| Dimension | Trade-off |
|---|---|
| Microsoft Learn alignment | Possible only if treated as a distinct module/layer with explicit dependency order, not as a duplicate component container. It still must remove duplicate unmanaged components from `PMO_v11_Tarefas`. |
| Rollback path | More complex. PM0 rollback requires coordinating the binding package and main PMO package because bot runtime behavior crosses package boundaries. |
| Dependency tree | Larger. `PMO_v11_Tarefas` depends on the binding solution being present and correct in the target environment. Microsoft documents that dependencies must exist or import can fail. |
| Future maintenance | Harder. Agents must always inspect two artifacts to understand one bot runtime path. This repeats the current failure mode where topics/actions live in both exports while workflows live in only one. |
| Owner UI complexity | Higher. Owner must track which solution owns bot components versus workflows/bindings and ensure imports happen in the correct order. |
| Cost/risk | May be useful only if AQ07 is intentionally promoted to a permanent app-layer solution. Current naming and history indicate it was a binding patch, not the product release owner. |

### Technical Choice

Codex #1 recommends **Option A** because PM0 card-first behavior is the core of the 3.16 PMO release, not an independent module. Microsoft Learn allows multiple-solution architectures, but the current exports violate the cleaner multiple-solution pattern because the same unmanaged bot components are present in both packages while only one package contains the PM0 workflows and mappings. Keeping the full PM0 runtime bundle inside `PMO_v11_Tarefas_3_16` gives the owner one auditable release artifact, reduces dependency/import-order risk, keeps rollback aligned with the main PMO package lineage, and removes the ambiguity that caused the current mismatch.

### Action Plan - Option A

1. **Read-only inventory:** Expand both owner-exported ZIPs to evidence folders and record SHA256, solution unique name, version, managed flag, component counts, and PM0 component list.
2. **Read-only dependency check:** Inspect `solution.xml`, `customizations.xml`, `[Content_Types].xml`, and `Assets/botcomponent_workflowset.xml` in both packages for PM0 component ownership, root components, dependent components, and missing dependencies.
3. **Read-only source alignment:** Compare the five PM0 workflows in the package candidate against local Alpha-fixed `Local_Repo/Assistente PMO V2/workflows/*/workflow.json`; require SHA match or documented intentional diff.
4. **Read-only placeholder gate:** Scan the rebuilt package contents for `"result": "<static successfully.>"`, `placeholder`, `todo`, and `tbd`; expected result is zero matches in PM0 runtime components.
5. **Read-only component boundary gate:** Assert that only `PMO_v11_Tarefas_3_16` contains PM0 bot action/topic components, PM0 workflow files, and PM0 workflowset mappings; assert `PMO_AQ07_CopilotBinding` does not duplicate active PM0 components.
6. **Local rebuild:** Build `PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` from the Alpha-fixed source and include all five PM0 workflows plus their workflowset mappings.
7. **Local package gates:** Run solution XML validity, P0/P24 package contracts, AQ-08 structural verifier against package contents, PM0 functional contract verifier, placeholder scan, and ASCII scan. Capture Evidence Triplet for each gate.
8. **Gate 4 ASK:** Ask the owner for explicit tenant write approval with exact package path, SHA256, environment ID, and write list. Do not combine unrelated writes into a vague approval request.
9. **Tenant write 1 after approval:** Import only the approved `PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` package. Capture command output, timestamp BRT, agent name, and screenshot evidence.
10. **Tenant write 2 after approval if needed:** Publish `Assistente PMO V2` only after explicit owner approval or if covered verbatim by Gate 4. Capture publish evidence.
11. **Post-write read-only verification:** Export/read back the tenant solution and verify PM0 components now have a single owning release boundary, PM0 workflows match fixed source, and action-to-workflow mappings exist.
12. **Runtime proof:** Run AQ-09 Section A 5/5 smoke and SharePoint read-back verification. A flow is not DONE until the Functional Definition of Done evidence is complete.

## Release Recommendation

Do not treat either package as a clean 3.16 release candidate.

Required correction before any import/publish gate:

1. Choose one owning solution boundary for the PM0 runtime bundle.
2. Remove duplicated PM0 bot action/topic components from the non-owning solution.
3. Ensure the owning solution contains all five:
   - PM0 action components
   - PM0 topic components
   - PM0 workflow JSON files
   - PM0 `botcomponent_workflowset.xml` mappings
4. Rebuild from local Alpha-fixed workflow/action/topic sources.
5. Re-run package gates against the rebuilt package and confirm zero placeholder responses.

No tenant write was performed during this reconciliation.

## Codex #1 Updated Opinion (2026-05-22 17:36:06 BRT)

### Question 1 — Codex #2 Package Consistency Check

#### Findings with Evidence Triplet

Codex #2's rebuilt package is directionally aligned with Option A because it is named and versioned as the `PMO_v11_Tarefas` 3.16 artifact and contains five PM0 workflow files, five PM0 action botcomponents, and five PM0 PMO topic botcomponents. It is **not yet consistent enough for Gate 4** because the strict check found zero PM0 entries in `Assets/botcomponent_workflowset.xml`, and all five workflow JSON files differ from current local Alpha workflow files after raw and canonical JSON comparison.

| Check | Result | Evidence |
|---|---|---|
| Package SHA256 | `4280EC92E29FC19C457273C6222ACC81383D0B59D66254578567AF42EC5EDD15` | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173428_Codex1_package_consistency_strict.md` |
| Five PM0 workflow entries present | PASS | Same evidence triplet |
| Five PM0 action components present | PASS | Same evidence triplet |
| Five PM0 topic components present | PASS | Same evidence triplet |
| Internal duplicate PM0 botcomponent instances | PASS: `0` duplicates | Same evidence triplet |
| `Assets/botcomponent_workflowset.xml` PM0 mappings | FAIL: `0` PM0 lines | Same evidence triplet |
| Raw local-vs-zip workflow SHA match | FAIL: `0/5` match | Same evidence triplet |
| Canonical local-vs-zip workflow JSON match | FAIL: `0/5` match | `.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173543_Codex1_canonical_workflow_compare.md` |
| Static placeholder response pattern in PM0 workflows | PASS: zero hits | Strict package consistency evidence |

The workflowset content still maps only legacy `PMO_PA_*` actions/topics and legacy topic-to-flow bindings. It does not map any of:

- `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` -> `1721e0a3-a250-f111-bec7-000d3abc5cc6`
- `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` -> `7c6300c2-a250-f111-bec7-000d3abc5cc6`
- `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` -> `7f662db7-a250-f111-bec7-000d3abc5cc6`
- `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` -> `e0e3c6b0-a250-f111-bec7-000d3abc5cc6`
- `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` -> `8333bd91-a250-f111-bec7-000d3abc5cc6`

#### Microsoft Learn Citation Table

| Claim | Citation |
|---|---|
| Solution packages are imported with `pac solution import`, and `--publish-changes` publishes changes after successful import. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` | accessed 2026-05-22 17:36:00 BRT |
| Power Platform CLI solution commands include `pac solution pack`, `unpack`, `import`, `list`, `publish`, and `delete`. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` | accessed 2026-05-22 17:36:00 BRT |
| Copilot Studio agents can be exported and imported with solutions. | `https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-solutions-import-export` | accessed 2026-05-22 17:36:00 BRT |
| Same unmanaged component should not be included in more than one solution. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:36:00 BRT |

#### Recommendation

Do **not** issue Gate 4 against this exact rebuilt package. Keep Option A as the target architecture, but require Codex #2 to rebuild or patch the package so `PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` includes the five PM0 workflowset mappings and either byte/canonical matches current local Alpha workflow files or documents every intentional diff before import approval.

#### Risk If Not Followed

If owner approves this package as-is, the import could install PM0 workflow files and PM0 action components while leaving the bot action-to-flow binding asset incomplete. That recreates the core failure mode: the package looks structurally richer than 3.15.1, but the bot may still not invoke the intended fixed PM0 flows.

### Question 2 — PMO_AQ07_CopilotBinding Cleanup Recommendation

#### Findings with Evidence Triplet

Prior export reconciliation already proved the live tenant export state was not a clean ownership model: `PMO_AQ07_CopilotBinding_1_0_0_1.zip` and `PMO_v11_Tarefas_3_16.zip` both carried the same 27 botcomponents; AQ07 was the only exported package with PM0 workflow JSON files and PM0 workflowset mappings; and AQ07's PM0 workflow responses were still placeholder strings. The new Codex #2 package has not changed tenant state, so tenant `PMO_AQ07_CopilotBinding` remains a stale duplicate-risk solution until read-only PAC inventory proves otherwise.

Evidence:

- `.planning/comms/codex_pm0_remediation_20260522/EXPORT_RECONCILIATION_20260522_1712.md` findings 1-4.
- `.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173428_Codex1_package_consistency_strict.md`.

#### Microsoft Learn Citation Table

| Claim | Citation |
|---|---|
| Microsoft's multiple-solution strategy is for distinct independent functional areas that do not share components. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:36:00 BRT |
| Microsoft explicitly warns not to include the same unmanaged component in more than one solution. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:36:00 BRT |
| Dependencies must exist in the target environment for solution import or deployment. | `https://learn.microsoft.com/en-us/troubleshoot/power-platform/dataverse/working-with-solutions/missing-dependency-on-solution-import` | accessed 2026-05-22 17:36:00 BRT |
| `pac solution delete` is an official command for deleting a solution from Dataverse; the currently accessed `pac solution` command list does not document `pac solution remove-solution-component`, but does document `add-solution-component`. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` | accessed 2026-05-22 17:36:00 BRT |

#### Recommendation

Choose **option (d): staged cleanup, not immediate AQ07 mutation**. After a corrected Option A package imports and publishes successfully, run read-only dependency and solutioncomponent inventory for `PMO_AQ07_CopilotBinding`. If AQ07 contains no unique live dependencies after PM0 ownership moves to `PMO_v11_Tarefas`, delete the entire AQ07 transition solution using the official `pac solution delete` path under a separate owner approval. If AQ07 still owns unique non-PM0 dependencies, do not delete it; remove/retire only PM0 duplicates through a documented supported method after confirming the exact component operation from Microsoft Learn or the maker portal.

Dependency risk is currently **unquantified in tenant** because no read-only PAC solutioncomponent query has been run after Codex #2's rebuild. From exported evidence only, AQ07 carries at least 27 botcomponents and PM0 workflowset mappings. That is enough to block cleanup-before-import and enough to require inventory-before-delete.

#### Risk If Not Followed

Deleting or modifying AQ07 before the corrected PMO_v11 import could remove the only tenant-held PM0 workflowset mappings currently observed in exports. Leaving AQ07 untouched through SHIP would retain the documented duplicate-unmanaged-component anti-pattern and could confuse future audits, rollback, and solution layering.

### Question 3 — Required Read-Only Preflight

#### Findings with Evidence Triplet

Codex #2's local package gates are useful but insufficient for owner approval because they do not prove current tenant solution membership, AQ07 dependency state, bot publish state, or live route drift. The strict local package check also found this package is not Gate-4-ready until workflowset mappings and workflow diff status are corrected.

Evidence:

- Package consistency strict check: `.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173428_Codex1_package_consistency_strict.md`.
- Canonical workflow compare: `.planning/comms/codex_pm0_remediation_20260522/CODEX1/UPDATED_OPINION/evidence/20260522_173543_Codex1_canonical_workflow_compare.md`.

#### Minimum Read-Only Preflight Before Any Gate 4 ASK

1. `pac solution list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56`  
   Capture current versions and solution IDs for `PMO_v11_Tarefas` and `PMO_AQ07_CopilotBinding`.

2. `pac env fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <solutioncomponent_fetch.xml>`  
   Fetch `solutioncomponent` rows for both solution IDs and component types relevant to PM0 workflow and botcomponent ownership. Use this to prove which solution currently owns or references the five PM0 workflows and PM0 botcomponents.

3. `pac env fetch --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --xmlFile <workflowset_fetch.xml>`  
   Fetch current PM0 `botcomponent_workflow`/workflowset rows for the five PM0 action schema names and workflow IDs.

4. `pac copilot list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56`  
   Capture current `Assistente PMO V2` publish/component state before import.

5. Read-only AQ-08 structural verifier against current tenant state.  
   Confirm current routing remains known before import so post-import drift can be attributed.

6. Corrected package preflight.  
   Re-run the local strict package check after Codex #2 rebuilds workflowset mappings and resolves workflow JSON diffs. Gate 4 should cite the corrected evidence, not the currently failing evidence.

#### Microsoft Learn Citation Table

| Claim | Citation |
|---|---|
| `pac solution list` lists all solutions in the current Dataverse organization. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` | accessed 2026-05-22 17:36:00 BRT |
| `pac env fetch` performs FetchXML queries against Dataverse; `pac org` was renamed to `pac env`, while `org` continues to work. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/env` | accessed 2026-05-22 17:36:00 BRT |
| `pac copilot list` lists copilots in the current or target Dataverse environment. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` | accessed 2026-05-22 17:36:00 BRT |
| SolutionComponent is the Dataverse table/entity used to represent solution components and their component type. | `https://learn.microsoft.com/en-us/power-apps/developer/data-platform/reference/entities/solutioncomponent#componenttype-choicesoptions` | accessed 2026-05-22 17:36:00 BRT |

#### Recommendation

Run the six read-only preflight checks above before asking the owner to approve any tenant write. Codex #2's local package gates should not be accepted as sufficient preflight because they do not inspect tenant solution boundaries and, on recheck, the package still lacks PM0 workflowset mappings.

#### Risk If Not Followed

Approving import without tenant preflight risks importing over an environment whose actual solution layers, AQ07 bindings, or bot publish state differ from the exported assumptions. That is exactly the class of drift that structural package tests alone did not catch earlier.

### Question 4 — Gate 4 ASK Shape

#### Findings with Evidence Triplet

No tenant write is authorized in the owner message. Project policy says tenant import, Copilot publish, and any runtime-state-changing operation require explicit owner approval in the current thread. `pac solution import --publish-changes` is a single CLI command, but the `--publish-changes` flag explicitly publishes changes after successful import, so the ASK must name that behavior if the flag is used.

Evidence:

- `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` section 5: import, Copilot publish, and runtime-state-changing operations require explicit owner approval in the current thread.
- `.planning/comms/SEV0_STOP_SHIP_QUALITY_GATES_PROTOCOL_20260514.md`: runtime evidence and rollback gates are blocking before ship readiness.

#### Microsoft Learn / Project Policy Citation Table

| Claim | Citation |
|---|---|
| `pac solution import` imports a solution into Dataverse; `--publish-changes` publishes changes upon successful import. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` | accessed 2026-05-22 17:36:00 BRT |
| `pac copilot publish` publishes a custom copilot and requires `--bot`. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` | accessed 2026-05-22 17:36:00 BRT |
| Project policy requires explicit owner approval in the current thread before tenant import, Copilot publish, or any runtime-state-changing operation. | `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md` | read 2026-05-22 17:36:00 BRT |

#### Recommendation

Split Gate 4 into separate approvals:

1. **Gate 4A - import approval:** exact package path, SHA256, environment ID, and exact `pac solution import` command. If `--publish-changes` is included, the approval text must explicitly say the import will publish Dataverse customizations after successful import.
2. **Gate 4B - Copilot publish approval:** exact `pac copilot publish --bot <bot-id-or-schema-name> --environment <env-id>` command after import read-back confirms the corrected PM0 components landed.
3. **Gate 4C - AQ07 cleanup approval:** separate later approval only after read-only dependency inventory and 3.16 runtime proof.

Do not ask for any Gate 4 approval until Question 1's package blocker is corrected.

#### Risk If Not Followed

A single broad "import and publish" approval would be operationally ambiguous and would not meet the project policy standard for explicit authorization per write. If `--publish-changes` is hidden inside the import command without being called out, owner approval would not be informed.

### Question 5 — Single Best Next Action

#### Updated Technical Opinion

My recommendation for the next 60 minutes is: **do not proceed to Gate 4 yet; keep Option A, but treat Codex #2's current package as a failed candidate until it includes the five PM0 workflowset mappings and matches or explicitly explains current Alpha workflow JSON diffs.** Run the remaining read-only investigations now, not after approval: tenant solution list, solutioncomponent FetchXML for both solutions, workflowset FetchXML, copilot list, current AQ-08 structural verifier, and corrected package strict check. Use two separate owner approvals: one for solution import and one for Copilot publish, with AQ07 cleanup as a third later approval if dependency inventory supports it. AQ07 cleanup should happen **after** the corrected 3.16 import/publish and runtime proof, not before, because the current exports indicate AQ07 still carries the only PM0 workflowset mappings observed so far. The owner should require package SHA, workflowset proof, local-vs-package workflow proof, no-placeholder scan, tenant read-only inventory, and rollback path before approving any write. The critical risk if owner approves now is that the imported package may still leave PM0 actions without packaged workflowset mappings, preserving the same structural/runtime gap that caused AQ-09 A1 to fail.

#### Microsoft Learn Citation Table

| Claim | Citation |
|---|---|
| Multiple solutions are valid only when planned around sharing/dependencies; duplicate unmanaged components are explicitly discouraged. | `https://learn.microsoft.com/en-us/power-platform/alm/organize-solutions` | accessed 2026-05-22 17:36:00 BRT |
| Import and publish are official PAC operations and must be named precisely in execution plans. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution` and `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/copilot` | accessed 2026-05-22 17:36:00 BRT |
| FetchXML read-only preflight is supported through `pac env fetch`. | `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/env` | accessed 2026-05-22 17:36:00 BRT |

#### Recommendation

Block Gate 4 until a corrected package passes strict package consistency and the read-only tenant preflight is captured. Then issue Gate 4A and Gate 4B separately. Defer AQ07 cleanup until after successful import/publish/read-back and runtime smoke, with its own owner approval.

#### Risk If Not Followed

Proceeding now would convert a local static-gate claim into a tenant write despite known local package inconsistencies. That would violate the new Functional DoD spirit: no PASS/PUBLISH claim should advance without proving the action/topic/workflow contract and runtime path are materially complete.
