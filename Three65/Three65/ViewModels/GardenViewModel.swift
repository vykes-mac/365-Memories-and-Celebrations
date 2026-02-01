//
//  GardenViewModel.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

/// Represents a single day in the garden view
struct GardenDay: Identifiable, Equatable {
    let id: Int // Day of year (1-365/366)
    let date: Date
    let isToday: Bool
    var moments: [Moment]

    /// Returns the primary category color for this day (first moment's category)
    var primaryCategoryColor: Color? {
        guard let firstMoment = moments.first else { return nil }
        return categoryColor(for: firstMoment.categoryId)
    }

    /// Returns all category colors for this day (for multi-event display)
    var categoryColors: [Color] {
        moments.compactMap { categoryColor(for: $0.categoryId) }
    }

    /// Whether this day has any events
    var hasEvents: Bool { !moments.isEmpty }

    /// Number of events on this day
    var eventCount: Int { moments.count }

    /// Whether this day is within the upcoming 7 days
    var isUpcoming: Bool {
        guard !isToday else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayStart = calendar.startOfDay(for: date)
        guard let daysUntil = calendar.dateComponents([.day], from: today, to: dayStart).day else {
            return false
        }
        return daysUntil > 0 && daysUntil <= 7
    }

    private func categoryColor(for categoryId: String) -> Color {
        switch categoryId {
        case "birthday": return ThemeColors.categoryBirthday
        case "anniversary": return ThemeColors.categoryAnniversary
        case "milestone": return ThemeColors.categoryMilestone
        case "memorial": return ThemeColors.categoryMemorial
        case "justBecause": return ThemeColors.categoryJustBecause
        default: return Theme.current.colors.accentPrimary
        }
    }
}

/// ViewModel for the 365 Garden view
@MainActor
final class GardenViewModel: BaseViewModel {
    // MARK: - Published Properties

    /// The currently selected year
    @Published var selectedYear: Int

    /// All days for the selected year with their moments
    @Published var days: [GardenDay] = []

    /// The currently selected day (for the detail sheet)
    @Published var selectedDay: GardenDay?

    /// Whether the day detail sheet is showing
    @Published var showingDayDetail: Bool = false

    /// Display mode: dot or heatmap
    @Published var displayMode: DisplayMode = .dot

    enum DisplayMode: String, CaseIterable {
        case dot
        case heatmap
    }

    // MARK: - Private Properties

    private let calendar = Calendar.current
    private var modelContext: ModelContext?

    // MARK: - Initialization

    override init() {
        self.selectedYear = Calendar.current.component(.year, from: Date())
        super.init()
    }

    // MARK: - Public Methods

    /// Set the model context for data fetching
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadDays()
    }

    /// Load all days for the selected year
    func loadDays() {
        guard let startOfYear = calendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: selectedYear, month: 12, day: 31)) else {
            return
        }

        // Get all moments for the year
        let yearMoments = fetchMomentsForYear()

        // Build days array
        var newDays: [GardenDay] = []
        var currentDate = startOfYear
        var dayOfYear = 1
        let today = calendar.startOfDay(for: Date())

        while currentDate <= endOfYear {
            let dayStart = calendar.startOfDay(for: currentDate)

            // Find moments for this day
            let dayMoments = yearMoments.filter { moment in
                if moment.recurring {
                    // For recurring moments, match month and day regardless of year
                    let momentComponents = calendar.dateComponents([.month, .day], from: moment.date)
                    let currentComponents = calendar.dateComponents([.month, .day], from: currentDate)
                    return momentComponents.month == currentComponents.month &&
                           momentComponents.day == currentComponents.day
                } else {
                    // For non-recurring, match exact date
                    return calendar.isDate(moment.date, inSameDayAs: currentDate)
                }
            }

            let gardenDay = GardenDay(
                id: dayOfYear,
                date: currentDate,
                isToday: calendar.isDate(currentDate, inSameDayAs: today),
                moments: dayMoments
            )
            newDays.append(gardenDay)

            dayOfYear += 1
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        days = newDays
    }

    /// Select a day to show details
    func selectDay(_ day: GardenDay) {
        selectedDay = day
        showingDayDetail = true
    }

    /// Dismiss the day detail sheet
    func dismissDayDetail() {
        showingDayDetail = false
        selectedDay = nil
    }

    /// Go to previous year
    func previousYear() {
        selectedYear -= 1
        loadDays()
    }

    /// Go to next year
    func nextYear() {
        selectedYear += 1
        loadDays()
    }

    /// Go to current year
    func goToCurrentYear() {
        selectedYear = calendar.component(.year, from: Date())
        loadDays()
    }

    // MARK: - Private Methods

    private func fetchMomentsForYear() -> [Moment] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Moment>()

        do {
            return try context.fetch(descriptor)
        } catch {
            errorMessage = "Failed to load moments: \(error.localizedDescription)"
            return []
        }
    }
}
