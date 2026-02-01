//
//  NotificationService.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Failed to request notifications permission: \(error.localizedDescription)")
            return false
        }
    }

    func clearAll() async {
        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()
    }

    func scheduleReminders(for moments: [Moment], settings: ReminderSetting) async {
        guard settings.enabled else {
            await clearAll()
            return
        }

        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()

        let calendar = Calendar.autoupdatingCurrent
        let now = Date()

        for moment in moments {
            guard let nextDate = nextOccurrence(for: moment, calendar: calendar, now: now) else { continue }

            for offset in settings.offsets {
                guard let scheduledDate = calendar.date(byAdding: .day, value: -offset.days, to: nextDate) else { continue }
                let adjustedDate = adjustForQuietHours(scheduledDate, settings: settings, calendar: calendar)
                if adjustedDate <= now { continue }

                var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: adjustedDate)
                components.calendar = calendar
                components.timeZone = calendar.timeZone

                let content = notificationContent(for: moment, offset: offset, calendar: calendar, now: now)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let identifier = "moment-\(moment.id.uuidString)-\(offset.rawValue)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                do {
                    try await center.add(request)
                } catch {
                    print("Failed to schedule reminder: \(error.localizedDescription)")
                }
            }
        }
    }

    private func nextOccurrence(for moment: Moment, calendar: Calendar, now: Date) -> Date? {
        if moment.recurring {
            let components = calendar.dateComponents([.month, .day], from: moment.date)
            let currentYear = calendar.component(.year, from: now)
            var nextComponents = DateComponents(year: currentYear, month: components.month, day: components.day)
            nextComponents.hour = 9
            nextComponents.minute = 0
            guard let thisYearDate = calendar.date(from: nextComponents) else { return nil }
            if thisYearDate >= now {
                return thisYearDate
            }
            nextComponents.year = currentYear + 1
            return calendar.date(from: nextComponents)
        }

        if moment.date >= now {
            return moment.date
        }
        return nil
    }

    private func notificationContent(for moment: Moment, offset: ReminderOffset, calendar: Calendar, now: Date) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        let personName = moment.person?.name ?? moment.title
        let relationship = moment.person?.relationship ?? "someone special"
        let offsetText = offsetDisplayText(offset, calendar: calendar, now: now, moment: moment)

        switch moment.categoryId {
        case "birthday":
            content.title = "\(personName)'s birthday is coming up"
            content.body = "It's \(offsetText). Time to celebrate your \(relationship)."
        case "anniversary":
            content.title = "Anniversary reminder for \(personName)"
            content.body = "It's \(offsetText). Plan something meaningful for your \(relationship)."
        case "memorial":
            content.title = "Remembering \(personName)"
            content.body = "It's \(offsetText). Hold your \(relationship) close today."
        default:
            content.title = "Upcoming moment with \(personName)"
            content.body = "It's \(offsetText). A perfect time for your \(relationship)."
        }

        content.sound = .default
        return content
    }

    private func offsetDisplayText(_ offset: ReminderOffset, calendar: Calendar, now: Date, moment: Moment) -> String {
        switch offset {
        case .dayOf:
            return "today"
        case .oneDay:
            return "tomorrow"
        case .sevenDays:
            return "in 7 days"
        }
    }

    private func adjustForQuietHours(_ date: Date, settings: ReminderSetting, calendar: Calendar) -> Date {
        guard settings.quietHoursEnabled,
              let startSeconds = settings.quietHoursStart,
              let endSeconds = settings.quietHoursEnd else {
            return date
        }

        let components = calendar.dateComponents([.hour, .minute], from: date)
        let currentSeconds = (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60

        if startSeconds < endSeconds {
            if currentSeconds >= startSeconds && currentSeconds < endSeconds {
                return calendar.date(bySettingHour: endSeconds / 3600, minute: (endSeconds % 3600) / 60, second: 0, of: date) ?? date
            }
        } else {
            if currentSeconds >= startSeconds {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: date) ?? date
                return calendar.date(bySettingHour: endSeconds / 3600, minute: (endSeconds % 3600) / 60, second: 0, of: nextDay) ?? date
            }
            if currentSeconds < endSeconds {
                return calendar.date(bySettingHour: endSeconds / 3600, minute: (endSeconds % 3600) / 60, second: 0, of: date) ?? date
            }
        }

        return date
    }
}
