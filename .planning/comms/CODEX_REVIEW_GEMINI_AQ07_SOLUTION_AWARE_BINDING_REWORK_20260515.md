# CODEX Review: Gemini AQ-07 Solution-Aware Binding Rework

Date: 2026-05-15
Reviewer: CODEX-LEAD
Task: AQ-07-REWORK-SOLUTION-AWARE-COPILOT-BINDABLE-FLOWS

## Verdict

STATUS: READY_FOR_OWNER_APPROVAL

Gemini's rework identifies the correct blocker and the correct documented recovery path: convert the six AQ-07 `PM0_PA_*` flows to solution-aware cloud flows with `Set-FlowAsSolutionAware`, then import a package that creates Copilot action components and `botcomponent_workflow` bindings using the generated Dataverse `workflowEntityId` values.

AQ-08 must stay blocked until this AQ-07 rework is approved, executed, and read-only verified.

## Review Findings

| Area | Result | Notes |
| --- | --- | --- |
| Root cause | PASS | AQ-08 discovery showed `WorkflowEntityId = null` for current AQ-07 ProcessSimple flows, so publishing would keep stale `PMO_PA_*` bindings. |
| Documented path | PASS | `deploy/MASTER_RUNBOOK/MASTER_RUNBOOK.md` and `deploy/CS_G4_Complete.ps1` use `Set-FlowAsSolutionAware` before Copilot workflow binding. |
| Target flow inventory | PASS | Rework uses the six required AQ-07 flow IDs, including actual Ops ID `2fb10a2f-e2d0-4ae3-93a8-6eb3fd133441`. |
| PowerShell parse | PASS | `.planning/comms/aq07_power_automate_build_20260515/Invoke-AQ07SolutionAwareBinding.ps1` parses successfully. |
| PAC failure detection | PATCHED | Updated local script to detect both `FAILURE:` and PAC `Error:` output. |
| Action output contract | PATCHED | Updated generated action `data` to expose output `result`, matching AQ-07 flow response body contract. |
| Tenant mutation status | NOT RUN | No tenant writes, no solution import, no Copilot publish, no SharePoint writes, no Planner writes, no runtime smoke. |

## Files Reviewed

```text
.planning/comms/GEMINI_AQ07_REWORK_PROMPT_SOLUTION_AWARE_COPILOT_BINDABLE_FLOWS_20260515.md
.planning/comms/AQ07_REWORK_PLAN_20260515.md
.planning/comms/aq07_power_automate_build_20260515/AQ07_REWORK_SOLUTION_AWARE_PLAN_20260515.md
.planning/comms/aq07_power_automate_build_20260515/Invoke-AQ07SolutionAwareBinding.ps1
deploy/PA_AQ07_MakeSolutionAware.ps1
deploy/MASTER_RUNBOOK/MASTER_RUNBOOK.md
deploy/CS_G4_Complete.ps1
deploy/copilot/AssistentePMO.template.yaml
```

## Local Patch Applied

```text
.planning/comms/aq07_power_automate_build_20260515/Invoke-AQ07SolutionAwareBinding.ps1
```

Changes:

```text
1. PAC failure detection now checks `(?m)^\s*Error:` and `FAILURE:`.
2. Generated Copilot action output changed from `message` to `result`.
```

## Required Owner Approval Before Execution

Recommended approval text:

```text
Approved: CODEX-LEAD may execute AQ-07 solution-aware Copilot binding rework using .planning/comms/aq07_power_automate_build_20260515/Invoke-AQ07SolutionAwareBinding.ps1.

Scope: run Set-FlowAsSolutionAware for the six AQ-07 PM0_PA_* flows and import the generated PMO_AQ07_CopilotBinding solution package to create Copilot action/workflow bindings.

Required evidence: workflowEntityId matrix, generated package manifest, pac import log, post-import read-only botcomponent_workflow inventory, and rollback note.

Not authorized: Copilot publish, AQ-09 runtime smoke, SharePoint schema writes, Planner writes outside approved runtime behavior, Teams production post, additional unrelated flow imports, or final SHIP.
```

## Next Steps

1. Owner approves the AQ-07 solution-aware binding execution.
2. CODEX-LEAD runs the patched `Invoke-AQ07SolutionAwareBinding.ps1`.
3. CODEX-LEAD captures execution evidence and read-only post-import binding inventory.
4. If all six `PM0_PA_*` actions bind to non-null workflow IDs, AQ-08 can resume topic/action binding and publish under the already stated AQ-08 approval.
5. Release remains NO-SHIP until AQ-09 runtime smoke and AQ-10 final decision complete.
