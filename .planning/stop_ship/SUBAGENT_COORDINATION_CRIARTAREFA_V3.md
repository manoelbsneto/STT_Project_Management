# Subagent Coordination - CriarTarefa V3

Date: 2026-05-07
Owner: Codex
Bot: Assistente PMO V2
Environment: e2d10003-4d8e-e007-9d63-76d5fe89ef56

## Objective

Stabilize the `CriarTarefa` end-to-end path without corrupting Copilot Studio or Power Automate metadata.

Current known state:

- Copilot Studio topic `CriarTarefa` can route and collect fields in GPT-4.1.
- UI-created flow/tool `PMO_PA_CriarTarefa_V3` is registered and callable.
- `FlowNotFound` is resolved for V3.
- V3 currently returns a stub message: `Fluxo V3 chamado com sucesso.`
- SharePoint list `Tarefas` did not receive the validation test items.
- The older `Clean_PMO_PA_CriarTarefa` flow creates/uses `Projetos`, not `Tarefas`.

## Non-Negotiable Constraints

- Do not re-register Copilot tools via PAC/import.
- Do not invent Power Automate schema.
- Do not change flow trigger/response schema unless matching an official Copilot Studio agent flow pattern.
- Do not expose credentials from `.env`.
- Do not delete bots, flows, or SharePoint items.
- Any SharePoint verification must be read-only unless explicitly authorized.
- Keep the bot model on GPT-4.1 for now.
- All user-facing bot text must be pt-BR.

## Workstreams

### Agent A - Flow Logic Mapper

Scope:

- Compare `Clean_PMO_PA_CriarTarefa` with desired V3 behavior.
- Identify exact SharePoint target list and internal field names.
- Produce a safe implementation plan for V3.

Must answer:

- Should V3 create in `Projetos`, `Tarefas`, or both?
- What fields are required?
- Which connection reference/runtime source must be preserved?
- What should `Respond to the agent` return?

Out of scope:

- Editing files.
- Importing solutions.
- Changing Dataverse rows.

### Agent B - Topic/YAML Auditor

Scope:

- Audit `CriarTarefa` YAML for routing robustness.
- Check risks around duplicate topics, `EndDialog`, confirmation, and trigger phrases.
- Return a full YAML recommendation only, never patch fragments.

Must answer:

- Does the topic explicitly end after success/cancel?
- Are trigger phrases robust enough for STT?
- Is `sim` handled correctly?
- Are there duplicate/ghost-topic risks?

Out of scope:

- Changing flow definitions.
- Registering tools.

### Agent C - SharePoint Evidence Runner

Scope:

- Build read-only verification commands for SharePoint.
- Verify `Projetos` and `Tarefas` after tests.
- Report item counts and matching records.

Must answer:

- Did the test item appear in SharePoint?
- In which list?
- Which fields were populated?
- What evidence proves success/failure?

Out of scope:

- Creating, updating, or deleting SharePoint items.
- Running destructive cleanup.

## Acceptance Criteria

- First user utterance routes reliably to `CriarTarefa` after publish/new test session.
- Confirmation accepts `sim`.
- Topic does not continue asking for title after success or cancellation.
- V3 creates the expected SharePoint item in the agreed list.
- V3 response includes a real success message and generated ID, not a stub.
- Programmatic SharePoint verification confirms the created item.

## Recommended Test Message

```text
criar tarefa: Teste Validacao PMO 999, responsavel=Manoel Benicio, prazo=31/05/2026, horas=8, prioridade=Alta
```

Confirmation:

```text
sim
```

## Evidence Format

Each agent must return:

- Finding
- Evidence path or command
- Risk
- Recommendation
- Whether code/UI action is required

