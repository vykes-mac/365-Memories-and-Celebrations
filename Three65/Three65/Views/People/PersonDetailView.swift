//
//  PersonDetailView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

/// Detail view for viewing and editing a person
struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var person: Person

    @State private var selectedAvatarItem: PhotosPickerItem?
    @State private var avatarData: Data?
    @State private var showingDeleteConfirm = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.l) {
                    avatarSection
                    mediaSection
                    detailsSection
                    notesSection
                    deleteSection
                }
                .padding(Spacing.screenHorizontal)
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                }
            }
        }
        .alert("Delete Person?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                deletePerson()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the person and all linked moments.")
        }
        .onAppear {
            avatarData = decodeAvatarData()
        }
        .onChange(of: selectedAvatarItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    avatarData = data
                    person.avatarRef = data.base64EncodedString()
                    saveChanges()
                }
            }
        }
    }

    private var avatarSection: some View {
        GlassCard {
            VStack(spacing: Spacing.m) {
                avatarView

                PhotosPicker(selection: $selectedAvatarItem, matching: .images) {
                    Text("Change Photo")
                        .font(Typography.button)
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                }

                if person.avatarRef != nil {
                    Button(role: .destructive) {
                        person.avatarRef = nil
                        avatarData = nil
                        saveChanges()
                    } label: {
                        Text("Remove Photo")
                            .font(Typography.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var detailsSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.m) {
                Text("Details")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                TextField("Name", text: $person.name)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, Spacing.s)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.s)
                            .fill(Theme.current.colors.glassCardFill)
                    )

                TextField("Relationship", text: $person.relationship)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, Spacing.m)
                    .padding(.vertical, Spacing.s)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.s)
                            .fill(Theme.current.colors.glassCardFill)
                    )
            }
        }
    }

    private var mediaSection: some View {
        MediaStrip(
            title: "Media",
            mediaItems: sortedMedia,
            onAdd: addMediaItems,
            onDelete: deleteMedia,
            onMove: moveMedia
        )
    }

    private var notesSection: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.m) {
                Text("Notes")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                ZStack(alignment: .topLeading) {
                    TextEditor(text: notesBinding)
                        .frame(minHeight: 120)
                        .padding(Spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.s)
                                .fill(Theme.current.colors.glassCardFill)
                        )

                    if notesBinding.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Add any notes about this person")
                            .font(Typography.caption)
                            .foregroundStyle(Theme.current.colors.textTertiary)
                            .padding(.horizontal, Spacing.m)
                            .padding(.vertical, Spacing.s)
                    }
                }
            }
        }
    }

    private var deleteSection: some View {
        Button(role: .destructive) {
            showingDeleteConfirm = true
        } label: {
            Text("Delete Person")
                .font(Typography.button)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.s)
        }
        .padding(.horizontal, Spacing.screenHorizontal)
    }

    private var avatarView: some View {
        Group {
            if let data = avatarData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Theme.current.colors.textTertiary)
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Theme.current.colors.glassCardStroke, lineWidth: 1)
        )
    }

    private var notesBinding: Binding<String> {
        Binding(
            get: { person.notes ?? "" },
            set: { person.notes = $0 }
        )
    }

    private func decodeAvatarData() -> Data? {
        guard let avatarRef = person.avatarRef else { return nil }
        return Data(base64Encoded: avatarRef)
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save person changes: \(error.localizedDescription)")
        }
    }

    private func deletePerson() {
        modelContext.delete(person)
        saveChanges()
        dismiss()
    }

    private var sortedMedia: [Media] {
        (person.media ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    private func addMediaItems(_ items: [PhotosPickerItem]) {
        Task {
            let startingOrder = sortedMedia.count
            var order = startingOrder

            for item in items {
                guard let identifier = item.itemIdentifier else { continue }
                let isVideo = item.supportedContentTypes.contains { $0.conforms(to: .movie) }
                let media = Media(
                    person: person,
                    localIdentifier: identifier,
                    type: isVideo ? .video : .photo,
                    sortOrder: order
                )
                modelContext.insert(media)
                order += 1
            }

            saveChanges()
        }
    }

    private func deleteMedia(_ media: Media) {
        modelContext.delete(media)
        saveChanges()
    }

    private func moveMedia(from source: IndexSet, to destination: Int) {
        var items = sortedMedia
        items.move(fromOffsets: source, toOffset: destination)
        for (index, item) in items.enumerated() {
            item.sortOrder = index
        }
        saveChanges()
    }
}

#Preview {
    let person = Person(name: "Jamie Rivera", relationship: "Friend")
    return NavigationStack {
        PersonDetailView(person: person)
    }
}
