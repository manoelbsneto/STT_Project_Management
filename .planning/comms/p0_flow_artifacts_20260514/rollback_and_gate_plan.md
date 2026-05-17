# Rollback and Gate Plan

Date: 2026-05-14
Scope: AQ-05 local planning only
Release decision: NO-SHIP

## Rollback Boundaries

These are planning notes only. Final rollback steps must be confirmed before any tenant write/import/publish.

| Area | Rollback direction | Current readiness |
|---|---|---|
| SharePoint schema | Leave new fields unused; remove only after separate owner approval and dependency check | DONE AQ-03 |
| SharePoint data writes | Use pilot-only records and before-after evidence | PENDING |
| Planner task writes | Use pilot task data only; no bucket add/delete | PENDING |
| Flow changes | Disable or revert new flows from owner-approved package | PENDING |
| Copilot topic routing | Revert topic bindings/static messages to previous owner-approved package | PENDING |
| Teams card posts | Leave evidence posts or delete manually only if owner requests | PENDING |

## Mandatory Gates Before Tenant Execution

| Gate | Required evidence | Current state |
|---|---|---|
| Owner approval | Explicit approval in current thread for each tenant action | DONE for AQ-03; pending for AQ-07/AQ-08/AQ-09 |
| Access protocol | Check-in with exact command/access route before access | DONE for AQ-03; pending for future tenant actions |
| Schema read-only | Field inventory tied to current tenant state | DONE for `Tarefas`; other list field reconciliation still pending |
| Schema write | Owner-approved Planner sync fields added to `Tarefas` | DONE AQ-03 |
| Planner read-only | Plan and bucket IDs from approved path only | DONE_OWNER_EVIDENCE via AQ-04 |
| Local artifact validation | JSON parse, ASCII scan, route keys, no raw output rule | READY for AQ-06 |
| Flow static validation | Actual flow artifacts inspected before import/save | PENDING |
| Runtime smoke | Flow run IDs, Teams screenshots, SP/Planner before-after | PENDING |
| XPIA regression | Known repro has no `ContentFiltered` / `openAIIndirectAttack` | PENDING |
| Release readiness | Gate-by-gate checklist tied to current artifact | PENDING |

## NO-SHIP Conditions

Keep release `NO-SHIP` if any of these remain true:

- AQ-04 Planner IDs are not carried into the actual flow package as owner-provided constants.
- Required `Tarefas` fields are missing from the current tenant state.
- Any Copilot output can expose raw SharePoint/Planner content.
- Any app-facing text is non-ASCII.
- Flow package/static validation is missing.
- Runtime evidence is stale or tied to a different artifact.
- Rollback plan is not specific to the actual tenant change.

## Next Gate

AQ-03 and AQ-04 are complete. The next blocking runtime gates are AQ-07 owner-approved flow save/import, AQ-08 Copilot publish/update, AQ-09 runtime smoke and XPIA regression, and AQ-10 final release decision.

No tenant write, flow save/import, Copilot publish, Planner write, SharePoint write, or Teams production post is authorized by this update.
