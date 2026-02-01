//
//  BaseService.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Foundation

/// Result type for service operations
enum ServiceResult<T> {
    case success(T)
    case failure(ServiceError)
}

/// Common error types for services
enum ServiceError: Error, LocalizedError {
    case notFound
    case invalidData
    case networkError(Error)
    case persistenceError(Error)
    case permissionDenied
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested resource was not found."
        case .invalidData:
            return "The data is invalid or corrupted."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .persistenceError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .permissionDenied:
            return "Permission denied."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

/// Base protocol for all services in the application.
/// Services handle data operations and business logic.
protocol ServiceProtocol {
    /// Unique identifier for the service, useful for logging and debugging
    static var serviceIdentifier: String { get }
}

/// Default implementation for ServiceProtocol
extension ServiceProtocol {
    static var serviceIdentifier: String {
        String(describing: Self.self)
    }
}

/// Base class for services providing common functionality.
/// Inherit from this class for services that need shared utilities.
class BaseService: ServiceProtocol {
    static var serviceIdentifier: String {
        String(describing: Self.self)
    }

    init() {}
}
