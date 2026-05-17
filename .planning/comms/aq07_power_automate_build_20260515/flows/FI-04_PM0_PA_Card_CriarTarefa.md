## Identity
- Flow key: FI-04
- Display name: PM0_PA_Card_CriarTarefa
- Purpose: Create new task in Planner and sync to SharePoint
- Route key: task.card.route
- Card templates: CriarTarefaCard.json
- Owner approval required before tenant save/import: yes

## Trigger
- Exact trigger type: When Copilot Studio calls an action
- Expected Copilot or manual input schema: Task title, project ID, action, optional target bucket string
- Required fields: title, projectId, action
- Optional fields: startDate, endDate, bucket
- Validation rules: sanitize inputs, action must equal 'create'

## Variables
- name: NewPlannerTaskId
- type: string
- default value: empty
- source: Planner Create Task output
- validation: string length

## Actions
1. action name: Determine Bucket and Status
   connector: Built-in Data Operation
   operationId: Compose
   input parameters: Map input bucket string to exact AQ-04 ID and status
   expressions: if bucket=='Piloto e Implantacao' then {bucketId: '4YAXH7iU9E-6jZE2P1DbG5cAMAzH', status: 'Piloto e Implantacao'}, if bucket=='Testes' then {bucketId: '7QYPufh54kum7MP4KUzzAZcAL6Ik', status: 'Testes'}, if bucket=='Cancelado' then {bucketId: '90TcFTFup0CjiHIdzY4gG5cALWKL', status: 'Cancelado'}, if bucket=='Concluido' then {bucketId: 'F2WYUsnXeEue5qlwQuu3GJcAN1Ns', status: 'Concluido'}, if bucket=='Em Andamento' then {bucketId: 'ugZSNxsYW0WWCJ5Dtx0-l5cALVXG', status: 'Em Andamento'}, else {bucketId: 'HmzyGOgC4k6uOPm_cwG3zZcAGiAG', status: 'Pendente'}
   run-after behavior: after trigger
   success output shape: object with bucketId and status
   failure behavior: fail flow

2. action name: Create Planner Task
   connector: Planner
   operationId: CreateTask_V3
   input parameters: groupId=96c5b0c4-46cc-46cd-8695-50451db74994, planId=-1kBj1PLv0qQM-R4PwkqbpcABv_P, bucketId=DetermineBucketAndStatus_Output.bucketId, title=triggerBody()?['title'], startDateTime=triggerBody()?['startDate'], dueDateTime=triggerBody()?['endDate']
   expressions: N/A
   run-after behavior: after Determine Bucket and Status
   success output shape: task object
   failure behavior: fail flow

3. action name: Create SharePoint Item
   connector: SharePoint
   operationId: CreateItem
   input parameters: list=Tarefas, Title=triggerBody()?['title'], ProjectID=triggerBody()?['projectId'], Status=DetermineBucketAndStatus_Output.status, PlannerTaskId=NewPlannerTaskId, PlannerBucketId=DetermineBucketAndStatus_Output.bucketId, PlannerSyncStatus='OK', PlannerLastSyncAt=utcNow(), PlannerSyncError=''
   expressions: N/A
   run-after behavior: after Create Planner Task
   success output shape: item object
   failure behavior: sanitize error and update sync status

4. action name: Respond
   connector: Power Virtual Agents
   operationId: ReturnResponse
   input parameters: success message
   expressions: N/A
   run-after behavior: after Create SharePoint Item
   success output shape: object
   failure behavior: fail flow

## SharePoint Behavior
- list name: Tarefas
- filter queries: none
- top limits: N/A
- selected columns: N/A
- required fields populated: Title, ProjectID, Status
- planner sync fields populated: PlannerTaskId, PlannerBucketId, PlannerSyncStatus, PlannerLastSyncAt, PlannerSyncError
- write order: Planner create first, then SharePoint create
- idempotency behavior: single create
- no raw row output to Copilot: Yes

## Planner Behavior
- operationId: CreateTask_V3
- groupId: 96c5b0c4-46cc-46cd-8695-50451db74994
- planId: -1kBj1PLv0qQM-R4PwkqbpcABv_P
- bucket IDs from AQ-04: explicitly mapped, default is HmzyGOgC4k6uOPm_cwG3zZcAGiAG (Pendente)
- canonical SharePoint Status values written by this flow: Pendente, Em Andamento, Testes, Piloto e Implantacao, Concluido, Cancelado
- conditional create/update path: always create
- exact fields to write: title, start date, due date
- error sanitization: remove stack traces, truncate
- no Planner write unless this specific flow behavior is later approved in AQ-07/AQ-09: Yes

## Teams/Card Behavior
- route key: task.card.route
- target route: card
- card template: CriarTarefaCard.json
- submit payload expected from card: task creation data
- action dispatch rule: routeKey + action
- operationId is correlation ID only, not action selector: Yes

## Copilot Return Contract
- exact static ASCII response string: "Task created successfully."
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
- disable/revert path: turn off flow, manual delete test task
- what to preserve: connections
- what not to delete without separate approval: flow definition
