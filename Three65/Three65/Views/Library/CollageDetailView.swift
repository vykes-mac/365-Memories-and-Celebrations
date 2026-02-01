//
//  CollageDetailView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct CollageDetailView: View {
    let project: CollageProject

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var previewImages: [UIImage?] = []
    @State private var showingShare = false
    @State private var shareItems: [Any] = []
    @State private var showingDeleteConfirm = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    CollagePreviewView(template: project.template, images: previewImages)
                        .frame(height: 360)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.m))

                    metadataSection

                    actionSection
                }
                .padding(Spacing.screenHorizontal)
            }
        }
        .navigationTitle("Collage")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
                .accessibilityLabel("Delete collage")
            }
        }
        .sheet(isPresented: $showingShare) {
            ShareSheet(activityItems: shareItems)
        }
        .confirmationDialog("Delete collage?", isPresented: $showingDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deleteProject()
            }
            Button("Cancel", role: .cancel) {}
        }
        .task {
            await loadPreviewImages()
        }
    }

    private var metadataSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text(project.template.displayName)
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Text("\(project.assets.count) items")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)

                Text("Updated \(dateFormatter.string(from: project.modifiedAt))")
                    .font(Typography.micro)
                    .foregroundStyle(Theme.current.colors.textTertiary)
            }
            .padding(Spacing.s)
        }
    }

    private var actionSection: some View {
        VStack(spacing: Spacing.s) {
            Button(action: shareCollage) {
                Text("Share")
                    .font(Typography.button)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .fill(Theme.current.colors.accentPrimary)
                    )
            }

            Button(role: .destructive, action: { showingDeleteConfirm = true }) {
                Text("Delete")
                    .font(Typography.button)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .stroke(Color.red.opacity(0.6), lineWidth: 1)
                    )
            }
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
            targetSize: CGSize(width: 600, height: 600)
        )
    }

    private func shareCollage() {
        if let exportedPath = project.exportedFilePath,
           FileManager.default.fileExists(atPath: exportedPath) {
            shareItems = [URL(fileURLWithPath: exportedPath)]
            showingShare = true
            return
        }

        Task {
            let targetSize = CGSize(width: 1080, height: 1080)
            let images = await PhotoAssetLoader.loadImages(
                localIdentifiers: project.assets,
                targetSize: targetSize
            )
            guard let renderedImage = renderCollageImage(template: project.template, images: images, size: targetSize) else {
                return
            }
            shareItems = [renderedImage]
            showingShare = true
        }
    }

    private func renderCollageImage(template: CollageTemplate, images: [UIImage?], size: CGSize) -> UIImage? {
        let view = CollagePreviewView(template: template, images: images)
            .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        renderer.proposedSize = .init(size)
        return renderer.uiImage
    }

    private func deleteProject() {
        modelContext.delete(project)
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete collage: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CollageDetailView(project: CollageProject(template: .grid))
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
