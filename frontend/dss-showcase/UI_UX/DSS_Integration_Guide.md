# DSS v3.0 — Zero-Drift Integration Guide

**Document:** DSS-INTEGRATION-2026-001  
**Version:** 1.0.0  
**Status:** ✅ Production — Mandatory for All New Projects  
**Owner:** Pre-Sales Architecture / Minsait — Indra Group  

> [!CAUTION]
> This document is **mandatory reading** for any agent, developer, or system building UI for the PortalShift / IndraMind / Minsait ecosystem. Non-compliance will result in brand audit failure.

---

## 1. Source of Truth — File Hierarchy

Any new project **MUST** reference these files in this exact priority order:

| Priority | File | Purpose |
|----------|------|---------|
| **1** | `DSS_Universal_Standard.md` | Canonical design spec — 12 colors, typography, spacing, component rules |
| **2** | `dss-showcase/styles.css` | Production-ready CSS with all `--indra-*` tokens |
| **3** | `dss-showcase/index.html` | Visual reference — what the output MUST look like |
| **4** | `dss-showcase/dashboard.html` | Dashboard template reference |
| **5** | `dss-showcase/tables.html` | Data table template reference |
| **6** | `dss-showcase/modals.html` | Dialog/modal template reference |

> [!IMPORTANT]
> **`styles.css` is the deployable artifact.** Copy it into your new project and import it. Do NOT recreate tokens from scratch — that's where drift starts.

---

## 2. Mandatory Integration Steps

### Step 1: Copy the Token File

```bash
# Copy the canonical stylesheet into your new project
cp dss-showcase/styles.css  your-project/styles/indra-tokens.css
```

### Step 2: Import in Your HTML

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="styles/indra-tokens.css">
```

### Step 3: Set the Theme

```html
<html lang="en" data-theme="dark">
```

### Step 4: Use ONLY `--indra-*` Variables

```css
/* ✅ CORRECT — uses token */
.my-card {
  background: var(--indra-dark);      /* #003E50 */
  color: var(--indra-off-white);       /* #F2F5F6 */
  border: 1px solid var(--indra-secondary); /* #346679 */
}

/* ❌ FORBIDDEN — hardcoded color */
.my-card {
  background: #003E50;  /* NEVER do this */
  color: white;         /* NEVER do this */
}
```

---

## 3. The 12 Canonical Colors — NO SUBSTITUTION

| Token | Hex | Usage |
|-------|-----|-------|
| `--indra-deep` | `#002B3A` | Page backgrounds, deepest layer |
| `--indra-dark` | `#003E50` | Card surfaces, containers, modal backgrounds |
| `--indra-primary` | `#06596E` | Button hover states, secondary interactive |
| `--indra-secondary` | `#346679` | Borders, dividers, subtle separators |
| `--indra-teal` | `#3F96AE` | Supporting accent, chart secondary |
| `--indra-cyan` | `#00B0BD` | **Primary accent** — CTAs, links, focus rings, active states |
| `--indra-light` | `#7A9CAE` | Muted text, labels, metadata, placeholders |
| `--indra-blue-gray` | `#B3C1DA` | Borders in light mode, subtle UI elements |
| `--indra-sky` | `#BADFF3` | Highlights, particle effects, data viz secondary |
| `--indra-warm-gray` | `#B0B4BD` | Form borders, neutral content |
| `--indra-off-white` | `#F2F5F6` | Light mode backgrounds, card surfaces |
| `--indra-white` | `#FFFFFF` | Primary text on dark backgrounds |

### Status Colors (4 additional)

| Token | Hex | Usage |
|-------|-----|-------|
| `--indra-success` | `#27AE60` | Success badges, operational status |
| `--indra-warning` | `#FF9800` | Warning badges, degraded status |
| `--indra-error` | `#E91E63` | Error states, failed badges, destructive actions |
| `--indra-gold` | `#FFC107` | Premium indicators, highlights |

> [!WARNING]
> **Do NOT use `#10B981`, `#EF4444`, `#3B82F6`, or any Tailwind/Material default colors.** They are off-brand and will fail audit.

---

## 4. Typography Rules

```css
/* Primary font — ALWAYS Inter */
font-family: 'Inter', -apple-system, sans-serif;

/* Monospace — for IDs, code, error traces */
font-family: 'Space Grotesk', 'JetBrains Mono', monospace;
```

| Level | Size | Weight | Letter-Spacing | Use Case |
|-------|------|--------|----------------|----------|
| Display | clamp(32px, 5vw, 64px) | 700 | -0.02em | Hero headlines |
| H1 | clamp(28px, 4vw, 48px) | 600 | -0.01em | Page titles |
| H2 | clamp(24px, 3vw, 32px) | 600 | normal | Section headers |
| H3 | 24px | 500 | normal | Subsection headers |
| Body Large | 18px | 400 | normal | Paragraph text |
| Body | 14-16px | 400 | normal | Default content |
| Label | 11-12px | 600-700 | 0.05-0.08em | Uppercase labels, table headers |
| Eyebrow | 12px | 500 | 0.1em | Section eyebrows, uppercase |

---

## 5. Component Rules — Non-Negotiable

### Buttons
```css
border-radius: 0;           /* Sharp corners — ALWAYS */
min-height: 44px;           /* WCAG touch target */
text-transform: uppercase;
font-weight: 600;
letter-spacing: 0.03em;
```

**Button variants:**
- **Primary**: `background: var(--indra-cyan); color: var(--indra-deep);`
- **Secondary**: `background: transparent; border: 1px solid var(--indra-cyan); color: white;`
- **Ghost**: `background: transparent; color: white;` + underline on hover
- **Danger**: `background: var(--indra-error); color: white;`

### Cards
```css
border-radius: 8px;         /* Rounded containers — 8px only */
background: var(--indra-dark);
border: 1px solid rgba(255,255,255,0.08);
padding: 24px-32px;
```

### Glass Cards (KPIs, hero metrics)
```css
background: rgba(0, 62, 80, 0.4);
backdrop-filter: blur(16px);
border: 1px solid rgba(255,255,255,0.08);
border-radius: 8px;
```

### Status Badges
```css
border-radius: 9999px;      /* Pill shape — badges ONLY */
font-size: 11-12px;
font-weight: 600;
text-transform: uppercase;
/* Include dot indicator before text */
```

### Form Inputs
```css
background: transparent;
border: none;
border-bottom: 2px solid var(--indra-light);  /* Underline style */
/* On focus: border-bottom-color: var(--indra-cyan); */
```

### Modals
```css
/* Overlay */
background: rgba(0,43,58,0.65);
backdrop-filter: blur(12px);

/* Card */
background: var(--indra-dark);
border-radius: 8px;
box-shadow: 0 20px 40px rgba(0,0,0,0.4);
```

---

## 6. Spacing Scale

```css
--space-1: 4px;   --space-2: 8px;   --space-3: 12px;
--space-4: 16px;  --space-6: 24px;  --space-8: 32px;
--space-12: 48px; --space-16: 64px; --space-20: 80px;
```

**Grid gutter:** 20-24px  
**Section padding:** 80-120px vertical  
**Card padding:** 24-32px  

---

## 7. Semantic Alias Map (for Agent Prompts)

When prompting an AI agent, use these semantic names to prevent drift:

```
"page background"     → var(--indra-deep)       #002B3A
"card background"     → var(--indra-dark)        #003E50
"accent color"        → var(--indra-cyan)        #00B0BD
"muted text"          → var(--indra-light)       #7A9CAE
"border color"        → var(--indra-secondary)   #346679
"primary text"        → #FFFFFF
"success"             → var(--indra-success)     #27AE60
"error"               → var(--indra-error)       #E91E63
"warning"             → var(--indra-warning)     #FF9800
```

---

## 8. Anti-Drift Checklist

Before shipping ANY page, verify all items:

- [ ] **No hardcoded hex colors** — every color must reference a `--indra-*` token
- [ ] **Font is Inter** — no Roboto, no system defaults, no Tailwind reset
- [ ] **Buttons have 0px radius** — no rounded buttons anywhere
- [ ] **Cards have 8px radius** — not 4px, not 12px, not 16px
- [ ] **Badges use pill shape** (9999px) — only exception to sharp corners
- [ ] **Form inputs use underline style** — no bordered/boxed inputs
- [ ] **Min touch target 44px** — WCAG AA compliance
- [ ] **Status colors match canonical set** — #27AE60, #FF9800, #E91E63 only
- [ ] **No placeholder text** — all content is contextually real
- [ ] **Background is #002B3A** — not #000, not #111, not #1a1a2e
- [ ] **Card surface is #003E50** — not #1e293b, not #334155

---

## 9. Agent System Prompt Template

When spinning up a new project with an AI agent, include this in the system prompt:

```
You are building a web application for the Indra/Minsait PortalShift Intelligence 
platform. You MUST follow the DSS v3.0 corporate standard with ZERO deviations.

MANDATORY RULES:
1. Import styles.css from the DSS showcase — do NOT create new tokens
2. Use ONLY --indra-* CSS custom properties for colors
3. Page background: #002B3A (--indra-deep)
4. Card surfaces: #003E50 (--indra-dark)  
5. Primary accent: #00B0BD (--indra-cyan)
6. Buttons: border-radius 0, min-height 44px, uppercase
7. Cards: border-radius 8px
8. Badges: pill-shaped (border-radius 9999px)
9. Form inputs: underline style (bottom border only)
10. Font: Inter for all text, Space Grotesk for monospace data
11. Status: Success=#27AE60, Warning=#FF9800, Error=#E91E63
12. No placeholder/lorem text — use real contextual data

REFERENCE FILES (in priority order):
- DSS_Universal_Standard.md (canonical spec)
- dss-showcase/styles.css (production tokens)
- dss-showcase/dashboard.html (dashboard pattern)
- dss-showcase/tables.html (data table pattern)
- dss-showcase/modals.html (dialog pattern)
```

---

## 10. Quick Visual Test

After building a page, compare these 5 checkpoints against the reference:

| Checkpoint | Expected | Screenshot Reference |
|------------|----------|---------------------|
| Background | Deep navy `#002B3A` | `index.html` hero section |
| Card surface | Dark teal `#003E50` | `dashboard.html` service cards |
| Accent highlight | Cyan `#00B0BD` | Any button or link |
| Status badges | Green/Orange/Pink pills | `tables.html` status column |
| Button shape | Sharp rectangle (0px radius) | Any CTA button |

---

## 11. File Manifest

```
dss-showcase/
├── index.html          ← DSS visual showcase (colors, typography, components)
├── dashboard.html      ← Dashboard template (KPIs, charts, status)
├── tables.html         ← Data table template (search, filter, pagination)
├── modals.html         ← Modal template (confirm, form, alert)
├── styles.css          ← ★ THE CANONICAL TOKEN FILE — copy this
└── app.js              ← Canvas sphere + scroll animations

DSS_Universal_Standard.md  ← Canonical design spec document
PRD_Apex_Strategy.md       ← Original tech stack mapping
```

> [!TIP]
> The fastest path to zero-drift: **copy `styles.css` into your project, use `--indra-*` tokens everywhere, and reference the showcase HTML for layout patterns.** That's it.
