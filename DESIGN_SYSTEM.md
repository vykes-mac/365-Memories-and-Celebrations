# 365: Birthdays & Anniversaries — iOS Design System (Glassmorphism)

> Purpose: Define a **cohesive, emotional, soft** visual + interaction system for *365*.  

---

## 1) Design Principles

### Emotional goals
- **Warmth & safety:** the UI feels like a gentle scrapbook—never clinical.
- **Anticipation:** upcoming moments feel “glowing” and inviting.
- **Memory-first:** photos and relationships feel central, not secondary.

### Visual principles
- **Glassmorphism everywhere (tastefully):** frosted layers over soft backgrounds.
- **Soft geometry:** rounded corners, pill controls, circular avatars, friendly spacing.
- **Quiet-to-celebratory range:** calm baseline; delight is reserved for meaningful moments.

### Interaction principles
- **One-hand friendly:** primary actions near bottom; sheets over pushes when possible.
- **Progressive disclosure:** surface “what matters today/this week” first.
- **Gentle motion:** subtle blur/opacity transitions, small haptics; avoid noisy animations.

### Images 
**Useful images:** use images when necessary to enhance the emotional impact of the UI. use the nano-banana/SKILL.md file for image generation (use sparingly and only when necessary) 

---

## 2) Theme System

### Theme Names (user-selectable)
- **Soft Blush** (default): romantic, airy, hopeful
- **Moonlight**: calm, reflective, slightly cooler
- **Warm Linen**: cozy, grounded, nostalgic
- **Garden**: fresh, uplifting, celebratory

> Implementation note: each theme provides a *Background*, *Accent*, *Secondary Accent*, and *Category colors*.

### Core Background Recipe (all themes)
- Base background: **near-white** with a **very subtle gradient** (2–6% shift).
- Background should be subtle gradient created with metal shader with subtle animation.
- Decorative “glow blobs”: faint radial gradients behind primary content areas.
- Avoid harsh contrast: keep large areas low-saturation.

### Suggested Color Tokens (hex placeholders)
These are **starting points** for exploration (tune in design):
- `bg.base`  
  - Soft Blush: `#FBF6F8`
  - Moonlight: `#F6F7FB`
  - Warm Linen: `#FBF7F0`
  - Garden: `#F5FBF6`
- `accent.primary`  
  - Soft Blush: `#B84BFF` (violet-pink)
  - Moonlight: `#5B6CFF` (periwinkle)
  - Warm Linen: `#FF7A59` (soft coral)
  - Garden: `#31C56B` (fresh green)
- `accent.secondary` (used for “glow ring” / gradients)
  - Soft Blush: `#FF7AD9`
  - Moonlight: `#9D7BFF`
  - Warm Linen: `#FFB35A`
  - Garden: `#69E3A1`
- `text.primary`: `#1C1B1F`
- `text.secondary`: `#5E5A66`
- `divider`: `rgba(0,0,0,0.06)`

### Category Colors (semantic)
- Birthday: `category.birthday`
- Anniversary: `category.anniversary`
- Milestone: `category.milestone`
- Memorial: `category.memorial`
- Just Because: `category.justBecause`
- Custom categories: user-defined, mapped to a curated palette

> Rule: category color = **ring / dot highlight / icon**, never full-screen saturation.

---

## 3) Glassmorphism Specification (Foundation)

### Glass Surface Token Set
Use **two** main surface types:
1. **Glass.Card** (most surfaces)
   - Blur: **18–28**
   - Fill: `rgba(255,255,255,0.55)` (light themes)
   - Stroke: `rgba(255,255,255,0.40)` top highlight
   - Shadow: subtle, wide, low-opacity
2. **Glass.Sheet** (bottom sheets / modals)
   - Blur: **28–40**
   - Fill: `rgba(255,255,255,0.72)`
   - Stroke: `rgba(255,255,255,0.50)`
   - Shadow: slightly stronger than cards

### Lighting & Depth
- **Top highlight**: 1px inner stroke, brighter at top-left.
- **Edge shadow**: soft drop shadow + tiny ambient shadow.
- **No hard borders**: use hairline strokes + blur separation.

### Content on glass
- Text on glass must maintain **AA contrast**.
- Avoid stacking too many glass layers; keep to **max 3** visible layers.

---

## 4) Typography

### Type Pairing
- **Display / editorial headings**: a soft serif for emotional tone
- **Body / UI**: a clean sans for clarity

### iOS-friendly suggestions (pick 1 pairing)
- **Option A (native)**: New York (Display) + SF Pro (Text)
- **Option B (brand)**: DM Serif Display + Inter
- **Option C (modern soft)**: Playfair Display + SF Pro (Text)

### Type Scale (points)
- `display.l`: 34–36 (hero titles)
- `display.m`: 28–30 (screen titles)
- `title.l`: 22–24 (section titles)
- `title.m`: 18–20 (card titles)
- `body`: 16–17
- `caption`: 12–13
- `micro`: 10–11 (badges only)

### Text Treatments
- Headings: serif + slightly increased tracking
- Buttons: sans, medium weight
- Badges: all-caps optional, tiny tracking, very short

---

## 5) Layout & Spacing

### Grid
- 8pt baseline grid
- Standard padding:
  - Screen horizontal padding: **20**
  - Card padding: **16**
  - Compact card padding: **12**
  - Section spacing: **16–24**

### Corner Radii
- `radius.s`: 12
- `radius.m`: 16
- `radius.l`: 24
- `radius.xl`: 32
- Pills: 999

### Elevation (shadow tokens)
- `elev.1`: ambient, almost invisible (chips)
- `elev.2`: cards
- `elev.3`: floating buttons / overlays
- `elev.4`: sheets / modals

---

## 6) Iconography & Illustration

### Icons
- Rounded-line icons, 2.0px stroke
- Prefer friendly shapes: hearts, sparkles, cake, ribbon, candle
- Use `accent.primary` for active icons; gray for inactive.

### Illustration
- Use warm, diverse, inclusive illustration sets.
- Keep illustration backgrounds minimal so glass UI remains dominant.

---

## 7) Motion, Haptics & Delight

### Motion rules
- Duration: 180–320ms
- Easing: iOS standard (ease-in-out, spring for sheets)
- Use blur transitions when presenting glass sheets.

### Delight moments
- **Confetti** only on: “Moment completed”, “Shared”, “Big anniversary”
- **Glow pulse**: upcoming events in next 7 days
- **Micro-shimmer**: on “Share Pack ready” state

### Haptics
- Light impact: toggles, chips, dot selection
- Medium impact: save moment, finalize share pack
- Success notification: scheduled successfully

---

## 8) Core Components

### 8.1 Navigation
**Tab bar** (glass)
- Tabs: Garden / Calendar / Create / Library / Profile
- Glass fill + blur; active tab uses accent dot + label color.

**Top bar**
- Year selector (e.g., “2026”)
- Settings / Search icons
- Keep minimal; avoid clutter.

---

### 8.2 365 Garden Grid
**Dot**
- Base: tiny circle (4–6pt)
- Event day: ring + inner dot
- Multi-event day: ring + stacked micro-dots (max 3) OR stronger glow
- Today: pulse ring (subtle)

**Heatmap cell**
- Rounded square (6–10pt)
- Intensity indicates number of moments (1–4+)

**Legend**
- Replace “developer legend” with emotional copy:
  - “quiet → radiant”
  - or “a year of connection”

---

### 8.3 Cards
**Moment Card**
- Avatar + name + occasion
- Date label + countdown badge (“7 days”)
- Primary action: “Plan” / “Share” / “Message”
- Glass card + category ring on leading edge.

**Person Card**
- Large avatar, relationship label
- Upcoming moment chips (birthday, anniversary)

---

### 8.4 Chips & Pills
- Category chip: icon + label, glass fill
- Selected: stronger fill + subtle glow + checkmark
- Use for filters and quick add.

---

### 8.5 Buttons
**Primary Button**
- Full-width pill
- Gradient or soft glow using theme accents
- Label: short, warm verbs (“Start my 365”, “Save this moment”)

**Secondary Button**
- Glass outline, no gradient
- For “Skip”, “Later”, “View all”

**Floating Action Button**
- Circular glass with plus icon
- Soft shadow and blur behind.

---

### 8.6 Inputs
**Text field**
- Glass inset surface
- Placeholder tone: warm (“e.g., Sarah”)
- Validation: gentle (“Add a date to continue”)

**Toggle**
- iOS toggle style; tint uses theme accent.

---

### 8.7 Bottom Sheets (Glass.Sheet)
Used for:
- Day details
- Add moment
- Quick share
- Theme selection

Sheet sections:
- Header: title + close
- Body: content cards
- Footer: primary action button

---

### 8.8 Media & Collage
**Media strip**
- Rounded thumbnails, 10–12pt radius
- “+ Add” tile uses glass.

**Collage templates**
- Polaroid stack
- Soft grid
- Film strip
- “Then & Now”
- Add subtle paper textures behind media, not on the whole screen.

---

## 9) States & Feedback

### Loading
- Skeleton shimmer on glass cards
- “Preparing your share pack…” with calm animation

### Empty states
- Editorial headline + small illustration
- CTA: “Add Mom”, “Add Best Friend”, “Add Someone Special”

### Errors
- Friendly language; avoid blame
- Provide action: “Try again” / “Choose different photos”

---

## 10) Accessibility

- Support Dynamic Type (especially body text).
- Color is never the only indicator:
  - Rings + icons + labels for categories
- Reduce Motion: disable shimmer/confetti, keep fades.
- Ensure tap targets ≥ 44pt.

---

## 11) Token Summary (for engineers)

### Colors
- `bg.base`, `bg.gradientA`, `bg.gradientB`
- `glass.card.fill`, `glass.card.stroke`, `glass.sheet.fill`, `glass.sheet.stroke`
- `accent.primary`, `accent.secondary`
- `text.primary`, `text.secondary`, `text.tertiary`

### Typography
- `font.display`, `font.title`, `font.body`
- `size.displayL`, `size.displayM`, `size.titleL`, `size.body`, `size.caption`

### Layout
- `spacing.8/12/16/20/24/32`
- `radius.12/16/24/32/999`
- `blur.card`, `blur.sheet`

### Motion
- `dur.fast=180`, `dur.base=240`, `dur.slow=320`
- `ease.standard`, `ease.spring`

---

## 12) Example Copy Bank (tone guide)

- “A year of the people you love.”
- “Who makes your year special?”
- “Add a moment”
- “Make it feel special”
- “Ready to share the love”
- “Your memory garden”
