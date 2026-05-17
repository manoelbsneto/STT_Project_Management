## Identity
- Flow key: FI-02
- Display name: PM0_PA_Card_AtualizarStatus
- Purpose: Post update status card to Teams
- Route key: pm.status.updates
- Card templates: AtualizarStatusCard.json, AtualizarStatusSingleBoxReviewCard.json
- Owner approval required before tenant save/import: yes

## Trigger
- Exact trigger type: When Copilot Studio calls an action
- Expected Copilot or manual input schema: Object with routeKey, status
- Required fields: routeKey
- Optional fields: status
- Validation rules: Verify routeKey matches expected dispatch

## Variables
- name: CardPayload
- type: string
- default value: empty
- source: Card JSON
- validation: valid JSON string

## Actions
1. action name: Parse Trigger
   connector: Built-in Data Operation
   operationId: ParseJson
   input parameters: triggerBody()
   expressions: N/A
   run-after behavior: after trigger
   success output shape: object
   failure behavior: fail flow

2. action name: Post Adaptive Card
   connector: Teams
   operationId: PostCardInChat
   input parameters: channel ID, card payload
   expressions: N/A
   run-after behavior: after Parse Trigger
   success output shape: card posted response
   failure behavior: fail flow

3. action name: Return Response
   connector: Power Virtual Agents
   operationId: ReturnResponse
   input parameters: success boolean
   expressions: N/A
   run-after behavior: after Post Adaptive Card
   success output shape: success
   failure behavior: fail flow

## SharePoint Behavior
- list name: Projetos
- filter queries: none
- top limits: 1
- selected columns: none
- write order: none
- idempotency behavior: safe read
- no raw row output to Copilot: Yes

## Planner Behavior
- operationId: N/A
- groupId: 96c5b0c4-46cc-46cd-8695-50451db74994
- planId: -1kBj1PLv0qQM-R4PwkqbpcABv_P
- bucket IDs from AQ-04: Not used here
- conditional create/update path: N/A
- exact fields to write: N/A
- error sanitization: N/A
- no Planner write unless this specific flow behavior is later approved in AQ-07/AQ-09: Yes

## Teams/Card Behavior
- route key: pm.status.updates
- target route: target PM chat or channel
- card template: AtualizarStatusCard.json
- submit payload expected from card: status update data
- action dispatch rule: routeKey + action
- operationId is correlation ID only, not action selector: Yes

## Copilot Return Contract
- exact static ASCII response string: "Status update card posted successfully."
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
- before/after evidence for writes: required
- error evidence if failed: required

## Rollback
- disable/revert path: turn off flow
- what to preserve: connections
- what not to delete without separate approval: flow definition