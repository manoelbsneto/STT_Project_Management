# IndraMind Design System Standard (DSS)

**Document ID:** DSS-INDRAMIND-2026-001  
**Version:** 4.0.0 | Classification: Enterprise Baseline — Official Standard  
**Created:** 2026-04-28 | **Last Updated:** 2026-04-28  
**Owner:** Pre-Sales Architecture / Minsait — Indra Group  
**Stitch Project:** `projects/11889709839974860769`  
**Color Source:** PRD Login Page — Official Indra Corporate Color Standard v1.0  

---

> **PURPOSE**: This is the **single source of truth** for all visual design decisions across the PortalShift Intelligence / IndraMind / Minsait ecosystem. Every agent, developer, or system building UI **MUST** follow this document with zero deviations.

> **SCOPE**: Colors, typography, spacing, components, animations, accessibility, deployment rules, and anti-drift enforcement.

---

# PART I — DESIGN TOKENS

---

## 1. Official Color Palette — 12 Canonical Swatches

> ⚠️ **MANDATORY**: These are the ONLY colors permitted. All components must use CSS custom properties (`--indra-*`) — never hardcoded hex values.

| # | Token Name | Hex | RGB | Role |
|---|-----------|-----|-----|------|
| 1 | `--indra-deep` | `#002B3A` | 0,43,58 | **Page background** — dark panels, headers, sidebar |
| 2 | `--indra-dark` | `#003E50` | 0,62,80 | **Card surfaces** — containers, modals, table rows |
| 3 | `--indra-primary` | `#06596E` | 6,89,110 | Button hover states, gradient endpoints |
| 4 | `--indra-secondary` | `#346679` | 52,102,121 | Borders, dividers, subtle separators |
| 5 | `--indra-teal` | `#3F96AE` | 63,150,174 | Chart accents, gradient midpoints |
| 6 | `--indra-cyan` | `#00B0BD` | 0,176,189 | **Primary accent** — CTAs, links, focus rings, active states |
| 7 | `--indra-light` | `#7A9CAE` | 122,156,174 | Muted text, labels, metadata, placeholders |
| 8 | `--indra-blue-gray` | `#B3C1DA` | 179,193,218 | Light mode borders, dividers |
| 9 | `--indra-sky` | `#BADFF3` | 186,223,243 | Highlights, particle effects, data viz secondary |
| 10 | `--indra-warm-gray` | `#B0B4BD` | 176,180,189 | Form borders (light mode), neutral content |
| 11 | `--indra-off-white` | `#F2F5F6` | 242,245,246 | Light mode backgrounds, card surfaces |
| 12 | — | `#FFFFFF` | 255,255,255 | Primary text on dark backgrounds |

### 1.1 Status Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `--indra-success` | `#27AE60` | Positive indicators, operational, deployed |
| `--indra-warning` | `#FF9800` | Attention required, degraded, in-progress |
| `--indra-error` | `#E91E63` | Error states, failed, destructive actions |
| `--indra-gold` | `#FFC107` | Premium highlights, important numbers |

### 1.2 Forbidden Colors

> ⚠️ The following colors are **explicitly banned** — they are Tailwind/Material defaults that cause brand drift:

| Banned Hex | Origin | Correct Replacement |
|-----------|--------|-------------------|
| `#10B981` | Tailwind emerald | Use `--indra-success` (`#27AE60`) |
| `#EF4444` | Tailwind red | Use `--indra-error` (`#E91E63`) |
| `#3B82F6` | Tailwind blue | Use `--indra-cyan` (`#00B0BD`) |
| `#6366F1` | Tailwind indigo | Use `--indra-teal` (`#3F96AE`) |
| `#000000` | Pure black | Use `--indra-deep` (`#002B3A`) |
| `#111827` | Tailwind gray-900 | Use `--indra-deep` (`#002B3A`) |
| `#1E293B` | Tailwind slate-800 | Use `--indra-dark` (`#003E50`) |

---

## 2. CSS Custom Properties (Copy-Paste Ready)

### 2.1 Brand Tokens — Paste This Into Every Project

```css
:root {
  /* ═══════════════════════════════════════
     OFFICIAL INDRA CORPORATE PALETTE
     12 Canonical Swatches — No Substitution
     Source: DSS-INDRAMIND-2026-001 v4.0.0
     ═══════════════════════════════════════ */

  --indra-deep:       #002B3A;
  --indra-dark:       #003E50;
  --indra-primary:    #06596E;
  --indra-secondary:  #346679;
  --indra-teal:       #3F96AE;
  --indra-cyan:       #00B0BD;
  --indra-light:      #7A9CAE;
  --indra-blue-gray:  #B3C1DA;
  --indra-sky:        #BADFF3;
  --indra-warm-gray:  #B0B4BD;
  --indra-off-white:  #F2F5F6;

  /* Status */
  --indra-success:    #27AE60;
  --indra-warning:    #FF9800;
  --indra-error:      #E91E63;
  --indra-gold:       #FFC107;
}
```

### 2.2 Dark Mode Semantic Aliases

```css
[data-theme="dark"], .dark {
  --background:           var(--indra-deep);
  --foreground:           var(--indra-off-white);
  --card:                 var(--indra-dark);
  --card-foreground:      var(--indra-off-white);
  --primary:              var(--indra-cyan);
  --primary-foreground:   var(--indra-deep);
  --secondary:            var(--indra-primary);
  --secondary-foreground: var(--indra-off-white);
  --muted:                var(--indra-primary);
  --muted-foreground:     var(--indra-light);
  --accent:               rgba(0,176,189,0.12);
  --accent-foreground:    var(--indra-sky);
  --destructive:          #FF6B9D;
  --border:               var(--indra-secondary);
  --input:                var(--indra-secondary);
  --ring:                 var(--indra-cyan);
}
```

### 2.3 Light Mode Semantic Aliases

```css
:root {
  --background:           #FFFFFF;
  --foreground:           var(--indra-dark);
  --card:                 var(--indra-off-white);
  --card-foreground:      var(--indra-dark);
  --primary:              var(--indra-deep);
  --primary-foreground:   #FFFFFF;
  --secondary:            var(--indra-off-white);
  --secondary-foreground: var(--indra-deep);
  --muted:                var(--indra-off-white);
  --muted-foreground:     var(--indra-light);
  --accent:               rgba(0,176,189,0.08);
  --accent-foreground:    var(--indra-deep);
  --destructive:          var(--indra-error);
  --border:               var(--indra-blue-gray);
  --input:                var(--indra-warm-gray);
  --ring:                 var(--indra-cyan);
}
```

---

## 3. Typography

**Primary Font:** `'Inter', -apple-system, sans-serif`  
**Monospace Font:** `'Space Grotesk', 'JetBrains Mono', monospace`  

```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600&display=swap" rel="stylesheet">
```

| Level | Size | Weight | Letter-Spacing | Use Case |
|-------|------|--------|----------------|----------|
| Display | clamp(32px, 5vw, 64px) | 700 | -0.02em | Hero headlines |
| H1 | clamp(28px, 4vw, 48px) | 600 | -0.01em | Page titles |
| H2 | clamp(24px, 3vw, 32px) | 600 | normal | Section headers |
| H3 | 24px | 500 | normal | Subsection headers |
| Body Large | 18px | 400 | normal | Paragraph text |
| Body | 14–16px | 400 | normal | Default content |
| Label | 11–12px | 600–700 | 0.05–0.08em | Table headers, uppercase labels |
| Eyebrow | 12px | 500 | 0.1em | Section eyebrows, uppercase |
| Button | 14px | 600 | 0.03em | Button text, uppercase |
| Stat value | 22–48px | 700 | -0.02em | KPI numbers |
| Stat label | 11px | 500 | 0.05em | KPI labels, uppercase |

---

## 4. Spacing

### 4.1 Scale (8px Grid)

| Token | Value | Usage |
|-------|-------|-------|
| `--space-1` | 4px | Tight gaps, badge padding |
| `--space-2` | 8px | Base unit, icon gaps |
| `--space-3` | 12px | Compact gaps, swatch info |
| `--space-4` | 16px | Standard padding, grid gap |
| `--space-6` | 24px | Card internal padding |
| `--space-8` | 32px | Section gutters, card padding |
| `--space-12` | 48px | Medium vertical gaps |
| `--space-16` | 64px | Section top/bottom margins |
| `--space-20` | 80px | Large section padding |
| `--space-30` | 120px | Full section separators |

### 4.2 Breakpoints

| Name | Width | Layout |
|------|-------|--------|
| Mobile | < 768px | Single column, sidebar hidden |
| Tablet | < 960px | Collapsed grids |
| Desktop | ≥ 960px | Full layout |
| Desktop XL | ≥ 1280px | Max container 1280px |

---

## 5. Animation System

```css
:root {
  --duration-fast:     200ms;
  --duration-normal:   300ms;
  --duration-slow:     500ms;
  --duration-emphasis: 800ms;
  --ease-out:    cubic-bezier(0.16, 1, 0.3, 1);
  --ease-in-out: cubic-bezier(0.65, 0, 0.35, 1);
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

| Animation | Duration | Easing | Usage |
|-----------|----------|--------|-------|
| Scroll reveal | 500ms | `ease-out` | Cards, sections entering viewport |
| Button hover | 250ms | `ease` | Background + transform |
| Card hover | 200ms | `ease-out` | translateY(-3px) + shadow |
| Input focus | 250ms | `ease` | Border-bottom color transition |
| Modal entrance | 250ms | `ease` | translateY(16px) → 0 + fade |
| KPI counter | 1500ms | `cubic-bezier(0,0,0.2,1)` | Number counting animation |

---

# PART II — COMPONENT SPECIFICATIONS

---

## 6. Buttons

```css
.btn {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 600;
  letter-spacing: 0.03em;
  text-transform: uppercase;
  padding: 12px 28px;
  min-height: 44px;           /* WCAG touch target */
  border-radius: 0;           /* Sharp corners — ALWAYS */
  transition: all 0.25s ease;
  cursor: pointer;
}
```

| Variant | Background | Text | Border |
|---------|-----------|------|--------|
| **Primary** | `--indra-cyan` | `--indra-deep` | none |
| **Secondary** | transparent | `--indra-cyan` | 1px solid `--indra-cyan` |
| **Default** | `--indra-deep` | #FFFFFF | 1px solid rgba(255,255,255,0.2) |
| **Ghost** | transparent | #FFFFFF | none (underline on hover) |
| **Danger** | `--indra-error` | #FFFFFF | none |
| **Disabled** | `--indra-deep` | #FFFFFF | none, `opacity: 0.4` |

## 7. Cards

```css
.card {
  background: var(--indra-dark);            /* #003E50 */
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 8px;                       /* 8px — not 4, not 12, not 16 */
  padding: 24px–32px;
}
.card:hover {
  transform: translateY(-3px);
  box-shadow: 0 12px 28px rgba(0,0,0,0.3);
}
```

### 7.1 Glass Cards (KPIs, hero metrics)

```css
.glass-card {
  background: rgba(0, 62, 80, 0.4);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border: 1px solid rgba(255,255,255,0.08);
  border-radius: 8px;
}
```

## 8. Form Inputs

```css
.form-input {
  background: transparent;
  border: none;
  border-bottom: 2px solid var(--indra-light);    /* Underline only */
  color: var(--indra-dark);
  font-family: 'Inter', sans-serif;
  font-size: 15px;
  padding: 10px 0;
  outline: none;
  transition: border-color 0.2s;
}
.form-input:focus {
  border-bottom-color: var(--indra-cyan);          /* Focus = cyan */
}
.form-input::placeholder {
  color: rgba(122,156,174,0.5);
}

/* Labels */
.form-label {
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--indra-light);
}
```

## 9. Status Badges

```css
.badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 3px 10px;
  border-radius: 9999px;          /* Pill shape — badges ONLY */
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.03em;
}
/* Dot indicator */
.badge::before {
  content: '';
  width: 6px; height: 6px;
  border-radius: 50%;
  background: currentColor;
}

.badge-success { color: var(--indra-success); background: rgba(39,174,96,0.12); }
.badge-warning { color: var(--indra-warning); background: rgba(255,152,0,0.12); }
.badge-error   { color: var(--indra-error);   background: rgba(233,30,99,0.12); }
.badge-gold    { color: var(--indra-gold);    background: rgba(255,193,7,0.12); }
```

## 10. Modals / Dialogs

```css
/* Overlay */
.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,43,58,0.65);
  backdrop-filter: blur(12px);
  z-index: 200;
}

/* Card */
.modal-card {
  background: var(--indra-dark);
  border-radius: 8px;
  box-shadow: 0 20px 40px rgba(0,0,0,0.4);
}

/* Header */
.modal-header {
  padding: 24px 32px 16px;
  border-bottom: 1px solid var(--indra-secondary);
}

/* Body */
.modal-body { padding: 24px 32px; }

/* Footer */
.modal-footer {
  padding: 16px 32px 24px;
  display: flex; justify-content: flex-end; gap: 12px;
}
```

## 11. Data Tables

```css
/* Header */
.table th {
  font-size: 11px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--indra-light);
  padding: 14px 16px;
  border-bottom: 1px solid var(--indra-secondary);
}

/* Rows */
.table tr:nth-child(odd)  { background: var(--indra-deep); }
.table tr:nth-child(even) { background: var(--indra-dark); }
.table tr:hover { background: rgba(0,176,189,0.06); }

/* Cells */
.table td {
  padding: 12px 16px;
  font-size: 14px;
  color: var(--indra-off-white);
  border-bottom: 1px solid rgba(179,193,218,0.06);
}

/* Monospace IDs */
.table .id-cell {
  font-family: 'Space Grotesk', monospace;
  font-size: 13px;
  color: var(--indra-light);
}
```

## 12. Navigation

```css
/* Top Bar */
.topbar {
  height: 56px;
  background: var(--indra-deep);
  border-bottom: 1px solid var(--indra-secondary);
}

/* Sidebar (64px) */
.sidebar {
  width: 64px;
  background: var(--indra-deep);
  border-right: 1px solid var(--indra-secondary);
}

/* Active indicator */
.nav-icon.active::before {
  content: '';
  width: 3px; height: 24px;
  background: var(--indra-cyan);
  position: absolute; left: 0;
}
```

## 13. Elevation & Depth

| Level | Background | Border | Usage |
|-------|-----------|--------|-------|
| Level 0 | `--indra-deep` (#002B3A) | None | Page background |
| Level 1 | `--indra-dark` (#003E50) | 1px rgba(255,255,255,0.08) | Cards, modals |
| Level 2 | `--indra-primary` (#06596E) | Cyan glow 15% | Hover/focus |
| Glass | rgba(0,62,80,0.4) | 1px rgba(255,255,255,0.08) | KPIs, hero metrics |

**Gradients:**

| Name | Value | Usage |
|------|-------|-------|
| Footer | `linear-gradient(90deg, #002B3A, #06596E)` | Footer bars |
| Hero | `radial-gradient(ellipse, rgba(0,176,189,0.15), transparent)` | Hero background texture |

---

# PART III — ACCESSIBILITY

---

## 14. WCAG 2.2 AA Compliance

| Check | Ratio | Result |
|-------|-------|--------|
| White on `#002B3A` | 15.1:1 | ✅ AAA |
| `#00B0BD` on `#002B3A` | 5.0:1 | ✅ AA |
| `#002B3A` on `#FFFFFF` | 14.8:1 | ✅ AAA |
| `#003E50` on `#FFFFFF` | 11.2:1 | ✅ AAA |
| Focus ring visible | — | ✅ Cyan underline |
| `prefers-reduced-motion` | — | ✅ Animations disabled |
| Min touch target | 44px | ✅ All buttons |

---

# PART III-B — DATA FORMATTING & FINANCIALS

---

## 14.1 Number Formatting

> ⚠️ All numeric values MUST use consistent formatting. Never display raw unformatted numbers.

| Type | Format | Example | CSS / JS |
|------|--------|---------|----------|
| **Integers** | Thousands separator (locale) | `12,450` | `toLocaleString()` |
| **Decimals** | Max 2 decimal places | `99.72` | `toFixed(2)` |
| **Large numbers** | Abbreviated with suffix | `€2.4M` / `1.2K` | Custom formatter |
| **Negative values** | Parentheses or minus | `(€1,200)` or `-€1,200` | Convention-dependent |

### JavaScript Formatter (Copy-Paste)

```javascript
/**
 * DSS v4.0 — Standard Number Formatter
 * Usage: formatNumber(1234567.89, 'currency')
 */
function formatNumber(value, type = 'integer') {
  const locale = 'pt-PT';  // Portuguese (EU) — Indra default

  switch (type) {
    case 'currency':
      return new Intl.NumberFormat(locale, {
        style: 'currency',
        currency: 'EUR',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(value);

    case 'currency-compact':
      if (value >= 1_000_000)
        return '€' + (value / 1_000_000).toFixed(1) + 'M';
      if (value >= 1_000)
        return '€' + (value / 1_000).toFixed(1) + 'K';
      return '€' + value.toFixed(2);

    case 'percent':
      return new Intl.NumberFormat(locale, {
        style: 'percent',
        minimumFractionDigits: 1,
        maximumFractionDigits: 1,
      }).format(value / 100);

    case 'decimal':
      return new Intl.NumberFormat(locale, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      }).format(value);

    case 'integer':
    default:
      return new Intl.NumberFormat(locale, {
        maximumFractionDigits: 0,
      }).format(value);
  }
}
```

### Locale Priority

| Context | Locale | Thousands Sep | Decimal Sep | Currency |
|---------|--------|--------------|-------------|----------|
| **EU (default)** | `pt-PT` | `.` | `,` | EUR (€) |
| **Brazil** | `pt-BR` | `.` | `,` | BRL (R$) |
| **US/International** | `en-US` | `,` | `.` | USD ($) |

> Always use `Intl.NumberFormat` — never manually insert separators.

## 14.2 Currency Display

### Placement Rules

| Currency | Symbol Position | Example |
|----------|----------------|---------|
| EUR (€) | Before amount | `€1.234.567,89` |
| BRL (R$) | Before amount | `R$ 1.234.567,89` |
| USD ($) | Before amount | `$1,234,567.89` |

### CSS for Financial Values

```css
/* KPI financial values — tabular nums for alignment */
.financial-value {
  font-family: 'Inter', sans-serif;
  font-size: 28px;
  font-weight: 600;
  font-feature-settings: 'tnum';    /* Tabular figures — numbers align vertically */
  letter-spacing: -0.01em;
  color: #FFFFFF;
  line-height: 1.1;
}

/* Compact financial (cards, badges) */
.financial-compact {
  font-family: 'Inter', sans-serif;
  font-size: 14px;
  font-weight: 500;
  font-feature-settings: 'tnum';
  color: var(--indra-off-white);
}

/* Negative values */
.financial-negative {
  color: var(--indra-error);         /* #E91E63 */
}

/* Positive delta */
.financial-positive {
  color: var(--indra-success);       /* #27AE60 */
}
```

## 14.3 Percentage Display

| Context | Format | Example |
|---------|--------|---------|
| KPI card | Integer + `%` suffix | `99%` |
| Detail / tooltip | 1 decimal + `%` | `99.2%` |
| Change indicator | Signed + `%` | `▲ 12.4%` / `▼ 8.7%` |
| Progress bar label | Integer + `%` | `72%` |

### Change Indicators (Deltas)

```css
/* Positive change */
.delta-up {
  color: var(--indra-success);
  background: rgba(39,174,96,0.12);
  padding: 2px 8px;
  border-radius: 9999px;
  font-size: 12px;
  font-weight: 500;
}
.delta-up::before { content: '▲ '; }

/* Negative change */
.delta-down {
  color: var(--indra-error);
  background: rgba(233,30,99,0.12);
  padding: 2px 8px;
  border-radius: 9999px;
  font-size: 12px;
  font-weight: 500;
}
.delta-down::before { content: '▼ '; }

/* Context label */
.delta-context {
  font-size: 12px;
  color: var(--indra-light);         /* #7A9CAE */
  margin-left: 4px;
}
```

### HTML Example

```html
<div class="kpi-card">
  <div class="kpi-label">Revenue (YTD)</div>
  <div class="financial-value">€2.4M</div>
  <span class="delta-up">12.4%</span>
  <span class="delta-context">vs last quarter</span>
</div>
```

## 14.4 Date & Time Formatting

| Context | Format | Example |
|---------|--------|---------|
| **Table cells** | `YYYY-MM-DD HH:mm` | `2026-04-28 14:23` |
| **Activity feed** | Relative | `14 minutes ago` |
| **Full timestamp** | `DD MMM YYYY, HH:mm` | `28 Apr 2026, 14:23` |
| **Date only** | `YYYY-MM-DD` | `2026-04-28` |
| **Month/Year** | `MMM YYYY` | `Apr 2026` |
| **Chart axis** | `MMM` or `MMM 'YY` | `Jan` / `Jan '26` |

### JavaScript Formatter

```javascript
/**
 * DSS v4.0 — Standard Date Formatter
 */
function formatDate(date, type = 'table') {
  const d = new Date(date);

  switch (type) {
    case 'table':
      return d.toISOString().slice(0, 16).replace('T', ' ');

    case 'full':
      return d.toLocaleDateString('en-GB', {
        day: '2-digit', month: 'short', year: 'numeric'
      }) + ', ' + d.toLocaleTimeString('en-GB', {
        hour: '2-digit', minute: '2-digit'
      });

    case 'relative':
      const diff = Date.now() - d.getTime();
      const mins = Math.floor(diff / 60000);
      if (mins < 60) return `${mins} minutes ago`;
      const hrs = Math.floor(mins / 60);
      if (hrs < 24) return `${hrs} hours ago`;
      const days = Math.floor(hrs / 24);
      return `${days} days ago`;

    case 'chart':
      return d.toLocaleDateString('en-US', { month: 'short' });

    default:
      return d.toISOString().slice(0, 10);
  }
}
```

### CSS for Dates

```css
.date-cell {
  font-size: 13px;
  font-feature-settings: 'tnum';    /* Aligned digits */
  color: var(--indra-light);         /* #7A9CAE */
  white-space: nowrap;
}
```

## 14.5 Tabular Data Alignment

| Data Type | Alignment | Reason |
|-----------|-----------|--------|
| Text (names, labels) | Left | Natural reading flow |
| Numbers / Currency | Right | Decimal alignment |
| Dates | Left | ISO format reads left-to-right |
| Status badges | Center | Visual balance |
| IDs (monospace) | Left | Code-like readability |
| Percentages | Right | Numeric alignment |
| Actions (buttons) | Center | Consistent click target |

```css
/* Table column alignment */
.col-text    { text-align: left; }
.col-number  { text-align: right; font-feature-settings: 'tnum'; }
.col-currency { text-align: right; font-feature-settings: 'tnum'; }
.col-date    { text-align: left; font-feature-settings: 'tnum'; }
.col-status  { text-align: center; }
.col-id      { text-align: left; font-family: 'Space Grotesk', monospace; }
.col-percent { text-align: right; font-feature-settings: 'tnum'; }
.col-actions { text-align: center; }
```

## 14.6 Chart Data Formatting

| Element | Format Rule |
|---------|-------------|
| Y-axis labels | Abbreviated (`12K`, `€2.4M`) |
| X-axis labels | Short month (`Jan`, `Feb`) |
| Tooltips | Full precision (`€1,234,567.89`) |
| Data point labels | Compact (`99.2%`, `€2.4M`) |
| Legend values | Full with unit (`12,450 users`) |

### Chart Color Assignments

| Data Series | Color Token | Hex |
|------------|-------------|-----|
| Primary series | `--indra-cyan` | `#00B0BD` |
| Secondary series | `--indra-teal` | `#3F96AE` |
| Tertiary series | `--indra-sky` | `#BADFF3` |
| Area fill | `--indra-cyan` at 25% | `rgba(0,176,189,0.25)` |
| Grid lines | white at 8% | `rgba(179,193,218,0.08)` |
| Axis text | `--indra-light` | `#7A9CAE` |

---

# PART IV — INTEGRATION & ANTI-DRIFT

---

## 15. How to Start a New Project

### Step 1: Copy the Token File

```bash
cp dss-showcase/styles.css  your-project/styles/indra-tokens.css
```

### Step 2: Import in Your HTML

```html
<html lang="en" data-theme="dark">
<head>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Space+Grotesk:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="styles/indra-tokens.css">
</head>
```

### Step 3: Use ONLY Token Variables

```css
/* ✅ CORRECT */
.my-card {
  background: var(--indra-dark);
  color: var(--indra-off-white);
  border: 1px solid var(--indra-secondary);
}

/* ❌ FORBIDDEN */
.my-card {
  background: #003E50;   /* hardcoded = drift */
  color: white;          /* not a token = drift */
}
```

## 16. Agent System Prompt (Copy-Paste)

When starting a project with any AI agent, include this:

```
You are building a web application for the Indra/Minsait PortalShift Intelligence
platform. You MUST follow the DSS v4.0 corporate standard with ZERO deviations.

MANDATORY RULES:
1.  Import styles.css from the DSS showcase — do NOT create new tokens
2.  Use ONLY --indra-* CSS custom properties for all colors
3.  Page background: #002B3A (--indra-deep) — NOT black, NOT #111
4.  Card surfaces: #003E50 (--indra-dark) — NOT #1e293b
5.  Primary accent: #00B0BD (--indra-cyan) — NOT #3B82F6
6.  Buttons: border-radius 0, min-height 44px, uppercase, font-weight 600
7.  Cards: border-radius 8px — NOT 4px, NOT 12px, NOT 16px
8.  Badges: pill-shaped (border-radius 9999px) — only exception to sharp corners
9.  Form inputs: underline style (bottom border only), no boxes
10. Font: Inter for all text, Space Grotesk for monospace/IDs
11. Status: Success=#27AE60, Warning=#FF9800, Error=#E91E63
12. No placeholder/lorem text — use real contextual data
13. Always implement prefers-reduced-motion

REFERENCE: Read DSS_Universal_Standard.md before writing any code.
FILE: Copy dss-showcase/styles.css into your project as the token source.
VISUAL: Use dss-showcase/dashboard.html, tables.html, modals.html as layout references.
```

## 17. Semantic Alias Map (for Agent Prompts)

Use these plain-language terms to ensure agents pick the right token:

| When You Say... | Agent Must Use | Hex |
|----------------|---------------|-----|
| "page background" | `var(--indra-deep)` | `#002B3A` |
| "card background" | `var(--indra-dark)` | `#003E50` |
| "accent color" | `var(--indra-cyan)` | `#00B0BD` |
| "muted text" | `var(--indra-light)` | `#7A9CAE` |
| "border color" | `var(--indra-secondary)` | `#346679` |
| "primary text" | `#FFFFFF` | `#FFFFFF` |
| "success state" | `var(--indra-success)` | `#27AE60` |
| "error state" | `var(--indra-error)` | `#E91E63` |
| "warning state" | `var(--indra-warning)` | `#FF9800` |

## 18. Anti-Drift Checklist

Before shipping ANY page, verify **every** item:

- [ ] No hardcoded hex colors — every color references a `--indra-*` token
- [ ] Font is Inter — no Roboto, no system defaults, no Tailwind reset
- [ ] Buttons have `border-radius: 0` — no rounded buttons
- [ ] Cards have `border-radius: 8px` — not 4px, not 12px, not 16px
- [ ] Badges use pill shape (`9999px`) — only exception to sharp corners
- [ ] Form inputs use underline style — no bordered/boxed inputs
- [ ] Min touch target 44px — WCAG AA compliance
- [ ] Status colors are canonical — `#27AE60`, `#FF9800`, `#E91E63` only
- [ ] No placeholder text — all content is contextually real
- [ ] Background is `#002B3A` — not `#000`, not `#111`, not `#1a1a2e`
- [ ] Card surface is `#003E50` — not `#1e293b`, not `#334155`
- [ ] `prefers-reduced-motion` is implemented
- [ ] No banned colors from Section 1.2

## 19. 3D Hero Element (Geodesic Sphere)

```javascript
const SPHERE_CONFIG = {
  lineColor:       'rgba(0, 176, 189, 0.25)',   // --indra-cyan at 25%
  pulseColor:      'rgba(63, 150, 174, 0.8)',    // --indra-teal at 80%
  particleColor:   'rgba(186, 223, 243, 0.6)',   // --indra-sky at 60%
  backgroundColor: '#002B3A',                     // --indra-deep
};
```

---

# PART V — INFRASTRUCTURE

---

## 20. Vercel Deployment Config

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-XSS-Protection", "value": "1; mode=block" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    }
  ]
}
```

## 21. File Manifest

```
dss-showcase/
├── index.html          ← DSS visual showcase (colors, typography, components)
├── dashboard.html      ← Dashboard template (KPIs, charts, activity feed)
├── tables.html         ← Data table template (search, filter, pagination)
├── modals.html         ← Modal template (confirm, form, alert dialogs)
├── styles.css          ← ★ THE CANONICAL TOKEN FILE — copy this to every project
└── app.js              ← Canvas sphere + scroll animations

DSS_Universal_Standard.md    ← THIS DOCUMENT — single source of truth
DSS_Integration_Guide.md     ← Quick-start integration guide
PRD_Apex_Strategy.md         ← Original tech stack mapping
```

## 22. Stitch Integration

| Asset | ID |
|-------|-----|
| Project | `projects/11889709839974860769` |
| Design System | `assets/2f8ae91fd6a54852ad25a4ac2a3dde29` |
| Dashboard Screen | `screens/aa1ef1d0284d459a833b9985aa8804cc` |
| Table Screen | `screens/b634d97e6c3942aabfeb0e7dba32b2cb` |
| Modal Screen | `screens/6a99244fc78f47c793e42768d805d893` |

## 23. Cross-Reference

| Document | Path | Relationship |
|----------|------|-------------|
| PRD Login Page v1.0 | User-provided PRD | **Authoritative color source** |
| Official Palette | `Indra_Minsait_Collors_Mapping.png` | Visual reference |
| PRD Apex Strategy | `PRD_Apex_Strategy.md` | Tech stack baseline |
| Skills Library | `data_expert_skills/` | 63 expert references |
| Stitch Project | `projects/11889709839974860769` | Visual design assets |

---

**Document End** | DSS-INDRAMIND-2026-001 | v4.0.0
