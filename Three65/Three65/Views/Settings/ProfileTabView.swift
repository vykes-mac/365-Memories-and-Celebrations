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
}

#Preview {
    ProfileTabView()
}
