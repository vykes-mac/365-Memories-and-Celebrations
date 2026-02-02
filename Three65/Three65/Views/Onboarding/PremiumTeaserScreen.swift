//
//  PremiumTeaserScreen.swift
//  Three65
//
//  Created on 02/02/2026.
//

import SwiftUI

/// Soft paywall screen showing premium features
/// Plants seed for future conversion without blocking onboarding
struct PremiumTeaserScreen: View {
    let onStartTrial: () -> Void
    let onMaybeLater: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showContent = false
    @State private var showPremium = false

    private let freeFeatures = [
        "Unlimited moments & people",
        "Garden view & reminders",
        "2 collage templates"
    ]

    private let premiumFeatures = [
        PremiumFeature(icon: "square.grid.3x3.fill", text: "All 8 premium templates"),
        PremiumFeature(icon: "video.fill", text: "Video memory highlights"),
        PremiumFeature(icon: "text.bubble.fill", text: "AI-powered caption suggestions"),
        PremiumFeature(icon: "photo.stack.fill", text: "Unlimited Creative Library"),
        PremiumFeature(icon: "icloud.fill", text: "Cloud backup & sync")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 40)

                // Header
                VStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.current.colors.accentPrimary)

                    Text("You're all set with\n365 Free!")
                        .font(Typography.Display.large)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Theme.current.colors.textPrimary)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: Duration.slow),
                    value: showContent
                )
                .padding(.horizontal, Spacing.screenHorizontal)

                Spacer()
                    .frame(height: 24)

                // Free tier features
                GlassCard(cornerRadius: Radius.l, padding: Spacing.m) {
                    VStack(alignment: .leading, spacing: Spacing.s) {
                        Text("Free includes:")
                            .font(Typography.button)
                            .foregroundStyle(Theme.current.colors.textSecondary)

                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            ForEach(freeFeatures, id: \.self) { feature in
                                HStack(spacing: Spacing.s) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(Theme.current.colors.accentPrimary)

                                    Text(feature)
                                        .font(Typography.body)
                                        .foregroundStyle(Theme.current.colors.textPrimary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: Duration.slow).delay(0.1),
                    value: showContent
                )

                Spacer()
                    .frame(height: 16)

                // Divider
                HStack {
                    Rectangle()
                        .fill(Theme.current.colors.divider)
                        .frame(height: 1)
                    Text("or")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textTertiary)
                        .padding(.horizontal, Spacing.s)
                    Rectangle()
                        .fill(Theme.current.colors.divider)
                        .frame(height: 1)
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .opacity(showPremium ? 1 : 0)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: Duration.slow),
                    value: showPremium
                )

                Spacer()
                    .frame(height: 16)

                // Premium tier
                VStack(spacing: Spacing.m) {
                    // Premium header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: Spacing.xs) {
                                Text("365")
                                    .font(Typography.Title.large)
                                    .foregroundStyle(Theme.current.colors.textPrimary)
                                Text("Plus")
                                    .font(Typography.Title.large)
                                    .foregroundStyle(Theme.current.colors.accentPrimary)
                            }
                            Text("Unlock the full experience")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                        Spacer()
                        // Price badge
                        VStack(spacing: 0) {
                            Text("$2.99")
                                .font(Typography.Title.medium)
                                .foregroundStyle(Theme.current.colors.textPrimary)
                            Text("/month")
                                .font(Typography.micro)
                                .foregroundStyle(Theme.current.colors.textTertiary)
                        }
                    }

                    // Premium features grid
                    VStack(spacing: Spacing.xs) {
                        ForEach(premiumFeatures) { feature in
                            HStack(spacing: Spacing.s) {
                                Image(systemName: feature.icon)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Theme.current.colors.accentSecondary)
                                    .frame(width: 20)

                                Text(feature.text)
                                    .font(Typography.body)
                                    .foregroundStyle(Theme.current.colors.textPrimary)

                                Spacer()
                            }
                        }
                    }

                    // Trial CTA
                    Button(action: {
                        Haptics.medium()
                        AnalyticsService.shared.track("premium_trial_started")
                        onStartTrial()
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                            Text("Start 7-day free trial")
                                .font(Typography.button)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.m)
                        .background(
                            LinearGradient(
                                colors: [Theme.current.colors.accentPrimary, Theme.current.colors.accentSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Radius.m))
                    }
                }
                .padding(Spacing.m)
                .background(
                    RoundedRectangle(cornerRadius: Radius.l)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.l)
                                .fill(Theme.current.colors.accentPrimary.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.l)
                                .stroke(Theme.current.colors.accentPrimary.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, Spacing.screenHorizontal)
                .opacity(showPremium ? 1 : 0)
                .offset(y: showPremium ? 0 : 30)
                .animation(
                    reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8),
                    value: showPremium
                )

                Spacer()
                    .frame(height: 16)

                // Maybe later
                Button(action: {
                    AnalyticsService.shared.track("premium_skipped")
                    onMaybeLater()
                }) {
                    Text("Maybe later")
                        .font(Typography.button)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                        .padding(.vertical, Spacing.s)
                }
                .opacity(showPremium ? 1 : 0)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: Duration.slow).delay(0.3),
                    value: showPremium
                )

                Spacer()
                    .frame(height: Spacing.xl)
            }
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { showContent = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showPremium = true }
        }
    }
}

// MARK: - Supporting Types

private struct PremiumFeature: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        PremiumTeaserScreen(
            onStartTrial: {},
            onMaybeLater: {}
        )
    }
}
