# CODEX #2 — PM0 CARD-FIRST FIX-AND-SHIP — R&D-GRADE BRAVO SPECIFICATION

| Field | Value |
|---|---|
| Mission ID | `PM0-REMED-20260522-BRAVO` |
| Severity | `SEV-0` |
| Date issued | `2026-05-22 16:08 BRT` |
| Owner | Manoel Benicio (sole approver) |
| Owner decision recorded | FIX-AND-SHIP, all 5 flows in 1 release, broken state stays in tenant during fix, Functional DoD with mandatory Evidence Triplet, Codex authorized for tenant writes |
| Source of truth | `learn.microsoft.com` only — all Microsoft product behavior must be cited from official Learn docs with full URL and accessed timestamp BRT |
| Tenant write authorization | Granted to Codex (#1 and #2). Each individual write requires explicit owner approval verbatim in the active thread before execution |
| Kiro role | Read-only. Kiro does not edit tenant. |
| Continuation | Continues from your prior B1/B2/B3 audit at `.planning/comms/codex_pm0_audit_20260522/BRAVO/`. Codex Lead is your peer (Team Alpha). |
| Execution model | Team Alpha (Codex Lead) + Team Bravo (you) in parallel. Both teams start at minute zero. Sync via `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` (append-only, 10-minute cadence) |
| Out-of-scope | 7 legacy `PMO_PA_*` topics remain on legacy per ADR_AQ08 |

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
| **Agent name** | Named agent (`Codex #2`, `Codex sub-B1`, `Codex sub-B2`, `Codex sub-B3`). No anonymous evidence. |

Storage path:
```
.planning/comms/codex_pm0_remediation_20260522/BRAVO/<workstream>/evidence/<YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}
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

## 1. CONTEXT (continuity from your audit)

You are Codex #2. Re-read your prior Bravo outputs and the Codex Lead's audit artifacts before remediation:

| Artifact | Path |
|---|---|
| Your B1 (tenant drift) | `.planning/comms/codex_pm0_audit_20260522/BRAVO/B1_tenant_drift/` |
| Your B2 (MS Learn citations) | `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md` |
| Your B3 (process failure) | `.planning/comms/codex_pm0_audit_20260522/BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md` |
| Codex Lead RCA | `.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md` |
| Codex Lead REMEDIATION_PLAN | `.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md` |
| Codex Lead Alpha A1 audit | `.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/AUDIT_TABLE.md` |
| Codex #1 Lead R&D prompt (your peer mission spec) | `.planning/comms/codex_pm0_remediation_20260522/PROMPT_CODEX_1_LEAD_R&D.md` |
| Updated Golden Rules | `.planning/GOLDEN_RULES.md` (sections updated 15:58 BRT) |

The 5 in-scope flows:

| Topic | Action | Workflow ID |
|---|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| `ConsultarPortfolio` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |

---

## 2. SUBAGENT B2 — FUNCTIONAL VERIFIER SPECIFICATION

You build `tests/Test-Pm0FunctionalContract.ps1`. This is the technical guardrail that prevents the next stub-passing-as-DONE incident.

### 2.1 Verifier inputs

| Input | Description |
|---|---|
| `-LocalRepoRoot <path>` | Path to `Local_Repo/Assistente PMO V2/` (or live tenant unpacked solution) |
| `-EvidenceDir <path>` | Directory to write per-flow JSON results and consolidated report |
| `-Mode <Local\|Tenant>` | `Local` reads files; `Tenant` runs `pac org fetch` for live workflow clientdata |
| `-EnvironmentId <guid>` | Required when `-Mode Tenant` |

### 2.2 Verifier checks per flow

For each of the 5 PM0 flows, run all checks below. Per-flow result is `PASS` only when every check `PASS`.

#### Check 1 — Workflow Response body is dynamic, not hardcoded

```powershell
# Pseudo-spec
$workflowJson = Get-Content "$workflowsDir/$flowName-*/workflow.json" | ConvertFrom-Json
$respondAction = $workflowJson.properties.definition.actions.PSObject.Properties |
                 Where-Object { $_.Value.kind -eq 'Skills' -and $_.Value.type -eq 'Response' } |
                 Select-Object -First 1
$bodyJson = $respondAction.Value.inputs.body | ConvertTo-Json -Depth 10
# FAIL if matches placeholder regex
if ($bodyJson -match '"result"\s*:\s*"[^@{][^"]*successfully\."') { return 'FAIL_HARDCODED' }
# FAIL if body does not reference any dynamic expression
if ($bodyJson -notmatch "@\{?(body|outputs|triggerBody|variables)\(") { return 'FAIL_NO_DYNAMIC_REF' }
```

MS Learn citation required: official `kind: Skills` Response action shape (capture URL from your B2 CITATION_INDEX).

#### Check 2 — Action `.mcs.yml` declares `inputs:` matching workflow trigger schema

```powershell
# Pseudo-spec
$workflowRequired = $workflowJson.properties.definition.triggers.manual.inputs.schema.required
$actionYaml = ConvertFrom-Yaml (Get-Content "$actionsDir/$flowName.mcs.yml" -Raw)
$declaredInputs = $actionYaml.inputs | ForEach-Object { $_.propertyName }
# FAIL if any required workflow trigger field is missing in action inputs
$missing = $workflowRequired | Where-Object { $_ -notin $declaredInputs }
if ($missing.Count -gt 0) { return "FAIL_MISSING_INPUTS:$($missing -join ',')" }
```

MS Learn citation: Copilot Studio `kind: TaskDialog` action schema with `inputs:` field semantics.

#### Check 3 — Topic `BeginDialog input:` maps all action inputs

```powershell
# Pseudo-spec
$topicYaml = ConvertFrom-Yaml (Get-Content "$topicsDir/$topicName.mcs.yml" -Raw)
$beginDialog = Find-Action $topicYaml.beginDialog.actions -Kind 'BeginDialog' -DialogPattern "*$flowName*"
$mappedInputs = $beginDialog.input.PSObject.Properties.Name
# FAIL if action declares inputs but topic input is empty
if ($declaredInputs.Count -gt 0 -and $mappedInputs.Count -eq 0) { return 'FAIL_EMPTY_INPUT' }
# FAIL if any declared input is not mapped in topic
$unmapped = $declaredInputs | Where-Object { $_ -notin $mappedInputs }
if ($unmapped.Count -gt 0) { return "FAIL_UNMAPPED:$($unmapped -join ',')" }
```

MS Learn citation: Copilot Studio `BeginDialog input:` Power Fx mapping syntax.

#### Check 4 — No placeholder strings anywhere

```powershell
# Pseudo-spec — grep across workflow JSON, action YAML, topic YAML
$placeholderPatterns = @(
  '"result"\s*:\s*"[^@{][^"]*successfully\."',
  '"placeholder"',
  '"todo"',
  '"tbd"',
  '"stub"'
)
foreach ($pattern in $placeholderPatterns) {
  if ((Get-Content $workflowJsonPath -Raw) -match $pattern) { return "FAIL_PLACEHOLDER:$pattern" }
}
```

#### Check 5 (Tenant Mode only) — Live tenant matches local source

When `-Mode Tenant`:
```powershell
# Pseudo-spec
$liveClientData = pac org fetch --xml @"
<fetch><entity name='workflow'><attribute name='clientdata'/><filter><condition attribute='workflowid' operator='eq' value='$workflowId'/></filter></entity></fetch>
"@
$liveJson = ConvertTo-Json $liveClientData
$localJson = Get-Content $workflowJsonPath -Raw
$liveSha = (Get-FileHash -InputObject $liveJson -Algorithm SHA256).Hash
$localSha = (Get-FileHash -InputObject $localJson -Algorithm SHA256).Hash
if ($liveSha -ne $localSha) { return "FAIL_DRIFT:LiveSha=$liveSha,LocalSha=$localSha" }
```

### 2.3 Verifier output JSON (mandatory shape)

Write to `<EvidenceDir>/Test-Pm0FunctionalContract_<YYYYMMDD_HHmmss>.json`:

```json
{
  "generatedAt": "2026-05-22 16:30:00 BRT",
  "agent": "Codex sub-B2",
  "mode": "Local",
  "overall": "PASS|FAIL",
  "passingFlowCount": 5,
  "blockingFlowCount": 0,
  "flows": [
    {
      "flowName": "PM0_PA_Card_ListarTarefas",
      "workflowId": "e0e3c6b0-a250-f111-bec7-000d3abc5cc6",
      "checks": {
        "check1_dynamic_response": {"status": "PASS", "evidence": "<body excerpt>", "msLearnCitation": "<url>"},
        "check2_action_inputs":    {"status": "PASS", "missing": [], "msLearnCitation": "<url>"},
        "check3_topic_mapping":    {"status": "PASS", "unmapped": [], "msLearnCitation": "<url>"},
        "check4_no_placeholder":   {"status": "PASS", "matchedPatterns": []},
        "check5_tenant_drift":     {"status": "SKIPPED_LOCAL_MODE"}
      },
      "overall": "PASS"
    }
  ]
}
```

### 2.4 Self-test requirements

You must self-test the verifier in 2 phases:

**Phase A — Negative test (pre-fix Local_Repo)**
- Run verifier against current `Local_Repo/Assistente PMO V2/`
- Expected: `overall: FAIL`, multiple flow checks FAIL (proves verifier catches the existing defects)
- Save output: `BRAVO/VERIFIER/pre_fix_negative_test/<ts>_pre_fix_result.json`
- Triplet evidence

**Phase B — Positive test (post-fix Local_Repo)**
- Wait for Codex Lead Alpha Gate 1 commit (fix patches applied to Local_Repo)
- Run verifier against patched Local_Repo
- Expected: `overall: PASS`, all 5 flows PASS
- Save output: `BRAVO/VERIFIER/post_fix_positive_test/<ts>_post_fix_result.json`
- Triplet evidence

If Phase A returns PASS or Phase B returns FAIL, the verifier itself is broken — fix the verifier before delivering.

### 2.5 B2 deliverables

```
.planning/comms/codex_pm0_remediation_20260522/BRAVO/VERIFIER/
├── Test-Pm0FunctionalContract.ps1        (the verifier)
├── VERIFIER_DESIGN.md                     (design doc with MS Learn cites)
├── pre_fix_negative_test/
│   ├── <ts>_pre_fix_result.json
│   └── evidence/<ts>_codex_sub_b2_negative_run.png
├── post_fix_positive_test/
│   ├── <ts>_post_fix_result.json
│   └── evidence/<ts>_codex_sub_b2_positive_run.png
└── VERIFIER_REPORT.md                     (acceptance summary)
```

---

## 3. SUBAGENT B1 — TEST DATA PREP + AQ-09 RUNTIME SMOKE EXECUTOR

You execute the 12-scenario AQ-09 runtime smoke after Codex Lead Gate 5 (publish) completes. Every scenario must produce full Evidence Triplet.

### 3.1 Phase 1 — Test data prep (read-only, before publish)

Per `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md` Shared Preconditions, verify these exist via PnP read-only (`Get-PnPListItem`):

| Asset | Expected value |
|---|---|
| Active project | `QA Robust 20260513 F` |
| ProjectID | `PRJ-274E5ACC` |
| SharePoint project item ID | `33` |
| Active task ID for update tests | `15` (or newer if owner chooses) |
| Deleted task ID for audit | `13` |
| SharePoint site | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital` |

PnP setup (Windows PowerShell 5.1):
```powershell
$ErrorActionPreference = "Stop"
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"
Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -DisableNameChecking
Connect-PnPOnline -Url $siteUrl -UseWebLogin
```

If any required asset is missing, document and request owner permission before seeding.

### 3.2 Phase 2 — Smoke execution (after Codex Lead Gate 5 publish completes)

Execute all 12 scenarios. **Section A is ship-gating. Section B is evidence only.**

#### Section A — In-Scope P0 Ship Gate (5 scenarios)

| Scenario | Topic | Chat input | Expected bot output spec | SP read-back assertion |
|---|---|---|---|---|
| **A1** | ListarTarefas | `listar tarefas QA Robust 20260513 F` | Static plain-text task list with real data from SP `Tarefas` for ProjectID `PRJ-274E5ACC`. No hardcoded "successfully". No markdown pipes. No responsavel email exposed. | `Get-PnPListItem -List Tarefas` filtered by `ProjectID eq 'PRJ-274E5ACC'` returns >= 1 active row matching bot reply |
| **A2** | ConsultarPortfolio | `consultar portfolio` | Static numeric counts: total active projects, RAG breakdown (Verde/Amarelo/Vermelho), open tasks total. Numbers must match SP. | `Get-PnPListItem -List Projetos` filtered by `Ativo eq true and Deleted eq false` count matches reply |
| **A3** | CriarTarefa | `criar tarefa: projeto=QA Robust 20260513 F, titulo=QA Smoke 316 20260522, responsavel=mbenicios@minsait.com, prazo=30/06/2026, horas=2, prioridade=Media` then `sim` | Confirmation with new task ID, ProjectID, no raw JSON exposed | New `Tarefas` row exists with `Title='QA Smoke 316 20260522'`, `ProjectID='PRJ-274E5ACC'`, `Deleted=false`. Capture new SP item ID |
| **A4** | AtualizarTarefa | `atualizar tarefa` then `15, em andamento, 2, nao, nao, nao, sim` | Bot preserves Responsavel, DataFim, Prioridade. No FlowActionBadGateway. Display shows real updated values, not raw `nao`. | `Get-PnPListItem -List Tarefas -Id 15` shows Responsavel/DataFim/Prioridade unchanged; Status=`Em Andamento`, HorasRealizadas updated |
| **A5** | AtualizarStatus | `atualizar status: projeto=QA Robust 20260513 F, status=Amarelo, resumo=Smoke 3.16 multilinha, percentual=45, risco=Nenhum, bloqueio=Nenhum, proxima acao=Revisar` then `sim` | Confirmation with parsed fields | New `Status Diario` row with `RAG=Amarelo`, `Resumo='Smoke 3.16 multilinha'`, `Percentual=45`, structured fields populated |

For each Section A scenario, **all 5 acceptance criteria** must hold:

1. Bot reply does NOT contain `ContentFiltered` or `openAIIndirectAttack`
2. Bot reply contains real backend data (verifiable in SP)
3. Bot reply does NOT contain hardcoded `"successfully."` placeholder
4. Power Automate run history shows `Succeeded` for the corresponding flow
5. Adaptive Card (where applicable) was posted to Teams channel `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2`

If any of the 5 fails for any Section A scenario → **NO-SHIP**.

#### Section B — Legacy out-of-scope (7 scenarios)

Execute B0 SP-Audit, B1 ConsultarProjeto, B2 CriarProjeto, B3 ExcluirProjeto, B4 ExcluirTarefa, B5 PedirDecisao, B6 RegistrarBloqueio, B7 RegistrarRisco per AQ09_SMOKE_RUNBOOK.md. ContentFiltered allowed (legacy debt). Capture full triplet evidence per scenario.

### 3.3 Per-scenario evidence triplet

For each of the 12 scenarios, capture:

```
.planning/comms/codex_pm0_remediation_20260522/BRAVO/SMOKE/<scenario>/
├── REPORT.md                    (per-scenario findings)
└── evidence/
    ├── <ts>_chat_input.txt      (verbatim user message sent)
    ├── <ts>_bot_reply.txt       (verbatim bot response)
    ├── <ts>_chat_screenshot.png (Copilot Studio test panel or Teams screenshot)
    ├── <ts>_pa_run_history.png  (Power Automate run history showing Succeeded)
    ├── <ts>_pa_run_id.txt       (run correlation ID)
    ├── <ts>_sp_readback.json    (PnP query result proving SP side effect)
    └── <ts>_sp_readback.png     (SharePoint UI screenshot proving the row)
```

REPORT.md template:

```markdown
# Scenario <ID> — <Topic> — <PASS|FAIL>

**Agent:** Codex sub-B1
**Timestamp BRT:** <YYYY-MM-DD HH:mm:ss>
**Power Automate run ID:** <guid>

## Acceptance criteria
| # | Criterion | Result |
|---|---|---|
| 1 | No ContentFiltered/openAIIndirectAttack | PASS/FAIL |
| 2 | Real backend data in bot reply | PASS/FAIL |
| 3 | No hardcoded "successfully." | PASS/FAIL |
| 4 | PA run Succeeded | PASS/FAIL |
| 5 | Adaptive Card posted (where applicable) | PASS/FAIL/N-A |

## Bot reply verbatim
<full text>

## SharePoint read-back
<query result>

## Evidence triplet files
<list of evidence/* files>
```

### 3.4 B1 deliverables

```
.planning/comms/codex_pm0_remediation_20260522/BRAVO/SMOKE/
├── PHASE1_TEST_DATA_PREP_REPORT.md
├── A1_ListarTarefas/{REPORT.md, evidence/}
├── A2_ConsultarPortfolio/{REPORT.md, evidence/}
├── A3_CriarTarefa/{REPORT.md, evidence/}
├── A4_AtualizarTarefa/{REPORT.md, evidence/}
├── A5_AtualizarStatus/{REPORT.md, evidence/}
├── B0_SP_Audit/...
├── B1_ConsultarProjeto/... ... B7_RegistrarRisco/...
├── SECTION_A_TABLE.md             (5-row table with PASS/FAIL summary)
├── SECTION_B_TABLE.md             (7-row table)
└── SMOKE_FINAL_REPORT.md          (consolidated, with ship recommendation)
```

---

## 4. SUBAGENT B3 — SOLUTION PACKAGE BUILDER + TENANT OPERATOR

You build the 3.16 solution package and execute the owner-approved tenant import + publish.

### 4.1 Phase 1 — Build package (after Codex Lead Alpha Gate 1 commits fix patches)

Reference script: `scripts/Build-Solution315ListStaticRuntimeBypass.ps1`. Adapt to:

```powershell
scripts/Build-Solution316Pm0FunctionalFix.ps1
```

#### Build steps

1. Apply Codex Lead Alpha's patches to `Local_Repo/Assistente PMO V2/` source files (workflows, actions, topics).
2. Run the new functional verifier from B2: `Test-Pm0FunctionalContract.ps1 -LocalRepoRoot 'Local_Repo/Assistente PMO V2/' -Mode Local -EvidenceDir <build_evidence>`. Must return `overall: PASS`.
3. Run all existing local static gates:
   - `tests/Test-PMOFlowStopShipAudit.ps1`
   - `tests/Test-SolutionZipP0Contracts.ps1`
   - `tests/Test-SolutionZipP24Contracts.ps1`
   - Content-safe test suite
   - Routing test suite
4. Build Dataverse solution zip via `pac solution pack` (per MS Learn). Output: `Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip`
5. Compute SHA256 and document version `3.16.0.0`
6. Re-run automated grep on the zip to confirm zero hardcoded placeholder matches:
   ```powershell
   Expand-Archive -Path 'Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip' -DestinationPath '<temp>'
   $matches = Select-String -Path "<temp>/Workflows/PM0_PA_Card_*.json" -Pattern '"result"\s*:\s*"[^@{][^"]*successfully\."'
   if ($matches) { throw "Hardcoded placeholders detected: $($matches.Count)" }
   ```

Triplet evidence per build step.

### 4.2 Phase 2 — Owner approval gate (Codex Lead asks, you wait)

Codex Lead writes the explicit ASK in the active thread (Codex Lead Gate 4). You wait for the owner's verbatim approval text. Do not proceed until owner approval is captured.

Capture: `.planning/comms/codex_pm0_remediation_20260522/BRAVO/PACKAGE_AND_PUBLISH/owner_approval_evidence.md` with:
- Verbatim owner message
- Timestamp BRT
- Codex Lead's ASK text that triggered the approval

### 4.3 Phase 3 — Tenant write execution

Pre-flight (read-only):
```powershell
pac auth list
pac env who
# expected: ColOfertasBrasilPro / e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

Triplet-evidence the pre-flight. If env is wrong, switch:
```powershell
pac env select --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
```

Import:
```powershell
pac solution import `
  --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 `
  --path 'Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip' `
  --publish-changes
```

Capture full terminal output, run ID, timestamp BRT.

Publish bot:
```powershell
pac copilot publish --bot-name 'Assistente PMO V2'
# or via Copilot Studio UI per MS Learn if pac copilot publish unsupported in current pac version
```

Capture: full terminal screenshot, Copilot Studio "Published" status panel screenshot, run IDs, timestamp BRT.

### 4.4 Phase 4 — Post-publish verification (read-only)

1. Re-run AQ-08 structural verifier:
   ```powershell
   tests/Test-Aq08PostRemediationReverify.ps1 -EvidenceDir 'BRAVO/PACKAGE_AND_PUBLISH/post_publish_aq08'
   ```
   Must remain PASS.

2. Re-run new functional verifier in tenant mode:
   ```powershell
   tests/Test-Pm0FunctionalContract.ps1 -Mode Tenant -EnvironmentId 'e2d10003-4d8e-e007-9d63-76d5fe89ef56' -EvidenceDir 'BRAVO/PACKAGE_AND_PUBLISH/post_publish_functional'
   ```
   Must return `overall: PASS`.

3. Drift monitor at T+5min and T+1h:
   ```powershell
   tests/Test-Aq08PublishDriftMonitor.ps1 -PublishedAt '<publish_utc>' -EvidenceDir 'BRAVO/PACKAGE_AND_PUBLISH/drift'
   ```

Triplet evidence per verification.

### 4.5 B3 deliverables

```
.planning/comms/codex_pm0_remediation_20260522/BRAVO/PACKAGE_AND_PUBLISH/
├── Build-Solution316Pm0FunctionalFix.ps1
├── package_build_log.txt
├── package/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip
├── package_sha256.txt
├── owner_approval_evidence.md
├── tenant_preflight_pac_env_who.txt
├── tenant_import_output.txt
├── tenant_import_screenshot.png
├── tenant_publish_output.txt
├── copilot_studio_published_panel.png
├── post_publish_aq08/{report.json, evidence/}
├── post_publish_functional/{report.json, evidence/}
├── drift/{t5min/, t1h/}
└── PACKAGE_AND_PUBLISH_REPORT.md
```

---

## 5. EXECUTION SEQUENCE AND CONCURRENCY

| Phase | Subagent | When to start | Depends on | Estimated effort |
|---|---|---|---|---|
| Verifier build | B2 | T+0 (immediately) | None | 2-3h |
| Verifier negative self-test | B2 | T+0 (parallel with build) | Verifier built | 30min |
| Test data prep | B1 Phase 1 | T+0 | None | 30min |
| Verifier positive self-test | B2 | After Codex Lead Alpha Gate 1 | Alpha fix patches committed | 30min |
| Package build | B3 Phase 1 | After B2 positive test PASS | B2 PASS + Alpha Gate 1 | 1h |
| Owner approval gate | B3 Phase 2 | After B3 Phase 1 done | Codex Lead Gate 4 ASK + Owner reply | wait |
| Tenant import + publish | B3 Phase 3 | After approval | Owner approval | 30min |
| Post-publish verification | B3 Phase 4 | After publish | Publish complete | 30min |
| Smoke 12 scenarios | B1 Phase 2 | After post-publish verify PASS | B3 Phase 4 PASS | 2h |
| Final Bravo report | B1 + B2 + B3 | After smoke complete | All Bravo done | 30min |

Critical path total: ~6-8h Bravo work (assuming Alpha completes in parallel).

---

## 6. EVIDENCE FOLDER (Bravo portion)

```
.planning/comms/codex_pm0_remediation_20260522/BRAVO/
├── VERIFIER/                       (B2)
│   ├── Test-Pm0FunctionalContract.ps1
│   ├── VERIFIER_DESIGN.md
│   ├── pre_fix_negative_test/
│   ├── post_fix_positive_test/
│   └── VERIFIER_REPORT.md
├── SMOKE/                          (B1)
│   ├── PHASE1_TEST_DATA_PREP_REPORT.md
│   ├── A1..A5/{REPORT.md, evidence/}
│   ├── B0..B7/{REPORT.md, evidence/}
│   ├── SECTION_A_TABLE.md
│   ├── SECTION_B_TABLE.md
│   └── SMOKE_FINAL_REPORT.md
├── PACKAGE_AND_PUBLISH/            (B3)
│   ├── Build-Solution316Pm0FunctionalFix.ps1
│   ├── package/, owner_approval_evidence.md
│   ├── tenant_*.{txt,png}
│   ├── post_publish_aq08/, post_publish_functional/
│   ├── drift/
│   └── PACKAGE_AND_PUBLISH_REPORT.md
├── BRAVO_FINAL_REPORT.md           (consolidated)
└── EVIDENCE_LOG.md                 (master triplet index for Bravo)
```

---

## 7. CONTINUOUS DOC UPDATES

After each phase transition, update:

- `.planning/AGENT_CHECKIN_REGISTRY.md` (log every Bravo subagent claim/complete with timestamp)
- `.planning/stop_ship/RISK_REGISTER.md` (if you discover new risks during smoke or verifier work)
- `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_TASKS_PLANNER.csv` (mark Bravo deliverables progress)
- `.planning/comms/STATUS_REPORT_20260522/STATUS_REPORT_EXECUTIVE_20260522.md` (after smoke completes, update gate status)
- `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` (10-min cadence)
- `.planning/comms/codex_pm0_remediation_20260522/DOC_UPDATES_LOG.md` (every project doc edit)

Header on every edit:
```
Last updated: <YYYY-MM-DD HH:mm:ss BRT> | Codex #2 | <one-line reason>
```

---

## 8. METRICS AND ACCEPTANCE CRITERIA (Bravo portion)

| Metric | Target | Verification |
|---|---|---|
| Functional verifier built and self-tested | 1 verifier, 2 self-tests (negative FAIL + positive PASS) | Files in `BRAVO/VERIFIER/` |
| Verifier covers 5 checks per flow | 25 check executions per run | Verifier output JSON |
| Solution 3.16 package built | 1 zip, SHA256 documented | `BRAVO/PACKAGE_AND_PUBLISH/` |
| Hardcoded placeholder regex match in zip | 0 matches | Build log + automated grep |
| Owner approval captured verbatim | 1 approval before tenant write | `owner_approval_evidence.md` |
| Tenant import success | 1 | `pac` output + screenshot |
| Tenant publish success | 1 | Copilot Studio panel screenshot |
| AQ-08 structural verifier post-publish | PASS | T+5min + T+1h evidence |
| Functional verifier in tenant mode post-publish | PASS | report.json |
| AQ-09 Section A scenarios | 5/5 PASS, all 5 acceptance criteria each | Per-scenario REPORT.md + evidence |
| ContentFiltered in Section A | 0 | Per-scenario evidence |
| Real backend data in Section A bot replies | 5/5 verifiable in SP | Per-scenario sp_readback evidence |
| AQ-09 Section B scenarios | 7/7 executed, evidence captured | Per-scenario REPORT.md |
| `[BRAVO COMPLETE]` marker | Written when all done | `INVESTIGATION_LOG.md` |
| EVIDENCE_LOG.md entries | One per gate transition + per scenario + per build step | Master index complete |

---

## 9. FORBIDDEN

| Action | Why |
|---|---|
| Tenant write without explicit owner approval per write | Tenant safety policy |
| Marking ANY step DONE without all 3 elements of Evidence Triplet | Golden Rule §0.2 |
| Marking ANY flow DONE without all 5 Functional DoD conditions | Golden Rule §0.3 |
| Citing memory or third-party for Microsoft behavior | MS Learn only |
| Inventing MS Learn URLs | Must be real, accessed, timestamped |
| Skipping any of 12 smoke scenarios | Acceptance criteria failure |
| Treating Section A ContentFiltered as ship-able | Section A is ship-gating |
| Editing tenant from Kiro instance | Kiro is read-only, only Codex writes tenant |
| Building package before Alpha commits fix patches | Build would package broken state |
| Running smoke before publish complete | Bot would test old broken state |

---

## 10. SYNC WITH CODEX #1 LEAD

- Both teams start at minute zero
- B2 (verifier) builds immediately using current Local_Repo trigger schemas
- B3 (package) waits for Alpha to commit fix patches and B2 positive test PASS
- B1 Phase 2 (smoke) waits for B3 publish complete and B3 post-publish verification PASS
- Both teams append progress to `.planning/comms/codex_pm0_remediation_20260522/INVESTIGATION_LOG.md` every 10 minutes
- When all Bravo deliverables done, write `[BRAVO COMPLETE]` line in `INVESTIGATION_LOG.md`
- Codex Lead consolidates Alpha + Bravo into `SHIP_REVIEW_3_16.md` for owner Gate 9

---

## 11. FINAL DELIVERY (your message in active thread when Bravo complete)

1. Confirmation of new Golden Rule (§0) absorbed and applied
2. Path to functional verifier source + design doc + self-test outputs (negative + positive)
3. Path to package zip + SHA256 + version tag
4. Owner approval evidence path (verbatim quote captured)
5. Tenant import + publish triplet evidence paths (terminal output, run IDs, screenshots)
6. AQ-09 Section A 5-row table (scenario, input, bot reply verbatim, SP read-back, all 5 acceptance criteria, triplet path)
7. AQ-09 Section B 7-row table (scenario, executed, content-filter status, evidence path)
8. Post-publish AQ-08 structural verifier result + functional verifier result
9. Drift T+5min and T+1h results
10. List of every project doc updated with timestamp BRT
11. Confirmation no tenant write was performed without explicit thread approval
12. `[BRAVO COMPLETE]` marker timestamp
13. Metrics table populated against §8 acceptance criteria

---

## 12. WHAT MUST NOT HAPPEN AGAIN

The defect that triggered this mission was a hardcoded `"result": "Tasks retrieved successfully."` in published flows that 5 prior agents marked DONE because structural verification passed and no one ran a real call.

Your B2 functional verifier is the technical guardrail that prevents this class of defect from passing gates again. Your B1 AQ-09 smoke is the runtime evidence that proves the fix actually works in the bot. Your B3 package + publish + post-verify is the controlled ship execution.

All three subagents must enforce Evidence Triplet and Functional DoD rigorously. If any Section A scenario delivers a hardcoded `"successfully."` reply, or if real backend data is not verifiable in SharePoint after a write, the mission has not been completed.

---

## END OF SPECIFICATION — Codex #2, begin Team Bravo now




