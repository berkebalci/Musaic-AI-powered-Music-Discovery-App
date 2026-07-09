//
//  AnimatedSparkle.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct AnimatedSparkle: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Central glow
            Circle()
                .fill(Theme.primary.opacity(0.15))
                .frame(width: 80, height: 80)
                .blur(radius: 20)
                .scaleEffect(isAnimating ? 1.2 : 0.9)

            // Sparkle icons
            Image(systemName: "sparkles")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.primary, Theme.accentPurple],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .shadow(color: Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
}
