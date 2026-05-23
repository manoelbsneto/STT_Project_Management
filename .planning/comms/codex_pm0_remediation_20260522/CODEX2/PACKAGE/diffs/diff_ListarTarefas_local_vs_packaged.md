# Codex #2 PM0 Workflow Diff - ListarTarefas

Package workflow: `PM0_PA_Card_ListarTarefas-E0E3C6B0-A250-F111-BEC7-000D3ABC5CC6.json`

| Change | JSON path | Local Alpha | Packaged | Classification | Reason |
|---|---|---|---|---|---|
| VALUE | `$.properties.connectionReferences.shared_planner.runtimeSource` | `invoker` | `embedded` | INTENTIONAL_PACKAGER | Builder normalizes invoker connection-reference source metadata to embedded package metadata. |
| VALUE | `$.properties.connectionReferences.shared_sharepointonline.runtimeSource` | `invoker` | `embedded` | INTENTIONAL_PACKAGER | Builder normalizes invoker connection-reference source metadata to embedded package metadata. |

Summary: 2 canonical leaf-value differences; 0 UNEXPLAINED.