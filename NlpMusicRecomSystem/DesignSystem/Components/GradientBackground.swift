//
//  GradientBackground.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct GradientBackground: View {
    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            // Subtle radial glow at top center
            RadialGradient(
                colors: [
                    Theme.accentCyan.opacity(0.08),
                    Color.clear,
                ],
                center: .top,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }
}
