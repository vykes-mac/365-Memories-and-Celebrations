//
//  DayDetailSheet.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import PhotosUI
import SwiftData

/// Bottom sheet showing details for a selected day
struct DayDetailSheet: View {
    let day: GardenDay
    let onDismiss: () -> Void
    let onAddMoment: (Date) -> Void
    @State private var showingCollageFlow = false
    @State private var showConfetti = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    var body: some View {
        VStack(spacing: Spacing.l) {
            header

            actionRow

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: Spacing.l) {
                    if day.hasEvents {
                        mediaSection
                        momentsSection
                    } else {
                        emptyState
                    }

                    celebrationCTA
                }
                .padding(.vertical, Spacing.s)
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.s)
        .padding(.bottom, Spacing.xl)
        .frame(maxWidth: .infinity)
        .glassSheet(cornerRadius: Radius.l)
        .sheet(isPresented: $showingCollageFlow) {
            CollageFlowView(person: day.moments.first?.person, moment: day.moments.first)
        }
        .overlay {
            if showConfetti {
                ConfettiBurstView()
            }
        }
        .onAppear {
            guard hasBigAnniversary, !reduceMotion else { return }
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showConfetti = false
            }
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: Spacing.s) {
            Capsule()
                .fill(Theme.current.colors.textTertiary.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, Spacing.xs)

            HStack(alignment: .center, spacing: Spacing.s) {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(dateFormatter.string(from: day.date))
                        .font(Typography.Title.large)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    if let badge = countdownBadgeText {
                        Text(badge)
                            .font(Typography.caption)
                            .foregroundStyle(Theme.current.colors.accentPrimary)
                            .padding(.horizontal, Spacing.s)
                            .padding(.vertical, Spacing.xxs)
                            .background(
                                Capsule()
                                    .fill(Theme.current.colors.accentPrimary.opacity(0.15))
                            )
                            .accessibilityLabel("Countdown: \(badge)")
                    }
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }
                .accessibilityLabel("Dismiss day details")
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: Spacing.s) {
            QuickActionButton(title: "Call", systemImage: "phone.fill") {}
            QuickActionButton(title: "Text", systemImage: "message.fill") {}
            QuickActionButton(title: "Share", systemImage: "square.and.arrow.up") {}
            QuickActionButton(title: "Plan", systemImage: "calendar.badge.plus") {}
        }
    }

    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Media")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            if mediaItems.isEmpty {
                MediaPlaceholderTile()
            } else {
                MediaPreviewStrip(mediaItems: mediaItems)
            }
        }
    }

    private var momentsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                Text("Moments")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Spacer()

                Button(action: { onAddMoment(day.date) }) {
                    Text("Add moment")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                        .padding(.horizontal, Spacing.s)
                        .padding(.vertical, Spacing.xxs)
                        .background(
                            Capsule()
                                .fill(Theme.current.colors.accentPrimary.opacity(0.15))
                        )
                }
                .accessibilityLabel("Add moment")
            }

            LazyVStack(spacing: Spacing.s) {
                ForEach(day.moments, id: \.id) { moment in
                    MomentRow(moment: moment)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(Theme.current.colors.textTertiary)

            Text("No moments on this day")
                .font(Typography.body)
                .foregroundStyle(Theme.current.colors.textSecondary)

            Button(action: {
                onAddMoment(day.date)
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
            .accessibilityLabel("Add moment")
        }
        .padding(.vertical, Spacing.xl)
    }

    private var celebrationCTA: some View {
        Button(action: {
            showingCollageFlow = true
        }) {
            HStack(spacing: Spacing.s) {
                Image(systemName: "sparkles")
                Text("Create Celebration Pack")
            }
            .font(Typography.button)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.m)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Radius.m)
                    .fill(Theme.current.colors.accentPrimary)
            )
        }
        .opacity(day.hasEvents ? 1 : 0.5)
        .disabled(!day.hasEvents)
        .accessibilityLabel("Create Celebration Pack")
    }

    // MARK: - Computed Properties

    private var mediaItems: [Media] {
        let allMedia = day.moments.flatMap { $0.media ?? [] }
        return allMedia.sorted { $0.sortOrder < $1.sortOrder }
    }

    private var countdownBadgeText: String? {
        if day.isToday {
            return "Today"
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayStart = calendar.startOfDay(for: day.date)

        guard let daysUntil = calendar.dateComponents([.day], from: today, to: dayStart).day else {
            return nil
        }

        if daysUntil == 1 {
            return "Tomorrow"
        } else if daysUntil > 1 && daysUntil <= 7 {
            return "\(daysUntil) days"
        }

        return nil
    }

    private var hasBigAnniversary: Bool {
        let calendar = Calendar.current
        return day.moments.contains { moment in
            guard moment.recurring else { return false }
            let years = calendar.dateComponents([.year], from: moment.date, to: day.date).year ?? 0
            return years >= 10 && years % 10 == 0
        }
    }
}

/// A single row displaying a moment in the day detail sheet
struct MomentRow: View {
    @Environment(\.modelContext) private var modelContext
    let moment: Moment

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
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

                    Text(categoryName)
                        .font(Typography.micro)
                        .foregroundStyle(Theme.current.colors.textTertiary)
                }

                Spacer()

                // Recurring indicator
                if moment.recurring {
                    Image(systemName: "repeat")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.current.colors.textTertiary)
                }
            }

            MediaStrip(
                title: nil,
                mediaItems: sortedMedia,
                onAdd: addMediaItems,
                onDelete: deleteMedia,
                onMove: moveMedia
            )
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

    private var categoryName: String {
        switch moment.categoryId {
        case "birthday": return "Birthday"
        case "anniversary": return "Anniversary"
        case "milestone": return "Milestone"
        case "memorial": return "Memorial"
        case "justBecause": return "Just Because"
        default: return "Moment"
        }
    }

    private var sortedMedia: [Media] {
        (moment.media ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    private func addMediaItems(_ items: [PhotosPickerItem]) {
        Task {
            let startingOrder = sortedMedia.count
            var order = startingOrder

            for item in items {
                guard let identifier = item.itemIdentifier else { continue }
                let isVideo = item.supportedContentTypes.contains { $0.conforms(to: .movie) }
                let media = Media(
                    moment: moment,
                    localIdentifier: identifier,
                    type: isVideo ? .video : .photo,
                    sortOrder: order
                )
                modelContext.insert(media)
                order += 1
            }

            saveChanges()
        }
    }

    private func deleteMedia(_ media: Media) {
        modelContext.delete(media)
        saveChanges()
    }

    private func moveMedia(from source: IndexSet, to destination: Int) {
        var items = sortedMedia
        items.move(fromOffsets: source, toOffset: destination)
        for (index, item) in items.enumerated() {
            item.sortOrder = index
        }
        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save media changes: \(error.localizedDescription)")
        }
    }
}

/// Quick action button used in the day details sheet
struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xxs) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(Typography.micro)
            }
            .foregroundStyle(Theme.current.colors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.s)
            .background(
                RoundedRectangle(cornerRadius: Radius.s)
                    .fill(Theme.current.colors.glassCardFill)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

/// Placeholder tile shown when no media is attached
struct MediaPlaceholderTile: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Radius.s)
            .fill(Theme.current.colors.glassCardFill)
            .frame(width: 72, height: 72)
            .overlay(
                VStack(spacing: Spacing.xxs) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 18))
                    Text("No media")
                        .font(Typography.micro)
                }
                .foregroundStyle(Theme.current.colors.textTertiary)
            )
            .accessibilityLabel("No media attached")
    }
}

// MARK: - Preview

#Preview {
    let person = Person(name: "Mom", relationship: "Mother")
    let moment = Moment(date: Date(), categoryId: "birthday", title: "Mom's Birthday")
    moment.person = person
    moment.media = [
        Media(localIdentifier: "sample-photo", type: .photo),
        Media(localIdentifier: "sample-video", type: .video)
    ]

    return DayDetailSheet(
        day: GardenDay(
            id: 1,
            date: Date(),
            isToday: true,
            moments: [moment]
        ),
        onDismiss: {},
        onAddMoment: { _ in }
    )
}
