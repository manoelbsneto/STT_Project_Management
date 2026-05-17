# Gemini AQ-07 Rework Prompt: Route Keys and FI-03 Contract

Date: 2026-05-15
Prepared by: CODEX-LEAD
Purpose: rework only the blocking findings from CODEX AQ-07 package review.

## Copy/Paste Prompt

```text
You are GEMINI-PA, continuing AQ-07 corrective build preparation.

This is a targeted rework. Do not rebuild the whole package from scratch. Fix only the blockers identified by CODEX-LEAD.

Read first:
1. D:\VMs\Projetos\STT_Project_Management\.planning\comms\CODEX_REVIEW_GEMINI_AQ07_BUILD_PACKAGE_20260515.md
2. D:\VMs\Projetos\STT_Project_Management\.planning\comms\GEMINI_AQ07_CORRECTIVE_PROMPT_20260515.md
3. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENT_TASK_IO_CONTRACT_PROTOCOL_20260515.md
4. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md

Update the check-in board before edits and after edits:
D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md

Allowed write scope:
- D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\
- D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md

Forbidden:
- No tenant actions.
- No Power Automate save/import.
- No Copilot publish.
- No SharePoint writes.
- No Planner writes.
- No Teams production posts.
- No Microsoft 365 CLI / m365.

TASK_ID: AQ-07-REWORK-ROUTE-KEYS-FI03

Required fixes:

1. Replace all invalid task route keys:
   - task.list -> task.card.route
   - task.create -> task.card.route
   - task.update -> task.card.route

2. Replace all invalid ops route keys:
   - ops.failure -> pmo.ops

3. Preserve action-specific behavior in the `action` field only.
   Correct pattern:
   - routeKey = task.card.route
   - action = list | create | update

4. Fix FI-03 consistency:
   - If FI-03 is a Planner task-list flow, its action sequence must include Planner `ListTasks_V3` with:
     groupId = 96c5b0c4-46cc-46cd-8695-50451db74994
     planId = -1kBj1PLv0qQM-R4PwkqbpcABv_P
   - Then normalize the Planner output before card construction.
   - Do not claim Planner `ListTasks_V3` in the manifest while using only SharePoint `GetItems` in the build file.

5. Update these files consistently:
   - PACKAGE_MANIFEST.json
   - CARD_ACTION_BINDING_MATRIX.csv
   - QUALITY_GATES.md
   - AQ07_ACCEPTANCE_MATRIX.md
   - VALIDATION.md
   - flows/FI-03_PM0_PA_Card_ListarTarefas.md
   - flows/FI-04_PM0_PA_Card_CriarTarefa.md
   - flows/FI-05_PM0_PA_Card_AtualizarTarefa.md
   - flows/FI-06_PM0_PA_OpsFailureHandling.md

6. Re-run local validation and record it in VALIDATION.md:
   - PACKAGE_MANIFEST.json parses.
   - CSV headers still match the required contract.
   - No invalid route keys remain:
     task.list, task.create, task.update, ops.failure
   - Approved route keys are used:
     board.status, pm.status.updates, task.card.route, pmo.ops
   - No UNKNOWN_BLOCKER remains.
   - No tenant actions performed.

Final status rules:
- READY_FOR_CODEX_REVIEW only if all blockers in CODEX_REVIEW_GEMINI_AQ07_BUILD_PACKAGE_20260515.md are resolved.
- BLOCKED_REWORK_REQUIRED if any invalid route key or FI-03 mismatch remains.

Final answer must include:
- TASK_ID
- STATUS
- DELIVERY_FORMAT
- FILES_CHANGED
- VALIDATION_PERFORMED
- QUALITY_GATES
- EVIDENCE
- TENANT_ACTIONS_PERFORMED
- BLOCKERS
- NEXT_OWNER_DECISION_NEEDED

State explicitly:
Tenant actions performed: none.
Release decision: NO-SHIP.
```

