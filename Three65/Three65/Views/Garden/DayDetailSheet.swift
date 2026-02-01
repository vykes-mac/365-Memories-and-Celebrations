//
//  DayDetailSheet.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

/// Bottom sheet showing details for a selected day
/// Note: Full implementation covered in F2.3
struct DayDetailSheet: View {
    let day: GardenDay
    let onDismiss: () -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    var body: some View {
        VStack(spacing: Spacing.m) {
            // Handle indicator
            RoundedRectangle(cornerRadius: Radius.pill)
                .fill(Theme.current.colors.textTertiary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, Spacing.s)

            // Date header
            VStack(spacing: Spacing.xxs) {
                Text(dateFormatter.string(from: day.date))
                    .font(Typography.Title.large)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                if day.isToday {
                    Text("Today")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical, Spacing.xxs)
                        .background(
                            Capsule()
                                .fill(Theme.current.colors.accentPrimary.opacity(0.15))
                        )
                } else if let countdown = countdownText {
                    Text(countdown)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)

            Divider()
                .background(Theme.current.colors.divider)

            // Moments list or empty state
            if day.hasEvents {
                momentsList
            } else {
                emptyState
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: Radius.l)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }

    // MARK: - Subviews

    @ViewBuilder
    private var momentsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.s) {
                ForEach(day.moments, id: \.id) { moment in
                    MomentRow(moment: moment)
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(Theme.current.colors.textTertiary)

            Text("No moments on this day")
                .font(Typography.body)
                .foregroundStyle(Theme.current.colors.textSecondary)

            Button(action: {
                // TODO: Trigger add moment flow
            }) {
                Text("Add a moment")
                    .font(Typography.button)
                    .foregroundStyle(.white)
                    .padding(.horizontal, Spacing.l)
                    .padding(.vertical, Spacing.s)
                    .background(
                        Capsule()
                            .fill(Theme.current.colors.accentPrimary)
                    )
            }
        }
        .padding(.vertical, Spacing.xxl)
    }

    // MARK: - Computed Properties

    private var countdownText: String? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayStart = calendar.startOfDay(for: day.date)

        guard let daysUntil = calendar.dateComponents([.day], from: today, to: dayStart).day else {
            return nil
        }

        if daysUntil == 1 {
            return "Tomorrow"
        } else if daysUntil > 1 && daysUntil <= 7 {
            return "\(daysUntil) days away"
        } else if daysUntil < 0 {
            let daysPast = abs(daysUntil)
            if daysPast == 1 {
                return "Yesterday"
            } else {
                return "\(daysPast) days ago"
            }
        }

        return nil
    }
}

/// A single row displaying a moment in the day detail sheet
struct MomentRow: View {
    let moment: Moment

    var body: some View {
        HStack(spacing: Spacing.s) {
            // Category indicator
            Circle()
                .fill(categoryColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(moment.title)
                    .font(Typography.body)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                if let personName = moment.person?.name {
                    Text(personName)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }
            }

            Spacer()

            // Recurring indicator
            if moment.recurring {
                Image(systemName: "repeat")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.current.colors.textTertiary)
            }
        }
        .padding(Spacing.cardPaddingCompact)
        .background(
            RoundedRectangle(cornerRadius: Radius.s)
                .fill(Theme.current.colors.glassCardFill)
        )
    }

    private var categoryColor: Color {
        switch moment.categoryId {
        case "birthday": return ThemeColors.categoryBirthday
        case "anniversary": return ThemeColors.categoryAnniversary
        case "milestone": return ThemeColors.categoryMilestone
        case "memorial": return ThemeColors.categoryMemorial
        case "justBecause": return ThemeColors.categoryJustBecause
        default: return Theme.current.colors.accentPrimary
        }
    }
}

// MARK: - Preview

#Preview {
    DayDetailSheet(
        day: GardenDay(
            id: 1,
            date: Date(),
            isToday: true,
            moments: []
        ),
        onDismiss: {}
    )
}
