# Codex #2 PM0 Workflow Diff - AtualizarTarefa

Package workflow: `PM0_PA_Card_AtualizarTarefa-7C6300C2-A250-F111-BEC7-000D3ABC5CC6.json`

| Change | JSON path | Local Alpha | Packaged | Classification | Reason |
|---|---|---|---|---|---|
| VALUE | `$.properties.connectionReferences.shared_planner.source` | `Invoker` | `Embedded` | INTENTIONAL_PACKAGER | Builder normalizes invoker connection-reference source metadata to embedded package metadata. |
| VALUE | `$.properties.connectionReferences.shared_sharepointonline.source` | `Invoker` | `Embedded` | INTENTIONAL_PACKAGER | Builder normalizes invoker connection-reference source metadata to embedded package metadata. |
| ONLY_PACKAGE | `$.properties.definition.actions.Get_SharePoint_Item.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Get_SharePoint_Item.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Get_SharePoint_Item.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_PACKAGE | `$.properties.definition.actions.Update_Planner_Task.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Update_Planner_Task.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Update_Planner_Task.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_PACKAGE | `$.properties.definition.actions.Update_SharePoint_Item.inputs.authentication` | `` | `@parameters('$authentication')` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Update_SharePoint_Item.inputs.authentication.type` | `Raw` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |
| ONLY_LOCAL | `$.properties.definition.actions.Update_SharePoint_Item.inputs.authentication.value` | `@json(decodeBase64(triggerOutputs().headers['X-MS-APIM-Tokens']))['$ConnectionKey']` | `` | INTENTIONAL_PACKAGER | Builder replaces raw APIM token authentication object with package authentication parameter reference. |

Summary: 11 canonical leaf-value differences; 0 UNEXPLAINED.