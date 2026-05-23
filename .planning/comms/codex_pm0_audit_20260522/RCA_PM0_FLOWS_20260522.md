# RCA - PM0 Card-First Flows - 2026-05-22

Last updated: 2026-05-22 15:32 BRT | Codex #1 | Alpha and Bravo evidence merged into incident RCA.

## 1. Incident Summary

AQ-09 A1 failed on 2026-05-22 at 14:42 BRT when the live `ListarTarefas` path returned the static flow result `Tasks retrieved successfully.` to Copilot Studio and the bot answered `Nao encontrei essa informacao nas listas do PMO.` instead of returning task data. The failure escaped because the AQ-07 build contract allowed static caller responses and later AQ-08/hotfix/publish evidence proved routing and artifact preservation, not caller-visible flow semantics.

The PM0 card-first lane is not functionally release-ready. Alpha found one local PM0 flow with no SharePoint or Planner action, four local PM0 flows with backend actions but static caller responses, all five PM0 action wrappers without an `inputs:` block, and all five migrated topics invoking PM0 actions with `input: {}`.

## 2. Detection Timeline

| Timestamp | Event | Evidence |
|---|---|---|
| 2026-05-15 16:01:08 BRT | AQ-07 preflight recorded `runtimeTestsPerformed: false`. | `.planning/comms/aq07_power_automate_build_20260515/execution_evidence/preflight.json` |
| 2026-05-15 | AQ-07 accepted PM0 flow save/build evidence, including a static FI-03 caller return. | `.planning/comms/aq07_power_automate_build_20260515/AQ07_ACCEPTANCE_MATRIX.md`; `flows/FI-03_PM0_PA_Card_ListarTarefas.md` |
| 2026-05-21 | 3.15.1 hotfix package gate passed because workflow files remained baseline-equal while topic routing was corrected. | `.planning/comms/solution_3_15_1_hotfix_topics_20260521/build/QA_EVIDENCE_HOTFIX_TOPICS.md` |
| 2026-05-21 14:15 BRT | Gemini-PA signed `PUBLISH_GO` on incremental pre-publish review. | `.planning/comms/gemini_pa_audit_3_15_1_hotfix_topics_20260521/AUDIT_REPORT.md` |
| 2026-05-21 15:58 BRT | Independent review consolidation signed `PUBLISH_GO` while AQ-09 runtime smoke remained outstanding. | `.planning/comms/independent_review_3_15_1_20260521/CONSOLIDATED_VERDICT.md` |
| 2026-05-22 08:28 and 09:23 BRT | AQ-08 post-publish drift summaries passed structural route/binding inventory. | `.planning/comms/aq08_topic_routing_verification_20260520/post_publish_verify/drift_monitoring_20260522_0816/` |
| 2026-05-22 14:42 BRT | Owner A1 smoke failed on the first evidenced caller-visible runtime path. | `.planning/stop_ship/A1_FAIL_RCA_20260522.md`; Bravo `pac_fetch_pm0_card_flowruns_by_workflow.txt` |
| 2026-05-22 15:18-15:32 BRT | Codex #1 Alpha and Codex #2 Bravo audit lanes produced local contract, tenant drift, Microsoft Learn, and process evidence. | `.planning/comms/codex_pm0_audit_20260522/` |

## 3. Affected Components

| Component | Current evidence |
|---|---|
| Tenant | `ColOfertasBrasilPro`, environment ID `e2d10003-4d8e-e007-9d63-76d5fe89ef56` |
| Bot | `Assistente PMO V2`, tenant row `pmo_AssistentePMO_V2`; Bravo read-only PAC output shows last published 2026-05-22 14:40 BRT and synchronized 14:41 BRT. |
| Active M2 package | `Solution/PMO_v11_Tarefas_3_15_1_HOTFIX_TOPICS.zip`, published candidate named in current baseline. |
| Rollback baseline | `Solution/PMO_v11_Tarefas_3_10_POST_WFSET_CLEAN.zip`, SHA256 `37A3E7C85392D9E049CD26E01CF1D31F4B78A00DF35E0B7FAE23A252F29CB691`. |
| Migrated topics | `AtualizarStatus`, `AtualizarTarefa`, `ConsultarPortfolio`, `CriarTarefa`, `ListarTarefas`. |
| PM0 actions | `PM0_PA_Card_AtualizarStatus`, `PM0_PA_Card_AtualizarTarefa`, `PM0_PA_Card_ResumoExecutivoPortfolio`, `PM0_PA_Card_CriarTarefa`, `PM0_PA_Card_ListarTarefas`. |
| PM0 workflows | IDs `1721e0a3-a250-f111-bec7-000d3abc5cc6`, `7c6300c2-a250-f111-bec7-000d3abc5cc6`, `8333bd91-a250-f111-bec7-000d3abc5cc6`, `7f662db7-a250-f111-bec7-000d3abc5cc6`, `e0e3c6b0-a250-f111-bec7-000d3abc5cc6`. |

Bravo B1 tenant drift evidence shows the live PM0 workflow clientdata is semantically equal to the local PM0 workflow clientdata for all five flows at the audited leaves (`fieldDriftCount: 0` per flow). The local workflow defects therefore remain relevant to the audited live PM0 workflow definitions even though raw serialized SHA256 values differ.

## 4. Investigation Methodology

### 4.1 Local evidence commands

The local audit is reproducible with these commands from repository root:

```powershell
rg -n '"result":|operationId|kind|inputs: \{\}|BeginDialog|PM0_PA_Card_' 'Local_Repo/Assistente PMO V2/actions' 'Local_Repo/Assistente PMO V2/topics' 'Local_Repo/Assistente PMO V2/workflows'
Get-Content '.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/AUDIT_TABLE.md'
Get-Content '.planning/comms/codex_pm0_audit_20260522/ALPHA/A2_actions/AUDIT_TABLE.md'
Get-Content '.planning/comms/codex_pm0_audit_20260522/ALPHA/A3_topics/AUDIT_TABLE.md'
Get-Content '.planning/comms/codex_pm0_audit_20260522/BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md'
Get-Content '.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md'
```

### 4.2 Local files read

- Mandatory reading gate files listed in the final handoff.
- Alpha reports under `.planning/comms/codex_pm0_audit_20260522/ALPHA/`.
- AQ-07, AQ-08, AQ-09, 3.15.1 hotfix, Gemini-PA, Track H, independent review, stop-ship, runbook, and status evidence cited in Bravo B3.
- Local source under `Local_Repo/Assistente PMO V2/{workflows,actions,topics}` for the five PM0 paths.

### 4.3 Bravo tenant read-only evidence

Bravo used read-only PAC/Dataverse fetch evidence stored under `.planning/comms/codex_pm0_audit_20260522/BRAVO/B1_tenant_drift/PAC_OUTPUTS/`:

- `pac_fetch_assistente_pmo_v2_bot_current.txt`
- `pac_fetch_pm0_card_botcomponent_workflow_bindings.txt`
- `pac_fetch_pm0_card_workflow_clientdata.txt`
- `pm0_card_clientdata_comparison_summary.json`
- `pac_fetch_pm0_card_flowruns_by_workflow.txt`

No Codex #1 tenant write was performed.

### 4.4 Microsoft Learn URLs used

- `https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent`
- `https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output`
- `https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/channels/agent-flow-action-bad-request`
- `https://learn.microsoft.com/en-us/connectors/sharepoint/`
- `https://learn.microsoft.com/en-us/connectors/planner/`
- `https://learn.microsoft.com/en-us/connectors/teams/`
- `https://learn.microsoft.com/en-us/power-automate/get-started-logic-flow`
- `https://learn.microsoft.com/en-us/power-automate/guidance/coding-guidelines/monitoring-and-alerting`
- `https://learn.microsoft.com/en-us/power-platform/developer/cli/reference/solution`

Access timestamps and source boundaries are indexed in Bravo B2. Microsoft Learn supports the agent-call trigger, agent response action, connector operations, flow testing, monitoring, and `pac solution import`. The exact exported YAML keys for `TaskDialog` / `InvokeFlowTaskAction`, exact exported `BeginDialog input:` mapping shape, exact exported workflow metadata `kind: Skills`, and a Microsoft Learn `pac flow run` reference were not found; this RCA treats those keys as local export evidence, not unsupported Microsoft behavior claims.

## 5. Findings And Defect Register

| ID | Severity | Finding | Evidence | Divergence |
|---|---|---|---|---|
| PM0-DEF-01 | SEV-0 | `ListarTarefas` A1 live runtime returns a static success placeholder to the bot instead of caller-visible task data. | Owner A1 failure; `pac_fetch_pm0_card_flowruns_by_workflow.txt`; A1 `ListarTarefas.md` response body line evidence. | Microsoft Learn agent-flow outputs are the flow response surfaced back into the agent; static success text cannot satisfy a task-list result contract. |
| PM0-DEF-02 | SEV-0 | None of the five audited PM0 local workflow response bodies is `REAL`; four are `PARTIAL`, one is `STUB`. | Alpha A1 audit table and per-flow reports. | AQ-08 structural route PASS was consumed as functional confidence. |
| PM0-DEF-03 | SEV-0 | All five PM0 action wrappers omit a top-level `inputs:` block; four omit fields required by matching workflow triggers. | Alpha A2 audit table and per-action reports. | Copilot Studio flow action input contracts are not represented in the audited local action wrappers. |
| PM0-DEF-04 | SEV-0 | All five migrated topic calls use `input: {}`; four topics omit workflow-required fields. | Alpha A3 audit table and per-topic reports. | Topic route correction did not carry the PM0 parameter contract. |
| PM0-DEF-05 | HIGH | `AtualizarStatus` is the only audited PM0 flow with no SharePoint or Planner action at all. | Alpha A1 `AtualizarStatus.md`. | A status-update path has no audited backend data/update action in its PM0 workflow body. |
| PM0-PROC-01 | HIGH | AQ-07 accepted static caller returns and explicitly deferred runtime. | AQ-07 acceptance matrix, FI-03 contract, preflight, quality gates; Bravo B3. | Build/save acceptance allowed the failure class. |
| PM0-PROC-02 | HIGH | Phase B, Gemini-PA, independent review, and AQ-08 post-publish drift gates were structural and did not block the caller-visible defect. | Bravo B3; `tests/Test-Aq08PostRemediationReverify.ps1`. | Publish confidence exceeded tested behavior. |
| PM0-DOC-01 | MEDIUM | Stop-ship summaries state all five PM0 flows are stubs with no SharePoint logic; current audit narrows that statement. | `.planning/stop_ship/RISK_REGISTER.md`; `.planning/stop_ship/MASTER_CHECKLIST.md`; Alpha A1; Bravo B3. | Incident docs must distinguish `STUB` from `PARTIAL`. |

Defect register counts: `SEV-0=4`, `HIGH=3`, `MEDIUM=1`.

## 6. Root Causes

### Direct root cause

The live `ListarTarefas` caller path exposes a static workflow `Response` result instead of a result derived from the task-query/card output. The audited topic and action wrapper contract also fails to pass required `action` and `projectId` fields into that PM0 flow path.

### Contributing root causes

1. AQ-07 defined static caller return text as acceptable build evidence for PM0 card flows.
2. The 3.15.1 hotfix focused on topic routing and baseline preservation, so inherited PM0 response behavior was not re-opened.
3. AQ-08 verifier logic checked route/action/workflow references and drift inventory only.

### Systemic root cause - five whys

1. Why did A1 fail? The bot received static success text instead of task data.
2. Why did the flow return static text? PM0 response bodies were saved with placeholders or non-dynamic success summaries.
3. Why did publish gates allow those bodies? AQ-07 accepted static returns and later gates checked routing, packaging, hashes, and bindings.
4. Why did those gates stand in for function? The Definition of Done did not require a real flow call plus a runtime bot assertion before a DONE/PUBLISH confidence statement.
5. Why was the gap systemic? Multiple agents reused the same structural evidence surface, so independent review increased repetition, not behavioral coverage.

## 7. Process Failure Analysis

Bravo B3 counts five product gate failures:

1. AQ-07 Power Automate build/save acceptance.
2. Phase B 3.15.1 hotfix package gate.
3. Gemini-PA 3.15.1 pre-publish incremental audit.
4. Independent Phase A review consolidation.
5. AQ-08 post-publish route/drift pass chain.

Track H and AQ-09 PREP V2 are not counted as product gate passes because their own reports limit scope to tooling/fixture readiness. AQ-09 A1 itself is the functional check that caught the defect.

## 8. Why Previous Audits Did Not Catch It

- AQ-07 checked that the PM0 flow definitions saved and returned sanitized ASCII status strings.
- Phase B checked that the hotfix changed routing artifacts and preserved workflow baseline equality.
- Gemini-PA and independent review accepted byte-equal workflows as no new workflow regression.
- AQ-08 checked expected PM0 action references and workflow bindings, not topic input propagation or response semantics.
- None of those gates required the observed sequence `topic -> action -> flow -> dynamic response -> bot-rendered result` for `ListarTarefas` before the owner ran A1.

## 9. Blast Radius

| Area | Assessment |
|---|---|
| Production decision | STOP-SHIP for PM0 card-first release confidence until functional evidence exists. |
| Live tenant | Bravo B1 shows PM0 bindings active and local/live audited workflow clientdata semantically aligned. |
| Data integrity | This audit proves response/contract defects. It does not prove SharePoint or Planner data corruption. Write-path flows remain high-risk until write-side smoke and side-effect checks pass. |
| M1 baseline | 3.10 remains the known rollback candidate in project docs. |
| M2 milestone | PM0 hybrid card-first milestone remains blocked on remediation or owner-approved containment. |
| Trust/process | Prior DONE/PUBLISH wording is unreliable where it relied only on structural evidence. |
| Downstream phases | Release, drift monitoring, AQ-09, and documentation gates must consume functional evidence labels separately from structural labels. |

## 10. Containment Actions Taken

| Timestamp BRT | Containment |
|---|---|
| 2026-05-22 14:42 | Owner A1 smoke exposed functional failure. |
| 2026-05-22 after A1 | Stop-ship/RCA lane opened in planning documents. |
| 2026-05-22 15:18 | Codex #1 mandatory-read gate completed before Alpha audit. |
| 2026-05-22 15:22 | Alpha A1/A2/A3 dispatched with disjoint local report folders. |
| 2026-05-22 15:23 | Bravo B1/B2/B3 dispatched with read-only tenant, Microsoft Learn, and process lanes. |
| 2026-05-22 15:32 | RCA merge written; no tenant write executed by Codex #1. |

## 11. Lessons Learned

1. A structural route PASS must be labeled `STRUCTURAL_ONLY`.
2. A flow call is not DONE because it returns a syntactically valid `result` key.
3. Local exported topic/action/flow contracts need an automated propagation check before publish.
4. Read-path flows need response-semantic checks against expected user-visible data.
5. Write-path flows need both side-effect checks and caller-visible confirmation.
6. Documentation hypotheses must be corrected when later audit evidence narrows them.

## 12. Action Items

| Action | Owner | Due | Acceptance |
|---|---|---|---|
| Choose containment path: rollback, fix-and-ship, or hybrid. | Manoel Benicio | Before next tenant write | Owner decision recorded in active thread and check-in registry. |
| Replace PM0 static caller results with dynamic feature-appropriate responses/cards. | Implementation owner after approval | Remediation sprint | Alpha A1 reclassifies all in-scope release flows as `REAL` or owner removes them from release scope. |
| Add topic/action/flow contract propagation verifier. | QA/automation owner | Before next PM0 publish | Four missing required-field cases fail pre-publish tests. |
| Split AQ-08 structural pass from runtime functional pass. | QA owner | Before next publish-go | Status docs cannot say DONE/PUBLISH from AQ-08 alone. |
| Execute AQ-09 functional smoke with saved transcript and run evidence. | Owner/runtime operator | After approved remediation or rollback | Real bot transcript, flow run, expected result, and side-effect evidence stored. |

## 13. References

- Alpha workflow audit table: `.planning/comms/codex_pm0_audit_20260522/ALPHA/A1_workflows/AUDIT_TABLE.md`
- Alpha action audit table: `.planning/comms/codex_pm0_audit_20260522/ALPHA/A2_actions/AUDIT_TABLE.md`
- Alpha topic audit table: `.planning/comms/codex_pm0_audit_20260522/ALPHA/A3_topics/AUDIT_TABLE.md`
- Bravo citation index: `.planning/comms/codex_pm0_audit_20260522/BRAVO/B2_ms_learn_citations/CITATION_INDEX.md`
- Bravo process analysis: `.planning/comms/codex_pm0_audit_20260522/BRAVO/B3_process_failure/PROCESS_FAILURE_ANALYSIS.md`
- Bravo tenant evidence: `.planning/comms/codex_pm0_audit_20260522/BRAVO/B1_tenant_drift/PAC_OUTPUTS/`

