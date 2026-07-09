//
//  GradientBackground.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            // Subtle tonal depth — no colored glows (DESIGN.md compliant)
            LinearGradient(
                colors: [
                    Theme.background,
                    Theme.backgroundPrimary,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}
