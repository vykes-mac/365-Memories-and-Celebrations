//
//  Media.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Foundation
import SwiftData

/// Type of media asset
enum MediaType: String, Codable {
    case photo
    case video
}

/// Represents a media asset (photo or video) attached to a person or moment
@Model
final class Media {
    /// Unique identifier
    var id: UUID

    /// Associated person (if attached to a person, not a specific moment)
    var person: Person?

    /// Associated moment (if attached to a specific moment)
    var moment: Moment?

    /// Local identifier from Photos library (PHAsset.localIdentifier)
    var localIdentifier: String

    /// Type of media (photo or video)
    var typeRawValue: String

    /// Date the media was added to the app
    var createdAt: Date

    /// Display order within the collection
    var sortOrder: Int

    /// Computed property for MediaType
    var type: MediaType {
        get { MediaType(rawValue: typeRawValue) ?? .photo }
        set { typeRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        person: Person? = nil,
        moment: Moment? = nil,
        localIdentifier: String,
        type: MediaType,
        createdAt: Date = Date(),
        sortOrder: Int = 0
    ) {
        self.id = id
        self.person = person
        self.moment = moment
        self.localIdentifier = localIdentifier
        self.typeRawValue = type.rawValue
        self.createdAt = createdAt
        self.sortOrder = sortOrder
    }
}
