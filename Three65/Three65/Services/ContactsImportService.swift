//
//  ContactsImportService.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import Contacts
import Foundation

struct BirthdayContact: Identifiable, Hashable {
    let id: String
    let name: String
    let birthday: DateComponents
}

final class ContactsImportService {
    static let shared = ContactsImportService()

    private let store = CNContactStore()

    private init() {}

    func requestAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            store.requestAccess(for: .contacts) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    func fetchBirthdayContacts() async throws -> [BirthdayContact] {
        let keys: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor
        ]

        let request = CNContactFetchRequest(keysToFetch: keys)
        var results: [BirthdayContact] = []

        try store.enumerateContacts(with: request) { contact, _ in
            guard let birthday = contact.birthday else { return }
            let fullName = [contact.givenName, contact.familyName]
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            let name = fullName.isEmpty ? "Unknown" : fullName
            results.append(BirthdayContact(id: contact.identifier, name: name, birthday: birthday))
        }

        return results.sorted { $0.name < $1.name }
    }
}
