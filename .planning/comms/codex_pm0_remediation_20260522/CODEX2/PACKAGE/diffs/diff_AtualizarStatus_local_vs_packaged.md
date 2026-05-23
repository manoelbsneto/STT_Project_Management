# Codex #2 PM0 Workflow Diff - AtualizarStatus

Package workflow: `PM0_PA_Card_AtualizarStatus-1721E0A3-A250-F111-BEC7-000D3ABC5CC6.json`

| Change | JSON path | Local Alpha | Packaged | Classification | Reason |
|---|---|---|---|---|---|
| VALUE | `$.properties.connectionReferences.shared_sharepointonline.source` | `Invoker` | `Embedded` | INTENTIONAL_PACKAGER | Builder normalizes invoker connection-reference source metadata to embedded package metadata. |
| VALUE | `$.properties.connectionReferences.shared_teams.source` | `Invoker` | `Embedded` | INTENTIONAL_PACKAGER | Builder normalizes invoker connection-reference source metadata to embedded package metadata. |
| ONLY_PACKAGE | `$.properties.definition.actions.Create_StatusDiario.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Create_StatusDiario.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Create_StatusDiario.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_PACKAGE | `$.properties.definition.actions.Get_Projeto_Item.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Get_Projeto_Item.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Get_Projeto_Item.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_PACKAGE | `$.properties.definition.actions.Post_Status_Card.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Post_Status_Card.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Post_Status_Card.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_PACKAGE | `$.properties.definition.actions.Update_SharePoint_Project.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Update_SharePoint_Project.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Update_SharePoint_Project.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |

Summary: 14 canonical leaf-value differences; 0 UNEXPLAINED.