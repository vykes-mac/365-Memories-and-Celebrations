//
//  ReminderSetting.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Foundation
import SwiftData

/// Reminder offset options
enum ReminderOffset: String, Codable, CaseIterable {
    case sevenDays = "7d"
    case oneDay = "1d"
    case dayOf = "0d"

    var displayName: String {
        switch self {
        case .sevenDays: return "7 days before"
        case .oneDay: return "1 day before"
        case .dayOf: return "Day of"
        }
    }

    var days: Int {
        switch self {
        case .sevenDays: return 7
        case .oneDay: return 1
        case .dayOf: return 0
        }
    }
}

/// User's reminder preferences
@Model
final class ReminderSetting {
    /// Unique identifier (typically only one per user)
    var id: UUID

    /// Whether reminders are enabled globally
    var enabled: Bool

    /// Enabled offsets (stored as JSON array of raw values)
    var offsetsJSON: String

    /// Quiet hours start time (stored as seconds from midnight)
    var quietHoursStart: Int?

    /// Quiet hours end time (stored as seconds from midnight)
    var quietHoursEnd: Int?

    /// Whether quiet hours are enabled
    var quietHoursEnabled: Bool

    /// Date settings were last modified
    var modifiedAt: Date

    /// Computed property for offsets
    var offsets: Set<ReminderOffset> {
        get {
            guard let data = offsetsJSON.data(using: .utf8),
                  let rawValues = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return Set(rawValues.compactMap { ReminderOffset(rawValue: $0) })
        }
        set {
            let rawValues = newValue.map { $0.rawValue }
            if let data = try? JSONEncoder().encode(rawValues),
               let string = String(data: data, encoding: .utf8) {
                offsetsJSON = string
            }
        }
    }

    /// Quiet hours start as Date components (hour and minute)
    var quietStart: (hour: Int, minute: Int)? {
        guard let seconds = quietHoursStart else { return nil }
        return (hour: seconds / 3600, minute: (seconds % 3600) / 60)
    }

    /// Quiet hours end as Date components (hour and minute)
    var quietEnd: (hour: Int, minute: Int)? {
        guard let seconds = quietHoursEnd else { return nil }
        return (hour: seconds / 3600, minute: (seconds % 3600) / 60)
    }

    init(
        id: UUID = UUID(),
        enabled: Bool = true,
        offsets: Set<ReminderOffset> = [.sevenDays, .oneDay, .dayOf],
        quietHoursEnabled: Bool = false,
        quietHoursStart: Int? = nil,
        quietHoursEnd: Int? = nil,
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.enabled = enabled
        self.quietHoursEnabled = quietHoursEnabled
        self.quietHoursStart = quietHoursStart
        self.quietHoursEnd = quietHoursEnd
        self.modifiedAt = modifiedAt

        // Initialize offsets JSON
        let rawValues = offsets.map { $0.rawValue }
        if let data = try? JSONEncoder().encode(rawValues),
           let string = String(data: data, encoding: .utf8) {
            self.offsetsJSON = string
        } else {
            self.offsetsJSON = "[]"
        }
    }

    /// Set quiet hours using hour and minute
    func setQuietHours(startHour: Int, startMinute: Int, endHour: Int, endMinute: Int) {
        quietHoursStart = startHour * 3600 + startMinute * 60
        quietHoursEnd = endHour * 3600 + endMinute * 60
        quietHoursEnabled = true
    }

    /// Disable quiet hours
    func disableQuietHours() {
        quietHoursEnabled = false
    }
}

// MARK: - Default Settings

extension ReminderSetting {
    /// Create default reminder settings
    static func createDefault() -> ReminderSetting {
        let setting = ReminderSetting(
            enabled: true,
            offsets: [.sevenDays, .oneDay, .dayOf],
            quietHoursEnabled: true
        )
        // Default quiet hours: 10 PM to 8 AM
        setting.setQuietHours(startHour: 22, startMinute: 0, endHour: 8, endMinute: 0)
        return setting
    }
}
