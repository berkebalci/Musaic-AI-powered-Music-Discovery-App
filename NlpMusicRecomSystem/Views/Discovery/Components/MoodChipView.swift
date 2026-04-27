//
//  MoodChipView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct MoodChipView: View {
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.chipFont)
                .foregroundColor(Theme.accentCyan)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Theme.accentCyan.opacity(isPressed ? 0.15 : 0.08))
                )
                .overlay(
                    Capsule()
                        .stroke(Theme.accentCyan.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
