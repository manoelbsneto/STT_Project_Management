# Codex #2 PM0 Workflow Diff - ResumoExecutivoPortfolio

Package workflow: `PM0_PA_Card_ResumoExecutivoPortfolio-8333BD91-A250-F111-BEC7-000D3ABC5CC6.json`

| Change | JSON path | Local Alpha | Packaged | Classification | Reason |
|---|---|---|---|---|---|
| ONLY_PACKAGE | `$.properties.definition.actions.Get_Projetos.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Get_Projetos.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Get_Projetos.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_PACKAGE | `$.properties.definition.actions.Get_Tarefas.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Get_Tarefas.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Get_Tarefas.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |

Summary: 6 canonical leaf-value differences; 0 UNEXPLAINED.