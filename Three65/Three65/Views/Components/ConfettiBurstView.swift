//
//  ConfettiBurstView.swift
//  Three65
//
//  Created by Ralph on 01/02/2026.
//

import SwiftUI

struct ConfettiBurstView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var animate = false
    @State private var pieces: [ConfettiPiece] = ConfettiPiece.generate()

    var body: some View {
        if reduceMotion {
            EmptyView()
        } else {
            GeometryReader { proxy in
                ZStack {
                    ForEach(pieces) { piece in
                        Rectangle()
                            .fill(piece.color)
                            .frame(width: piece.size, height: piece.size * 0.6)
                            .rotationEffect(.degrees(animate ? piece.rotation : 0))
                            .offset(
                                x: piece.x * proxy.size.width - proxy.size.width / 2,
                                y: animate ? proxy.size.height + 40 : -40
                            )
                            .opacity(animate ? 0 : 1)
                            .animation(
                                .easeOut(duration: Duration.slow * 4).delay(piece.delay),
                                value: animate
                            )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .allowsHitTesting(false)
            .onAppear {
                animate = true
            }
        }
    }
}

private struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let size: CGFloat
    let rotation: Double
    let color: Color
    let delay: Double

    static func generate(count: Int = 28) -> [ConfettiPiece] {
        let colors: [Color] = [
            Theme.current.colors.accentPrimary,
            Theme.current.colors.accentSecondary,
            ThemeColors.categoryBirthday,
            ThemeColors.categoryAnniversary,
            ThemeColors.categoryMilestone
        ]

        return (0..<count).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0.05...0.95),
                size: CGFloat.random(in: 6...12),
                rotation: Double.random(in: -45...45),
                color: colors.randomElement() ?? Theme.current.colors.accentPrimary,
                delay: Double.random(in: 0...0.3)
            )
        }
    }
}

#Preview {
    ConfettiBurstView()
}
