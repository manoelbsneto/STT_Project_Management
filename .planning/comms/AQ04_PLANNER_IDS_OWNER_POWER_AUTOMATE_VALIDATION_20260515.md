# AQ-04 Planner IDs: Owner Power Automate Validation

Date: 2026-05-15
Owner evidence source: Owner-provided Power Automate Planner Standard connector runbook
Reviewed by: CODEX-LEAD
Scope: AQ-04 read-only Planner plan/bucket discovery
Release decision: NO-SHIP
Tenant writes by CODEX: None

## 1. Verdict

AQ-04 is accepted as owner-provided read-only Planner discovery evidence for local P0 planning.

Result: PASS FOR PLANNER ID MAPPING BASELINE

This evidence unblocks local flow planning, schema planning, and deterministic bucket mapping design.

This evidence does not authorize Planner writes, SharePoint writes, flow saves/imports, Copilot publish, Teams production posts, or SHIP.

## 2. Evidence Basis

The owner provided a runbook documenting successful Power Automate Planner Standard connector validation in `ColOfertasBrasilPro` using `shared_planner`.

Validated read operations:

| Operation | Operation ID | Result |
|---|---|---|
| List my tasks | `ListMyTasks_V2` | `statusCode 200`, `@odata.count 87` |
| Get task | `GetTask_V2` | `statusCode 200` |
| Get task details | `GetTaskDetails_V2` | `statusCode 200` |
| List buckets | `ListBuckets_V3` | `statusCode 200`, `@odata.count 6` |
| List tasks | `ListTasks_V3` | `statusCode 200`, `@odata.count 9` |

Graph Explorer was blocked by Enterprise Application policy, but Power Automate Planner connector access succeeded. This is acceptable for P0 because the planned implementation uses the Planner Standard connector.

## 3. Canonical Planner Context

| Item | Value |
|---|---|
| Group / Team name | `Grp_T_DN_Transformacao_Digital` |
| `groupId` | `96c5b0c4-46cc-46cd-8695-50451db74994` |
| Planner plan name | `Desenvolvimento de Software` |
| `planId` | `-1kBj1PLv0qQM-R4PwkqbpcABv_P` |
| Connector | `shared_planner` |
| Connected user | `mbenicios@minsait.com` |

## 4. Bucket Mapping

| Bucket / list | `bucketId` |
|---|---|
| `Piloto e Implantacao` | `4YAXH7iU9E-6jZE2P1DbG5cAMAzH` |
| `Testes` | `7QYPufh54kum7MP4KUzzAZcAL6Ik` |
| `Cancelado` | `90TcFTFup0CjiHIdzY4gG5cALWKL` |
| `Concluido` | `F2WYUsnXeEue5qlwQuu3GJcAN1Ns` |
| `Em andamento` | `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG` |
| `Pendente` | `HmzyGOgC4k6uOPm_cwG3zZcAGiAG` |

## 5. Current Task Inventory

| Task | `taskId` | Bucket | `bucketId` |
|---|---|---|---|
| `Determinar o escopo do projeto` | `nRLK90eL4EGpBzihEemNGpcAGc5q` | `Pendente` | `HmzyGOgC4k6uOPm_cwG3zZcAGiAG` |
| `Implantar o software` | `e0ccLIjrDEmI7MslrGt7OZcAH0RE` | `Piloto e Implantacao` | `4YAXH7iU9E-6jZE2P1DbG5cAMAzH` |
| `Realizar os testes de usuario` | `MAiu82neAEWc84C-vZJsA5cAIDml` | `Concluido` | `F2WYUsnXeEue5qlwQuu3GJcAN1Ns` |
| `Rascunho de especificacoes preliminares do software` | `u9C6QAiuKU-oNqJ3JpAwzJcALmcj` | `Em andamento` | `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG` |
| `Desenvolver o codigo` | `TF7ohhezj0KSRKYD6SGhTJcAM7_1` | `Cancelado` | `90TcFTFup0CjiHIdzY4gG5cALWKL` |
| `Realizar testes` | `VLia4fYJ-02cirnunGnoK5cADm3w` | `Testes` | `7QYPufh54kum7MP4KUzzAZcAL6Ik` |
| `Realizar a analise de necessidades` | `V80aVns6ck-spPsbIVKWQZcAJPoC` | `Em andamento` | `ugZSNxsYW0WWCJ5Dtx0-l5cALVXG` |
| `Obter os comentarios do usuario` | `sSw6uGZjFEawcahh6l61lZcAG0m8` | `Piloto e Implantacao` | `4YAXH7iU9E-6jZE2P1DbG5cAMAzH` |
| `Desenvolver o prototipo com base em especificacoes` | `139iKgnHy0GGC5CZkRHygZcAOe4-` | `Concluido` | `F2WYUsnXeEue5qlwQuu3GJcAN1Ns` |

## 6. Agent Rules From Evidence

- Use `ListTasks_V3` for plan-scoped task inventory.
- Use `ListMyTasks_V2` only for user-assigned task discovery across plans.
- Never use task title as `taskId`.
- Resolve a task by title only after reading `ListTasks_V3`; then use the returned `id`.
- Use `GetTask_V2` for task metadata.
- Use `GetTaskDetails_V2` for description, checklist, references, preview type, and modified metadata.
- Do not add, delete, rename, or reorder buckets for P0.
- Do not write Planner without separate owner approval.

## 7. Impact on Approval Queue

AQ-04 can move from `PENDING` to `DONE_OWNER_EVIDENCE`.

Remaining blockers:

- AQ-03 SharePoint `Tarefas` schema write approval and evidence.
- AQ-07 flow save/import approval and evidence.
- AQ-08 Copilot publish/update approval and evidence.
- AQ-09 runtime smoke and XPIA regression evidence.
- AQ-10 final release decision.

## 8. Current Release Status

```text
NO-SHIP
```

No tenant writes were performed by CODEX while recording this evidence.
