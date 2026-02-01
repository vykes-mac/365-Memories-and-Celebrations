//
//  CollageFlowView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import SwiftData

struct CollageFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CelebrationPackViewModel()
    @State private var didTrackStart = false

    let person: Person?
    let moment: Moment?

    init(person: Person? = nil, moment: Moment? = nil) {
        self.person = person
        self.moment = moment
    }

    var body: some View {
        NavigationStack {
            TemplatePickerView()
                .environmentObject(viewModel)
                .navigationTitle("Templates")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
        .onAppear {
            viewModel.configureContext(person: person, moment: moment)
            trackStartIfNeeded()
        }
    }

    private func trackStartIfNeeded() {
        guard !didTrackStart else { return }
        didTrackStart = true
        AnalyticsService.shared.track("celebration_pack_started")
    }
}

#Preview {
    CollageFlowView(person: Person(name: "Mom", relationship: "Mother"))
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
