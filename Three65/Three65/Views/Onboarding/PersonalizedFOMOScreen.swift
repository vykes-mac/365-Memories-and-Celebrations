//
//  PersonalizedFOMOScreen.swift
//  Three65
//
//  Created on 02/02/2026.
//

import SwiftUI

/// Shows upcoming dates to create urgency
/// Personalized based on imported contacts or uses sample data
struct PersonalizedFOMOScreen: View {
    let upcomingDates: [UpcomingDate]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showHeader = false
    @State private var showDates = false
    @State private var showFooter = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Header
            VStack(spacing: Spacing.xs) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.current.colors.accentPrimary)
                    .symbolEffect(.pulse, options: .repeating)

                Text("Look what's\ncoming up!")
                    .font(Typography.Display.large)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.current.colors.textPrimary)
            }
            .opacity(showHeader ? 1 : 0)
            .offset(y: showHeader ? 0 : 20)
            .animation(
                reduceMotion ? .none : .easeOut(duration: Duration.slow),
                value: showHeader
            )
            .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 32)

            // Upcoming dates list
            VStack(spacing: Spacing.s) {
                ForEach(Array(upcomingDates.prefix(4).enumerated()), id: \.element.id) { index, date in
                    UpcomingDateCard(upcomingDate: date)
                        .opacity(showDates ? 1 : 0)
                        .offset(x: showDates ? 0 : -30)
                        .animation(
                            reduceMotion ? .none : .easeOut(duration: Duration.slow).delay(Double(index) * 0.15),
                            value: showDates
                        )
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 32)

            // Footer message
            VStack(spacing: Spacing.xs) {
                Text("Without 365, these would sneak up on you.")
                    .font(Typography.body)
                    .foregroundStyle(Theme.current.colors.textSecondary)

                Text("Now you'll be ready.")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.accentPrimary)
            }
            .multilineTextAlignment(.center)
            .opacity(showFooter ? 1 : 0)
            .offset(y: showFooter ? 0 : 15)
            .animation(
                reduceMotion ? .none : .easeOut(duration: Duration.slow),
                value: showFooter
            )

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation { showDates = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showFooter = true }
        }
    }
}

// MARK: - Supporting Types

struct UpcomingDate: Identifiable {
    let id = UUID()
    let name: String
    let event: String
    let daysAway: Int
    let category: UpcomingDateCategory

    var icon: String {
        switch category {
        case .birthday: return "gift.fill"
        case .anniversary: return "heart.fill"
        case .milestone: return "flag.fill"
        case .other: return "star.fill"
        }
    }

    var color: Color {
        switch category {
        case .birthday: return ThemeColors.categoryBirthday
        case .anniversary: return ThemeColors.categoryAnniversary
        case .milestone: return ThemeColors.categoryMilestone
        case .other: return ThemeColors.categoryJustBecause
        }
    }

    var urgencyText: String {
        switch daysAway {
        case 0: return "Today!"
        case 1: return "Tomorrow!"
        case 2...7: return "\(daysAway) days"
        case 8...14: return "\(daysAway) days"
        default: return "\(daysAway) days"
        }
    }

    var isUrgent: Bool {
        daysAway <= 14
    }
}

enum UpcomingDateCategory {
    case birthday
    case anniversary
    case milestone
    case other
}

private struct UpcomingDateCard: View {
    let upcomingDate: UpcomingDate

    var body: some View {
        GlassCard(padding: Spacing.s) {
            HStack(spacing: Spacing.m) {
                // Icon
                ZStack {
                    Circle()
                        .fill(upcomingDate.color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: upcomingDate.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(upcomingDate.color)
                }

                // Details
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(upcomingDate.name)'s \(upcomingDate.event)")
                        .font(Typography.body)
                        .foregroundStyle(Theme.current.colors.textPrimary)
                        .lineLimit(1)

                    Text(upcomingDate.category == .birthday ? "Birthday" : upcomingDate.event)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }

                Spacer()

                // Countdown badge
                CountdownBadge(
                    text: upcomingDate.urgencyText,
                    isUrgent: upcomingDate.isUrgent,
                    color: upcomingDate.color
                )
            }
        }
    }
}

private struct CountdownBadge: View {
    let text: String
    let isUrgent: Bool
    let color: Color

    var body: some View {
        Text(text)
            .font(Typography.micro)
            .foregroundStyle(isUrgent ? .white : Theme.current.colors.textSecondary)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xxs)
            .background(
                Capsule()
                    .fill(isUrgent ? color : Theme.current.colors.textTertiary.opacity(0.2))
            )
    }
}

// MARK: - Sample Data

extension PersonalizedFOMOScreen {
    /// Sample data for preview or when no contacts imported
    static let sampleDates: [UpcomingDate] = [
        UpcomingDate(name: "Mom", event: "Birthday", daysAway: 23, category: .birthday),
        UpcomingDate(name: "Alex", event: "Anniversary", daysAway: 41, category: .anniversary),
        UpcomingDate(name: "Dad", event: "60th", daysAway: 67, category: .milestone),
        UpcomingDate(name: "Best Friend", event: "Birthday", daysAway: 89, category: .birthday)
    ]
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        PersonalizedFOMOScreen(upcomingDates: PersonalizedFOMOScreen.sampleDates)
    }
}
