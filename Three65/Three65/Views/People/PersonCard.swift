//
//  PersonCard.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import UIKit

/// Card view displaying a person's summary and upcoming moments
struct PersonCard: View {
    let person: Person

    var body: some View {
        GlassCard {
            HStack(alignment: .top, spacing: Spacing.m) {
                avatarView

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(person.name)
                        .font(Typography.Title.medium)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    Text(person.relationship)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)

                    if !upcomingMomentChips.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.xs) {
                                ForEach(upcomingMomentChips, id: \.id) { chip in
                                    MomentChip(label: chip.label, color: chip.color)
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var avatarView: some View {
        Group {
            if let image = avatarImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(initials)
                    .font(Typography.body)
                    .foregroundStyle(Theme.current.colors.textPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.current.colors.glassCardFill)
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Theme.current.colors.glassCardStroke, lineWidth: 1)
        )
    }

    private var initials: String {
        let components = person.name.split(separator: " ")
        let first = components.first?.first.map(String.init) ?? ""
        let second = components.dropFirst().first?.first.map(String.init) ?? ""
        return (first + second).uppercased()
    }

    private var avatarImage: UIImage? {
        guard let avatarRef = person.avatarRef,
              let data = Data(base64Encoded: avatarRef),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    private var upcomingMomentChips: [MomentChipData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let upcoming: [(Moment, Date, Int)] = (person.moments ?? []).compactMap { moment in
            guard let nextDate = nextOccurrence(for: moment, calendar: calendar, today: today) else { return nil }
            guard let daysUntil = calendar.dateComponents([.day], from: today, to: nextDate).day else { return nil }
            guard daysUntil >= 0 else { return nil }
            return (moment, nextDate, daysUntil)
        }

        return upcoming
            .sorted { $0.2 < $1.2 }
            .prefix(3)
            .map { moment, _, daysUntil in
                let label = chipLabel(for: moment, daysUntil: daysUntil)
                return MomentChipData(id: moment.id.uuidString, label: label, color: categoryColor(for: moment))
            }
    }

    private func nextOccurrence(for moment: Moment, calendar: Calendar, today: Date) -> Date? {
        if moment.recurring {
            let components = calendar.dateComponents([.month, .day], from: moment.date)
            var currentYearComponents = DateComponents(year: calendar.component(.year, from: today), month: components.month, day: components.day)
            if let currentYearDate = calendar.date(from: currentYearComponents),
               currentYearDate >= today {
                return currentYearDate
            }

            currentYearComponents.year = (currentYearComponents.year ?? 0) + 1
            return calendar.date(from: currentYearComponents)
        }

        let momentDate = calendar.startOfDay(for: moment.date)
        return momentDate >= today ? momentDate : nil
    }

    private func chipLabel(for moment: Moment, daysUntil: Int) -> String {
        let name = categoryName(for: moment.categoryId)
        if daysUntil == 0 {
            return "\(name) · Today"
        } else if daysUntil == 1 {
            return "\(name) · 1d"
        } else {
            return "\(name) · \(daysUntil)d"
        }
    }

    private func categoryName(for categoryId: String) -> String {
        switch categoryId {
        case "birthday": return "Birthday"
        case "anniversary": return "Anniversary"
        case "milestone": return "Milestone"
        case "memorial": return "Memorial"
        case "justBecause": return "Just Because"
        case "custom": return "Custom"
        default: return "Moment"
        }
    }

    private func categoryColor(for moment: Moment) -> Color {
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

private struct MomentChipData {
    let id: String
    let label: String
    let color: Color
}

private struct MomentChip: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(Typography.micro)
            .foregroundStyle(Theme.current.colors.textPrimary)
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.xxs)
            .background(
                Capsule()
                    .fill(color.opacity(0.2))
            )
    }
}

#Preview {
    let person = Person(name: "Jordan Lee", relationship: "Friend")
    let moment = Moment(date: Date(), categoryId: "birthday", title: "Jordan's Birthday")
    moment.person = person
    person.moments = [moment]

    return PersonCard(person: person)
        .padding()
}
