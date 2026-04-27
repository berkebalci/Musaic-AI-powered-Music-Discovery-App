//
//  Theme.swift
//  NlpMusicRecomSystem
//

import SwiftUI

enum Theme {

    // MARK: - Background Colors

    static let backgroundDark = Color(hex: "#070E1A")
    static let backgroundPrimary = Color(hex: "#0A1628")
    static let backgroundMid = Color(hex: "#0F2030")
    static let backgroundLight = Color(hex: "#162D40")

    // MARK: - Accent Colors

    static let accentCyan = Color(hex: "#00D4FF")
    static let accentTeal = Color(hex: "#1A8A8A")
    static let accentPurple = Color(hex: "#7B61FF")
    static let accentPink = Color(hex: "#FF6B9D")

    // MARK: - Surface Colors

    static let cardSurface = Color.white.opacity(0.07)
    static let cardBorder = Color.white.opacity(0.12)
    static let cardSurfaceHover = Color.white.opacity(0.12)

    // MARK: - Text Colors

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let textTertiary = Color.white.opacity(0.35)

    // MARK: - Tab Bar

    static let tabBarBackground = Color(hex: "#0B1420").opacity(0.95)
    static let tabBarActive = accentCyan
    static let tabBarInactive = Color.white.opacity(0.4)

    // MARK: - Gradients

    static let backgroundGradient = LinearGradient(
        colors: [backgroundDark, backgroundPrimary, backgroundMid],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.1),
            Color.white.opacity(0.04),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accentCyan, accentTeal],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Album Art Placeholder Gradients

    static let albumGradients: [[Color]] = [
        [Color(hex: "#FF6B6B"), Color(hex: "#556270")],
        [Color(hex: "#C471F5"), Color(hex: "#FA71CD")],
        [Color(hex: "#00C6FF"), Color(hex: "#0072FF")],
        [Color(hex: "#F857A6"), Color(hex: "#FF5858")],
        [Color(hex: "#4ECDC4"), Color(hex: "#556270")],
        [Color(hex: "#F7971E"), Color(hex: "#FFD200")],
        [Color(hex: "#614385"), Color(hex: "#516395")],
        [Color(hex: "#1A2980"), Color(hex: "#26D0CE")],
    ]

    static func albumArtGradient(for songId: String) -> [Color] {
        let hash = abs(songId.hashValue) % albumGradients.count
        return albumGradients[hash]
    }

    // MARK: - Typography

    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular)
    static let captionFont = Font.system(size: 13, weight: .medium)
    static let chipFont = Font.system(size: 13, weight: .medium)

    // MARK: - Dimensions

    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 20
    static let chipCornerRadius: CGFloat = 20
    static let tabBarHeight: CGFloat = 80
}
