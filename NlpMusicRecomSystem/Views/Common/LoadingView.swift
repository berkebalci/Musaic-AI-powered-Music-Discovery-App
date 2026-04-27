//
//  LoadingView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct LoadingView: View {

    @State private var isAnimating = false
    @State private var pulseScale: CGFloat = 0.8

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 32) {
                ZStack {
                    // Pulsing rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(Theme.accentCyan.opacity(0.2 - Double(index) * 0.05), lineWidth: 2)
                            .frame(width: CGFloat(80 + index * 30), height: CGFloat(80 + index * 30))
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .opacity(isAnimating ? 0.0 : 0.6)
                            .animation(
                                .easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                                value: isAnimating
                            )
                    }

                    // Center icon
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accentCyan)
                        .scaleEffect(pulseScale)
                        .shadow(color: Theme.accentCyan.opacity(0.4), radius: 16)
                }

                VStack(spacing: 8) {
                    Text("Analyzing your mood")
                        .font(Theme.headlineFont)
                        .foregroundColor(Theme.textPrimary)

                    Text("Finding the perfect tracks...")
                        .font(Theme.bodyFont)
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .onAppear {
            isAnimating = true
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.1
            }
        }
    }
}
