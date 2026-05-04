# G2 Wiring Field Mapping

Use this mapping when completing the two placeholder flows in the Power Automate portal.

## Environment

- Environment: `ColOfertasBrasilPro`
- Environment ID: `e2d10003-4d8e-e007-9d63-76d5fe89ef56`
- Site: `https://indra365.sharepoint.com/sites/Grp_T_DN_Transformacao_Digital`

## CheckInDiario Card Payload

`deploy/cards/CheckInDiario.json` submits these payload ids:

| Card value | Source |
|---|---|
| `projectId` | `Action.Submit.data.projectId` |
| `statusRAG` | `Input.ChoiceSet id=statusRAG` |
| `resumo` | `Input.Text id=resumo` |
| `percentual` | `Input.Number id=percentual` |
| `risco` | `Input.Text id=risco` |
| `bloqueio` | `Input.Text id=bloqueio` |
| `proximaAcao` | `Input.Text id=proximaAcao` |
| `cardVersion` | `Action.Submit.data.cardVersion` |
| `origemEntrada` | `Action.Submit.data.origemEntrada` |

Important: the payload uses lowercase/mixed-case names. Do not build Parse JSON only for `ProjectID`, `StatusRAG`, `Percentual`, `Resumo`, or `Bloqueios` unless the flow normalizes both variants.

## Flow 2: PMO_PA_ProcessarRespostaCheckIn

### Parse JSON Output Normalization

Normalize these values before SharePoint actions:

| Normalized value | Expression source |
|---|---|
| `ProjectID` | `projectId` or `ProjectID` |
| `RAG` / `StatusRAG` | `statusRAG` or `StatusRAG` |
| `Resumo` | `resumo` or `Resumo` |
| `Risco` | `risco` or `Risco` |
| `Bloqueio` | `bloqueio`, `Bloqueio`, or `Bloqueios` |
| `ProximaAcao` | `proximaAcao` or `ProximaAcao` |
| `Percentual` | `percentual` or `Percentual` |

### Create Item: Status Diario

Use actual SharePoint internal names from G1 provisioning:

| Status Diario field | Value |
|---|---|
| `Title` | `concat('STATUS-', utcNow())` or equivalent |
| `StatusID` | generated status id, for example `concat('ST-', ticks(utcNow()))` |
| `ProjectID` | normalized `ProjectID` |
| `DataRegistro` | `utcNow()` |
| `PM` | responder user, if available from trigger |
| `RAG` | normalized status |
| `Resumo` | normalized `Resumo` |
| `Risco` | normalized `Risco` |
| `Bloqueio` | normalized `Bloqueio` |
| `ProximaAcao` | normalized `ProximaAcao` |
| `Percentual` | normalized `Percentual` |
| `OrigemEntrada` | `AdaptiveCard` |
| `CardVersion` | card version |

Do not use `StatusRAG`, `DataCheckin`, or `Bloqueios` as Status Diario field names; those are not the G1 internal names.

### Update Item: Projetos

The card currently sends `projectId`, which is the business key (`ProjectID`), not the SharePoint item `ID`.

Required sequence:

1. SharePoint Get items from `Projetos` with filter:
   `ProjectID eq '<normalized ProjectID>'`
2. Use the returned SharePoint item `ID`.
3. Update item in `Projetos`:
   - `StatusRAG` = normalized status
   - `Percentual` = normalized percent
   - `UltimaAtualizacao` = `utcNow()`

## Flow 3: PMO_PA_AlertaProjetoVermelho

Use actual `Projetos` fields:

| Projetos field | Use |
|---|---|
| `ProjectID` | Card/email project id |
| `NomeProjeto` | Card/email project name |
| `PM` | PM person field |
| `Sponsor` | sponsor email recipient |
| `StatusRAG` | condition equals `Vermelho` |
| `Percentual` | card/email detail |
| `DataAlvo` | card/email detail |
| `UltimaAtualizacao` | card/email detail |

Condition:

- If `StatusRAG` equals `Vermelho`: post `deploy/cards/AlertaCritico.json` to Teams and send sponsor email.
- Else: terminate with success.

## G2 Pass Reminder

G2 can only pass after:

- all 5 flows have real actions, no placeholders;
- all actions target `ColOfertasBrasilPro`;
- Standard connectors only;
- at least one E2E test per flow is documented;
- at least one Teams Adaptive Card render screenshot is captured.
