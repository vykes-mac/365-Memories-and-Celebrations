//
//  Theme.swift
//  Three65
//
//  Created by Kenroy McLeish on 31/01/2026.
//

import SwiftUI

/// User-selectable theme for the app
enum Theme: String, CaseIterable, Identifiable {
    case softBlush
    case moonlight
    case warmLinen
    case garden

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .softBlush: return "Soft Blush"
        case .moonlight: return "Moonlight"
        case .warmLinen: return "Warm Linen"
        case .garden: return "Garden"
        }
    }

    var colors: ThemeColors {
        switch self {
        case .softBlush: return .softBlush
        case .moonlight: return .moonlight
        case .warmLinen: return .warmLinen
        case .garden: return .garden
        }
    }

    /// Current theme, stored in UserDefaults
    static var current: Theme {
        get {
            guard let rawValue = UserDefaults.standard.string(forKey: "selectedTheme"),
                  let theme = Theme(rawValue: rawValue) else {
                return .softBlush
            }
            return theme
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedTheme")
        }
    }
}

/// Color tokens for each theme
struct ThemeColors {
    let bgBase: Color
    let bgGradientA: Color
    let bgGradientB: Color
    let accentPrimary: Color
    let accentSecondary: Color
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    let divider: Color

    // Glass surface colors
    let glassCardFill: Color
    let glassCardStroke: Color
    let glassSheetFill: Color
    let glassSheetStroke: Color

    // Category colors (shared across themes)
    static let categoryBirthday = Color(hex: "FF6B9D")
    static let categoryAnniversary = Color(hex: "FF7A59")
    static let categoryMilestone = Color(hex: "5B6CFF")
    static let categoryMemorial = Color(hex: "9D7BFF")
    static let categoryJustBecause = Color(hex: "31C56B")

    // Theme-specific palettes
    static let softBlush = ThemeColors(
        bgBase: Color(hex: "FBF6F8"),
        bgGradientA: Color(hex: "FBF6F8"),
        bgGradientB: Color(hex: "F5EEF2"),
        accentPrimary: Color(hex: "B84BFF"),
        accentSecondary: Color(hex: "FF7AD9"),
        textPrimary: Color(hex: "1C1B1F"),
        textSecondary: Color(hex: "5E5A66"),
        textTertiary: Color(hex: "8E8A96"),
        divider: Color.black.opacity(0.06),
        glassCardFill: Color.white.opacity(0.55),
        glassCardStroke: Color.white.opacity(0.40),
        glassSheetFill: Color.white.opacity(0.72),
        glassSheetStroke: Color.white.opacity(0.50)
    )

    static let moonlight = ThemeColors(
        bgBase: Color(hex: "F6F7FB"),
        bgGradientA: Color(hex: "F6F7FB"),
        bgGradientB: Color(hex: "EDEEF5"),
        accentPrimary: Color(hex: "5B6CFF"),
        accentSecondary: Color(hex: "9D7BFF"),
        textPrimary: Color(hex: "1C1B1F"),
        textSecondary: Color(hex: "5E5A66"),
        textTertiary: Color(hex: "8E8A96"),
        divider: Color.black.opacity(0.06),
        glassCardFill: Color.white.opacity(0.55),
        glassCardStroke: Color.white.opacity(0.40),
        glassSheetFill: Color.white.opacity(0.72),
        glassSheetStroke: Color.white.opacity(0.50)
    )

    static let warmLinen = ThemeColors(
        bgBase: Color(hex: "FBF7F0"),
        bgGradientA: Color(hex: "FBF7F0"),
        bgGradientB: Color(hex: "F5EFE5"),
        accentPrimary: Color(hex: "FF7A59"),
        accentSecondary: Color(hex: "FFB35A"),
        textPrimary: Color(hex: "1C1B1F"),
        textSecondary: Color(hex: "5E5A66"),
        textTertiary: Color(hex: "8E8A96"),
        divider: Color.black.opacity(0.06),
        glassCardFill: Color.white.opacity(0.55),
        glassCardStroke: Color.white.opacity(0.40),
        glassSheetFill: Color.white.opacity(0.72),
        glassSheetStroke: Color.white.opacity(0.50)
    )

    static let garden = ThemeColors(
        bgBase: Color(hex: "F5FBF6"),
        bgGradientA: Color(hex: "F5FBF6"),
        bgGradientB: Color(hex: "ECF5EE"),
        accentPrimary: Color(hex: "31C56B"),
        accentSecondary: Color(hex: "69E3A1"),
        textPrimary: Color(hex: "1C1B1F"),
        textSecondary: Color(hex: "5E5A66"),
        textTertiary: Color(hex: "8E8A96"),
        divider: Color.black.opacity(0.06),
        glassCardFill: Color.white.opacity(0.55),
        glassCardStroke: Color.white.opacity(0.40),
        glassSheetFill: Color.white.opacity(0.72),
        glassSheetStroke: Color.white.opacity(0.50)
    )
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
