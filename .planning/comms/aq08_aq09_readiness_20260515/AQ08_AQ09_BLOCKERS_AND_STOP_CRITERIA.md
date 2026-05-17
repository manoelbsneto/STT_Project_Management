# AQ-08 / AQ-09 Blockers and Stop Criteria

Date: 2026-05-15
Release decision: NO-SHIP

## Current Blockers (Preventing Start)
- [RESOLVED] AQ-07 Power Automate programmatic save completed by CODEX-LEAD.
- [RESOLVED] AQ-07 exact Flow IDs are available in `AQ08_COPILOT_PUBLISH_CHECKLIST.md`.
- [BLOCKED_FOR_APPROVAL] Owner must provide explicit approval text for AQ-08.
- [BLOCKED_FOR_APPROVAL] Owner must provide explicit approval text for AQ-09.

## Global Stop Criteria (During Execution)
Stop execution and keep `NO-SHIP` if any of the following occurs:

- Owner approval text is missing or narrower than the intended action.
- A command or portal action would exceed the approved gate scope.
- Copilot publish fails or bindings point to stale flows/actions.
- Runtime smoke routes to the wrong Teams channel/chat.
- Copilot exposes raw SharePoint/Planner rows, raw JSON, stack traces, or connector diagnostics.
- `ContentFiltered` or `openAIIndirectAttack` appears in runtime evidence.
- SharePoint or Planner write behavior differs from the approved smoke plan.
- Rollback evidence is missing before a write/import/publish gate.
