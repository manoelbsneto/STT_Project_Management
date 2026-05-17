# Gemini AQ-07 Rework Prompt: Create Status Mapping

Date: 2026-05-15
Prepared by: CODEX-LEAD
Purpose: fix FI-04 SharePoint status mismatch with selected Planner bucket.

## Copy/Paste Prompt

```text
You are GEMINI-PA, continuing AQ-07 corrective build preparation.

This is a targeted rework. Do not rebuild the whole package from scratch.

Read first:
1. D:\VMs\Projetos\STT_Project_Management\.planning\comms\CODEX_REVIEW_GEMINI_AQ07_SHAREPOINT_REQUIRED_FIELDS_20260515.md
2. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ04_PLANNER_IDS_OWNER_POWER_AUTOMATE_VALIDATION_20260515.md
3. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AQ03_SHAREPOINT_TAREFAS_SCHEMA_WRITE_20260515.md
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

TASK_ID: AQ-07-REWORK-CREATE-STATUS-MAPPING

Required fix:

1. In:
   D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\flows\FI-04_PM0_PA_Card_CriarTarefa.md

   replace hard-coded:
   Status='Pendente'

   with a mapped status output tied to the selected bucket.

2. Define explicit mapping:
   - Piloto e Implantacao -> Status `Piloto e Implantacao`, bucketId `4YAXH7iU9E-6jZE2P1DbG5cAMAzH`
   - Testes -> Status `Testes`, bucketId `7QYPufh54kum7MP4KUzzAZcAL6Ik`
   - Cancelado -> Status `Cancelado`, bucketId `90TcFTFup0CjiHIdzY4gG5cALWKL`
   - Concluido -> Status `Concluido`, bucketId `F2WYUsnXeEue5qlwQuu3GJcAN1Ns`
   - Em Andamento -> Status `Em Andamento`, bucketId `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG`
   - empty/unmapped -> Status `Pendente`, bucketId `HmzyGOgC4k6uOPm_cwG3zZcAGiAG`

3. The `Create SharePoint Item` action must set:
   - Status = DetermineStatus_Output
   - PlannerBucketId = DetermineBucket_Output

4. Update:
   - FIELD_MAPPING.md
   - AQ07_ACCEPTANCE_MATRIX.md
   - VALIDATION.md
   - QUALITY_GATES.md if needed

5. Re-run local validation:
   - PACKAGE_MANIFEST.json parses.
   - FI-04 no longer has unconditional `Status='Pendente'`.
   - FI-04 explicitly maps selected bucket to SharePoint Status.
   - No UNKNOWN_BLOCKER remains.
   - No tenant actions performed.

Final status rules:
- READY_FOR_CODEX_REVIEW only if AQ07-BLOCK-11 is resolved.
- BLOCKED_REWORK_REQUIRED if create task can still write PlannerBucketId and SharePoint Status inconsistently.

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
