//
//  GlassCard.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// Glass card view modifier for card surfaces
/// Applies blur 18-28, fill rgba(255,255,255,0.55), and stroke
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = Radius.m

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Theme.current.colors.glassCardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Theme.current.colors.glassCardStroke, lineWidth: 1)
                    )
            )
            .elevation(2)
    }
}

/// View extension for applying glass card styling
extension View {
    /// Applies glassmorphism card styling
    /// - Parameter cornerRadius: Corner radius for the card (default: Radius.m = 16)
    func glassCard(cornerRadius: CGFloat = Radius.m) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }
}

/// A pre-styled glass card container
struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat = Radius.m
    var padding: CGFloat = Spacing.cardPadding
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .glassCard(cornerRadius: cornerRadius)
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

        VStack(spacing: Spacing.m) {
            GlassCard {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Mom's Birthday")
                        .font(Typography.Title.medium)
                    Text("March 15, 2026")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.current.colors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text("Plain card content")
                .padding()
                .glassCard()
        }
        .padding(Spacing.screenHorizontal)
    }
}
