//
//  CaptionSuggestionGenerator.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import Foundation

struct CaptionSuggestionContext {
    let name: String
    let age: String
    let relationship: String
    let categoryId: String?
}

enum CaptionSuggestionGenerator {
    private static let templatesByCategory: [String: [String]] = [
        "birthday": [
            "Happy {Age}th, {Name}! So grateful for my {Relationship}.",
            "Cheers to {Name} and {Age} amazing years. Love you, {Relationship}!",
            "{Name}, {Age} looks good on you. Proud to celebrate my {Relationship}.",
            "Sending all the love to {Name} on their {Age}th. My favorite {Relationship}."
        ],
        "anniversary": [
            "{Age} years of you, {Name}. Lucky to have my {Relationship}.",
            "Celebrating {Name} and {Age} beautiful years. Love you, {Relationship}.",
            "Another year, another memory with {Name}. {Age} years strong, {Relationship}.",
            "Here’s to {Age} years of {Name}. Forever grateful for my {Relationship}."
        ],
        "milestone": [
            "Big {Age} moment for {Name}! So proud of my {Relationship}.",
            "{Name} hit {Age} and I’m cheering for my {Relationship}.",
            "Celebrating {Name} at {Age}. You inspire me, {Relationship}.",
            "{Age} and thriving, {Name}. Love my {Relationship} to bits."
        ],
        "memorial": [
            "Thinking of {Name} today. {Age} beautiful years, my {Relationship}.",
            "Holding {Name} close. {Age} memories with my {Relationship}.",
            "Forever grateful for {Name}. {Age} years of love, {Relationship}.",
            "Remembering {Name} and {Age} cherished years. My {Relationship}, always."
        ],
        "justBecause": [
            "Just because: {Name}, you’re everything to my {Relationship} heart at {Age}.",
            "Thinking of {Name} today. {Age} reasons to love my {Relationship}.",
            "No reason needed to celebrate {Name}. {Age} smiles with my {Relationship}.",
            "Grateful for {Name} and {Age} sweet moments, {Relationship}."
        ],
        "default": [
            "Celebrating {Name} and {Age} wonderful years. My {Relationship} forever.",
            "{Name} at {Age} is a whole vibe. Love my {Relationship}.",
            "Today is for {Name}. {Age} reasons to be thankful for my {Relationship}.",
            "Here’s to {Name} and {Age} beautiful memories, {Relationship}."
        ]
    ]

    static func suggestions(for context: CaptionSuggestionContext) -> [String] {
        let key = context.categoryId ?? "default"
        let templates = templatesByCategory[key] ?? templatesByCategory["default"] ?? []

        return templates.map { template in
            template
                .replacingOccurrences(of: "{Name}", with: context.name)
                .replacingOccurrences(of: "{Age}", with: context.age)
                .replacingOccurrences(of: "{Relationship}", with: context.relationship)
        }
    }
}
