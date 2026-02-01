//
//  Three65App.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI
import SwiftData

@main
struct Three65App: App {
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                MainTabView()
                    .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self])
            } else {
                OnboardingFlow {
                    hasOnboarded = true
                }
                .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self])
            }
        }
    }
}
