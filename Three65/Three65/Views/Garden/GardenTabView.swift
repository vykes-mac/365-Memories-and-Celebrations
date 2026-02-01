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
    @State private var showingAddMoment = false
    @State private var addMomentDate = Date()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Background gradient
                LinearGradient(
                    colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with year switcher and mode toggle
                    HStack {
                        YearSwitcher(
                            selectedYear: $viewModel.selectedYear,
                            onPrevious: viewModel.previousYear,
                            onNext: viewModel.nextYear,
                            onGoToCurrent: viewModel.goToCurrentYear
                        )

                        Spacer()

                        // Display mode toggle
                        DisplayModeToggle(selectedMode: $viewModel.displayMode)
                    }
                    .padding(.horizontal, Spacing.screenHorizontal)

                    // Grid view based on display mode
                    switch viewModel.displayMode {
                    case .dot:
                        DotGridView(viewModel: viewModel) { day in
                            viewModel.selectDay(day)
                        }
                    case .heatmap:
                        HeatmapGridView(viewModel: viewModel) { day in
                            viewModel.selectDay(day)
                        }
                    }
                }

                floatingAddButton
            }
            .navigationTitle("Garden")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showingDayDetail) {
                if let selectedDay = viewModel.selectedDay {
                    DayDetailSheet(
                        day: selectedDay,
                        onDismiss: {
                            viewModel.dismissDayDetail()
                        },
                        onAddMoment: { date in
                            viewModel.dismissDayDetail()
                            presentAddMoment(for: date)
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                }
            }
            .sheet(isPresented: $showingAddMoment) {
                AddMomentFlow(initialDate: addMomentDate) {
                    viewModel.loadDays()
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    private var floatingAddButton: some View {
        Button(action: {
            presentAddMoment(for: Date())
        }) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Theme.current.colors.accentPrimary)
                )
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, Spacing.screenHorizontal)
        .padding(.bottom, Spacing.xl)
        .accessibilityLabel("Add moment")
    }

    private func presentAddMoment(for date: Date) {
        addMomentDate = date
        showingAddMoment = true
    }
}

/// Toggle button to switch between Dot and Heatmap display modes
struct DisplayModeToggle: View {
    @Binding var selectedMode: GardenViewModel.DisplayMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GardenViewModel.DisplayMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.easeInOut(duration: Duration.base)) {
                        selectedMode = mode
                    }
                }) {
                    Image(systemName: mode.iconName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(selectedMode == mode
                            ? Theme.current.colors.accentPrimary
                            : Theme.current.colors.textTertiary)
                        .frame(width: 36, height: 36)
                        .background(
                            selectedMode == mode
                                ? Theme.current.colors.accentPrimary.opacity(0.15)
                                : Color.clear
                        )
                }
                .accessibilityLabel("\(mode.displayName) view")
                .accessibilityAddTraits(selectedMode == mode ? .isSelected : [])
            }
        }
        .background(
            RoundedRectangle(cornerRadius: Radius.s)
                .fill(Theme.current.colors.glassCardFill)
        )
        .clipShape(RoundedRectangle(cornerRadius: Radius.s))
    }
}

// MARK: - DisplayMode Extensions

extension GardenViewModel.DisplayMode {
    var iconName: String {
        switch self {
        case .dot: return "circle.grid.3x3"
        case .heatmap: return "square.grid.3x3"
        }
    }

    var displayName: String {
        switch self {
        case .dot: return "Dot"
        case .heatmap: return "Heatmap"
        }
    }
}

#Preview {
    GardenTabView()
        .modelContainer(for: [Person.self, Moment.self, Category.self, Media.self, CollageProject.self, ReminderSetting.self], inMemory: true)
}
