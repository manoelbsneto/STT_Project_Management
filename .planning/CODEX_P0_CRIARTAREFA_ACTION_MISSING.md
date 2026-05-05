# CODEX P0 — CriarTarefa Action Not Found (Bot Cannot Publish)

> **Severity:** P0 BLOCKER — Bot cannot publish
> **Error:** `Dialog with id 'template-content.action.PMO_PA_CriarTarefa' not found`
> **Commit baseline:** `838f04b`

---

## ERROR (verbatim from Copilot Studio)

```json
{
  "diagnosticResult": [
    {
      "$kind": "InvalidReferenceError",
      "referenceType": "Dialog",
      "referenceId": "template-content.action.PMO_PA_CriarTarefa",
      "errorCode": "NotFound",
      "errorMessage": "Dialog with id 'template-content.action.PMO_PA_CriarTarefa' not found"
    }
  ],
  "componentDisplayName": "CriarTarefa",
  "componentId": "b7fbf995-ffd8-4657-ba76-d289f6a9d3a8"
}
```

## WHAT HAPPENED

The CriarTarefa **topic** (botcomponent) was successfully imported and exists in the bot.
The CriarTarefa **action** (botcomponent that wraps the Power Automate flow) was NOT created or failed to import.

The topic's BeginDialog calls:
```yaml
- kind: BeginDialog
  id: call_criar_tarefa
  dialog: template-content.action.PMO_PA_CriarTarefa   # ← THIS DOES NOT EXIST
```

But no botcomponent with schemaName `template-content.action.PMO_PA_CriarTarefa` exists in the bot.

## WHAT NEEDS TO HAPPEN

The Power Automate flow `PMO_PA_CriarTarefa` must be registered as an **Action** in the Copilot Studio bot. This creates the missing `template-content.action.PMO_PA_CriarTarefa` botcomponent.

## KNOWN CONTEXT

- Flow ID (Power Automate): `7ca90102-525b-48bb-875e-0f7bda96f85b`
- Workflow Entity ID (Dataverse): `71f62da4-9748-f111-bec7-6045bdf42cae`
- Bot ID: `0c4a9729-d55d-483c-8ec3-db9369583155`
- Environment: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`
- The flow IS deployed and enabled (state=Started) — confirmed in prior evidence
- The flow uses Skills trigger/response pattern (same as CheckInOnDemand, AtualizarTarefa, etc.)

## REFERENCE: How existing actions work

Look at an existing working action in the bot. For example `PMO_PA_AtualizarTarefa`:

```yaml
- kind: DialogComponent
  displayName: PMO_PA_AtualizarTarefa
  schemaName: template-content.action.PMO_PA_AtualizarTarefa
  state: Active
  status: Active
  dialog:
    kind: TaskDialog
    inputs: [...]
    outputs: [...]
    action:
      kind: InvokeFlowTaskAction
      flowId: 98408d55-3748-f111-bec7-000d3abc5cc6
      connectionProperties:
        $kind: ConnectionProperties
        mode: Invoker
    outputMode: All
```

The PMO_PA_CriarTarefa action needs to follow the EXACT same pattern, with:
- `flowId: 71f62da4-9748-f111-bec7-6045bdf42cae`
- outputs: success, message, errorcode, projectId

## YOUR TASK

1. **Diagnose**: Query Dataverse to list all botcomponents for the Assistente PMO bot. Confirm that `template-content.action.PMO_PA_CriarTarefa` is missing.

2. **Fix**: Register the PMO_PA_CriarTarefa flow as an action in the bot. Options (use whichever works):
   - **Option A**: Use `pac copilot add-action` or equivalent PAC CLI command
   - **Option B**: Create the botcomponent record directly in Dataverse via PAC/API
   - **Option C**: Create a minimal solution ZIP containing ONLY the missing action botcomponent and import it
   - **Option D**: If none of the above work, create a PowerShell script that uses the Dataverse Web API to create the botcomponent record

3. **Verify**: After fixing, extract the bot template and confirm:
   - `template-content.action.PMO_PA_CriarTarefa` exists
   - It references `flowId: 71f62da4-9748-f111-bec7-6045bdf42cae`
   - The bot publishes without errors

4. **RCA**: Provide root cause analysis explaining why the previous deployment (commit `09f70f7`) failed to create this action component.

## EXISTING EVIDENCE TO REVIEW

- `.planning/comms/cs_assistente_pmo_post_criartarefa_20260505_125833.yaml` — extracted template showing what SHOULD exist
- `.planning/comms/pa_criartarefa_flow_20260505_123028.json` — flow deployment evidence
- `.planning/comms/cs_criartarefa_patch_20260505_125833.json` — patch evidence
- `deploy/CS_CriarTarefa_Patch.ps1` — the script that was supposed to wire this

## CONSTRAINTS

- All programmatic — no manual UI steps
- Evidence to `.planning/comms/`
- Commit after successful verification
- The bot MUST publish without errors after your fix
