# Macro Plan: Adaptive Cards + Planner Architecture Revision

Date: 2026-05-14  
Status: Planning only; no tenant changes executed  
Decision direction: move from Copilot-chat-rendered operational data to Adaptive Cards + Power Automate controller + SharePoint/Planner backend.

## 1. Executive Answer

We are not throwing away the work done so far.

Most of the work remains valid. The change is architectural routing and output handling:

```text
Before:
Copilot -> Flow -> SharePoint/Planner data -> Copilot chat response

After:
Copilot -> Flow -> Teams Adaptive Card
Flow -> SharePoint/Planner write/read
Copilot -> static acknowledgement only
```

The main issue is not the SharePoint schema, Planner direction, or Power Automate business logic. The issue is that Copilot Studio currently remains in the path where operational data, flow outputs, or connector context can be interpreted by the Responsible AI/XPIA layer.

## 2. What We Keep

| Area | Keep? | Rationale |
|---|---:|---|
| SharePoint PMO lists | Yes | They remain the PMO system of record. |
| Existing ProjectID/TaskID/DecisionID model | Yes | Still required for audit, traceability, and Planner mapping. |
| Logical delete model | Yes | Still correct for governance and audit. |
| Existing Power Automate validation logic | Mostly yes | Can be reused/refactored inside card controller flows. |
| Existing Copilot topics and trigger phrases | Partially yes | Reused as routers, but not as data renderers. |
| Existing Adaptive Card governance templates | Yes | Check-in, decision, alerts, summaries are reusable. |
| Planner Standard connector decision | Yes | Already aligned with PRD and project constraints. |
| Current QA evidence and RCA | Yes | Becomes justification for architecture change. |
| Speech-to-text feature | Yes | Preserved, but routed through review card before write. |
| Executive query experience via Copilot | Yes | Preserved for short, curated summaries. |

## 3. What We Change

| Area | Change |
|---|---|
| `ListarTarefas` | Stop rendering or returning task details in Copilot. Send task list as Teams Adaptive Card. |
| `CriarTarefa` | Stop returning dynamic IDs/ProjectID in Copilot chat. Create/update through card flow and show result in Teams card. |
| `AtualizarTarefa` | Move update interaction to cards where possible; Copilot only initiates or confirms route. |
| `AtualizarStatus` | Keep Copilot/Teams/STT entry, but always use review card before write when input is free-form or transcribed. |
| Executive portfolio queries | Copilot returns small aggregated summaries; details go to Adaptive Cards or SharePoint/Teams tabs. |
| Flow outputs to Copilot | Replace operational payloads with static acknowledgements or tiny status codes. |
| Planner integration | Add operational create/update/sync mapping from SharePoint to Planner. |

## 4. What We Retire or Stop Using

| Item | Why |
|---|---|
| Long Flow outputs to Copilot | XPIA/content-filter risk. |
| Raw SharePoint/Planner JSON in bot variables | XPIA/content-filter risk. |
| Copilot-generated task list rendering | Primary source of current post-action block risk. |
| Returning SharePoint IDs as dynamic chat text where avoidable | Increases structured payload surface. |
| Any architecture that asks Copilot to summarize connector responses directly | Reintroduces the same failure pattern. |

## 5. Macro Timeline

The timeline below assumes one focused implementer plus owner availability for tenant UI actions, publish, and runtime validation.

| Wave | Macro Activity | Estimate | Main Output |
|---|---|---:|---|
| 0 | Governance documentation and change request | 0.5 to 1 day | AS-IS/TO-BE, CR, ADR, PRD/contract updates, RCA cross-reference |
| 1 | Planner/Teams readiness inventory | 0.5 to 1 day | Team/channel routing, Planner Plan IDs, Bucket IDs, permission check |
| 2 | P0 `ListarTarefas` card-first proof | 1 to 1.5 days | Known failing command sends Teams card and no longer triggers `ContentFiltered` |
| 3 | `CriarTarefa` card + Planner create | 1.5 to 2.5 days | Card-driven create, SharePoint write, Planner task create, sync fields |
| 4 | `AtualizarTarefa` card + Planner update | 1 to 2 days | Card-driven update of SharePoint and Planner |
| 5 | `AtualizarStatus` + Speech-to-Text review flow | 1.5 to 2.5 days | Voice/text input becomes reviewed card before write |
| 6 | Executive portfolio/query summaries | 1 to 2 days | Director asks Copilot; short summary in chat, detail in card/tab |
| 7 | Regression, QA evidence, release readiness | 1 to 2 days | Full evidence pack, rollback plan, go/no-go decision |

## 6. Estimated Total Effort

| Scenario | Estimate | Description |
|---|---:|---|
| Minimal RAI unblock only | 1 to 2 days | Remove risky Copilot output paths without full Planner/card architecture. |
| Recommended P0 architecture | 3 to 5 days | ListarTarefas + CriarTarefa + AtualizarTarefa with card-first and Planner mapping. |
| Full TO-BE revision | 7 to 12 days | Task management, status/STT, executive summaries, Planner sync, governance cards, QA. |
| Production hardening buffer | +1 to 2 days | Evidence, screenshots, run history, rollback, owner validation. |

Recommended path:

```text
Do Wave 0 and Wave 1 first.
Then build Wave 2 as the proof.
Only after the known XPIA repro is solved, continue with create/update and STT.
```

## 7. AS-IS vs TO-BE

### AS-IS

```text
User asks Copilot
Copilot identifies topic
Copilot calls Power Automate action
Flow queries/writes SharePoint
Flow returns result/context to Copilot
Copilot displays response
RAI/XPIA layer may block after success
```

Issues:

- Copilot remains in the operational data path.
- Internal tool/connector context can still be evaluated by RAI.
- Successful operations can look failed to users.
- Runtime diagnostics are limited because Application Insights is not available.

### TO-BE

```text
User asks Copilot or uses Teams
Copilot routes only, or Teams card starts directly
Power Automate controls business process
Adaptive Card displays/collects structured data
Flow writes SharePoint and Planner
Copilot receives only static acknowledgement or no operational payload
```

Benefits:

- Lower XPIA exposure.
- Better UX for PMs and directors.
- Stronger audit and confirmation model.
- Planner can become the operational task destination.
- Speech-to-text remains possible with review-before-write.

## 8. Key Dependencies

| Dependency | Owner | Needed By |
|---|---|---|
| Teams card destination strategy | Owner/PMO | Wave 1 |
| Planner Plan ID and Bucket ID mapping | Owner/PMO | Wave 2 |
| Permission confirmation for Planner connector | Owner/PMO | Wave 2 |
| Owner approval for tenant changes/import/publish | Owner | Any implementation wave |
| Runtime validation screenshots | Owner + Codex | Waves 2-7 |

## 9. Risk and Mitigation

| Risk | Impact | Mitigation |
|---|---|---|
| Teams card routing blocked by permissions | P0 delayed | Validate channel/direct chat routing before building all cards. |
| Planner mapping incomplete | Planner create/update partial | Keep SharePoint as source of record and mark Planner sync as pending/error. |
| XPIA still triggers after `ListarTarefas` card proof | Architecture assumption challenged | Stop rollout and isolate whether Copilot action call itself is enough to trigger. |
| Speech-to-text transcription is ambiguous | Incorrect status update | Always use review card before write. |
| Director wants long detail in Copilot chat | RAI risk returns | Chat gives summary; details go to Teams card or SharePoint tab. |

## 10. Recommendation

Proceed with the TO-BE architecture, but do not big-bang the whole product.

The correct sequence is:

1. Document and approve the architecture change.
2. Validate Planner/Teams routing.
3. Convert `ListarTarefas` first.
4. Prove the known failing command no longer triggers `ContentFiltered`.
5. Convert create/update task flows.
6. Add STT review-card flow.
7. Add executive summary cards and curated Copilot responses.

This preserves the existing investment while removing the architectural pattern that is causing the current release blocker.

