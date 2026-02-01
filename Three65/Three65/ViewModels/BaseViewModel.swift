//
//  BaseViewModel.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import Foundation
import Combine

/// Base protocol for all ViewModels in the application.
/// Provides a common interface for observable state management.
@MainActor
protocol ViewModelProtocol: ObservableObject {
    /// Called when the view appears. Use for initial data loading.
    func onAppear()

    /// Called when the view disappears. Use for cleanup.
    func onDisappear()
}

/// Default implementations for ViewModelProtocol
extension ViewModelProtocol {
    func onAppear() {}
    func onDisappear() {}
}

/// Base class for ViewModels providing common functionality.
/// Inherit from this class to get cancellable storage and loading state management.
@MainActor
class BaseViewModel: ObservableObject, ViewModelProtocol {
    /// Storage for Combine subscriptions
    var cancellables = Set<AnyCancellable>()

    /// Indicates whether the view model is currently loading data
    @Published var isLoading = false

    /// Optional error message to display to the user
    @Published var errorMessage: String?

    init() {}

    func onAppear() {
        // Override in subclasses for initial data loading
    }

    func onDisappear() {
        // Override in subclasses for cleanup
    }

    /// Clears any displayed error message
    func clearError() {
        errorMessage = nil
    }
}
