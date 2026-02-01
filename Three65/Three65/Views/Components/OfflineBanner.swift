//
//  OfflineBanner.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

struct OfflineBanner: View {
    var body: some View {
        GlassCard {
            HStack(spacing: Spacing.s) {
                Image(systemName: "wifi.slash")
                    .foregroundStyle(Theme.current.colors.accentSecondary)
                Text("Offline mode. Changes will sync when you're back online.")
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.top, Spacing.s)
    }
}

#Preview {
    OfflineBanner()
}
