# CODEX #1 (LEAD) — PM0 CARD-FIRST FIX-AND-SHIP — R&D-GRADE REMEDIATION SPECIFICATION

| Field | Value |
|---|---|
| Mission ID | `PM0-REMED-20260522-LEAD` |
| Severity | `SEV-0` |
| Date issued | `2026-05-22 16:05 BRT` |
| Owner | Manoel Benicio (sole approver) |
| Owner decision recorded | FIX-AND-SHIP, all 5 flows in 1 release, broken state stays in tenant during fix, Functional DoD with mandatory Evidence Triplet, Codex authorized for tenant writes |
| Source of truth | `learn.microsoft.com` only — all Microsoft product behavior must be cited from official Learn docs with full URL and accessed timestamp BRT |
| Tenant write authorization | Granted to Codex (#1 and #2). Each individual write requires explicit owner approval verbatim in the active thread before execution |
| Kiro role | Read-only. Kiro does not edit tenant. |
| Continuation | This mission continues from your prior audit completed `2026-05-22 15:41 BRT`. RCA, REMEDIATION_PLAN, MITIGATION_PLAN, EXECUTIVE_SUMMARY exist at `.planning/comms/codex_pm0_audit_20260522/`. You implement REMEDIATION_PLAN now. |
| Execution model | Team Alpha (you) + Team Bravo (Codex #2) in parallel. Both teams start at minute zero. Sync via `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` (append-only, 10-minute cadence) |
| Out-of-scope | 7 legacy `PMO_PA_*` topics (`ConsultarProjeto`, `CriarProjeto`, `ExcluirProjeto`, `ExcluirTarefa`, `PedirDecisao`, `RegistrarBloqueio`, `RegistrarRisco`) remain on legacy per ADR_AQ08 |

---

## 0. NEW MANDATORY GOLDEN RULES (read updated `.planning/GOLDEN_RULES.md` first)

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
| **Agent name** | Named agent (`Codex Lead`, `Codex sub-A1`, `Codex sub-A2`, `Codex sub-A3`, etc.). No anonymous evidence. |

Storage path:
```
.planning/comms/codex_pm0_remediation_20260522/<workstream>/evidence/<YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}
```
Index: `EVIDENCE_LOG.md` per workstream. One row per evidence file.

If any of the three elements is missing, the entry is `INCOMPLETE`. Cannot be cited as DONE/PASS/PUBLISH. Re-execute with full triplet capture.

Owner literal directive (preserved): *"todos testes e deploy somente são considerados entregues se tiver timestamp do agente, nome e evidência com printscreen"*.

### 0.3 Functional Definition of Done Rule (MANDATORY)
A flow is DONE only when:

1. Real runtime call returns real backend data (not hardcoded placeholder string in Response action body).
2. Runtime call evidence captured per Evidence Triplet (screenshot of `pac flow run` or Power Automate run history or Copilot Studio test panel + timestamp BRT + agent name).
3. Bot end-to-end test (Copilot Studio test panel or Teams chat) reproduces the same successful outcome and the bot-rendered response contains the real backend data.
4. Action component `.mcs.yml` declares `inputs:` matching the workflow trigger schema.
5. Topic `.mcs.yml` `BeginDialog input:` Power Fx mapping passes all required workflow trigger fields.
6. No agent writes DONE/PASS/PUBLISH_GO until conditions 1-5 above are evidenced.

Verifiers (Codex #2 will build `Test-Pm0FunctionalContract.ps1`) must include functional checks, not only structural component-name and binding-name matching. A verifier returning PASS without evidencing conditions 1-5 is itself a defect.

---

## 1. CONTEXT (continuity from your audit)

You are Codex Lead. You produced these artifacts at audit time. Re-read them before remediation:

| Artifact | Path |
|---|---|
| RCA | `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md` |
| Remediation Plan | `.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md` |
| Mitigation Plan | `.planning/comms/codex_pm0_audit_20260522/MITIGATION_PLAN.md` |
| Executive Summary | `.planning/comms/codex_pm0_audit_20260522/EXECUTIVE_SUMMARY.md` |
| Alpha A1 (workflow body audit) | `.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/AUDIT_TABLE.md` |
| Alpha A2 (action contract audit) | `.planning/comms/codex_pm0_audit_20260522/ALPHA/A2_actions/AUDIT_TABLE.md` |
| Alpha A3 (topic contract audit) | `.planning/comms/codex_pm0_audit_20260522/ALPHA/A3_topics/AUDIT_TABLE.md` |
| Bravo B2 (MS Learn citation index) | `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md` |
| Bravo B3 (process failure analysis) | `.planning/comms/codex_pm0_audit_20260522/BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md` |

Plus the 20 mandatory project docs you already read at audit time.

---

## 2. TARGET STATE — DEFINITION (specification)

After this remediation completes and ships as 3.16, the following must be objectively true and triplet-evidenced:

### 2.1 Topic-Action-Workflow contracts

| Layer | Specification |
|---|---|
| **Workflow JSON** (`Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_*-<id>/workflow.json`) | Response action body contains dynamic Power Automate expressions referencing at least one of: `@body('Get_*')`, `@body('List_*')`, `@outputs('*')`, `@triggerBody()`, `@variables('*')`. Must NOT match regex `"result":\s*"[^@{][^"]*successfully\."`. Adaptive Card post action (where applicable) uses `body/messageBody` with dynamic content from SP/Planner outputs, not static text. |
| **Action `.mcs.yml`** (`Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_*.mcs.yml`) | Declares `inputs:` block with one entry per `triggers.manual.inputs.schema.required[]` field from the bound workflow. Each input declares `propertyName`, `displayName` (optional), and `description` (optional). Field types match (string, number, boolean) per Microsoft Learn `kind: TaskDialog` schema. |
| **Topic `.mcs.yml`** (`Local_Repo/Assistente PMO V2/topics/<topic>.mcs.yml`) | `BeginDialog input:` block contains explicit Power Fx mapping for every required workflow trigger field. No `input: {}` empty unless the action declares no inputs. ProjectID resolution: where the topic captures a project name (e.g., `ListarTarefas`), an upstream `Get items` SharePoint lookup must convert name → ProjectID before calling the action. |

### 2.2 Per-flow target schema

Below are the binding contracts for each of the 5 flows. The action `inputs:` and topic `input:` mappings must match these schemas exactly. Field names mirror current workflow trigger schemas captured in `.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/`.

#### 2.2.1 PM0_PA_Card_AtualizarStatus
**Workflow trigger required[]:** `["routeKey"]` (current schema). The workflow only posts a static Teams card.
**Remediation requirement:** Expand workflow trigger schema to accept structured PMO status fields, post Adaptive Card with dynamic content, write to SharePoint `Status Diario` list. New trigger schema:
```json
{
  "type": "object",
  "properties": {
    "routeKey":  {"type":"string","description":"Route key"},
    "projectId": {"type":"string","description":"PMO ProjectID (PRJ-XXXXXXXX)"},
    "rag":       {"type":"string","description":"Status RAG: Verde, Amarelo, Vermelho"},
    "resumo":    {"type":"string","description":"Status summary"},
    "percentual":{"type":"number","description":"Completion percent"},
    "risco":     {"type":"string","description":"Risk note"},
    "bloqueio":  {"type":"string","description":"Blocker note"},
    "proximaAcao":{"type":"string","description":"Next action"}
  },
  "required": ["routeKey","projectId","rag","resumo"]
}
```
**Workflow body:** `Get_Project` (SP `Projetos` filter `ProjectID eq @{triggerBody()?['projectId']}`) → `Create_StatusDiario` (SP `Status Diario` PostItem with `RAG`, `Resumo`, `Percentual`, `Risco`, `Bloqueio`, `ProximaAcao`, `Created` from `@utcNow()`) → `Update_Project_RAG` (SP `Projetos` PatchItem with `StatusRAG` from `@triggerBody()?['rag']`, `UltimaAtualizacao` from `@utcNow()`) → `Post_Status_Card` (Teams `PostCardToConversation` with dynamic Adaptive Card showing the new status row and project context) → `Respond_Success`:
```json
{ "result": "@{concat('Status registrado para ', body('Get_Project')?['Title'], ' (RAG=', triggerBody()?['rag'], ', ', triggerBody()?['percentual'], '%). Item ', body('Create_StatusDiario')?['ID'], '.')}" }
```

#### 2.2.2 PM0_PA_Card_AtualizarTarefa
**Workflow trigger:** already accepts task fields (`spItemId`, `taskId`, `status`, `taskStatus`, `comments`). Has Get/Compose/Update Planner/Update SP chain. Defects: action declares no inputs; topic passes `input: {}`; Response body hardcoded.
**Remediation:** Expand schema to add `horasRealizadas`, `responsavel`, `dataFim`, `prioridade`. Action declares all inputs. Topic maps `Topic.TaskID`, `Topic.Status`, `Topic.HorasRealizadas`, `Topic.Responsavel`, `Topic.DataFim`, `Topic.Prioridade` to `taskId`, `status`, `horasRealizadas`, `responsavel`, `dataFim`, `prioridade`. Update SharePoint Patch must include all updated fields. Add Adaptive Card post showing updated task. Response body:
```json
{ "result": "@{concat('Tarefa ', triggerBody()?['taskId'], ' atualizada para ', triggerBody()?['status'], '. Responsavel: ', if(empty(triggerBody()?['responsavel']),'mantido',triggerBody()?['responsavel']), '. Prazo: ', if(empty(triggerBody()?['dataFim']),'mantido',triggerBody()?['dataFim']), '. Item SP: ', body('Update_SharePoint_Item')?['ID'], '.')}" }
```

#### 2.2.3 PM0_PA_Card_CriarTarefa
**Workflow trigger:** already comprehensive (`projectId`, `taskTitle`, `bucket`, `dueDate`, etc.). Has Compose/Create Planner/Create SP chain. Defects: same pattern (action no inputs; topic empty; hardcoded result).
**Remediation:** Action declares all inputs (`projectId`, `action`, `title`, `responsavel`, `prazo`, `horas`, `prioridade`, `bucket`). Topic maps `Topic.NomeProjeto` → resolved `ProjectID` (via upstream Get items lookup), `Topic.Titulo`, `Topic.Responsavel`, `Topic.Prazo`, `Topic.Horas`, `Topic.Prioridade`. Add Adaptive Card post. Response body:
```json
{ "result": "@{concat('Tarefa criada: ', triggerBody()?['title'], ' (Projeto ', triggerBody()?['projectId'], ', Item SP ', body('Create_SharePoint_Item')?['ID'], ', Planner ', body('Create_Planner_Task')?['id'], ', Bucket ', outputs('Determine_Bucket_and_Status')?['status'], ').')}" }
```

#### 2.2.4 PM0_PA_Card_ListarTarefas
**Workflow trigger required[]:** `["action","projectId"]`. Has Get_Tarefas (SP filter by `ProjectID`), List_Planner_Tasks, Normalize_Tasks (Select). Defects: action no inputs; topic empty; Response body hardcoded; Normalize_Tasks output is dropped.
**Remediation:** Action declares `projectId` and `action`. Topic adds upstream `Get_Project_By_Name` SP lookup (filter `Title eq @{Topic.NomeProjeto}` or `NomeProjeto eq @{Topic.NomeProjeto}`) returning ProjectID, then maps `Topic.ResolvedProjectID` → `projectId`, constant `"list"` → `action`. Response body must serialize the normalized task list:
```json
{
  "result": "@{if(equals(length(body('Normalize_Tasks')),0), concat('Nenhuma tarefa ativa para o projeto ', triggerBody()?['projectId'], '.'), concat('Tarefas do projeto ', triggerBody()?['projectId'], ' (', length(body('Normalize_Tasks')), ' itens): ', join(body('Normalize_Tasks_Display'),' | ')))}"
}
```
Where `Normalize_Tasks_Display` is a new Select action mapping `@concat(item()?['title'], ' [', item()?['status'], ']')`. Add `Post_Tasks_Card` (Adaptive Card with dynamic FactSet of tasks).

#### 2.2.5 PM0_PA_Card_ResumoExecutivoPortfolio
**Workflow trigger required[]:** `[]` (no inputs). Has Get_Projetos, Get_Tarefas. Defects: hardcoded result; aggregation logic missing; no card post.
**Remediation:** Action declares no inputs (matches workflow). Topic passes `input: {}` (correct for this case). Workflow adds:
- `Filter_Active_Projects` (Filter array on `Get_Projetos`: `Ativo eq true and Deleted eq false`)
- `Group_By_RAG` (Select + Compose to count Verde/Amarelo/Vermelho)
- `Count_Active_Tasks` (Filter array on `Get_Tarefas`: `Deleted eq false and Status ne 'Concluida'`)
- `Post_Portfolio_Card` (Adaptive Card with FactSet showing totals)
- `Respond_Success` body:
```json
{ "result": "@{concat('Portfolio: ', length(body('Filter_Active_Projects')), ' projetos ativos (Verde=', outputs('Group_By_RAG')?['verde'], ', Amarelo=', outputs('Group_By_RAG')?['amarelo'], ', Vermelho=', outputs('Group_By_RAG')?['vermelho'], '). Tarefas em aberto: ', length(body('Filter_Active_Tasks')), '.')}" }
```

### 2.3 Action `.mcs.yml` shape (target template)

For each action, the `.mcs.yml` must follow this structure (verified against MS Learn `kind: TaskDialog`):

```yaml
mcs.metadata:
  componentName: PM0_PA_Card_<Name>
  description: <one-line semantic description>
kind: TaskDialog
inputs:
  - propertyName: <field1>
    displayName: <Field 1>
    description: <doc>
  - propertyName: <field2>
    displayName: <Field 2>
    description: <doc>
outputs:
  - propertyName: result
action:
  kind: InvokeFlowTaskAction
  flowId: <workflow-guid>
  connectionProperties:
    $kind: ConnectionProperties
    diagnostics:
    mode: Invoker
outputMode: All
```

### 2.4 Topic `.mcs.yml` `BeginDialog` block (target template)

```yaml
- kind: BeginDialog
  id: call_<flow_alias>
  input:
    field1: =Topic.<Variable1>
    field2: =Topic.<Variable2>
    # one entry per declared action input
  dialog: pmo_AssistentePMO_V2.action.PM0_PA_Card_<Name>
  output:
    binding:
      result: Topic.<ResultVariable>
```

---

## 3. EXECUTION PLAN — TEAM ALPHA (you)

### 3.1 Subagent Allocation

| Subagent | Scope | Estimated effort |
|---|---|---|
| **A1 — Workflow Body Fixer** | Patch all 5 workflow.json files: trigger schema expansion, dynamic Response body, Adaptive Card post integration, MS Learn `kind: Skills` Response shape compliance | 4-6h |
| **A2 — Action Contract Fixer** | Add `inputs:` block to all 5 `PM0_PA_Card_*.mcs.yml` files matching expanded workflow trigger schemas | 1-2h |
| **A3 — Topic Contract Fixer** | Replace `input: {}` with explicit Power Fx mapping in all 5 topic files. Add upstream ProjectID resolution lookups for `ListarTarefas` and `CriarTarefa` | 2-3h |

All three subagents work in parallel. Cross-dependency: A2 and A3 depend on A1's final trigger schema; A1 publishes the schemas to a shared file `ALPHA/SHARED/workflow_trigger_schemas.json` after first pass, enabling A2/A3 to start with the correct contract.

### 3.2 Per-flow deliverables (Codex Lead owns end-to-end fix)

For each of the 5 flows, produce under `.planning/comms/codex_pm0_remediation_20260522/ALPHA/<flow>/`:

```
<flow>/
├── DEFECT_FIX_REPORT.md         (per defect: ID, fix description, MS Learn cite, before/after)
├── workflow_patch.diff           (unified diff of workflow.json)
├── action_patch.diff             (unified diff of action.mcs.yml)
├── topic_patch.diff              (unified diff of topic.mcs.yml)
├── unit_test/
│   ├── test_workflow_response.ps1     (asserts Response body references SP/Planner outputs)
│   ├── test_action_inputs.ps1          (asserts action declares all required inputs)
│   ├── test_topic_input_mapping.ps1   (asserts topic maps all action inputs)
│   ├── test_no_placeholder.ps1         (greps workflow JSON for "successfully.", "placeholder", "todo", "tbd")
│   └── results/<test>_<YYYYMMDD_HHmmss>.{json,txt}
└── evidence/
    └── <YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}
```

### 3.3 DEFECT_FIX_REPORT template

For each defect from `REMEDIATION_PLAN.md`:

```markdown
## DEFECT-<ID>

**Severity:** SEV-0 / HIGH / MEDIUM
**File:** <path>
**Line(s):** <L1-L2>

### Before (current state)
```<lang>
<verbatim broken code>
```

### After (patched state)
```<lang>
<verbatim fixed code>
```

### Why this fixes the defect
<2-3 sentences citing the workflow/action/topic contract from §2 and the relevant MS Learn URL>

### MS Learn citation
<URL> | accessed <YYYY-MM-DD HH:mm:ss BRT> | excerpt: "<quoted relevant section>"

### Unit test
<path to test PS1> | run command | expected exit code | actual exit code

### Evidence triplet
- Screenshot: <path>
- Timestamp: <YYYY-MM-DD HH:mm:ss BRT>
- Agent: <Codex sub-A1 / A2 / A3>
```

---

## 4. RELEASE PIPELINE — 9 GATES, NO SKIPS

Each gate must pass with full Evidence Triplet before advancing. Document every gate transition in `INVESTIGATION_LOG.md` with timestamp.

### Gate 1 — Local fixes complete (Alpha owns)
- All 5 `<flow>/DEFECT_FIX_REPORT.md` written
- Every defect from REMEDIATION_PLAN closed
- All 4 unit tests per flow PASS
- Triplet evidence per PASS
- Acceptance: 5 × (1 fix report + 4 unit tests passing) = 25 triplet entries

### Gate 2 — Functional verifier validates patches (Bravo B2 builds, Alpha runs)
- Codex #2 delivers `tests/Test-Pm0FunctionalContract.ps1`
- Run against patched Local_Repo
- All 5 flows must PASS the verifier
- Triplet evidence per PASS
- Acceptance: verifier output JSON shows `overall: PASS`, all 5 flows status `PASS`, zero `INCOMPLETE`

### Gate 3 — Solution package build (Bravo B3 builds, Alpha reviews)
- Codex #2 builds `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip`
- Local static gates pass: P0/P24 contracts, stop-ship audit, content-safe, routing
- Automated grep MUST return zero matches for `"result":\s*"[^@{][^"]*successfully\."` in any PM0 workflow JSON inside the zip
- SHA256 documented
- Triplet evidence
- Acceptance: zip exists, all gates PASS, SHA256 captured, version `3.16.0.0`

### Gate 4 — Owner approval for tenant write (Codex Lead asks, Owner replies)
- Codex Lead writes single explicit ASK in active thread:
  > "Codex requesting tenant write authorization to import `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip` (SHA256: <hash>) into `ColOfertasBrasilPro` and republish `Assistente PMO V2`. Local Gates 1-3 PASS. Awaiting owner OK."
- Wait for explicit owner approval text in thread (must contain `approved` / `OK` / `vai` / equivalent semantics; literal Portuguese acceptance words count)
- Capture verbatim quote of owner approval to `evidence/<ts>_owner_approval_gate4.md`
- Acceptance: owner approval present and captured

### Gate 5 — Tenant import + publish (Codex #2 sub-B3 executes, Alpha verifies)
- `pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path 'Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip' --publish-changes`
- `pac copilot publish` for `Assistente PMO V2` (or equivalent per MS Learn)
- Capture: full terminal screenshot, command output verbatim, run IDs, timestamp BRT, agent name
- Screenshot of Copilot Studio "Published" status panel post-publish
- Acceptance: import returns success, copilot publish returns success, both triplet-evidenced

### Gate 6 — Drift monitor structural pass (Bravo runs, Alpha verifies)
- Run `tests/Test-Aq08PostRemediationReverify.ps1` post-publish at T+5min and T+1h
- Must remain PASS (no routing regression)
- Acceptance: both reports show `overall: PASS`, `blockingTopicCount: 0`, triplet-evidenced

### Gate 7 — AQ-09 runtime smoke 12 scenarios (Bravo B1 executes, Alpha audits)
- 5 Section A + 7 Section B per `aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`
- Per scenario: chat input → bot reply → SP read-back verification
- Triplet per scenario
- Section A acceptance: 5/5 PASS, zero `ContentFiltered`/`openAIIndirectAttack`, real backend data verifiable in bot reply
- Section B: all 7 executed, evidence captured (legacy debt accepted by ADR_AQ08, not ship-blocking)
- Acceptance: Section A 5-row table all PASS with triplet, Section B 7-row table executed

### Gate 8 — Functional DoD attestation (Codex Lead writes per flow)
- Per flow, write `.planning/comms/codex_pm0_remediation_20260522/DOD_ATTESTATIONS/<flow>_DOD.md` with:
  - Each of the 5 functional DoD criteria from §0.3
  - Each criterion linked to specific triplet evidence file
  - Codex Lead signature (timestamp + agent name)
- Acceptance: 5 DOD_ATTESTATION files signed and complete

### Gate 9 — Owner final SHIP decision
- Codex Lead writes `SHIP_REVIEW_3_16.md` consolidating Gates 1-8 evidence
- Owner reviews and writes SHIP / NO-SHIP / Rollback decision in thread
- Codex does not auto-advance
- Acceptance: owner decision recorded verbatim in `SHIP_REVIEW_3_16.md`

---

## 5. EVIDENCE FOLDER STRUCTURE

```
.planning/comms/codex_pm0_remediation_20260522/
├── INVESTIGATION_LOG.md             (append-only, both teams, 10-min cadence)
├── DOC_UPDATES_LOG.md               (every project doc edit with diff link)
├── EVIDENCE_LOG.md                  (master index of all triplet files)
├── ALPHA/                           (Codex #1 owns)
│   ├── SHARED/
│   │   └── workflow_trigger_schemas.json   (A1 publishes early for A2/A3)
│   ├── AtualizarStatus/{DEFECT_FIX_REPORT.md, *_patch.diff, unit_test/, evidence/}
│   ├── AtualizarTarefa/...
│   ├── ConsultarPortfolio/...
│   ├── CriarTarefa/...
│   └── ListarTarefas/...
├── BRAVO/                           (Codex #2 owns — read for sync)
│   ├── SMOKE/
│   ├── VERIFIER/
│   └── PACKAGE_AND_PUBLISH/
├── DOD_ATTESTATIONS/
│   ├── AtualizarStatus_DOD.md
│   ├── AtualizarTarefa_DOD.md
│   ├── ConsultarPortfolio_DOD.md
│   ├── CriarTarefa_DOD.md
│   └── ListarTarefas_DOD.md
└── ship_review/
    └── SHIP_REVIEW_3_16.md          (Codex Lead consolidates)
```

---

## 6. CONTINUOUS DOC UPDATES

After each gate transition or significant action, update:

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

Header on every edit:
```
Last updated: <YYYY-MM-DD HH:mm:ss BRT> | Codex #1 | <one-line reason>
```

Every edit logged in `DOC_UPDATES_LOG.md` with diff link or hash.

---

## 7. METRICS AND ACCEPTANCE CRITERIA

Mission accepted only when ALL true:

| Metric | Target | Verification |
|---|---|---|
| Defects from REMEDIATION_PLAN closed | 8/8 (4 SEV-0 + 3 HIGH + 1 MEDIUM) | Per-flow DEFECT_FIX_REPORT files |
| Functional verifier PASS | 5/5 flows | Verifier JSON output |
| Local static gates | All PASS | Existing test suite outputs |
| Hardcoded placeholder regex match | 0 in 3.16 zip | Automated grep result |
| Tenant import success | 1 | `pac` output |
| Tenant publish success | 1 | Copilot Studio panel screenshot |
| AQ-08 structural verifier post-publish | PASS | T+5min + T+1h |
| AQ-09 Section A scenarios PASS | 5/5 | Per-scenario triplet |
| ContentFiltered in Section A | 0 | Per-scenario triplet |
| Real backend data in Section A bot replies | 5/5 | Per-scenario triplet + SP read-back |
| Section B scenarios executed | 7/7 | Per-scenario triplet |
| DOD_ATTESTATION files signed | 5/5 | Files exist with all 5 criteria triplet-linked |
| Owner SHIP/NO-SHIP decision recorded | 1 | Verbatim quote in SHIP_REVIEW |
| Project docs continuously updated | All within 10min of last action | `Last updated:` headers |
| EVIDENCE_LOG.md entries | One per gate transition + per scenario + per defect fix | Master index complete |

---

## 8. FORBIDDEN

| Action | Why |
|---|---|
| Tenant write without explicit owner approval per Gate 4 | Tenant safety policy (`AGENT_ACCESS_PROTOCOL_P0_20260514.md`) |
| Marking ANY step DONE without all 3 elements of Evidence Triplet | Golden Rule §0.2 (mandatory) |
| Marking ANY flow DONE without all 5 Functional DoD conditions | Golden Rule §0.3 (mandatory) |
| Citing memory or third-party for Microsoft behavior | Golden Rule §Official MS Docs |
| Auto-advancing past Gate 9 without owner SHIP decision | Owner gate |
| Inventing MS Learn URLs | Golden Rule (must be real, accessed, timestamped) |
| Workflow Response containing hardcoded `"successfully\."` or equivalent placeholder | Gate 3 automated grep blocks |
| Skipping unit tests | Acceptance criteria failure |
| Batching doc updates | Continuous Documentation Update Rule violation |
| Editing tenant from Kiro instance | Kiro is read-only, only Codex writes tenant |

---

## 9. SYNC WITH CODEX #2

- Both teams start at minute zero
- B2 (functional verifier) can be built immediately using current Local_Repo trigger schemas (output schemas published to `ALPHA/SHARED/workflow_trigger_schemas.json` once A1 commits final shapes)
- B3 (package build) waits for Alpha to commit fix patches
- B1 Phase 2 (smoke) waits for Gate 5 (publish) complete
- Both teams append progress to `INVESTIGATION_LOG.md` every 10 minutes
- When all Bravo deliverables done, Codex #2 marks `[BRAVO COMPLETE]`. Codex #1 marks `[ALPHA COMPLETE]` after fix patches committed and Gate 1 PASS
- Final merge into RCA, REMEDIATION report addendum, SHIP_REVIEW done by Codex Lead

---

## 10. FINAL DELIVERY (your message in active thread when mission complete)

1. Confirmation of new Golden Rule (§0) absorbed and applied
2. Per-flow fix summary table (5 rows: flow, defects closed, MS Learn cites used, triplet count)
3. Pipeline gate status table (Gate 1-9, PASS/FAIL/SKIPPED, evidence path, timestamp)
4. AQ-09 Section A 5-row table (input, bot reply verbatim, SP verification result, triplet path)
5. AQ-09 Section B 7-row table (executed status, evidence path)
6. Path to `SHIP_REVIEW_3_16.md`
7. Path to all 5 `DOD_ATTESTATION` files
8. Path to functional verifier source + self-test outputs (Codex #2 deliverable, you reference)
9. List of every project doc updated with timestamp BRT and reason
10. Owner approvals recorded (Gate 4 write authorization + Gate 9 SHIP decision)
11. Confirmation no tenant write was performed without explicit thread approval
12. Time stamps: Alpha dispatch / completion / merge with Bravo
13. Metrics table populated against §7 acceptance criteria
14. Any escalation request if 8 agents proved insufficient (concrete blockers)

---

## 11. WHAT MUST NOT HAPPEN AGAIN

The defect that triggered this mission was a hardcoded `"result": "Tasks retrieved successfully."` placeholder in production-candidate flows. Five prior agents marked work DONE because structural verification passed and no one ran a real call. Evidence Triplet Rule (§0.2) and Functional DoD Rule (§0.3) exist now to prevent this.

Your remediation must enforce both rules end-to-end across all 9 gates. If your final delivery cannot map every PASS to a triplet evidence file and every flow to 5 satisfied DoD criteria, the mission is NOT complete.

---

## END OF SPECIFICATION — Codex #1 Lead, begin Team Alpha now
