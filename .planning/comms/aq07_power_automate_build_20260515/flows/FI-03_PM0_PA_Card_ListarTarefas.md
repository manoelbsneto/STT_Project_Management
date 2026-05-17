## Identity
- Flow key: FI-03
- Display name: PM0_PA_Card_ListarTarefas
- Purpose: Retrieve tasks for project
- Route key: task.card.route
- Card templates: ListarTarefasProjetoCard.json
- Owner approval required before tenant save/import: yes

## Trigger
- Exact trigger type: When Copilot Studio calls an action
- Expected Copilot or manual input schema: Project ID filter, action
- Required fields: projectId, action
- Optional fields: none
- Validation rules: Must be valid project ID, action must equal 'list'

## Variables
- name: TasksList
- type: array
- default value: []
- source: SharePoint get items
- validation: array

## Actions
1. action name: Get SharePoint Tasks
   connector: SharePoint
   operationId: GetItems
   input parameters: list=Tarefas, site=https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
   expressions: N/A
   run-after behavior: after trigger
   success output shape: list of SharePoint items
   failure behavior: fail flow

2. action name: Get Planner Tasks
   connector: Planner
   operationId: ListTasks_V3
   input parameters: groupId=96c5b0c4-46cc-46cd-8695-50451db74994, planId=-1kBj1PLv0qQM-R4PwkqbpcABv_P
   expressions: none
   run-after behavior: after Get SharePoint Tasks
   success output shape: list of Planner tasks
   failure behavior: fail flow

3. action name: Normalize Tasks
   connector: Built-in Data Operation
   operationId: Select
   input parameters: Map Planner fields to Card properties by correlating PlannerTaskId from SharePoint with Planner task ID
   expressions: none
   run-after behavior: after Get Planner Tasks
   success output shape: normalized task array
   failure behavior: fail flow

4. action name: Return Tasks
   connector: Power Virtual Agents
   operationId: ReturnResponse
   input parameters: Card JSON
   expressions: N/A
   run-after behavior: after Normalize Tasks
   success output shape: object
   failure behavior: fail flow

## SharePoint Behavior
- list name: Tarefas
- filter queries: ProjectID eq '@{triggerBody()?['projectId']}'
- top limits: 100
- selected columns: None
- write order: None
- idempotency behavior: safe read
- no raw row output to Copilot: Yes

## Planner Behavior
- operationId: ListTasks_V3
- groupId: 96c5b0c4-46cc-46cd-8695-50451db74994
- planId: -1kBj1PLv0qQM-R4PwkqbpcABv_P
- bucket IDs from AQ-04: read only
- conditional create/update path: N/A
- exact fields to write: N/A
- error sanitization: sanitize PlannerSyncError
- no Planner write unless this specific flow behavior is later approved in AQ-07/AQ-09: Yes

## Teams/Card Behavior
- route key: task.card.route
- target route: requester chat
- card template: ListarTarefasProjetoCard.json
- submit payload expected from card: None
- action dispatch rule: routeKey + action
- operationId is correlation ID only, not action selector: Yes

## Copilot Return Contract
- exact static ASCII response string: "Tasks retrieved successfully."
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