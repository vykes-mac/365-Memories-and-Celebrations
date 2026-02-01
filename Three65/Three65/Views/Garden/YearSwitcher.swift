//
//  YearSwitcher.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

/// A compact year selector with previous/next buttons
struct YearSwitcher: View {
    @Binding var selectedYear: Int
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onGoToCurrent: () -> Void

    private let currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        HStack(spacing: Spacing.m) {
            // Previous year button
            Button(action: onPrevious) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.current.colors.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Previous year")

            // Year display with tap to return to current
            Button(action: onGoToCurrent) {
                VStack(spacing: Spacing.xxs) {
                    Text(String(selectedYear))
                        .font(Typography.Title.large)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    if selectedYear != currentYear {
                        Text("Tap for \(currentYear)")
                            .font(Typography.micro)
                            .foregroundStyle(Theme.current.colors.textTertiary)
                    }
                }
            }
            .accessibilityLabel("Year \(selectedYear)")
            .accessibilityHint(selectedYear != currentYear ? "Double tap to return to \(currentYear)" : "")

            // Next year button
            Button(action: onNext) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.current.colors.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Next year")
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var year = 2026

    VStack {
        YearSwitcher(
            selectedYear: $year,
            onPrevious: { year -= 1 },
            onNext: { year += 1 },
            onGoToCurrent: { year = 2026 }
        )
    }
    .padding()
    .background(Theme.current.colors.bgBase)
}
