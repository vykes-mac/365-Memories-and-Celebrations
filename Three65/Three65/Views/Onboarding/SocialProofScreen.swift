//
//  SocialProofScreen.swift
//  Three65
//
//  Created on 02/02/2026.
//

import SwiftUI

/// Social proof screen with testimonial carousel
/// Builds trust and creates aspiration through real user stories
struct SocialProofScreen: View {
    @State private var currentIndex = 0
    @State private var showHeader = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let testimonials = [
        Testimonial(
            quote: "My husband was shocked I remembered our dating anniversary. This app is a game-changer!",
            name: "Sarah",
            role: "Partner",
            avatarColor: ThemeColors.categoryBirthday
        ),
        Testimonial(
            quote: "I finally feel like the organized friend I always wanted to be. No more last-minute scrambles.",
            name: "Marcus",
            role: "Best Friend",
            avatarColor: ThemeColors.categoryMilestone
        ),
        Testimonial(
            quote: "My mom cried when I sent her a collage of our memories together. Worth every second.",
            name: "Jamie",
            role: "Daughter",
            avatarColor: ThemeColors.categoryAnniversary
        ),
        Testimonial(
            quote: "Managing birthdays for my whole family used to stress me out. Now it's actually fun!",
            name: "Alex",
            role: "Family Organizer",
            avatarColor: ThemeColors.categoryJustBecause
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Header
            VStack(spacing: Spacing.xs) {
                Text("Join 50,000+")
                    .font(Typography.Display.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Text("thoughtful gift-givers")
                    .font(Typography.Display.large)
                    .foregroundStyle(Theme.current.colors.accentPrimary)
            }
            .multilineTextAlignment(.center)
            .opacity(showHeader ? 1 : 0)
            .offset(y: showHeader ? 0 : 20)
            .animation(
                reduceMotion ? .none : .easeOut(duration: Duration.slow),
                value: showHeader
            )

            Spacer()
                .frame(height: 40)

            // Testimonial carousel
            TabView(selection: $currentIndex) {
                ForEach(Array(testimonials.enumerated()), id: \.offset) { index, testimonial in
                    TestimonialCard(testimonial: testimonial)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 280)

            // Custom page indicator
            HStack(spacing: Spacing.xs) {
                ForEach(0..<testimonials.count, id: \.self) { index in
                    Circle()
                        .fill(currentIndex == index ? Theme.current.colors.accentPrimary : Theme.current.colors.textTertiary.opacity(0.3))
                        .frame(width: currentIndex == index ? 10 : 8, height: currentIndex == index ? 10 : 8)
                        .animation(.easeInOut(duration: Duration.fast), value: currentIndex)
                }
            }
            .padding(.top, Spacing.m)

            Spacer()
                .frame(height: 32)

            // Trust indicators
            HStack(spacing: Spacing.xl) {
                TrustBadge(icon: "star.fill", text: "4.9 Rating")
                TrustBadge(icon: "heart.fill", text: "Made with care")
            }
            .opacity(showHeader ? 1 : 0)
            .animation(
                reduceMotion ? .none : .easeOut(duration: Duration.slow).delay(0.3),
                value: showHeader
            )

            Spacer()
        }
        .onAppear {
            withAnimation {
                showHeader = true
            }
        }
    }
}

// MARK: - Supporting Types

private struct Testimonial: Identifiable {
    let id = UUID()
    let quote: String
    let name: String
    let role: String
    let avatarColor: Color
}

private struct TestimonialCard: View {
    let testimonial: Testimonial

    var body: some View {
        GlassCard(cornerRadius: Radius.l, padding: Spacing.l) {
            VStack(spacing: Spacing.m) {
                // Quote icon
                Image(systemName: "quote.opening")
                    .font(.system(size: 28))
                    .foregroundStyle(Theme.current.colors.accentPrimary.opacity(0.5))

                // Quote text
                Text(testimonial.quote)
                    .font(Typography.body)
                    .foregroundStyle(Theme.current.colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Spacer()
                    .frame(height: Spacing.xs)

                // Attribution
                HStack(spacing: Spacing.s) {
                    // Avatar
                    Circle()
                        .fill(testimonial.avatarColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(testimonial.name.prefix(1))
                                .font(Typography.Title.medium)
                                .foregroundStyle(testimonial.avatarColor)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(testimonial.name)
                            .font(Typography.button)
                            .foregroundStyle(Theme.current.colors.textPrimary)

                        Text(testimonial.role)
                            .font(Typography.caption)
                            .foregroundStyle(Theme.current.colors.textSecondary)
                    }

                    Spacer()

                    // Stars
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.yellow)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
    }
}

private struct TrustBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Theme.current.colors.accentSecondary)

            Text(text)
                .font(Typography.caption)
                .foregroundStyle(Theme.current.colors.textSecondary)
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

        SocialProofScreen()
    }
}
