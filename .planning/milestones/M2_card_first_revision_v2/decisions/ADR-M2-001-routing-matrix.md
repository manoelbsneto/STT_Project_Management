# ADR-001: Routing Matrix DM + Channel by Audience

**ADR ID:** ADR-M2-001
**Date:** 2026-05-20
**Status:** Accepted (locked by owner 2026-05-20 17:46 BRT)
**Author:** Opus 4.7
**Owner approval:** Manoel Benicio
**Milestone:** M2
**Supersedes:** none

---

## Context

M2 adopts a hybrid card-first pattern: chat collection (current strength) + Adaptive Card confirmation (new). Each Adaptive Card must be posted to a Teams destination. The destination has TWO dimensions:

1. **DM (direct chat)** — private to a single user. Used for confirmations of operations the user initiated.
2. **Channel (canal)** — shared visibility. Used for broadcasts where multiple stakeholders need awareness.

Different operations have different audience needs. Some need only DM, some only Channel, but most need BOTH (DM to creator + Channel for broadcast).

This ADR locks the routing matrix definitively. No future replan is needed unless tenant config changes (new channels, new groups).

## Decision

### 4 route keys remain in use (locked)

| Route key | Type | Target |
|---|---|---|
| `task.card.route` | DM | `mbenicios@minsait.com` (owner direct chat). Used for ALL operation confirmations + private results. |
| `board.status` | Channel | `Projetos_Transformacao_Digital` (group `96c5b0c4-46cc-46cd-8695-50451db74994`, channel `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2`). Used for executive broadcasts (new project, RAG=Vermelho status, decision approvals). |
| `pmo.ops` | Channel | Same channel as `board.status` for now (`Projetos_Transformacao_Digital`). May separate to dedicated ops channel in future. Used for operational alerts (errors, sync failures, audit broadcasts). |
| `pm.status.updates` | Channel | `QA_Projetos` (group `96c5b0c4-46cc-46cd-8695-50451db74994`, channel `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2`). Used for PM-relevant updates (task assignments, status changes). |

### 12 user operations × routing destinations

For each operation, the table below specifies which routes get the card:

| Operation | DM (`task.card.route`) — creator gets | Channel `board.status` | Channel `pmo.ops` | Channel `pm.status.updates` | Conditional |
|---|---|---|---|---|---|
| **CriarProjeto** | Confirm + Result | Result (broadcast new project) | — | — | — |
| **ConsultarProjeto** | Result | — | — | — | — |
| **ExcluirProjeto** | Confirm + Result | — | Result (audit broadcast) | — | — |
| **CriarTarefa** | Confirm + Result | — | — | Result (PM sees new task) | — |
| **ListarTarefas** | Result | — | — | — | — |
| **AtualizarTarefa** | Confirm + Result | — | — | Result (PM sees status change) | — |
| **ExcluirTarefa** | Confirm + Result | — | Result (audit broadcast) | — | — |
| **AtualizarStatus** | Confirm + Result | Result (only if RAG=Vermelho) | — | Result | conditional on RAG |
| **RegistrarRisco** | Confirm + Result | — | Result (PMO ops alert) | — | — |
| **RegistrarBloqueio** | Confirm + Result | — | Result (PMO ops alert) | — | — |
| **PedirDecisao** | Confirm card to creator | Result (decision card to approver) | — | — | — |
| **ConsultarPortfolio** | Result | Result (only if requester=executive role) | — | — | conditional on requester |

### Operation-to-route logic

Each PM0_PA_Card_* flow follows this logic:

1. After validation + write success, identify which routes the operation requires.
2. Build the appropriate cards (confirmation, result, broadcast variants — same template, slightly different data).
3. Post to each target route in parallel (DM first, channels second).
4. Return ack to Copilot: "Card enviado / Operação concluída."

### Conditional routing rules

- **AtualizarStatus + RAG=Vermelho** → also post to `board.status` for executive visibility. Otherwise only DM + `pm.status.updates`.
- **ConsultarPortfolio + executive role requesting** → also post to `board.status`. Otherwise only DM. Role detection: check requester UPN against owner-maintained executive list (initial value: just owner). Future enhancement: SP-stored role mapping.
- **Idempotency**: each post carries `operationId` (guid). Re-execution with same `operationId` does not duplicate posts.

### Ops failure handling

`PM0_PA_OpsFailureHandling` is the universal error card flow. It posts ONLY to:
- DM (`task.card.route`) — affected user
- `pmo.ops` channel — PMO ops team

Never to `board.status` or `pm.status.updates` (errors are not executive content).

### Card variants per route

Same operation may need slightly different card content per audience:

- **DM confirmation card**: full data, action buttons (Confirmar/Cancelar)
- **DM result card**: full data, success state, no actions
- **Channel broadcast card**: less detail, no action buttons (read-only), header indicating "Broadcast — Operação X concluída"

This ADR mandates **two layouts per operation**: `[Op]ConfirmCard.json` (DM) and `[Op]BroadcastCard.json` (Channel). Result variants share template with Confirm but with success state.

---

## Consequences

### Accepted positive consequences

1. **Audit trail é automático**: cada operação destrutiva ou estratégica deixa rastro num canal apropriado.
2. **Visibilidade executiva sem ruído**: diretoria só vê broadcasts quando relevante (novo projeto, RAG vermelho).
3. **PM produtividade**: assignments e mudanças aparecem em canal dedicado, não competem com ruído ops.
4. **Privacidade do criador**: confirmações privadas ficam na DM, sem expor dados em canais públicos.
5. **Escalabilidade futura**: separar `pmo.ops` de `board.status` é trivial (basta atualizar o channel ID).

### Accepted negative consequences

1. **Duplicação de payload**: mesmo dado pode ir pra 2-3 lugares (DM + canal + canal condicional). Mitigação: idempotency via `operationId`, mesmo card template renderizado 2-3x.
2. **Quota Teams**: posting frequente pode atingir limites do connector Standard. Mitigação: monitoring runbook acompanha.
3. **Card design complexity**: 2 layouts por operação (confirmation/result + broadcast). Mitigação: design system unifica visual.
4. **Router state**: flow precisa decidir quais routes ativar. Mitigação: matriz hard-coded em `Compose Routing Decisions` action no início de cada flow.

### Future evolution triggers

This ADR can be revised when:
- Stakeholder PMO secundário se junta (precisa de novo canal)
- Volume de broadcasts gera ruído (precisa de filter/digest)
- Tenant migra para grupo Teams diferente

---

## Implementation notes

### Per-flow routing block (template)

Each PM0_PA_Card_* flow includes this Compose action right after validation:

```json
{
  "type": "Compose",
  "name": "Determine_Routing",
  "inputs": {
    "operationName": "CriarProjeto",
    "routes": {
      "dm": {
        "enabled": true,
        "target": "@parameters('owner_upn')",
        "cardVariant": "confirm"
      },
      "board_status": {
        "enabled": true,
        "groupId": "96c5b0c4-46cc-46cd-8695-50451db74994",
        "channelId": "19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2",
        "cardVariant": "broadcast"
      },
      "pmo_ops": { "enabled": false },
      "pm_status_updates": { "enabled": false }
    },
    "conditional": {
      "rule": "none"
    }
  }
}
```

### Routes per operation — definitive JSON

Stored in `phases/02_architecture_spec/ROUTING_MATRIX.json`. Generated from this ADR. Hard-coded in flow Compose actions.

---

## Approvals

| Role | Name | Date |
|---|---|---|
| Architect | Opus 4.7 | 2026-05-20 17:46 BRT |
| Owner | Manoel Benicio | 2026-05-20 17:46 BRT (in-thread approval) |
