//
//  DataBackupView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

struct DataBackupView: View {
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.l) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Data & Backup")
                                .font(Typography.Title.medium)
                                .foregroundStyle(Theme.current.colors.textPrimary)

                            Toggle("iCloud Sync", isOn: $iCloudSyncEnabled)
                                .tint(Theme.current.colors.accentPrimary)

                            if iCloudSyncEnabled {
                                Text(networkMonitor.isConnected
                                    ? "Sync is enabled and will keep your data up to date."
                                    : "Offline. Changes will sync when you're back online.")
                                    .font(Typography.caption)
                                    .foregroundStyle(Theme.current.colors.textSecondary)
                            }

                            Text("Keep your moments safe across devices.")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                        .padding(Spacing.s)
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: Spacing.s) {
                            Text("Export")
                                .font(Typography.Title.medium)
                                .foregroundStyle(Theme.current.colors.textPrimary)

                            Button(action: {}) {
                                Text("Export my data")
                                    .font(Typography.button)
                                    .foregroundStyle(Theme.current.colors.accentPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, Spacing.m)
                                    .background(
                                        RoundedRectangle(cornerRadius: Radius.m)
                                            .stroke(Theme.current.colors.accentPrimary, lineWidth: 1)
                                    )
                            }
                            .disabled(true)
                            .opacity(0.6)

                            Text("Exporting will be available soon.")
                                .font(Typography.caption)
                                .foregroundStyle(Theme.current.colors.textSecondary)
                        }
                        .padding(Spacing.s)
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
        }
        .navigationTitle("Data & Backup")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DataBackupView()
    }
}
