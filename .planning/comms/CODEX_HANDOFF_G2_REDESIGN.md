# CODEX Handoff — G2 Redesign: PostCardAndWaitForResponse

Copy/paste to CODEX-LEAD:

```text
You are CODEX-LEAD for PMO Intelligent Hub MVP.

OPUS-ARCH DESIGN DECISION — MANDATORY REDESIGN:

The "When someone responds to an adaptive card" TRIGGER has documented limitations in non-Default environments. Since all our work must stay in ColOfertasBrasilPro, OPUS-ARCH mandates the following redesign.

The ACTION "Post adaptive card and wait for a response" IS supported in non-Default environments. Therefore we consolidate the check-in into a single flow.

---

REDESIGN: Merge ProcessarRespostaCheckIn INTO EnviarCheckInDiario

Current architecture (2 flows):
- Flow A: PMO_PA_EnviarCheckInDiario → Recurrence 9h → Post card → END
- Flow B: PMO_PA_ProcessarRespostaCheckIn → Trigger: "When someone responds" → Process response → Write SP

New architecture (1 flow):
- Flow A (redesigned): PMO_PA_EnviarCheckInDiario → Recurrence 9h → Get active projects → Apply to each:
  1. "Post adaptive card and wait for a response" (Teams action, NOT trigger) using CheckInDiario.json in channel Projetos_Tranformação_Digital
  2. Parse the response body (StatusRAG, Percentual, Resumo, Bloqueios)
  3. SharePoint "Create item" → Status Diario list
  4. SharePoint "Update item" → Projetos list (StatusRAG, Percentual, UltimaAtualizacao)
  5. Condition: IF StatusRAG = "Vermelho" → Post AlertaCritico card + Email Sponsor

Flow B (PMO_PA_ProcessarRespostaCheckIn): DISABLE but keep for reference. Do NOT delete.

---

ALSO REDESIGN: PMO_PA_CheckInOnDemand

Same pattern — use "Post adaptive card and wait for a response" instead of posting card and relying on separate trigger.

- PMO_PA_CheckInOnDemand → Manual/Instant trigger → "Post adaptive card and wait for a response" for specific project → Parse response → Write SP Status Diario → Update Projetos

---

NO CHANGES to these flows (keep as-is):
- PMO_PA_AlertaProjetoVermelho — trigger is SP "When item modified", not Teams response. No risk.
- PMO_PA_AlertaSemAtualizacao — trigger is Recurrence. No risk.

---

Environment: ColOfertasBrasilPro (e2d10003-4d8e-e007-9d63-76d5fe89ef56)
SharePoint site: https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital
Teams channel: Projetos_Tranformação_Digital (GroupID: 96c5b0c4-46cc-46cd-8695-50451db74994)
Card JSONs: deploy/cards/CheckInDiario.json, deploy/cards/AlertaCritico.json

Constraints:
- Standard connectors ONLY
- "Post adaptive card and wait for a response" is a Standard Teams action
- Max card size 27KB (our cards are all <3KB)
- Flow timeout for wait: up to 28 days (acceptable for daily check-in)

After redesign:
1. Test EnviarCheckInDiario end-to-end: trigger → card posted → response received → SP written
2. Test CheckInOnDemand end-to-end: manual trigger → card → response → SP
3. Verify AlertaProjetoVermelho fires on SP item change
4. Verify AlertaSemAtualizacao fires on recurrence
5. Take Teams Desktop screenshot of each card rendered
6. Disable PMO_PA_ProcessarRespostaCheckIn (turn off, do not delete)

Update logs:
- .planning/comms/SUB2_PA_LOG.md
- .planning/comms/CODEX_LEAD_LOG.md
- .planning/comms/GATE_STATUS.md
- Create .planning/comms/OPUS_HANDOFF_G2_REDESIGN.md when done

Specifications reference: .planning/AGENT_CONTRACT.md Section 6
Auth reference: .planning/SHAREPOINT_ACCESS_RUNBOOK.md
```
