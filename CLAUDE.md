# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

365: Memories & Celebrations is an iOS app built with SwiftUI. It's a "memory garden" that helps users track important dates (birthdays, anniversaries, milestones) and generate shareable celebration content (collages, videos).

## Build Commands

```bash
# Build the project
xcodebuild -project Three65/Three65.xcodeproj -scheme Three65 -configuration Debug build

# Run tests
xcodebuild -project Three65/Three65.xcodeproj -scheme Three65 test -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test
xcodebuild -project Three65/Three65.xcodeproj -scheme Three65 test -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:Three65Tests/TestClassName/testMethodName
```

## Architecture

The project follows standard SwiftUI app structure:
- `Three65/Three65/` - Main app source code
- `Three65/Three65Tests/` - Unit tests
- `Three65/Three65UITests/` - UI tests

## Design System

The app uses a **glassmorphism aesthetic** with user-selectable themes. Key design tokens are documented in `DESIGN_SYSTEM.md`:

**Themes:** Soft Blush (default), Moonlight, Warm Linen, Garden

**Glass Surfaces:**
- `Glass.Card`: blur 18-28, fill `rgba(255,255,255,0.55)`
- `Glass.Sheet`: blur 28-40, fill `rgba(255,255,255,0.72)`

**Typography:** Serif for display headings + sans-serif for body (suggested: New York + SF Pro)

**Spacing:** 8pt baseline grid, corner radii: 12/16/24/32

**Category Colors:** birthday, anniversary, milestone, memorial, justBecause (used as ring/dot highlights, not full-screen)

## Core Data Model

- **Person**: id, name, relationship, avatarRef, notes
- **Moment**: id, personId, date, recurring, categoryId, title, notes
- **Category**: id, name, colorToken, icon
- **Media**: id, personId?, momentId?, localIdentifier, type, createdAt
- **CollageProject**: id, templateId, momentId?, assets[], captionDrafts[], createdAt

## Key Features to Implement

1. **365 Garden View**: Year-at-a-glance dot/heatmap grid showing events
2. **Day Details Sheet**: Bottom sheet showing moments for a tapped day
3. **Add Moment Flow**: Person + date + category + recurring option
4. **Celebration Pack**: Collage generator with templates (Polaroid, grid, film strip, then&now)
5. **Reminders**: 7 days before, 1 day before, day-of notifications with quiet hours

## Motion & Interaction

- Duration: 180-320ms with iOS standard easing
- Haptics: light (toggles), medium (save), success (scheduled)
- Delight: confetti on completion, glow pulse for upcoming 7 days
- Support Reduce Motion accessibility setting

## Development Philosophy

- **Modularity**: Separate concerns into distinct modules for maintainability and testability
- **Unit Testing**: Write unit tests to validate core functionality and edge cases
- **Integration Testing**: Write UI tests when a feature is complete to validate functionality and edge cases
- **Performance**: Optimize for smooth performance on various devices and network conditions
