//
//  PhotoSelectionView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import PhotosUI
import SwiftData
import UIKit

struct PhotoSelectionView: View {
    @EnvironmentObject private var viewModel: CelebrationPackViewModel
    @Query(sort: \Person.name, order: .forward) private var people: [Person]

    @State private var selectedItems: [PhotosPickerItem] = []

    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

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
                    header

                    if viewModel.selectedPerson == nil {
                        personPicker
                    }

                    personMediaSection

                    libraryPickerSection

                    selectedAssetsSection

                    NavigationLink {
                        CollageEditorView()
                            .environmentObject(viewModel)
                    } label: {
                        Text("Continue")
                            .font(Typography.button)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.m)
                            .background(
                                RoundedRectangle(cornerRadius: Radius.m)
                                    .fill(Theme.current.colors.accentPrimary)
                            )
                    }
                    .disabled(viewModel.selectedAssetIdentifiers.isEmpty)
                    .opacity(viewModel.selectedAssetIdentifiers.isEmpty ? 0.5 : 1)
                }
                .padding(Spacing.screenHorizontal)
            }
        }
        .navigationTitle("Select Photos")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            let identifiers = newItems.compactMap { $0.itemIdentifier }
            viewModel.addAssetIdentifiers(identifiers)
            selectedItems = []
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Pick your photos")
                .font(Typography.Title.large)
                .foregroundStyle(Theme.current.colors.textPrimary)

            if let template = viewModel.selectedTemplate {
                Text("Template: \(template.displayName)")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
        }
    }

    private var personPicker: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Choose a person (optional)")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            if people.isEmpty {
                Text("No people saved yet")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.s) {
                        ForEach(people, id: \.id) { person in
                            Button(action: {
                                viewModel.selectedPerson = person
                            }) {
                                PersonSelectionCard(person: person)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var personMediaSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                Text("Person media")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Spacer()

                if let person = viewModel.selectedPerson {
                    Text(person.name)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }
            }

            let mediaItems = viewModel.selectedPerson?.media ?? []

            if mediaItems.isEmpty {
                Text("Attach media to a person to see it here")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            } else {
                LazyVGrid(columns: gridColumns, spacing: Spacing.s) {
                    ForEach(mediaItems.sorted { $0.sortOrder < $1.sortOrder }, id: \.id) { media in
                        SelectableMediaTile(
                            identifier: media.localIdentifier,
                            isSelected: viewModel.isSelected(media.localIdentifier),
                            onTap: { viewModel.toggleAssetIdentifier(media.localIdentifier) }
                        )
                    }
                }
            }
        }
    }

    private var libraryPickerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Photo library")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: 12,
                matching: .any(of: [.images, .videos])
            ) {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Choose from library")
                        .font(Typography.caption)
                }
                .foregroundStyle(Theme.current.colors.accentPrimary)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.s)
                .background(
                    RoundedRectangle(cornerRadius: Radius.m)
                        .fill(Theme.current.colors.accentPrimary.opacity(0.12))
                )
            }
        }
    }

    private var selectedAssetsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            HStack {
                Text("Selected")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Spacer()

                Text("\(viewModel.selectedAssetIdentifiers.count) items")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }

            if viewModel.selectedAssetIdentifiers.isEmpty {
                Text("Select at least one photo to continue")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.s) {
                        ForEach(viewModel.selectedAssetIdentifiers, id: \.self) { identifier in
                            SelectableMediaTile(
                                identifier: identifier,
                                isSelected: true,
                                onTap: { viewModel.toggleAssetIdentifier(identifier) }
                            )
                            .frame(width: 72, height: 72)
                        }
                    }
                }
            }
        }
    }
}

private struct PersonSelectionCard: View {
    let person: Person

    var body: some View {
        GlassCard {
            VStack(spacing: Spacing.xs) {
                Circle()
                    .fill(Theme.current.colors.glassCardFill)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(String(person.name.prefix(1)))
                            .font(Typography.Title.medium)
                            .foregroundStyle(Theme.current.colors.textPrimary)
                    )

                Text(person.name)
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textPrimary)
            }
            .padding(Spacing.s)
        }
        .frame(width: 110)
    }
}

private struct SelectableMediaTile: View {
    let identifier: String
    let isSelected: Bool
    let onTap: () -> Void

    @State private var image: UIImage?

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: Radius.s)
                    .fill(Theme.current.colors.glassCardFill)
                    .overlay(
                        Group {
                            if let image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 18))
                                    .foregroundStyle(Theme.current.colors.textSecondary)
                            }
                        }
                    )
                    .clipped()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                        .background(Circle().fill(Color.white.opacity(0.7)))
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(width: 96, height: 96)
        .task {
            image = await PhotoAssetLoader.loadImage(localIdentifier: identifier, targetSize: CGSize(width: 200, height: 200))
        }
        .accessibilityLabel(isSelected ? "Selected photo" : "Photo")
    }
}

#Preview {
    PhotoSelectionView()
        .environmentObject(CelebrationPackViewModel())
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
