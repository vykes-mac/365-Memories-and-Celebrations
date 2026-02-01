//
//  CollageEditorView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct CollageEditorView: View {
    @EnvironmentObject private var viewModel: CelebrationPackViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var previewImages: [UIImage?] = []
    @State private var exportFormat: CollageExportFormat = .square
    @State private var showingShare = false
    @State private var shareItems: [Any] = []

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
                    previewSection

                    formatSection

                    actionSection

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(Typography.caption)
                            .foregroundStyle(.red)
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
        }
        .navigationTitle("Collage")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShare) {
            ShareSheet(activityItems: shareItems)
        }
        .task {
            await loadPreviewImages()
        }
        .onChange(of: viewModel.selectedAssetIdentifiers) { _, _ in
            Task { await loadPreviewImages() }
        }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Preview")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            CollagePreviewView(
                template: viewModel.selectedTemplate ?? .grid,
                images: previewImages
            )
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: Radius.m))
        }
    }

    private var formatSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Export format")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            Picker("Export format", selection: $exportFormat) {
                ForEach(CollageExportFormat.allCases, id: \.self) { format in
                    Text(format.displayName).tag(format)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var actionSection: some View {
        VStack(spacing: Spacing.s) {
            Button(action: saveToLibrary) {
                Text("Save to Library")
                    .font(Typography.button)
                    .foregroundStyle(Theme.current.colors.accentPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.m)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .stroke(Theme.current.colors.accentPrimary, lineWidth: 1)
                    )
            }

            Button(action: exportCollage) {
                Text("Export")
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
    }

    private func saveToLibrary() {
        viewModel.saveProject(in: modelContext)
    }

    private func exportCollage() {
        Task {
            let identifiers = viewModel.selectedAssetIdentifiers
            let template = viewModel.selectedTemplate ?? .grid
            let targetSize = exportFormat.size

            let images = await PhotoAssetLoader.loadImages(localIdentifiers: identifiers, targetSize: targetSize)
            guard let renderedImage = renderCollageImage(template: template, images: images, size: targetSize) else {
                viewModel.errorMessage = "Failed to render collage image."
                return
            }

            let exportURL = saveExportedImage(renderedImage)
            viewModel.saveProject(in: modelContext, exportedFilePath: exportURL?.path, markExported: true)
            AnalyticsService.shared.track("celebration_pack_exported")

            shareItems = exportURL.map { [$0] } ?? [renderedImage]
            showingShare = true
        }
    }

    private func loadPreviewImages() async {
        let identifiers = viewModel.selectedAssetIdentifiers
        guard !identifiers.isEmpty else {
            previewImages = []
            return
        }

        let images = await PhotoAssetLoader.loadImages(
            localIdentifiers: identifiers,
            targetSize: CGSize(width: 600, height: 600)
        )
        previewImages = images
    }

    private func renderCollageImage(template: CollageTemplate, images: [UIImage?], size: CGSize) -> UIImage? {
        let view = CollagePreviewView(template: template, images: images)
            .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        renderer.proposedSize = .init(size)
        return renderer.uiImage
    }

    private func saveExportedImage(_ image: UIImage) -> URL? {
        let filename = "collage-\(UUID().uuidString).png"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
        guard let url, let data = image.pngData() else { return nil }

        do {
            try data.write(to: url)
            return url
        } catch {
            viewModel.errorMessage = "Failed to save export: \(error.localizedDescription)"
            return nil
        }
    }
}

enum CollageExportFormat: String, CaseIterable {
    case square
    case story

    var displayName: String {
        switch self {
        case .square: return "Square"
        case .story: return "Story"
        }
    }

    var size: CGSize {
        switch self {
        case .square:
            return CGSize(width: 1080, height: 1080)
        case .story:
            return CGSize(width: 1080, height: 1920)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CollageEditorView()
        .environmentObject(CelebrationPackViewModel())
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
