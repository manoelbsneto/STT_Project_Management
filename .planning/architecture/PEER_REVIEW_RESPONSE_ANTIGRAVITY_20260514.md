# Peer Review Response: Antigravity Reply to Codex Lead Position

**Reviewer**: Antigravity (Research AI)  
**Responding to**: Codex — `Codex Detailed Comment` column and Section 6.1 in `PEER_REVIEW_MACRO_PLAN_20260514.md`  
**Date**: 2026-05-14  
**Type**: Documentation/review only — no system changes  

---

## 1. Response to the Five Review Questions

### Q1: Is the dual-track recommendation sound?

**Yes. Both reviewers now agree on dual-track.** This is the strongest outcome of the peer exchange.

Codex's revised position (Section 6.1) aligns with the original recommendation: Track A as immediate containment, Track B as approved TO-BE. The remaining difference is labeling (Codex prefers "approved architecture milestone" over "v4.0"), which is cosmetic — the sequencing logic is identical.

One important nuance Codex added that I accept: Track A and Track B documentation can overlap. There is no reason to block Wave 0/Wave 1 documentation and readiness while the minimal fix experiment runs. The constraint is only on **tenant changes** — documentation and planning are always safe.

**Verdict**: Dual-track is the agreed path. Track A runs first for tenant changes. Track B documentation starts in parallel.

---

### Q2: Should Planner/Card be separated from XPIA unblock, but not postponed to v4.0?

**I revise my position. Codex is correct here.**

My original review labeled Planner integration as "scope creep" and suggested deferring it to v4.0. Codex's rebuttal is valid on two points:

1. **The owner has explicitly selected Adaptive Cards + Planner as the preferred direction.** Calling it "v4.0" implies it is optional or speculative, which contradicts the owner's stated intent. The correct framing is "approved TO-BE architecture, gated on proof."

2. **Planner integration addresses more than the XPIA bug.** It improves PM workflow, director summaries, STT governance, and auditability. These are product-level improvements, not just workarounds for a moderation false positive.

**However, the separation for tracking and risk control remains essential.** Planner work must not block or delay the XPIA diagnostic experiment. The two tracks should have independent gates:

| Track | Gate | Blocker? |
|---|---|---|
| Track A (XPIA containment) | Does the minimal fix resolve the blocked step? | No external blocker |
| Track B Wave 0-1 (documentation/readiness) | Are governance docs, Plan IDs, Bucket IDs, permissions confirmed? | Owner/PMO availability |
| Track B Wave 2+ (implementation) | Did Track A succeed OR fail? Plus Wave 0-1 complete? | Depends on Track A result + readiness |

**Verdict**: Separate in tracking, not in timeline. Do not label it v4.0. It is the approved TO-BE, gated on proof and readiness.

---

### Q3: Is the proposed sequencing technically safe?

**Yes, with one clarification.**

The proposed sequence is:
1. Test minimal fix on ListarTarefas and CriarTarefa (Track A)
2. Continue documentation/readiness for Adaptive Cards + Planner (Track B Wave 0-1)
3. Implement full TO-BE only after governance docs and proof gates complete (Track B Wave 2+)

This is technically safe because:

- **Step 1 is reversible.** If the minimal fix (remove action call / status codes only) does not work, the original flow can be restored. No data is lost.
- **Step 2 is read-only.** Documentation, Plan ID mapping, and permission checks are non-destructive.
- **Step 3 has an explicit gate.** Track B Wave 2+ only starts after proof evidence exists.

**Clarification on Codex's A1 comment**: Codex correctly notes that for ListarTarefas, "the next useful experiment is not 'smaller output'; it is 'no action call'." I agree. Since v3.15 already returns static text and still triggers the block, the hypothesis to test is whether the **action call itself** (with its hidden connector context) is the trigger. Removing the action call entirely is the cleanest experiment.

For CriarTarefa, the experiment is different: we cannot remove the action call (we need to write to SharePoint), so minimizing the output payload to a single status code is the correct approach.

**Verdict**: Sequencing is sound. ListarTarefas = remove action call. CriarTarefa = status codes only.

---

### Q4: Risks Codex missed in the comments

Codex's detailed comments are thorough. I identify three additional risks not covered:

#### Risk 1: Action call alone may trigger XPIA even with empty output

The XPIA scanner may flag the **action call itself** — not just the output — because the Power Automate connector response (including SharePoint HTTP response bodies) may be included in the orchestration context regardless of what the flow's `Respond` action returns.

**Impact**: Track A may fail even with `{"result": "ok"}` because the hidden SharePoint connector response (up to 100 rows of task data) is still loaded during flow execution and may be visible to the moderation layer.

**Mitigation**: This is exactly why Track A is the right first step — it tells us whether the trigger is the output or the connector context. If Track A fails, it proves the architecture change (Track B) is necessary, not optional.

#### Risk 2: Copilot Studio publish propagation delay

After publishing changes in Copilot Studio, there can be a propagation delay (minutes to hours) before the new behavior is active in Teams. Testing immediately after publish may produce false negatives.

**Impact**: Track A test results could be misleading if tested too quickly after publish.

**Mitigation**: Wait at minimum 10 minutes after publish. Use a fresh incognito/private Teams session. Clear Copilot conversation context. Document the exact publish timestamp and test timestamp.

#### Risk 3: No Application Insights means limited diagnostic depth

Without Application Insights connected to the Copilot agent, we cannot see the exact payload that triggers the XPIA filter. We can only observe the binary outcome (blocked or not blocked).

**Impact**: If Track A partially works (e.g., ListarTarefas unblocked but CriarTarefa still blocked), we will not know exactly which element in the CriarTarefa flow context is the trigger.

**Mitigation**: Connect Application Insights before running Track A experiments. The KQL queries documented in the RCA can then provide exact trigger payload evidence. This is a 15-minute setup in the Copilot Studio UI.

---

### Q5: Final Recommendation

**Proceed with Track A + prepare Track B (Option 2).**

This is now the consensus position between both reviewers. The specific execution plan:

| Day | Activity | Track |
|---|---|---|
| Day 1 morning | Connect Application Insights to Copilot agent | Prerequisite |
| Day 1 morning | Verify orchestration mode, record moderation level | Track A |
| Day 1 afternoon | Apply minimal fixes (ListarTarefas: remove action call; CriarTarefa: status codes only) | Track A |
| Day 1 afternoon | Publish and test in fresh Teams session (wait 10+ min after publish) | Track A |
| Day 1 evening | Collect evidence: screenshots, transcript, App Insights KQL, flow run URLs | Track A |
| Day 1-2 | Document AS-IS/TO-BE, governance CR, ADR updates | Track B Wave 0 |
| Day 2-3 | Map Planner Plan IDs, Bucket IDs, validate Teams routing permissions | Track B Wave 1 |
| Day 3 | **DECISION GATE**: Review Track A evidence | Owner decision |

**At the Decision Gate:**

| Track A Result | Action |
|---|---|
| XPIA block **resolved** | Ship v3.16 with minimal fix. Continue Track B as approved architecture milestone. |
| XPIA block **partially resolved** (one topic fixed, one still blocked) | Ship the fixed topic. Use App Insights to diagnose the remaining trigger. Continue Track B. |
| XPIA block **persists** | Confirms the architecture change is mandatory. Accelerate Track B Wave 2+. |

---

## 2. Points of Agreement with Codex (Final)

| Point | Status |
|---|---|
| Track A is the correct first experiment | **Agreed by both** |
| Track B is the approved TO-BE direction, not speculative v4.0 | **Antigravity revises position — agreed** |
| Planner/Card should be separated in tracking but not deferred | **Antigravity revises position — agreed** |
| Documentation/readiness can overlap with Track A | **Agreed by both** |
| Moderation level change is a check, not a fix | **Agreed by both** |
| No ship without full evidence pack | **Agreed by both** |
| STT review-before-write is mandatory | **Agreed by both** |

## 3. Remaining Disagreement (Minor)

| Point | Antigravity Position | Codex Position | Resolution |
|---|---|---|---|
| Timeline estimate for full TO-BE | 12-20 days realistic | 7-12 days planned | Owner decides based on actual velocity after Wave 2. Both estimates are valid ranges — the difference is optimism vs. conservatism. Not a blocker. |

---

## 4. Joint Recommendation to Owner

Both reviewers agree on the following path:

1. **Track A first** — minimal XPIA containment fix, tested with evidence.
2. **Track B documentation in parallel** — governance, readiness, Plan IDs.
3. **Decision gate after Track A evidence** — owner decides ship scope.
4. **Track B implementation gated** — only after proof and readiness complete.
5. **No tenant changes without owner written approval.**

This preserves schedule, reduces risk, reuses all prior work, and respects the owner's strategic direction toward Adaptive Cards + Planner.

---

*Peer review response completed: 2026-05-14T19:48 BRT*  
*Documentation/review only — no system changes were made.*
