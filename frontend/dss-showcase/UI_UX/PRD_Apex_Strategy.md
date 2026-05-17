# PRD — Apex Strategy: Global Management Consulting Website

| Field | Value |
|---|---|
| **Document ID** | `PRD-APEX-2026-001` |
| **Version** | `1.0.0` |
| **Status** | `Approved — Baseline` |
| **Author** | Senior Product Management — Documents Automation |
| **Created** | 2026-04-28 |
| **Live URL** | [https://apex-strategy-ashy.vercel.app/](https://apex-strategy-ashy.vercel.app/) |
| **Classification** | Internal — Agent Deployment Reference |

---

## 1. Executive Summary

**Apex Strategy** is a premium, single-page corporate website for a global management consulting firm. The site communicates authority, intellectual rigor, and exclusivity through a dark-mode, gold-accented visual language, a bespoke 3D geodesic sphere animation, and a meticulously crafted typographic hierarchy. It is deployed as a **static HTML/CSS/JS** application on **Vercel's Edge Network** with zero framework dependencies.

> [!IMPORTANT]
> This PRD is the **canonical baseline** for any AI agent, developer, or automation pipeline tasked with replicating, forking, or extending this website. Every technical detail has been reverse-engineered from the live production build.

---

## 2. Product Vision & Objectives

| Objective | Description |
|---|---|
| **Brand Authority** | Convey the gravitas of a tier-one consulting firm through premium visual design |
| **Lead Generation** | Drive high-intent engagement via a structured contact form |
| **Performance** | Sub-300ms DOM interactive; < 15 KB total page weight (compressed) |
| **Zero Dependencies** | No framework lock-in — pure HTML/CSS/JS for maximum portability |

---

## 3. Technology Stack — Complete Specification

### 3.1 Core Architecture

| Layer | Technology | Version / Detail |
|---|---|---|
| **Markup** | HTML5 | Semantic elements (`<nav>`, `<section>`, `<footer>`) |
| **Styling** | Vanilla CSS3 | Inline `<style>` block, CSS Custom Properties (design tokens) |
| **Logic** | Vanilla JavaScript (ES6+) | Single inline `<script>` block, ~9,569 chars |
| **3D Graphics** | Canvas 2D API | Custom geodesic sphere renderer (no Three.js) |
| **Fonts** | Google Fonts API | `Cormorant Garamond`, `EB Garamond`, `Inter` |
| **Icons** | Inline SVG | 6 hand-crafted SVG icons (no icon library) |
| **Framework** | **None** | No React, Vue, Angular, Svelte, Next.js, or similar |

### 3.2 Hosting & Deployment

| Component | Detail |
|---|---|
| **Platform** | Vercel (Edge Network) |
| **Region** | `gru1` (São Paulo / South America) |
| **Protocol** | HTTP/2 (`h2`) over TLS |
| **Compression** | Brotli (`br`) |
| **Cache Strategy** | `public, max-age=0, must-revalidate` with ETag |
| **HSTS** | `max-age=63072000; includeSubDomains; preload` |
| **CORS** | `access-control-allow-origin: *` |
| **Content Type** | `text/html; charset=utf-8` |
| **Server Header** | `Vercel` |
| **Cache Status** | `x-vercel-cache: HIT` (CDN cached) |

### 3.3 Performance Metrics (Production)

| Metric | Value |
|---|---|
| **Time to First Byte (TTFB)** | 17 ms |
| **DOM Interactive** | 274 ms |
| **DOM Content Loaded** | 274 ms |
| **Full Page Load** | 301 ms |
| **Encoded Body Size** | 12,578 bytes (~12.3 KB) |
| **Decoded Body Size** | 49,089 bytes (~47.9 KB) |
| **Transfer Size** | 12,878 bytes (~12.6 KB) |
| **Total Page Weight** | ~1,950 bytes (external resources) |
| **Total Network Requests** | 6 (HTML + 1 CSS + 3 fonts + 1 favicon) |
| **Total DOM Elements** | 283 |

### 3.4 File Architecture

```
apex-strategy/
├── index.html          # Single-file application (HTML + inline CSS + inline JS)
├── favicon.ico         # ⚠️ Missing (404) — needs creation
└── (no other files)    # Zero external JS/CSS bundles
```

> [!WARNING]
> The favicon returns a **404**. Any future deployment MUST include a proper `favicon.ico` (recommended: gold diamond on navy background, 32×32 + 16×16 ICO format).

---

## 4. Design System — Complete Token Reference

### 4.1 Color Palette

#### Navy Scale (Backgrounds)
| Token | Hex | Usage |
|---|---|---|
| `--navy-deep` | `#06090f` | Deepest background, footer, testimonials |
| `--navy-base` | `#0a0f1e` | Primary body background |
| `--navy-mid` | `#0d1530` | Services section, card backgrounds |
| `--navy-lift` | `#111e3d` | Hover states, elevated surfaces |
| `--navy-glass` | `rgba(13,21,48,.6)` | Frosted glass navbar on scroll |

#### Gold Scale (Accents)
| Token | Hex | Usage |
|---|---|---|
| `--gold-muted` | `#8a6f38` | Numbering, subtle accents |
| `--gold-base` | `#c9a84c` | Primary accent, CTAs, borders |
| `--gold-bright` | `#e8c96b` | Highlights, italic text, hover states |
| `--gold-pale` | `rgba(201,168,76,.12)` | Background tints, icon hover fills |
| `--gold-line` | `rgba(201,168,76,.3)` | Borders, dividers, grid lines |

#### White Scale (Text)
| Token | Hex | Usage |
|---|---|---|
| `--white` | `#f4f1eb` | Primary text (warm off-white) |
| `--white-dim` | `rgba(244,241,235,.55)` | Secondary text, descriptions |
| `--white-ghost` | `rgba(244,241,235,.08)` | Subtle hover backgrounds |

### 4.2 Typography

| Token | Font Stack | Usage |
|---|---|---|
| `--ff-display` | `'Cormorant Garamond', Georgia, serif` | Headings, quotes, stat numbers |
| `--ff-body` | `'Inter', sans-serif` | Body text, labels, navigation |

#### Google Fonts Import
```
Cormorant Garamond: ital,wght@0,300;0,400;0,500;0,600;0,700;1,300;1,400;1,600
EB Garamond: ital,wght@0,400;0,500;1,400
Inter: wght@300;400;500
```

#### Type Scale
| Element | Font | Size | Weight | Extras |
|---|---|---|---|---|
| `h1` | Display | `clamp(3.4rem, 7vw, 7.2rem)` | 500 | `line-height: 1.04`, `letter-spacing: -0.01em` |
| `h2` | Display | `clamp(2.4rem, 4.5vw, 4rem)` | 400 | `line-height: 1.1` |
| `h3` | Display | `1.55rem` | 500 | `line-height: 1.2` |
| `h1 em` | Display Italic | Inherited | Inherited | `color: var(--gold-bright)` |
| Body | Body | `16px` base | 300 | `line-height: 1.7` |
| Labels | Body | `0.63rem–0.72rem` | 400–500 | `letter-spacing: 0.18em–0.32em`, uppercase |

### 4.3 Animation Tokens

| Token | Value | Usage |
|---|---|---|
| `--ease-out` | `cubic-bezier(.16,1,.3,1)` | Most transitions (smooth deceleration) |
| `--ease-in` | `cubic-bezier(.7,0,.84,0)` | Entry animations |

### 4.4 Responsive Breakpoints

| Breakpoint | Rules Applied |
|---|---|
| `max-width: 900px` | Single-column layouts, nav links hidden, custom cursor disabled, hero stats repositioned, forms stacked |

---

## 5. Component Architecture

### 5.1 Page Sections (in DOM order)

| # | Section | CSS Class | ID | Description |
|---|---|---|---|---|
| 1 | Custom Cursor | `#cursor` | `cursor` | Gold dot + ring following mouse position |
| 2 | Navigation | `nav` | `navbar` | Fixed top, glassmorphism on scroll |
| 3 | Hero | `.hero` | — | Full-viewport, 3D sphere canvas, CTA buttons, statistics |
| 4 | Services | `.services` | `services` | 6-card grid with diagonal clip-path |
| 5 | Philosophy | `.philosophy` | `philosophy` | 2-column: visual box + content with 4 pillars |
| 6 | Testimonials | `.testimonials` | `testimonials` | 3-card grid with decorative quote mark |
| 7 | Contact | `.contact` | `contact` | 2-column: info + form (4 fields + submit) |
| 8 | Footer | `footer` | — | Brand, nav groups (Services, Firm, Connect), legal |

### 5.2 CSS Class Inventory (80 Unique Classes)

```
arrow, btn-ghost, btn-primary, btn-submit, contact, contact-detail,
contact-form, contact-info, contact-item, contact-item-label, contact-item-val,
divider, field-input, field-label, field-wrap, footer-bottom, footer-brand,
footer-copy, footer-legal, footer-nav-group, footer-tagline, footer-top,
form-note, form-row, hero, hero-actions, hero-bg, hero-diamond, hero-eyebrow,
hero-stats, hero-sub, nav-cta, nav-links, nav-logo, nav-logo-mark, phil-box,
phil-box-1, phil-box-2, phil-ornament, phil-quote, philosophy, philosophy-content,
philosophy-text, philosophy-visual, pillar, pillar-num, pillar-text, pillar-title,
pillars, reveal, reveal-delay-1..5, scrolled, section-header, section-lead,
section-tag, service-card, service-desc, service-icon, service-link, service-num,
services, services-grid, stat-item, stat-label, stat-num, testi-author,
testi-avatar, testi-card, testi-company, testi-name, testi-role, testi-stars,
testi-text, testimonials, testimonials-grid, visible
```

### 5.3 HTML Elements Used

```
a, body, button, canvas, circle, cite, div, em, footer, form, h1, h2, h3, h4,
head, html, input, label, li, line, link, meta, nav, p, path, rect, script,
section, span, style, svg, textarea, title, ul
```

---

## 6. Interactive Systems

### 6.1 Custom Cursor System

- **Dot** (`#cursor-dot`): 6px gold circle, instant tracking via `mousemove`
- **Ring** (`#cursor-ring`): 36px gold-border ring with 0.12 lerp factor lag
- **Hover State**: Ring expands to 54px + 50% opacity on `a:hover` / `button:hover`
- **Mobile**: Hidden via `@media (max-width: 900px)`, restores `cursor: auto`
- **Implementation**: `requestAnimationFrame` loop with linear interpolation

### 6.2 3D Geodesic Sphere (Hero Canvas)

| Parameter | Value |
|---|---|
| **Canvas ID** | `hero3d` |
| **Geometry** | Icosahedron → Level-2 geodesic subdivision (162 vertices, 320 faces, 480 edges) |
| **Rendering** | Canvas 2D context (no WebGL) |
| **Projection** | Perspective with `fov = 3.8`, sphere radius = `min(W,H) × 0.37` |
| **Position** | Centered at 62% horizontal, 50% vertical |
| **Auto Rotation** | Y-axis at `+0.0025 rad/frame` |
| **Mouse Parallax** | X: `±0.6 rad`, Y: `±1.4 rad`, smoothed at 0.05 factor |
| **Edge Rendering** | Depth-sorted, alpha `0.04–0.26`, width `0.3–1.0px`, gold color |
| **Glow Pass** | Top 12% front-facing edges get `shadowBlur: 10` + extra stroke |
| **Vertex Dots** | Front-facing only (depth > 0.28), radius `0.6–2.8px`, with glow |
| **Pulse Particles** | Spawned every 22 frames on random edges, radial gradient with bright core |
| **Center Glow** | Radial gradient at sphere center, radius `R × 0.42`, subtle gold tint |
| **Resize** | `ResizeObserver` for responsive canvas dimensions |

### 6.3 Scroll Animations

| System | Implementation |
|---|---|
| **Nav Glassmorphism** | `scroll` event → `.scrolled` class at `scrollY > 60` → `backdrop-filter: blur(20px)` |
| **Scroll Reveal** | `IntersectionObserver` at `threshold: 0.12` → `.visible` class (one-shot) |
| **Reveal Effect** | `opacity: 0 → 1`, `translateY(28px) → none`, duration `0.85s` |
| **Stagger Delays** | `.reveal-delay-1..5` → `0.1s–0.5s` `transition-delay` |

### 6.4 CSS Animations

| Name | Keyframes | Usage |
|---|---|---|
| `fadeUp` | `0%: opacity:0, translateY(30px)` → `100%: opacity:1, none` | Hero elements entry |
| `fadeIn` | `0%: opacity:0` → `100%: opacity:1` | Hero stats entry |

### 6.5 Contact Form

| Field | Type | Placeholder |
|---|---|---|
| Full Name | `text` | "Alexandra Whitmore" |
| Email | `email` | "a.whitmore@company.com" |
| Company | `text` | "Company Name" |
| Message | `textarea` | "Describe the strategic challenge you're facing..." |
| Submit | `button` | "Send Inquiry →" |

- **Submit Behavior**: `preventDefault()` → button text changes to "Inquiry Sent ✓" → resets after 3 seconds
- **Backend**: **None** — form is client-side only (no `action` URL, no API endpoint)

---

## 7. Visual Design Specifications

### 7.1 Grid Texture Overlay
```css
body::before {
  background-image:
    linear-gradient(rgba(201,168,76,.04) 1px, transparent 1px),
    linear-gradient(90deg, rgba(201,168,76,.04) 1px, transparent 1px);
  background-size: 60px 60px;
}
```

### 7.2 Services Section
- **Layout**: `clip-path: polygon(0 0, 100% 5%, 100% 100%, 0 95%)` diagonal edges
- **Grid**: `repeat(auto-fit, minmax(280px, 1fr))`, `1.5px` gap with gold border
- **Cards**: Top-line animation on hover (`right: 100% → 0`), background lifts to `--navy-lift`

### 7.3 Testimonials
- Decorative giant `"` quote mark: `font-size: 22rem`, positioned top-left
- Diamond-shaped avatars: `44px × 44px`, `transform: rotate(45deg)`
- Star indicators: `8px × 8px` gold squares rotated 45°

### 7.4 Diamond Ornaments
- Logo mark: `28px × 28px` rotated square with inner `10px` gold fill
- Philosophy section: nested `64px × 64px` diamond with inner border at `12px` inset
- Hero diamond: replaced by 3D canvas (hidden via `display: none !important`)

---

## 8. Content Architecture

### 8.1 Six Service Verticals

| # | Service | Description |
|---|---|---|
| 01 | Corporate Strategy | Portfolio design, growth architecture, long-horizon planning |
| 02 | M&A Advisory | Deal origination, due diligence, valuation, PMI |
| 03 | Digital Transformation | AI strategy, operating model reinvention, platform modernization |
| 04 | Operations Excellence | Supply chain optimization, lean transformation, performance improvement |
| 05 | Risk Management | Enterprise risk frameworks, regulatory strategy, resilience planning |
| 06 | Organizational Design | Leadership alignment, talent architecture, culture transformation |

### 8.2 Philosophy Pillars

| # | Pillar | Statement |
|---|---|---|
| 01 | Senior Attention | Partners average 22 years experience; senior at every stage |
| 02 | Evidence-Based | Primary research, proprietary data, rigorous financial modeling |
| 03 | Outcome-Committed | Stay until outcomes are realized |
| 04 | Relationship-Driven | 68% revenue from returning clients |

---

## 9. SEO & Accessibility Audit

### 9.1 Current State

| Check | Status | Detail |
|---|---|---|
| `<html lang>` | ✅ | `lang="en"` |
| `<meta charset>` | ✅ | `UTF-8` |
| `<meta viewport>` | ✅ | `width=device-width, initial-scale=1.0` |
| `<title>` | ✅ | "Apex Strategy — Global Management Consulting" |
| `<meta description>` | ❌ Missing | **Must add** |
| `<meta og:*>` | ❌ Missing | **Must add Open Graph tags** |
| `<meta twitter:*>` | ❌ Missing | **Must add Twitter Card tags** |
| `<link rel="icon">` | ❌ 404 | **Must create favicon** |
| Heading hierarchy | ✅ | Single `h1`, proper `h2`/`h3`/`h4` cascade |
| Semantic HTML | ✅ | `nav`, `section`, `footer`, `form`, `label` |
| Form labels | ✅ | `<label>` + `<input>` pairing |
| Color contrast | ⚠️ | `--white-dim` (55% opacity) may fail WCAG AA |
| Keyboard nav | ⚠️ | Custom cursor hides native focus indicators |

### 9.2 Recommended Meta Tags

```html
<meta name="description" content="Apex Strategy is a global management consulting firm advising the world's most consequential organizations since 1994.">
<meta property="og:title" content="Apex Strategy — Global Management Consulting">
<meta property="og:description" content="We partner with the world's most ambitious organizations to navigate complexity, unlock growth, and build enduring competitive advantage.">
<meta property="og:type" content="website">
<meta property="og:url" content="https://apex-strategy-ashy.vercel.app/">
<link rel="icon" type="image/x-icon" href="/favicon.ico">
```

---

## 10. Deployment & Infrastructure

### 10.1 Vercel Configuration

| Setting | Value |
|---|---|
| **Project Type** | Static Site |
| **Build Command** | None (pre-built HTML) |
| **Output Directory** | `.` (root) |
| **Framework Preset** | Other (static) |
| **Custom Domain** | `apex-strategy-ashy.vercel.app` (Vercel subdomain) |

### 10.2 Recommended `vercel.json`

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    }
  ],
  "cleanUrls": true,
  "trailingSlash": false
}
```

---

## 11. Agent Deployment Instructions

> [!TIP]
> The following section provides step-by-step instructions for any AI agent tasked with replicating or extending this website.

### 11.1 Replication Checklist

```
[ ] 1. Create single index.html file
[ ] 2. Embed all CSS in <style> within <head>
[ ] 3. Copy all CSS custom properties from Section 4
[ ] 4. Add Google Fonts <link> with preconnect
[ ] 5. Build semantic HTML structure per Section 5.1
[ ] 6. Implement 3D geodesic sphere per Section 6.2
[ ] 7. Implement custom cursor per Section 6.1
[ ] 8. Implement scroll reveal via IntersectionObserver
[ ] 9. Implement nav glassmorphism on scroll
[ ] 10. Implement contact form with client-side feedback
[ ] 11. Add SEO meta tags per Section 9.2
[ ] 12. Create favicon.ico (gold diamond on navy)
[ ] 13. Deploy to Vercel as static site
[ ] 14. Verify performance: TTFB < 50ms, Load < 500ms
[ ] 15. Test responsive at 900px breakpoint
```

### 11.2 Critical Implementation Notes

1. **No framework required** — single HTML file with inline CSS/JS
2. **Canvas 2D, not WebGL** — the 3D sphere uses `ctx.beginPath()` / `ctx.lineTo()`
3. **Icosahedron math** — golden ratio `φ = (1 + √5) / 2` generates initial 12 vertices
4. **Two subdivision passes** produce geodesic density (12 → 42 → 162 vertices)
5. **Depth sorting** is essential — edges and vertices sorted back-to-front
6. **Pulse particles** use sinusoidal fade (`Math.sin(t * π)`) with radial gradients
7. **`cursor: none`** on body — custom cursor replaces native one
8. **`clip-path`** on services creates diagonal section transitions
9. **`body:has()`** selector for cursor ring hover; requires modern browser
10. **Grid texture overlay** on `body::before` creates subtle background pattern

### 11.3 Extension Points

| Extension | Approach |
|---|---|
| Backend form submission | POST to Vercel Serverless Function or external API |
| CMS integration | Headless CMS; SSG with Next.js or Astro |
| Page transitions | View Transitions API or Barba.js |
| Analytics | GA4 or Plausible via `<script>` tag |
| Multi-page | Create `about.html`, `services.html` or migrate to framework |

---

## 12. Quality Gates

| Gate | Criteria | Tool |
|---|---|---|
| **Performance** | TTFB < 100ms, LCP < 1.5s, CLS = 0 | Lighthouse |
| **Accessibility** | WCAG 2.1 AA compliance | axe DevTools |
| **SEO** | Score ≥ 90 | Lighthouse |
| **Visual Regression** | Pixel-diff < 1% vs baseline | Percy / Chromatic |
| **Cross-Browser** | Chrome, Firefox, Safari, Edge (latest 2) | BrowserStack |
| **Responsive** | Functional at 320px–2560px | Manual + Device Lab |

---

## 13. Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| `body:has()` unsupported | Cursor ring won't expand | Feature-detect with `@supports` |
| No form backend | Lead data lost | Implement serverless API |
| Missing favicon | Unprofessional tab icon | Create and deploy `favicon.ico` |
| Missing meta description | Poor SEO | Add meta tags per Section 9.2 |
| Single-file architecture | Hard to maintain at scale | Migrate to components if expanding |
| Canvas CPU usage | High on low-end devices | Pause animation when tab hidden |

---

## 14. Appendix

### A. Network Request Manifest

| # | URL | Status | Type |
|---|---|---|---|
| 1 | `apex-strategy-ashy.vercel.app/` | 200 | document |
| 2 | `fonts.googleapis.com/css2?...` | 200 | stylesheet |
| 3 | `fonts.gstatic.com/.../cormorantgaramond/...woff2` | 200 | font |
| 4 | `fonts.gstatic.com/.../inter/...woff2` | 200 | font |
| 5 | `fonts.gstatic.com/.../cormorantgaramond/...woff2` | 200 | font |
| 6 | `apex-strategy-ashy.vercel.app/favicon.ico` | 404 | other |

### B. Browser Compatibility

| Feature | Chrome | Firefox | Safari | Edge |
|---|---|---|---|---|
| CSS `:has()` | 105+ | 121+ | 15.4+ | 105+ |
| `IntersectionObserver` | 51+ | 55+ | 12.1+ | 15+ |
| `ResizeObserver` | 64+ | 69+ | 13.1+ | 79+ |
| CSS `clamp()` | 79+ | 75+ | 13.1+ | 79+ |
| `backdrop-filter` | 76+ | 103+ | 9+ | 79+ |
| Canvas 2D | All | All | All | All |

---

> **Document End** — PRD-APEX-2026-001 v1.0.0
