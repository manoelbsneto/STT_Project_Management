# CODEX #2 — PM0 FIX-AND-SHIP REMEDIATION (Team Bravo)
## Mission: build functional verifier, prep test data, build & ship package, execute AQ-09 smoke
## SEV-0 | Run in parallel with Codex #1 Lead

**Date:** 2026-05-22 16:02 BRT
**Owner decision:** FIX-AND-SHIP, all 5 flows in 1 release, broken state stays in tenant during fix.
**Owner:** Manoel Benicio. Sole approver. **Codex (#1 and #2) is the ONLY agent authorized to perform tenant writes.** Kiro is read-only.
**Source of truth:** official Microsoft Learn (`learn.microsoft.com`) only. Memory, blogs, third-party rejected.
**Continuation:** Continues from your prior B1/B2/B3 audit at `.planning/comms/codex_pm0_audit_20260522/BRAVO/`.

---

## 0. NEW MANDATORY RULES (read first)

`.planning/GOLDEN_RULES.md` was updated 2026-05-22 15:58 BRT with three rules that govern this mission:

### Continuous Documentation Update Rule
After every action, update relevant project doc immediately. No batching.

### Evidence Triplet Rule (MANDATORY)
Every test, deploy, audit, gate, smoke, DONE claim MUST include all three:
1. **Screenshot** — PNG/JPG saved under evidence folder. Required for UI surfaces (Copilot Studio test, Teams, SharePoint, Power Automate run history). CLI: terminal screenshot.
2. **Timestamp BRT** — `YYYY-MM-DD HH:mm:ss BRT` at moment of action.
3. **Agent name** — named agent (Codex #2, Codex sub-B1, etc.).

Storage: `.planning/comms/codex_pm0_remediation_20260522/<workstream>/evidence/<YYYYMMDD_HHmmss>_<agent>_<step>.{png,md,txt,json}` indexed in `EVIDENCE_LOG.md`.

Missing any element = `INCOMPLETE` = cannot cite as DONE/PASS/PUBLISH.

### Functional Definition of Done Rule
Flow DONE only when:
1. Real runtime call returns real backend data (not hardcoded).
2. Runtime evidence captured per Triplet.
3. Bot end-to-end reproduces with real data in reply.
4. Action declares `inputs:` matching workflow trigger schema.
5. Topic `BeginDialog input:` maps all required workflow trigger fields.
6. No DONE/PASS/PUBLISH wording without 1-5.

---

## 1. CONTEXT (continuity)

Read your prior Bravo outputs and updated Golden Rules:
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B1_tenant_drift/`
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md`
- `.planning/comms/codex_pm0_audit_20260522/BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md`
- `.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md` (written by Codex #1)
- `.planning/GOLDEN_RULES.md` (updated 15:58 BRT)
- `.planning/comms/aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md`

The 5 in-scope flows:

| Topic | Action | Workflow ID |
|---|---|---|
| `AtualizarStatus` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarStatus` | `1721e0a3-a250-f111-bec7-000d3abc5cc6` |
| `AtualizarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_AtualizarTarefa` | `7c6300c2-a250-f111-bec7-000d3abc5cc6` |
| `ConsultarPortfolio` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ResumoExecutivoPortfolio` | `8333bd91-a250-f111-bec7-000d3abc5cc6` |
| `CriarTarefa` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_CriarTarefa` | `7f662db7-a250-f111-bec7-000d3abc5cc6` |
| `ListarTarefas` | `pmo_AssistentePMO_V2.action.PM0_PA_Card_ListarTarefas` | `e0e3c6b0-a250-f111-bec7-000d3abc5cc6` |

---

## 2. YOUR DELIVERABLES (3 subagents in parallel)

### Subagent B1 — Test Data Prep + AQ-09 Runtime Smoke Executor

**Phase 1: Test data prep (read-only first, write after Codex Lead Gate 5 publish)**

Per `aq09_smoke_runbook_20260520/AQ09_SMOKE_RUNBOOK.md` Shared Preconditions:

- Active project: `QA Robust 20260513 F`, ProjectID `PRJ-274E5ACC`, SP item `33`
- Active task for update tests: `15` (or newer if needed)
- Deleted task for audit: `13`

Verify these exist via PnP read-only (`Get-PnPListItem`). If any missing, document and request owner permission to seed via PnP write.

**Phase 2: AQ-09 smoke execution (after Codex Lead Gate 5 publish)**

Execute all 12 scenarios from `AQ09_SMOKE_RUNBOOK.md`:

- **Section A (5 scenarios, ship-gating):** A1 ListarTarefas, A2 ConsultarPortfolio, A3 CriarTarefa, A4 AtualizarTarefa, A5 AtualizarStatus
- **Section B (7 scenarios, evidence only):** B0 SP-Audit, B1 ConsultarProjeto, B2 CriarProjeto, B3 ExcluirProjeto, B4 ExcluirTarefa, B5 PedirDecisao, B6 RegistrarBloqueio, B7 RegistrarRisco

Per scenario, capture full Evidence Triplet:
- Screenshot of Copilot Studio test panel OR Teams chat (PNG)
- Timestamp BRT at moment of message send
- Agent name = `Codex #2 sub-B1`
- Bot reply text verbatim
- Power Automate run ID (when flow invoked)
- SP read-back evidence proving the side effect (or lack thereof)

For Section A: any ContentFiltered/openAIIndirectAttack = NO-SHIP.
For Section B: ContentFiltered allowed (legacy debt per ADR_AQ08).

Output:
```
.planning/comms/codex_pm0_remediation_20260522/SMOKE/
├── A1_ListarTarefas/{evidence/, REPORT.md}
├── A2_ConsultarPortfolio/...
├── A3_CriarTarefa/...
├── A4_AtualizarTarefa/...
├── A5_AtualizarStatus/...
├── B0_SP_Audit/...
├── B1_ConsultarProjeto/... ... B7_RegistrarRisco/...
├── SECTION_A_TABLE.md
├── SECTION_B_TABLE.md
└── SMOKE_FINAL_REPORT.md
```

### Subagent B2 — Functional Verifier Builder

Build new test script `tests/Test-Pm0FunctionalContract.ps1` that enforces the Functional DoD rule per flow:

For each of the 5 PM0 workflows, the verifier must check:

1. **Workflow Response body is dynamic, not hardcoded.**
   - Parse workflow JSON
   - Find `Respond_Success` (or equivalent Response action of `kind: Skills`)
   - Body must NOT match regex `"result":\s*"[^@{][^"]*successfully\."`
   - Body MUST reference at least one of: `@body('Get_*')`, `@body('List_*')`, `@outputs('*')`, `@triggerBody()`, `@variables('*')`
   - Cite MS Learn (from B2 CITATION_INDEX) for required Skills Response shape

2. **Action `.mcs.yml` declares `inputs:` block with all required workflow trigger fields.**
   - Parse workflow trigger schema (`triggers.manual.inputs.schema.required[]`)
   - Parse action `.mcs.yml`
   - Action `inputs:` must declare every field in workflow `required[]`
   - Field types must match (string, number, boolean per MS Learn)

3. **Topic `.mcs.yml` `BeginDialog input:` maps all action inputs.**
   - Parse action `inputs:` from previous check
   - Parse topic `BeginDialog` block calling that action
   - `input:` Power Fx mapping must reference each action input
   - No `input: {}` empty allowed when action declares inputs

4. **No placeholder strings anywhere.**
   - Grep workflow JSON, action YAML, topic YAML for `"successfully."`, `"placeholder"`, `"todo"`, `"tbd"`, `"stub"`, hardcoded strings in Response bodies
   - Any match = FAIL

Output: `tests/Test-Pm0FunctionalContract.ps1` (PowerShell), exit code 0 PASS, exit code 1 FAIL with detailed report.

Self-test: run against current Local_Repo (must FAIL — proves it catches the existing defect). Run against Codex #1's patched files post-fix (must PASS — proves remediation works).

Save self-test outputs:
```
.planning/comms/codex_pm0_remediation_20260522/VERIFIER/
├── Test-Pm0FunctionalContract.ps1
├── pre_fix_negative_test/ (FAIL expected, evidenced)
├── post_fix_positive_test/ (PASS expected after Alpha fixes, evidenced)
└── VERIFIER_REPORT.md
```

### Subagent B3 — Solution Package Builder + Tenant Operator

**Phase 1: Build package (after Alpha fixes complete)**

- Use existing `scripts/Build-Solution315ListStaticRuntimeBypass.ps1` as reference, adapt to `Build-Solution316Pm0FunctionalFix.ps1`
- Package name: `PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip`
- Apply Alpha's patches to `Local_Repo` source
- Run all existing local gates: P0/P24 contracts, stop-ship audit, content-safe, routing, drift
- Run NEW functional verifier from B2: must PASS
- Compute SHA256, document version `3.16.0.0`

**Phase 2: Tenant write (only after explicit owner approval)**

You are authorized by owner directive 2026-05-22 to perform tenant writes. Codex Lead will request specific approval per write in the active thread (Gate 4 of Codex Lead pipeline). Wait for approval text. Then execute:

```powershell
pac auth list
pac env who          # confirm ColOfertasBrasilPro
pac solution import --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --path 'Solution/PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip' --publish-changes
pac copilot publish  # or equivalent per MS Learn for Assistente PMO V2
```

Capture full Evidence Triplet for import + publish:
- Screenshot of `pac` terminal output
- Timestamp BRT
- Agent = `Codex #2 sub-B3`
- Run IDs from import response
- Screenshot of Copilot Studio "Published" status panel post-publish

**Phase 3: Post-publish verification (read-only)**

- Re-run AQ-08 structural verifier (`tests/Test-Aq08PostRemediationReverify.ps1`) — must remain PASS
- Re-run new functional verifier (`tests/Test-Pm0FunctionalContract.ps1`) against tenant — must PASS
- Drift monitor at T+5min and T+1h after publish

Output:
```
.planning/comms/codex_pm0_remediation_20260522/PACKAGE_AND_PUBLISH/
├── Build-Solution316Pm0FunctionalFix.ps1
├── package_build_log.txt
├── PMO_v11_Tarefas_3_16_PM0_FUNCTIONAL_FIX.zip   (linked from package/)
├── package_sha256.txt
├── owner_approval_evidence.md  (verbatim quote of owner approval in thread)
├── tenant_import_output.txt
├── tenant_publish_output.txt
├── post_publish_aq08_verifier_result.json
├── post_publish_functional_verifier_result.json
├── drift_t5min.json, drift_t1h.json
└── evidence/  (all triplet files)
```

---

## 3. EVIDENCE FOLDER

```
.planning/comms/codex_pm0_remediation_20260522/
├── INVESTIGATION_LOG.md         (append-only, both teams)
├── DOC_UPDATES_LOG.md
├── EVIDENCE_LOG.md              (master triplet index)
├── ALPHA/                       (Codex #1)
├── BRAVO/                       (you own)
│   ├── SMOKE/                   (B1)
│   ├── VERIFIER/                (B2)
│   └── PACKAGE_AND_PUBLISH/     (B3)
└── ship_review/SHIP_REVIEW_3_16.md   (Codex Lead writes)
```

---

## 4. SYNC WITH CODEX #1 LEAD

- Both teams start at minute zero
- B2 (functional verifier) can be built immediately, before Alpha fixes complete (uses workflow trigger schema as input, that exists in current Local_Repo)
- B3 (package build) waits for Alpha to commit fix patches
- B1 Phase 2 (smoke) waits for Codex Lead Gate 5 (publish) to complete
- Append progress to `INVESTIGATION_LOG.md` every 10 minutes
- Mark `[BRAVO COMPLETE]` after smoke + verifier + post-publish verify all done

---

## 5. CONTINUOUS DOC UPDATES

Same list as Codex Lead. Each edit: `Last updated: <YYYY-MM-DD HH:mm:ss BRT> | Codex #2 | <one-line reason>` and logged in `DOC_UPDATES_LOG.md`.

---

## 6. FORBIDDEN

- Tenant writes without explicit owner approval per write
- Marking ANY step DONE without all 3 elements of Evidence Triplet
- Marking ANY flow DONE without all 5 conditions of Functional DoD
- Citing memory or third-party for Microsoft behavior
- Inventing MS Learn URLs
- Skipping Section A scenarios in smoke
- Treating Section A ContentFiltered as ship-able

---

## 7. ACCEPTANCE GATES (Bravo portion)

1. Functional verifier built, self-tested negative (pre-fix FAIL) and positive (post-fix PASS), both triplet-evidenced
2. Solution 3.16 package built, SHA256 documented, all local gates PASS
3. Owner approval verbatim quote captured before tenant write
4. Tenant import + publish executed with full triplet evidence
5. AQ-08 structural verifier post-publish PASS (no regression)
6. Functional verifier post-publish PASS
7. Drift T+5min and T+1h PASS
8. AQ-09 Section A 5/5 PASS with real backend data, zero ContentFiltered, full triplet per scenario
9. AQ-09 Section B all 7 executed, evidence captured (Section B failures don't block ship)
10. `[BRAVO COMPLETE]` marker in INVESTIGATION_LOG.md
11. EVIDENCE_LOG.md complete with every triplet entry

---

## 8. FINAL DELIVERY (your message in active thread)

1. Confirmation of new Golden Rule (§0) absorbed
2. Path to functional verifier + self-test results (pre and post)
3. Path to package zip + SHA256
4. Owner approval evidence path
5. Tenant import + publish triplet evidence paths
6. AQ-09 Section A 5-row table (input, bot reply, SP verification, triplet path)
7. AQ-09 Section B 7-row table
8. Post-publish structural + functional verifier results
9. Drift T+5min / T+1h results
10. List of every project doc updated with timestamp
11. Confirmation no tenant write was performed without explicit thread approval
12. `[BRAVO COMPLETE]` marker timestamp

---

## 9. WHAT MUST NOT HAPPEN AGAIN

The defect that triggered this mission was a hardcoded placeholder in published flows that 5 prior agents marked DONE. Your functional verifier (B2) is the technical guardrail that prevents this class of defect from passing gates again. Your AQ-09 smoke (B1) is the runtime evidence that proves the fix works. Your package build + publish (B3) is the ship execution. All three subagents must enforce Evidence Triplet and Functional DoD rigorously.

---

## END OF PROMPT — Codex #2, begin Bravo remediation
