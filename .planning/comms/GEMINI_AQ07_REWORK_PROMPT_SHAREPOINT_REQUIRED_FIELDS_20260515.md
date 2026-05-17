# Gemini AQ-07 Rework Prompt: SharePoint Required Fields

Date: 2026-05-15
Prepared by: CODEX-LEAD
Purpose: fix remaining FI-04 SharePoint create-item blocker.

## Copy/Paste Prompt

```text
You are GEMINI-PA, continuing AQ-07 corrective build preparation.

This is a targeted rework. Do not rebuild the whole package from scratch.

Read first:
1. D:\VMs\Projetos\STT_Project_Management\.planning\comms\CODEX_REVIEW_GEMINI_AQ07_EXACT_PLANNER_INPUTS_20260515.md
2. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md
3. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md
4. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENT_TASK_IO_CONTRACT_PROTOCOL_20260515.md

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

TASK_ID: AQ-07-REWORK-SHAREPOINT-REQUIRED-FIELDS

Required fix:

1. Update only the AQ-07 portal-build package files needed to fix FI-04 SharePoint create behavior.

2. In:
   D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\flows\FI-04_PM0_PA_Card_CriarTarefa.md

   update action `Create SharePoint Item` so it explicitly sets:
   - Title = triggerBody()?['title']
   - ProjectID = triggerBody()?['projectId']
   - Status = mapped status from selected bucket, default `Pendente`
   - PlannerTaskId = Planner Create Task output `id`
   - PlannerBucketId = DetermineBucket_Output
   - PlannerSyncStatus = `OK`
   - PlannerLastSyncAt = utcNow()
   - PlannerSyncError = empty string

3. Update `SharePoint Behavior` in FI-04:
   - required fields populated: Title, ProjectID, Status
   - planner sync fields populated: PlannerTaskId, PlannerBucketId, PlannerSyncStatus, PlannerLastSyncAt, PlannerSyncError
   - write order: Planner create first, then SharePoint create

4. Update supporting files:
   - FIELD_MAPPING.md
   - AQ07_ACCEPTANCE_MATRIX.md
   - VALIDATION.md
   - QUALITY_GATES.md if status text needs correction

5. Re-run local validation and record it in VALIDATION.md:
   - PACKAGE_MANIFEST.json parses.
   - FI-04 Create SharePoint Item includes Title, ProjectID, Status.
   - FI-04 Create SharePoint Item includes all five Planner sync fields.
   - No UNKNOWN_BLOCKER remains.
   - No tenant actions performed.

Final status rules:
- READY_FOR_CODEX_REVIEW only if AQ07-BLOCK-10 is resolved.
- BLOCKED_REWORK_REQUIRED if FI-04 still omits any required SharePoint create field.

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

