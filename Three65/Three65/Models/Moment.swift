//
//  Moment.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Foundation
import SwiftData

/// Represents a significant moment or event to celebrate
@Model
final class Moment {
    /// Unique identifier
    var id: UUID

    /// The person this moment is for
    var person: Person?

    /// The date of this moment
    var date: Date

    /// Whether this moment recurs yearly
    var recurring: Bool

    /// The category of this moment (stored as raw value for simplicity)
    var categoryId: String

    /// Title for the moment
    var title: String

    /// Additional notes about this moment
    var notes: String?

    /// Date the moment was created
    var createdAt: Date

    /// Media attached to this specific moment
    @Relationship(deleteRule: .cascade, inverse: \Media.moment)
    var media: [Media]?

    /// Collage projects created for this moment
    @Relationship(deleteRule: .nullify, inverse: \CollageProject.moment)
    var collageProjects: [CollageProject]?

    init(
        id: UUID = UUID(),
        person: Person? = nil,
        date: Date,
        recurring: Bool = true,
        categoryId: String,
        title: String,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.person = person
        self.date = date
        self.recurring = recurring
        self.categoryId = categoryId
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
    }
}
