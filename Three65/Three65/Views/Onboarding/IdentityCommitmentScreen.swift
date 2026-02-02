//
//  IdentityCommitmentScreen.swift
//  Three65
//
//  Created on 02/02/2026.
//

import SwiftUI

/// Identity commitment screen for psychological buy-in
/// Uses commitment/consistency principle to increase engagement
struct IdentityCommitmentScreen: View {
    @Binding var selectedIdentities: Set<String>
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showIdentities = false
    @State private var showFooter = false

    private let identities = [
        Identity(
            id: "friend",
            icon: "person.2.fill",
            title: "The friend who never forgets",
            color: ThemeColors.categoryMilestone
        ),
        Identity(
            id: "partner",
            icon: "heart.fill",
            title: "The partner who plans ahead",
            color: ThemeColors.categoryAnniversary
        ),
        Identity(
            id: "family",
            icon: "house.fill",
            title: "The family member who stays connected",
            color: ThemeColors.categoryBirthday
        ),
        Identity(
            id: "special",
            icon: "sparkles",
            title: "The one who makes people feel special",
            color: ThemeColors.categoryJustBecause
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 60)

            // Header
            Text("Who do you\nwant to be?")
                .font(Typography.Display.large)
                .multilineTextAlignment(.center)
                .foregroundStyle(Theme.current.colors.textPrimary)
                .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 40)

            // Identity options
            VStack(spacing: Spacing.s) {
                ForEach(Array(identities.enumerated()), id: \.element.id) { index, identity in
                    IdentityCard(
                        identity: identity,
                        isSelected: selectedIdentities.contains(identity.id),
                        onTap: { toggleIdentity(identity.id) }
                    )
                    .opacity(showIdentities ? 1 : 0)
                    .offset(y: showIdentities ? 0 : 20)
                    .animation(
                        reduceMotion ? .none : .easeOut(duration: Duration.slow).delay(Double(index) * 0.1),
                        value: showIdentities
                    )
                }
            }
            .padding(.horizontal, Spacing.screenHorizontal)

            Spacer()
                .frame(height: 32)

            // Footer message
            Text("We'll help you become exactly that.")
                .font(Typography.body)
                .foregroundStyle(Theme.current.colors.textSecondary)
                .multilineTextAlignment(.center)
                .opacity(showFooter ? 1 : 0)
                .animation(
                    reduceMotion ? .none : .easeOut(duration: Duration.slow),
                    value: showFooter
                )

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    showIdentities = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation {
                    showFooter = true
                }
            }
        }
    }

    private func toggleIdentity(_ id: String) {
        Haptics.light()
        withAnimation(.easeInOut(duration: Duration.fast)) {
            if selectedIdentities.contains(id) {
                selectedIdentities.remove(id)
            } else {
                selectedIdentities.insert(id)
            }
        }
        AnalyticsService.shared.track("identity_selected", properties: ["identity": id])
    }
}

// MARK: - Supporting Types

private struct Identity: Identifiable {
    let id: String
    let icon: String
    let title: String
    let color: Color
}

private struct IdentityCard: View {
    let identity: Identity
    let isSelected: Bool
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.m) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.s / 2)
                        .fill(isSelected ? identity.color : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.s / 2)
                                .stroke(isSelected ? identity.color : Theme.current.colors.textTertiary, lineWidth: 2)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                // Icon
                Image(systemName: identity.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? identity.color : Theme.current.colors.textSecondary)
                    .frame(width: 28)

                // Title
                Text(identity.title)
                    .font(Typography.body)
                    .foregroundStyle(isSelected ? Theme.current.colors.textPrimary : Theme.current.colors.textSecondary)

                Spacer()
            }
            .padding(Spacing.m)
            .background(
                RoundedRectangle(cornerRadius: Radius.m)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .fill(isSelected ? identity.color.opacity(0.1) : Theme.current.colors.glassCardFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.m)
                            .stroke(isSelected ? identity.color.opacity(0.5) : Theme.current.colors.glassCardStroke, lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(reduceMotion ? .none : .easeInOut(duration: Duration.fast), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(identity.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        IdentityCommitmentScreen(selectedIdentities: .constant(["friend"]))
    }
}
