//
//  LibraryTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Library tab - creative library of saved collages
struct LibraryTabView: View {
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
                            Image(systemName: "photo.stack.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.current.colors.accentPrimary)

                            Text("Library")
                                .font(Typography.Title.large)
                                .foregroundStyle(Theme.current.colors.textPrimary)

                            Text("Your saved creations")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    LibraryTabView()
}
