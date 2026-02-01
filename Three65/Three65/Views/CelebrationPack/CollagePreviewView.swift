//
//  CollagePreviewView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI
import UIKit

struct CollagePreviewView: View {
    let template: CollageTemplate
    let images: [UIImage?]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                RoundedRectangle(cornerRadius: Radius.m)
                    .fill(Theme.current.colors.glassCardFill)

                switch template {
                case .grid:
                    gridLayout(in: size)
                case .polaroid:
                    polaroidLayout(in: size)
                case .filmStrip:
                    filmStripLayout(in: size)
                case .thenAndNow:
                    thenAndNowLayout(in: size)
                }
            }
        }
    }

    private func image(at index: Int) -> UIImage? {
        if images.indices.contains(index) {
            return images[index]
        }
        return nil
    }

    private func gridLayout(in size: CGSize) -> some View {
        let spacing: CGFloat = 6
        let cellWidth = (size.width - spacing * 3) / 2
        let cellHeight = (size.height - spacing * 3) / 2

        return VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                CollageImageView(image: image(at: 0))
                    .frame(width: cellWidth, height: cellHeight)
                CollageImageView(image: image(at: 1))
                    .frame(width: cellWidth, height: cellHeight)
            }
            HStack(spacing: spacing) {
                CollageImageView(image: image(at: 2))
                    .frame(width: cellWidth, height: cellHeight)
                CollageImageView(image: image(at: 3))
                    .frame(width: cellWidth, height: cellHeight)
            }
        }
        .padding(spacing)
    }

    private func polaroidLayout(in size: CGSize) -> some View {
        let cardWidth = size.width * 0.58
        let cardHeight = size.height * 0.7

        return ZStack {
            PolaroidCard(image: image(at: 0))
                .frame(width: cardWidth, height: cardHeight)
                .rotationEffect(.degrees(-6))
                .offset(x: -size.width * 0.12, y: size.height * 0.04)

            PolaroidCard(image: image(at: 1))
                .frame(width: cardWidth, height: cardHeight)
                .rotationEffect(.degrees(5))
                .offset(x: size.width * 0.1, y: -size.height * 0.06)

            PolaroidCard(image: image(at: 2))
                .frame(width: cardWidth * 0.9, height: cardHeight * 0.9)
                .rotationEffect(.degrees(-2))
                .offset(x: size.width * 0.16, y: size.height * 0.18)
        }
    }

    private func filmStripLayout(in size: CGSize) -> some View {
        let spacing: CGFloat = 8
        let frameHeight = (size.height - spacing * 4) / 3

        return ZStack {
            RoundedRectangle(cornerRadius: Radius.m)
                .fill(Color.black.opacity(0.85))

            VStack(spacing: spacing) {
                CollageImageView(image: image(at: 0))
                    .frame(height: frameHeight)
                CollageImageView(image: image(at: 1))
                    .frame(height: frameHeight)
                CollageImageView(image: image(at: 2))
                    .frame(height: frameHeight)
            }
            .padding(.horizontal, spacing)
            .padding(.vertical, spacing * 1.5)

            filmStripHoles(in: size)
        }
    }

    private func filmStripHoles(in size: CGSize) -> some View {
        let holeCount = 6
        let holeSize: CGFloat = 6
        let totalSpacing = size.width - CGFloat(holeCount) * holeSize
        let holeSpacing = totalSpacing / CGFloat(holeCount + 1)

        return VStack {
            HStack(spacing: holeSpacing) {
                ForEach(0..<holeCount, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: holeSize, height: holeSize)
                }
            }
            .padding(.top, 8)

            Spacer()

            HStack(spacing: holeSpacing) {
                ForEach(0..<holeCount, id: \.self) { _ in
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: holeSize, height: holeSize)
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, holeSpacing)
    }

    private func thenAndNowLayout(in size: CGSize) -> some View {
        let spacing: CGFloat = 8
        let cardWidth = (size.width - spacing * 3) / 2
        let cardHeight = size.height - spacing * 2

        return HStack(spacing: spacing) {
            VStack(spacing: Spacing.xs) {
                CollageImageView(image: image(at: 0))
                    .frame(width: cardWidth, height: cardHeight * 0.82)
                Text("Then")
                    .font(Typography.micro)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
            VStack(spacing: Spacing.xs) {
                CollageImageView(image: image(at: 1))
                    .frame(width: cardWidth, height: cardHeight * 0.82)
                Text("Now")
                    .font(Typography.micro)
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
        }
        .padding(spacing)
    }
}

private struct CollageImageView: View {
    let image: UIImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Radius.s)
                .fill(Theme.current.colors.glassCardFill)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.current.colors.textSecondary)
            }
        }
        .clipped()
    }
}

private struct PolaroidCard: View {
    let image: UIImage?

    var body: some View {
        VStack(spacing: 0) {
            CollageImageView(image: image)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(Spacing.xs)

            Rectangle()
                .fill(Color.white)
                .frame(height: 24)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: Radius.s))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    CollagePreviewView(template: .grid, images: [])
        .frame(width: 200, height: 200)
}
