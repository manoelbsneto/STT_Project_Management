# Remediation Plan - PM0 Card-First Flows

Last updated: 2026-05-22 16:06 BRT | Codex #3 | Local verifier guard scripts implemented and expected failing evidence captured.

## Decision Boundary

This plan is local and read-only until Manoel Benicio approves tenant writes in the active thread. It separates proposed source changes, test changes, and any later tenant import/publish action.

Microsoft Learn basis:

- Agent flows used by Copilot Studio must use the agent-call trigger and return through the agent response action: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/flow-modify-use-with-agent`
- Agent flow inputs and outputs are the contract surfaced into Copilot Studio: `https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow-input-output`
- Missing or mismatched agent flow inputs/outputs can fail the action path: `https://learn.microsoft.com/en-us/troubleshoot/power-platform/copilot-studio/channels/agent-flow-action-bad-request`
- Power Automate provides explicit cloud-flow testing guidance and run monitoring guidance: `https://learn.microsoft.com/en-us/power-automate/get-started-logic-flow`, `https://learn.microsoft.com/en-us/power-automate/guidance/coding-guidelines/monitoring-and-alerting`

## Functional Definition Of Done

No in-scope flow may be marked DONE, READY, PASS, PUBLISH_GO, or functionally correct until all are true:

1. Structural route/binding/package checks pass.
2. Topic -> action -> flow required-input propagation is proven in source and in the release artifact.
3. Caller-visible response body is feature-appropriate and derived from the intended runtime data path or approved card-post path, not a placeholder success sentence.
4. A real cloud-flow test run is captured with inputs, outputs, status, and timestamp.
5. A runtime bot smoke test captures user utterance, any prompts, flow run, bot-visible output, and expected-versus-observed result.
6. Write flows additionally prove expected SharePoint/Planner side effects and rollback/cleanup handling.

The user-requested DoD phrase names `pac flow run`. Current project evidence does not support that command: Bravo B2 found no Microsoft Learn reference for `pac flow run`, and `.planning/TENANT_COMMAND_RUNBOOK.md` states installed PAC CLI `2.6.4` has no `pac flow` command. The functional gate remains mandatory; the run mechanism must be one of:

1. documented Power Automate cloud-flow test/run evidence plus bot transcript;
2. an owner-approved project harness that triggers the flow and stores equivalent run/output evidence;
3. a future Microsoft-documented PAC flow command if the toolchain gains one and the runbook is updated.

## Per-Defect Remediation

| Defect | Proposed fix | Proof test | Rollback if fix fails | Approval gate |
|---|---|---|---|---|
| PM0-DEF-01 / PM0-DEF-02 | Replace static PM0 response bodies with dynamic response/card output that matches each feature acceptance criterion. | Response-semantic verifier plus real runtime smoke per flow. | Revert source patch locally; if already imported, owner chooses approved tenant rollback or topic containment. | Required before any flow import/update or bot publish. |
| PM0-DEF-03 | Add action input declarations for flow-triggered fields used by PM0 actions. | Action/workflow contract test fails if required trigger field has no action input declaration. | Revert action YAML patch and block release. | Required before action artifact import/publish. |
| PM0-DEF-04 | Map topic variables into PM0 action calls; add a project resolver where workflow requires `projectId` but topic only collects name/code text. | Topic/action/workflow propagation test plus runtime prompt audit. | Restore previous topic YAML locally and stay NO-SHIP. | Required before topic paste/import/publish. |
| PM0-DEF-05 | Implement or remove `AtualizarStatus` PM0 release scope; current PM0 workflow is a Teams-only static path. | Alpha A1 re-audit must not classify release-scoped flow `STUB`. | Route back to approved legacy path or disable new path with owner decision. | Required for PM0 status path. |
| PM0-PROC-01 / 02 | Split structural gates from functional gates and block publish-go language without runtime proof. | Tests and checklist changes exercised on fixture that contains a static `result`. | Revert verifier changes only if replaced by stronger gate. | Documentation/QA owner approval. |
| PM0-DOC-01 | Correct stop-ship summaries from blanket `all stubs` to audited `1 STUB / 4 PARTIAL / 0 REAL`. | Documentation review against Alpha A1 table. | Keep correction; do not restore refuted statement. | None beyond audit merge. |

## Proposed Source Diffs

These are the exact source change shapes required by the audited contracts. Field names are taken from local PM0 workflow trigger schemas. Variable selection must be verified in the target topic before implementation because the audit found project name text where workflows require `projectId`.

### 1. Topic input propagation

```diff
--- Local_Repo/Assistente PMO V2/topics/ListarTarefas.mcs.yml
+++ Local_Repo/Assistente PMO V2/topics/ListarTarefas.mcs.yml
@@
-        input: {}
+        input:
+          binding:
+            action: =Topic.Action
+            projectId: =Topic.ProjectId
```

```diff
--- Local_Repo/Assistente PMO V2/topics/CriarTarefa.mcs.yml
+++ Local_Repo/Assistente PMO V2/topics/CriarTarefa.mcs.yml
@@
-        input: {}
+        input:
+          binding:
+            action: =Topic.Action
+            projectId: =Topic.ProjectId
```

```diff
--- Local_Repo/Assistente PMO V2/topics/AtualizarTarefa.mcs.yml
+++ Local_Repo/Assistente PMO V2/topics/AtualizarTarefa.mcs.yml
@@
-        input: {}
+        input:
+          binding:
+            action: =Topic.Action
```

```diff
--- Local_Repo/Assistente PMO V2/topics/AtualizarStatus.mcs.yml
+++ Local_Repo/Assistente PMO V2/topics/AtualizarStatus.mcs.yml
@@
-        input: {}
+        input:
+          binding:
+            routeKey: =Topic.RouteKey
```

If the current topic does not define `Topic.Action`, `Topic.ProjectId`, or `Topic.RouteKey`, implementation must add the corresponding variable assignment or resolver before these bindings. `ConsultarPortfolio` currently has no required workflow trigger fields.

### 2. Action input declarations

Each affected action wrapper needs local exported-input declarations aligned to the matching workflow trigger fields. The exact exported field shape must be copied from an existing project-local action wrapper with verified inputs because Microsoft Learn evidence for these exact exported `.mcs.yml` keys was not found in Bravo B2.

Required declarations by file:

```diff
--- Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_ListarTarefas.mcs.yml
+++ Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_ListarTarefas.mcs.yml
@@
+inputs:
+  - action
+  - projectId
```

```diff
--- Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_CriarTarefa.mcs.yml
+++ Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_CriarTarefa.mcs.yml
@@
+inputs:
+  - action
+  - projectId
```

```diff
--- Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_AtualizarTarefa.mcs.yml
+++ Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_AtualizarTarefa.mcs.yml
@@
+inputs:
+  - action
```

```diff
--- Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_AtualizarStatus.mcs.yml
+++ Local_Repo/Assistente PMO V2/actions/PM0_PA_Card_AtualizarStatus.mcs.yml
@@
+inputs:
+  - routeKey
```

The implementation patch must replace the compact placeholder form above with the repository-valid exported YAML structure and `InvokeFlowTaskAction` bindings proven by local examples.

### 3. Workflow response semantics

The response bodies must stop returning static success-only placeholders for release-scoped paths.

```diff
--- Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json
+++ Local_Repo/Assistente PMO V2/workflows/PM0_PA_Card_ListarTarefas-e0e3c6b0-a250-f111-bec7-000d3abc5cc6/workflow.json
@@
-          "result": "Tasks retrieved successfully."
+          "result": "@{<approved expression derived from the ListarTarefas result/card path>}"
```

Equivalent replacement is required for:

- `PM0_PA_Card_AtualizarStatus`: `Status update card posted successfully.`
- `PM0_PA_Card_AtualizarTarefa`: `Task updated successfully.`
- `PM0_PA_Card_ResumoExecutivoPortfolio`: `Executive portfolio retrieved successfully.`
- `PM0_PA_Card_CriarTarefa`: `Task created successfully.`

The approved expression must be feature-specific. A generic success sentence is not sufficient for a read path that is expected to return PMO data.

## Updated Verifier Requirements

Implementation status 2026-05-22 16:06 BRT: the local verifier guards now exist and have been run against the current PM0 source. Reports are stored under `.planning/comms/codex_pm0_audit_20260522/PM0_LOCAL_VERIFIERS/`.

| Verifier | Script | Current result |
|---|---|---|
| Topic/action/flow contract propagation | `tests/Test-Pm0TopicActionFlowContract.ps1` | Expected FAIL, exit `1`, 12 failed checks for missing action inputs and empty topic `input: {}` mappings. |
| Workflow response semantics | `tests/Test-Pm0WorkflowResponseSemantics.ps1` | Expected FAIL, exit `1`, 11 failed checks for static placeholders and missing backend lineage in `AtualizarStatus`. |
| Runtime evidence completeness | `tests/Test-Pm0RuntimeEvidence.ps1` | Expected FAIL, exit `1`, five PM0 paths incomplete until approved runtime evidence is captured. |

### Structural verifier remains

Keep AQ-08 route checks:

- expected PM0 action reference exists in topic;
- forbidden legacy action reference absent where migration intends PM0;
- action-to-workflow ID binding matches expected workflow inventory;
- package hashes, manifest, ASCII, and import-shape checks remain.

### Functional verifier added

Add blocking tests before any functional PASS:

1. `Test-Pm0TopicActionFlowContract.ps1`
   - parse five topic YAMLs, five action YAMLs, five workflow JSON trigger schemas;
   - fail when workflow `required` fields are absent from action/topic propagation;
   - fail known empty-input fixture for `ListarTarefas`.
2. `Test-Pm0WorkflowResponseSemantics.ps1`
   - parse workflow JSON response actions;
   - fail literal placeholder results from the audited list;
   - fail release-scoped flow classified `STUB`;
   - require data/action lineage note for response expression.
3. `Test-Pm0RuntimeEvidence.ps1`
   - validate stored runtime evidence artifact has utterance, expected result, observed result, run status, timestamp, operator, and flow ID;
   - keep structural-only evidence insufficient for runtime PASS.

## Build And Release Gates

| Gate | Before | Required change |
|---|---|---|
| AQ-07 save/build | Static result strings could pass. | Reject placeholder caller results for release-scoped PM0 paths. |
| Phase B hotfix | Workflow byte-equality treated as confidence. | Byte-equality may prove no new drift only; it cannot replace response-semantic checks. |
| Pre-publish review | Runtime smoke could be outstanding. | Publish-go is blocked until designated runtime smoke evidence exists or owner explicitly chooses containment/no-ship. |
| AQ-08 | Structural route PASS. | Label as `STRUCTURAL_ONLY`; runtime remains separate. |
| AQ-09 | Owner/manual smoke caught escape late. | Store repeatable evidence fixture and require it after approved change. |

## Automated Evidence Spec

| Artifact | Command | Expected output |
|---|---|---|
| Topic/action/flow contract report | `pwsh -File tests/Test-Pm0TopicActionFlowContract.ps1` | PASS for all required fields or explicit failing field list. |
| Response semantics report | `pwsh -File tests/Test-Pm0WorkflowResponseSemantics.ps1` | No audited placeholder result remains in release scope. |
| Runtime evidence validation | `pwsh -File tests/Test-Pm0RuntimeEvidence.ps1 -EvidencePath <path>` | PASS only when run evidence and bot transcript are complete. |
| Manual/approved cloud flow run | Power Automate test/run capture per runbook and Learn testing guidance. | Inputs, output, status, timestamp, and run ID saved. |
| Runtime bot smoke | AQ-09 runbook plus saved transcript. | Expected PMO task/portfolio/update/create behavior appears to user. |

## Acceptance

Remediation is accepted only when:

1. in-scope PM0 flows no longer classify `STUB` or `PARTIAL` unless explicitly removed from release scope;
2. topic/action/flow contract tests pass;
3. runtime bot evidence exists for each release-scoped flow path;
4. owner approves any tenant write before import, flow update, topic paste, or publish.
