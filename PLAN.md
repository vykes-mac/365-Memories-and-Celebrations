# PLAN.md

This file tracks implementation progress for the 365: Memories & Celebrations iOS app. It is designed for long-running agent sessions following Anthropic's recommended harness patterns.

---

## Quick Start (Init Checklist)

Before starting work, run these commands to understand current state:

```bash
# 1. Check recent git history
git log --oneline -20

# 2. Review this file's Activity Log section for recent work. ACTIVITY.md
```

---

## Feature List

Each feature includes verification steps. **Do not remove or edit existing verification steps.** Mark `passes: true` only when all verification steps succeed.

### Terminology Update
- In this plan, “glass” refers to **SwiftUI liquid glass materials**. Do not simulate glass effects with custom blur layers.

### Phase 1: Foundation

#### F1.1 - Project Structure & Architecture
- **Category:** Foundation
- **Description:** Set up MVVM architecture with proper folder structure, dependency injection, and base protocols
- **Verification Steps:**
  1. Project has folders: Models, Views, ViewModels, Services, Utilities, Resources
  2. Base protocols exist for ViewModels and Services
  3. Project builds without warnings
- **passes:** true

#### F1.2 - Design System Implementation
- **Category:** Foundation
- **Description:** Implement design tokens from DESIGN_SYSTEM.md including colors, typography, spacing, and liquid glass materials
- **Verification Steps:**
  1. Theme enum exists with cases: softBlush, moonlight, warmLinen, garden
  2. Color tokens are accessible via `Theme.current.colors.bgBase`, etc.
  3. Typography styles match spec (display, title, body, caption scales)
  4. GlassCard and GlassSheet view modifiers render blur + fill correctly
  5. Spacing constants follow 8pt grid
- **Note:** GlassCard/GlassSheet should wrap SwiftUI liquid glass materials; avoid custom blur simulation.
- **passes:** true

#### F1.3 - Data Models (SwiftData)
- **Category:** Foundation
- **Description:** Implement core data models: Person, Moment, Category, Media, CollageProject, ReminderSetting
- **Verification Steps:**
  1. All 6 model classes are defined with correct properties per PRD section 10
  2. Relationships are properly configured (Person ↔ Moment, Moment ↔ Media)
  3. Models persist and retrieve correctly in unit tests
  4. Category has default seed data (birthday, anniversary, milestone, memorial, justBecause)
- **passes:** true

#### F1.4 - Navigation Structure
- **Category:** Foundation
- **Description:** Implement tab-based navigation with 5 tabs: Garden, Calendar, Create, Library, Profile
- **Verification Steps:**
  1. TabView renders with 5 tabs and correct icons
  2. Tab bar uses glass effect per design system
  3. Each tab navigates to its root view
  4. Active tab shows accent color indicator
- **passes:** false

---

### Phase 2: Core Features

#### F2.1 - 365 Garden View (Dot Mode)
- **Category:** Garden
- **Description:** Year-at-a-glance dot grid showing 365 days with event highlighting
- **Verification Steps:**
  1. Grid displays 365 dots for selected year
  2. Dots with events show category-colored ring
  3. Multi-event days show stacked micro-dots or stronger glow
  4. Today's dot has subtle pulse animation
  5. Year switcher allows changing displayed year
  6. Tapping a dot triggers day details sheet
  7. Renders at 60fps on iPhone 12 and newer
- **passes:** false

#### F2.2 - 365 Garden View (Heatmap Mode)
- **Category:** Garden
- **Description:** Alternative heatmap visualization showing moment density
- **Verification Steps:**
  1. Toggle switches between Dot and Heatmap modes
  2. Heatmap cells are rounded squares (6-10pt)
  3. Intensity varies based on number of moments (1-4+)
  4. Tap behavior matches Dot mode
- **passes:** false

#### F2.3 - Day Details Sheet
- **Category:** Garden
- **Description:** Bottom sheet showing moments for a selected day with actions
- **Verification Steps:**
  1. Sheet presents from bottom with Glass.Sheet styling
  2. Shows list of moments for selected day
  3. Displays countdown badge ("7 days", "Tomorrow", "Today")
  4. Quick action buttons: call, text, share, plan
  5. Media preview strip shows attached photos/videos
  6. "Create Celebration Pack" CTA is visible
  7. "Add moment" option available for empty days
- **passes:** false

#### F2.4 - Add Moment Flow
- **Category:** Moments
- **Description:** Multi-step flow to create a new moment
- **Verification Steps:**
  1. Flow accessible from FAB, empty state, and day sheet
  2. Step 1: Name + relationship input with suggestions
  3. Step 2: Date picker + recurring yearly toggle
  4. Step 3: Category selection (birthday/anniversary/milestone/memorial/just because/custom)
  5. Step 4: Optional notes field
  6. Save persists moment to SwiftData
  7. New moment appears on Garden immediately
  8. Analytics event `moment_created` fires on save
- **passes:** false

#### F2.5 - Person Management
- **Category:** People
- **Description:** Create, edit, and view person profiles
- **Verification Steps:**
  1. Person card displays avatar, name, relationship label
  2. Upcoming moment chips shown on person card
  3. Can edit person details (name, relationship, notes)
  4. Can attach/remove avatar photo
  5. Deleting person prompts confirmation and removes linked moments
- **passes:** false

---

### Phase 3: Media & Celebration Packs

#### F3.1 - Media Attachment
- **Category:** Media
- **Description:** Attach photos/videos to people and moments
- **Verification Steps:**
  1. Photo picker allows selecting from library
  2. Can attach media to a Person
  3. Can attach media to a specific Moment
  4. Media strip shows thumbnails with "+ Add" tile
  5. Can reorder attached media
  6. Can delete attached media
  7. Media operations don't block UI (async loading)
- **passes:** false

#### F3.2 - Collage Generator
- **Category:** Celebration Pack
- **Description:** Generate shareable collages from selected photos
- **Verification Steps:**
  1. Template selection screen shows: Polaroid, Grid, Film Strip, Then & Now
  2. Photo selection allows picking from person's media or library
  3. Collage renders with selected template layout
  4. Export produces social-friendly image sizes
  5. Story format option available
  6. Saved collages appear in Creative Library
  7. Analytics event `celebration_pack_started` fires on entry
  8. Analytics event `celebration_pack_exported` fires on export
- **passes:** false

#### F3.3 - Caption Suggestions
- **Category:** Celebration Pack
- **Description:** Template-based caption suggestions by category and relationship
- **Verification Steps:**
  1. Caption suggestions appear after collage generation
  2. Suggestions use variables: {Name}, {Age}, {Relationship}
  3. Multiple caption options provided (3+)
  4. Tap to copy caption to clipboard
  5. Analytics event `caption_copied` fires on copy
- **passes:** false

#### F3.4 - Creative Library
- **Category:** Library
- **Description:** View and manage saved collages and celebration packs
- **Verification Steps:**
  1. Library tab shows grid of saved collages
  2. Can view full collage detail
  3. Can re-share from library
  4. Can delete from library
  5. Empty state shows helpful CTA
- **passes:** false

---

### Phase 4: Notifications & Settings

#### F4.1 - Reminder System
- **Category:** Notifications
- **Description:** Configurable reminders for upcoming moments
- **Verification Steps:**
  1. Settings allow enabling/disabling reminders
  2. Offset options: 7 days before, 1 day before, day of
  3. Quiet hours setting prevents notifications during set times
  4. Notifications schedule correctly across timezone changes
  5. Notification copy is warm and personal (matches moment/person)
  6. Analytics event `reminder_enabled` fires when enabled
- **passes:** false

#### F4.2 - Theme Selection
- **Category:** Settings
- **Description:** User-selectable app theme
- **Verification Steps:**
  1. Theme picker shows all 4 themes with previews
  2. Selecting theme applies immediately
  3. Theme persists across app launches
  4. All screens respect current theme colors
  5. Analytics event `theme_selected` fires on change
- **passes:** false

#### F4.3 - Profile & Settings Screen
- **Category:** Settings
- **Description:** User profile and app settings
- **Verification Steps:**
  1. Profile tab shows user settings
  2. Theme selection accessible
  3. Notification preferences accessible
  4. Quiet hours configuration
  5. Data/backup options visible (iCloud toggle if implemented)
- **passes:** false

---

### Phase 5: Onboarding

#### F5.1 - Welcome Flow
- **Category:** Onboarding
- **Description:** First-launch experience guiding users through setup
- **Verification Steps:**
  1. Welcome screen shows on first launch only
  2. "A year of the people you love" tagline displayed
  3. Import options: Contacts birthdays, Calendar import (both optional/skippable)
  4. Theme selection step
  5. Guided moment creation: "Add Mom", "Add Best Friend", "Add Someone Special"
  6. Notification permission request with clear explanation
  7. Completes to Garden view
  8. Analytics event `onboarding_started` fires at start
  9. Analytics event `import_contacts_tapped` fires if contacts import used
- **passes:** false

#### F5.2 - Contacts Import
- **Category:** Onboarding
- **Description:** Import birthdays from device contacts
- **Verification Steps:**
  1. Requests contacts permission with clear explanation
  2. Scans contacts for birthday fields
  3. Shows preview of importable birthdays
  4. User can select/deselect individual contacts
  5. Import creates Person + Moment for each selected
  6. Handles contacts without birthdays gracefully
- **passes:** false

---

### Phase 6: Polish & Accessibility

#### F6.1 - Animations & Haptics
- **Category:** Polish
- **Description:** Implement motion design per DESIGN_SYSTEM.md
- **Verification Steps:**
  1. Transitions use 180-320ms duration with iOS standard easing
  2. Sheets use spring animation
  3. Confetti appears on: moment completed, shared, big anniversary
  4. Glow pulse on events within 7 days
  5. Haptics: light (toggles), medium (save), success (scheduled)
  6. Reduce Motion setting disables shimmer/confetti
- **passes:** false

#### F6.2 - Accessibility
- **Category:** Accessibility
- **Description:** Support Dynamic Type, VoiceOver, and Reduce Motion
- **Verification Steps:**
  1. All text scales with Dynamic Type
  2. Tap targets are ≥ 44pt
  3. Color is never the sole indicator (icons + labels accompany colors)
  4. VoiceOver reads all interactive elements correctly
  5. Reduce Motion disables animations while keeping fades
- **passes:** false

#### F6.3 - Offline Support
- **Category:** Reliability
- **Description:** Core functionality works without network
- **Verification Steps:**
  1. Garden browsing works offline
  2. Adding/editing moments works offline
  3. Viewing attached media works offline
  4. Changes sync when network available (if sync enabled)
- **passes:** false

---

## Progress Log

_Record completed work here. Each entry should note the date, what was done, and any relevant details for future sessions._

```
[YYYY-MM-DD] - Description of work completed
- Files created/modified: list files
- Tests added: list test files/methods
- Notes: any context for future sessions
```

### Entries

_(No entries yet - project initialization phase)_

---

## Implementation Notes

### Architecture Decisions

- **UI Framework:** SwiftUI (iOS 17+)
- **Data Persistence:** SwiftData
- **Architecture Pattern:** MVVM with Coordinator for navigation
- **Dependency Injection:** Environment-based for SwiftUI

### File Structure (Target)

```
Three65/
├── Three65App.swift
├── Models/
│   ├── Person.swift
│   ├── Moment.swift
│   ├── Category.swift
│   ├── Media.swift
│   ├── CollageProject.swift
│   └── ReminderSetting.swift
├── Views/
│   ├── Garden/
│   │   ├── GardenView.swift
│   │   ├── DotGridView.swift
│   │   ├── HeatmapGridView.swift
│   │   └── DayDetailSheet.swift
│   ├── Moments/
│   │   ├── AddMomentFlow.swift
│   │   └── MomentCard.swift
│   ├── People/
│   │   ├── PersonCard.swift
│   │   └── PersonDetailView.swift
│   ├── CelebrationPack/
│   │   ├── CollageEditorView.swift
│   │   ├── TemplatePickerView.swift
│   │   └── CaptionSuggestionsView.swift
│   ├── Library/
│   │   └── CreativeLibraryView.swift
│   ├── Settings/
│   │   ├── ProfileView.swift
│   │   ├── ThemePickerView.swift
│   │   └── NotificationSettingsView.swift
│   ├── Onboarding/
│   │   └── OnboardingFlow.swift
│   └── Components/
│       ├── GlassCard.swift
│       ├── GlassSheet.swift
│       ├── PrimaryButton.swift
│       └── CategoryChip.swift
├── ViewModels/
│   ├── GardenViewModel.swift
│   ├── MomentViewModel.swift
│   ├── CelebrationPackViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── DataService.swift
│   ├── NotificationService.swift
│   ├── MediaService.swift
│   ├── ContactsImportService.swift
│   └── AnalyticsService.swift
├── Utilities/
│   ├── Theme.swift
│   ├── DesignTokens.swift
│   └── Extensions/
└── Resources/
    ├── Assets.xcassets
    └── CaptionTemplates.json
```

### Critical Constraints

1. **Do not remove or edit verification steps** - they serve as acceptance criteria
2. **Garden must render at 60fps** - use lazy loading and efficient diffing
3. **Notifications must handle DST/timezone** - store events in local time
4. **Photos remain on-device by default** - respect privacy
5. **Maintain AA contrast on liquid glass surfaces** - accessibility requirement
6. **Metal shader background on all screens** - theme-driven with subtle animation; reduce for Reduce Motion

---

## Session Handoff Checklist

When ending a session, update this file:

1. [ ] Add entry to Activity Log with work completed (ACTIVITY.md)
2. [ ] Update `passes` boolean for any completed features
3. [ ] Commit changes with descriptive message
4. [ ] Note any blockers or decisions needed for next session
