## Identity
- Flow key: FI-05
- Display name: PM0_PA_Card_AtualizarTarefa
- Purpose: Update existing task in Planner and SharePoint
- Route key: task.card.route
- Card templates: AtualizarTarefaCard.json
- Owner approval required before tenant save/import: yes

## Trigger
- Exact trigger type: When Copilot Studio calls an action
- Expected Copilot or manual input schema: SP Item ID, new status, action
- Required fields: spItemId, status, action
- Optional fields: comments
- Validation rules: sanitize inputs, action must equal 'update'

## Variables
- name: TargetPlannerTaskId
- type: string
- default value: empty
- source: SharePoint get item PlannerTaskId field
- validation: string length

## Actions
1. action name: Get SharePoint Item
   connector: SharePoint
   operationId: GetItem
   input parameters: list=Tarefas, id=spItemId
   expressions: N/A
   run-after behavior: after trigger
   success output shape: item object
   failure behavior: fail flow

2. action name: Determine Bucket and Percent
   connector: Built-in Data Operation
   operationId: Compose
   input parameters: Map target status to bucket ID and percentComplete
   expressions: if status=='Pendente' then {bucketId: 'HmzyGOgC4k6uOPm_cwG3zZcAGiAG', percentComplete: 0}, if status=='Em Andamento' then {bucketId: 'ugZSNxsYW0WWCJ5Dtx0-l5cALVXG', percentComplete: 50}, if status=='Testes' then {bucketId: '7QYPufh54kum7MP4KUzzAZcAL6Ik', percentComplete: 50}, if status=='Piloto e Implantacao' then {bucketId: '4YAXH7iU9E-6jZE2P1DbG5cAMAzH', percentComplete: 50}, if status=='Concluido' then {bucketId: 'F2WYUsnXeEue5qlwQuu3GJcAN1Ns', percentComplete: 100}, if status=='Cancelado' then {bucketId: '90TcFTFup0CjiHIdzY4gG5cALWKL', percentComplete: 100}
   run-after behavior: after Get SharePoint Item
   success output shape: object with bucketId and percentComplete
   failure behavior: fail flow

3. action name: Update Planner Task
   connector: Planner
   operationId: UpdateTask_V2
   input parameters: id=TargetPlannerTaskId, body/percentComplete=DetermineBucketAndPercent_Output.percentComplete
   expressions: N/A
   run-after behavior: after Determine Bucket and Percent
   success output shape: task object
   failure behavior: fail flow

4. action name: Update SharePoint Item
   connector: SharePoint
   operationId: UpdateItem
   input parameters: list=Tarefas, id=spItemId, Status=status
   expressions: N/A
   run-after behavior: after Update Planner Task
   success output shape: item object
   failure behavior: fail flow

5. action name: Respond
   connector: Power Virtual Agents
   operationId: ReturnResponse
   input parameters: success message
   expressions: N/A
   run-after behavior: after Update SharePoint Item
   success output shape: object
   failure behavior: fail flow

## SharePoint Behavior
- list name: Tarefas
- filter queries: none
- top limits: 1
- selected columns: PlannerTaskId
- write order: Get, then Update
- idempotency behavior: overwrite
- no raw row output to Copilot: Yes

## Planner Behavior
- operationId: UpdateTask_V2
- groupId: 96c5b0c4-46cc-46cd-8695-50451db74994
- planId: -1kBj1PLv0qQM-R4PwkqbpcABv_P
- bucket IDs from AQ-04: explicitly mapped based on canonical SharePoint Status values
- canonical SharePoint Status values accepted by this flow: Pendente, Em Andamento, Testes, Piloto e Implantacao, Concluido, Cancelado
- Planner progress values: Pendente=0, Em Andamento/Testes/Piloto e Implantacao=50, Concluido/Cancelado=100
- conditional create/update path: always update
- exact Planner fields to write: percentComplete
- exact SharePoint fields to write: Status, PlannerBucketId, PlannerSyncStatus, PlannerLastSyncAt, PlannerSyncError
- error sanitization: yes
- no Planner write unless this specific flow behavior is later approved in AQ-07/AQ-09: Yes

## Teams/Card Behavior
- route key: task.card.route
- target route: card
- card template: AtualizarTarefaCard.json
- submit payload expected from card: task update data
- action dispatch rule: routeKey + action
- operationId is correlation ID only, not action selector: Yes

## Copilot Return Contract
- exact static ASCII response string: "Task updated successfully."
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
