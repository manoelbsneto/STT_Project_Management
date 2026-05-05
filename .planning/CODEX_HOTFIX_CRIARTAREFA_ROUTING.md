# CODEX HOTFIX — CriarTarefa Topic Not Routing (Intent Recognition Failure)

> **Priority:** P0 — Bot returns "Não entendi bem" for all CriarTarefa inputs
> **Author:** Senior Solutions Architect
> **Executor:** Codex (Principal Deployment Engineer)
> **Date:** 2026-05-05
> **Commit Baseline:** `09f70f7` (Deploy CriarTarefa flow and copilot patch)

---

## PROBLEM

The Copilot Studio bot `Assistente PMO` does NOT recognize "Criar tarefa: ..." inputs.
Instead of routing to the CriarTarefa topic, it falls through to LowConfidence fallback:

> "Não entendi bem. Você pode reformular? Posso ajudar com: atualizar status, consultar portfólio, registrar risco, solicitar decisão."

**Screenshot confirmed by user** — the bot cannot match the intent.

---

## ROOT CAUSE (3 issues)

### RC1: `includeInOnSelectIntent: false` on CriarTarefa topic
Line 841 in the extracted template:
```yaml
intent:
  displayName: CriarTarefa
  includeInOnSelectIntent: false   # ← THIS IS THE BLOCKER
```
When `GenerativeActionsEnabled: true`, the Generative Orchestrator uses `OnSelectIntent` to decide which topic to route to. If `includeInOnSelectIntent` is `false`, the orchestrator **skips this topic entirely**. It will never be selected.

**Fix:** Set `includeInOnSelectIntent: true`

### RC2: Insufficient trigger phrases
Current trigger phrases (line 842-846):
```yaml
triggerQueries:
  - criar tarefa
  - nova tarefa
  - adicionar tarefa
  - cadastrar tarefa
```
The user sends: `"Criar tarefa: Título=Agente Qualificação de Ofertas, Responsável=Manoel Benicio, Prazo=2026-06-30, Horas=336, Prioridade=Alta"`

The NLU needs more coverage for variations PMs will actually use.

**Fix:** Add these trigger phrases:
```yaml
triggerQueries:
  - criar tarefa
  - nova tarefa
  - adicionar tarefa
  - cadastrar tarefa
  - criar projeto
  - novo projeto
  - abrir projeto
  - registrar projeto
  - criar tarefa:
  - abrir tarefa
```

### RC3: LowConfidence fallback message is outdated
Line 299:
```yaml
activity: "Não entendi bem. Você pode reformular? Posso ajudar com: atualizar status, consultar portfólio, registrar risco, solicitar decisão."
```
It does NOT list "criar tarefa" or "criar projeto" as available capabilities.

**Fix:** Update to:
```yaml
activity: "Não entendi bem. Você pode reformular? Posso ajudar com: criar tarefa/projeto, atualizar status, consultar portfólio, registrar risco, solicitar decisão."
```

### RC4: CriarTarefa topic still asks for ProjectID
Lines 848-853:
```yaml
- kind: Question
  id: ask_projectid
  variable: Topic.ProjectID
  prompt: "Qual o código do projeto? (ex: PRJ-001)"
  entity: StringPrebuiltEntity
```
The flow auto-generates ProjectID. This question node must be **removed**.

---

## EXECUTION PLAN

Create a new script `deploy/CS_CriarTarefa_Hotfix.ps1` that:

1. Extracts the current bot template via `pac copilot extract-template`
2. Patches the YAML programmatically (all 4 fixes)
3. Imports the patched template via `pac copilot import-template`
4. Publishes via `pac copilot publish`
5. Extracts again to verify

### Implementation

```powershell
# Script: deploy/CS_CriarTarefa_Hotfix.ps1
# Parameters: EnvironmentName, BotId (same defaults as other scripts)

# Step 1: Extract current template
pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFile $extractPath --overwrite

# Step 2: Read YAML, apply 4 fixes via string replacement:

# FIX 1: includeInOnSelectIntent on CriarTarefa topic
# Find the CriarTarefa topic block and change includeInOnSelectIntent: false → true
# IMPORTANT: Only change it in the CriarTarefa topic block, not in other topics

# FIX 2: Add trigger phrases to CriarTarefa topic
# Replace the triggerQueries block under CriarTarefa with expanded list

# FIX 3: Update LowConfidence fallback message
# Replace the old message with new one that includes "criar tarefa/projeto"

# FIX 4: Remove the ask_projectid Question node from CriarTarefa topic
# Delete the Question block with id: ask_projectid
# Also remove any reference to Topic.ProjectID in the confirmation prompt
# Update the confirmation prompt to NOT mention ProjectID
# Remove SetVariable for Global.PMO_Criar_ProjectID

# Step 3: Import patched template
pac copilot import-template --environment $EnvironmentName --bot $BotId --templateFile $patchedPath

# Step 4: Publish
pac copilot publish --environment $EnvironmentName --bot $BotId

# Step 5: Extract again to verify
pac copilot extract-template --environment $EnvironmentName --bot $BotId --templateFile $verifyPath --overwrite
```

### Exact YAML Patches

#### PATCH 1: CriarTarefa includeInOnSelectIntent
```diff
     intent:
       displayName: CriarTarefa
-      includeInOnSelectIntent: false
+      includeInOnSelectIntent: true
```

#### PATCH 2: CriarTarefa trigger phrases
```diff
       triggerQueries:
         - criar tarefa
         - nova tarefa
         - adicionar tarefa
         - cadastrar tarefa
+        - criar projeto
+        - novo projeto
+        - abrir projeto
+        - registrar projeto
+        - criar tarefa:
+        - abrir tarefa
```

#### PATCH 3: LowConfidence fallback
```diff
-    activity: "Não entendi bem. Você pode reformular? Posso ajudar com: atualizar status, consultar portfólio, registrar risco, solicitar decisão."
+    activity: "Não entendi bem. Você pode reformular? Posso ajudar com: criar tarefa/projeto, atualizar tarefa, atualizar status, consultar portfólio, consultar projeto, listar tarefas, registrar risco, registrar bloqueio, solicitar decisão."
```

#### PATCH 4: Remove ask_projectid from CriarTarefa
Remove the entire block:
```yaml
          - kind: Question
            id: ask_projectid
            variable: Topic.ProjectID
            prompt: "Qual o código do projeto? (ex: PRJ-001)"
            entity: StringPrebuiltEntity
```

And update the confirmation prompt from:
```yaml
              Vou criar a tarefa '{Topic.Title}' no projeto {Topic.ProjectID}.
              Responsável: {Topic.Responsavel}
              Prazo: {Topic.DataFim}
              Horas: {Topic.HorasEstimadas}h
              Prioridade: {Topic.Prioridade}
```
To:
```yaml
              Vou criar a tarefa '{Topic.Title}'.
              Responsável: {Topic.Responsavel}
              Prazo: {Topic.DataFim}
              Horas: {Topic.HorasEstimadas}h
              Prioridade: {Topic.Prioridade}
              (O código do projeto será gerado automaticamente)
```

And update the success message from:
```yaml
              Tarefa criada com sucesso.

              Projeto: {Topic.ProjectID}
              Título: {Topic.Title}
```
To:
```yaml
              Tarefa criada com sucesso.

              Título: {Topic.Title}
```

And remove the SetVariable for ProjectID:
```yaml
                  - kind: SetVariable
                    id: set_global_projectid
                    variable: Global.PMO_Criar_ProjectID
                    value: =Topic.ProjectID
```

---

## ENVIRONMENT

```
Environment ID:  e2d10003-4d8e-e007-9d63-76d5fe89ef56
Bot ID:          0c4a9729-d55d-483c-8ec3-db9369583155
Bot Schema:      pmo_AssistentePMO
PAC CLI version: 2.6.4 (updated by Codex in previous deployment)
```

---

## VERIFICATION

After publishing, extract the template and confirm:

1. ✅ CriarTarefa topic has `includeInOnSelectIntent: true`
2. ✅ CriarTarefa has 10 trigger phrases (including "criar projeto", "abrir projeto")
3. ✅ LowConfidence message includes "criar tarefa/projeto"
4. ✅ CriarTarefa topic does NOT have `ask_projectid` Question node
5. ✅ Confirmation prompt does NOT reference `{Topic.ProjectID}`
6. ✅ No `set_global_projectid` SetVariable action

---

## IMPORTANT CONSTRAINTS

- Use `pac copilot extract-template` and `pac copilot import-template` — NOT solution import
- The template is YAML — use PowerShell string operations to patch (Get-Content -Raw, -replace, Set-Content)
- Back up the original extracted template before patching
- Evidence goes to `.planning/comms/`
- Commit after successful verification
- Do NOT modify any other topics — only CriarTarefa and LowConfidence
