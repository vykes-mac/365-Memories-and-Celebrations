//
//  ContactsImportView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData
import Contacts

struct ContactsImportView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var contacts: [BirthdayContact] = []
    @State private var selected: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)

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

                        if authorizationStatus == .authorized {
                            contactsList
                        } else {
                            permissionCard
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(Typography.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(Spacing.screenHorizontal)
                }
            }
            .navigationTitle("Import Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            if authorizationStatus == .authorized {
                loadContacts()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Import birthdays")
                .font(Typography.Title.large)
                .foregroundStyle(Theme.current.colors.textPrimary)

            Text("Select the birthdays you want to remember.")
                .font(Typography.caption)
                .foregroundStyle(Theme.current.colors.textSecondary)
        }
    }

    private var permissionCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Allow contacts access")
                    .font(Typography.Title.medium)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Text("We only read birthday fields to help you plan celebrations.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)

                Button(action: requestAccess) {
                    Text("Allow Access")
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
            .padding(Spacing.s)
        }
    }

    private var contactsList: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if contacts.isEmpty {
                Text("No birthdays found in your contacts.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            } else {
                ForEach(contacts) { contact in
                    Toggle(isOn: bindingForContact(contact)) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(contact.name)
                                .font(Typography.body)
                                .foregroundStyle(Theme.current.colors.textPrimary)

                            Text(birthdayText(contact.birthday))
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Theme.current.colors.accentPrimary))
                    .padding(.vertical, Spacing.xxs)
                }

                Button(action: importSelected) {
                    Text("Import Selected")
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
    }

    private func requestAccess() {
        Task {
            let granted = await ContactsImportService.shared.requestAccess()
            authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
            if granted {
                loadContacts()
            }
        }
    }

    private func loadContacts() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetched = try await ContactsImportService.shared.fetchBirthdayContacts()
                await MainActor.run {
                    contacts = fetched
                    selected = Set(fetched.map { $0.id })
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Unable to load contacts."
                    isLoading = false
                }
            }
        }
    }

    private func importSelected() {
        let calendar = Calendar.current
        var importedCount = 0

        for contact in contacts where selected.contains(contact.id) {
            guard let date = calendar.date(from: normalizedBirthday(contact.birthday)) else { continue }
            let person = fetchOrCreatePerson(name: contact.name)

            let moment = Moment(
                date: date,
                recurring: true,
                categoryId: "birthday",
                title: "\(contact.name)'s Birthday",
                notes: "Imported from Contacts"
            )
            moment.person = person
            modelContext.insert(moment)
            importedCount += 1
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save imported contacts."
        }
    }

    private func fetchOrCreatePerson(name: String) -> Person {
        let descriptor = FetchDescriptor<Person>(predicate: #Predicate { $0.name == name })
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let person = Person(name: name, relationship: "Contact")
        modelContext.insert(person)
        return person
    }

    private func normalizedBirthday(_ birthday: DateComponents) -> DateComponents {
        var components = birthday
        if components.year == nil {
            components.year = Calendar.current.component(.year, from: Date())
        }
        return components
    }

    private func birthdayText(_ birthday: DateComponents) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        if let date = Calendar.current.date(from: normalizedBirthday(birthday)) {
            return formatter.string(from: date)
        }
        return "Birthday"
    }

    private func bindingForContact(_ contact: BirthdayContact) -> Binding<Bool> {
        Binding(
            get: { selected.contains(contact.id) },
            set: { isOn in
                if isOn {
                    selected.insert(contact.id)
                } else {
                    selected.remove(contact.id)
                }
            }
        )
    }
}

#Preview {
    ContactsImportView()
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
