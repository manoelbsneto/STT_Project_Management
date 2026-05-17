# Phase 2.4 Research

**Status:** Complete
**Scope:** Microsoft-supported design basis for CriarProjeto, CriarTarefa, and Gerar_Multiplos_Projetos.

## Official Microsoft Basis

- SharePoint Connector for Power Automate supports list triggers/actions including item creation and update patterns for SharePoint lists.
  - Source: https://learn.microsoft.com/en-us/sharepoint/dev/business-apps/power-automate/sharepoint-connector-actions-triggers
- Power Automate supports Adaptive Cards in Teams and wait-for-response patterns for collecting input through Teams cards.
  - Source: https://learn.microsoft.com/en-us/power-automate/overview-adaptive-cards
  - Source: https://learn.microsoft.com/en-us/power-automate/create-adaptive-cards
- Adaptive Cards `Action.Submit` gathers input fields and sends them back for processing; input validation is supported in schema 1.3+.
  - Source: https://learn.microsoft.com/en-us/adaptive-cards/schema-explorer/action-submit
  - Source: https://learn.microsoft.com/en-us/adaptive-cards/authoring-cards/input-validation
- Teams sends Adaptive Card submit input as key-value pairs to the bot/action handler.
  - Source: https://learn.microsoft.com/en-us/microsoftteams/platform/task-modules-and-cards/cards/cards-actions
- Copilot Studio flows can receive inputs and return outputs between topics and Power Automate.
  - Source: https://learn.microsoft.com/en-ie/microsoft-copilot-studio/advanced-flow-input-output

## Design Findings

### SharePoint List Boundaries

`Projetos` and `Tarefas` must be separate write targets.

- `Projetos` is the master project/status list.
- `Tarefas` is the operational task list used by ListarTarefas, AtualizarTarefa, and ExcluirTarefa.
- The phase must add tests that fail if the target list is wrong.

### Adaptive Cards

Adaptive Cards are the right primary user experience because they provide structured input, review, and submit actions inside Teams/Power Automate. For this project:

- Card must be used as preview/confirmation, not immediate write.
- Card JSON must stay small enough for Teams/Power Automate constraints.
- Fallback must exist because cards can fail to render in some clients or contexts.

### Multiline/STT Fallback

Raw text fallback remains mandatory because users paste structured blocks and may use speech-to-text. It must:

- Capture raw text.
- Parse known labels.
- Ask only missing required fields.
- Confirm with string-based confirmation.
- Normalize to the same internal payload as the Adaptive Card path.

### Batch Risk

Batch creation must be limited and idempotent. Without row-level guards it can create operational junk quickly.

Minimum controls:

- Max 10 projects/tasks in 2.4.
- Duplicate check per project.
- No task creation if corresponding project create failed/skipped.
- Per-line result status.
- No all-or-nothing success message.

## Recommended Technical Shape

1. Keep local 2.3 as baseline.
2. Introduce/rename project-create capability:
   - Topic: `CriarProjeto`
   - Flow: `PMO_PA_CriarProjeto`
   - Target: `Projetos`
3. Rebuild true task-create capability:
   - Topic: `CriarTarefa`
   - Flow: `PMO_PA_CriarTarefa`
   - Target: `Tarefas`
4. Add batch capability:
   - Topic: `Gerar_Multiplos_Projetos`
   - Flow: `PMO_PA_Gerar_Multiplos_Projetos`
   - Targets: `Projetos` and optional `Tarefas`
5. Update tests so old behavior cannot pass silently.

## Open Implementation Questions

- Whether to create a new `PMO_PA_CriarProjeto` workflow component or reuse the old workflow ID under a renamed topic in the local package.
- Whether `Responsavel` in `Tarefas` is a person field requiring Claims or text in the live schema.
- Whether `Tarefas` has `Ativo`; previous live query showed `Ativo` does not exist on `Tarefas`, so tests must match actual schema.

## Recommendation

Proceed to a local-only plan. Do not execute import/publish until the package passes static gates and the owner explicitly approves runtime changes.
