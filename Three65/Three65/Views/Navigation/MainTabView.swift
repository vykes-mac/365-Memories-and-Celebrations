//
//  MainTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Tab enumeration for the main navigation
enum AppTab: String, CaseIterable, Identifiable {
    case garden
    case calendar
    case create
    case library
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .garden: return "Garden"
        case .calendar: return "Calendar"
        case .create: return "Create"
        case .library: return "Library"
        case .profile: return "Profile"
        }
    }

    var icon: String {
        switch self {
        case .garden: return "circle.grid.3x3"
        case .calendar: return "calendar"
        case .create: return "plus.circle.fill"
        case .library: return "photo.stack"
        case .profile: return "person.crop.circle"
        }
    }

    var selectedIcon: String {
        switch self {
        case .garden: return "circle.grid.3x3.fill"
        case .calendar: return "calendar"
        case .create: return "plus.circle.fill"
        case .library: return "photo.stack.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

/// Main tab-based navigation view
struct MainTabView: View {
    @State private var selectedTab: AppTab = .garden
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.softBlush.rawValue

    private var currentTheme: Theme {
        Theme(rawValue: selectedTheme) ?? .softBlush
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            GardenTabView()
                .tabItem {
                    Label(AppTab.garden.title, systemImage: selectedTab == .garden ? AppTab.garden.selectedIcon : AppTab.garden.icon)
                }
                .tag(AppTab.garden)

            CalendarTabView()
                .tabItem {
                    Label(AppTab.calendar.title, systemImage: selectedTab == .calendar ? AppTab.calendar.selectedIcon : AppTab.calendar.icon)
                }
                .tag(AppTab.calendar)

            CreateTabView()
                .tabItem {
                    Label(AppTab.create.title, systemImage: AppTab.create.icon)
                }
                .tag(AppTab.create)

            LibraryTabView()
                .tabItem {
                    Label(AppTab.library.title, systemImage: selectedTab == .library ? AppTab.library.selectedIcon : AppTab.library.icon)
                }
                .tag(AppTab.library)

            ProfileTabView()
                .tabItem {
                    Label(AppTab.profile.title, systemImage: selectedTab == .profile ? AppTab.profile.selectedIcon : AppTab.profile.icon)
                }
                .tag(AppTab.profile)
        }
        .tint(currentTheme.colors.accentPrimary)
        // Glass effect for tab bar using SwiftUI material
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview {
    MainTabView()
}
