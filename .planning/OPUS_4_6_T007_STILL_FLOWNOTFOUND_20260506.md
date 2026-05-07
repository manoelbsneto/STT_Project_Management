# Opus 4.6 Update - T-007 Still FlowNotFound After Clean Schema Fix

Date: 2026-05-06

Environment: `ColOfertasBrasilPro`

Bot: `Assistente PMO Clean`

Bot ID: `77cfb838-6ed1-4488-9e57-ab98751081d3`

Release decision: **NO-SHIP**

## Summary

The old deleted bot schema cleanup is complete, but T-007 still fails at runtime.

The latest user tests in Copilot Studio show the `CriarTarefa` topic is selected, parsing works for the full labeled utterance, and confirmation is reached. After the user replies `sim`, the bot still returns:

```text
O fluxo com a ID 71f62da4-9748-f111-bec7-6045bdf42cae nao foi encontrado na definicao do bot:
FlowNotFound.
```

This happened after the successful publish at `2026-05-06 19:17:20 UTC`.

## Fresh Runtime Evidence From Screenshots

### Attempt 1

Prompt:

```text
Criar tarefa: Titulo=Teste Clean Schema T007 20260506, Responsavel=mbenicios@minsait.com, Prazo=30/06/2026, Horas=336, Prioridade=Alta
```

Result:

- Bot selected `CriarTarefa`.
- Bot parsed all fields.
- Bot asked confirmation.
- User replied `sim`.
- Runtime failed with `FlowNotFound`.
- Conversation ID: `f3290285-3f68-432e-8f87-c90a8c426e60`
- UTC error times shown: `2026-05-06 19:55:19` and `2026-05-06 19:55:40`.

### Attempt 2

Prompt:

```text
Criar tarefa: Agente Qualificacao de Ofertas 9999
```

Result:

- Bot selected `CriarTarefa`.
- Missing-field fallback did not ask for title/responsavel/prazo/horas/prioridade.
- Bot asked confirmation with blank fields.
- User replied `sim`.
- Runtime failed with `FlowNotFound`.
- Conversation ID: `96217359-f3ea-4d2b-ab92-bfbacdba4d3f`
- UTC error times shown: `2026-05-06 19:58:22` and `2026-05-06 19:59:06`.

## Fresh Dataverse Checks After Failure

`pac org fetch` still shows the correct action-level relationship only:

```text
pmo_AssistentePMO_Clean.action.PMO_PA_CriarTarefa -> PMO_PA_CriarTarefa
workflowid = 71f62da4-9748-f111-bec7-6045bdf42cae
workflow state/status = Activado / Activado
```

No topic-level `pmo_AssistentePMO_Clean.topic.CriarTarefa -> workflow` relationship remains.

`pac copilot list` shows:

```text
Assistente PMO Clean
77cfb838-6ed1-4488-9e57-ab98751081d3
Published
Active
Provisioned
```

## Updated RCA

This is no longer primarily an old `pmo_AssistentePMO.*` ghost-reference problem.

The runtime error now points to a Copilot Studio **published bot definition / tool registry** issue:

- The `_Clean` topic calls `_Clean.action.PMO_PA_CriarTarefa`.
- The `_Clean` action data contains `InvokeFlowTaskAction` with `flowId = 71f62da4-9748-f111-bec7-6045bdf42cae`.
- The `botcomponent_workflow` relationship exists and points to the active workflow.
- But the published bot runtime still says that flow is not present in the bot definition.

Most likely, the solution import created Dataverse component rows but did not fully register the flow as a Copilot Studio tool/action in the runtime definition. Microsoft guidance for flow actions says the flow should be added as a tool/action from Copilot Studio, and action nodes should be refreshed after flow changes before saving and republishing.

## New UI Evidence - Tool Details Broken

When opening the topic action node through **Exibir ferramenta**, Copilot Studio shows the tool details page with this banner:

```text
O fluxo foi excluido ou os direitos de acesso foram perdidos
```

The tool details form is also blank/invalid:

- `Nome` is empty and required.
- `Descricao` is empty and required.
- The flow area does not resolve to the real `PMO_PA_CriarTarefa` metadata.

This is now the strongest evidence. The Dataverse rows exist, but Copilot Studio UI cannot hydrate the tool/action definition. That explains why runtime says the flow is not in the bot definition.

Do not save this broken blank tool details page, because it can overwrite or preserve invalid metadata.

After deleting the topic tool block and re-adding `PMO_PA_CriarTarefa` from the **Adicionar uma ferramenta > Ferramenta** picker, the same red banner still appears. Therefore, the picker is only reusing the same broken tool registration. The existing `PMO_PA_CriarTarefa` Copilot tool record should be considered non-repairable from the topic canvas.

## Recommended Next Fix

Use Copilot Studio UI for this step, not PAC-only import.

1. Open `Assistente PMO Clean`.
2. Go to `Topicos > CriarTarefa`.
3. On the action/tool node that calls `PMO_PA_CriarTarefa`, open the node menu.
4. Select **Refresh** if available.
5. Verify inputs match the flow:
   - `nomeProjeto`
   - `titulo`
   - `responsavel`
   - `prazo`
   - `horas`
   - `prioridade`
6. Save the topic.
7. Publish the agent.
8. Start a new test conversation and rerun T-007.

If Refresh is not available or the same error persists:

1. Delete the current `PMO_PA_CriarTarefa` action node from the topic.
2. Add it back through the UI:
   - Add node
   - Add a tool
   - Flow
   - select `PMO_PA_CriarTarefa`
3. Re-map the six inputs from the topic/global variables.
4. Save and publish.
5. Export the solution immediately after a passing test and diff the generated action component data against the current package.

Do **not** restore the topic-level `botcomponent_workflow` binding. The correct model is: topic calls action; action owns the CloudFlow binding.

Because **Exibir ferramenta** now shows the missing/deleted/access-lost banner, the preferred path is to delete and re-add the tool node instead of trying to repair the existing tool page.

Update: re-add from the picker still shows the red banner. Next viable fix is to create a new UI-native agent flow/tool registration, then either migrate the existing CriarTarefa logic into it or call a child flow/reference flow from that new UI-created wrapper.

## Secondary Defect

The missing-field path is not behaving correctly. When the user says:

```text
Criar tarefa: Agente Qualificacao de Ofertas 9999
```

the bot should ask for missing fields. Instead, it reaches confirmation with blank values.

This is lower priority than `FlowNotFound` because the fully labeled T-007 prompt parses correctly, but it should be fixed before release. Likely cause: the `Blank()` values from regex parse are not satisfying the current `IsBlank(Topic.*)` checks in the topic runtime.

## Current Gate

T-007 remains blocked:

- Create path: **FAIL - FlowNotFound**
- Cancel path: **not yet validly tested**
- Missing-field collection: **FAIL**

Release remains **NO-SHIP**.

## New Duplicated Flow Candidate

User duplicated the CriarTarefa flow in Power Automate:

```text
Clean_PMO_PA_CriarTarefa
```

Observed duplicated flow URL ID from screenshot:

```text
953b36ea-972e-ec8b-d050-647eaa918cd4
```

Important correction: the browser URL ID above is not the Dataverse `workflowid`.

FetchXML found the real workflow ID:

```text
42d9abd1-8849-f111-bec7-7ced8d955c6c
```

This flow opens in the Power Automate run panel with the expected agent-trigger inputs:

- `nomeProjeto`
- `titulo`
- `responsavel`
- `prazo`
- `horas`
- `prioridade`

Next validation step is to manually run this duplicated flow from Power Automate. If it succeeds, use this new UI-native/duplicated flow as the Copilot Studio tool instead of the broken `PMO_PA_CriarTarefa` tool registration.

Manual direct run result:

```text
Seu fluxo foi executado com exito.
```

Observed green path:

- `Quando um agente chama o fluxo`
- `Compose NomeProjeto`
- `Compose DataAlvo`
- `Map Prioridade`
- `Get Duplicate Projects`
- `Condition Duplicate Projeto`
- `Compose ProjectID`
- `Create Projeto SharePoint`
- `Response Success`

This proves the duplicated flow is executable and connected to SharePoint. It is now the preferred flow/tool for the next Copilot Studio replacement test.

Before wiring it into Copilot Studio, add `Clean_PMO_PA_CriarTarefa` to the unmanaged solution:

```text
PMO_v11_Tarefas
```

Reason: if the duplicated flow remains outside the solution, Copilot Studio may not expose it reliably as a valid bot tool and the final release export may miss the working flow/tool dependency.

User then added `Clean_PMO_PA_CriarTarefa` into solution `PMO_v11_Tarefas` and removed the original/broken `PMO_PA_CriarTarefa` flow component from that solution's cloud-flow list. Current solution cloud-flow list shows six active flows:

- `Clean_PMO_PA_CriarTarefa`
- `PMO_PA_AtualizarTarefa`
- `PMO_PA_CheckInOnDemand`
- `PMO_PA_EscalarRiscoCritico`
- `PMO_PA_ListarTarefas`
- `PMO_PA_RegistrarDecisaoBoard`

Next step: in Copilot Studio, replace the topic tool block with `Clean_PMO_PA_CriarTarefa`, save, publish, and retest T-007.

Codex then explicitly added the real Dataverse workflow component to the solution with PAC:

```text
workflowid = 42d9abd1-8849-f111-bec7-7ced8d955c6c
solution = PMO_v11_Tarefas
componenttype = 29
```

Verified `solutioncomponent` row:

```text
objectid = 42d9abd1-8849-f111-bec7-7ced8d955c6c
s.uniquename = PMO_v11_Tarefas
```

Published all customizations successfully:

```text
async operation = 86edcc8c-8d49-f111-bec7-7ced8d955c6c
Published All Customizations.
```
