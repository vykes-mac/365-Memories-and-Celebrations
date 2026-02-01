//
//  AddMomentFlow.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData

/// Multi-step flow for creating a new moment
struct AddMomentFlow: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let onSave: (() -> Void)?

    @State private var step: Step = .person
    @State private var name: String = ""
    @State private var relationship: String = ""
    @State private var date: Date
    @State private var isRecurring: Bool = true
    @State private var selectedCategoryId: String? = nil
    @State private var customCategoryName: String = ""
    @State private var notes: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""

    init(initialDate: Date = Date(), initialName: String? = nil, initialRelationship: String? = nil, onSave: (() -> Void)? = nil) {
        self.onSave = onSave
        _date = State(initialValue: initialDate)
        _name = State(initialValue: initialName ?? "")
        _relationship = State(initialValue: initialRelationship ?? "")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: Spacing.l) {
                stepHeader

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Spacing.l) {
                        stepContent
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, Spacing.s)
                }

                navigationControls
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.top, Spacing.m)
            .padding(.bottom, Spacing.xl)
            .background(
                LinearGradient(
                    colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Add Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Unable to Save", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Step Content

    private var stepHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(step.title)
                .font(Typography.Title.large)
                .foregroundStyle(Theme.current.colors.textPrimary)

            Text("Step \(step.index) of \(Step.allCases.count)")
                .font(Typography.caption)
                .foregroundStyle(Theme.current.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .person:
            personStep
        case .date:
            dateStep
        case .category:
            categoryStep
        case .notes:
            notesStep
        }
    }

    private var personStep: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            inputField(title: "Name", text: $name, placeholder: "e.g. Maria")

            suggestionRow(title: "Name suggestions", items: ["Mom", "Dad", "Best Friend", "Partner"]) { name = $0 }

            inputField(title: "Relationship", text: $relationship, placeholder: "e.g. Sister")

            suggestionRow(
                title: "Relationship suggestions",
                items: ["Mother", "Father", "Partner", "Friend", "Grandparent"]
            ) { relationship = $0 }
        }
    }

    private var dateStep: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Date")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                DatePicker("Moment Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }

            Toggle("Repeats yearly", isOn: $isRecurring)
                .font(Typography.body)
                .tint(Theme.current.colors.accentPrimary)
        }
    }

    private var categoryStep: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Category")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.s) {
                ForEach(categoryOptions) { option in
                    CategoryOptionButton(
                        option: option,
                        isSelected: selectedCategoryId == option.id
                    ) {
                        selectedCategoryId = option.id
                    }
                }
            }

            if selectedCategoryId == "custom" {
                inputField(title: "Custom category", text: $customCategoryName, placeholder: "e.g. Graduation")
            }
        }
    }

    private var notesStep: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Notes")
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $notes)
                    .frame(minHeight: 140)
                    .padding(Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.s)
                            .fill(Theme.current.colors.glassCardFill)
                    )

                if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Add a thoughtful note (optional)")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textTertiary)
                        .padding(.horizontal, Spacing.m)
                        .padding(.vertical, Spacing.s)
                }
            }
        }
    }

    private var navigationControls: some View {
        HStack(spacing: Spacing.s) {
            Button(action: previousStep) {
                Text("Back")
                    .font(Typography.button)
                    .foregroundStyle(Theme.current.colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.s)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .fill(Theme.current.colors.glassCardFill)
                    )
            }
            .disabled(step == .person)
            .opacity(step == .person ? 0.5 : 1)

            Button(action: nextStep) {
                Text(step == .notes ? "Save" : "Next")
                    .font(Typography.button)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.s)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .fill(Theme.current.colors.accentPrimary)
                    )
            }
            .disabled(!canProceed)
            .opacity(canProceed ? 1 : 0.5)
        }
    }

    // MARK: - Helpers

    private func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(title)
                .font(Typography.Title.medium)
                .foregroundStyle(Theme.current.colors.textPrimary)

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .padding(.horizontal, Spacing.m)
                .padding(.vertical, Spacing.s)
                .background(
                    RoundedRectangle(cornerRadius: Radius.s)
                        .fill(Theme.current.colors.glassCardFill)
                )
        }
    }

    private func suggestionRow(title: String, items: [String], action: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(Typography.caption)
                .foregroundStyle(Theme.current.colors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(items, id: \.self) { item in
                        Button(action: { action(item) }) {
                            Text(item)
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textPrimary)
                                .padding(.horizontal, Spacing.s)
                                .padding(.vertical, Spacing.xxs)
                                .background(
                                    Capsule()
                                        .fill(Theme.current.colors.glassCardFill)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var canProceed: Bool {
        switch step {
        case .person:
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !relationship.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .date:
            return true
        case .category:
            if selectedCategoryId == "custom" {
                return !customCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return selectedCategoryId != nil
        case .notes:
            return true
        }
    }

    private func nextStep() {
        if step == .notes {
            saveMoment()
            return
        }

        if let next = step.next {
            step = next
        }
    }

    private func previousStep() {
        if let previous = step.previous {
            step = previous
        }
    }

    private func saveMoment() {
        do {
            let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedRelationship = relationship.trimmingCharacters(in: .whitespacesAndNewlines)
            let person = fetchOrCreatePerson(name: trimmedName, relationship: trimmedRelationship)

            let categoryId = selectedCategoryId ?? "justBecause"
            let title = momentTitle(for: categoryId, name: trimmedName)
            let resolvedNotes = normalizedNotes(for: categoryId)

            let moment = Moment(
                date: date,
                recurring: isRecurring,
                categoryId: categoryId,
                title: title,
                notes: resolvedNotes
            )
            moment.person = person

            modelContext.insert(moment)
            try modelContext.save()

            AnalyticsService.shared.track("moment_created")
            onSave?()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }

    private func fetchOrCreatePerson(name: String, relationship: String) -> Person {
        let descriptor = FetchDescriptor<Person>(
            predicate: #Predicate { $0.name == name && $0.relationship == relationship }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        let person = Person(name: name, relationship: relationship)
        modelContext.insert(person)
        return person
    }

    private func momentTitle(for categoryId: String, name: String) -> String {
        if categoryId == "custom" {
            let customName = customCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !customName.isEmpty {
                return "\(name)'s \(customName)"
            }
        }

        let categoryName = categoryOptions.first { $0.id == categoryId }?.name ?? "Moment"
        if categoryId == "justBecause" {
            return "Just Because"
        }
        return "\(name)'s \(categoryName)"
    }

    private func normalizedNotes(for categoryId: String) -> String? {
        var noteLines: [String] = []
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if categoryId == "custom" {
            let customName = customCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
            if !customName.isEmpty {
                noteLines.append("Category: \(customName)")
            }
        }

        if !trimmedNotes.isEmpty {
            noteLines.append(trimmedNotes)
        }

        return noteLines.isEmpty ? nil : noteLines.joined(separator: "\n")
    }

    private var categoryOptions: [CategoryOption] {
        [
            CategoryOption(id: "birthday", name: "Birthday", color: ThemeColors.categoryBirthday, icon: "gift.fill"),
            CategoryOption(id: "anniversary", name: "Anniversary", color: ThemeColors.categoryAnniversary, icon: "heart.fill"),
            CategoryOption(id: "milestone", name: "Milestone", color: ThemeColors.categoryMilestone, icon: "flag.fill"),
            CategoryOption(id: "memorial", name: "Memorial", color: ThemeColors.categoryMemorial, icon: "leaf.fill"),
            CategoryOption(id: "justBecause", name: "Just Because", color: ThemeColors.categoryJustBecause, icon: "sparkles"),
            CategoryOption(id: "custom", name: "Custom", color: Theme.current.colors.accentPrimary, icon: "pencil")
        ]
    }
}

// MARK: - Step Definition

private enum Step: Int, CaseIterable {
    case person
    case date
    case category
    case notes

    var title: String {
        switch self {
        case .person: return "Who is this for?"
        case .date: return "When is it?"
        case .category: return "What kind of moment?"
        case .notes: return "Add a note"
        }
    }

    var index: Int {
        rawValue + 1
    }

    var next: Step? {
        Step(rawValue: rawValue + 1)
    }

    var previous: Step? {
        Step(rawValue: rawValue - 1)
    }
}

// MARK: - Category Options

private struct CategoryOption: Identifiable {
    let id: String
    let name: String
    let color: Color
    let icon: String
}

private struct CategoryOptionButton: View {
    let option: CategoryOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.s) {
                Circle()
                    .fill(option.color)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(option.name)
                        .font(Typography.body)
                    Image(systemName: option.icon)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.current.colors.textTertiary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Theme.current.colors.accentPrimary)
                }
            }
            .padding(.horizontal, Spacing.s)
            .padding(.vertical, Spacing.s)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Radius.s)
                    .fill(Theme.current.colors.glassCardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.s)
                    .stroke(
                        isSelected ? Theme.current.colors.accentPrimary : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(option.name)
    }
}

#Preview {
    AddMomentFlow()
}
