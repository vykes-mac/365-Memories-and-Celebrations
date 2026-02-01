//
//  DotGridView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

/// A single dot representing one day in the garden
struct DayDot: View {
    let day: GardenDay
    let size: CGFloat
    let onTap: () -> Void

    @State private var isPulsing = false
    @State private var isGlowing = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Base dot
                Circle()
                    .fill(baseFillColor)
                    .frame(width: size, height: size)

                // Category ring for event days
                if day.hasEvents {
                    Circle()
                        .strokeBorder(day.primaryCategoryColor ?? Theme.current.colors.accentPrimary, lineWidth: ringWidth)
                        .frame(width: size, height: size)

                    // Multi-event indicator: stacked micro-dots
                    if day.eventCount > 1 {
                        multiEventIndicator
                    }
                }

                // Upcoming glow (events within 7 days)
                if day.isUpcoming && day.hasEvents {
                    Circle()
                        .fill(day.primaryCategoryColor?.opacity(0.3) ?? Theme.current.colors.accentPrimary.opacity(0.3))
                        .frame(width: size + 6, height: size + 6)
                        .blur(radius: isGlowing ? 4 : 2)
                        .opacity(isGlowing ? 0.6 : 0.3)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
                }

                // Today's pulse animation
                if day.isToday {
                    todayIndicator
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view day details")
        .onAppear {
            if day.isToday && !reduceMotion {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            if day.isUpcoming && day.hasEvents && !reduceMotion {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isGlowing = true
                }
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var multiEventIndicator: some View {
        // Show micro-dots for additional events (up to 3 visible)
        let colors = day.categoryColors
        let visibleColors = Array(colors.prefix(3))
        let offsetAmount: CGFloat = size * 0.15

        ForEach(visibleColors.indices, id: \.self) { index in
            Circle()
                .fill(visibleColors[index])
                .frame(width: size * 0.3, height: size * 0.3)
                .offset(
                    x: CGFloat(index - 1) * offsetAmount,
                    y: -size * 0.4
                )
        }
    }

    @ViewBuilder
    private var todayIndicator: some View {
        // Inner filled circle for today
        Circle()
            .fill(Theme.current.colors.accentPrimary)
            .frame(width: size * 0.5, height: size * 0.5)

        // Pulse ring
        if !reduceMotion {
            Circle()
                .stroke(Theme.current.colors.accentPrimary.opacity(isPulsing ? 0.2 : 0.5), lineWidth: 2)
                .frame(width: size + (isPulsing ? 8 : 4), height: size + (isPulsing ? 8 : 4))
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
        }
    }

    // MARK: - Computed Properties

    private var baseFillColor: Color {
        if day.isToday {
            return Theme.current.colors.accentPrimary.opacity(0.15)
        } else if day.hasEvents {
            return Theme.current.colors.glassCardFill
        } else {
            return Theme.current.colors.textTertiary.opacity(0.2)
        }
    }

    private var ringWidth: CGFloat {
        // Stronger ring for multi-event days
        day.eventCount > 1 ? 2 : 1.5
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

/// Grid of 365 dots representing a full year
struct DotGridView: View {
    @ObservedObject var viewModel: GardenViewModel
    let onDayTap: (GardenDay) -> Void

    // Grid configuration
    private let columns = 19 // ~19 columns to fit 365 days in ~19 rows
    private let dotSize: CGFloat = 14
    private let spacing: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - (Spacing.screenHorizontal * 2)
            let calculatedDotSize = calculateDotSize(availableWidth: availableWidth)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(calculatedDotSize), spacing: spacing), count: columns),
                    spacing: spacing
                ) {
                    ForEach(viewModel.days) { day in
                        DayDot(day: day, size: calculatedDotSize) {
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

    private func calculateDotSize(availableWidth: CGFloat) -> CGFloat {
        // Calculate dot size to fit nicely within available width
        let totalSpacing = CGFloat(columns - 1) * spacing
        let maxDotSize = (availableWidth - totalSpacing) / CGFloat(columns)
        return min(maxDotSize, dotSize)
    }
}

// MARK: - Preview

#Preview {
    DotGridView(
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
