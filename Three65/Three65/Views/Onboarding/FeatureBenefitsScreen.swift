//
//  FeatureBenefitsScreen.swift
//  Three65
//
//  Created on 02/02/2026.
//

import SwiftUI

/// Feature benefits breakdown screen
/// Articulates clear value proposition before permission asks
struct FeatureBenefitsScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showHeader = false
    @State private var cardAppearIndex = 0

    private let features = [
        Feature(
            icon: "leaf.fill",
            iconColor: ThemeColors.categoryJustBecause,
            title: "365 Garden",
            description: "See your whole year at a glance. Never be caught off guard."
        ),
        Feature(
            icon: "bell.fill",
            iconColor: ThemeColors.categoryAnniversary,
            title: "Gentle Reminders",
            description: "7 days ahead, so you have time to plan something meaningful."
        ),
        Feature(
            icon: "sparkles",
            iconColor: ThemeColors.categoryBirthday,
            title: "Celebration Packs",
            description: "Create shareable collages with perfect captions in seconds."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Header
            Text("Everything you need\nto celebrate well")
                .font(Typography.Display.large)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.current.colors.textPrimary)
                .opacity(showHeader ? 1 : 0)
                .offset(y: showHeader ? 0 : 20)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: Duration.slow),
                    value: showHeader
                )
                .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 40)

            // Feature cards
            VStack(spacing: Spacing.m) {
                ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                    FeatureCard(feature: feature)
                        .opacity(cardAppearIndex > index ? 1 : 0)
                        .offset(y: cardAppearIndex > index ? 0 : 30)
                        .scaleEffect(cardAppearIndex > index ? 1 : 0.95)
                        .animation(
                            reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.15),
                            value: cardAppearIndex
                        )
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { showHeader = true }
        }

        for i in 0...features.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.2) {
                withAnimation {
                    cardAppearIndex = i + 1
                }
            }
        }
    }
}

// MARK: - Supporting Types

private struct Feature: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
}

private struct FeatureCard: View {
    let feature: Feature

    @State private var isHovered = false

    var body: some View {
        GlassCard(cornerRadius: Radius.l, padding: Spacing.m) {
            HStack(alignment: .top, spacing: Spacing.m) {
                // Icon container
                ZStack {
                    Circle()
                        .fill(feature.iconColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: feature.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(feature.iconColor)
                }

                // Text content
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(feature.title)
                        .font(Typography.Title.medium)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    Text(feature.description)
                        .font(Typography.body)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        FeatureBenefitsScreen()
    }
}
