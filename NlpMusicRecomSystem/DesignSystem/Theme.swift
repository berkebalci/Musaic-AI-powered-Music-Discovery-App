//
//  Theme.swift
//  NlpMusicRecomSystem
//
//  Design system aligned with DESIGN.md (HIG-compliant, iOS-native).
//

import SwiftUI

enum Theme {

    // MARK: - Core Colors (DESIGN.md Aligned)

    /// Primary accent — Vibrant Indigo for core actions and active states.
    static let primary = Color(hex: "#5856D6")
    /// Pure black background — OLED optimized.
    static let background = Color(hex: "#000000")
    /// Secondary background — Cards, list rows, inputs.
    static let secondaryBg = Color(hex: "#1C1C1E")
    /// Tertiary background — Selected rows, elevated surfaces.
    static let tertiaryBg = Color(hex: "#2C2C2E")

    // MARK: - Legacy Aliases (backward compatibility)

    static let backgroundDark = background
    static let backgroundPrimary = Color(hex: "#131315")
    static let backgroundMid = secondaryBg
    static let backgroundLight = tertiaryBg

    // MARK: - Accent Colors

    static let accentCyan = primary              // Mapped to Indigo
    static let accentTeal = Color(hex: "#4B8EFF") // primary-container
    static let accentPurple = Color(hex: "#C2C1FF") // secondary
    static let accentPink = Color(hex: "#FFB595")   // tertiary

    // MARK: - Surface Colors

    static let cardSurface = secondaryBg
    static let cardBorder = Color.white.opacity(0.10)
    static let cardSurfaceHover = tertiaryBg

    // MARK: - Text Colors

    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    static let textTertiary = Color.white.opacity(0.35)

    // MARK: - Tab Bar

    static let tabBarBackground = Color.black.opacity(0.95)
    static let tabBarActive = primary
    static let tabBarInactive = Color.white.opacity(0.4)

    // MARK: - Gradients

    static let backgroundGradient = LinearGradient(
        colors: [background, backgroundPrimary, secondaryBg.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.06),
            Color.white.opacity(0.02),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [primary, accentTeal],
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

    static func albumArtGradient(for songId: Int) -> [Color] {
        let hash = abs(songId.hashValue) % albumGradients.count
        return albumGradients[hash]
    }

    // MARK: - Typography (HIG-aligned)

    /// 34pt Bold — Screen entry points, primary headers.
    static let largeTitleFont = Font.system(size: 34, weight: .bold)
    /// 28pt Bold — Section headers.
    static let titleFont = Font.system(size: 28, weight: .bold)
    /// 17pt Semibold — Card titles, section headers.
    static let headlineFont = Font.system(size: 17, weight: .semibold)
    /// 17pt Regular — Body text.
    static let bodyFont = Font.system(size: 17, weight: .regular)
    /// 16pt Regular — Callout text.
    static let calloutFont = Font.system(size: 16, weight: .regular)
    /// 15pt Regular — Subheadline.
    static let subheadlineFont = Font.system(size: 15, weight: .regular)
    /// 13pt Regular — Footnote, metadata, timestamps.
    static let captionFont = Font.system(size: 13, weight: .regular)
    /// 13pt Medium — Chips, small labels.
    static let chipFont = Font.system(size: 13, weight: .medium)

    // MARK: - Dimensions

    static let cornerRadius: CGFloat = 12
    static let cardCornerRadius: CGFloat = 12
    static let chipCornerRadius: CGFloat = 20
    static let tabBarHeight: CGFloat = 80
}
