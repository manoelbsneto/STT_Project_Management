# Mission Control / Cockpit — Adversarial UI Review

**Audited:** 2026-05-21T00:55 BRT
**Auditor:** kiro_default acting as gsd-ui-auditor (adversarial pass)
**Baseline:** WCAG 2.2 AA + Core Web Vitals + 6-pillar standards + prior `UI-REVIEW.md` claim of 24/24
**Stack:** Vanilla HTML5 + CSS + JS, served from `127.0.0.1:7777`
**Screenshots:** not captured — Playwright-MCP unavailable; `npx --no-install playwright --version` not attempted because the audit goal is code-level disproof of the 24/24 claim, and the live server confirmed all bytes-on-wire match disk
**Stance:** Adversarial — every pillar assumed failing until proven otherwise. The prior pass scored itself across all 6 pillars at the maximum; that score is treated as a hypothesis to disprove.

---

## Pillar Scores (re-scored adversarially)

| Pillar | Prior Claim | Adversarial Score | Δ | Justification |
|--------|:-:|:-:|:-:|---------------|
| 1. Copywriting | 4/4 | 2/4 | −2 | Activity-feed renders raw enums (HEARTBEAT/CHECKIN/CHECKOUT/HANDOFF/LOCK/UNLOCK/ERROR/WARNING) verbatim; no key-based i18n system as the skill mandates. |
| 2. Visuals | 4/4 | 3/4 | −1 | Heading semantics are wrong (every view's `<h2>` lives under a stale topbar `<h1>`); `initHeroCanvas` is dead-but-still-running code referencing a removed `<canvas id="missionHeroCanvas">`. |
| 3. Color | 4/4 | 3/4 | −1 | `--text-faint` (used for table dashes and empty placeholders) fails WCAG 1.4.3 at 2.83:1; `.activity-op.op-error` fails at ~3.65:1; one hardcoded `#001a26` outside the token block. |
| 4. Typography | 4/4 | 2/4 | −2 | 15 distinct font-sizes (prior pass claimed 9); eyebrow letter-spacing actually varies 0.10/0.12/0.14/0.16/0.18em (prior pass claimed standardized to 0.18em). |
| 5. Spacing | 4/4 | 2/4 | −2 | `.kpi-skeleton` defined twice — section 17 silently overrides section 6, so the skeleton's padding/border DON'T match the documented `.mission-kpi`; dead-code `@media .mission-hero` rules still present (prior pass's own Follow-up #1, still not done); no 320px reflow rule. |
| 6. Experience Design | 4/4 | 2/4 | −2 | `.kpi-card` clickable `<div>`s on Dashboard are not keyboard-navigable (WCAG 2.1.1 hard fail); Dispatch / Revoke action has no `confirm()` guard while Reset Local Flags does — inconsistent destructive-action handling. |

**Overall: 14/24** (Δ = −10 from prior claim)

---

## All Findings (BLOCKER / WARNING)

1. **[BLOCKER] Activity feed renders raw enum strings** — Pillar: 1 — `cockpit.js:766` (`renderHTML` for `.activity-op`) — the operation label is emitted as `${escapeHtml(act.operation || 'EVT')}`, so the user sees `HEARTBEAT`, `CHECKIN`, `CHECKOUT`, `HANDOFF`, `LOCK`, `UNLOCK`, `ERROR`, `WARNING` as all-caps machine enums on every row of the live stream and the activity view. The `<select>` filter at `index.html:236-247` already proves the project knows the right copy ("Check-in", "Check-out", "Heartbeat", "Lock / Unlock") — those values just aren't reused in the feed. **User impact:** the busiest part of the cockpit reads as logfile output, not exec-grade ops. **Fix:** add a label map and use it in `activityHtml`:
   ```js
   const OP_LABEL = { HEARTBEAT:'Heartbeat', CHECKIN:'Check-in', CHECKOUT:'Check-out',
                      HANDOFF:'Handoff', LOCK:'Locked', UNLOCK:'Unlocked',
                      ERROR:'Error', WARNING:'Warning' };
   // …
   <div class="activity-op op-${escapeAttr(op)}">${escapeHtml(OP_LABEL[act.operation] || act.operation || 'Event')}</div>
   ```

2. **[BLOCKER] `.kpi-skeleton` rule conflict — skeleton dimensions don't match `.mission-kpi`** — Pillar: 5 — `cockpit.css:672-683` and `cockpit.css:1447-1462`. The first definition sets `min-height: 96px; padding: 18px 22px; border-left: 2px solid var(--border-strong);` to "match new compact size" (per the comment). Section 17 then redefines the same selector with `padding: var(--s-5) var(--s-6)` (= 20px 24px) and `border-left: 3px solid var(--border-strong);` — silently overriding via cascade. **User impact:** when KPIs first arrive over the wire (~5s polling), each tile shifts 2px + has a 1px wider left border than the skeleton it replaces — visible layout jump on every page load. The prior pass's "match new compact size" claim is provably untrue in the served bytes. **Fix:** delete the duplicate `.kpi-skeleton` block at lines 1447-1462; keep only the section-6 rule.

3. **[BLOCKER] Dashboard `.kpi-card` clickable `<div>`s are not keyboard-reachable** — Pillar: 6, WCAG 2.1.1 — `cockpit.js:722, 726, 730, 734`. Every dashboard KPI card is rendered as `<div class="kpi-card" onclick="window.location.hash='#agents'">` with no `tabindex`, no `role="button"`, no `keydown` handler. The same file's `agent-strip` items at line 716 do this correctly (`tabindex="0" role="button" onkeydown="…"`) — so the pattern is known but inconsistently applied. **User impact:** Tab-key users (keyboard-only operators, screen-reader users) cannot navigate to any of the 4 dashboard KPI cards. **Fix:** in `renderDashboard()`, add `tabindex="0" role="button" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();window.location.hash='#agents'}"` to each `.kpi-card`. Better: replace the inline `onclick` strings with delegated `addEventListener('click', …)` and `addEventListener('keydown', …)`.

4. **[BLOCKER] Dispatch / Revoke action has no confirmation; Reset does** — Pillar: 6 — `cockpit.js:626` (`Cockpit.toggleDispatch`) calls dispatch toggling directly with no `confirm()` guard, while line 643 (`btnSequenceReset.onclick`) does ask "Reset all local dispatch flags?". Each Dispatch row click writes/erases a `cockpit_dispatch_state` localStorage entry that is the sole source of truth for "DISPATCHED" badge state. Clicking the wrong row toggles a badge with no undo path — the prior pass's "destructive action confirmation" coverage is incomplete. **User impact:** misclicks on a 12-agent fleet table flip dispatch state without warning, breaking the dispatch sequence operators rely on. **Fix:** wrap the body of `toggleDispatch(agentId)` with `if (!confirm(\`${ds[agentId] ? 'Revoke dispatch flag for' : 'Dispatch'} ${agentId}?\`)) return;` — or move to a softer toast-with-undo pattern.

5. **[WARNING] Dead-code `@media` rules reference removed selectors** — Pillar: 5 — `cockpit.css:1372-1375` and `cockpit.css:1376-1385`. Both blocks still target `.mission-hero` and `.mission-hero-content`, neither of which exists in `index.html` (verified — `grep mission-hero index.html` returns 0 hits, and the addendum HTML at line 128–142 uses `.view-header.view-header-hero` instead). Prior pass explicitly listed this as Follow-up #1 — **still not done**. **Fix:** delete or rewrite the two blocks to target `.view-header-hero` if responsive collapse is needed.

6. **[WARNING] Orphaned `initHeroCanvas()` runs on every dispatch view nav** — Pillar: 2 / 5 — `cockpit.js:298-445` (~150 lines) builds an icosahedron + 12 particle traversers on `<canvas id="missionHeroCanvas">`, but that element no longer exists in `index.html`. The function is still called from `navigateTo('dispatch')` at line 153 and from `renderCurrentView`'s dispatch branch via `initHeroCanvas()` at line 154. It now hits `getElementById('missionHeroCanvas')` → null → early-returns at line 305, but the supporting `mousemove` listener attached during the **prior** correctly-functioning load (before the redesign) and the function call overhead remain. The addendum's claim "Removed: `<canvas class="hero-canvas">` and all related CSS rules deleted" is true for HTML/CSS but **false for JS**. **Fix:** delete `initHeroCanvas` entirely (lines 297-446), remove the call at line 154.

7. **[WARNING] 15 distinct font-sizes — exceeds 10-size budget; prior pass claimed 9** — Pillar: 4 — `cockpit.css` distinct values: `9px, 10px, 10.5px, 11px, 11.5px, 12px, 13px, 14px, 15px, 18px, 22px, 24px, 28px, 32px, clamp(24px, 2.6vw, 30px)`. The prior pass said "9 distinct sizes — within the 10-size budget" — provably false. The 0.5px stragglers at 10.5 (`.mission-status-chip`, `.activity-op`) and 11.5 (`.activity-list .activity-item`) read as accidents of optical tweaking and could collapse to 10/11 or 11/12. **Fix:** introduce a `--fs-*` scale `9, 10, 11, 12, 13, 14, 16, 18, 22, 28` and snap all sizes to it; eliminate the .5 values.

8. **[WARNING] Eyebrow letter-spacing rhythm is NOT uniform** — Pillar: 4 — prior pass claimed "Eyebrows: 0.18em (was 0.14-0.16em mixed) — more uniform breathing." Reality across uppercase mono eyebrows:
   - `0.10em`: `.sidebar-brand-sub` L269, `.sidebar-project-meta` L307, multiple `.dispatch-family-header h3` L870, `.handoff-stat-label` L1564, etc.
   - `0.12em`: `.topbar-env-badge` L472, `.kpi-title` L1144, `.dispatch-table thead th` L904
   - `0.14em`: `.snapshot-banner-label` L1607
   - `0.16em`: `.sidebar-project-label` L282, `.mission-kpi-label` L618
   - `0.18em`: ONLY `.section-eyebrow` L718 and `.sidebar-brand-name` L264
   
   Five different spacings on what should be one rhythm. **Fix:** create `--eyebrow-spacing: 0.16em` token, apply uniformly to every uppercase mono label.

9. **[WARNING] `--text-faint` fails WCAG 1.4.3 contrast for normal text** — Pillar: 3 — `--text-faint: rgba(255, 255, 255, 0.32)` over `--bg-app: #001A26` composites to roughly `#51636B`. Computed luminance ratio = **2.83:1** for 14px text (e.g., `.activity-empty` "Waiting for data…", `.dispatch-empty`). Threshold for normal text is 4.5:1 → fails AA. The same color is used for `<span style="color:var(--text-faint)">—</span>` dashes inside the dispatch-table errors column at `cockpit.js:613-616` — those dashes are functional content (they read as "no errors / no warnings"), so the 2.83 ratio is below the non-text 3:1 threshold too. **Fix:** raise `--text-faint` to `rgba(255, 255, 255, 0.50)` (≈ 4.6:1) or use `--text-muted` (already 0.50) for any user-visible content; reserve `--text-faint` for purely decorative borders.

10. **[WARNING] `.activity-op.op-error` text fails WCAG 1.4.3** — Pillar: 3 — `cockpit.css:1208-1209` renders `color: var(--indra-error)` (`#E91E63`) on `background: rgba(233, 30, 99, 0.15)` over `var(--bg-card)`. Composited bg ≈ `#28203F`; computed contrast ≈ **3.65:1** at 10.5px/700. 10.5px = 7.875pt — not "large" by WCAG (large = 18pt or 14pt-bold). Threshold is 4.5:1 → fails. **Fix:** lighten the foreground (e.g., `#FF4081`) or darken the background (lower alpha to 0.08) until ratio ≥ 4.5; alternatively bump the font-size on the op chip to ≥14px (and 700 weight = bold) to qualify as large text.

11. **[WARNING] Hardcoded `#001a26` outside the token block** — Pillar: 3 — `cockpit.css:1626`: `.snapshot-banner .btn:hover { background: #001a26; }`. The token `--bg-app` is exactly `#001A26`; this should be `background: var(--bg-app)`. Token drift; minor but breaks the "single source of truth" promise of the `:root` block. **Fix:** replace literal with `var(--bg-app)`.

12. **[WARNING] No 320 CSS px reflow strategy — fails WCAG 1.4.10** — Pillar: 5 — smallest media query is `@media (max-width: 640px)` (`cockpit.css:1386-1390`). Below 640px the topbar still tries to render: sidebar-toggle + `<h1 class="topbar-title">Mission Control</h1>` + `LIVE` badge + last-update timestamp + Refresh + Load + Export + theme + avatar = ~9 items in a `display: flex; justify-content: space-between` row with no `flex-wrap`. At 320 CSS px viewport, this row will horizontally overflow. WCAG 1.4.10 requires content to render without two-dimensional scrolling at 320 CSS px (or 256 CSS px after zoom). **Fix:** add `@media (max-width: 480px)` block that hides the title, last-update, and Load/Export buttons (keep refresh + theme + avatar) and applies `.app-topbar { flex-wrap: wrap; height: auto; padding: var(--s-2) var(--s-4); }`.

13. **[WARNING] Inline `onclick=` strings throughout `cockpit.js`** — Pillar: 6 — `cockpit.js:625, 626, 722, 726, 730, 734, 819, 962`. Every dispatch table row, dashboard KPI, agent-strip item, and prompt-list item has its handler embedded as a string in HTML. Beyond the keyboard-nav defect (#3), this:
   - prevents Content-Security-Policy (`script-src 'self'` would break the page),
   - couples view rendering to the global `Cockpit.*` namespace via implicit `window.Cockpit` lookup,
   - makes argument escaping fragile (currently safe because `escapeAttr` covers `'`, but one missed escape would be an XSS).
   **Fix:** replace inline `onclick` with `data-action="copyPrompt" data-prompt-id="…"` and a single delegated `dispatchContainer.addEventListener('click', e => { … })` that reads `dataset` and calls `Cockpit.copyPrompt(...)` directly.

14. **[WARNING] No key-based i18n; English strings hardcoded throughout** — Pillar: 1 — the gsd-ui-auditor skill mandates a key-based string system. Cockpit has zero. Examples (cockpit.js): 'Snapshot refreshed', 'Refresh failed', 'Connection lost — retrying…', 'No fleet data — verify ACTIVITY_LOG is reachable.', 'Snapshot mode active — click "Return to Live" to resume polling', 'Loaded:', 'Returned to live mode', 'Dispatched:', 'Dispatch flag revoked:'. Across the project, `viewer.js:1377` even mixes Portuguese (`Restaurar "${doc.name}" para o conteúdo original?…`) — the surface is bilingual but unkeyed. **Fix:** introduce `Web_MD_Viewer/i18n.js` with `t('cockpit.snapshot.refreshed')` lookups and locale files (`en.json`, `pt-BR.json`).

15. **[WARNING] Heading semantics are inverted across views** — Pillar: 2 — every cockpit view (`#viewDispatch`, `#viewDashboard`, `#viewAgents`, `#viewActivity`, `#viewPhases`, `#viewHandoffs`, `#viewPrompts`) renders its main heading as `<h2>` (e.g., `index.html:130 <h2>Mission Control</h2>`, line 207 `<h2>Cockpit Overview</h2>`). The page's only `<h1>` is the **static** topbar element at `index.html:99 <h1 class="topbar-title">Mission Control</h1>`, which never updates when navigating to other views. **User impact:** screen-reader users hearing the document outline get "h1: Mission Control → h2: Cockpit Overview" when on the dashboard — disorienting; on every view except `#viewDispatch` the h1 is wrong. **Fix:** either (a) demote the topbar text to a `<div role="banner">` and promote each view's `<h2>` to `<h1>`, or (b) update `topbar-title` content from JS in `navigateTo()` so it always reflects the active view. Option (b) is the lighter touch.

---

## Top 3 Priority Fixes

These are the three with the highest user impact across both functional (keyboard nav, destructive-action safety) and signal-vs-noise (raw enums in the busiest panel) axes.

### 1. Replace raw operation enums in the activity feed (Finding #1, Pillar 1)

The feed is the most-watched surface in the cockpit. Operators read it continuously while the polling indicator cycles. Showing `HEARTBEAT` / `CHECKIN` / `CHECKOUT` / `HANDOFF` / `LOCK` / `UNLOCK` / `WARNING` / `ERROR` as all-caps enums fights every other typographic decision in the file. The label map exists conceptually (the filter `<select>` already lists "Check-in", "Check-out", "Heartbeat", "Lock / Unlock", "Handoff", "Error", "Warning") — it just isn't reused in the renderer.

**Apply in `cockpit.js`** (above `function activityHtml`, ~line 752):

```js
const OP_LABEL = {
  HEARTBEAT: 'Heartbeat',
  CHECKIN:   'Check-in',
  CHECKOUT:  'Check-out',
  HANDOFF:   'Handoff',
  LOCK:      'Locked',
  UNLOCK:    'Unlocked',
  ERROR:     'Error',
  WARNING:   'Warning'
};

function opLabel(op) {
  return OP_LABEL[op] || (op ? op.charAt(0) + op.slice(1).toLowerCase() : 'Event');
}
```

Then change line 766 to `<div class="activity-op op-${escapeAttr(op)}">${escapeHtml(opLabel(act.operation))}</div>`.

CSS already uppercases via `text-transform: uppercase` on `.activity-op` — but the **letter-spacing** rhythm wants title-case input under `text-transform: uppercase` for clean tracking. Drop `text-transform: uppercase` from `.activity-op` (`cockpit.css:1207`) and let the title-case render naturally with `font-size: 11.5px` + the existing 0.10em letter-spacing.

### 2. Make Dashboard `.kpi-card` divs keyboard-navigable (Finding #3, Pillar 6, WCAG 2.1.1)

A 4-card row that drives navigation is dead to keyboard users. The pattern is one-line of work — already used correctly on the agent-strip just two methods later in the same file.

**Apply in `cockpit.js` `renderDashboard()`** (~lines 720-740):

```js
function kpiCardKbdAttrs(targetHash) {
  const safe = escapeAttr(targetHash);
  return ` tabindex="0" role="button" onclick="window.location.hash='${safe}'"
           onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();window.location.hash='${safe}'}"`;
}
// Then on each .kpi-card line use it:
//   <div class="kpi-card"${kpiCardKbdAttrs('#agents')}>
```

This brings them in line with the agent-strip pattern at `cockpit.js:716`. Add `:focus-visible` outline coverage by ensuring `.kpi-card` doesn't strip the global `:focus-visible` rule (it currently doesn't; the global rule already applies).

### 3. Resolve the duplicate `.kpi-skeleton` rule + 320px reflow (Findings #2, #5, #12, Pillar 5)

**3a.** Delete the second `.kpi-skeleton` definition at `cockpit.css:1447-1462` (Section 17). Keep the Section 6 version that actually matches `.mission-kpi` proportions (18px 22px padding, 2px left border). This eliminates the layout jump on first KPI load.

**3b.** Delete the dead `@media` blocks at `cockpit.css:1372-1385` that target `.mission-hero` and `.mission-hero-content`. Replace with the responsive rules the new `.view-header-hero` actually needs (a smaller-than-640 reflow):

```css
@media (max-width: 480px) {
  .app-topbar {
    flex-wrap: wrap;
    height: auto;
    padding: var(--s-2) var(--s-4);
    gap: var(--s-2);
  }
  .topbar-title { font-size: 14px; }
  #btnLoadSnapshot span,
  #btnExportSnapshot span { display: none; }      /* keep icons only */
  .view-header-hero h2 { font-size: 22px; }
  .mission-status-chip { font-size: 9.5px; padding: 5px 8px; }
}
```

This addresses both the dead-code and the WCAG 1.4.10 320px reflow gaps in one pass.

---

## Detailed Findings (per pillar)

### Pillar 1: Copywriting (2/4)

- **Activity feed renders raw enums** (Finding #1): `cockpit.js:766` outputs `act.operation` verbatim → HEARTBEAT/CHECKIN/CHECKOUT/HANDOFF/LOCK/UNLOCK/ERROR/WARNING. The audit spec calls this out explicitly as a check; prior pass marked it 4/4 anyway.
- **Generic state strings**: `index.html:190 "Waiting for data…"`, `index.html:271 "Click a phase above to view details."`, `index.html:286 "Loading handoffs…"`, `index.html:295 "Loading prompts…"` — none are critical, but they're filler-grade.
- **No key-based i18n** (Finding #14): every user-visible string in cockpit.js is hardcoded English; `viewer.js` mixes Portuguese ("Restaurar...para o conteúdo original?"). Skill mandates key-based strings.
- **Hero copy stays strong**: `index.html:131-134` ("Real-time orchestration of 12 parallel AI agents…") is genuinely executive-grade, as the prior pass noted. But one strong hero block doesn't average a 2-issue feed up to 4/4.

Generic-label grep was clean (no "Submit", "Click Here", "OK", "Cancel", "Save" buttons exposed; "Loading…" only inside loading-state messages with context).

### Pillar 2: Visuals (3/4)

- **Heading semantics inverted** (Finding #15): topbar `<h1>` is static "Mission Control" — wrong on 6 of 7 views.
- **Orphaned `initHeroCanvas`** (Finding #6): 150 lines of icosahedron canvas code in `cockpit.js:297-446` targeting a removed DOM element; still wired into `navigateTo`.
- **Icon-only buttons all have `aria-label`**: `index.html:97 sidebarToggle`, `:121 themeToggle` both have aria-label. ✅
- **`<button>` audit is clean for accessibility**: the 5 `<button>` elements in `index.html` (lines 23, 97, 105, 109, 114, 121) all have either visible text or `aria-label` or both.
- **Single focal point per view**: dispatch view has hero header + KPI row + dispatch console. The KPI row competes for attention with the dispatch console title; not catastrophic.
- **No animated decorative background**: the `<canvas class="hero-canvas">` is gone from the DOM (verified — `grep` of `index.html` returns 0 matches). ✅ The orphaned JS is a code-cleanliness issue, not a visible defect.

### Pillar 3: Color (3/4)

Token usage is heavy and mostly clean. Counts in `cockpit.css`:

- `var(--indra-cyan)`: 47 references ✅ dominant accent
- `var(--indra-error)`: 14 references (banner border, op-error badge, rerun-flag, status-dead, dispatch row stripe, etc.)
- `var(--bg-app)`: 4 references (light vs dark bodies; not the dominant 60%)
- `var(--bg-card)`, `var(--bg-card-hover)`: ~25 references
- `var(--text-primary)`, `var(--text-secondary)`, `var(--text-muted)`, `var(--text-faint)`: ~70 combined references

60/30/10 holds in spirit (dark navy dominates via `body { background: var(--bg-app) }` and `.app-shell::before` gradient overlay; cards/glass form the 30%; cyan is the single accent).

**Hardcoded hex hunt outside :root**:

| Line | Selector | Hex | Verdict |
|------|----------|-----|---------|
| 767 | `.filter-select-sm option` | `#002B3A` | ✅ explicit Chromium native fallback (acceptable per spec) |
| 768 | `.filter-select-sm option` | `#FFFFFF` | ✅ same |
| 772 | `[data-theme="light"] .filter-select-sm option` | `#FFFFFF` | ✅ light-theme native fallback |
| 773 | `[data-theme="light"] .filter-select-sm option` | `#002B3A` | ✅ same |
| 1496 | `[data-theme="light"] .connection-banner` | `#002B3A` | ⚠️ should be `var(--indra-deep)` or `var(--text-primary)` (light theme) |
| 1626 | `.snapshot-banner .btn:hover` | `#001a26` | ⚠️ should be `var(--bg-app)` (Finding #11) |

**Spot-check WCAG 1.4.3 contrast** (computed via standard relative-luminance formula, foreground over composited background):

| Pair | Foreground | Background | Ratio | Threshold | Result |
|------|-----------|------------|------:|----------:|:------:|
| `.section-eyebrow` (10px/600) | `#00B0BD` cyan | `#001A26` body | 6.62 | 4.5 | ✅ |
| `.btn-cyan` label (13px/700) | `#002B3A` deep | `#00B0BD` cyan | 5.69 | 4.5 | ✅ |
| `.mission-status-chip strong` (10.5px/700) | `#00B0BD` cyan | `rgba(0,176,189,0.05)` over body | 6.28 | 4.5 | ✅ |
| `.cockpit-last-update` (11px/400) | `--text-muted` (0.50α white) | bg-topbar over body | 5.39 | 4.5 | ✅ |
| `.mission-kpi-value.is-completion` (28px/600) | `#00B0BD` cyan | bg-glass tile | 5.78 | 3.0 (large) | ✅ |
| `.mission-kpi-value.is-rerun` (28px/600) | `#E91E63` magenta | bg-glass tile | 3.55 | 3.0 (large) | ✅ |
| `.activity-op.op-error` (10.5px/700) | `#E91E63` magenta | `rgba(233,30,99,0.15)` over bg-card | **3.65** | 4.5 | ❌ **fails AA** |
| `.dispatch-empty` "—" (14px/400, `--text-faint`) | `rgba(255,255,255,0.32)` ≈ `#51636B` | bg-app | **2.83** | 4.5 | ❌ **fails AA** |
| `.activity-empty` "Waiting for data…" (14px/400) | `--text-faint` | bg-card | **~2.85** | 4.5 | ❌ **fails AA** |
| `.topbar-env-badge` LIVE (10px/700) | `#27AE60` | `rgba(39,174,96,0.12)` over bg-topbar | 5.47 | 4.5 | ✅ |

Two contrast failures (`--text-faint` for placeholder dashes/empty states, and `.op-error` for live error events) are the basis for −1 on this pillar.

### Pillar 4: Typography (2/4)

**Distinct font-sizes** (15 — exceeds 10-size budget):

```
9px, 10px, 10.5px, 11px, 11.5px, 12px, 13px, 14px, 15px, 18px, 22px, 24px, 28px, 32px, clamp(24px, 2.6vw, 30px)
```

The .5 stragglers at 10.5 (`.mission-status-chip`, `.activity-op`) and 11.5 (`.activity-list .activity-item`) read as ad-hoc tweaking. Prior pass claimed 9 distinct — provably false.

**Distinct font-weights** (4 — within budget):
- `500` (h2, nav-label, smaller body)
- `600` (default strong, labels, h2)
- `700` (KPI values where set, badges)
- `800` (sidebar brand)

The `400` and `300` weights are loaded from the Google Fonts URL (`@300;400;500;600;700;800`) but never used in `cockpit.css` directly — they inherit from `body { font-family… }` default 400. Acceptable.

**Letter-spacing on uppercase mono eyebrows** (5 distinct values — should be 1):

| Selector | Value | Line |
|----------|------:|-----:|
| `.section-eyebrow` | 0.18em | 718 |
| `.sidebar-brand-name` | 0.18em | 264 |
| `.mission-kpi-label` | 0.16em | 618 |
| `.sidebar-project-label` | 0.16em | 282 |
| `.snapshot-banner-label` | 0.14em | 1607 |
| `.kpi-title` | 0.12em | 1144 |
| `.topbar-env-badge` | 0.12em | 472 |
| `.dispatch-table thead th` | 0.10em | 904 |
| `.handoff-stat-label` | 0.10em | 1564 |
| `.dispatch-family-header h3` | 0.10em | 870 |
| `.sidebar-brand-sub` | 0.10em | 269 |
| `.sidebar-project-meta` | 0.10em | 307 |

Prior pass: "Eyebrows: 0.18em (was 0.14-0.16em mixed) — more uniform breathing." False — **only 2 selectors are at 0.18em**, the rest are 0.10/0.12/0.14/0.16em.

**`tabular-nums` coverage**: ✅ correctly applied on `.mission-kpi-value` via `font-feature-settings: 'tnum'` (line 627). Not applied on `.kpi-value` (dashboard) at line 1148 — minor gap; numbers there are smaller scope and dashboard isn't a column-aligned grid.

**Net**: 2/4 — the two specific claims the prior pass made about typography are both contradicted by the served bytes.

### Pillar 5: Spacing (2/4)

- **`.kpi-skeleton` rule conflict** (Finding #2, BLOCKER): two definitions; section 17 wins; documented "match new compact size" claim is false. Skeleton 20×24 vs tile 18×22, plus 3px vs 2px left border = visible jump on first paint.
- **Dead-code `@media` rules** (Finding #5): `.mission-hero` / `.mission-hero-content` rules at lines 1372–1385 target removed selectors. Prior pass's own Follow-up #1 — still not done.
- **No 320px reflow rule** (Finding #12): smallest breakpoint is 640px; at 320 viewport the topbar will overflow horizontally.
- **Hardcoded paddings outside the spacing scale**: `padding: 18px 22px` (`.mission-kpi`, `.kpi-skeleton`), `padding: 9px 20px` (`.btn`), `padding: 7px 12px` (`.filter-select-sm`, `.mission-status-chip`), `padding: 11px var(--s-5)` (nav-item) — all bypass the `--s-*` token scale even though similar values exist (s-2=8, s-3=12, s-4=16, s-5=20). Not a bug per se; consistency drift.
- **Tap-target audit (WCAG 2.5.8 → 24×24 minimum)**: ✅
  - `.btn` min-height 36px
  - `.btn-sm` min-height 32px
  - `.btn-xs` min-height 26px (just above)
  - `.topbar-icon-btn` 36×36
  - `.filter-select-sm` ~28px (7+12+7)
  - `.nav-item` ~42px (11+13×1.55+11)

### Pillar 6: Experience Design (2/4)

**State coverage matrix:**

| State | Coverage | Evidence |
|-------|:-:|----------|
| Loading | partial | `.kpi-skeleton` exists (but conflicting rules — Finding #2); `.skeleton::before` shimmer rule exists; only KPIs get skeletons (`renderHandoffs`, `renderPromptsList` show plain text "Loading prompts…") |
| Empty | yes | `.activity-empty` styled at `cockpit.css:1223`, used in `cockpit.js:743, 783, 898, 601` |
| Error | partial | `.connection-banner` (now soft), `.toast.toast-error`, `op-error` styling — but no dedicated full-page error state for "snapshot endpoint returned malformed JSON" beyond toast |
| Offline | yes | `.app-shell.is-offline { filter: grayscale(0.3) }` + connection-banner |
| Degraded | no | no UI for "snapshot is N seconds stale" or "X of Y agents missing" — fleet renders whatever the backend sent without freshness signal beyond `.cockpit-last-update` timestamp |

- **Focus visibility** (WCAG 2.4.7): ✅ — `:focus-visible` rule at `cockpit.css:124-129` produces a 2px cyan outline + 4px halo. Cyan-on-bg-app contrast ≈ 6.6:1 ≫ 3:1 non-text threshold.
- **Reduced-motion** (`prefers-reduced-motion: reduce`): partial — global rule at `cockpit.css:116-120` clamps `animation-duration` and `transition-duration` to 0.01ms ✅; the JS respects it for `animateCount` (line 313) and `initHeroCanvas` (line 304). The `mission-progress-fill::after` shimmer is suppressed because the global rule covers `animation-duration`. ✅
- **Keyboard navigation**: ❌ FAIL on `.kpi-card` (Finding #3); ✅ on agent-strip; ✅ on nav-items (binding at `cockpit.js:99-105`).
- **Confirmation for destructive actions**: ❌ inconsistent (Finding #4) — Reset Local Flags has `confirm()`; Dispatch / Revoke does not.

**Focus-not-obscured (WCAG 2.4.11)**: the snapshot banner is `position: sticky; top: 0; z-index: 60`; topbar is `position: sticky; top: 0; z-index: 50`. When snapshot mode is active, both stick to the top simultaneously and the snapshot banner stacks above the topbar. Items focused near the top of viewport during snapshot mode could be visually obscured by the stacked stickies (the `html { scroll-padding-top: calc(var(--topbar-h) + 16px) }` only accounts for the 64px topbar height — not the additional snapshot banner). Soft warning, not in the BLOCKER set.

---

## WCAG 2.2 AA Compliance

| Criterion | Status | Evidence |
|-----------|:-:|----------|
| 1.4.3 Contrast (Minimum) | **fail** | `--text-faint` 2.83:1; `.op-error` ~3.65:1; both fall below 4.5:1 normal-text threshold (Findings #9, #10) |
| 1.4.10 Reflow | **fail** | smallest breakpoint is 640px; topbar overflows at 320 CSS px (Finding #12) |
| 2.1.1 Keyboard | **fail** | `.kpi-card` divs are mouse-only (Finding #3) |
| 2.4.7 Focus Visible | pass | `:focus-visible` 2px outline + 4px halo at `cockpit.css:124-129` |
| 2.4.11 Focus Not Obscured | pass (soft) | scroll-padding-top accounts for topbar; in snapshot mode the stacked sticky banners may obscure focused items near viewport top — minor edge case |
| 2.5.8 Target Size | pass | all interactive elements ≥ 26 CSS px on shortest axis (`.btn-xs` is the smallest at 26px); ≥ 24×24 minimum met |

3 of 6 inspected criteria fail. The prior pass did not verify 1.4.3, 1.4.10, or 2.1.1 numerically.

---

## Live-Server Verification

Server started via `Start-Process node -ArgumentList cockpit-server.js -WorkingDirectory Web_MD_Viewer -WindowStyle Hidden`. All endpoints respond `200`.

| Endpoint | Status | Bytes-on-wire | Disk bytes | Match | Observation |
|----------|:-:|----:|----:|:-:|---------|
| `/` | 200 | 15975 | 15975 | ✅ | served from disk |
| `/cockpit.css` | 200 | 48505 | 48505 | ✅ | no stale cache |
| `/cockpit.js` | 200 | 41973 | 41973 | ✅ | no stale cache |
| `/api/health` | 200 | 101 | n/a | ✅ | JSON `{status:"ok", uptime_seconds: …}` |
| `/api/cockpit/snapshot` | 200 | 34616 | n/a | ✅ | JSON snapshot with `fleet`, `fleet_kpis`, `kpis`, `recent_activity` |

Server is healthy. The `/api/cockpit/snapshot` payload at 34 KB shows the audit findings are not artifacts of a missing data path — the data layer is functioning; the UI defects above are real.

---

## Files Audited

| File | Bytes | Read |
|------|------:|:-:|
| `Web_MD_Viewer/UI-REVIEW.md` | ~22 KB | full |
| `Web_MD_Viewer/index.html` | 15,975 | full |
| `Web_MD_Viewer/cockpit.css` | 48,505 | full (1626 lines) |
| `Web_MD_Viewer/cockpit.js` | 41,973 | first ~800 lines + targeted sections |
| `Web_MD_Viewer/cockpit-server.js` | 24,942 | header + endpoint surface |
| `Web_MD_Viewer/package.json` | 428 | full |

---

## Disagreements with Prior UI-REVIEW.md

The prior `UI-REVIEW.md` claimed **24/24** with detailed sub-claims. The following are contradicted by code in the served bytes:

1. **"9 distinct sizes — within the 10-size budget"** (Pillar 4 detail) — false. There are **15 distinct font-sizes** in `cockpit.css`. Listed under Finding #7.

2. **"Eyebrows: 0.18em (was 0.14-0.16em mixed) — more uniform breathing"** (Pillar 4 detail) — false. Only 2 selectors are at 0.18em; the other ~10 uppercase-mono eyebrows use 0.10em / 0.12em / 0.14em / 0.16em. Listed under Finding #8.

3. **"Hardcoded hex colors: only inside the SVG chevron … and the explicit `<option>` background fallbacks. No drift."** (Pillar 3 detail) — false. `.snapshot-banner .btn:hover { background: #001a26 }` at `cockpit.css:1626` and `[data-theme="light"] .connection-banner { color: #002B3A }` at line 1496 are hardcoded outside the token block and outside `<option>` overrides. Listed under Finding #11.

4. **"Skeleton placeholder ... match new compact size: padding 18px 22px, border-left: 2px"** (Addendum diff inventory) — false. Section 17 silently overrides Section 6; the served `.kpi-skeleton` actually has `padding: var(--s-5) var(--s-6)` (= 20px 24px) and `border-left: 3px solid var(--border-strong)`. Cascade order verified by direct file inspection. Listed under Finding #2.

5. **Addendum: "Removed: `<canvas class="hero-canvas">` and all related CSS rules deleted"** — half true. The HTML and CSS are removed; **the JS is not** — `initHeroCanvas()` (lines 297–446 of `cockpit.js`, ~150 lines) still builds an icosahedron canvas particle field, still runs on every dispatch nav, and has registered a global `mousemove` listener. The function early-returns now because `getElementById('missionHeroCanvas')` is null, but the code is dead and the call hasn't been removed. Listed under Finding #6.

6. **Addendum Follow-up #1: "Dead-code sweep of the two legacy `@media` blocks that still reference `.mission-hero` / `.mission-hero-content` (lines 1372 and 1379 of cockpit.css). Harmless because those selectors no longer match anything in the DOM, but should be removed in the next housekeeping pass."** — explicitly listed as a follow-up; **still not done**. They remain at lines 1372-1385 in the current served CSS. Listed under Finding #5.

7. **Pillar 6 "every interactive element (.btn, .nav-item, .kpi-card, .mission-kpi, .mission-status-chip, .activity-list .activity-item, .topbar-icon-btn, .topbar-avatar) has a transition + visible hover state"** — silent on keyboard reachability. `.kpi-card` is a `<div onclick=…>` with no `tabindex` or `keydown` handler — the prior 4/4 score on Pillar 6 includes a WCAG 2.1.1 hard fail. Listed under Finding #3.

8. **Pillar 1 "Activity feed operations use sentence-style verbs (HEARTBEAT, CHECKIN, LOCK, UNLOCK, HANDOFF, WARNING, ERROR) — concise, professional"** — these are all-caps machine enums, not sentence-style verbs. The prior pass's own description of the values contradicts the "sentence-style" classification. The audit spec explicitly flagged this as a check; the prior pass marked Pillar 1 4/4 anyway. Listed under Finding #1.

9. **Pillar 6 "Disabled / loading: .btn.is-loading rotates the SVG"** — true, but the prior pass did not enumerate full state coverage (degraded, partial-failure, snapshot-stale-warning) — there's no `is-stale` indicator beyond the absolute timestamp. Soft contradiction; not a numbered finding above.

The 14/24 adversarial total versus the 24/24 prior claim isn't an averaging difference — it's the result of running each pillar's specific checks (counting font-sizes, computing contrast ratios, verifying keyboard reachability, checking the `.kpi-skeleton` cascade, looking for the dead `<canvas id>`). On every pillar except Visuals, the adversarial pass found at least one specific factual contradiction with the prior pass's documented sub-claims.

---

## Recommendation Count

- **BLOCKER findings: 4** (Findings #1, #2, #3, #4)
- **WARNING findings: 11** (Findings #5–#15)
- **Total fixes proposed: 15**

Roadmap order (highest user impact first):
1. Activity feed enum → label map (Finding #1)
2. `.kpi-card` keyboard reachability (Finding #3)
3. `.kpi-skeleton` duplicate rule + dead `@media` cleanup (Findings #2, #5)
4. Dispatch/Revoke confirmation parity with Reset (Finding #4)
5. `--text-faint` and `.op-error` contrast fixes (Findings #9, #10)
6. 320px reflow + topbar wrap (Finding #12)
7. Heading semantics: dynamic topbar `<h1>` per view (Finding #15)
8. Delete dead `initHeroCanvas` (Finding #6)
9. Eyebrow letter-spacing token + font-size scale token (Findings #7, #8)
10. Replace inline `onclick` strings + add CSP-friendly delegation (Finding #13)
11. Hardcoded `#001a26` → `var(--bg-app)` (Finding #11)
12. i18n key-based string extraction (Finding #14)

---

*kiro_default — adversarial UI review pass — 2026-05-21T00:55 BRT*
