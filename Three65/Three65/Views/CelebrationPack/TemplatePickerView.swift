//
//  TemplatePickerView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

struct TemplatePickerView: View {
    @EnvironmentObject private var viewModel: CelebrationPackViewModel

    private let columns = [GridItem(.flexible(), spacing: Spacing.m), GridItem(.flexible(), spacing: Spacing.m)]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.current.colors.bgGradientA, Theme.current.colors.bgGradientB],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.m) {
                    Text("Choose a layout")
                        .font(Typography.Title.large)
                        .foregroundStyle(Theme.current.colors.textPrimary)

                    LazyVGrid(columns: columns, spacing: Spacing.m) {
                        ForEach(CollageTemplate.allCases, id: \.self) { template in
                            NavigationLink {
                                PhotoSelectionView()
                                    .environmentObject(viewModel)
                            } label: {
                                TemplateCard(template: template, isSelected: viewModel.selectedTemplate == template)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                viewModel.selectedTemplate = template
                            })
                        }
                    }
                }
                .padding(Spacing.screenHorizontal)
            }
        }
    }
}

private struct TemplateCard: View {
    let template: CollageTemplate
    let isSelected: Bool

    var body: some View {
        GlassCard {
            VStack(spacing: Spacing.s) {
                CollagePreviewView(
                    template: template,
                    images: Array(repeating: nil, count: 4)
                )
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: Radius.s))

                Text(template.displayName)
                    .font(Typography.caption)
                    .foregroundStyle(Theme.current.colors.textPrimary)
            }
            .padding(Spacing.s)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.m)
                    .stroke(isSelected ? Theme.current.colors.accentPrimary : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    TemplatePickerView()
        .environmentObject(CelebrationPackViewModel())
}
