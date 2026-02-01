//
//  ThemePickerView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

struct ThemePickerView: View {
    @AppStorage("selectedTheme") private var selectedTheme: String = Theme.softBlush.rawValue

    private let columns = [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text("Choose your theme")
                        .font(Typography.Title.large)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    LazyVGrid(columns: columns, spacing: Spacing.m) {
                        ForEach(Theme.allCases, id: \.self) { theme in
                            Button(action: { select(theme) }) {
                                ThemeCard(theme: theme, isSelected: theme.rawValue == selectedTheme)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func select(_ theme: Theme) {
        selectedTheme = theme.rawValue
        Theme.current = theme
        AnalyticsService.shared.track("theme_selected", properties: ["theme": theme.rawValue])
    }
}

private struct ThemeCard: View {
    let theme: Theme
    let isSelected: Bool

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                RoundedRectangle(cornerRadius: Radius.s)
                    .fill(
                        LinearGradient(
                            colors: [theme.colors.bgGradientA, theme.colors.bgGradientB],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 90)
                    .overlay(
                        HStack {
                            Circle()
                                .fill(theme.colors.accentPrimary)
                                .frame(width: 16, height: 16)

                            Circle()
                                .fill(theme.colors.accentSecondary)
                                .frame(width: 10, height: 10)

                            Spacer()
                        }
                        .padding(Spacing.s)
                    )

                Text(theme.displayName)
                    .font(Typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            .padding(Spacing.s)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.m)
                    .stroke(isSelected ? theme.colors.accentPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    NavigationStack {
        ThemePickerView()
    }
}
