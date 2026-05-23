# CODEX #2 — PM0 FIXES R&D-GRADE — IMPLEMENT, PACKAGE, PUBLISH, SMOKE

| Field | Value |
|---|---|
| Mission ID | `PM0-FIXES-20260522-CODEX2` |
| Severity | `SEV-0` |
| Date issued | `2026-05-22 16:30 BRT` |
| Owner | Manoel Benicio (sole approver) |
| Owner directive (literal) | All 5 PM0 flows must be fixed in scope. AtualizarStatus must be implemented in full (no deferral). FIX-AND-SHIP path. Quality gates mandatory. Codex authorized for tenant writes per individual owner approval. |
| Continuation | Continues from Codex #3 handoff at `.planning/comms/codex_pm0_audit_20260522/HANDOFF_TO_OTHER_IDE_20260522.md` (timestamp `2026-05-22 16:12:42 BRT`). Codex #3 delivered 3 local verifier scripts, currently failing as expected against broken PM0 source. Codex #1 Lead is implementing fixes in parallel under `.planning/comms/codex_pm0_remediation_20260522/PROMPT_CODEX_1_LEAD_R&D.md`. |
| Source of truth | `learn.microsoft.com` only — every Microsoft product behavior must be cited from official Learn docs with full URL and accessed timestamp BRT |
| Tenant write authorization | Granted to Codex (#1 and #2) per owner directive. Each individual write requires explicit owner approval verbatim in the active thread before execution. |
| Kiro role | Read-only. Kiro does not edit tenant. |
| Sync channel | `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` (append-only, 10-minute cadence) |

---

## 0. MANDATORY GOLDEN RULES (read updated `.planning/GOLDEN_RULES.md` first)

Three rules added to `.planning/GOLDEN_RULES.md` at `2026-05-22 15:58 BRT`. They govern this mission. Re-read before starting.

### 0.1 Continuous Documentation Update Rule
After every action (file read, command run, evidence captured, decision rendered, gate transition), update the relevant project doc immediately. No batching. Every doc edit must carry header:
```
Last updated: <YYYY-MM-DD HH:mm:ss BRT> | <agent_name> | <one-line reason>
```
And be logged in `DOC_UPDATES_LOG.md` with diff link.

### 0.2 Evidence Triplet Rule (MANDATORY)
Every test, deploy, audit, gate, smoke, and DONE/PASS/PUBLISH claim MUST include all three:

| Element | Specification |
|---|---|
| **Screenshot (printscreen)** | PNG or JPG file. Required for any UI surface (Copilot Studio test panel, Teams chat, SharePoint UI, Power Automate run history, `pac` terminal). For pure CLI: full terminal screenshot or rendered output, not just text logs. Captured at moment of action. |
| **Timestamp BRT** | Exact `YYYY-MM-DD HH:mm:ss BRT`, captured by the agent at moment of action (not afterwards from memory). |
| **Agent name** | Named agent (`Codex #2`, `Codex sub-2A`, `Codex sub-2B`, `Codex sub-2C`). No anonymous evidence. |

Storage path:
```
.planning/comms/codex_pm0_remediation_20260522/CODEX2/<workstream>/evidence/<YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}
```
Index: `EVIDENCE_LOG.md`. One row per evidence file.

If any of the three elements is missing, the entry is `INCOMPLETE`. Cannot be cited as DONE/PASS/PUBLISH. Re-execute with full triplet capture.

Owner literal directive (preserved): *"todos testes e deploy somente são considerados entregues se tiver timestamp do agente, nome e evidência com printscreen"*.

### 0.3 Functional Definition of Done Rule (MANDATORY)
A flow is DONE only when:

1. Real runtime call returns real backend data (not hardcoded placeholder).
2. Runtime call evidence captured per Evidence Triplet.
3. Bot end-to-end test reproduces successful outcome with real data in bot reply.
4. Action `.mcs.yml` declares `inputs:` matching workflow trigger schema.
5. Topic `.mcs.yml` `BeginDialog input:` Power Fx mapping passes all required workflow trigger fields.
6. No agent writes DONE/PASS/PUBLISH_GO until conditions 1-5 above are evidenced.

Verifiers must include functional checks. A verifier returning PASS without evidencing conditions 1-5 is itself a defect.

---

## 1. MANDATORY READING (Codex #3 handoff + audit artifacts)

Read these in order before starting technical work. Confirm reading by listing each path with one-line summary in your first response.

### 1.1 Project rules and state

| File | Purpose |
|---|---|
| `.planning/GOLDEN_RULES.md` | Mandatory rules (Continuous Doc, Evidence Triplet, Functional DoD) |
| `.planning/CURRENT_BASELINE.md` | Active 3.15.1 artifact, rollback target |
| `.planning/AGENT_CHECKIN_REGISTRY.md` | Active ownership and audit history |
| `.planning/START_HERE_CURRENT_STATUS.md` | Current release state |
| `.planning/stop_ship/MASTER_CHECKLIST.md` | Stop-ship gates |
| `.planning/stop_ship/RISK_REGISTER.md` | Open risks including PM0 SEV-0 |
| `docs/MANUAL_OPERACIONAL_PMO.md` | PMO operational behavior baseline |

### 1.2 Codex #3 handoff (your starting point)

| File | Purpose |
|---|---|
| `.planning/comms/codex_pm0_audit_20260522/HANDOFF_TO_OTHER_IDE_20260522.md` | Codex #3 handoff with verifier results and next safe steps |
| `tests/Test-Pm0TopicActionFlowContract.ps1` | Codex #3 verifier — topic↔action↔flow contract |
| `tests/Test-Pm0WorkflowResponseSemantics.ps1` | Codex #3 verifier — Response body dynamic content |
| `tests/Test-Pm0RuntimeEvidence.ps1` | Codex #3 verifier — evidence triplet present |
| `.planning/comms/codex_pm0_audit_20260522/PM0_LOCAL_VERIFIERS/` | Codex #3 verifier evidence folder (current expected FAIL state) |

### 1.3 Audit artifacts from prior round

| File | Purpose |
|---|---|
| `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md` | Root cause analysis |
| `.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md` | Remediation directives |
| `.planning/comms/codex_pm0_audit_20260522/MITIGATION_PLAN.md` | Mitigation/rollback options |
| `.planning/comms/codex_pm0_audit_20260522/EXECUTIVE_SUMMARY.md` | Owner-facing summary |
| `.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/AUDIT_TABLE.md` | Workflow body audit |
| `.planning/comms/codex_pm0_audit_20260522/ALPHA/A2_actions/AUDIT_TABLE.md` | Action contract audit |
| `.planning/comms/codex_pm0_audit_20260522/ALPHA/A3_topics/AUDIT_TABLE.md` | Topic contract audit |
| `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md` | Microsoft Learn citation index |
| `.planning/comms/codex_pm0_audit_20260522/BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md` | Process failure root cause |

### 1.4 Codex #1 Lead parallel mission

| File | Purpose |
|---|---|
| `.planning/comms/codex_pm0_remediation_20260522/PROMPT_CODEX_1_LEAD_R&D.md` | Codex #1 mission spec — Team Alpha (workflow body, action inputs, topic mapping fixes) |

You and Codex #1 work in parallel. Codex #1 owns Alpha (per-flow source patches). You own this mission (full-flow remediation including AtualizarStatus from-scratch implementation, package build, tenant operations, AQ-09 smoke). Coordination via `INVESTIGATION_LOG.md`.

---

## 2. SCOPE — 5 PM0 FLOWS, ALL IN RELEASE 3.16, NO DEFERRALS

Owner directive 2026-05-22 16:26 BRT (literal): *"vc vai incluir sim a porra do Atualizarstatus... coloca a porra desse atualizar status pra ser feito imediatamente"*.

**No flow may be deferred. All 5 must be fully functional in release 3.16.**

| Topic | Action | Workflow ID | Current state (per audit) | Required final state |
|---|---|---|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` | **STUB** — no SP/Planner backend; only static Teams card text "Status update requested"; hardcoded Response | Full SharePoint backend (Get_Project, Create_StatusDiario, Update_Project_RAG), dynamic Adaptive Card, dynamic Response |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` | **PARTIAL** — has SP Get/Patch + Planner Update; hardcoded Response; action no inputs; topic empty | Action declares inputs; topic maps; Response references SP/Planner outputs dynamically |
| `ConsultarPortfolio` (action `PM0_PA_Card_ResumoExecutivoPortfolio`) | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` | **PARTIAL** — has SP Get_Projetos + Get_Tarefas; hardcoded Response; no aggregation; no card | Aggregation logic (filter, group), dynamic Response with counts, Adaptive Card with FactSet |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` | **PARTIAL** — has Planner Create + SP Create; hardcoded Response; action no inputs; topic empty | Action declares inputs; topic maps with ProjectID resolution; Response references created item; card |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` | **PARTIAL** — has SP Get_Tarefas + Planner List + Normalize_Tasks Select; Response is hardcoded and does not serialize the normalized list | Action declares inputs; topic maps with ProjectID resolution; Response serializes Normalize_Tasks output; card |

**Out-of-scope for this mission:** 7 legacy `PMO_PA_*` topics remain on legacy per ADR_AQ08.

---

## 3. RELATIONSHIP WITH CODEX #1 LEAD (parallel team)

Codex #1 Lead is implementing fixes for the 4 PARTIAL flows under Team Alpha (workflow Response patches + action inputs declarations + topic input mapping). Verify Codex #1's progress at `.planning/comms/codex_pm0_remediation_20260522/ALPHA/` before duplicating work.

**Your unique additions over Codex #1:**

1. **AtualizarStatus full backend implementation** (Codex #1 only patches existing code — for AtualizarStatus the backend doesn't exist, so you build it from scratch)
2. **ProjectID resolution helper for ListarTarefas and CriarTarefa** (upstream `Get items` SharePoint lookup converting project name → ProjectID before action call)
3. **Adaptive Card dynamic content patches** for all 5 flows where applicable (use existing `deploy/cards/*.json` as base; render with workflow output data)
4. **Solution package 3.16 build + import + publish**
5. **AQ-09 12-scenario runtime smoke with full Evidence Triplet**
6. **Post-publish structural + functional verifier runs (using Codex #3's 3 verifier scripts)**

If Codex #1 has already committed a fix for any of items 1-3 (check `ALPHA/` folder), do not overwrite. Add only what is missing. Coordinate via `INVESTIGATION_LOG.md`.

---

## 4. FIX SPECIFICATIONS — PER FLOW (mandatory implementation)

For each flow, produce all 4 patches (workflow.json, action.mcs.yml, topic.mcs.yml, Adaptive Card JSON if applicable). Save patches under `.planning/comms/codex_pm0_remediation_20260522/CODEX2/<flow>/` with full Evidence Triplet per change.

### 4.1 PM0_PA_Card_AtualizarStatus — FULL FROM-SCRATCH BACKEND

**Owner directive 2026-05-22 16:26 BRT:** AtualizarStatus must be fully implemented in this release. No deferral.

#### 4.1.1 Workflow trigger schema (target)

Replace current schema (only `routeKey`) with:

```json
{
  "type": "object",
  "properties": {
    "routeKey":     {"type": "string", "description": "Route key"},
    "projectId":    {"type": "string", "description": "PMO ProjectID (PRJ-XXXXXXXX)"},
    "rag":          {"type": "string", "description": "Status RAG: Verde, Amarelo, Vermelho"},
    "resumo":       {"type": "string", "description": "Status summary text"},
    "percentual":   {"type": "number", "description": "Completion percent (0-100)"},
    "risco":        {"type": "string", "description": "Risk note"},
    "bloqueio":     {"type": "string", "description": "Blocker note"},
    "proximaAcao":  {"type": "string", "description": "Next action"}
  },
  "required": ["routeKey", "projectId", "rag", "resumo"]
}
```

#### 4.1.2 Workflow body (target action chain)

| Order | Action name | Type | Purpose |
|---|---|---|---|
| 1 | `Get_Project` | SharePoint `GetItems` | List `Projetos` filtered `ProjectID eq '@{triggerBody()?[''projectId'']}'`, `$top=1` |
| 2 | `Validate_Project_Exists` | Condition | If `length(body('Get_Project')?['value'])` is 0 → branch to `Respond_NotFound`; else continue |
| 3 | `Create_StatusDiario` | SharePoint `PostItem` | Insert into `Status Diario` list with: `Title='@{concat(''STU-'',formatDateTime(utcNow(),''yyyyMMddHHmmss''))}'`, `ProjectID=@triggerBody()?['projectId']`, `RAG=@triggerBody()?['rag']`, `Resumo=@triggerBody()?['resumo']`, `Percentual=@triggerBody()?['percentual']`, `Risco=@triggerBody()?['risco']`, `Bloqueio=@triggerBody()?['bloqueio']`, `ProximaAcao=@triggerBody()?['proximaAcao']`, `Deleted=false`, `Created=@utcNow()` |
| 4 | `Update_Project_RAG` | SharePoint `PatchItem` | Update `Projetos` row with `id=@first(body('Get_Project')?['value'])?['ID']`, `StatusRAG/Value=@triggerBody()?['rag']`, `Percentual=@triggerBody()?['percentual']`, `UltimaAtualizacao=@utcNow()` |
| 5 | `Post_Status_Card` | Teams `PostCardToConversation` | Post Adaptive Card (see §4.1.4) to channel `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2`, group `96c5b0c4-46cc-46cd-8695-50451db74994`, body bound to dynamic project + status data |
| 6 | `Respond_Success` | Response (`kind: Skills`) | Body: `{"result": "@{concat('Status registrado para ', first(body('Get_Project')?['value'])?['Title'], ' (RAG=', triggerBody()?['rag'], ', ', string(triggerBody()?['percentual']), '%). Status Diario item ', body('Create_StatusDiario')?['ID'], '.')}"}` |
| 7 | `Respond_NotFound` (in else branch) | Response | Body: `{"result": "@{concat('Projeto nao encontrado: ', triggerBody()?['projectId'])}"}` |

MS Learn citations required (cite from B2 CITATION_INDEX.md):
- SharePoint Standard `GetItems`, `PostItem`, `PatchItem` operations
- Teams Standard `PostCardToConversation` operation
- Power Automate Response `kind: Skills` shape

#### 4.1.3 Action `.mcs.yml` (target)

```yaml
mcs.metadata:
  componentName: PM0_PA_Card_AtualizarStatus
  description: Registra status diario do projeto, atualiza RAG e posta card no Teams.
kind: TaskDialog
inputs:
  - propertyName: routeKey
    description: Route key
  - propertyName: projectId
    description: PMO ProjectID
  - propertyName: rag
    description: Status RAG (Verde, Amarelo, Vermelho)
  - propertyName: resumo
    description: Status summary
  - propertyName: percentual
    description: Completion percent
  - propertyName: risco
    description: Risk note
  - propertyName: bloqueio
    description: Blocker note
  - propertyName: proximaAcao
    description: Next action
outputs:
  - propertyName: result
action:
  kind: InvokeFlowTaskAction
  flowId: 1721e0a3-a250-f111-bec7-000d3abc5cc6
  connectionProperties:
    $kind: ConnectionProperties
    diagnostics:
    mode: Invoker
outputMode: All
```

#### 4.1.4 Topic `.mcs.yml` `BeginDialog` patch

Replace the current `input: {}` with:

```yaml
- kind: BeginDialog
  id: invokeFlowAction_atualizar_status
  input:
    routeKey: ="atualizar_status_v1"
    projectId: =Topic.ProjectIDResolved
    rag: =Topic.RAG
    resumo: =Topic.Resumo
    percentual: =Topic.Percentual
    risco: =Topic.Risco
    bloqueio: =Topic.Bloqueio
    proximaAcao: =Topic.ProximaAcao
  dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus
  output:
    binding:
      result: Topic.AtualizarStatusResult
```

Add upstream ProjectID resolution before the BeginDialog block (since user types project name, not ProjectID):

```yaml
- kind: SearchAndSummarizeContent
  # OR a SharePoint Get items lookup pattern. Use whichever the topic engine supports natively.
- kind: SetVariable
  id: resolve_project_id
  variable: Topic.ProjectIDResolved
  value: |
    =If(StartsWith(Upper(Topic.Projeto), "PRJ-"), Topic.Projeto,
        First(Filter(SP_Projetos_ByName, Title = Topic.Projeto)).ProjectID)
```

If Power Fx native lookup is not available in topic, perform the lookup inside the workflow (extra `Get_Project_By_Name` action filtering `Title eq @triggerBody()?['projectName']` and use its ProjectID downstream). Document the chosen pattern with MS Learn citation.

#### 4.1.5 Adaptive Card JSON (target — body posted in Teams)

Save under `deploy/cards/AtualizarStatusCard_v316.json`:

```json
{
  "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
  "type": "AdaptiveCard",
  "version": "1.5",
  "body": [
    { "type": "TextBlock", "text": "Status Diario PMO", "weight": "Bolder", "size": "Medium" },
    { "type": "FactSet", "facts": [
      { "title": "Projeto", "value": "${projectTitle}" },
      { "title": "ProjectID", "value": "${projectId}" },
      { "title": "RAG", "value": "${rag}" },
      { "title": "Percentual", "value": "${percentual}%" },
      { "title": "Resumo", "value": "${resumo}" },
      { "title": "Risco", "value": "${risco}" },
      { "title": "Bloqueio", "value": "${bloqueio}" },
      { "title": "Proxima Acao", "value": "${proximaAcao}" }
    ]},
    { "type": "TextBlock", "text": "Item Status Diario: ${statusItemId}", "isSubtle": true, "size": "Small" }
  ]
}
```

Cite Adaptive Cards 1.5 schema from MS Learn CITATION_INDEX.

### 4.2 PM0_PA_Card_AtualizarTarefa — PATCH

If Codex #1 Alpha has not committed, you implement. If committed, validate and add Adaptive Card patch only.

#### Action inputs (declare):
`taskId`, `status`, `horasRealizadas`, `responsavel`, `dataFim`, `prioridade`, `comments`, `action`

#### Topic input mapping:
```yaml
input:
  taskId: =Topic.TaskID
  status: =Topic.Status
  horasRealizadas: =Topic.HorasRealizadas
  responsavel: =Topic.Responsavel
  dataFim: =Topic.DataFim
  prioridade: =Topic.Prioridade
  action: ="update_task_v1"
```

#### Workflow Response body (replace hardcoded):
```json
{
  "result": "@{concat('Tarefa ', triggerBody()?['taskId'], ' atualizada para ', triggerBody()?['status'], '. Responsavel: ', if(empty(triggerBody()?['responsavel']),'mantido',triggerBody()?['responsavel']), '. Prazo: ', if(empty(triggerBody()?['dataFim']),'mantido',triggerBody()?['dataFim']), '. Item SP: ', body('Update_SharePoint_Item')?['ID'], '.')}"
}
```

#### Adaptive Card update (use existing `deploy/cards/AtualizarTarefaCard.json`, bind dynamic data).

### 4.3 PM0_PA_Card_CriarTarefa — PATCH

#### Action inputs (declare):
`projectId`, `action`, `title`, `taskTitle`, `responsavel`, `prazo`, `dueDate`, `horas`, `prioridade`, `bucket`, `plannerBucketName`

#### Topic input mapping (with upstream ProjectID resolution):
```yaml
input:
  projectId: =Topic.ProjectIDResolved
  title: =Topic.Titulo
  responsavel: =Topic.Responsavel
  dueDate: =Topic.Prazo
  horas: =Topic.Horas
  prioridade: =Topic.Prioridade
  bucket: =Topic.Bucket
  action: ="create_task_v1"
```

#### Workflow Response body:
```json
{
  "result": "@{concat('Tarefa criada: ', triggerBody()?['title'], ' (Projeto ', triggerBody()?['projectId'], ', Item SP ', body('Create_SharePoint_Item')?['ID'], ', Planner ', body('Create_Planner_Task')?['id'], ', Bucket ', outputs('Determine_Bucket_and_Status')?['status'], ').')}"
}
```

### 4.4 PM0_PA_Card_ListarTarefas — PATCH

#### Action inputs (declare):
`projectId`, `action`

#### Topic input mapping (with upstream ProjectID resolution):
```yaml
input:
  projectId: =Topic.ProjectIDResolved
  action: ="list_tasks_v1"
```

#### Workflow patch — add `Normalize_Tasks_Display` Select before Response:

```json
"Normalize_Tasks_Display": {
  "runAfter": { "Normalize_Tasks": ["Succeeded"] },
  "type": "Select",
  "inputs": {
    "from": "@body('Normalize_Tasks')",
    "select": "@concat('- ', item()?['title'], ' [Status: ', coalesce(item()?['status'],'Pendente'), '] (Item SP ', item()?['plannerTaskId'], ')')"
  }
}
```

#### Workflow Response body (replace hardcoded):
```json
{
  "result": "@{if(equals(length(body('Normalize_Tasks')),0), concat('Nenhuma tarefa ativa para o projeto ', triggerBody()?['projectId'], '.'), concat('Tarefas do projeto ', triggerBody()?['projectId'], ' (', string(length(body('Normalize_Tasks'))), ' itens):', char(10), join(body('Normalize_Tasks_Display'), char(10))))}"
}
```

#### Adaptive Card (new): `deploy/cards/ListarTarefasCard_v316.json` with FactSet of tasks (use Adaptive Cards 1.5 templating).

### 4.5 PM0_PA_Card_ResumoExecutivoPortfolio — PATCH

#### Action inputs (declare): none (matches workflow `required: []`).

#### Topic input mapping: `input: {}` is correct here.

#### Workflow patches — add aggregation actions before Response:

```json
"Filter_Active_Projects": {
  "runAfter": { "Get_Tarefas": ["Succeeded"] },
  "type": "Query",
  "inputs": {
    "from": "@body('Get_Projetos')?['value']",
    "where": "@and(equals(item()?['Ativo'], true), not(equals(item()?['Deleted'], true)))"
  }
},
"Group_RAG": {
  "runAfter": { "Filter_Active_Projects": ["Succeeded"] },
  "type": "Compose",
  "inputs": {
    "verde":     "@length(filter(body('Filter_Active_Projects'), equals(item()?['StatusRAG']?['Value'], 'Verde')))",
    "amarelo":   "@length(filter(body('Filter_Active_Projects'), equals(item()?['StatusRAG']?['Value'], 'Amarelo')))",
    "vermelho":  "@length(filter(body('Filter_Active_Projects'), equals(item()?['StatusRAG']?['Value'], 'Vermelho')))"
  }
},
"Filter_Active_Tasks": {
  "runAfter": { "Group_RAG": ["Succeeded"] },
  "type": "Query",
  "inputs": {
    "from": "@body('Get_Tarefas')?['value']",
    "where": "@and(not(equals(item()?['Deleted'], true)), not(equals(item()?['Status']?['Value'], 'Concluida')))"
  }
}
```

#### Workflow Response body:
```json
{
  "result": "@{concat('Portfolio: ', string(length(body('Filter_Active_Projects'))), ' projetos ativos (Verde=', string(outputs('Group_RAG')?['verde']), ', Amarelo=', string(outputs('Group_RAG')?['amarelo']), ', Vermelho=', string(outputs('Group_RAG')?['vermelho']), '). Tarefas em aberto: ', string(length(body('Filter_Active_Tasks'))), '.')}"
}
```

#### Adaptive Card (new): `deploy/cards/ResumoExecutivoPortfolioCard_v316.json` with FactSet showing all 4 totals.

---

## 5. PER-FLOW DELIVERABLES (mandatory)

For each of the 5 flows, produce under `.planning/comms/codex_pm0_remediation_20260522/CODEX2/<flow>/`:

```
<flow>/
├── DEFECT_FIX_REPORT.md          (defects closed, before/after, MS Learn cites)
├── workflow_patch.diff            (unified diff of workflow.json — full backend including new actions for AtualizarStatus)
├── action_patch.diff              (unified diff of action.mcs.yml)
├── topic_patch.diff               (unified diff of topic.mcs.yml — including ProjectID resolution upstream)
├── card_patch.diff                (unified diff of Adaptive Card JSON if changed)
├── unit_test/
│   ├── test_workflow_response_dynamic.ps1   (asserts Response body references action outputs)
│   ├── test_workflow_actions_present.ps1    (asserts SP/Planner/Teams actions exist in chain)
│   ├── test_action_inputs_match.ps1          (asserts action declares all required workflow trigger fields)
│   ├── test_topic_input_mapping.ps1         (asserts topic maps all action inputs)
│   ├── test_no_placeholder.ps1               (greps for hardcoded "successfully.", "placeholder", "todo")
│   └── results/<test>_<YYYYMMDD_HHmmss>.{json,txt}
└── evidence/
    └── <YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}
```

DEFECT_FIX_REPORT.md must use this template:

```markdown
## DEFECT-<ID>

**Severity:** SEV-0 / HIGH / MEDIUM
**File:** <path>
**Line(s):** <L1-L2>

### Before (verbatim broken code)
<code block>

### After (verbatim fixed code)
<code block>

### Why this fixes the defect
<2-3 sentences citing the workflow/action/topic contract from §4 and the relevant MS Learn URL>

### MS Learn citation
<URL> | accessed <YYYY-MM-DD HH:mm:ss BRT> | excerpt: "<quoted relevant section>"

### Unit test
<path to test PS1> | run command | expected exit code | actual exit code | output JSON path

### Evidence triplet
- Screenshot: <path>
- Timestamp BRT: <YYYY-MM-DD HH:mm:ss>
- Agent: <Codex sub-2A / 2B / 2C>
```

---

## 6. CRITICAL BLOCKERS — ATTACK ALL OF THESE IN PARALLEL (no waiting)

Owner directive 2026-05-22 16:39 BRT: attack everything at once. Use up to 3 subagents in parallel. Below are every blocker known. Do not return to owner asking which to do first — do all of them.

### 6.0 Codex #1 Lead handoff state (verbatim)

Codex Lead reported at 2026-05-22 16:37 BRT:
- ✅ Alpha local patches DONE: 5 per-flow `DEFECT_FIX_REPORT.md` written under `.planning/comms/codex_pm0_remediation_20260522/ALPHA/`
- ✅ Final local checks PASS at `2026-05-22 16:33:00 BRT`: workflow response semantics, topic/action/workflow contract, placeholder + non-ASCII scan
- ✅ Project docs synchronized: `CURRENT_BASELINE.md`, `RISK_REGISTER.md`, M2 `STATE.md`, exec status report, `AGENT_CHECKIN_REGISTRY.md`, `INVESTIGATION_LOG.md`, `DOC_UPDATES_LOG.md`
- ❌ **Gate 3 package build NOT done — `3.15.1` zip does NOT contain `PM0_PA_Card_*` workflow entries**
- ❌ Tenant write, import, publish, PAC tenant command, runtime smoke — none performed

Read these before starting:
- `.planning/comms/codex_pm0_remediation_20260522/ALPHA/AtualizarStatus/DEFECT_FIX_REPORT.md`
- `.planning/comms/codex_pm0_remediation_20260522/ALPHA/AtualizarTarefa/DEFECT_FIX_REPORT.md`
- `.planning/comms/codex_pm0_remediation_20260522/ALPHA/CriarTarefa/DEFECT_FIX_REPORT.md`
- `.planning/comms/codex_pm0_remediation_20260522/ALPHA/ListarTarefas/DEFECT_FIX_REPORT.md`
- `.planning/comms/codex_pm0_remediation_20260522/ALPHA/ConsultarPortfolio/DEFECT_FIX_REPORT.md`
- `.planning/comms/codex_pm0_remediation_20260522/ALPHA/evidence/20260522_163300_CodexLead_*_final.md`
- `.planning/comms/codex_pm0_remediation_20260522/EVIDENCE_LOG.md`
- `tests/Test-Pm0TopicActionFlowContract.ps1` (strengthened by Codex Lead — now checks every declared action input)

### 6.1 BLOCKER #1 — Package build 3.16 (HIGHEST PRIORITY)

The active `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip` does NOT include the 5 `PM0_PA_Card_*` workflows as solution components. Package build is the critical blocker for Gate 4 owner approval.

**Subagent 2A — Package Build Engineer**

Tasks:

1. Investigate solution component packaging via official Microsoft Learn:
   - `pac solution add-solution-component` semantics
   - `Solution.xml` manifest workflow component entries
   - `customizations.xml` workflow embedding
   - How to include Power Automate flows in unmanaged solution export
   - Cite every URL with accessed timestamp BRT in `BRAVO/B2_ms_learn_citations/CITATION_INDEX.md`

2. Verify in tenant if the 5 workflow IDs are already members of the `pmo_AssistentePMO_V2` solution:
   ```powershell
   pac auth list
   pac env who   # confirm ColOfertasBrasilPro
   pac solution list
   pac org fetch --xml @"
   <fetch><entity name='solutioncomponent'>
     <attribute name='objectid'/><attribute name='componenttype'/>
     <filter><condition attribute='solutionid' operator='eq' value='<pmo_AssistentePMO_V2_solution_guid>'/>
             <condition attribute='componenttype' operator='eq' value='29'/></filter>
   </entity></fetch>
   "@
   ```
   Capture screenshot of output. If the 5 PM0 workflows are NOT solution members, Codex must add them via `pac solution add-solution-component` (component type `29` = Workflow) — this is a tenant write and requires Gate 4 owner approval.

3. Build the new package `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip`:
   - Adapt `scripts/Build-Solution315ListStaticRuntimeBypass.ps1` → `scripts/Build-Solution316Pm0FunctionalFix.ps1`
   - Source: patched `Local_Repo/Assistente PMO V2/`
   - Use `pac solution pack` per MS Learn (cite URL)
   - Confirm zip contains `Workflows/PM0_PA_Card_*-<id>.json` entries
   - Confirm zip contains updated `customizations.xml` with `<Workflow>` elements
   - Confirm `Solution.xml` lists each workflow with version, statecode, statuscode
   - Confirm zip contains the 5 actions and 5 topics under their MCS folders
   - Compute SHA256
   - Document version `3.16.0.0`
   - Run automated grep:
     ```powershell
     Expand-Archive -Path 'Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip' -DestinationPath 'temp_3_16'
     $hits = Select-String -Path "temp_3_16/Workflows/PM0_PA_Card_*.json" -Pattern '"result"\s*:\s*"[^@{][^"]*successfully\."'
     if ($hits) { throw "Hardcoded placeholders found: $($hits.Count)" }
     ```

4. Diff `3.16` vs `3.15.1` zip contents:
   - Workflow files added/changed
   - Action `.mcs.yml` changes
   - Topic `.mcs.yml` changes
   - Adaptive Card JSON additions
   - Save diff to `BRAVO/PACKAGE_AND_PUBLISH/diff_3_16_vs_3_15_1.md`

Deliverables:
```
.planning/comms/codex_pm0_remediation_20260522/CODEX2/PACKAGE/
├── Build-Solution316Pm0FunctionalFix.ps1
├── package_build_log.txt
├── package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip
├── package_sha256.txt
├── package_inventory.md       (list of every workflow/action/topic/card in zip)
├── diff_3_16_vs_3_15_1.md
├── solution_membership_preflight.md (PAC fetchxml output for solution components)
└── evidence/<ts>_<agent>_<step>.{png,txt,json}
```

### 6.2 BLOCKER #2 — Run all verifiers against patched local source

**Subagent 2B — Verifier Operator**

Tasks:

1. Run all 3 Codex #3 verifiers against patched `Local_Repo/Assistente PMO V2`:
   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Pm0TopicActionFlowContract.ps1 `
     -SourceRoot "Local_Repo\Assistente PMO V2" `
     -ReportPath ".planning\comms\codex_pm0_remediation_20260522\CODEX2\VERIFIERS\post_alpha_topic_action_flow_contract.json"

   powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Pm0WorkflowResponseSemantics.ps1 `
     -SourceRoot "Local_Repo\Assistente PMO V2" `
     -ReportPath ".planning\comms\codex_pm0_remediation_20260522\CODEX2\VERIFIERS\post_alpha_workflow_response_semantics.json"

   powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Pm0RuntimeEvidence.ps1 `
     -EvidencePath ".planning\comms\aq09_smoke_runbook_20260520\evidence" `
     -ReportPath ".planning\comms\codex_pm0_remediation_20260522\CODEX2\VERIFIERS\post_alpha_runtime_evidence.json"
   ```

2. Expected results after Codex #1 Alpha patches:
   - `Test-Pm0TopicActionFlowContract.ps1`: exit 0 (PASS, all topic↔action↔flow contracts honored)
   - `Test-Pm0WorkflowResponseSemantics.ps1`: exit 0 (PASS, no hardcoded responses)
   - `Test-Pm0RuntimeEvidence.ps1`: still expected exit 1 until AQ-09 smoke runs (5 paths missing runtime triplet evidence — this is normal until §10)

3. If any contract or response semantics verifier FAILS post-Alpha:
   - Capture the failed JSON with verbatim error list
   - Cross-reference with `.planning/comms/codex_pm0_remediation_20260522/ALPHA/<flow>/DEFECT_FIX_REPORT.md`
   - Identify which fix is incomplete or wrong
   - Either patch yourself (small fix) or escalate to Codex Lead via `INVESTIGATION_LOG.md`
   - Re-run until PASS

4. Run all existing static gates:
   - `tests/Test-PMOFlowStopShipAudit.ps1`
   - `tests/Test-SolutionZipP0Contracts.ps1` (against new 3.16 zip)
   - `tests/Test-SolutionZipP24Contracts.ps1`
   - `tests/Test-CopilotRoutingInstructions.ps1`
   - `tests/Test-CopilotPowerFxRegexSafety.ps1`
   - Cite each PASS/FAIL with triplet evidence

Deliverables:
```
.planning/comms/codex_pm0_remediation_20260522/CODEX2/VERIFIERS/
├── post_alpha_topic_action_flow_contract.json
├── post_alpha_workflow_response_semantics.json
├── post_alpha_runtime_evidence.json
├── existing_static_gates_results.md
├── VERIFIER_REPORT.md
└── evidence/<ts>_<agent>_<step>.{png,txt,json}
```

### 6.3 BLOCKER #3 — Test data preparation + AQ-09 readiness

**Subagent 2C — Smoke Prep + Executor**

Tasks (Phase 1, before publish):

1. Read-only PnP verification of test data per `aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md` Shared Preconditions:
   ```powershell
   $siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
   Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking
   Connect-PnPOnline -Url $siteUrl -UseWebLogin

   # Verify project exists
   Get-PnPListItem -List Projetos -Id 33 -Fields ID,Title,ProjectID,Ativo,Deleted

   # Verify active task
   Get-PnPListItem -List Tarefas -Id 15 -Fields ID,Title,ProjectID,Status,Responsavel,DataFim,Prioridade,Deleted

   # Verify deleted task
   Get-PnPListItem -List Tarefas -Id 13 -Fields ID,Title,Deleted,DeletedAt,DeletedReason,DeletedByUPN
   ```

2. Capture PnP outputs to:
   ```
   CODEX2/SMOKE_PREP/preflight_data_check.json
   CODEX2/SMOKE_PREP/preflight_screenshot.png
   ```

3. If any required asset is missing or in unexpected state, document and escalate (do not seed data without owner approval).

4. Read `Status Diario` list schema to confirm fields used by the patched `AtualizarStatus` workflow exist:
   ```powershell
   Get-PnPField -List "Status Diario" | Where-Object { $_.InternalName -in @('ProjectID','RAG','Resumo','Percentual','Risco','Bloqueio','ProximaAcao','Deleted','Created','Title') } |
     Select-Object InternalName, Title, TypeAsString, Required
   ```
   If any field is missing (especially `RAG`, `ProximaAcao`, `Bloqueio`), document and escalate. Schema additions require owner-approved tenant write.

Deliverables:
```
.planning/comms/codex_pm0_remediation_20260522/CODEX2/SMOKE_PREP/
├── preflight_data_check.json
├── preflight_data_check.png
├── status_diario_schema.json
└── PHASE1_PREP_REPORT.md
```

### 6.4 BLOCKER #4 — Adaptive Card content + size budget

Confirm that all 5 Adaptive Cards (existing in `deploy/cards/` plus new ones from §4) comply with Adaptive Cards 1.5 spec and the prior 27KB ceiling per `.planning/STATE.md`.

Tasks:

1. For each card JSON, validate against Adaptive Cards 1.5 schema (cite MS Learn).
2. Measure JSON size: must be < 27KB after dynamic data binding.
3. Test render via Adaptive Cards Designer (`https://adaptivecards.io/designer/`) with sample data — capture screenshot.
4. Document any card that requires reduction.

Deliverables under `CODEX2/CARDS/`:
- Per-card validation report
- Size measurements
- Designer render screenshots

### 6.5 BLOCKER #5 — ContentFiltered / openAIIndirectAttack mitigation review

The XPIA risk that triggered M1 → M2 redesign is still present. The patched workflows must not reintroduce dynamic SP/Planner data into bot-visible responses in a way that triggers Copilot Studio Responsible AI checks.

Tasks:

1. For each workflow Response body (per §4), assess XPIA risk:
   - Does the body include user-controlled SharePoint text fields (Title, Resumo, Descricao)?
   - Are pipe characters, markdown, emojis, or non-ASCII present in the dynamic content?
   - Does the body length exceed thresholds known to trigger filtering?
2. Cite `RCA_COPILOT_STUDIO_OPENAIINDIRECTATTACK_3_15_20260514.md` and `STUDY_XPIA_MITIGATION_v3_16_20260514.md` for prior mitigations.
3. If risk identified, propose mitigations (truncate dynamic text, ASCII-only, length cap, static framing).

Deliverable: `CODEX2/XPIA_REVIEW/XPIA_RISK_ASSESSMENT.md`

---

## 7. RELEASE PIPELINE — GATES 1-9 (Codex #2 owns Gates 3 onward)

Codex #1 Lead has confirmed Gates 1 and 2 PASS at 16:33 BRT. You own from Gate 3.

| Gate | Owner | Status | Acceptance |
|---|---|---|---|
| 1 — Local fixes complete | Codex #1 Alpha | ✅ DONE 16:33 BRT | 5 DEFECT_FIX_REPORT.md, all unit tests PASS |
| 2 — Functional verifier validates patches | Codex #1 + Codex #3 verifiers | ✅ DONE 16:33 BRT | Workflow response semantics PASS, topic/action contract PASS |
| 3 — Solution package build | **You (Subagent 2A)** | 🔴 BLOCKED | New 3.16 zip with all 5 PM0 workflows as solution components, SHA256, version, automated grep zero matches |
| 4 — Owner approval for tenant write | **You write the ASK, owner replies** | 🔴 PENDING | Verbatim owner approval captured in `BRAVO/PACKAGE_AND_PUBLISH/owner_approval_evidence.md` |
| 5 — Tenant import + publish | **You execute** | 🔴 PENDING | `pac solution import` + `pac copilot publish` with full triplet |
| 6 — Drift monitor structural pass | **You run** | 🔴 PENDING | `Test-Aq08PostRemediationReverify.ps1` PASS at T+5min and T+1h |
| 7 — AQ-09 runtime smoke 12 scenarios | **You execute (Subagent 2C)** | 🔴 PENDING | Section A 5/5 PASS with all 5 acceptance criteria, Section B 7/7 evidence captured |
| 8 — Functional DoD attestation | Codex #1 Lead writes per flow | 🔴 PENDING | 5 DOD_ATTESTATION files with all 5 criteria triplet-linked |
| 9 — Owner final SHIP decision | **Owner replies in thread** | 🔴 PENDING | Verbatim SHIP/NO-SHIP/Rollback recorded |

### 7.1 Gate 4 ASK template (you write this in active thread when Gate 3 PASS)

```
Codex #2 requesting tenant write authorization to:
1. Import Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip (SHA256: <hash>) into ColOfertasBrasilPro environment.
2. Re-publish bot Assistente PMO V2.

Local Gates 1-3 PASS:
- Gate 1: 5 PM0 flows patched, Codex #1 evidence at .planning/comms/codex_pm0_remediation_20260522/ALPHA/.
- Gate 2: All 3 Codex #3 verifiers + 5 existing static gates PASS post-Alpha (evidence: CODEX2/VERIFIERS/).
- Gate 3: Package built, SHA256 captured, contains 5 PM0_PA_Card_* workflows as solution components, zero hardcoded placeholders (evidence: CODEX2/PACKAGE/).

Diff vs 3.15.1: <count> workflows changed/added, <count> actions changed, <count> topics changed, <count> cards added.

Awaiting owner OK / approved / vai to proceed with Gate 5 (tenant import + publish).
```

### 7.2 Gate 5 commands

```powershell
pac auth list
pac env who   # must show ColOfertasBrasilPro
pac env select --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56

pac solution import `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --path 'Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip' `
  --publish-changes

pac copilot publish --bot-name 'Assistente PMO V2'
# If pac copilot publish unsupported in current pac version, document and use Copilot Studio UI per MS Learn citation
```

Capture per command:
- Full terminal screenshot
- Exit code
- Run/correlation IDs
- Timestamp BRT
- Agent name

### 7.3 Gate 6 commands

```powershell
# T+5min after publish
Start-Sleep -Seconds 300
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Aq08PostRemediationReverify.ps1 `
  -EvidenceDir '.planning\comms\codex_pm0_remediation_20260522\CODEX2\POST_PUBLISH\T+5min'

# T+1h after publish
Start-Sleep -Seconds 3300   # 55 min more
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Aq08PostRemediationReverify.ps1 `
  -EvidenceDir '.planning\comms\codex_pm0_remediation_20260522\CODEX2\POST_PUBLISH\T+1h'
```

Both must return exit 0 with `overall: PASS`, `blockingTopicCount: 0`. If T+5min PASS but T+1h FAIL, capture both and escalate.

Also re-run all 3 Codex #3 verifiers in tenant mode if `Test-Pm0*.ps1` supports a `-TenantMode` parameter; otherwise re-run them against a freshly downloaded tenant solution export.

---

## 8. AQ-09 RUNTIME SMOKE — 12 SCENARIOS WITH FULL EVIDENCE TRIPLET (Gate 7)

Subagent 2C executes after Gate 6 PASS. Per `aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`.

### 8.1 Section A — In-Scope P0 Ship Gate (5 scenarios, ship-gating)

For each Section A scenario, the bot reply must satisfy ALL 5 acceptance criteria:

1. NOT contain `ContentFiltered` or `openAIIndirectAttack`
2. Contain real backend data verifiable in SharePoint
3. NOT contain hardcoded `"successfully."` or equivalent placeholder
4. Power Automate run history shows `Succeeded`
5. Adaptive Card (where applicable) posted to Teams channel `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2`

| Scenario | Topic | Chat input | Bot reply spec | SP read-back |
|---|---|---|---|---|
| **A1** | ListarTarefas | `listar tarefas QA Robust 20260513 F` | Plain-text task list with real `Tarefas` rows for `PRJ-274E5ACC` | `Get-PnPListItem -List Tarefas` filter `ProjectID eq 'PRJ-274E5ACC'` matches reply rows |
| **A2** | ConsultarPortfolio | `consultar portfolio` | Numeric counts for active projects + RAG breakdown + open tasks | Counts match SP query `Ativo eq true and Deleted eq false` |
| **A3** | CriarTarefa | `criar tarefa: projeto=QA Robust 20260513 F, titulo=QA Smoke 316 20260522, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Media` then `sim` | Confirmation with new task ID, ProjectID | New `Tarefas` row exists with `Title='QA Smoke 316 20260522'`, `ProjectID='PRJ-274E5ACC'`, `Deleted=false` |
| **A4** | AtualizarTarefa | `atualizar tarefa` then `15, em andamento, 2, nao, nao, nao, sim` | Bot preserves Responsavel, DataFim, Prioridade. No `FlowActionBadGateway`. | Task `15`: Responsavel/DataFim/Prioridade unchanged; Status=`Em Andamento`, HorasRealizadas updated |
| **A5** | AtualizarStatus | `atualizar status: projeto=QA Robust 20260513 F, status=Amarelo, resumo=Smoke 3.16 multilinha, percentual=45, risco=Nenhum, bloqueio=Nenhum, proxima acao=Revisar` then `sim` | Confirmation with parsed fields, new Status Diario item ID | New `Status Diario` row with all structured fields populated; project `StatusRAG=Amarelo` updated |

If ANY Section A scenario fails any of the 5 acceptance criteria → **NO-SHIP**.

### 8.2 Section B — Legacy out-of-scope (7 scenarios, evidence only)

Execute B0 SP-Audit, B1 ConsultarProjeto, B2 CriarProjeto, B3 ExcluirProjeto, B4 ExcluirTarefa, B5 PedirDecisao, B6 RegistrarBloqueio, B7 RegistrarRisco per AQ09_SMOKE_RUNBOOK.md. ContentFiltered allowed (legacy debt per ADR_AQ08).

### 8.3 Per-scenario evidence triplet structure

```
.planning/comms/codex_pm0_remediation_20260522/CODEX2/SMOKE/<scenario>/
├── REPORT.md                    (per-scenario findings with 5-row criteria table)
└── evidence/
    ├── <ts>_chat_input.txt
    ├── <ts>_bot_reply.txt
    ├── <ts>_chat_screenshot.png
    ├── <ts>_pa_run_history.png
    ├── <ts>_pa_run_id.txt
    ├── <ts>_sp_readback.json
    └── <ts>_sp_readback.png
```

### 8.4 SMOKE_FINAL_REPORT.md must include

- Section A 5-row table: scenario, input verbatim, bot reply verbatim, SP read-back result, all 5 acceptance criteria PASS/FAIL, triplet path
- Section B 7-row table: scenario, executed Y/N, content-filter status, evidence path
- Aggregate: total PASS, total FAIL, ship recommendation
- Re-run of Codex #3 `Test-Pm0RuntimeEvidence.ps1` against the new evidence folder — must return exit 0 (all 5 paths now have triplet evidence)

---

## 9. CONTINUOUS DOC UPDATES (mandatory, real-time)

After every gate transition, every smoke scenario, every tenant operation, every verifier run — update relevant project docs immediately.

Documents to keep in continuous sync:

- `.planning/STATE.md`
- `.planning/CURRENT_BASELINE.md`
- `.planning/AGENT_CHECKIN_REGISTRY.md`
- `.planning/START_HERE_CURRENT_STATUS.md`
- `.planning/stop_ship/MASTER_CHECKLIST.md`
- `.planning/stop_ship/RISK_REGISTER.md`
- `.planning/milestones/M2_card_first_revision_v2/STATE.md`
- `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_EXECUTIVE_20260522.md`
- `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_TASKS_PLANNER.csv`
- `.planning/comms/STATUS_REPORT_20260522/UNBLOCK_PATH_VISUAL.md`
- `.planning/comms/STATUS_REPORT_20260522/IMMEDIATE_ACTION.md`
- `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md`
- `.planning/comms/codex_pm0_remediation_20260522/DOC_UPDATES_LOG.md`
- `.planning/comms/codex_pm0_remediation_20260522/EVIDENCE_LOG.md`

Header on every edit:
```
Last updated: <YYYY-MM-DD HH:mm:ss BRT> | Codex #2 | <one-line reason>
```

---

## 10. METRICS AND ACCEPTANCE CRITERIA (full Codex #2 portion)

Mission accepted only when ALL true:

| Metric | Target | Verification |
|---|---|---|
| All 5 Codex Lead Alpha defects validated post-fix | 5/5 verifier PASS | `Test-Pm0TopicActionFlowContract.ps1` exit 0 + `Test-Pm0WorkflowResponseSemantics.ps1` exit 0 |
| All static gates PASS post-Alpha | 5/5 | Existing test outputs |
| AtualizarStatus full backend implemented (from-scratch) | Yes | `ALPHA/AtualizarStatus/DEFECT_FIX_REPORT.md` + `Test-Pm0WorkflowResponseSemantics.ps1` PASS |
| Solution 3.16 zip built | 1 zip | `CODEX2/PACKAGE/package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` |
| Zip contains 5 PM0_PA_Card_* workflows as solution components | 5 workflows | `package_inventory.md` |
| Zip diff vs 3.15.1 documented | Yes | `diff_3_16_vs_3_15_1.md` |
| Hardcoded placeholder regex match in zip | 0 | Build log + automated grep |
| Owner Gate 4 approval captured verbatim | 1 | `owner_approval_evidence.md` |
| Tenant import success | 1 | `pac` output + screenshot |
| Tenant publish success | 1 | Copilot Studio panel screenshot |
| Drift T+5min and T+1h | PASS | Both reports `overall: PASS`, `blockingTopicCount: 0` |
| AQ-09 Section A scenarios | 5/5 PASS, all 5 acceptance criteria each | Per-scenario REPORT.md + triplet |
| ContentFiltered in Section A | 0 | Per-scenario evidence |
| Real backend data in Section A bot replies | 5/5 verifiable in SP | sp_readback evidence |
| AQ-09 Section B scenarios | 7/7 executed, evidence captured | Per-scenario REPORT.md |
| `Test-Pm0RuntimeEvidence.ps1` post-smoke | exit 0 (PASS) | Verifier output |
| 5 DOD_ATTESTATION files signed (Codex Lead writes) | 5/5 | `DOD_ATTESTATIONS/` |
| Project docs continuously updated | All within 10min of last action | `Last updated:` headers |
| EVIDENCE_LOG.md entries | One per gate transition + per scenario + per build step | Master index |

---

## 11. FORBIDDEN

| Action | Why |
|---|---|
| Tenant write before Gate 4 owner approval captured verbatim | Owner authorization gate |
| Marking ANY step DONE without all 3 Evidence Triplet elements | Golden Rule §0.2 |
| Marking ANY flow DONE without all 5 Functional DoD conditions | Golden Rule §0.3 |
| Citing memory or third-party for Microsoft behavior | MS Learn only |
| Inventing MS Learn URLs | Must be real, accessed, timestamped |
| Skipping any of 12 smoke scenarios | Acceptance failure |
| Treating Section A ContentFiltered as ship-able | Section A is ship-gating |
| Skipping Adaptive Card validation | Card render in Teams may fail silently |
| Skipping XPIA risk assessment | Reintroducing M1 → M2 trigger |
| Editing tenant from Kiro instance | Kiro is read-only, only Codex writes tenant |
| Building package without verifying 5 PM0 workflows are solution members | Empty zip would re-import without flows |
| Treating Codex Lead Gate 1/2 PASS as Gate 3+ blanket SHIP confidence | Each gate independent |

---

## 12. FINAL DELIVERY (your message in active thread when mission complete)

1. Confirmation of new Golden Rules (§0) absorbed and applied
2. Confirmation Codex Lead Alpha state read and verified at start (16:33 BRT PASS)
3. Per-flow validation summary: each of 5 flows post-Alpha verifier results
4. Path to package zip + SHA256 + version + diff vs 3.15.1
5. Solution membership preflight result (5 workflows confirmed as solution components)
6. Owner approval Gate 4 verbatim quote path
7. Tenant import + publish triplet evidence (terminal output, run IDs, screenshots, timestamps)
8. AQ-08 structural verifier post-publish T+5min + T+1h results
9. AQ-09 Section A 5-row table (input, bot reply verbatim, SP read-back, 5 acceptance criteria each, triplet path)
10. AQ-09 Section B 7-row table
11. `Test-Pm0RuntimeEvidence.ps1` post-smoke result (must be exit 0)
12. List of every project doc updated with timestamp BRT and reason
13. Confirmation no tenant write performed without explicit thread approval
14. Metrics table populated against §10 acceptance criteria
15. Recommendation to Owner: SHIP / NO-SHIP / Rollback for Gate 9 with grounded justification

---

## 13. WHAT MUST NOT HAPPEN AGAIN

The defect that triggered this mission was a hardcoded `"result": "Tasks retrieved successfully."` placeholder in production-candidate flows that 5 prior agents marked DONE because structural verification passed and no one ran a real call.

Your AQ-09 smoke is the runtime evidence that proves the fix actually works. Your package build with solution-component verification ensures the flows actually deploy. Your post-publish verifiers confirm tenant state matches local intent.

If any Section A scenario delivers a hardcoded `"successfully."` reply, or if real backend data is not verifiable in SharePoint after a write, or if the package zip lacks the 5 workflow components, the mission is NOT complete.

---

## END OF SPECIFICATION — Codex #2, attack all blockers in §6 in parallel now


