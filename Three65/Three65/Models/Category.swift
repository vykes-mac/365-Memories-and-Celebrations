//
//  Category.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Foundation
import SwiftData

/// Represents a category/type of moment (birthday, anniversary, etc.)
@Model
final class Category {
    /// Unique identifier
    var id: String

    /// Display name
    var name: String

    /// Color token name (references ThemeColors.category*)
    var colorToken: String

    /// SF Symbol name for the icon
    var icon: String

    /// Whether this is a system-provided category
    var isSystem: Bool

    /// Display order for sorting
    var sortOrder: Int

    init(
        id: String,
        name: String,
        colorToken: String,
        icon: String,
        isSystem: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorToken = colorToken
        self.icon = icon
        self.isSystem = isSystem
        self.sortOrder = sortOrder
    }
}

// MARK: - Default Categories

extension Category {
    /// Default system categories
    static let defaultCategories: [Category] = [
        Category(
            id: "birthday",
            name: "Birthday",
            colorToken: "categoryBirthday",
            icon: "gift.fill",
            isSystem: true,
            sortOrder: 0
        ),
        Category(
            id: "anniversary",
            name: "Anniversary",
            colorToken: "categoryAnniversary",
            icon: "heart.fill",
            isSystem: true,
            sortOrder: 1
        ),
        Category(
            id: "milestone",
            name: "Milestone",
            colorToken: "categoryMilestone",
            icon: "star.fill",
            isSystem: true,
            sortOrder: 2
        ),
        Category(
            id: "memorial",
            name: "Memorial",
            colorToken: "categoryMemorial",
            icon: "leaf.fill",
            isSystem: true,
            sortOrder: 3
        ),
        Category(
            id: "justBecause",
            name: "Just Because",
            colorToken: "categoryJustBecause",
            icon: "sparkles",
            isSystem: true,
            sortOrder: 4
        )
    ]

    /// Seed the database with default categories if they don't exist
    @MainActor
    static func seedDefaultCategories(in context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Category>(
            predicate: #Predicate { $0.isSystem == true }
        )

        do {
            let existingCategories = try context.fetch(fetchDescriptor)
            let existingIds = Set(existingCategories.map { $0.id })

            for category in defaultCategories {
                if !existingIds.contains(category.id) {
                    context.insert(category)
                }
            }
        } catch {
            // If fetch fails, insert all defaults
            for category in defaultCategories {
                context.insert(category)
            }
        }
    }
}
