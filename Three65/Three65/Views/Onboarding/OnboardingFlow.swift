//
//  OnboardingFlow.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

struct OnboardingFlow: View {
    let onComplete: () -> Void

    @State private var step: Step = .welcome
    @State private var didTrackStart = false
    @State private var showingAddMoment = false
    @State private var showingContactsImport = false
    @State private var showingCalendarImport = false
    @State private var prefillName: String = ""
    @State private var prefillRelationship: String = ""
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.softBlush.rawValue

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: Spacing.l) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        stepContent
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                navigationControls
            }
            .padding(Spacing.screenHorizontal)
            .padding(.top, Spacing.l)
            .padding(.bottom, Spacing.xl)
        }
        .sheet(isPresented: $showingAddMoment) {
            AddMomentFlow(initialDate: Date(), initialName: prefillName, initialRelationship: prefillRelationship)
        }
        .sheet(isPresented: $showingContactsImport) {
            ContactsImportView()
        }
        .alert("Calendar import is coming soon.", isPresented: $showingCalendarImport) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            if !didTrackStart {
                didTrackStart = true
                AnalyticsService.shared.track("onboarding_started")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(step.title)
                .font(Typography.Title.large)
                .foregroundStyle(Theme.current.colors.textPrimary)

            Text(step.subtitle)
                .font(Typography.caption)
                .foregroundStyle(Theme.current.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .welcome:
            welcomeStep
        case .imports:
            importStep
        case .theme:
            themeStep
        case .moments:
            momentStep
        case .notifications:
            notificationsStep
        }
    }

    private var welcomeStep: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("A year of the people you love")
                    .font(Typography.Display.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Text("Capture birthdays, anniversaries, and quiet moments that matter.")
                    .font(Typography.body)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
            .padding(Spacing.m)
        }
    }

    private var importStep: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Import birthdays and milestones")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            Button(action: {
                AnalyticsService.shared.track("import_contacts_tapped")
                showingContactsImport = true
            }) {
                OnboardingActionCard(
                    title: "Import from Contacts",
                    subtitle: "Bring in birthdays automatically",
                    systemImage: "person.crop.circle.badge.plus"
                )
            }
            .buttonStyle(.plain)

            Button(action: { showingCalendarImport = true }) {
                OnboardingActionCard(
                    title: "Import from Calendar",
                    subtitle: "Add upcoming celebrations",
                    systemImage: "calendar.badge.plus"
                )
            }
            .buttonStyle(.plain)

            Text("You can skip this and add moments manually.")
                .font(Typography.caption)
                .foregroundStyle(Theme.current.colors.textSecondary)
        }
    }

    private var themeStep: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Pick a theme")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.m) {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Button(action: { selectTheme(theme) }) {
                        ThemeSelectionCard(theme: theme, isSelected: selectedTheme == theme.rawValue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var momentStep: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Start with someone special")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            VStack(spacing: Spacing.s) {
                Button(action: { openAddMoment(name: "Mom", relationship: "Mother") }) {
                    OnboardingActionCard(
                        title: "Add Mom",
                        subtitle: "Quickly capture a birthday",
                        systemImage: "heart.fill"
                    )
                }
                .buttonStyle(.plain)

                Button(action: { openAddMoment(name: "Best Friend", relationship: "Friend") }) {
                    OnboardingActionCard(
                        title: "Add Best Friend",
                        subtitle: "Never miss their day",
                        systemImage: "sparkles"
                    )
                }
                .buttonStyle(.plain)

                Button(action: { openAddMoment(name: "Someone Special", relationship: "Partner") }) {
                    OnboardingActionCard(
                        title: "Add Someone Special",
                        subtitle: "Plan meaningful moments",
                        systemImage: "star.fill"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var notificationsStep: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Stay ahead with reminders")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            Text("We’ll send gentle reminders so you can plan something thoughtful.")
                .font(Typography.body)
                .foregroundStyle(Theme.current.colors.textSecondary)

            Button(action: requestNotifications) {
                Text("Enable notifications")
                    .font(Typography.button)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .fill(Theme.current.colors.accentPrimary)
                    )
            }
        }
    }

    private var navigationControls: some View {
        HStack(spacing: Spacing.s) {
            Button(action: previousStep) {
                Text("Back")
                    .font(Typography.button)
                    .foregroundStyle(Theme.current.colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.s)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .fill(Theme.current.colors.glassCardFill)
                    )
            }
            .disabled(step == .welcome)
            .opacity(step == .welcome ? 0.5 : 1)

            Button(action: nextStep) {
                Text(step == .notifications ? "Finish" : "Next")
                    .font(Typography.button)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.s)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .fill(Theme.current.colors.accentPrimary)
                    )
            }
        }
    }

    private func nextStep() {
        if step == .notifications {
            onComplete()
            return
        }
        if let next = step.next {
            step = next
        }
    }

    private func previousStep() {
        if let previous = step.previous {
            step = previous
        }
    }

    private func selectTheme(_ theme: Theme) {
        selectedTheme = theme.rawValue
        Theme.current = theme
        AnalyticsService.shared.track("theme_selected", properties: ["theme": theme.rawValue])
    }

    private func openAddMoment(name: String, relationship: String) {
        prefillName = name
        prefillRelationship = relationship
        showingAddMoment = true
    }

    private func requestNotifications() {
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
    }
}

private struct OnboardingActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        GlassCard {
            HStack(spacing: Spacing.m) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.current.colors.accentPrimary)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(Typography.body)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    Text(subtitle)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }

                Spacer()
            }
            .padding(Spacing.s)
        }
    }
}

private struct ThemeSelectionCard: View {
    let theme: Theme
    let isSelected: Bool

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                RoundedRectangle(cornerRadius: Radius.s)
                    .fill(
                        LinearGradient(
                            colors: [theme.colors.bgGradientA, theme.colors.bgGradientB],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 80)
                    .overlay(
                        HStack {
                            Circle()
                                .fill(theme.colors.accentPrimary)
                                .frame(width: 14, height: 14)

                            Circle()
                                .fill(theme.colors.accentSecondary)
                                .frame(width: 8, height: 8)

                            Spacer()
                        }
                        .padding(Spacing.s)
                    )

                Text(theme.displayName)
                    .font(Typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .padding(Spacing.s)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.m)
                    .stroke(isSelected ? theme.colors.accentPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}

private enum Step: Int, CaseIterable {
    case welcome
    case imports
    case theme
    case moments
    case notifications

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .imports: return "Import"
        case .theme: return "Theme"
        case .moments: return "First moments"
        case .notifications: return "Notifications"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome: return "A gentle start"
        case .imports: return "Optional quick setup"
        case .theme: return "Make it yours"
        case .moments: return "Add three meaningful people"
        case .notifications: return "Stay on track"
        }
    }

    var next: Step? { Step(rawValue: rawValue + 1) }
    var previous: Step? { Step(rawValue: rawValue - 1) }
}

#Preview {
    OnboardingFlow(onComplete: {})
}
