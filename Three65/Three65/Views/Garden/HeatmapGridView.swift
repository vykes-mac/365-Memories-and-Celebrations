//
//  HeatmapGridView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

/// A single cell in the heatmap representing one day
struct HeatmapCell: View {
    let day: GardenDay
    let size: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(fillColor)
                .frame(width: size, height: size)
                .overlay(
                    // Today indicator
                    day.isToday ?
                    RoundedRectangle(cornerRadius: size * 0.2)
                        .strokeBorder(Theme.current.colors.accentPrimary, lineWidth: 2)
                    : nil
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view day details")
    }

    // MARK: - Computed Properties

    /// Color based on intensity level (number of moments)
    private var fillColor: Color {
        switch day.eventCount {
        case 0:
            return Theme.current.colors.textTertiary.opacity(0.15)
        case 1:
            return intensity(level: 1)
        case 2:
            return intensity(level: 2)
        case 3:
            return intensity(level: 3)
        default: // 4+
            return intensity(level: 4)
        }
    }

    /// Returns color with opacity based on intensity level (1-4)
    private func intensity(level: Int) -> Color {
        let baseColor = day.primaryCategoryColor ?? Theme.current.colors.accentPrimary
        switch level {
        case 1: return baseColor.opacity(0.3)
        case 2: return baseColor.opacity(0.5)
        case 3: return baseColor.opacity(0.7)
        default: return baseColor.opacity(0.9)
        }
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long

        var label = formatter.string(from: day.date)

        if day.isToday {
            label = "Today, \(label)"
        }

        if day.hasEvents {
            label += ", \(day.eventCount) event\(day.eventCount > 1 ? "s" : "")"
        }

        return label
    }
}

/// Heatmap grid showing moment density across the year
struct HeatmapGridView: View {
    @ObservedObject var viewModel: GardenViewModel
    let onDayTap: (GardenDay) -> Void

    // Grid configuration - matches dot grid columns
    private let columns = 19
    private let minCellSize: CGFloat = 6
    private let maxCellSize: CGFloat = 10
    private let spacing: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - (Spacing.screenHorizontal * 2)
            let calculatedCellSize = calculateCellSize(availableWidth: availableWidth)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(calculatedCellSize), spacing: spacing), count: columns),
                    spacing: spacing
                ) {
                    ForEach(viewModel.days) { day in
                        HeatmapCell(day: day, size: calculatedCellSize) {
                            onDayTap(day)
                        }
                    }
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.vertical, Spacing.m)
            }
        }
    }

    // MARK: - Helper Methods

    private func calculateCellSize(availableWidth: CGFloat) -> CGFloat {
        // Calculate cell size to fit nicely within available width
        let totalSpacing = CGFloat(columns - 1) * spacing
        let computedSize = (availableWidth - totalSpacing) / CGFloat(columns)
        return min(max(computedSize, minCellSize), maxCellSize)
    }
}

// MARK: - Preview

#Preview {
    HeatmapGridView(
        viewModel: GardenViewModel(),
        onDayTap: { _ in }
    )
    .background(
        LinearGradient(
            colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
