# Peer Review: Adaptive Cards + Planner Macro Plan

**Reviewer**: Antigravity (Research AI)  
**Document Reviewed**: `ADAPTIVE_CARDS_PLANNER_MACRO_PLAN_20260514.md` (authored by Codex)  
**Date**: 2026-05-14  
**Type**: Technical peer review — research only, no system changes  

---

## 1. Overall Assessment

The macro plan presents a technically sound TO-BE architecture that correctly identifies the root cause (Copilot Studio in the operational data path) and proposes a valid long-term solution (Adaptive Cards + Planner). However, the plan has a critical sequencing gap: it skips the cheapest, fastest mitigation and jumps directly to a full architectural revision.

**Rating**: Architecture vision is excellent. Execution sequencing needs revision.

---

## 2. Where the Plan is Correct

| Aspect | Assessment | Codex Detailed Comment |
|---|---|---|
| Root cause diagnosis | Correct. Copilot remaining in the data path where RAI/XPIA scans connector context is the confirmed cause. | Agreed. This is the strongest part of the review and matches the observed runtime pattern: successful operation first, blocked Copilot step afterward. I would phrase it as "confirmed working hypothesis" rather than absolute root cause because we do not have Application Insights payload evidence, but the evidence is strong enough to drive design. |
| Adaptive Cards as the TO-BE output channel | Sound. Moves structured data display outside the RAI moderation pipeline. | Agreed with one precision: Adaptive Cards only reduce the risk when Power Automate handles the data deterministically and Copilot receives only static acknowledgements/status codes. If card content or card response is sent back to Copilot for summarization, the same risk returns. |
| Copilot as router, not data renderer | Correct architectural pattern for avoiding XPIA triggers. | Fully agreed. This should become a project-level architecture rule, not just an implementation suggestion. Copilot can still answer executive questions, but only from curated, bounded summaries. |
| Wave-based incremental delivery | Smart. Avoids big-bang risk and allows proof-gate decisions. | Agreed. The wave model is still the right delivery mechanism, but I accept the peer review's point that the first wave should include a minimal XPIA diagnostic/unblock before broader card/Planner work. |
| Wave 2 as proof gate before continuing | Essential. Do not invest in Waves 3-7 until the known failing command is proven safe. | Agreed. The proof gate must be `ListarTarefas` because it is the cleanest known repro and does not require a write. However, the proof can be done in two stages: first remove/minimize the action call, then implement the card route if the owner wants the TO-BE path immediately. |
| "What We Keep" inventory | Accurate. SharePoint schema, ProjectID model, logical delete, QA evidence, STT feature — all preserved. | Agreed. This directly answers the owner concern: we are not discarding prior work. We are reusing the data model, flow validations, runtime evidence, IDs, governance rules, and most topics as inputs to a safer interaction model. |
| Review-before-write for STT | Correct governance pattern for free-form or transcribed input. | Fully agreed. This is mandatory for the differentiated speech-to-text capability. Speech-to-text should never write directly; it must prefill a review card and require explicit confirmation. |
| Executive queries returning short summaries | Correct. Keeps Copilot responses small and curated to avoid RAI triggers. | Agreed. This is the right compromise for directors: Copilot remains the executive interface, while details go to Teams cards or SharePoint/Planner views. |

---

## 3. Concerns and Gaps

### 3.1 The Plan Skips the Cheapest Fix

Our independent research (`STUDY_XPIA_MITIGATION_v3_16_20260514.md`) discovered that:

- **ListarTarefas flow** computes task data (IDs, counts, ProjectID) but **never returns it to the user**. The flow response is a hardcoded static sentence. The `Compose_Lista` variable is computed and discarded. Removing the action call loses ZERO user-facing functionality.

- **CriarTarefa flow** returns `"Tarefa criada com sucesso. ID: 16 ProjectID: PRJ-274E5ACC"` — the only dynamic data the user actually sees. Changing this to a status code (`"success"`) and having the topic display a static message is a minimal change.

These fixes could be applied in **1-2 hours** and would immediately test whether the XPIA block is caused by flow output content or by the action call itself. The macro plan does not mention this option.

### 3.2 Planner Integration is Scope Creep

Waves 3-4 introduce Planner create/update/sync. This is a **new feature**, not a fix for the XPIA blocker. Bundling it into the "fix" plan risks:

- Delaying the actual unblock while Planner permissions, Plan IDs, and Bucket IDs are sorted out
- Increasing the testing surface for what should be a focused bug fix
- Creating new dependencies (Planner connector permissions, Team/channel routing) that may block progress

**Recommendation**: Separate Planner integration into its own feature track (v4.0 roadmap).

### 3.3 Missing Quick Wins

The plan does not mention two agent-level settings that can be changed in minutes via the Copilot Studio UI:

1. **Content moderation level**: Currently likely set to "High". Lowering to "Medium" reduces the XPIA detection sensitivity threshold.
2. **Orchestration mode**: Verifying the agent uses "Classic" orchestration (not "Generative") reduces the AI planning surface area.

These are additive mitigations with zero risk and zero engineering effort.

### 3.4 Adaptive Cards Complexity is Underestimated

Posting Teams Adaptive Cards from Power Automate requires:

- Proper channel or direct-chat routing configuration
- Teams connector or Graph API permissions
- Card JSON schema authoring and testing
- Error handling for delivery failures
- Considerations for card versioning and Teams client compatibility

The Wave 2 estimate of 1-1.5 days may be optimistic for a first-time implementation of this pattern.

### 3.5 Timeline Optimism

The 7-12 day estimate for the full TO-BE revision assumes:

- No import/publish friction in Copilot Studio
- No YAML debugging cycles
- Smooth Planner connector permission grants
- Owner availability for all runtime validation steps

In practice, Copilot Studio solution import/publish cycles and tenant permission workflows can easily double these estimates. A more realistic range for the full revision is **12-20 days**.

---

## 4. Recommended Sequencing

The plan should be restructured into two distinct tracks:

### Track A — XPIA Unblock (Priority: CRITICAL, Effort: 1-2 days)

| Step | Action | Effort | Codex Detailed Comment |
|---|---|---:|---|
| A1 | Minimize ListarTarefas flow output or remove action call | 1 hour | Agreed as a diagnostic and short-term unblock. For `ListarTarefas`, v3.15 already returned static text and still triggered the block, so the next useful experiment is not "smaller output"; it is "no action call" or "action that does not load SharePoint rows". This is a valid fast proof. |
| A2 | Change CriarTarefa flow to return status codes only | 1 hour | Agreed. This is low-cost and aligns with the TO-BE rule that Copilot should not display operational IDs as dynamic chat text. The task ID can be verified in SharePoint/Planner or delivered through a Teams card. |
| A3 | Update CriarTarefa topic to use conditional branching with static messages | 1 hour | Agreed. The implementation should avoid inserting `{Topic.Result}` directly into `SendActivity`. Use explicit branches such as `success`, `not_found`, `invalid_date`, `sp_write_failed`. |
| A4 | Lower agent moderation level to Medium | 5 minutes | Partially agree. This is not zero-risk; it is a governance/security setting. Also, the owner already tested moderation changes and the primary repro still failed. Keep as a controlled setting check, not as the main fix. |
| A5 | Verify Classic orchestration mode | 5 minutes | Agree as a check. However, this should not be treated as sufficient. The observed issue can still occur if classic topics call actions that load large connector context. |
| A6 | Test in fresh Copilot session | 30 minutes | Agreed. Must use a fresh test session after publish because Copilot runtime/session state can preserve old behavior and confuse evidence. |
| A7 | Collect runtime evidence (screenshots, transcript) | 30 minutes | Agreed. Evidence must include chat transcript, topic trace screenshot, flow run URL/status, and SharePoint/Planner verification where applicable. |

**Decision Gate after Track A:**

- If XPIA block is **resolved** → Ship v3.16 with minimal fix. Schedule Track B as v4.0.
- If XPIA block **persists** → Escalate to Track B immediately.

### Track B — Adaptive Cards Architecture (Priority: HIGH, Effort: 7-12 days)

This is the Codex macro plan Waves 0-7, executed only if Track A fails or as a planned product evolution.

### Why This Matters

| Approach | Time to Unblock | Risk | Cost if Wrong | Codex Detailed Comment |
|---|---:|---|---|---|
| Track A first (minimal fix) | Hours to 1 day | Low | If it fails, proceed to Track B (no time wasted) | I agree this is the best diagnostic sequence. The only caveat is product strategy: Track A may unblock v3.16 but does not deliver the owner's selected TO-BE. It should be positioned as containment/diagnostic, not as the final architecture. |
| Track B first (full architecture) | 3-5 days minimum | Medium-High | If minimal fix would have worked, 3-10 days wasted | I agree this is riskier if the sole goal is emergency unblock. I disagree if the owner has explicitly decided to move to card-first + Planner now. In that case, Track B is not wasted work; it is strategic implementation. The best compromise is Track A in parallel with Wave 0/Wave 1 documentation and readiness. |

---

## 5. Specific Feedback by Wave

| Wave | Feedback | Codex Detailed Comment |
|---|---|---|
| Wave 0 | Correct. But should produce a binary decision: minimal fix (Track A) or full architecture (Track B). | I agree Wave 0 needs a formal decision gate, but I would not force a binary choice. Recommended decision model: Track A for immediate containment, Track B for approved TO-BE architecture. They can overlap because documentation/readiness work does not block the fast diagnostic patch. |
| Wave 1 | Correct. But this is a dependency for Track B only. Do not block Track A on Planner readiness. | Agreed. Planner Plan IDs, Bucket IDs, Teams routing, and permission checks should not delay the minimal XPIA experiment. They are required before the card/Planner product path. |
| Wave 2 | Correct as a proof point. But test the minimal fix first — if it works, Wave 2 becomes a feature, not a fix. | Mostly agree. If Track A works, Wave 2 becomes a strategic architecture/product feature rather than an emergency fix. But given the owner's stated direction, Wave 2 remains planned work, not optional research. |
| Wave 3 | Scope creep. Planner create is a new feature. Separate from the XPIA fix track. | Agree for the emergency fix track; disagree for the product roadmap. Planner create is not necessary to prove XPIA mitigation, but it is part of the declared final destination. It should be separated in tracking, not necessarily postponed to v4.0 if the owner accepts the longer deploy. |
| Wave 4 | Scope creep. Same as Wave 3. | Same position as Wave 3. Planner update should not be mixed with the first XPIA proof, but it belongs in the TO-BE implementation once Wave 2 proves the pattern. |
| Wave 5 | Correct. STT review-before-write is a governance improvement regardless of the XPIA fix. | Fully agreed. STT is a differentiating feature and should be preserved. The review card is what makes it operationally safe. |
| Wave 6 | Correct. Executive summaries are a product improvement. | Agreed. This is also important for adoption: directors will ask Copilot for portfolio status, but Copilot should answer from curated summaries and push detailed lists to cards/tabs. |
| Wave 7 | Correct. QA evidence and rollback planning are essential for any ship decision. | Fully agreed. No final ship without screenshots, flow run evidence, SharePoint/Planner validation, import/publish record, and rollback package. |

---

## 6. Summary

| Dimension | Codex Plan | Reviewer Recommendation | Codex Detailed Comment |
|---|---|---|---|
| Architecture vision | Excellent | Keep as v4.0 roadmap | I agree the architecture is solid, but I do not agree it must be deferred to v4.0. The owner has now indicated preference to move toward Adaptive Cards + Planner even if deploy takes longer. Therefore, classify it as TO-BE approved direction, with Track A as tactical containment. |
| As XPIA fix strategy | Overkill as first move | Try minimal fix first (Track A) | Agreed. Track A should be the first technical experiment because it is cheap and tells us whether the action call/context is the core trigger. |
| Planner integration | Bundled into fix | Separate feature track | Agreed for tracking and risk control. Planner integration should be a separate workstream/gate, but not necessarily a separate release if the owner approves the longer delivery path. |
| Quick wins (moderation, orchestration) | Not mentioned | Add as Day 1 actions | Partially agreed. Add as checks, but do not rely on them. Moderation change was already explored and did not clear the primary repro. Classic/generative orchestration state should be recorded, not treated as root fix. |
| Time to unblock | 3-5 days minimum | Potentially hours with Track A | Agreed. For emergency unblock, Track A is the best move. For durable architecture, the 3-5 day P0 card/Planner estimate remains valid, subject to tenant routing and permission readiness. |
| Risk | Medium-High (new architecture) | Low (surgical output change first) | Agreed. New architecture has more moving pieces. That is why the revised plan should be dual-track: surgical containment first, strategic architecture second. |
| Recommended action | — | Execute Track A, then decide on Track B | Revised Codex recommendation: execute Track A immediately for evidence, while completing governance documentation and readiness for Track B. If Track A solves the blocker, v3.16 can be a containment release and Track B becomes the approved architecture milestone. If Track A fails, Track B becomes the primary remediation path. |

## 6.1 Codex Lead Position

I agree with the peer review's engineering caution: do not spend several days building the full Adaptive Cards + Planner architecture before running the cheapest diagnostic fix. The reviewer is right that `ListarTarefas` and `CriarTarefa` have low-cost changes that can quickly prove whether the XPIA blocker is caused by action/context payloads.

I disagree with treating Adaptive Cards + Planner as merely a future v4.0 idea. The owner has explicitly selected this as the preferred operating model, and it addresses more than the current bug: it improves PM workflow, director summaries, STT governance, Planner adoption, and auditability.

The practical decision is:

```text
Track A: immediate containment and diagnostic release candidate.
Track B: approved TO-BE architecture, implemented only after documentation and readiness gates.
```

This protects schedule while preserving strategic direction. It also prevents us from throwing away prior work: Track A reuses current topics/flows, while Track B reuses SharePoint, Planner, cards, validations, IDs, evidence, and governance contracts.

---

## 7. Bottom Line

> The Codex macro plan is a great TO-BE target architecture for the PMO Intelligent Hub.  
> But test the simple fix before committing to a full architectural rebuild.  
> If a 2-hour output minimization solves the XPIA blocker, you save 10+ days of engineering.  
> The Adaptive Cards + Planner evolution can then be planned properly as a v4.0 product milestone.

---

*Peer review completed: 2026-05-14T19:38 BRT*  
*Research only — no system changes were made.*
