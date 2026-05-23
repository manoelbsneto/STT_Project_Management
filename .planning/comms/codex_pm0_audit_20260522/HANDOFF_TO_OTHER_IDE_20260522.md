# Handoff To Other IDE - PM0 SEV-0 Local Guards

Timestamp BRT: 2026-05-22 16:12:42 BRT
Agent: Codex #3
Workspace root: `D:\VMs\Projetos\STT_Project_Management`
Active repo subtree: `D:\VMs\Projetos\STT_Project_Management\Local_Repo`

## Copy/Paste Prompt

Continue from this state. Do not ask the owner to repeat context.

Mandatory first reads:

```text
.planning/GOLDEN_RULES.md
.planning/CURRENT_BASELINE.md
.planning/AGENT_CHECKIN_REGISTRY.md
.planning/START_HERE_CURRENT_STATUS.md
.planning/stop_ship/MASTER_CHECKLIST.md
.planning/comms/codex_pm0_audit_20260522/RCA_PM0_FLOWS_20260522.md
.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md
.planning/comms/codex_pm0_audit_20260522/MITIGATION_PLAN.md
.planning/comms/codex_pm0_audit_20260522/EXECUTIVE_SUMMARY.md
docs/MANUAL_OPERACIONAL_PMO.md
```

Current release state:

```text
NO-SHIP.
Active artifact is 3.15.1 HOTFIX_TOPICS in ColOfertasBrasilPro, but AQ-09 A1 failed.
AQ-08 route verification is structural-only and cannot be treated as functional PASS.
Owner must choose containment path before any tenant write: rollback, fix-and-ship, or hybrid.
No import, publish, deploy, portal/runtime modification, SharePoint write, Planner write, Teams post, or commit is allowed without explicit owner approval in the current thread.
```

Incident summary:

```text
AQ-09 A1 ListarTarefas failed because the live PM0 card-first path returned static caller text:
"Tasks retrieved successfully."

The bot then failed to return PMO task data.

Merged audit classification:
- STUB=1
- PARTIAL=4
- REAL=0

Main defects:
1. PM0 topic calls use input: {}.
2. PM0 action wrappers omit inputs: declarations.
3. PM0 workflow Response bodies return hardcoded/non-dynamic text.
4. AtualizarStatus PM0 flow has no SharePoint or Planner backend action.
```

Local verifier work completed by Codex #3:

```text
Added:
tests/Test-Pm0TopicActionFlowContract.ps1
tests/Test-Pm0WorkflowResponseSemantics.ps1
tests/Test-Pm0RuntimeEvidence.ps1

Evidence folder:
.planning/comms/codex_pm0_audit_20260522/PM0_LOCAL_VERIFIERS/

Current expected failures:
- Test-Pm0TopicActionFlowContract.ps1: exit 1, 12 failed checks
- Test-Pm0WorkflowResponseSemantics.ps1: exit 1, 11 failed checks
- Test-Pm0RuntimeEvidence.ps1: exit 1, 5 incomplete PM0 paths

These failures are expected against the current broken PM0 source and should remain blocking until real remediation is implemented and evidenced.
```

Commands to reproduce local verifier evidence:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Pm0TopicActionFlowContract.ps1 -SourceRoot "Local_Repo\Assistente PMO V2" -ReportPath ".planning\comms\codex_pm0_audit_20260522\PM0_LOCAL_VERIFIERS\topic_action_flow_contract.json"

powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Pm0WorkflowResponseSemantics.ps1 -SourceRoot "Local_Repo\Assistente PMO V2" -ReportPath ".planning\comms\codex_pm0_audit_20260522\PM0_LOCAL_VERIFIERS\workflow_response_semantics.json"

powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\Test-Pm0RuntimeEvidence.ps1 -EvidencePath ".planning\comms\aq09_smoke_runbook_20260520\evidence" -ReportPath ".planning\comms\codex_pm0_audit_20260522\PM0_LOCAL_VERIFIERS\runtime_evidence.json"
```

Current task state:

```text
PM0-REMEDIATE is PARTIAL_LOCAL_GUARDS_DONE.
Only verifier guards were implemented.
Deployable PM0 source fixes were not implemented in this turn.
Tenant/runtime actions were not performed.
Production remains blocked on owner containment/remediation decision.
```

Next safe local steps after owner chooses fix-and-ship or hybrid remediation:

```text
1. Patch PM0 action wrappers to declare required inputs matching workflow trigger schemas.
2. Patch PM0 topic BeginDialog blocks to map real topic variables instead of input: {}.
3. Replace static PM0 workflow Response result strings with feature-appropriate dynamic outputs or remove the path from release scope.
4. Re-run the three PM0 local verifier scripts.
5. Only after local guards pass, request explicit owner approval for any tenant write/import/publish/runtime retest.
6. Run AQ-09 functional smoke with evidence triplet: screenshot, timestamp BRT, agent name.
```

Files changed by Codex #3:

```text
tests/Test-Pm0TopicActionFlowContract.ps1
tests/Test-Pm0WorkflowResponseSemantics.ps1
tests/Test-Pm0RuntimeEvidence.ps1
.planning/START_HERE_CURRENT_STATUS.md
.planning/AGENT_CHECKIN_REGISTRY.md
.planning/stop_ship/MASTER_CHECKLIST.md
.planning/comms/AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
.planning/comms/codex_pm0_audit_20260522/REMEDIATION_PLAN.md
.planning/comms/codex_pm0_audit_20260522/DOC_UPDATES_LOG.md
.planning/comms/codex_pm0_audit_20260522/INVESTIGATION_LOG.md
.planning/comms/codex_pm0_audit_20260522/PM0_LOCAL_VERIFIERS/*
```

Important warning:

```text
Do not convert AQ-08 PASS into SHIP/PUBLISH confidence.
Do not mark any PM0 flow DONE until topic/action/flow contract, response semantics, runtime bot transcript, flow run evidence, timestamp BRT, agent name, and screenshot evidence all exist.
```
