//
//  CreateTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Create tab - celebration pack creation hub
struct CreateTabView: View {
    @State private var showingCollageFlow = false

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
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.current.colors.accentPrimary)

                            Text("Create Celebration Pack")
                                .font(Typography.Title.large)
                                .foregroundStyle(Theme.current.colors.textPrimary)

                            Text("Turn memories into shareable collages")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    Button(action: {
                        withAnimation(.spring(response: Duration.slow, dampingFraction: 0.85)) {
                            showingCollageFlow = true
                        }
                    }) {
                        Text("Start a Collage")
                            .font(Typography.button)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.m)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.m)
                                    .fill(Theme.current.colors.accentPrimary)
                            )
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingCollageFlow) {
                CollageFlowView()
            }
        }
    }
}

#Preview {
    CreateTabView()
}
