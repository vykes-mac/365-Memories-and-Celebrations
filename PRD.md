# 365: Memories & Celebrations  — Product Requirements Document (PRD)

## 1) Overview

**Product:** 365: Memories & Celebrations (iOS)  
**Tagline:** *A year of the people you love.*  
**Positioning:** A **memory garden** that helps users capture meaningful dates, attach memories, and generate beautiful shareable collages/video packs on the right day.

### Problem
People forget important dates, scramble to find photos, and end up posting late (or not at all). Traditional calendars feel transactional, not emotional.

### Solution
A **365-day visual “garden”** (dots/heatmap) that turns dates into a year-view of relationships—plus a **Celebration Pack** generator that makes it effortless to share something beautiful.

---

## 2) Goals & Success Metrics

### Primary goals
1. Help users **capture** important dates for the year in minutes.
2. Make upcoming dates feel **organized + emotionally warm**.
3. Enable quick creation of **beautiful memory content** (collage/video + captions).
4. Drive recurring engagement through **gentle reminders** and “this week/month” views.

### Success metrics (MVP)
- Activation: % users who add ≥ 3 moments in onboarding
- Engagement: weekly active users; “view garden” sessions/week
- Creation: % users generating ≥ 1 Celebration Pack
- Retention: D7 and D30
- Conversion: free → paid (if subscription enabled)

---

## 3) Target Audience

### Primary
Women who are the “memory keepers” in families/friend groups:
- Keep birthdays/anniversaries in their head
- Share photos socially
- Value sentimental moments and aesthetics

### Secondary
- Partners who want help remembering anniversaries
- Busy professionals (low time, high intention)
- Long-distance families/friends

---

## 4) Core User Stories

### Onboarding & setup
- As a user, I want to **import birthdays** from contacts so I don’t have to type everything.
- As a user, I want to quickly add **my top 3 people** so the app feels useful immediately.
- As a user, I want to choose a **theme** that matches my vibe.

### Garden / discovery
- As a user, I want to see my entire year at a glance as a **beautiful grid**.
- As a user, I want to tap a day and see **what’s happening** with details and actions.
- As a user, I want an “Upcoming” view so I can plan **this week**.

### Creating a Celebration Pack
- As a user, I want to add photos/videos to an event to create a **collage** quickly.
- As a user, I want the app to suggest **captions** that match my relationship.
- As a user, I want content ready on the day so I can **post in seconds**.

### Notifications
- As a user, I want reminders **7 days before / 1 day before / day of**.
- As a user, I want quiet hours so the app never bothers me at night.

---

## 5) Key Differentiators

1. **365 Garden** as the signature identity (emotional year-view)
2. **Glassmorphism aesthetic** (soft, premium feel)
3. **Celebration Pack** (collage/video + captions + schedule)
4. Relationship context (labels like “Mom”, “Best Friend”) informs suggestions

---

## 6) MVP Scope

### Must-have (MVP)
- 365 Garden view (Dot Garden + Heatmap toggle)
- Add Moment flow (person + relationship + date + category + recurring)
- Day Details sheet (list moments, actions, quick add media)
- Media attach (photos + videos) to person/moment
- Collage generator (templates + export assets)
- Caption suggestions (basic, template-based; AI optional)
- Reminders (7 days / 1 day / day-of) + quiet hours
- Themes (at least Soft Blush + one alternative)
- Data sync/backup (iCloud preferred; or account-based if needed)

### Nice-to-have (post-MVP)
- Video highlight generator with music
- Gift idea notes + links
- Printed “Year Memory Book” export
- Shared gardens (family/couple)
- Widgets (upcoming next 7 days)
- Auto-resurfacing “Through the years” memories

### Out of scope (MVP)
- Fully automated posting to every platform (use share sheet / export)
- Complex social scheduling integrations that are unreliable or restricted

---

## 7) Product Flows

### 7.1 Onboarding
1. Welcome: “A year of the people you love.”
2. Import options:
   - Contacts birthdays (optional)
   - Calendar import (optional)
3. Theme selection
4. Add top moments (guided):
   - Add Mom
   - Add Best Friend
   - Add Someone Special
5. Notifications permissions + preferences
6. Land on Garden (current year)

### 7.2 Add Moment
Entry points:
- FAB (+)
- Empty state CTA
- Day tap → “Add moment”
Steps:
1. Who is this for? (name + relationship)
2. When do we celebrate? (date + recurring toggle)
3. Occasion category (birthday/anniversary/milestone/memorial/just because/custom)
4. Optional: add notes
5. Save

### 7.3 Garden → Day Details
- Tap day → bottom sheet
- Shows:
  - Moments list
  - Countdown badge
  - Quick actions (call/text/share/plan)
  - Media preview strip
  - CTA: “Create Celebration Pack”

### 7.4 Celebration Pack
1. Select template (Polaroid, grid, film strip, then&now)
2. Pick photos/videos (smart suggestions: person’s top media)
3. Auto-generate:
   - Collage image(s)
   - Optional short video (if in scope)
   - Caption suggestions
4. Save to library
5. Share options:
   - iOS share sheet
   - Save to Photos
   - “Schedule reminder to post” (in-app reminder)

---

## 8) Functional Requirements

### 8.1 Garden View
- Displays 365 days for selected year
- Two modes: Dot Garden / Heatmap
- Highlighting:
  - Event days: ring + glow
  - Multi-event: stacked micro dots or stronger glow
  - Today: subtle pulse
- Year switcher
- Tap → Day Details

### 8.2 Moments & People
- Person fields:
  - name, relationship label, avatar (optional), notes
- Moment fields:
  - date, category, recurring (yearly), linked person(s), title, notes
- Support:
  - Multiple moments per day
  - Multiple people per moment (optional in later versions)

### 8.3 Media
- Attach photos/videos:
  - to person
  - to specific moment
- Media browsing:
  - recent, favorites, suggested
- Basic editing:
  - reorder
  - delete
  - crop (optional for MVP)

### 8.4 Collage Generation
- Template selection
- Layout rendering
- Export output:
  - image(s) at social-friendly sizes
  - optional story format
- Save to “Creative Library”

### 8.5 Caption Suggestions
MVP (non-AI):
- Template-based captions by category + relationship
- Variables: {Name}, {Age}, {Relationship}, {MemoryPrompt}

AI (optional / later):
- Prompt includes relationship context + selected photos metadata (no faces analysis required)
- Tone choices: sweet / funny / short

### 8.6 Notifications
- User-configurable reminders:
  - 7 days before
  - 1 day before
  - day of (morning)
- Quiet hours
- Notification copy feels warm and personal

### 8.7 Themes
- Theme selection screen
- Theme affects:
  - background gradients
  - primary/secondary accents
  - category ring colors
- Theme can be changed anytime

---

## 9) Non-Functional Requirements

- Performance:
  - Garden must render smoothly (60fps target)
  - Media operations must not block UI
- Reliability:
  - Notifications must be consistent across timezones and DST
- Privacy:
  - Photos remain on-device unless user enables backup/sync
  - Clear permission prompts and explanations
- Accessibility:
  - Dynamic Type, Reduce Motion support
  - Color not sole indicator
- Offline:
  - Core browsing/editing works offline; sync when available

---

## 10) Data Model (Suggested)

### Entities
- **User** (optional if account-based)
- **Person**
  - id, name, relationship, avatarRef, notes
- **Moment**
  - id, personId (or many-to-many), date, recurring, categoryId, title, notes
- **Category**
  - id, name, colorToken, icon
- **Media**
  - id, personId?, momentId?, localIdentifier, type(photo/video), createdAt
- **CollageProject**
  - id, templateId, momentId?, assets[], captionDrafts[], createdAt
- **ReminderSetting**
  - id, offsets (7d/1d/dayOf), quietHours, enabled

---

## 11) Analytics (Events)

- `onboarding_started`
- `import_contacts_tapped`
- `theme_selected`
- `moment_created`
- `garden_day_opened`
- `celebration_pack_started`
- `celebration_pack_exported`
- `caption_copied`
- `reminder_enabled`
- `subscription_viewed` / `subscription_purchased` (if applicable)

---

## 12) Monetization (Optional for MVP)

### Free
- Unlimited moments
- Garden view
- Basic reminders
- Limited collage templates (e.g., 2)

### Plus (subscription)
- Premium templates
- Video highlights
- Expanded caption styles
- Creative Library history
- Backup/sync across devices

### One-time add-on
- “Year Memory Book” export (PDF/print-ready)

---

## 13) Release Plan

### v0.1 (MVP)
- Garden + add moment + day sheet
- Theme selection (2 themes)
- Reminders
- Basic collage templates + export
- Creative Library

### v0.2
- Better media suggestions
- More templates
- Widgets (upcoming)

### v1.0
- Optional AI captions
- Video highlight (if feasible)
- Memory resurfacing (“Through the years”)

---

## 14) Risks & Mitigations

- **Auto-posting limitations:** platform restrictions → use share pack + reminders instead.
- **Notification timing issues (DST/timezone):** store event in local time + robust scheduling tests.
- **Media privacy concerns:** default on-device, transparent permission messaging.
- **Glassmorphism readability:** enforce contrast checks + reduce transparency option if needed.

---

## 15) Acceptance Criteria (MVP)

1. User can add at least 3 moments and see them highlighted on the Garden.
2. User can tap a highlighted day and view moment details.
3. User can attach photos to a moment and generate a collage.
4. User can export/share the collage and save it in the Creative Library.
5. User can enable reminders and receive notifications on schedule.
6. Theme selection applies consistently across the app.
