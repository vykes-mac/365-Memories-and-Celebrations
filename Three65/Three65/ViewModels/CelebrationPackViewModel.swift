//
//  CelebrationPackViewModel.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class CelebrationPackViewModel: BaseViewModel {
    @Published var selectedTemplate: CollageTemplate?
    @Published var selectedAssetIdentifiers: [String] = []
    @Published var selectedPerson: Person?
    @Published var selectedMoment: Moment?
    @Published var project: CollageProject?

    private var didConfigureContext = false

    func configureContext(person: Person?, moment: Moment?) {
        guard !didConfigureContext else { return }
        didConfigureContext = true

        selectedPerson = person ?? moment?.person
        selectedMoment = moment
    }

    func addAssetIdentifiers(_ identifiers: [String]) {
        let set = Set(selectedAssetIdentifiers)
        let newIdentifiers = identifiers.filter { !set.contains($0) }
        if !newIdentifiers.isEmpty {
            selectedAssetIdentifiers.append(contentsOf: newIdentifiers)
        }
    }

    func toggleAssetIdentifier(_ identifier: String) {
        if let index = selectedAssetIdentifiers.firstIndex(of: identifier) {
            selectedAssetIdentifiers.remove(at: index)
        } else {
            selectedAssetIdentifiers.append(identifier)
        }
    }

    func isSelected(_ identifier: String) -> Bool {
        selectedAssetIdentifiers.contains(identifier)
    }

    func saveProject(in context: ModelContext, exportedFilePath: String? = nil, markExported: Bool = false) {
        let template = selectedTemplate ?? .grid
        let now = Date()

        if let project {
            project.template = template
            project.assets = selectedAssetIdentifiers
            project.modifiedAt = now
            if let selectedMoment {
                project.moment = selectedMoment
            }
            if let exportedFilePath {
                project.exportedFilePath = exportedFilePath
            }
            if markExported {
                project.isExported = true
            }
        } else {
            let newProject = CollageProject(
                template: template,
                moment: selectedMoment,
                assets: selectedAssetIdentifiers,
                captionDrafts: [],
                createdAt: now,
                isExported: markExported,
                exportedFilePath: exportedFilePath
            )
            context.insert(newProject)
            project = newProject
        }

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to save collage: \(error.localizedDescription)"
        }
    }
}
