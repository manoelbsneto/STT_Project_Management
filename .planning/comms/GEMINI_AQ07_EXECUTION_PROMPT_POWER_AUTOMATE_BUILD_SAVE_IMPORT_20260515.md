# Gemini AQ-07 Execution Prompt: Power Automate Build Save Import

Date: 2026-05-15
Prepared by: CODEX-LEAD
Purpose: execute AQ-07 Power Automate build/save/import only after local CODEX review passed.

## Agent To Use

Paste this prompt to: `GEMINI-PA`

After GEMINI-PA returns the result, paste the full output and evidence back to: `CODEX-LEAD`

## Copy/Paste Prompt

```text
You are GEMINI-PA, Principal Deploy Engineer for Power Automate.

TASK_ID: AQ-07-POWER-AUTOMATE-BUILD-SAVE-IMPORT

Owner approval scope:
You are approved ONLY to build/save/import the reviewed AQ-07 Power Automate flows from this local runbook package:

D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\

This is not a general tenant approval.

This approval does NOT authorize:
- Copilot publish.
- AQ-08 work.
- AQ-09 runtime smoke tests.
- SharePoint test writes outside what Power Automate build/save/import requires.
- Planner test writes outside what Power Automate build/save/import requires.
- Teams production posts.
- Final release / SHIP.
- Microsoft 365 CLI / m365.
- Any behavior change beyond the reviewed runbook.

Read first:
1. D:\VMs\Projetos\STT_Project_Management\.planning\comms\CODEX_REVIEW_GEMINI_AQ07_FINAL_PASS_20260515.md
2. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\PACKAGE_MANIFEST.json
3. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\QUALITY_GATES.md
4. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\FIELD_MAPPING.md
5. D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\VALIDATION.md
6. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
7. D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENT_TASK_IO_CONTRACT_PROTOCOL_20260515.md

Before starting, update:
D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md

Allowed tenant action:
- Power Automate portal build/save/import for AQ-07 reviewed flows only.

Allowed local write scope:
- D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md
- New AQ-07 execution evidence files under:
  D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\

Required build source:
- Use the exact flow build files under:
  D:\VMs\Projetos\STT_Project_Management\.planning\comms\aq07_power_automate_build_20260515\flows\

Critical implementation constraints:
1. Do not rebuild the flow behavior from memory.
2. Do not substitute route keys.
3. Do not change SharePoint field names.
4. Do not change Planner groupId, planId, or bucket IDs unless the portal blocks save/import and you return BLOCKED_AQ07_EXECUTION_REQUIRED.
5. Do not reintroduce hard-coded unconditional Status='Pendente'.
6. Do not create a create-task implementation where PlannerBucketId and SharePoint Status can diverge.
7. FI-04 Create Task must use the reviewed bucket/status mapping. SharePoint `Tarefas.Status` now preserves legacy values and includes the canonical AQ-07 values:
   - Piloto e Implantacao -> Status Piloto e Implantacao, bucketId 4YAXH7iU9E-6jZE2P1DbG5cAMAzH
   - Testes -> Status Testes, bucketId 7QYPufh54kum7MP4KUzzAZcAL6Ik
   - Cancelado -> Status Cancelado, bucketId 90TcFTFup0CjiHIdzY4gG5cALWKL
   - Concluido -> Status Concluido, bucketId F2WYUsnXeEue5qlwQuu3GJcAN1Ns
   - Em Andamento -> Status Em Andamento, bucketId ugZSNxsYW0WWCJ5Dtx0-l5cALVXG
   - empty/unmapped -> Status Pendente, bucketId HmzyGOgC4k6uOPm_cwG3zZcAGiAG
8. FI-04 Create SharePoint Item must set Status and PlannerBucketId from the same selected bucket mapping.

Required flow coverage:
- FI-01 PM0_PA_Card_ResumoExecutivoPortfolio
- FI-02 PM0_PA_Card_AtualizarStatus
- FI-03 PM0_PA_Card_ListarTarefas
- FI-04 PM0_PA_Card_CriarTarefa
- FI-05 PM0_PA_Card_AtualizarTarefa
- FI-06 PM0_PA_OpsFailureHandling

Stop conditions:
- If any flow cannot be built/saved/imported exactly from the reviewed runbook, stop and return BLOCKED_AQ07_EXECUTION_REQUIRED.
- If the portal requires behavior changes, stop and return BLOCKED_AQ07_EXECUTION_REQUIRED.
- If any required connector reference is missing or cannot be bound, stop and return BLOCKED_AQ07_EXECUTION_REQUIRED.
- If save/import triggers any unapproved data write or test execution, stop and document what happened.
- If you are uncertain whether an action is within scope, stop and ask for owner decision.

Evidence to capture:
- Flow display name.
- Flow ID.
- Environment name / URL.
- Connector references used.
- Screenshots of saved/imported flow overview.
- Screenshots or notes showing trigger/action sequence.
- Evidence FI-04 contains mapped Status + PlannerBucketId behavior.
- Any warnings/errors from Power Automate.
- Confirmation no Copilot publish occurred.
- Confirmation no Teams production posts occurred.
- Confirmation no Microsoft 365 CLI / m365 was used.
- Confirmation release remains NO-SHIP.

After completion or stop condition, update the check-in board again:
D:\VMs\Projetos\STT_Project_Management\.planning\comms\AGENTIC_CHECKIN_ADAPTIVE_CARDS_PLANNER_20260514.md

Final answer must include:
- TASK_ID
- STATUS
- DELIVERY_FORMAT
- FLOWS_BUILT_OR_IMPORTED
- FLOW_IDS
- ENVIRONMENT
- CONNECTION_REFERENCES
- FILES_USED
- VALIDATION_PERFORMED
- EVIDENCE_CAPTURED
- TENANT_ACTIONS_PERFORMED
- FORBIDDEN_ACTIONS_CONFIRMED_NOT_PERFORMED
- BLOCKERS
- NEXT_OWNER_DECISION_NEEDED

Allowed final statuses:
- READY_FOR_CODEX_REVIEW only if all AQ-07 flows were built/saved/imported and evidence was captured.
- BLOCKED_AQ07_EXECUTION_REQUIRED if any required flow cannot be built/saved/imported from the reviewed runbook.
- BLOCKED_FOR_OWNER_DECISION if a required action is outside the approval scope.

State explicitly:
Tenant actions performed: Power Automate build/save/import only, if completed.
Copilot publish performed: none.
Teams production posts performed: none.
Microsoft 365 CLI / m365 used: none.
Release decision: NO-SHIP.
```
