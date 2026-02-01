//
//  NotificationSettingsView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData

struct NotificationSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [ReminderSetting]
    @Query(sort: \Moment.date) private var moments: [Moment]

    @State private var activeSetting: ReminderSetting?
    @State private var quietStart: Date = Calendar.current.startOfDay(for: Date())
    @State private var quietEnd: Date = Calendar.current.startOfDay(for: Date())

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if let setting = activeSetting ?? settings.first {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        remindersSection(setting)
                        offsetsSection(setting)
                        quietHoursSection(setting)
                    }
                    .padding(Spacing.screenHorizontal)
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadSetting)
    }

    private func remindersSection(_ setting: ReminderSetting) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Reminders")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Toggle("Enable reminders", isOn: binding(
                    get: { setting.enabled },
                    set: { newValue in
                        setting.enabled = newValue
                        setting.modifiedAt = Date()
                        saveChanges()
                        if newValue {
                            AnalyticsService.shared.track("reminder_enabled")
                            Task {
                                _ = await NotificationService.shared.requestAuthorization()
                                await refreshSchedule(setting)
                            }
                        } else {
                            Task { await NotificationService.shared.clearAll() }
                        }
                    }
                ))
                .tint(Theme.current.colors.accentPrimary)

                Text("Get gentle nudges before important moments.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
            .padding(Spacing.s)
        }
    }

    private func offsetsSection(_ setting: ReminderSetting) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Notify me")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                ForEach(ReminderOffset.allCases, id: \.self) { offset in
                    Toggle(offset.displayName, isOn: binding(
                        get: { setting.offsets.contains(offset) },
                        set: { isOn in
                            var offsets = setting.offsets
                            if isOn {
                                offsets.insert(offset)
                            } else {
                                offsets.remove(offset)
                            }
                            setting.offsets = offsets
                            setting.modifiedAt = Date()
                            saveChanges()
                            Task { await refreshSchedule(setting) }
                        }
                    ))
                    .tint(Theme.current.colors.accentPrimary)
                }
            }
            .padding(Spacing.s)
        }
        .opacity(setting.enabled ? 1 : 0.5)
        .disabled(!setting.enabled)
    }

    private func quietHoursSection(_ setting: ReminderSetting) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Quiet hours")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Toggle("Silence notifications", isOn: binding(
                    get: { setting.quietHoursEnabled },
                    set: { isOn in
                        setting.quietHoursEnabled = isOn
                        if isOn {
                            updateQuietHours(setting)
                        }
                        setting.modifiedAt = Date()
                        saveChanges()
                        Task { await refreshSchedule(setting) }
                    }
                ))
                .tint(Theme.current.colors.accentPrimary)

                if setting.quietHoursEnabled {
                    DatePicker("Start", selection: $quietStart, displayedComponents: .hourAndMinute)
                        .onChange(of: quietStart) { _, _ in
                            updateQuietHours(setting)
                            Task { await refreshSchedule(setting) }
                        }

                    DatePicker("End", selection: $quietEnd, displayedComponents: .hourAndMinute)
                        .onChange(of: quietEnd) { _, _ in
                            updateQuietHours(setting)
                            Task { await refreshSchedule(setting) }
                        }
                }

                Text("Notifications will wait until quiet hours end.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
            .padding(Spacing.s)
        }
        .opacity(setting.enabled ? 1 : 0.5)
        .disabled(!setting.enabled)
    }

    private func loadSetting() {
        if let existing = settings.first {
            activeSetting = existing
            updateQuietState(from: existing)
            return
        }

        let newSetting = ReminderSetting.createDefault()
        modelContext.insert(newSetting)
        activeSetting = newSetting
        updateQuietState(from: newSetting)
        saveChanges()
    }

    private func updateQuietState(from setting: ReminderSetting) {
        quietStart = dateFromSeconds(setting.quietHoursStart ?? 22 * 3600)
        quietEnd = dateFromSeconds(setting.quietHoursEnd ?? 8 * 3600)
    }

    private func updateQuietHours(_ setting: ReminderSetting) {
        let startSeconds = secondsFromDate(quietStart)
        let endSeconds = secondsFromDate(quietEnd)
        setting.quietHoursStart = startSeconds
        setting.quietHoursEnd = endSeconds
        setting.quietHoursEnabled = true
        setting.modifiedAt = Date()
        saveChanges()
    }

    private func dateFromSeconds(_ seconds: Int) -> Date {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .second, value: seconds, to: startOfDay) ?? startOfDay
    }

    private func secondsFromDate(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save reminder settings: \(error.localizedDescription)")
        }
    }

    private func refreshSchedule(_ setting: ReminderSetting) async {
        await NotificationService.shared.scheduleReminders(for: moments, settings: setting)
    }

    private func binding<T>(get: @escaping () -> T, set: @escaping (T) -> Void) -> Binding<T> {
        Binding(get: get, set: set)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
            .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
    }
}
