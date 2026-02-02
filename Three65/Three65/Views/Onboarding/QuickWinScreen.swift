//
//  QuickWinScreen.swift
//  Three65
//
//  Created on 02/02/2026.
//

import SwiftUI

/// Quick win screen showing immediate reward after adding first moment
/// Creates positive reinforcement and previews the collage feature
struct QuickWinScreen: View {
    let personName: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showCelebration = false
    @State private var showGarden = false
    @State private var showCollagePreview = false
    @State private var showCTA = false
    @State private var dotScale: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            // Celebration header
            VStack(spacing: Spacing.s) {
                ZStack {
                    // Sparkle burst
                    ForEach(0..<8, id: \.self) { index in
                        Image(systemName: "sparkle")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.current.colors.accentSecondary)
                            .offset(
                                x: showCelebration ? cos(Double(index) * .pi / 4) * 40 : 0,
                                y: showCelebration ? sin(Double(index) * .pi / 4) * 40 : 0
                            )
                            .opacity(showCelebration ? 0.6 : 0)
                            .animation(
                                reduceMotion ? .none : .easeOut(duration: 0.6).delay(0.1),
                                value: showCelebration
                            )
                    }

                    // Seedling icon
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                        .scaleEffect(showCelebration ? 1 : 0.5)
                        .opacity(showCelebration ? 1 : 0)
                        .animation(
                            reduceMotion ? .none : .spring(response: 0.5, dampingFraction: 0.6),
                            value: showCelebration
                        )
                }
                .frame(height: 80)

                Text("Your first moment\nis planted!")
                    .font(Typography.Display.large)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.current.colors.textPrimary)
                    .opacity(showCelebration ? 1 : 0)
                    .offset(y: showCelebration ? 0 : 20)
                    .animation(
                        reduceMotion ? .none : .easeOut(duration: Duration.slow).delay(0.2),
                        value: showCelebration
                    )
            }

            Spacer()
                .frame(height: 32)

            // Mini garden preview with one glowing dot
            GlassCard(cornerRadius: Radius.l, padding: Spacing.m) {
                VStack(spacing: Spacing.s) {
                    HStack {
                        Text("Your Garden")
                            .font(Typography.Title.medium)
                            .foregroundStyle(Theme.current.colors.textPrimary)
                        Spacer()
                    }

                    // Simple mini grid with one highlighted dot
                    MiniGardenWithHighlight(dotScale: dotScale)
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .opacity(showGarden ? 1 : 0)
            .offset(y: showGarden ? 0 : 30)
            .animation(
                reduceMotion ? .none : .easeOut(duration: Duration.slow),
                value: showGarden
            )

            Spacer()
                .frame(height: 24)

            // Collage preview teaser
            VStack(spacing: Spacing.s) {
                Text("Here's a sneak peek of what you can create:")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)

                CollagePreviewTeaser(personName: personName)
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .opacity(showCollagePreview ? 1 : 0)
            .offset(y: showCollagePreview ? 0 : 20)
            .animation(
                reduceMotion ? .none : .easeOut(duration: Duration.slow),
                value: showCollagePreview
            )

            Spacer()
                .frame(height: 24)

            // CTA text
            Text("Beautiful celebration packs,\nready in seconds.")
                .font(Typography.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.current.colors.textSecondary)
                .opacity(showCTA ? 1 : 0)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: Duration.slow),
                    value: showCTA
                )

            Spacer()
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { showCelebration = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showGarden = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                dotScale = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showCollagePreview = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation { showCTA = true }
        }
    }
}

// MARK: - Mini Garden With Highlight

private struct MiniGardenWithHighlight: View {
    let dotScale: CGFloat

    private let rows = 5
    private let cols = 12
    private let highlightedIndex = 27 // Random position for the highlighted dot

    @State private var isGlowing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 3) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<cols, id: \.self) { col in
                        let index = row * cols + col
                        let isHighlighted = index == highlightedIndex

                        ZStack {
                            Circle()
                                .fill(isHighlighted ? Theme.current.colors.glassCardFill : Theme.current.colors.textTertiary.opacity(0.2))
                                .frame(width: 10, height: 10)

                            if isHighlighted {
                                // Glow effect
                                Circle()
                                    .fill(Theme.current.colors.accentPrimary.opacity(0.3))
                                    .frame(width: 18, height: 18)
                                    .blur(radius: 4)
                                    .opacity(isGlowing ? 0.8 : 0.4)

                                // Ring
                                Circle()
                                    .stroke(ThemeColors.categoryBirthday, lineWidth: 2)
                                    .frame(width: 10, height: 10)
                                    .scaleEffect(dotScale)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
        }
    }
}

// MARK: - Collage Preview Teaser

private struct CollagePreviewTeaser: View {
    let personName: String

    var body: some View {
        GlassCard(cornerRadius: Radius.m, padding: Spacing.s) {
            HStack(spacing: Spacing.m) {
                // Mini collage template preview
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.s)
                        .fill(Theme.current.colors.textTertiary.opacity(0.1))
                        .frame(width: 60, height: 60)

                    // Grid pattern
                    VStack(spacing: 2) {
                        HStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ThemeColors.categoryBirthday.opacity(0.5))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ThemeColors.categoryAnniversary.opacity(0.5))
                        }
                        HStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ThemeColors.categoryMilestone.opacity(0.5))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(ThemeColors.categoryJustBecause.opacity(0.5))
                        }
                    }
                    .padding(8)
                    .frame(width: 60, height: 60)
                }

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("For \(personName)'s Birthday")
                        .font(Typography.button)
                        .foregroundStyle(Theme.current.colors.textPrimary)
                        .lineLimit(1)

                    Text("Collage template ready to customize")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.current.colors.textTertiary)
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

        QuickWinScreen(personName: "Mom")
    }
}
