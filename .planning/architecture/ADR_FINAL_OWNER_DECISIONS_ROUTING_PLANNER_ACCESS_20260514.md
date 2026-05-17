# ADR: Final Owner Decisions for P0 Routing, Planner Buckets, Gemini, and Access

Date: 2026-05-14  
Status: Accepted for P0 documentation control  
Owner decision source: `.planning/comms/OWNER_DECISIONS_REQUIRED_P0_ADAPTIVE_CARDS_PLANNER_20260514.md`  
Access protocol source: `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`  
Tenant changes: None executed by this ADR

## 1. Context

The owner accelerated documentation control for the Adaptive Cards + Planner P0 delivery and finalized operational decisions needed by flow design, card design, QA readiness, and CODEX-LEAD integration.

This ADR records those owner decisions as project-control guidance only. It does not authorize tenant writes, Power Automate saves, Copilot Studio edits, Teams posts, SharePoint changes, Planner writes, or bucket changes.

## 2. Decision

### 2.1 Teams Routing

For P0, the following route decisions are final:

| Route key | P0 target | Group ID | Channel ID | Notes |
|---|---|---|---|---|
| `board.status` | `Projetos_Transformacao_Digital` route | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | Owner-approved executive / board card route. Existing local display name appears as `Projetos_Tranformação_Digital`. |
| `pmo.ops` | `Projetos_Transformacao_Digital` route | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:4c8fe80b169f4e698c9b1b15d1868691@thread.tacv2` | Owner-approved PMO operations route for P0 alerts and controlled pilot notifications. |
| `pm.status.updates` | `QA_Projetos` | `96c5b0c4-46cc-46cd-8695-50451db74994` | `19:10900a91b53344c68d9c2a4299aa42d7@thread.tacv2` | PM status update and review cards use `QA_Projetos`; fallback to `Projetos_Transformacao_Digital` only if pilot validation proves the QA route fails. |
| `task.card.route` | Direct chat | N/A | N/A | Task list/create/update cards use temporary P0 direct chat to `mbenicios@minsait.com`. |

### 2.2 Planner Buckets

Existing Planner buckets are preserved for P0.

Observed bucket names from the owner-provided Teams screenshot:

| Bucket name | P0 control |
|---|---|
| `Concluido` | Preserve existing bucket. |
| `Piloto e Implantacao` | Preserve existing bucket. Screenshot text was truncated, but owner approved using existing buckets as shown. |
| `Em andamento` | Preserve existing bucket. |
| `Testes` | Preserve existing bucket. |
| `Cancelado` | Preserve existing bucket. |
| `Pendente` | Preserve existing bucket. |

No agent may add, delete, rename, or reorder Planner buckets for P0 unless CODEX-LEAD/CODEX requests explicit owner approval later and the owner approves that change in writing.

Planner bucket IDs remain pending approved read-only discovery through the project master runbooks. `m365` is not approved for this discovery.

### 2.3 Gemini Authorization

Gemini may act whenever needed under owner authorization.

Control conditions:

- CODEX-LEAD must notify the owner before Gemini starts.
- The owner must authorize/start the Gemini session.
- Current allowed Gemini mode is local/programmatic design only unless the owner explicitly authorizes a stronger mode.
- Gemini may not execute tenant changes, Power Automate saves, SharePoint writes, Planner writes, Teams production posts, Copilot Studio publishes, or solution imports without explicit owner approval.

### 2.4 Access and Discovery Constraint

Microsoft 365 CLI / `m365` is forbidden for discovery, Planner lookup, bucket discovery, or other P0 access work.

Approved access behavior:

- Use only the project master docs and runbooks.
- Follow `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`.
- Post planned access route/command in the check-in board before access-related work.
- Wait for the required owner approval gate before any runtime or tenant-impacting action.

## 3. Rationale

These decisions remove ambiguity before flow and card implementation:

- Executive and PMO operational notifications have a single owner-approved P0 route.
- PM status cards have a dedicated QA pilot channel and a clear fallback rule.
- Task cards are scoped to a temporary direct-chat pilot target.
- Planner design can proceed without changing existing bucket structure.
- Gemini participation is allowed but remains owner-gated.
- The `m365` prohibition is now explicitly tied to Planner discovery and P0 access control.

## 4. Consequences

Downstream agents must treat this ADR as the routing and access-control baseline for P0:

- Flow designs should use route keys and the owner-approved IDs above.
- Card action contracts should not assume project-specific task channels for P0.
- QA evidence should validate `board.status`, `pmo.ops`, `pm.status.updates`, and direct-chat task card delivery separately.
- Planner create/update design must map to existing buckets only.
- Any request to add/delete Planner buckets becomes a separate owner approval item.
- Any discovery proposal using `m365` must be rejected.

## 5. Implementation Controls

This ADR does not change implementation artifacts.

Not authorized by this ADR:

- tenant import or publish;
- Power Automate save;
- Copilot Studio edit or publish;
- SharePoint schema or item write;
- Planner task write;
- Planner bucket add/delete/rename;
- Teams production post;
- direct Graph call;
- Microsoft 365 CLI / `m365` discovery.

## 6. References

- `.planning/comms/OWNER_DECISIONS_REQUIRED_P0_ADAPTIVE_CARDS_PLANNER_20260514.md`
- `.planning/comms/AGENT_ACCESS_PROTOCOL_P0_20260514.md`
- `.planning/architecture/PLANNER_TASK_MAPPING_SCHEMA_DECISION_20260514.md`
- `.planning/AGENT_CONTRACT.md`
