# Gemini AQ-07 Rework Prompt: Exact Planner Inputs

Date: 2026-05-15
Prepared by: CODEX-LEAD
Purpose: remove remaining ambiguity from AQ-07 portal-build runbook.

## Copy/Paste Prompt

```text
You are GEMINI-PA, continuing AQ-07 corrective build preparation.

This is a targeted rework. Do not rebuild the whole package from scratch. Fix only the remaining AQ-07 build specificity blockers.

Read first:
1. D:\VMs\Projetos\STT_Project_Management\.planning\comms\CODEX_REVIEW_GEMINI_AQ07_REWORK_ROUTE_KEYS_20260515.md
2. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md
3. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md
4. D:\VMs\Projetos\STT_Project_Management\.planning\comms\GEMINI_AQ07_CORRECTIVE_PROMPT_20260515.md
5. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENT_TASK_IO_CONTRACT_PROTOCOL_20260515.md

Update check-in before edits and after edits:
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

TASK_ID: AQ-07-REWORK-EXACT-PLANNER-INPUTS

Required fixes:

1. FI-03 task list behavior:
   - Make the task source explicit.
   - If using Planner list, the action sequence must say:
     connector: Planner
     operationId: ListTasks_V3
     groupId: 96c5b0c4-46cc-46cd-8695-50451db74994
     planId: -1kBj1PLv0qQM-R4PwkqbpcABv_P
   - If using SharePoint `Tarefas` for correlation, specify the exact internal field used for project correlation.
   - Do not use `Title eq projectId` unless the evidence proves Title stores projectId. If not proven, replace it.

2. FI-04 create task behavior:
   - Replace `input parameters: planId, title` with exact portal-build inputs:
     groupId
     planId
     bucketId
     title
     startDateTime if used
     dueDateTime if used
   - Replace `bucket IDs from AQ-04: target specific bucket` with an exact bucket selection rule.
   - Use only AQ-04 bucket IDs:
     Piloto e Implantacao = 4YAXH7iU9E-6jZE2P1DbG5cAMAzH
     Testes = 7QYPufh54kum7MP4KUzzAZcAL6Ik
     Cancelado = 90TcFTFup0CjiHIdzY4gG5cALWKL
     Concluido = F2WYUsnXeEue5qlwQuu3GJcAN1Ns
     Em andamento = ugZSNxsYW0WWCJ5Dtx0-l5cALVXG
     Pendente = HmzyGOgC4k6uOPm_cwG3zZcAGiAG
   - Default create bucket must be `Pendente` unless card input explicitly maps to another approved bucket.

3. FI-05 update task behavior:
   - Replace `input parameters: taskId=TargetPlannerTaskId, details` with exact update inputs.
   - Define exact status-to-bucket and percentComplete mapping:
     Pendente -> bucketId HmzyGOgC4k6uOPm_cwG3zZcAGiAG, percentComplete 0
     Em andamento -> bucketId ugZSNxsYW0WWCJ5Dtx0-l5cALVXG, percentComplete 50
     Testes -> bucketId 7QYPufh54kum7MP4KUzzAZcAL6Ik, percentComplete 75
     Piloto e Implantacao -> bucketId 4YAXH7iU9E-6jZE2P1DbG5cAMAzH, percentComplete 90
     Concluido -> bucketId F2WYUsnXeEue5qlwQuu3GJcAN1Ns, percentComplete 100
     Cancelado -> bucketId 90TcFTFup0CjiHIdzY4gG5cALWKL, percentComplete 100
   - Keep rule: never trust client-submitted plannerTaskId. Resolve PlannerTaskId server-side from SharePoint `Tarefas`.

4. Update supporting files:
   - FIELD_MAPPING.md
   - PACKAGE_MANIFEST.json if needed
   - CARD_ACTION_BINDING_MATRIX.csv if needed
   - AQ07_ACCEPTANCE_MATRIX.md
   - QUALITY_GATES.md
   - VALIDATION.md
   - flows/FI-03_PM0_PA_Card_ListarTarefas.md
   - flows/FI-04_PM0_PA_Card_CriarTarefa.md
   - flows/FI-05_PM0_PA_Card_AtualizarTarefa.md

5. Re-run local validation and record it in VALIDATION.md:
   - PACKAGE_MANIFEST.json parses.
   - No invalid route keys remain.
   - No ambiguous Planner placeholders remain:
     target specific bucket
     use target bucket
     input parameters: planId, title
     input parameters: taskId=TargetPlannerTaskId, details
     Title eq projectId
   - No UNKNOWN_BLOCKER remains.
   - No tenant actions performed.

Final status rules:
- READY_FOR_CODEX_REVIEW only if all blockers in CODEX_REVIEW_GEMINI_AQ07_REWORK_ROUTE_KEYS_20260515.md are resolved.
- BLOCKED_REWORK_REQUIRED if any ambiguous Planner build input remains.

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

