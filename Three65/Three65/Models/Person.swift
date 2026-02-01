//
//  Person.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Foundation
import SwiftData

/// Represents a person whose moments we want to remember and celebrate
@Model
final class Person {
    /// Unique identifier
    var id: UUID

    /// Person's name
    var name: String

    /// Relationship label (e.g., "Mom", "Best Friend", "Partner")
    var relationship: String

    /// Reference to avatar image (asset name or file path)
    var avatarRef: String?

    /// Additional notes about this person
    var notes: String?

    /// Date the person was created
    var createdAt: Date

    /// Moments associated with this person
    @Relationship(deleteRule: .cascade, inverse: \Moment.person)
    var moments: [Moment]?

    /// Media associated with this person (not specific to a moment)
    @Relationship(deleteRule: .cascade, inverse: \Media.person)
    var media: [Media]?

    init(
        id: UUID = UUID(),
        name: String,
        relationship: String,
        avatarRef: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.avatarRef = avatarRef
        self.notes = notes
        self.createdAt = createdAt
    }
}
