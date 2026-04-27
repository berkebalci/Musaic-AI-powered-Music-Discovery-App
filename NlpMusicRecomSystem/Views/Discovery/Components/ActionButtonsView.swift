//
//  ActionButtonsView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct ActionButtonsView: View {

    let onDislike: () -> Void
    let onPlay: () -> Void
    let onLike: () -> Void

    var body: some View {
        HStack(spacing: 28) {
            // Dislike button
            Button(action: onDislike) {
                ZStack {
                    Circle()
                        .fill(Theme.cardSurface)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(Theme.cardBorder, lineWidth: 1)
                        )

                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            .buttonStyle(ScaleButtonStyle())

            // Play button
            Button(action: onPlay) {
                ZStack {
                    Circle()
                        .stroke(Theme.accentCyan, lineWidth: 2.5)
                        .frame(width: 68, height: 68)

                    Image(systemName: "play.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Theme.textPrimary)
                }
            }
            .buttonStyle(ScaleButtonStyle())

            // Like button
            Button(action: onLike) {
                ZStack {
                    Circle()
                        .fill(Theme.accentCyan.opacity(0.12))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(Theme.accentCyan.opacity(0.3), lineWidth: 1)
                        )

                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.accentCyan)
                }
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}
