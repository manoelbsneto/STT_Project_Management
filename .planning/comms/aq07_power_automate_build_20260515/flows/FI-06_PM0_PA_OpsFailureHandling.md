## Identity
- Flow key: FI-06
- Display name: PM0_PA_OpsFailureHandling
- Purpose: Handle failures and post errors safely
- Route key: pmo.ops
- Card templates: None
- Owner approval required before tenant save/import: yes

## Trigger
- Exact trigger type: When Copilot Studio calls an action
- Expected Copilot or manual input schema: error source, error code
- Required fields: source, code
- Optional fields: details
- Validation rules: truncate details to 500 chars

## Variables
- name: SanitizedError
- type: string
- default value: empty
- source: trigger input
- validation: max 500 chars

## Actions
1. action name: Sanitize Error
   connector: Built-in Data Operation
   operationId: Compose
   input parameters: details
   expressions: substring(..., 0, 500)
   run-after behavior: after trigger
   success output shape: string
   failure behavior: fail flow

2. action name: Respond
   connector: Power Virtual Agents
   operationId: ReturnResponse
   input parameters: SanitizedError
   expressions: N/A
   run-after behavior: after Sanitize Error
   success output shape: object
   failure behavior: fail flow

## SharePoint Behavior
- list name: None
- filter queries: N/A
- top limits: N/A
- selected columns: N/A
- write order: N/A
- idempotency behavior: safe read
- no raw row output to Copilot: Yes

## Planner Behavior
- operationId: N/A
- groupId: 96c5b0c4-46cc-46cd-8695-50451db74994
- planId: -1kBj1PLv0qQM-R4PwkqbpcABv_P
- bucket IDs from AQ-04: N/A
- conditional create/update path: N/A
- exact fields to write: N/A
- error sanitization: remove stack trace
- no Planner write unless this specific flow behavior is later approved in AQ-07/AQ-09: Yes

## Teams/Card Behavior
- route key: pmo.ops
- target route: ops channel
- card template: None
- submit payload expected from card: None
- action dispatch rule: routeKey + action
- operationId is correlation ID only, not action selector: Yes

## Copilot Return Contract
- exact static ASCII response string: "Operation failed securely."
- max length: 200 chars
- no raw SharePoint output: Yes
- no raw Planner output: Yes
- no stack trace: Yes

## Evidence To Capture During AQ-07/AQ-09
- flow ID: required
- run ID: required
- screenshots: required
- input sample: required
- output sample: required
- before/after evidence for writes: N/A
- error evidence if failed: required

## Rollback
- disable/revert path: turn off flow
- what to preserve: connections
- what not to delete without separate approval: flow definition
