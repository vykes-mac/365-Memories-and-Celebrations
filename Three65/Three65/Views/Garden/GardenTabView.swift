//
//  GardenTabView.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI
import SwiftData

/// Garden tab - 365 year-at-a-glance view
struct GardenTabView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GardenViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Year switcher header
                    YearSwitcher(
                        selectedYear: $viewModel.selectedYear,
                        onPrevious: viewModel.previousYear,
                        onNext: viewModel.nextYear,
                        onGoToCurrent: viewModel.goToCurrentYear
                    )
                    .padding(.horizontal, Spacing.screenHorizontal)

                    // Dot grid
                    DotGridView(viewModel: viewModel) { day in
                        viewModel.selectDay(day)
                    }
                }
            }
            .navigationTitle("Garden")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showingDayDetail) {
                if let selectedDay = viewModel.selectedDay {
                    DayDetailSheet(day: selectedDay) {
                        viewModel.dismissDayDetail()
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}

#Preview {
    GardenTabView()
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
