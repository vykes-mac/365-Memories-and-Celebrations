//
//  DesignTokens.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

// MARK: - Typography

/// Typography styles following the design system
/// Uses New York (Display) + SF Pro (Text) pairing
enum Typography {
    /// Display styles for hero and screen titles (serif)
    enum Display {
        /// 34-36pt hero titles
        static let large = Font.system(size: 35, weight: .bold, design: .serif)
        /// 28-30pt screen titles
        static let medium = Font.system(size: 29, weight: .semibold, design: .serif)
    }

    /// Title styles for sections and cards (serif)
    enum Title {
        /// 22-24pt section titles
        static let large = Font.system(size: 23, weight: .semibold, design: .serif)
        /// 18-20pt card titles
        static let medium = Font.system(size: 19, weight: .medium, design: .serif)
    }

    /// Body text (sans-serif)
    static let body = Font.system(size: 17, weight: .regular, design: .default)

    /// Caption text (sans-serif)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)

    /// Micro text for badges only (sans-serif)
    static let micro = Font.system(size: 11, weight: .medium, design: .default)

    /// Button label text (sans-serif, medium weight)
    static let button = Font.system(size: 17, weight: .medium, design: .default)
}

// MARK: - Spacing (8pt Grid)

/// Spacing constants following the 8pt baseline grid
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32

    /// Screen horizontal padding
    static let screenHorizontal: CGFloat = 20
    /// Card internal padding
    static let cardPadding: CGFloat = 16
    /// Compact card internal padding
    static let cardPaddingCompact: CGFloat = 12
    /// Section spacing
    static let sectionSpacing: CGFloat = 20
}

// MARK: - Corner Radii

/// Corner radius tokens
enum Radius {
    static let s: CGFloat = 12
    static let m: CGFloat = 16
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    /// Pill shape radius
    static let pill: CGFloat = 999
}

// MARK: - Blur

/// Blur intensity tokens for glassmorphism
enum Blur {
    /// Card blur intensity: 18-28
    static let card: CGFloat = 20
    /// Sheet blur intensity: 28-40
    static let sheet: CGFloat = 32
}

// MARK: - Duration

/// Animation duration tokens (milliseconds converted to seconds)
enum Duration {
    /// Fast animations (180ms)
    static let fast: Double = 0.18
    /// Base animations (240ms)
    static let base: Double = 0.24
    /// Slow animations (320ms)
    static let slow: Double = 0.32
}

// MARK: - Elevation (Shadow)

/// Shadow/elevation tokens
enum Elevation {
    /// Level 1: Chips, almost invisible
    static func level1() -> some View {
        Color.clear
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    }

    /// Level 2: Cards
    static func level2() -> some View {
        Color.clear
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }

    /// Level 3: Floating buttons / overlays
    static func level3() -> some View {
        Color.clear
            .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
    }

    /// Level 4: Sheets / modals
    static func level4() -> some View {
        Color.clear
            .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 12)
    }
}

// MARK: - Shadow View Modifier

struct ShadowModifier: ViewModifier {
    let level: Int

    func body(content: Content) -> some View {
        switch level {
        case 1:
            content.shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        case 2:
            content.shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        case 3:
            content.shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
        case 4:
            content.shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 12)
        default:
            content
        }
    }
}

extension View {
    func elevation(_ level: Int) -> some View {
        modifier(ShadowModifier(level: level))
    }
}
