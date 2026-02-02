//
//  PainPointScreen.swift
//  Three65
//
//  Created on 02/02/2026.
//

import SwiftUI

/// Emotional resonance screen that acknowledges common pain points
/// Helps users recognize their need for the app
struct PainPointScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appearIndex = 0
    @State private var showSolution = false

    private let painPoints = [
        PainPoint(
            icon: "calendar.badge.exclamationmark",
            text: "Remembered a birthday... a day late"
        ),
        PainPoint(
            icon: "gift",
            text: "Scrambled for last-minute gift ideas"
        ),
        PainPoint(
            icon: "heart.slash",
            text: "Wished you'd planned something more thoughtful"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Header
            Text("We've all been there...")
                .font(Typography.Display.large)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.current.colors.textPrimary)
                .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 48)

            // Pain points with staggered animation
            VStack(spacing: Spacing.m) {
                ForEach(Array(painPoints.enumerated()), id: \.offset) { index, painPoint in
                    PainPointCard(painPoint: painPoint)
                        .opacity(appearIndex > index ? 1 : 0)
                        .offset(y: appearIndex > index ? 0 : 20)
                        .animation(
                            reduceMotion ? .none : .easeOut(duration: Duration.slow).delay(Double(index) * 0.2),
                            value: appearIndex
                        )
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 48)

            // Solution statement
            VStack(spacing: Spacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.current.colors.accentPrimary)

                Text("365 helps you stay ahead\nof the moments that matter.")
                    .font(Typography.Title.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.current.colors.textPrimary)
            }
            .opacity(showSolution ? 1 : 0)
            .offset(y: showSolution ? 0 : 15)
            .animation(
                reduceMotion ? .none : .easeOut(duration: Duration.slow),
                value: showSolution
            )
            .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
        }
        .onAppear {
            startAnimations()
        }
    }

    private func startAnimations() {
        // Stagger the pain points appearance
        for i in 0...painPoints.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                withAnimation {
                    appearIndex = i + 1
                }
            }
        }

        // Show solution after pain points
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(painPoints.count) * 0.3 + 0.4) {
            withAnimation {
                showSolution = true
            }
        }
    }
}

// MARK: - Supporting Types

private struct PainPoint: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

private struct PainPointCard: View {
    let painPoint: PainPoint

    var body: some View {
        GlassCard {
            HStack(spacing: Spacing.m) {
                Image(systemName: painPoint.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.current.colors.accentSecondary)
                    .frame(width: 32)

                Text(painPoint.text)
                    .font(Typography.body)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Spacer()
            }
            .padding(.vertical, Spacing.xs)
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

        PainPointScreen()
    }
}
