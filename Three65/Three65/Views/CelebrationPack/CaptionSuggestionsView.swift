//
//  CaptionSuggestionsView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData
import UIKit

struct CaptionSuggestionsView: View {
    @EnvironmentObject private var viewModel: CelebrationPackViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var suggestions: [String] = []
    @State private var copiedMessage: String?

    var body: some View {
        NavigationStack {
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

                        VStack(spacing: Spacing.s) {
                            ForEach(suggestions, id: \.self) { suggestion in
                                CaptionRow(text: suggestion) {
                                    copyCaption(suggestion)
                                }
                            }
                        }

                        if let copiedMessage {
                            Text(copiedMessage)
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.accentPrimary)
                        }
                    }
                    .padding(Spacing.screenHorizontal)
                }
            }
            .navigationTitle("Caption Ideas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            generateSuggestions()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Make it personal")
                .font(Typography.Title.large)
                .foregroundStyle(Theme.current.colors.textPrimary)

            Text("Tap a caption to copy it.")
                .font(Typography.caption)
                .foregroundStyle(Theme.current.colors.textSecondary)
        }
    }

    private var context: CaptionSuggestionContext {
        let personName = viewModel.selectedPerson?.name ?? "Someone"
        let relationship = viewModel.selectedPerson?.relationship ?? "Friend"
        let age = computedAgeString()
        return CaptionSuggestionContext(
            name: personName,
            age: age,
            relationship: relationship,
            categoryId: viewModel.selectedMoment?.categoryId
        )
    }

    private func computedAgeString() -> String {
        guard let date = viewModel.selectedMoment?.date else { return "1" }
        let calendar = Calendar.current
        let years = calendar.dateComponents([.year], from: date, to: Date()).year ?? 0
        return String(max(1, abs(years)))
    }

    private func generateSuggestions() {
        let generated = CaptionSuggestionGenerator.suggestions(for: context)
        suggestions = generated

        if let project = viewModel.project {
            project.captionDrafts = generated
            project.modifiedAt = Date()
            do {
                try modelContext.save()
            } catch {
                viewModel.errorMessage = "Failed to save captions: \(error.localizedDescription)"
            }
        }
    }

    private func copyCaption(_ caption: String) {
        UIPasteboard.general.string = caption
        AnalyticsService.shared.track("caption_copied")
        copiedMessage = "Copied to clipboard"
    }
}

private struct CaptionRow: View {
    let text: String
    let onCopy: () -> Void

    var body: some View {
        Button(action: onCopy) {
            GlassCard {
                HStack(spacing: Spacing.s) {
                    Text(text)
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textPrimary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "doc.on.doc")
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                }
                .padding(Spacing.s)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Copy caption")
    }
}

#Preview {
    CaptionSuggestionsView()
        .environmentObject(CelebrationPackViewModel())
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
