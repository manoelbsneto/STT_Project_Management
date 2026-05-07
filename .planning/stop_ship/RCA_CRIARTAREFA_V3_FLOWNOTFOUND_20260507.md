# RCA - Assistente PMO V2 CriarTarefa / FlowNotFound / V3 Stabilization

Date: 2026-05-07
Owner: Codex
Audience: Principal Architect / Opus 4.6 / Power Platform reviewers
Severity: SEV-0 stop-ship

## Executive Summary

The `Assistente PMO V2` bot could not reliably execute the `CriarTarefa` path. The original failure was `FlowNotFound` for the flow `Clean_PMO_PA_CriarTarefa` (`42d9abd1-8849-f111-bec7-7ced8d955c6c`) even though the flow existed, was active, and had the correct Copilot-compatible trigger/response shape.

The core finding is that Dataverse/PAC-level bindings are not sufficient to make a Power Automate flow callable as a Copilot Studio tool at runtime. A tool created/imported programmatically can appear partially present in Dataverse while the Copilot Studio runtime still cannot resolve it. Creating a new agent flow through the Copilot Studio UI registered the flow correctly and removed `FlowNotFound`.

Current state:

- `FlowNotFound` is resolved for UI-created `PMO_PA_CriarTarefa_V3`.
- The `CriarTarefa` topic can call V3 and receive `Fluxo V3 chamado com sucesso.`
- The V3 flow is still a stub and does not yet write to SharePoint.
- Programmatic SharePoint verification found no test records in `Tarefas`.
- The previous `Clean_PMO_PA_CriarTarefa` logic writes to `Projetos`, not `Tarefas`, which must be clarified before copying production logic into V3.

## Environment

| Item | Value |
|---|---|
| Environment ID | `e2d10003-4d8e-e007-9d63-76d5fe89ef56` |
| Environment Name | `ColOfertasBrasilPro` |
| Solution | `PMO v1.1 - Task Management Topics` / `PMO_v11_Tarefas` |
| Bot | `Assistente PMO V2` |
| Bot ID | `df148bf8-0a3e-495b-80c4-841dcb61d9a4` |
| Broken flow | `Clean_PMO_PA_CriarTarefa` |
| Broken flow workflow ID | `42d9abd1-8849-f111-bec7-7ced8d955c6c` |
| New UI-created flow | `PMO_PA_CriarTarefa_V3` |
| New V3 workflow ID | `3104124d-364a-f111-bec7-7ced8d955c6c` |
| Required model for bot | `GPT-4.1` |
| Problematic model observed | `GPT-5 Chat` |
| SharePoint site | `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital` |

No credentials are documented in this RCA.

## Timeline

### 1. Initial Stop-Ship

The handoff stated that `Assistente PMO V2` could not invoke `CriarTarefa` because Copilot Studio showed the action as deleted or inaccessible:

```text
O fluxo foi excluído
```

Runtime error during test:

```text
The flow with id 42d9abd1-8849-f111-bec7-7ced8d955c6c was not found in the bot definition.
Error code: FlowNotFound.
```

### 2. Flow Inspection

`Clean_PMO_PA_CriarTarefa` was inspected from Dataverse/solution export.

Findings:

- Flow exists.
- Flow is active.
- Trigger is `Request` with `kind: Skills`.
- Responses are `Response` with `kind: Skills`.
- Flow is in the same environment as the bot.
- Flow was in the solution.

Conclusion: the flow definition itself was not the root cause of invisibility/runtime failure.

### 3. PAC/Dataverse Binding Attempt

An attempted programmatic fix was made by exporting/unpacking `PMO_v11_Tarefas`, adding/adjusting a V2 action component and `botcomponent_workflow` binding, then importing the solution again.

Artifacts created:

- `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627.zip`
- `.planning/stop_ship/live_export/PMO_v11_Tarefas_live_20260507_132627_unpacked/`
- `.planning/stop_ship/live_export/PMO_v11_Tarefas_V2_CriarTarefa_FIX_20260507_1335.zip`
- `.planning/stop_ship/live_export/PMO_v11_Tarefas_V2_CriarTarefa_FIX_NO_OUTPUT_20260507_1339.zip`
- `.planning/stop_ship/v2_criartarefa_components_after_fix_20260507_1335.txt`
- `.planning/stop_ship/v2_criartarefa_bindings_after_fix_20260507_1335.txt`
- `.planning/stop_ship/v2_copilot_list_after_publish_20260507_1335.txt`

Result:

- Dataverse showed a binding from V2 action to `42d9abd1-...`.
- Copilot Studio UI still showed the tool as broken/deleted/inaccessible.
- Runtime still returned `FlowNotFound`.

Conclusion: Dataverse binding alone does not register the tool in the Copilot Studio runtime registry.

### 4. Opus / Advisor Analysis

Opus 4.6 analysis proposed several alternatives:

1. Create a new flow via Copilot Studio UI.
2. Delete and re-add existing flow via UI.
3. Patch solution metadata via PAC.
4. Force sync via publish/cache invalidation.
5. Save As / clone and re-register.

Recommended path was the UI-created agent flow because it populates the Copilot Studio runtime registration, not only Dataverse rows.

### 5. Manual UI Fix - V3 Flow Creation

A new agent flow was created manually in Copilot Studio:

```text
PMO_PA_CriarTarefa_V3
```

Observed workflow ID from URL:

```text
3104124d-364a-f111-bec7-7ced8d955c6c
```

Inputs created in the UI:

| UI Label | Intended Field |
|---|---|
| Texto | `nomeProjeto` |
| Texto 1 | `titulo` |
| Texto 2 | `responsavel` |
| Texto 3 | `prazo` |
| Número | `horas` |
| Texto 4 | `prioridade` |

Output:

| Output | Value |
|---|---|
| `result` | `Fluxo V3 chamado com sucesso.` |

The V3 flow was published successfully.

### 6. Topic Rebinding To V3

The `CriarTarefa` topic was edited in Copilot Studio to call `PMO_PA_CriarTarefa_V3`.

Mapping used:

| Flow input | Topic/global value |
|---|---|
| `Texto` / `text` | `Global.PMO_Criar_Title` |
| `Texto 1` / `text_1` | `Global.PMO_Criar_Title` |
| `Texto 2` / `text_2` | `Global.PMO_Criar_Responsavel` |
| `Texto 3` / `text_3` | `Global.PMO_Criar_DataFim` |
| `Número` / `number` | `Topic.HorasEstimadas` |
| `Texto 4` / `text_4` | `Global.PMO_Criar_Prioridade` |
| output `result` | `Topic.CriarTarefaResult` |

This removed `FlowNotFound` for V3.

### 7. Topic/YAML Stabilization

The topic code was improved through the Copilot Studio code editor, not PAC.

Goals:

- Better trigger recognition.
- Parse long structured messages.
- Accept `sim` as confirmation.
- Return the flow result.
- End topic after success/cancellation.

Important discoveries:

- `BooleanPrebuiltEntity` behaved poorly for pt-BR in this bot because the bot language/model behavior favored English confirmation (`yes`) over `sim`.
- Replacing the confirmation capture with `StringPrebuiltEntity` and explicit text matching made `sim` work.
- `EndDialog` with `clearTopicQueue: true` is needed to prevent the topic from continuing and asking `Qual o titulo da tarefa?` after success.
- First message after publish can still fall back until a new test session/published cache stabilizes.

Recommended test message:

```text
criar tarefa: Teste Validacao PMO 999, responsavel=Manoel Benicio, prazo=31/05/2026, horas=8, prioridade=Alta
```

Confirmation:

```text
sim
```

### 8. Model Finding

The user observed that when the bot model was `GPT-5 Chat`, topic routing failed more frequently. After switching back to `GPT-4.1`, routing and tool behavior improved.

Decision:

```text
Assistente PMO V2 must stay on GPT-4.1 for now.
```

This is a production constraint until model-specific routing behavior is retested.

### 9. SharePoint Verification

Programmatic read-only verification was run against SharePoint list `Tarefas`.

Result:

```json
{
  "List": "Tarefas",
  "ItemCount": 3,
  "MatchCount": 0,
  "Matches": []
}
```

Recent `Tarefas` items:

```text
ID  Title                    ProjectID       Responsavel              Horas  Prioridade
3   Teste Projeto Inexistente PRJ-NO-MATCH   mbenicios@minsait.com    1      Alta
2   Revisao tecnica           PRJ-2127A0E4   mbenicios@minsait.com    4      Media
1   Preparar proposta         PRJ-2127A0E4   mbenicios@minsait.com    8      Alta
```

No items were found for:

- `Teste Validacao PMO`
- `888888888`
- `77777777777777`

Conclusion:

```text
V3 is callable but is still a stub. It does not write to SharePoint yet.
```

## Subagent Findings

### Flow Logic Mapper

The old `Clean_PMO_PA_CriarTarefa` flow does not create items in `Tarefas`. It creates/uses the `Projetos` SharePoint list.

Important old-flow behavior:

- Trigger: `Request` / `Skills`
- Duplicate lookup: `Projetos`
- Create action: `PostItem` in `Projetos`
- Fields used:
  - `Title`
  - `ProjectID`
  - `NomeProjeto`
  - `StatusRAG/Value`
  - `Percentual`
  - `Ativo`
  - `PM/Claims`
  - `DataAlvo`
  - `UltimaAtualizacao`
  - `Prioridade/Value`
  - `ResumoExecutivo`
- Response success:
  - `Projeto <nome> criado com codigo <ProjectID>.`

Risk:

The topic is named `CriarTarefa`, but the old flow creates `Projetos`. The desired target must be clarified: `Projetos`, `Tarefas`, or both.

### Topic/YAML Auditor

Findings:

- `EndDialog` should be explicit after success and cancel.
- Trigger phrases should include realistic STT phrases, not only short keywords.
- There is ghost/duplicate risk because `Assistente PMO Clean` and `Assistente PMO V2` both exist.
- Do not use direct PAC re-registration for tool actions.

### SharePoint Evidence Runner

Recommended read-only verification:

- Use Windows PowerShell 5.1.
- Use `SharePointPnPPowerShellOnline` 3.29.
- Query `Projetos` and `Tarefas`.
- List recent records and search by title.
- Optionally query Power Automate run history through PowerApps module / `InvokeApi`.

## Root Cause

### Primary Root Cause

The broken `PMO_PA_CriarTarefa` tool/action was registered through solution/Dataverse/PAC operations but was not properly registered in the Copilot Studio runtime tool registry.

Evidence:

- Dataverse binding existed.
- Flow existed and was active.
- Trigger and response were correct.
- Copilot Studio UI still showed the tool as deleted/inaccessible.
- Runtime returned `FlowNotFound`.
- UI-created V3 flow/tool became callable immediately.

### Secondary Root Causes

1. **Bot/topic routing sensitivity**
   - GPT-5 Chat showed weaker routing behavior than GPT-4.1.
   - First test message after publish can hit stale routing/cache.

2. **Language mismatch for confirmation**
   - `BooleanPrebuiltEntity` recognized `yes` more reliably than `sim`.
   - Fixed by using text confirmation and explicit condition checks.

3. **Topic completion missing/uncertain**
   - Without explicit `EndDialog`, the bot could continue and ask for title again after success.

4. **Ambiguous business contract**
   - `CriarTarefa` name suggests list `Tarefas`.
   - Old `Clean_PMO_PA_CriarTarefa` creates records in `Projetos`.
   - SharePoint verification of `Tarefas` shows V3 does not create tasks yet.

5. **Ghost bot / duplicate solution components**
   - `Assistente PMO Clean` and `Assistente PMO V2` coexist.
   - This increases operational confusion and risk of editing/testing the wrong component.

## What Worked

- Creating `PMO_PA_CriarTarefa_V3` from Copilot Studio UI.
- Binding the topic to V3 from Copilot Studio UI.
- Using GPT-4.1.
- Using explicit string confirmation for `sim`.
- Using full YAML replacement through the code editor instead of partial UI patching.
- Programmatic SharePoint verification via legacy PnP module.

## What Did Not Work

- PAC/solution import to repair runtime tool registration.
- Assuming Dataverse `botcomponent_workflow` binding was enough.
- Using `BooleanPrebuiltEntity` for pt-BR confirmation.
- Testing old conversations after publish without starting a new test session.
- Assuming `Fluxo V3 chamado com sucesso.` meant SharePoint write succeeded.

## Current Full Topic Direction

The current preferred topic design is:

- `OnRecognizedIntent`
- expanded `triggerQueries`
- `Topic.RawInput = System.Activity.Text`
- parse fields from long user message
- ask only missing fields
- confirmation as string
- if confirmed:
  - set globals
  - invoke V3
  - send `Topic.CriarTarefaResult`
  - `EndDialog clearTopicQueue: true`
- else:
  - cancellation message
  - `EndDialog clearTopicQueue: true`

## Open Decisions For Architect

1. Should `CriarTarefa` create an item in `Tarefas`, `Projetos`, or both?

2. If creating in `Tarefas`, what is the required `ProjectID` behavior?
   - User supplies an existing project?
   - Flow creates a new project first?
   - Flow creates a standalone task with generated `ProjectID`?

3. Should `Responsavel` be stored as:
   - plain text,
   - email,
   - SharePoint person field claims,
   - or resolved through directory lookup?

4. Should duplicate prevention apply to:
   - project name/date,
   - task title/date/responsavel,
   - or no duplicate prevention?

5. Should `CriarTarefa` be renamed to `CriarProjeto` if the business intent is project creation?

## Recommended Next Steps

### Step 1 - Decide Target List

Pick one:

- Option A: V3 creates in `Projetos`, matching old flow.
- Option B: V3 creates in `Tarefas`, matching topic name and T-007.
- Option C: V3 creates in both `Projetos` and `Tarefas`.

Recommendation:

```text
Use `Tarefas` for CriarTarefa. Use a separate CriarProjeto topic/flow for Projetos.
```

### Step 2 - Implement Real V3 Logic

Do this inside the UI-created V3 flow, preserving its Copilot Studio runtime registration.

Required V3 final response should be something like:

```text
Tarefa criada com sucesso. TaskID: TASK-XXXX. ProjectID: PRJ-XXXX.
```

### Step 3 - Programmatic Verification

After running the bot test, query SharePoint:

- list `Tarefas`
- title contains test marker
- confirm fields populated

### Step 4 - Cleanup

After V3 is stable:

- remove `Assistente PMO Clean` from the solution, not delete it.
- keep `Assistente PMO V2` as the active bot.
- document GPT-4.1 as required model.

## Useful Commands / Evidence Patterns

Read-only SharePoint verification pattern:

```powershell
$ErrorActionPreference = "Stop"
$env:PNPLEGACYMESSAGE = "false"
$siteUrl = "https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital"

Import-Module SharePointPnPPowerShellOnline -RequiredVersion 3.29.2101.0 -ErrorAction Stop
Connect-PnPOnline -Url $siteUrl -UseWebLogin

$items = Get-PnPListItem -List "Tarefas" -PageSize 100
$items | Where-Object {
  ([string]$_.FieldValues["Title"]) -like "*Teste Validacao PMO*"
} | ForEach-Object {
  [pscustomobject]@{
    ID = $_.Id
    Title = $_.FieldValues["Title"]
    ProjectID = $_.FieldValues["ProjectID"]
    Responsavel = $_.FieldValues["Responsavel"]
    DataFim = $_.FieldValues["DataFim"]
    HorasEstimadas = $_.FieldValues["HorasEstimadas"]
    Prioridade = $_.FieldValues["Prioridade"]
  }
}
```

## Final Status

| Item | Status |
|---|---|
| FlowNotFound on old `42d9...` | Avoided, not fixed in-place |
| UI-created V3 callable | Pass |
| Topic routes after retry/new session | Partial pass |
| `sim` confirmation | Pass |
| Topic returns V3 result | Pass |
| Topic should end after success | YAML includes recommended `EndDialog`; verify after publish |
| SharePoint `Tarefas` item created | Fail / not implemented |
| Production ready | No |

## Bottom Line

The SEV-0 runtime binding issue was bypassed correctly by creating a Copilot Studio UI-native V3 flow. The remaining work is not a Copilot runtime binding problem anymore. It is now a business logic implementation task: replace the V3 stub with real SharePoint write logic, using the agreed target list and fields.

