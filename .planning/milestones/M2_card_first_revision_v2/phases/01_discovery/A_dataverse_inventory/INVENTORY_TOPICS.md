# Inventory Topics

Source evidence: `pac_env_who.txt`, `all_topics_inventory.txt`, `query_topics.fetchxml`.

Fetched botcomponent rows: 26. Topic rows: 16.

## User-facing topics

| Topic | State | Status | Modified | YAML bytes | Present |
|---|---|---|---|---:|---|
| CriarProjeto | Activo | Activo | 14/05/2026 15:03 | 6752 | yes |
| ConsultarProjeto | Activo | Activo | 14/05/2026 15:02 | 2798 | yes |
| ExcluirProjeto | Activo | Activo | 14/05/2026 15:03 | 3580 | yes |
| CriarTarefa | Activo | Activo | 14/05/2026 15:03 | 6889 | yes |
| ListarTarefas | Activo | Activo | 14/05/2026 15:03 | 2095 | yes |
| AtualizarTarefa | Activo | Activo | 14/05/2026 15:02 | 15255 | yes |
| ExcluirTarefa | Activo | Activo | 14/05/2026 15:03 | 5152 | yes |
| AtualizarStatus | Activo | Activo | 14/05/2026 15:02 | 9090 | yes |
| RegistrarRisco | Activo | Activo | 14/05/2026 15:02 | 6195 | yes |
| RegistrarBloqueio | Activo | Activo | 14/05/2026 15:02 | 5685 | yes |
| PedirDecisao | Activo | Activo | 14/05/2026 15:03 | 8254 | yes |
| ConsultarPortfolio | Activo | Activo | 14/05/2026 15:03 | 1260 | yes |

## System topics

| Topic | State | Status | Modified | YAML bytes | Present |
|---|---|---|---|---:|---|
| Greeting | Activo | Activo | 14/05/2026 15:02 | 266 | yes |
| LowConfidence | Activo | Activo | 14/05/2026 15:02 | 10615 | yes |
| SeHouverErro | Activo | Activo | 14/05/2026 15:03 | 298 | yes |
| Gerar_Multiplos_Projetos | Activo | Activo | 14/05/2026 15:03 | 1170 | yes |

## Notes

- The FetchXML returned 10 action botcomponents in addition to topic rows because Dataverse labels componenttype 9 as Tema (V2) for both topic/action dialog records. These are excluded from `topic_inventory.json`.
- `modifiedon` is preserved exactly as PAC returned it, in localized `dd/MM/yyyy HH:mm` format.
