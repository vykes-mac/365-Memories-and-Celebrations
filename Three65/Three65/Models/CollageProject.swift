//
//  CollageProject.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Foundation
import SwiftData

/// Template types for collage generation
enum CollageTemplate: String, Codable, CaseIterable {
    case polaroid = "polaroid"
    case grid = "grid"
    case filmStrip = "filmStrip"
    case thenAndNow = "thenAndNow"

    var displayName: String {
        switch self {
        case .polaroid: return "Polaroid"
        case .grid: return "Grid"
        case .filmStrip: return "Film Strip"
        case .thenAndNow: return "Then & Now"
        }
    }
}

/// Represents a collage project for a celebration pack
@Model
final class CollageProject {
    /// Unique identifier
    var id: UUID

    /// Template used for this collage
    var templateId: String

    /// Associated moment (optional)
    var moment: Moment?

    /// Asset local identifiers used in the collage (stored as JSON array)
    var assetsJSON: String

    /// Caption drafts (stored as JSON array)
    var captionDraftsJSON: String

    /// Date the project was created
    var createdAt: Date

    /// Date the project was last modified
    var modifiedAt: Date

    /// Whether the project has been exported
    var isExported: Bool

    /// Path to exported file (if exported)
    var exportedFilePath: String?

    /// Computed property for template
    var template: CollageTemplate {
        get { CollageTemplate(rawValue: templateId) ?? .grid }
        set { templateId = newValue.rawValue }
    }

    /// Computed property for assets array
    var assets: [String] {
        get {
            guard let data = assetsJSON.data(using: .utf8),
                  let array = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return array
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                assetsJSON = string
            }
        }
    }

    /// Computed property for caption drafts array
    var captionDrafts: [String] {
        get {
            guard let data = captionDraftsJSON.data(using: .utf8),
                  let array = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return array
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let string = String(data: data, encoding: .utf8) {
                captionDraftsJSON = string
            }
        }
    }

    init(
        id: UUID = UUID(),
        template: CollageTemplate,
        moment: Moment? = nil,
        assets: [String] = [],
        captionDrafts: [String] = [],
        createdAt: Date = Date(),
        isExported: Bool = false,
        exportedFilePath: String? = nil
    ) {
        self.id = id
        self.templateId = template.rawValue
        self.moment = moment
        self.createdAt = createdAt
        self.modifiedAt = createdAt
        self.isExported = isExported
        self.exportedFilePath = exportedFilePath

        // Initialize JSON strings
        if let data = try? JSONEncoder().encode(assets),
           let string = String(data: data, encoding: .utf8) {
            self.assetsJSON = string
        } else {
            self.assetsJSON = "[]"
        }

        if let data = try? JSONEncoder().encode(captionDrafts),
           let string = String(data: data, encoding: .utf8) {
            self.captionDraftsJSON = string
        } else {
            self.captionDraftsJSON = "[]"
        }
    }
}
