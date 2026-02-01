//
//  GardenTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Garden tab - 365 year-at-a-glance view
struct GardenTabView: View {
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
                            Image(systemName: "circle.grid.3x3.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.current.colors.accentPrimary)

                            Text("365 Garden")
                                .font(Typography.Title.large)
                                .foregroundStyle(Theme.current.colors.textPrimary)

                            Text("Your year at a glance")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
            .navigationTitle("Garden")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    GardenTabView()
}
