//
//  MediaStrip.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import PhotosUI
import Photos
import UIKit

/// Horizontal media strip with add, reorder, and delete support
struct MediaStrip: View {
    let title: String?
    let mediaItems: [Media]
    let onAdd: ([PhotosPickerItem]) -> Void
    let onDelete: (Media) -> Void
    let onMove: (IndexSet, Int) -> Void

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var showingReorder = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            if let title {
                HStack {
                    Text(title)
                        .font(Typography.Title.medium)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    Spacer()

                    if mediaItems.count > 1 {
                        Button("Reorder") {
                            showingReorder = true
                        }
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.s) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .any(of: [.images, .videos])
                    ) {
                        AddMediaTile()
                    }

                    ForEach(mediaItems, id: \.id) { item in
                        MediaThumbnailView(media: item, showDelete: true) {
                            onDelete(item)
                        }
                    }
                }
                .padding(.vertical, Spacing.xxs)
            }
        }
        .sheet(isPresented: $showingReorder) {
            ReorderMediaSheet(items: mediaItems, onMove: onMove)
        }
        .onChange(of: selectedItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            onAdd(newItems)
            selectedItems = []
        }
    }
}

/// Read-only media preview strip without add/delete controls
struct MediaPreviewStrip: View {
    let mediaItems: [Media]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.s) {
                ForEach(mediaItems, id: \.id) { item in
                    MediaThumbnailView(media: item, showDelete: false, onDelete: nil)
                }
            }
            .padding(.vertical, Spacing.xxs)
        }
    }
}

private struct AddMediaTile: View {
    var body: some View {
        RoundedRectangle(cornerRadius: Radius.s)
            .fill(Theme.current.colors.glassCardFill)
            .frame(width: 72, height: 72)
            .overlay(
                VStack(spacing: Spacing.xxs) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Add")
                        .font(Typography.micro)
                }
                .foregroundStyle(Theme.current.colors.textTertiary)
            )
            .accessibilityLabel("Add media")
    }
}

private struct MediaThumbnailView: View {
    let media: Media
    let showDelete: Bool
    let onDelete: (() -> Void)?
    @State private var image: UIImage?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: Radius.s)
                .fill(Theme.current.colors.glassCardFill)
                .frame(width: 72, height: 72)
                .overlay(
                    Group {
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: media.type == .video ? "video.fill" : "photo.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                    }
                )
                .clipped()

            if showDelete, let onDelete {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.current.colors.textSecondary)
                        .background(Circle().fill(Color.white.opacity(0.7)))
                }
                .offset(x: 6, y: -6)
            }
        }
        .task {
            image = await loadThumbnail()
        }
        .accessibilityLabel(media.type == .video ? "Video thumbnail" : "Photo thumbnail")
    }

    private func loadThumbnail() async -> UIImage? {
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [media.localIdentifier], options: nil)
        guard let asset = fetchResult.firstObject else { return nil }

        return await withCheckedContinuation { continuation in
            let targetSize = CGSize(width: 120, height: 120)
            let options = PHImageRequestOptions()
            options.isSynchronous = false
            options.deliveryMode = .opportunistic

            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

private struct ReorderMediaSheet: View {
    let items: [Media]
    let onMove: (IndexSet, Int) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(items, id: \.id) { item in
                    HStack(spacing: Spacing.s) {
                        Image(systemName: item.type == .video ? "video.fill" : "photo.fill")
                            .foregroundStyle(Theme.current.colors.textSecondary)
                        Text(item.localIdentifier.isEmpty ? "Media" : item.localIdentifier)
                            .font(Typography.caption)
                            .lineLimit(1)
                    }
                }
                .onMove(perform: onMove)
            }
            .navigationTitle("Reorder Media")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
        }
    }
}
