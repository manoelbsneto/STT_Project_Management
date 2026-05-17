# CODEX Review: Gemini P0 Flow Implementation Checklist

Date: 2026-05-14
Reviewer: CODEX-LEAD
Reviewed artifact: `.planning/comms/P0_FLOW_IMPLEMENTATION_CHECKLIST_20260514.md`
Decision: REWORK REQUIRED before it can be treated as deploy-ready
Tenant execution: None

## 1. Summary

Gemini produced a useful high-level flow map, but it is not sufficient as a deploy-ready implementation artifact under SEV-0 quality gates.

The artifact can be used as a starting checklist only.

It cannot yet be used to approve import, publish, flow save, or tenant execution.

## 2. Findings

| ID | Severity | Finding | Evidence | Required Correction |
|---|---|---|---|---|
| GFI-001 | High | Artifact says `Status: READY`, but it is not deploy-ready under SEV-0 gates. | `P0_FLOW_IMPLEMENTATION_CHECKLIST_20260514.md:6` | Change status to `READY_FOR_REWORK` or create a fuller implementation package with evidence. |
| GFI-002 | High | Required deliverable 2 was not satisfied: no draft local flow definition JSON or detailed pseudocode artifacts were created. | Dispatch prompt requires draft JSON/pseudocode; checklist only has brief action bullets at lines 16-21, 29-32, 40-44, 52-57, 65-69. | Produce flow-level pseudocode or local draft definition files under a planning folder. |
| GFI-003 | Medium | Copilot output contains non-ASCII user-facing text. | Line 26 has `Atualização`. Current baseline requires app-facing text to be ASCII safe. | Replace with ASCII-safe wording, for example `Atualizacao recebida. Confirme no card enviado.` |
| GFI-004 | High | Task create/update routes are ambiguous. | Lines 50 and 63 say `Same context as submit`. | Explicitly use `task.card.route` for task cards and `pmo.ops` for operational alerts/failures. |
| GFI-005 | High | Planner create/update mapping omits bucket mapping and sync fields in the action sequence. | Lines 55-56 mention Planner create and `PlannerTaskId` but omit `PlannerBucketId`, `PlannerLastSyncAt`, and `PlannerSyncError`. | Define exact behavior for bucket selection, sync status, last sync timestamp, and sanitized error persistence. |
| GFI-006 | Medium | Failure handling is too generic for executive and task flows. | Line 21 says `Post simple error card`; line 44 returns static error but no route/evidence behavior. | Define failure route, card template or static response, no-write behavior, and evidence fields for each failure branch. |
| GFI-007 | High | SEV-0 gates are not referenced in the checklist. | Artifact has no gate/evidence section. | Add gate mapping: card static validation, flow static-output validation, route validation, schema gate, read-only Planner discovery, runtime smoke evidence, rollback. |
| GFI-008 | Medium | Schema plan lacks exact field type details aligned to SharePoint/PnP execution. | Lines 75-79 provide generic types only. | Add SharePoint field implementation details: display name, internal name, type, choices, required=false, and idempotency/read-before-write behavior. |

## 3. Accepted Parts

| Area | Status |
|---|---|
| Flow names and P0 scope | Accepted as baseline. |
| Owner-approved route keys for executive, PM status, and task cards | Mostly aligned, except task submit ambiguity. |
| SharePoint-first / Planner-second principle | Accepted. |
| Tenant execution control | Accepted; no tenant write was performed. |
| Required approvals list | Accepted as initial list, but it needs gate-specific expansion. |

## 4. Required Rework Scope

Gemini should produce one of these before CODEX can accept the workstream:

1. A detailed flow pseudocode package, one file per P0 flow; or
2. A single expanded implementation checklist with each flow broken into trigger, variables, action sequence, conditions, outputs, error handling, evidence fields, and gates.

Minimum required sections per flow:

- Trigger type.
- Inputs.
- Variables initialized.
- SharePoint actions with filters and top limits.
- Card template used.
- Route key used.
- Copilot return payload.
- Teams card submit action payload.
- Validation rules.
- Write order.
- Planner conditional logic.
- Failure handling.
- Evidence to capture.
- Rollback / no-write behavior.

## 5. Current Release Impact

This does not block continuing local design work.

It does block:

- tenant flow save;
- solution import;
- Copilot publish;
- runtime ship decision;
- any claim that Power Automate implementation is ready.

Current release decision remains:

```text
NO-SHIP
```

Reason: implementation artifacts and mandatory runtime evidence are not yet complete.
