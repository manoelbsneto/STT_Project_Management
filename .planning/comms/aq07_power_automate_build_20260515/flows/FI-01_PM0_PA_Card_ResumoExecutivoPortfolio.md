## Identity
- Flow key: FI-01
- Display name: PM0_PA_Card_ResumoExecutivoPortfolio
- Purpose: Retrieve executive portfolio summary and return Adaptive Card
- Route key: board.status
- Card templates: ResumoExecutivoPortfolio.json
- Owner approval required before tenant save/import: yes

## Trigger
- Exact trigger type: When Copilot Studio calls an action
- Expected Copilot or manual input schema: Object with no mandatory inputs
- Required fields: None
- Optional fields: None
- Validation rules: sanitize input

## Variables
- name: CardPayload
- type: string
- default value: empty
- source: Card JSON template
- validation: must be valid JSON string

## Actions
1. action name: Parse Trigger Input
   connector: Built-in Data Operation
   operationId: ParseJson
   input parameters: triggerBody()
   expressions: string()
   run-after behavior: after trigger
   success output shape: parsed object
   failure behavior: fail flow

2. action name: Get Projetos
   connector: SharePoint
   operationId: GetItems
   input parameters: site = https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital, list = Projetos
   expressions: N/A
   run-after behavior: after Parse Trigger Input
   success output shape: array of items
   failure behavior: fail flow

3. action name: Respond to Copilot
   connector: Power Virtual Agents
   operationId: ReturnResponse
   input parameters: Card JSON string
   expressions: N/A
   run-after behavior: after Get Projetos
   success output shape: valid response
   failure behavior: return error card

## SharePoint Behavior
- list name: Projetos
- filter queries: None
- top limits: 100
- selected columns: Title, Status
- write order: None
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
- route key: board.status
- target route: PMO Channel or direct to requester
- card template: ResumoExecutivoPortfolio.json
- submit payload expected from card: None
- action dispatch rule: routeKey + action
- operationId is correlation ID only, not action selector: Yes

## Copilot Return Contract
- exact static ASCII response string: "Executive portfolio retrieved successfully."
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
- what to preserve: previous versions if any
- what not to delete without separate approval: flow definition and connections