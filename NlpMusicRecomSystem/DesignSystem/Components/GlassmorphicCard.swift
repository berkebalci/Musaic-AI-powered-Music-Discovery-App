//
//  GlassmorphicCard.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct GlassmorphicCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
            )
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(Theme.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCornerRadius))
    }
}
