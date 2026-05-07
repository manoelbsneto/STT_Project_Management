# 🚨 SEV-0 HANDOFF: Assistente PMO V2 — CriarTarefa Flow Binding Failure

**Priority**: SEV-0 STOP-SHIP  
**Date**: 2026-05-07  
**Assigned To**: Codex  
**Handoff From**: Antigravity (pair programming session with Manoel Benicio)

---

## 1. EXECUTIVE SUMMARY

The **Assistente PMO V2** Copilot bot cannot invoke the `CriarTarefa` (Create Task) action because the Power Automate flow `Clean_PMO_PA_CriarTarefa` is **invisible** to Copilot Studio's tool picker. The flow exists in the solution and Dataverse, but does NOT appear when adding a tool in Copilot Studio. This is a **production blocker**.

---

## 2. ENVIRONMENT

| Item | Value |
|---|---|
| **Environment ID** | `e2d10003-4d8e-e007-9d63-76d5fe89ef56` |
| **Solution** | `PMO v1.1 - Task Management Topics` |
| **Bot** | `Assistente PMO V2` (ID: `df148bf8-0a3e-495b-80c4-841dcb61d9a4`) |
| **Broken Flow** | `Clean_PMO_PA_CriarTarefa` (Dataverse ID: `42d9abd1-...`) |
| **Copilot Studio URL** | `https://copilotstudio.microsoft.com/environments/e2d10003-4d8e-e007-9d63-76d5fe89ef56/bots/df148bf8-0a3e-495b-80c4-841dcb61d9a4` |
| **Power Automate URL** | `https://make.powerautomate.com/environments/e2d10003-4d8e-e007-9d63-76d5fe89ef56/solutions` |

---

## 3. ROOT CAUSE ANALYSIS

### 3.1 What Happened
1. Original flow `PMO_PA_CriarTarefa` (ID: `71f62da4-...`) was **deleted** during cleanup.
2. A replacement flow `Clean_PMO_PA_CriarTarefa` (ID: `42d9abd1-...`) was created and added to the solution.
3. Dataverse audit confirms the bot's `botcomponent_workflow` binding CORRECTLY points to `42d9abd1-...` (the clean flow).
4. **HOWEVER**, Copilot Studio UI shows "O fluxo foi excluído" (The flow was deleted) on the action `PMO_PA_CriarTarefa`.
5. When attempting to re-add the flow via "Adicionar uma ferramenta" in Copilot Studio, `Clean_PMO_PA_CriarTarefa` does **NOT appear** in any tab (Ferramentas básicas, Conector, Ferramenta, Fluxo).

### 3.2 Probable Root Cause (Per Microsoft Official Docs)
Based on Microsoft documentation research, a Power Automate flow will **NOT appear** in Copilot Studio's tool picker unless ALL of these conditions are met:

| Requirement | Status | Notes |
|---|---|---|
| **Trigger**: Must be `"When an agent calls the flow"` (Quando um agente chama o fluxo) | ⚠️ **UNVERIFIED** | This is the most likely failure point. Must inspect the flow's trigger block. |
| **Response**: Must end with `"Respond to the agent"` (Responder ao agente) | ⚠️ **UNVERIFIED** | Must inspect the flow's last action. |
| In a Solution | ✅ Confirmed | Flow is in `PMO v1.1` solution |
| Same Environment as bot | ✅ Confirmed | Both in `e2d10003-...` |
| Flow is saved and activated | ✅ Confirmed | Dataverse shows `statecode=1` (Activated) |
| Flow not in draft state | ⚠️ **UNVERIFIED** | Must verify |

### 3.3 Secondary Issues
- **Ghost Bot Conflict**: Solution contains TWO bots (`Assistente PMO Clean` + `Assistente PMO V2`) sharing the same flows — an anti-pattern per Microsoft guidelines. The old bot should be removed from the solution.

---

## 4. TASKS TO EXECUTE (IN ORDER)

### TASK 1: Inspect Flow Trigger Type
**Priority**: CRITICAL — this determines the entire fix path.

```
Steps:
1. Go to: https://make.powerautomate.com
2. Navigate to Solution "PMO v1.1 - Task Management Topics"
3. Open flow "Clean_PMO_PA_CriarTarefa"
4. Inspect the TRIGGER block (first block in the flow)
5. Document: What is the trigger type?
   - Expected: "When an agent calls the flow" / "Run a flow from Copilot"
   - Problem: Any other trigger type (Manual, HTTP, Scheduled, etc.)
6. Inspect the LAST action block
   - Expected: "Respond to the agent" / "Return value(s) to Power Virtual Agents"
   - Problem: Any other response type or no response at all
```

### TASK 2: Fix Flow Trigger (If Wrong)
**If trigger is NOT "When an agent calls the flow":**

**Option A — Edit existing flow:**
```
1. Open Clean_PMO_PA_CriarTarefa in edit mode
2. Delete the existing trigger
3. Add trigger: "When an agent calls the flow"
4. Configure inputs:
   - text (string) → Title
   - text_1 (string) → Responsavel
   - text_2 (string) → DataFim
   - number (number) → HorasEstimadas
   - text_3 (string) → Prioridade
5. Keep all middle logic intact (SharePoint create item, etc.)
6. Replace last action with: "Respond to the agent"
7. Configure outputs:
   - text (string) → ProjectID
   - text_1 (string) → message
8. Save and activate
```

**Option B — Create new flow from Copilot Studio (safest):**
```
1. Go to Copilot Studio → Assistente PMO V2 → Ferramentas
2. Click "+ Adicionar uma ferramenta"
3. Select "Novo fluxo do Agente" (New Agent flow)
4. This creates a flow with the CORRECT trigger automatically
5. Name it: PMO_PA_CriarTarefa_V3
6. Add the SharePoint "Create Item" action with the same logic as Clean_PMO_PA_CriarTarefa
7. Configure inputs/outputs as above
8. Save → it will automatically appear in the bot's tools
```

### TASK 3: Remove Ghost Bot from Solution
```
1. Go to Power Automate → Solution "PMO v1.1"
2. Find "Assistente PMO Clean" in the Agents section
3. Click ⋮ → "Remove" (remove from solution, do NOT delete)
4. Confirm
```

### TASK 4: Re-link Action in CriarTarefa Topic
```
1. Go to Copilot Studio → Assistente PMO V2 → Tópicos → CriarTarefa
2. After the last SetVariable (Global.PMO_Criar_Prioridade), click "+"
3. Select "Adicionar uma ferramenta" → select the fixed/new flow
4. Map inputs:
   - text → Global.PMO_Criar_Title
   - text_1 → Global.PMO_Criar_Responsavel
   - text_2 → Global.PMO_Criar_DataFim
   - number → Global.PMO_Criar_HorasEstimadas
   - text_3 → Global.PMO_Criar_Prioridade
5. Save topic
```

### TASK 5: Configure System Prompt (Instructions)
```
1. Go to Visão Geral → Instruções → Editar
2. Paste the system prompt (see Section 6 below)
3. Save
```

### TASK 6: Publish and Test (T-007)
```
1. Click "Publicar"
2. Wait for completion
3. Open test chat panel
4. Type: "criar tarefa: titulo=Teste Validacao PMO, responsavel=Manoel Benicio, prazo=31/05/2026, horas=8, prioridade=Alta"
5. Expected: Bot asks for confirmation → user confirms → flow executes → returns ProjectID
6. Test cancellation: respond "não" → expect "criação cancelada"
```

---

## 5. TOPIC YAML REFERENCE (CriarTarefa)

The action call node should be:
```yaml
- kind: BeginDialog
  id: call_criar_tarefa
  input: {}
  dialog: pmo_AssistentePMO_V2.action.PMO_PA_CriarTarefa
```

The action definition should be:
```yaml
- kind: DialogComponent
  displayName: PMO_PA_CriarTarefa
  description: Acao vinculada ao fluxo Power Automate - cria tarefa e gera ProjectID automaticamente.
  schemaName: template-content.action.PMO_PA_CriarTarefa
  dialog:
    kind: TaskDialog
    inputs:
      - kind: ManualTaskInput
        propertyName: text
        value: =Global.PMO_Criar_Title
      - kind: ManualTaskInput
        propertyName: text_1
        value: =Global.PMO_Criar_Responsavel
      - kind: ManualTaskInput
        propertyName: text_2
        value: =Global.PMO_Criar_DataFim
      - kind: ManualTaskInput
        propertyName: number
        value: =Global.PMO_Criar_HorasEstimadas
      - kind: ManualTaskInput
        propertyName: text_3
        value: =Global.PMO_Criar_Prioridade
    output: {}
```

---

## 6. SYSTEM PROMPT (Instructions)

```
Voce e o Assistente PMO V2, um agente de IA para gestao de portfolio de projetos da equipe de Transformacao Digital da Minsait/Indra.

Regras:
1. Responda SEMPRE em portugues do Brasil (pt-BR).
2. Use APENAS dados das listas SharePoint do PMO (Projetos, Tarefas, Status Diario, Riscos e Bloqueios, Decisoes do Board).
3. NUNCA invente dados. Se nao encontrar informacao, diga 'Nao encontrei essa informacao nas listas do PMO.'
4. Para QUALQUER operacao de escrita (criar tarefa, atualizar tarefa, atualizar status, registrar risco, pedir decisao), SEMPRE confirme com o usuario antes de executar.
5. NAO pesquise na internet. NAO use conhecimento generico.
6. Formate respostas com emojis para status: 🟢 Verde, 🟡 Amarelo, 🔴 Vermelho.
7. Seja conciso e direto.
8. Quando o usuario pedir para criar tarefa ou projeto, use o topico CriarTarefa.
9. Quando o usuario pedir para atualizar uma tarefa existente, use o topico AtualizarTarefa.
10. Quando o usuario pedir para listar tarefas, use o topico ListarTarefas.
```

---

## 7. ALL 6 FLOWS REFERENCE

| # | Flow Name | Dataverse ID | Status |
|---|---|---|---|
| 1 | Clean_PMO_PA_CriarTarefa | `42d9abd1-...` | ✅ Active — **TRIGGER UNVERIFIED** |
| 2 | Clean_PMO_PA_AtualizarTarefa | verified | ✅ Active + Working |
| 3 | Clean_PMO_PA_ListarTarefas | verified | ✅ Active + Working |
| 4 | Clean_PMO_PA_RegistrarDecisaoBoard | verified | ✅ Active + Working |
| 5 | Clean_PMO_PA_EscalarRiscoCritico | verified | ✅ Active + Working |
| 6 | Clean_PMO_PA_CheckInOnDemand | verified | ✅ Active + Working |

---

## 8. MICROSOFT OFFICIAL REQUIREMENTS (SOURCE)

Per Microsoft documentation, for a flow to appear in Copilot Studio tool picker:

1. **Trigger MUST be**: `"When an agent calls the flow"` (previously "When Power Virtual Agents calls a flow")
2. **Last action MUST be**: `"Respond to the agent"` (previously "Return value(s) to Power Virtual Agents")
3. Flow MUST be inside a **Solution**
4. Flow MUST be in the **same environment** as the bot
5. Flow MUST be **saved and activated** (not draft)
6. Flow license type should be set to **"Copilot Studio"** if applicable

Source: [Microsoft Learn - Use Power Automate flows in Copilot Studio](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-flow)

---

## 9. ACCEPTANCE CRITERIA

- [ ] Flow `Clean_PMO_PA_CriarTarefa` appears in Copilot Studio tool picker
- [ ] CriarTarefa topic correctly calls the flow action
- [ ] T-007 test passes: bot creates task via flow without FlowNotFound error
- [ ] T-007 cancellation test passes: user says "não" → creation cancelled
- [ ] Bot is published successfully
- [ ] `Assistente PMO Clean` removed from solution
- [ ] System prompt configured in Instruções

---

## 10. FILES AND ARTIFACTS

| File | Path | Purpose |
|---|---|---|
| Template YAML | `.planning/stop_ship/AssistentePMO_V2_TEMPLATE.yaml` | Full bot definition reference |
| Master Checklist | `.planning/stop_ship/MASTER_CHECKLIST.md` | Overall progress tracker |
| Test Report | `.planning/stop_ship/OPUS_MANUAL_TEST_REPORT.md` | Previous test results (T-001 to T-007) |
| Bot Components | `.planning/stop_ship/rnd_botcomponents_by_parent_20260506.txt` | Dataverse component inventory |
| Workflow Bindings | `.planning/stop_ship/rnd_workflow_bindings_by_parent_20260506.txt` | Dataverse flow binding audit |

---

**END OF HANDOFF — Codex, please execute TASK 1 immediately and report findings.**
