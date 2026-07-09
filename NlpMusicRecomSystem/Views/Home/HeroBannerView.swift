//
//  HeroBannerView.swift
//  NlpMusicRecomSystem
//
//  Fan-style card stack showcasing featured album art.
//  Aligned with DESIGN.md Music Discovery Cards spec.
//

import SwiftUI

struct HeroBannerView: View {

    @State private var appear = false

    private let cardData = [
        ("Home Hero Banner", "The Driftwood Trio", "Whispers of the Hearth"), // Center (index 0)
        ("hero banner 2", "", "New Music"),       // Right (index 1)
        ("hero banner 3", "Chill Vibes", "Acoustic")      // Left (index 2)
    ]

    var body: some View {
        ZStack {
            // Back-left card
            cardView(index: 2)
                .rotationEffect(.degrees(-8))
                .offset(x: -80, y: 10)
                .scaleEffect(0.85)
                .opacity(appear ? 0.7 : 0)

            // Back-right card
            cardView(index: 1)
                .rotationEffect(.degrees(6))
                .offset(x: 80, y: 8)
                .scaleEffect(0.88)
                .opacity(appear ? 0.8 : 0)

            // Front-center card (hero)
            cardView(index: 0)
                .scaleEffect(appear ? 1.0 : 0.9)
                .opacity(appear ? 1.0 : 0)
        }
        .frame(height: 300)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                appear = true
            }
        }
    }

    // MARK: - Card View

    @ViewBuilder
    private func cardView(index: Int) -> some View {
        let data = cardData[index]

        RoundedRectangle(cornerRadius: 12)
            .fill(Theme.secondaryBg)
            .frame(width: 220, height: 280)
            .overlay(
                VStack(spacing: 0) {
                    // Static image
                    Image(data.0)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 220, height: 220)
                        .clipped()

                    // Song info footer
                    VStack(alignment: .leading, spacing: 2) {
                        Text(data.1)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)

                        Text(data.2)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Theme.secondaryBg)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
    }
}
