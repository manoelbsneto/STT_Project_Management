# GEMINI CLI PROMPT — PMO Executive Viewer V3 Ultra-Premium Rebuild

## ROLE

You are simultaneously a **Senior UI/UX Design Architect**, **Senior Fullstack Developer**, **CSS Animation Specialist**, **WebGL/Canvas Expert**, and **Senior QA Engineer** working at a Fortune 500 design consultancy. Your mission is a FULL REFACTOR of an existing PMO Executive Dashboard web application into a **category-defining, award-winning visual experience**.

## CONTEXT

### Repository
- **Root:** `d:/VMs/Projetos/STT_Project_Management`
- **Target directory:** `frontend/pmo-executive-viewer/`
- **Current files:** `index.html`, `styles.css`, `app.js` (static site, no build tools)

### Brand System (MANDATORY — zero deviation)
Read the official Indra/Minsait DSS v4.0 design tokens from:
- `frontend/dss-showcase/UI_UX/DSS_Universal_Standard.md`
- `frontend/dss-showcase/UI_UX/styles.css`

**12 Canonical Color Swatches (use ONLY these):**
| Token | Hex |
|---|---|
| --indra-deep | #002B3A |
| --indra-dark | #003E50 |
| --indra-primary | #06596E |
| --indra-secondary | #346679 |
| --indra-teal | #3F96AE |
| --indra-cyan | #00B0BD |
| --indra-light | #7A9CAE |
| --indra-blue-gray | #B3C1DA |
| --indra-sky | #BADFF3 |
| --indra-warm-gray | #B0B4BD |
| --indra-off-white | #F2F5F6 |
| Semantic: success | #27AE60 |
| Semantic: warning | #FF9800 |
| Semantic: error | #E91E63 |

### Expert Skills (READ before coding)
Read these skill files for design patterns:
- `skills/data_expert_skills/fortune500-executive-dashboard.md`
- `skills/data_expert_skills/css-animation-microinteraction-expert.md`
- `skills/data_expert_skills/dashboard-design__dashboard-design__SKILL.md`
- `skills/data_expert_skills/senior-uiux-data-products.md`
- `skills/data_expert_skills/software-ui-ux-design.md`
- `skills/data_expert_skills/chartjs-d3-visualization-expert.md`
- `skills/data_expert_skills/component-checklist.md`
- `skills/data_expert_skills/layout_patterns.md`

### What the app does
1. User uploads a `.md` markdown status file (or drags/drops)
2. App parses H1=title, H2=sections, tables, lists, code blocks
3. Renders as an executive C-level dashboard with KPI cards, status tables, navigation
4. Auto-detects SHIP/NO-SHIP/CONDITIONAL gate status
5. Fully static — NO backend, NO frameworks, pure HTML+CSS+JS

## REQUIREMENTS — VISUAL EXCELLENCE

### 1. LEFT SIDEBAR — 4D/5D Experience
- Fixed left sidebar (260px) with **3D extruded buttons** using CSS `transform-style: preserve-3d`
- Each nav button must have: front face, bottom face (depth shadow), side glow
- **Hover:** buttons lift up (translateZ + translateY), glow intensifies, subtle rotation
- **Active state:** persistent cyan glow halo + left accent bar
- **Scroll spy:** active button follows current section automatically
- Logo area: animated 3D rotating cube using CSS transforms
- Upload button at bottom: pulsing glow animation, 3D depth effect

### 2. PARTICLE NETWORK BACKGROUND
- Full-viewport `<canvas>` behind everything with animated particles
- Particles: small dots (0.5-2px) in cyan color, floating with random velocity
- Connection lines between nearby particles (distance < 120px)
- Must be performant: use `requestAnimationFrame`, max 80-100 particles
- Opacity: 0.4-0.6 so it's atmospheric, not distracting

### 3. HERO LANDING PAGE
- Full-height section with animated CSS grid background (slowly scrolling grid lines)
- Large typography using `Outfit` font family, weight 300 for elegance
- Floating glassmorphism preview cards on the right side with `cardFloat` animation
- Shimmer effect on primary CTA button (gradient sweep animation)
- Format tags (.MD, .MARKDOWN, .TXT) as frosted-glass chips
- "EXECUTIVE INTELLIGENCE PLATFORM" badge with pulsing dot

### 4. PAGE TRANSITIONS
- Hero → Dashboard: smooth `opacity + translateY + scale` animation (0.7s cubic-bezier)
- Each section enters viewport with staggered `fadeSlideIn` animation
- KPI cards: cascade animation with 80ms delay between each
- Tables: slide in with subtle glass-refraction effect

### 5. KPI CARDS
- Glassmorphism: `background: rgba(0,43,58,0.55)` + `backdrop-filter: blur(16px)`
- Top accent line: gradient shimmer (transparent → cyan → transparent)
- Hover: `translateY(-4px) scale(1.02)` with box-shadow glow
- Large numbers: 40px, weight 800, `font-feature-settings: 'tnum'`
- Color-coded: success=green, warning=orange, error=pink, neutral=cyan

### 6. TABLES
- Glassmorphism container with rounded corners (14px) and glass border
- Sticky header with uppercase labels
- Row hover: subtle cyan tint background
- Status cells: render as **pills** with dot indicator + rounded background
- Status classification: PASS/DONE/COMPLETED=green, PENDING/PARTIAL=orange, FAIL/ERROR=pink

### 7. LIST ITEMS
- Each list item is a glassmorphism card with left cyan dot (+ glow shadow)
- Hover: `translateX(4px)` slide effect + border color change
- Staggered entrance animation

### 8. TYPOGRAPHY
- Primary: `Inter` (body, labels, data)
- Display: `Outfit` (headings, hero text — weight 300 for luxury feel)
- Monospace: `Space Grotesk` (code blocks, timestamps, technical data)
- Google Fonts import all three

### 9. RESPONSIVE
- Desktop: full sidebar + content
- Tablet (≤1024px): sidebar collapses off-screen, hamburger menu
- Mobile (≤768px): single column, stacked KPIs

### 10. MICRO-INTERACTIONS
- All interactive elements: 0.25s transitions with `cubic-bezier(0.34, 1.56, 0.64, 1)` (spring easing)
- Buttons: 3D press effect on `:active` (translateY down, remove shadow)
- Gate status badge: pulsing dot animation
- Sidebar: scroll progress indicator (thin gradient bar)
- `prefers-reduced-motion`: respect accessibility, disable animations

## TECHNICAL CONSTRAINTS

1. **Pure static site**: HTML + CSS + JS only. No React, no build tools, no npm
2. **Three files only**: `index.html`, `styles.css`, `app.js`
3. **No external JS libraries**: vanilla JS only (no jQuery, no GSAP, no Three.js)
4. **Canvas particles**: implement from scratch using Canvas 2D API
5. **Markdown parser**: built-in, handles H1, H2, tables, ordered/unordered lists, code blocks, inline formatting (bold, italic, backtick)
6. **File handling**: `<input type="file">` + drag-and-drop with overlay
7. **Demo mode**: built-in "LOAD DEMO" button with realistic PMO status data
8. **Performance**: 60fps animations, passive event listeners, will-change hints

## OUTPUT

Rewrite ALL THREE files completely:
1. `frontend/pmo-executive-viewer/index.html`
2. `frontend/pmo-executive-viewer/styles.css`
3. `frontend/pmo-executive-viewer/app.js`

After writing the files, open `http://localhost:3847` in the browser (the server is already running via `npx serve`) and verify:
- Landing page renders with particles, sidebar, hero section
- LOAD DEMO works and transitions to dashboard
- KPI cards display with correct numbers
- Tables render with colored status pills
- Sidebar nav highlights on scroll
- All animations are smooth at 60fps

## QUALITY BAR

This must look like it was designed by **Pentagram** and built by a **Google senior frontend team**. If anyone sees this dashboard, their first reaction must be "this is incredibly polished." No generic designs. No basic layouts. Every pixel must communicate premium quality and technological sophistication.
