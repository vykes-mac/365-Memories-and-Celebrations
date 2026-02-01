//
//  ProfileTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI
import SwiftData

/// Profile tab - user settings and profile
struct ProfileTabView: View {
    @Query(sort: \Person.name) private var people: [Person]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.m) {
                        headerCard
                        settingsSection

                        if people.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: Spacing.s) {
                                ForEach(people) { person in
                                    NavigationLink {
                                        PersonDetailView(person: person)
                                    } label: {
                                        PersonCard(person: person)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(Spacing.screenHorizontal)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var headerCard: some View {
        GlassCard {
            VStack(spacing: Spacing.xs) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.current.colors.accentPrimary)

                Text("People")
                    .font(Typography.Title.large)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Text("Manage the people you celebrate")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var emptyState: some View {
        GlassCard {
            VStack(spacing: Spacing.s) {
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.current.colors.textTertiary)

                Text("No people yet")
                    .font(Typography.body)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Text("Add a moment to create your first person.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Settings")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            NavigationLink {
                NotificationSettingsView()
            } label: {
                SettingsRow(
                    title: "Reminders",
                    subtitle: "Upcoming moments and quiet hours",
                    systemImage: "bell.badge"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                ThemePickerView()
            } label: {
                SettingsRow(
                    title: "Theme",
                    subtitle: "Pick your color mood",
                    systemImage: "paintpalette"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                DataBackupView()
            } label: {
                SettingsRow(
                    title: "Data & Backup",
                    subtitle: "Sync and export options",
                    systemImage: "icloud.and.arrow.up"
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct SettingsRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        GlassCard {
            HStack(spacing: Spacing.m) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.current.colors.accentPrimary)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(Typography.body)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    Text(subtitle)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.current.colors.textTertiary)
            }
            .padding(Spacing.s)
        }
    }
}

#Preview {
    ProfileTabView()
}
