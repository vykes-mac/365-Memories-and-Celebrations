//
//  ValuePreviewScreen.swift
//  Three65
//
//  Created on 02/02/2026.
//

import SwiftUI

/// Shows a preview of what the user's year could look like
/// Creates desire by showing the end state (filled garden)
struct ValuePreviewScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animatedDotCount = 0
    @State private var showTagline = false
    @State private var showCollagePreview = false

    private let totalDots = 365
    private let dotsPerRow = 19
    private let highlightedDots: Set<Int> = {
        // Simulate scattered events throughout the year
        var dots = Set<Int>()
        let eventIndices = [
            14, 28, 45, 67, 89, 102, 134, 156, 178, 192,
            210, 234, 256, 278, 295, 312, 334, 350, 363,
            7, 52, 98, 143, 188, 233, 278, 323
        ]
        eventIndices.forEach { dots.insert($0) }
        return dots
    }()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            // Header
            Text("Imagine your year,\nbeautifully organized")
                .font(Typography.Display.large)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.current.colors.textPrimary)
                .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 32)

            // Animated garden preview
            ZStack {
                GlassCard(cornerRadius: Radius.l, padding: Spacing.m) {
                    VStack(spacing: Spacing.s) {
                        // Year label
                        HStack {
                            Text("2026")
                                .font(Typography.Title.medium)
                                .foregroundStyle(Theme.current.colors.textPrimary)
                            Spacer()
                            Image(systemName: "sparkle")
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.current.colors.accentPrimary)
                        }

                        // Mini dot grid
                        MiniGardenGrid(
                            totalDots: totalDots,
                            dotsPerRow: dotsPerRow,
                            animatedCount: animatedDotCount,
                            highlightedDots: highlightedDots
                        )
                    }
                }
                .padding(.horizontal, Spacing.screenHorizontal)

                // Floating collage preview badge
                if showCollagePreview {
                    FloatingCollageBadge()
                        .offset(x: 80, y: 100)
                        .transition(.scale.combined(with: .opacity))
                }
            }

            Spacer()
                .frame(height: 32)

            // Tagline
            VStack(spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                    Text("Every birthday remembered")
                        .font(Typography.body)
                        .foregroundStyle(Theme.current.colors.textPrimary)
                }

                HStack(spacing: Spacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                    Text("Every milestone celebrated")
                        .font(Typography.body)
                        .foregroundStyle(Theme.current.colors.textPrimary)
                }
            }
            .opacity(showTagline ? 1 : 0)
            .offset(y: showTagline ? 0 : 15)
            .animation(
                reduceMotion ? .none : .easeOut(duration: Duration.slow),
                value: showTagline
            )

            Spacer()
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Animate dots filling in
        let animationDuration = reduceMotion ? 0.0 : 1.5
        let dotInterval = animationDuration / Double(totalDots)

        for i in 0...totalDots {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * dotInterval) {
                animatedDotCount = i
            }
        }

        // Show collage preview after dots animate
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showCollagePreview = true
            }
        }

        // Show tagline after collage
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + 0.6) {
            withAnimation {
                showTagline = true
            }
        }
    }
}

// MARK: - Mini Garden Grid

private struct MiniGardenGrid: View {
    let totalDots: Int
    let dotsPerRow: Int
    let animatedCount: Int
    let highlightedDots: Set<Int>

    private let dotSize: CGFloat = 8
    private let spacing: CGFloat = 3

    var body: some View {
        let rows = (totalDots + dotsPerRow - 1) / dotsPerRow

        VStack(spacing: spacing) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<dotsPerRow, id: \.self) { col in
                        let index = row * dotsPerRow + col
                        if index < totalDots {
                            MiniDot(
                                index: index,
                                isAnimated: index < animatedCount,
                                isHighlighted: highlightedDots.contains(index)
                            )
                        }
                    }
                }
            }
        }
    }
}

private struct MiniDot: View {
    let index: Int
    let isAnimated: Bool
    let isHighlighted: Bool

    @State private var isGlowing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let categoryColors: [Color] = [
        ThemeColors.categoryBirthday,
        ThemeColors.categoryAnniversary,
        ThemeColors.categoryMilestone,
        ThemeColors.categoryJustBecause
    ]

    var body: some View {
        Circle()
            .fill(dotColor)
            .frame(width: 8, height: 8)
            .overlay {
                if isHighlighted && isAnimated {
                    Circle()
                        .stroke(highlightColor, lineWidth: 1.5)
                        .frame(width: 8, height: 8)
                }
            }
            .scaleEffect(isAnimated ? 1 : 0.3)
            .opacity(isAnimated ? 1 : 0.3)
            .animation(.easeOut(duration: 0.1), value: isAnimated)
            .onChange(of: isAnimated) { _, animated in
                if animated && isHighlighted && !reduceMotion {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        isGlowing = true
                    }
                }
            }
    }

    private var dotColor: Color {
        if isHighlighted && isAnimated {
            return Theme.current.colors.glassCardFill
        }
        return Theme.current.colors.textTertiary.opacity(0.3)
    }

    private var highlightColor: Color {
        // Use deterministic color based on index
        return categoryColors[index % categoryColors.count]
    }
}

// MARK: - Floating Collage Badge

private struct FloatingCollageBadge: View {
    @State private var isFloating = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: Spacing.xxs) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.s)
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.s)
                            .fill(Color.white.opacity(0.5))
                    )

                VStack(spacing: 4) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Theme.current.colors.accentPrimary)

                    Text("Collage")
                        .font(Typography.micro)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
        }
        .rotationEffect(.degrees(-8))
        .offset(y: isFloating ? -4 : 4)
        .animation(
            reduceMotion ? .none : .easeInOut(duration: 2).repeatForever(autoreverses: true),
            value: isFloating
        )
        .onAppear {
            if !reduceMotion {
                isFloating = true
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

        ValuePreviewScreen()
    }
}
