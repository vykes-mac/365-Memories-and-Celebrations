//
//  CreativeLibraryView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct CreativeLibraryView: View {
    @Query(sort: \CollageProject.modifiedAt, order: .reverse) private var projects: [CollageProject]
    @State private var showingCollageFlow = false

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
                    Text("Creative Library")
                        .font(Typography.Title.large)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    if projects.isEmpty {
                        EmptyLibraryState(onCreate: {
                            withAnimation(.spring(response: Duration.slow, dampingFraction: 0.85)) {
                                showingCollageFlow = true
                            }
                        })
                    } else {
                        LazyVGrid(columns: columns, spacing: Spacing.m) {
                            ForEach(projects, id: \.id) { project in
                                NavigationLink {
                                    CollageDetailView(project: project)
                                } label: {
                                    CollageLibraryCard(project: project)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
        }
        .sheet(isPresented: $showingCollageFlow) {
            CollageFlowView()
        }
    }
}

private struct CollageLibraryCard: View {
    let project: CollageProject
    @State private var previewImages: [UIImage?] = []

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                CollagePreviewView(template: project.template, images: previewImages)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.s))

                Text(project.template.displayName)
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Text("\(project.assets.count) items")
                    .font(Typography.micro)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
            .padding(Spacing.s)
        }
        .task {
            await loadPreviewImages()
        }
    }

    private func loadPreviewImages() async {
        let identifiers = Array(project.assets.prefix(4))
        guard !identifiers.isEmpty else {
            previewImages = []
            return
        }

        previewImages = await PhotoAssetLoader.loadImages(
            localIdentifiers: identifiers,
            targetSize: CGSize(width: 300, height: 300)
        )
    }
}

private struct EmptyLibraryState: View {
    let onCreate: () -> Void

    var body: some View {
        GlassCard {
            VStack(spacing: Spacing.s) {
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(Theme.current.colors.accentPrimary)

                Text("No collages yet")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Text("Create a celebration pack to see it here.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
                    .multilineTextAlignment(.center)

                Button(action: onCreate) {
                    Text("Start a Collage")
                        .font(Typography.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.m)
                        .padding(.vertical, Spacing.xs)
                        .background(
                            Capsule()
                                .fill(Theme.current.colors.accentPrimary)
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.l)
        }
    }
}

#Preview {
    CreativeLibraryView()
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
