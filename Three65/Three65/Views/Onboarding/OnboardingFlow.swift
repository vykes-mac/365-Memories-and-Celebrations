//
//  OnboardingFlow.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import AVKit

struct OnboardingFlow: View {
    let onComplete: () -> Void

    @State private var step: Step = .painPoint
    @State private var didTrackStart = false
    @State private var showingAddMoment = false
    @State private var showingContactsImport = false
    @State private var showingCalendarImport = false
    @State private var prefillName: String = ""
    @State private var prefillRelationship: String = ""
    @State private var selectedIdentities: Set<String> = []
    @State private var importedUpcomingDates: [UpcomingDate] = []
    @State private var hasImportedContacts = false
    @State private var firstMomentPersonName: String = "Mom"
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.softBlush.rawValue

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if step.isFullScreen {
                fullScreenStep
            } else {
                VStack(spacing: Spacing.l) {
                    // Progress indicator
                    progressIndicator

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
        }
        .sheet(isPresented: $showingAddMoment) {
            AddMomentFlow(initialDate: Date(), initialName: prefillName, initialRelationship: prefillRelationship)
        }
        .sheet(isPresented: $showingContactsImport) {
            ContactsImportView(onImportComplete: handleContactsImport)
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

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        let totalSteps = visibleSteps.count
        let currentIndex = getCurrentStepIndex()

        return HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? Theme.current.colors.accentPrimary : Theme.current.colors.textTertiary.opacity(0.3))
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: 200)
    }

    private var visibleSteps: [Step] {
        Step.allCases.filter { !$0.isConditional || (hasImportedContacts && $0 == .personalizedFOMO) }
    }

    private func getCurrentStepIndex() -> Int {
        visibleSteps.firstIndex(of: step) ?? 0
    }

    // MARK: - Full Screen Steps

    @ViewBuilder
    private var fullScreenStep: some View {
        switch step {
        case .painPoint:
            VStack {
                PainPointScreen()
                Spacer()
                fullScreenContinueButton
            }
        case .welcome:
            welcomeStep
        case .valuePreview:
            VStack {
                ValuePreviewScreen()
                Spacer()
                fullScreenContinueButton
            }
        case .socialProof:
            VStack {
                SocialProofScreen()
                Spacer()
                fullScreenContinueButton
            }
        case .quickWin:
            VStack {
                QuickWinScreen(personName: firstMomentPersonName)
                Spacer()
                fullScreenContinueButton
            }
        case .premium:
            PremiumTeaserScreen(
                onStartTrial: {
                    AnalyticsService.shared.track("premium_trial_started")
                    onComplete()
                },
                onMaybeLater: {
                    onComplete()
                }
            )
        default:
            EmptyView()
        }
    }

    private var fullScreenContinueButton: some View {
        Button(action: nextStep) {
            HStack(spacing: Spacing.xs) {
                Text("Continue")
                    .font(Typography.button)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: Radius.xl)
                    .fill(Theme.current.colors.accentPrimary)
            )
        }
        .padding(.horizontal, Spacing.xxl)
        .padding(.bottom, Spacing.xl)
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
        case .painPoint, .welcome, .valuePreview, .socialProof, .quickWin, .premium:
            EmptyView() // Handled by fullScreenStep
        case .imports:
            importStep
        case .personalizedFOMO:
            PersonalizedFOMOScreen(upcomingDates: importedUpcomingDates.isEmpty ? PersonalizedFOMOScreen.sampleDates : importedUpcomingDates)
        case .theme:
            themeStep
        case .identity:
            IdentityCommitmentScreen(selectedIdentities: $selectedIdentities)
        case .moments:
            momentStep
        case .features:
            FeatureBenefitsScreen()
        case .notifications:
            notificationsStep
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Hero title
            Text("A year of the people\nyou love.")
                .font(Typography.Display.large)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.current.colors.textPrimary)
                .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 40)

            // Hero video with heart badge
            ZStack(alignment: .bottomTrailing) {
                HeroVideoView()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 340)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.xl))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.l)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Theme.current.colors.bgGradientA,
                                        Theme.current.colors.bgGradientB
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 20
                            )
                            .blur(radius: 10)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Radius.l))

                // Heart badge
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.l)
                        .fill(.thinMaterial)
                        .frame(width: 72, height: 72)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.l)
                                .fill(.white.opacity(0.3))
                        )

                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 0.8))
                }
                .rotationEffect(.degrees(-8))
                .offset(x: -8, y: 20)
            }
            .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()

            // Start button
            Button(action: nextStep) {
                HStack(spacing: Spacing.xs) {
                    Text("Start my 365")
                        .font(Typography.button)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.m)
                .background(
                    RoundedRectangle(cornerRadius: Radius.xl)
                        .fill(Color(red: 0.2, green: 0.15, blue: 0.25))
                )
            }
            .padding(.horizontal, Spacing.xxl)

            Spacer()
                .frame(height: Spacing.xl)
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

            Text("We'll send gentle reminders so you can plan something thoughtful.")
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
            .disabled(!step.canGoBack)
            .opacity(step.canGoBack ? 1 : 0.5)

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

    // MARK: - Actions

    private func nextStep() {
        // Handle step completion
        if step == .notifications {
            // Go to premium teaser instead of completing
            withAnimation(.easeInOut(duration: Duration.base)) {
                step = .premium
            }
            return
        }

        if step == .premium {
            onComplete()
            return
        }

        // Find next step, skipping conditional steps if needed
        var nextStepCandidate = step.next
        while let candidate = nextStepCandidate {
            if candidate.isConditional {
                if candidate == .personalizedFOMO && hasImportedContacts {
                    break // Show FOMO screen if contacts were imported
                }
                // Skip conditional step
                nextStepCandidate = candidate.next
            } else {
                break
            }
        }

        if let next = nextStepCandidate {
            withAnimation(.easeInOut(duration: Duration.base)) {
                step = next
            }
        }
    }

    private func previousStep() {
        var prevStepCandidate = step.previous
        while let candidate = prevStepCandidate {
            if candidate.isConditional && !(candidate == .personalizedFOMO && hasImportedContacts) {
                prevStepCandidate = candidate.previous
            } else {
                break
            }
        }

        if let previous = prevStepCandidate {
            withAnimation(.easeInOut(duration: Duration.base)) {
                step = previous
            }
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
        firstMomentPersonName = name
        showingAddMoment = true
    }

    private func requestNotifications() {
        Task {
            _ = await NotificationService.shared.requestAuthorization()
        }
    }

    private func handleContactsImport(dates: [UpcomingDate]) {
        hasImportedContacts = true
        importedUpcomingDates = dates
        AnalyticsService.shared.track("contacts_imported", properties: ["count": dates.count])
    }
}

// MARK: - Supporting Views

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

private struct HeroVideoView: View {
    @State private var player = AVPlayer()
    @State private var isConfigured = false

    var body: some View {
        PlayerLayerView(player: player)
            .onAppear {
                configureIfNeeded()
                player.play()
            }
            .onDisappear {
                player.pause()
            }
            .onReceive(NotificationCenter.default.publisher(
                for: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )) { _ in
                player.seek(to: .zero)
                player.play()
            }
            .allowsHitTesting(false)
    }

    private func configureIfNeeded() {
        guard !isConfigured else { return }
        isConfigured = true

        guard let item = makePlayerItem() else { return }
        player.replaceCurrentItem(with: item)
        player.isMuted = true
        player.actionAtItemEnd = .none
    }

    private func makePlayerItem() -> AVPlayerItem? {
        guard let url = Bundle.main.url(forResource: "together", withExtension: "mp4") else {
            return nil
        }
        return AVPlayerItem(url: url)
    }
}

private struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerContainerView {
        let view = PlayerContainerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: PlayerContainerView, context: Context) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = .resizeAspectFill
    }
}

private final class PlayerContainerView: UIView {
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    var playerLayer: AVPlayerLayer {
        layer as? AVPlayerLayer ?? AVPlayerLayer()
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

// MARK: - Step Enum

private enum Step: Int, CaseIterable {
    case painPoint
    case welcome
    case valuePreview
    case socialProof
    case imports
    case personalizedFOMO
    case theme
    case identity
    case moments
    case quickWin
    case features
    case notifications
    case premium

    var title: String {
        switch self {
        case .painPoint: return ""
        case .welcome: return "Welcome"
        case .valuePreview: return ""
        case .socialProof: return ""
        case .imports: return "Import"
        case .personalizedFOMO: return "Coming Up"
        case .theme: return "Theme"
        case .identity: return "Your Goals"
        case .moments: return "First moments"
        case .quickWin: return ""
        case .features: return "Features"
        case .notifications: return "Notifications"
        case .premium: return ""
        }
    }

    var subtitle: String {
        switch self {
        case .painPoint: return ""
        case .welcome: return "A gentle start"
        case .valuePreview: return ""
        case .socialProof: return ""
        case .imports: return "Optional quick setup"
        case .personalizedFOMO: return "Don't miss these dates"
        case .theme: return "Make it yours"
        case .identity: return "What matters to you"
        case .moments: return "Add three meaningful people"
        case .quickWin: return ""
        case .features: return "What you get"
        case .notifications: return "Stay on track"
        case .premium: return ""
        }
    }

    var isFullScreen: Bool {
        switch self {
        case .painPoint, .welcome, .valuePreview, .socialProof, .quickWin, .premium:
            return true
        default:
            return false
        }
    }

    var isConditional: Bool {
        self == .personalizedFOMO
    }

    var canGoBack: Bool {
        self != .painPoint
    }

    var next: Step? { Step(rawValue: rawValue + 1) }
    var previous: Step? { Step(rawValue: rawValue - 1) }
}

#Preview {
    OnboardingFlow(onComplete: {})
}
