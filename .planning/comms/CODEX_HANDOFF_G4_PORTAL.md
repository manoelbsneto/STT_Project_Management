# CODEX Handoff — G4 Programmatic Completion

Copy/paste to CODEX-LEAD:

```text
You are CODEX-LEAD for PMO Intelligent Hub MVP.

OPUS-ARCH reviewed the Copilot Studio portal state for "Assistente PMO" (bot ID: 0c4a9729-d55d-483c-8ec3-db9369583155).

IMPORTANT: The user is available RIGHT NOW to provide MFA, credentials, or any interactive authentication needed. If you hit AADSTS50076 or any auth blocker, STOP and ask the user to complete the MFA step — do NOT skip the task.

All tasks should be done PROGRAMMATICALLY via Dataverse Web API or PAC CLI — not manually in the portal.

Environment: ColOfertasBrasilPro
- Environment ID: e2d10003-4d8e-e007-9d63-76d5fe89ef56
- Dataverse URL: https://colofertasbrasilpro.crm4.dynamics.com
- Bot ID: 0c4a9729-d55d-483c-8ec3-db9369583155

Auth: Use existing PAC CLI session (`pac auth list` should show ColOfertasBrasilPro).
For Dataverse API calls, use the PAC auth token or PowerShell with the existing authenticated session.

---

TASK 1 — Set Agent Instructions via Dataverse API

The bot's system prompt (Instructions) is stored in the Dataverse `bot` entity.

Option A — PAC CLI:
pac copilot update --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --id 0c4a9729-d55d-483c-8ec3-db9369583155 --instructions "Você é o Assistente PMO, um agente de IA para gestão de portfólio de projetos da equipe de Transformação Digital.\n\nRegras:\n1. Responda SEMPRE em português do Brasil (pt-BR).\n2. Use APENAS dados das listas SharePoint do PMO (Projetos, Status Diário, Riscos e Bloqueios, Decisões do Board).\n3. NUNCA invente dados. Se não encontrar informação, diga 'Não encontrei essa informação nas listas do PMO.'\n4. Para QUALQUER operação de escrita (atualizar status, registrar risco, pedir decisão), SEMPRE confirme com o usuário antes de executar.\n5. NÃO pesquise na internet. NÃO use conhecimento genérico.\n6. Formate respostas com emojis para status: 🟢 Verde, 🟡 Amarelo, 🔴 Vermelho.\n7. Seja conciso e direto."

Option B — Dataverse PATCH:
PATCH https://colofertasbrasilpro.crm4.dynamics.com/api/data/v9.2/bots(0c4a9729-d55d-483c-8ec3-db9369583155)
Content-Type: application/json
{
  "configuration": "{\"Instructions\":\"Você é o Assistente PMO...\"}"
}

Try Option A first. If --instructions is not a supported flag, use Option B with PowerShell Invoke-RestMethod.

---

TASK 2 — Add SharePoint Knowledge Source via Dataverse API

Knowledge sources in Copilot Studio are stored as `botcomponent` records of type `KnowledgeSource`.

Use Dataverse API to create a knowledge source component:
POST https://colofertasbrasilpro.crm4.dynamics.com/api/data/v9.2/botcomponents
Content-Type: application/json
{
  "componenttype": 12,
  "name": "PMO SharePoint Knowledge",
  "schemaname": "cr8a5_pmosharepoint",
  "content": "{\"SharePointUrl\":\"https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital\"}",
  "bot_botcomponent@odata.bind": "/bots(0c4a9729-d55d-483c-8ec3-db9369583155)"
}

Alternative: Use `pac copilot` commands if available for knowledge binding.

If the exact schema for knowledge source components is different, first query existing components:
GET https://colofertasbrasilpro.crm4.dynamics.com/api/data/v9.2/botcomponents?$filter=_bot_botid_value eq '0c4a9729-d55d-483c-8ec3-db9369583155'&$select=name,componenttype,content

This will show all existing bot components and their structure, which you can use as reference.

---

TASK 3 — Bind additional PA flows as tools

First, make the flows solution-aware if not already:
pac flow update --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --id cd0467a2-c989-474e-a629-28c704913489 --solution-aware true
pac flow update --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --id f67daf7b-53a7-4d35-9275-7c8c42a35896 --solution-aware true

Then query Dataverse for their workflow entity IDs:
GET https://colofertasbrasilpro.crm4.dynamics.com/api/data/v9.2/workflows?$filter=name eq 'PMO_PA_EscalarRiscoCritico' or name eq 'PMO_PA_RegistrarDecisaoBoard'&$select=workflowid,name

Then add them as bot actions via Dataverse:
POST https://colofertasbrasilpro.crm4.dynamics.com/api/data/v9.2/botcomponents
{
  "componenttype": 1,
  "name": "PMO_PA_EscalarRiscoCritico",
  "content": "{\"WorkflowId\":\"<dataverse-workflow-id>\",\"FlowId\":\"cd0467a2-c989-474e-a629-28c704913489\"}",
  "bot_botcomponent@odata.bind": "/bots(0c4a9729-d55d-483c-8ec3-db9369583155)"
}

Reference: the existing CheckInOnDemand binding used workflowEntityId f5aab85e-ff46-f111-bec7-7ced8d955c6c.

---

TASK 4 — Publish the agent

pac copilot publish --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --id 0c4a9729-d55d-483c-8ec3-db9369583155

If 409 conflict occurs again, check:
pac copilot list --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56
If it shows Published=true, the publish may have succeeded despite the 409.

---

TASK 5 — Validate via API

After all tasks, export the bot and verify:
pac copilot export --environment e2d10003-4d8e-e007-9d63-76d5fe89ef56 --id 0c4a9729-d55d-483c-8ec3-db9369583155 --outputDirectory .planning/comms/g4_portal_export

Also query bot components to verify:
GET https://colofertasbrasilpro.crm4.dynamics.com/api/data/v9.2/botcomponents?$filter=_bot_botid_value eq '0c4a9729-d55d-483c-8ec3-db9369583155'&$select=name,componenttype,content,schemaname

---

Deliverables:
1. Instructions set (verified via export or API query)
2. SharePoint knowledge source bound (verified via API query)
3. EscalarRiscoCritico + RegistrarDecisaoBoard bound as tools
4. Agent published
5. Export as evidence

Update logs:
- .planning/comms/SUB3_CS_LOG.md
- .planning/comms/CODEX_LEAD_LOG.md
- .planning/comms/GATE_STATUS.md
- Create .planning/comms/OPUS_HANDOFF_G4_COMPLETE.md
```
