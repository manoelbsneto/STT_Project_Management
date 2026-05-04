# OPUS Handoff — G4 Copilot Studio Review

## Request
Review G4 for PMO Intelligent Hub MVP and decide whether the current Copilot Studio deployment can remain conditional or requires portal/runtime completion before Phase 5.

## Environment
- Power Platform environment: `ColOfertasBrasilPro` (`e2d10003-4d8e-e007-9d63-76d5fe89ef56`)
- Agent: `Assistente PMO`
- Bot ID: `0c4a9729-d55d-483c-8ec3-db9369583155`
- Bot URL: `https://web.powerva.microsoft.com/environments/e2d10003-4d8e-e007-9d63-76d5fe89ef56/bots/0c4a9729-d55d-483c-8ec3-db9369583155`

## Completed
- Created the Copilot Studio agent through `pac copilot create`.
- `pac copilot list` reports `Assistente PMO` as `Published`, `Active`, and `Provisioned`.
- Template includes Integrated Microsoft authentication and Teams channel configuration.
- Exported template shows `GenerativeActionsEnabled=false`.
- Created 8 PMO topics:
  - `AtualizarStatus`
  - `ConsultarPortfolio`
  - `ConsultarProjeto`
  - `RegistrarRisco`
  - `RegistrarBloqueio`
  - `PedirDecisao`
  - `LowConfidence`
  - `Greeting`
- Confirm-before-action prompts are present in `AtualizarStatus`, `RegistrarRisco`, `RegistrarBloqueio`, and `PedirDecisao`.
- Migrated `PMO_PA_CheckInOnDemand` to solution-aware and bound it as a Copilot action:
  - ProcessSimple flow ID: `c9e51483-38e7-422a-98cd-cf7604d14a16`
  - Dataverse workflow ID used by Copilot: `f5aab85e-ff46-f111-bec7-7ced8d955c6c`

## Evidence
- `.planning/comms/g4_assistente_pmo_summary_20260503_1153.json`
- `.planning/comms/g4_assistente_pmo_export_20260503_1153.yaml`
- `deploy/copilot/AssistentePMO.template.yaml`
- `deploy/copilot/kickStartTemplate-1.0.0.json`
- `.planning/comms/AssistentePMOExport-1.0.0.json`
- `.planning/comms/SUB3_CS_LOG.md`
- `.planning/comms/CODEX_LEAD_LOG.md`
- `.planning/comms/GATE_STATUS.md`

## Conditional Gaps
- PAC create did not expose a reliable `pt-BR` primary-language parameter; export reports primary language as English/language 0 even though topic text and triggers are pt-BR.
- Native Copilot custom entities were not created through PAC. The topics use constrained prompts for project/status/severity/impact instead of first-class entity records.
- SharePoint PMO list knowledge-source binding was not proven by PAC export.
- `ConsultarPortfolio` and `ConsultarProjeto` are structural topic stubs, not verified direct SharePoint query actions.
- `RegistrarRisco`, `RegistrarBloqueio`, and `PedirDecisao` implement confirmation but still require write actions to SharePoint or callable standard-flow wrappers.
- Teams channel installation in `Projetos_Tranformação_Digital` was not verified interactively.
- `pac copilot publish` logged `Pva.Publish` success and then a PowerVA 409 conflict; `pac copilot list` still reports the bot as Published.
- `pac copilot status` fails with a PAC CLI attribute bug on `componentstate_Property`.

## Recommended OPUS Decision
Mark G4 as `CONDITIONAL`, not full PASS. The agent exists and is listed as Published, but acceptance criteria requiring native entities, SharePoint-backed knowledge/actions, Teams channel install, and live conversation validation still need portal/runtime work.

## Suggested Next Actions
1. Open the bot URL in Copilot Studio and set/check language, authentication, and Teams channel publication.
2. Create the four native entities: `ProjectName`, `StatusRAG`, `RiskSeverity`, `ImpactLevel`.
3. Bind SharePoint PMO lists as the only knowledge sources and confirm public/web/generic knowledge is disabled.
4. Replace structural stubs with direct SharePoint actions or standard callable Power Automate wrappers.
5. Install/publish to the Teams channel and test at least `Greeting`, `AtualizarStatus` confirmation, `ConsultarPortfolio`, and `PedirDecisao` confirmation.
