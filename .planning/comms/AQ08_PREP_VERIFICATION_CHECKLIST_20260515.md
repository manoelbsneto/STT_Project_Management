# AQ-08 Copilot Publish Readiness & Verification

Date: 2026-05-15
Status: PARALLEL PREPARATION ONLY
Scope: Verification criteria for AQ-08 publish, post AQ-07 workflow activation.

## 1. AQ-08 Post-Activation Read-Only Verification Checklist

Before proceeding with any `pac copilot publish` operations in AQ-08, the following criteria must be verified from the read-only evidence provided by CODEX after they activate the stopped flow:

- [ ] **Flow State:** All six `PM0_PA_*` workflows (`PM0_PA_Card_ResumoExecutivoPortfolio`, `PM0_PA_Card_AtualizarStatus`, `PM0_PA_Card_ListarTarefas`, `PM0_PA_Card_CriarTarefa`, `PM0_PA_Card_AtualizarTarefa`, `PM0_PA_OpsFailureHandling`) are active (`Activado`) in Dataverse.
- [ ] **Bot Component Workflows:** All six `botcomponent_workflow` rows accurately map to the `PM0_PA_*` action components (e.g., `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa`).
- [ ] **No Stale Bindings:** No stale bindings (such as `PMO_PA_*` instead of the new `PM0_PA_*`) are claimed as part of the AQ-07 success. The new action components must strictly reference the new AQ-07 cloud flows.
- [ ] **Copilot Publish Evidence Tied to Artifact:** Copilot publish evidence must be tied directly to the final AQ-07 artifact.

## 2. PASS/BLOCK Decision Table

| Criteria | PASS Condition | BLOCK Condition |
|---|---|---|
| Flow Activation State | All 6 flows are active (`Activado`) in the Dataverse inventory. | Any `PM0_PA_*` flow is `Borrador` / stopped. |
| Copilot Action Bindings | `botcomponent_workflow` rows point to all six new `PM0_PA_*` actions. | `botcomponent_workflow` rows point to missing or old `PMO_PA_*` actions. |
| Stale Flow References | No `PMO_PA_` bindings are claimed as success. | Stale `PMO_PA_` bindings are claimed as the AQ-07 target. |
| Copilot Publish Evidence | Evidence is tied to the final AQ-07 artifact. | Evidence is not tied to the final AQ-07 artifact. |

## 3. Rollback Checklist for Copilot Binding / Publish

Ensure the following rollback paths are clear. 
*Note: Any `pac solution import` or `pac copilot publish` command for rollback must be marked as an owner-approved gated action only. These are not executable under the current prep task.*

- [ ] **Current State Evidence:** A snapshot of the current Copilot component bindings (`pac org fetch` for `botcomponent_workflow`) exists and is saved to the `.planning/comms/` directory.
- [ ] **Prior Solution Export:** An export of the previous known-good solution (e.g., `PMO_G4_Completion` or `AssistentePMO` base) is available locally for immediate import if the new bindings break runtime behavior.
- [ ] **Rollback Execution Path:** If the AQ-08 publish fails or AQ-09 runtime smoke discovers routing issues, the owner-approved gated rollback action is to re-import the prior solution using `pac solution import --publish-changes` and re-run `pac copilot publish`.
- [ ] **No Destructive Deletions:** Do not delete any existing topics or actions manually; rely on Solution lifecycle imports to update the Dataverse schema.

## 4. AQ-08 Publish Handoff Note Template

```text
STATUS: READY_FOR_CODEX_REVIEW
AQ-07 evidence required: Read-only Dataverse workflow inventory showing all six PM0_PA_* flows as Activado, and botcomponent_workflow rows pointing to PM0_PA_* components.
Pre-publish checks: All conditions in the PASS/BLOCK table evaluate to PASS.
Publish command/manual path: Owner-approved execution of pac copilot publish.
Rollback evidence required: Snapshots of current component bindings and prior known-good solution export.
Stop criteria: Any flow is Borrador/stopped, stale PMO_PA_* bindings claimed as success, or publish evidence not tied to final artifact.
Owner approval needed: Approve CODEX-LEAD to execute AQ-08 Copilot update/publish based on the successful AQ-07 activation evidence. No further Flow logic changes, SharePoint schema writes, Planner writes, or AQ-09 runtime smoke is authorized.
```

## 5. Stale / Conflicting Planning Artifacts

The following files indicate that AQ-08 is blocked only because `workflowEntityId` was null. They will need to be updated after CODEX activation evidence lands, as the `workflowEntityId` issue is resolved but the flow state was `Borrador`:
- `.planning/comms/aq08_copilot_publish_20260515/AQ08_READONLY_DISCOVERY.md`
- `.planning/comms/aq08_aq09_readiness_20260515/AQ08_COPILOT_PUBLISH_CHECKLIST.md`
