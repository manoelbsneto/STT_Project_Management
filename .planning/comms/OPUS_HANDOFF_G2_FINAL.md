# OPUS Handoff — G2 Wiring Patch Review

Copy/paste to OPUS-ARCH:

```text
You are OPUS-ARCH for PMO Intelligent Hub MVP.

Gate context:
- G0 PASSED.
- G1 PASSED.
- G2 remains CONDITIONAL, not FULL PASS.
- Mandatory environment remains ColOfertasBrasilPro only:
  - Environment ID: e2d10003-4d8e-e007-9d63-76d5fe89ef56
  - Environment URL: https://colofertasbrasilpro.crm4.dynamics.com/
- Do not use Default environment unless you explicitly approve a design exception.

What CODEX completed on 2026-05-02:
- Verified PAC and Windows PowerShell 5.1 PowerApps access against ColOfertasBrasilPro.
- Exported live definitions for all 5 PMO_PA_* P0 flows.
- Patched the 2 placeholder-only flows via ProcessSimple PATCH while preserving their live triggers:
  1. PMO_PA_ProcessarRespostaCheckIn
     - FlowName: 6c8ae320-46e0-42da-bc05-5d5a9622be03
     - Post-patch summary includes:
       - Compose normalization actions
       - SharePoint GetItems
       - SharePoint PostItem to Status Diario
       - SharePoint PatchItem to Projetos
       - Teams PostCardToConversation
       - Outlook SendEmailV2
  2. PMO_PA_AlertaProjetoVermelho
     - FlowName: 5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd
     - Post-patch summary includes:
       - If condition
       - SharePoint GetItem
       - Teams PostCardToConversation
       - Outlook SendEmailV2

Evidence:
- Patch script: deploy/PA_Patch_G2_Wiring.ps1
- Patch summary: .planning/comms/g2_wiring_patch_summary.json
- Patch request/result:
  - .planning/comms/processsimple_patch_request_6c8ae320-46e0-42da-bc05-5d5a9622be03.json
  - .planning/comms/processsimple_patch_result_6c8ae320-46e0-42da-bc05-5d5a9622be03.json
  - .planning/comms/processsimple_patch_request_5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd.json
  - .planning/comms/processsimple_patch_result_5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd.json
- Post-patch exported definitions/summaries:
  - .planning/comms/flow_definition_POSTPATCH_PMO_PA_ProcessarRespostaCheckIn_6c8ae320-46e0-42da-bc05-5d5a9622be03.json
  - .planning/comms/flow_summary_POSTPATCH_PMO_PA_ProcessarRespostaCheckIn_6c8ae320-46e0-42da-bc05-5d5a9622be03.json
  - .planning/comms/flow_definition_POSTPATCH_PMO_PA_AlertaProjetoVermelho_5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd.json
  - .planning/comms/flow_summary_POSTPATCH_PMO_PA_AlertaProjetoVermelho_5a2a491c-e135-4d3e-a4b5-5bfd0f5bc5fd.json
- Run-history captures:
  - .planning/comms/flow_runs_*.json
- Updated logs:
  - .planning/comms/SUB2_PA_LOG.md
  - .planning/comms/CODEX_LEAD_LOG.md
  - .planning/comms/GATE_STATUS.md
  - .planning/STATE.md
  - .planning/ROADMAP.md

Important design risk for OPUS review:
- Microsoft Teams connector docs state:
  1. "When someone responds to an adaptive card" works only in the default environment.
  2. "Post card in a chat or channel" cannot be combined with a separate "When someone responds to an adaptive card" listener flow without response-handling failures; Microsoft recommends PostCardAndWaitForResponse as the alternative.
- This conflicts with the project rule that all Power Platform / Power Automate work must stay in ColOfertasBrasilPro.

What is still missing for G2 FULL PASS:
1. Interactive Power Automate test run for each of the 5 P0 flows.
2. SharePoint validation that Status Diario is created and Projetos is updated from a check-in response.
3. Teams Desktop render screenshots for:
   - CheckInDiario.json
   - AlertaCritico.json
   - DecisaoBoard.json
4. Confirmation that Teams adaptive-card response architecture is acceptable in ColOfertasBrasilPro, or OPUS decision to redesign around PostCardAndWaitForResponse.

Decision requested:
- Review the post-patch evidence and decide:
  A. Keep current two-flow response-listener design and run interactive E2E despite Microsoft connector constraints.
  B. Redesign G2 check-in flow so card posting and response handling are in the same flow using Teams PostCardAndWaitForResponse.
  C. Approve a documented exception to use Default environment only for Teams adaptive-card response handling.

Recommended next owner:
- OPUS-ARCH for design decision.
- Then CODEX-LEAD / CODEX-PA for E2E validation and any approved redesign patch.
```
