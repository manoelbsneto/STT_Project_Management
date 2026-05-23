# A3 Topic Contract Audit Table

## Scope

This table consolidates the local A3 topic audit for the five PM0 topics requested on 2026-05-22. Trigger contract evidence is derived directly from the matching local workflow JSON, not from A1 output.

| Topic | PM0 action call evidence | Exact current `input` | Local PM0 workflow trigger fields | Required trigger fields | Headline finding | Report |
|---|---|---|---|---|---|---|
| `AtualizarStatus` | `Local_Repo/Assistente PMO V2/topics/AtualizarStatus.mcs.yml:158` | `{}` at topic line 160 | `action`, `status`, `routeKey` at workflow lines 38-53 | `routeKey` | Empty topic input omits required `routeKey`; collected status remains unmapped. | `AtualizarStatus.md` |
| `AtualizarTarefa` | `Local_Repo/Assistente PMO V2/topics/AtualizarTarefa.mcs.yml:208` | `{}` at topic line 210 | `action`, `spItemId`, `taskId`, `status`, `taskStatus`, `comments` at workflow lines 50-77 | `action` | Empty topic input omits required `action`; task ID and status collected by topic are not passed to fields read by workflow body. | `AtualizarTarefa.md` |
| `ConsultarPortfolio` | `Local_Repo/Assistente PMO V2/topics/ConsultarPortfolio.mcs.yml:27` | `{}` at topic line 29 | Empty trigger properties and empty required list at workflow lines 32-36 | None | Empty topic input matches the matching local workflow trigger schema. | `ConsultarPortfolio.md` |
| `CriarTarefa` | `Local_Repo/Assistente PMO V2/topics/CriarTarefa.mcs.yml:169` | `{}` at topic line 171 | `dueDate`, `action`, `taskTitle`, `projectId`, `endDate`, `startDate`, `bucket`, `title`, `plannerBucketName` at workflow lines 50-90 | `projectId`, `action` | Empty topic input omits both required fields; topic has project-name text but no resolved `ProjectID` variable. | `CriarTarefa.md` |
| `ListarTarefas` | `Local_Repo/Assistente PMO V2/topics/ListarTarefas.mcs.yml:46` | `{}` at topic line 48 | `action`, `projectId` at workflow lines 47-59 | `action`, `projectId` | Empty topic input omits both required fields; topic has project-name text but no resolved `ProjectID` variable. | `ListarTarefas.md` |

## Cross-Topic Findings

1. All five topics call the expected `pmo_AssistentePMO_V2.action.PM0_PA_Card_*` or portfolio PM0 action component, but every observed PM0 `BeginDialog` block uses the exact input object `input: {}` in the topic YAML.
2. Four of the five matching local PM0 workflow trigger schemas require at least one trigger field that the topic does not pass: `AtualizarStatus`, `AtualizarTarefa`, `CriarTarefa`, and `ListarTarefas`.
3. `CriarTarefa` and `ListarTarefas` collect or prompt for project name/code text as `Topic.NomeProjeto`, but their matching PM0 workflows use a trigger field named `projectId`; `ListarTarefas` visibly filters SharePoint `ProjectID` with that field at workflow line 152.
4. `ConsultarPortfolio` is the only topic in this set whose empty input object matches the matching local workflow trigger schema because that trigger declares no fields and no required entries.

## Microsoft Learn Citation

- Official page: Microsoft Learn, "Configure zero prompt experience for Copilot in Dynamics 365 Sales (preview)"
- URL: `https://learn.microsoft.com/en-us/dynamics365/sales/zero-prompt-experience`
- Accessed: `2026-05-22 15:23:02 -03:00`
- Citation use: the sample YAML at page lines 131-160 shows a `BeginDialog` action using `input:` with nested `binding:` entries before `dialog:` and `output:`. This supports the `BeginDialog input.binding` syntax only; PM0 field names and requirements in this table come from local workflow JSON.
