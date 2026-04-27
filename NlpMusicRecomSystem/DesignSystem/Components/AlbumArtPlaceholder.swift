//
//  AlbumArtPlaceholder.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct AlbumArtPlaceholder: View {
    let songId: String
    let size: CGFloat
    var cornerRadius: CGFloat? = nil

    private var gradient: [Color] {
        Theme.albumArtGradient(for: songId)
    }

    private var computedCornerRadius: CGFloat {
        cornerRadius ?? (size * 0.12)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: computedCornerRadius)
            .fill(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: size * 0.25, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            )
    }
}
