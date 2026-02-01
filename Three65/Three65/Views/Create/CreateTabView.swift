//
//  CreateTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Create tab - celebration pack creation hub
struct CreateTabView: View {
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
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.current.colors.accentPrimary)

                            Text("Create")
                                .font(Typography.Title.large)
                                .foregroundStyle(Theme.current.colors.textPrimary)

                            Text("Make celebration packs")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    CreateTabView()
}
