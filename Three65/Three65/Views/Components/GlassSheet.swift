//
//  GlassSheet.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Glass sheet view modifier for bottom sheets and modals
/// Applies blur 28-40, fill rgba(255,255,255,0.72), and stroke
struct GlassSheetModifier: ViewModifier {
    var cornerRadius: CGFloat = Radius.xl

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Theme.current.colors.glassSheetFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Theme.current.colors.glassSheetStroke, lineWidth: 1)
                    )
            )
            .elevation(4)
    }
}

/// View extension for applying glass sheet styling
extension View {
    /// Applies glassmorphism sheet styling
    /// - Parameter cornerRadius: Corner radius for the sheet (default: Radius.xl = 32)
    func glassSheet(cornerRadius: CGFloat = Radius.xl) -> some View {
        modifier(GlassSheetModifier(cornerRadius: cornerRadius))
    }
}

/// A pre-styled glass sheet container with header and content
struct GlassSheet<Content: View>: View {
    var title: String
    var cornerRadius: CGFloat = Radius.xl
    var onDismiss: (() -> Void)?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, Spacing.xs)

            // Header
            HStack {
                Text(title)
                    .font(Typography.Title.large)
                    .foregroundStyle(Theme.current.colors.textPrimary)

                Spacer()

                if let onDismiss {
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.current.colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)
            .padding(.top, Spacing.m)
            .padding(.bottom, Spacing.s)

            // Content
            content()
        }
        .glassSheet(cornerRadius: cornerRadius)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Theme.softBlush.colors.bgGradientA, Theme.softBlush.colors.bgGradientB],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            Spacer()

            GlassSheet(title: "March 15", onDismiss: {}) {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text("Mom's Birthday")
                        .font(Typography.Title.medium)
                    Text("She's turning 60 this year!")
                        .font(Typography.body)
                        .foregroundStyle(Theme.current.colors.textSecondary)

                    Spacer().frame(height: Spacing.xl)
                }
                .padding(.horizontal, Spacing.screenHorizontal)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}
