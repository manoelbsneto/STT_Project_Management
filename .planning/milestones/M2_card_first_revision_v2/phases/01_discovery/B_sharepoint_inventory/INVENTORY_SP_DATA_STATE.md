# Track B.2 - SharePoint Data State

Source: read-only PnP item queries. Soft-delete is determined from the `Deleted` Boolean field when present.

| List | Total items | Active | Soft-deleted | Last write |
|---|---:|---:|---:|---|
| Projetos | 34 | 25 | 9 | 2026-05-14T19:10:33.0000000Z |
| Tarefas | 16 | 7 | 9 | 2026-05-14T19:11:37.0000000Z |
| Status Diario | 5 | 4 | 1 | 2026-05-14T19:10:02.0000000Z |
| Riscos e Bloqueios | 7 | 5 | 2 | 2026-05-13T16:50:32.0000000Z |
| Decisoes do Board | 5 | 3 | 2 | 2026-05-14T19:08:33.0000000Z |

## Analysis

- No SharePoint writes, schema mutations, view changes, or item edits were performed.
- Lists with active residual test candidates are detailed in `INVENTORY_TEST_RESIDUALS.md`.
