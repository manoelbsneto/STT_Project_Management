# GEMINI FLASH 3.5 — COCKPIT BUILD ADDENDUM #1

**Date:** 2026-05-20 19:09 BRT
**From:** Opus 4.7 (architect)
**To:** GEMINI-FLASH-COCKPIT (you, currently building the cockpit)
**Priority:** HIGH — blocks v1 release if not implemented
**Original prompt:** `.planning/cockpit/dispatch_gemini_flash_cockpit.md`
**Original spec:** `.planning/cockpit/SPECIFICATION.md`

---

## What changed

Owner reviewed v1 spec and identified a critical gap: the cockpit was designed as a **passive monitoring** tool but is missing the **active Mission Control / Dispatch Console** that Owner actually needs.

**FR-11 (Dispatch Console) was added** to the SPEC. Re-read `.planning/cockpit/SPECIFICATION.md` from section "## 5. Functional Requirements" to find FR-11 (it's the new section between FR-10 and the start of Non-Functional Requirements section §6).

---

## Summary of FR-11

A new view at URL `#dispatch` (becomes the **default landing page**, replacing `#dashboard`).

It's the operational core of the cockpit:
- All 12 M2 Phase 1 agents listed grouped by family (Codex#1, Codex#2, Opus, Gemini Flash)
- Per-agent row with: order #, state icon, agent ID, state badge, heartbeat freshness, action buttons
- Action buttons: Copy prompt to clipboard, Open file in OS, Mark as dispatched, Reset
- State machine: PENDING → DISPATCHED (localStorage) → CHECKED_IN (auto from ACTIVITY_LOG) → IN_PROGRESS → DONE/BLOCKED (or DEAD if heartbeat >10min)
- Wave progress KPIs at top
- Optional audio chime on state transitions
- Drag-to-reorder
- Snapshot export

---

## Implementation impact on your build sequence

### What changes in your existing plan

- **Step 5** (orchestrator + dashboard view): also build Dispatch Console as the **primary view** since it's now the default landing page. Estimated +30 min.
- **Step 6** (remaining views): Dashboard becomes secondary. Save Dashboard implementation last.

### Updated step priority

```
Step 5 (extended):
   - Build orchestrator (polling, state mgmt, hash routing)
   - Build Dispatch Console (FR-11) — PRIMARY VIEW
   - Build basic Dashboard (FR-01) — secondary, can be minimal v1

Step 6 (revised order):
   1. renderAgentRoster (FR-02)
   2. renderActivityFeed (FR-03)
   3. renderPhaseTracker (FR-04)
   4. renderPromptsLibrary (FR-06) — secondary, simplified since FR-11 covers most prompt interaction
   5. renderHandoffMap (FR-05) — last, lowest priority
```

### New time budget

Total estimate adjusts from 4-6h to **5-7h** due to FR-11 addition.

If hitting time pressure, FR-05 (Handoff Map) can ship as v1.1 (deferred). FR-11 is non-negotiable for v1.

---

## Specific FR-11 implementation guidance

### State storage (CRITICAL)

The cockpit should NOT write to disk. State storage strategy:

- **localStorage** for "dispatched intent" (owner clicked Mark Dispatched)
  - Keys: `cockpit.dispatch.<agent_id>` value: ISO timestamp
  - Keys: `cockpit.dispatch_order` value: JSON array of agent IDs
  - Keys: `cockpit.audio_enabled` value: bool
- **ACTIVITY_LOG.md (read-only)** for actual agent state (CHECKIN, HEARTBEAT, CHECKOUT)
- Server stays read-only. NO new POST/PUT endpoints.

### Computed state per agent

```javascript
function computeAgentState(agentId, localStorageDispatched, activityLog) {
  const checkin = activityLog.findLast(e => e.agent_id === agentId && e.operation === 'CHECKIN');
  const lastHeartbeat = activityLog.findLast(e => e.agent_id === agentId && (e.operation === 'HEARTBEAT' || e.operation === 'CHECKIN'));
  const checkout = activityLog.findLast(e => e.agent_id === agentId && e.operation === 'CHECKOUT');

  if (checkout) {
    return checkout.fields.status === 'DONE' ? 'DONE' : 'BLOCKED';
  }
  if (!checkin) {
    return localStorageDispatched ? 'DISPATCHED' : 'PENDING';
  }
  if (!lastHeartbeat) {
    return 'CHECKED_IN';
  }
  const ageSeconds = (Date.now() - new Date(lastHeartbeat.timestamp)) / 1000;
  if (ageSeconds > 600) return 'DEAD';
  if (ageSeconds > 300) return 'STALE';
  return 'IN_PROGRESS';
}
```

### Clipboard integration

```javascript
async function copyPromptToClipboard(promptId) {
  const response = await fetch(`/api/prompts/${promptId}/content`);
  const data = await response.json();
  await navigator.clipboard.writeText(data.content);
  showToast(`Prompt copied (${data.size_bytes} bytes). Paste in agent IDE.`);
}
```

### Audio cues

Use tiny base64 WAV data URIs embedded in cockpit.js. Sample sources:
- "click" — single soft tone (200Hz, 50ms)
- "ding" — bell-like (800Hz, 200ms with reverb)
- "alarm" — alternating tones (300Hz/600Hz, 600ms)
- "fanfare" — ascending chord (400Hz/600Hz/800Hz, 1.2s)

You can synthesize these with the Web Audio API in cockpit.js if you prefer (no need for actual audio files):

```javascript
function playTone(frequency, durationMs, volume = 0.1) {
  const ctx = new (window.AudioContext || window.webkitAudioContext)();
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.frequency.value = frequency;
  osc.type = 'sine';
  gain.gain.value = volume;
  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start();
  osc.stop(ctx.currentTime + durationMs / 1000);
}
```

### Reorder UX

Use HTML5 native `draggable="true"` + `dragstart`/`dragover`/`drop` events. No external library needed.

```html
<div class="dispatch-row" draggable="true" data-agent-id="CODEX-1-LEAD">...</div>
```

### Default view

In `index.html` initial state, set `#dispatch` view as default active. URL hash routing should default to `#dispatch` if hash is empty.

### Visual fidelity target

The user explicitly requested **"Fortune 500 / C-Level / SpaceX launch console"** aesthetic. This means:

- Dense information layout but with clear visual hierarchy
- Mono-spaced font (JetBrains Mono, already loaded) for technical fields
- Strong color semantics (status badges instantly readable)
- Subtle animations (avoid distracting movement during operations)
- Group families with subtle border boxes
- Top wave progress = HERO of the page (large, prominent)
- Reduce visual noise — no decorative elements that don't carry data

Reference visual style:
- Indra brand intact (cyan/teal accents on deep navy)
- High data density, low chrome
- Like a flight management console, not a marketing dashboard

---

## Acceptance criteria additions

In addition to spec §12 hard gates, add these for FR-11:

- [ ] `#dispatch` is the default landing page (URL with no hash redirects there)
- [ ] All 12 M2 Phase 1 agents listed in 4 family-grouped panels
- [ ] Order numbers ① through ⑫ visible and match recommended sequence
- [ ] "Copy prompt" button fetches /api/prompts/<id>/content and copies to clipboard
- [ ] "Mark dispatched" persists to localStorage with timestamp
- [ ] State auto-transitions PENDING→DISPATCHED→CHECKED_IN→IN_PROGRESS→DONE based on logs
- [ ] DEAD detection accurate (>10min no heartbeat → red status)
- [ ] Wave progress bar updates correctly (X/12 dispatched, Y/12 online, Z/12 done)
- [ ] Reorder drag-and-drop persists order to localStorage
- [ ] Audio toggle works, plays sounds via Web Audio API on transitions
- [ ] Snapshot download includes localStorage state + computed agent states
- [ ] Reset confirmation modal works
- [ ] Visual treatment matches Fortune 500 / launch-console aesthetic
- [ ] Dispatch Console works on Chrome 110+, Firefox 110+

---

## Action required from you

1. Acknowledge this addendum in your next response: "Addendum #1 received and integrated into build plan."
2. Re-read SPECIFICATION.md sections FR-11 (around lines 350-470 of the updated spec)
3. Adjust your build plan: Step 5 extended, Step 6 reordered
4. Continue build with FR-11 as primary view
5. Self-validate against the 13 new acceptance criteria above

If any FR-11 detail is ambiguous, ask via this dispatch (Owner will relay to me Opus 4.7) — do NOT silently improvise on visual style or state machine.

---

## No other changes

Everything else in the spec stays valid. Same hard constraints, same tech stack, same deliverables list. Just FR-11 added.

---

*Addendum #1 — locked 2026-05-20 19:09 BRT*
