//
//  CalendarTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Calendar tab - traditional calendar view of moments
struct CalendarTabView: View {
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

                VStack(spacing: Spacing.m) {
                    GlassCard {
                        VStack(spacing: Spacing.xs) {
                            Image(systemName: "calendar")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.current.colors.accentPrimary)

                            Text("Calendar")
                                .font(Typography.Title.large)
                                .foregroundStyle(Theme.current.colors.textPrimary)

                            Text("View moments by date")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    CalendarTabView()
}
