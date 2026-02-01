//
//  AnalyticsService.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import Foundation

/// Minimal analytics service for tracking events
final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    func track(_ event: String, properties: [String: String]? = nil) {
        var message = "[Analytics] \(event)"
        if let properties, !properties.isEmpty {
            message += " \(properties)"
        }
        print(message)
    }
}
