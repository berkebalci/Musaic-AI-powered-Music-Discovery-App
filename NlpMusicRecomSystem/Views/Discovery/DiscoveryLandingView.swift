//
//  DiscoveryLandingView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// The Discovery tab landing screen showing a featured song card stack
/// with a "Start Discovering" CTA that leads to the swipe card flow.
struct DiscoveryLandingView: View {

    @ObservedObject var viewModel: DiscoveryViewModel
    @ObservedObject var audioPlayer: AudioPlayerViewModel

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)

                // App title
                Text("Discovery")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.primary, Theme.accentPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, 24)

                // Featured card stack
                featuredCardStack
                    .padding(.horizontal, 24)

                Spacer()
                    .frame(height: 32)

                // Headline
                Text("Ready for Your Vibe?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)

                // Subtitle
                Text("Our AI has curated a unique deck of\nsongs just for you. Swipe through to\nfind your perfect match.")
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)

                // CTA Button
                startDiscoveringButton
                    .padding(.horizontal, 40)

                Spacer()
                    .frame(height: 120)
            }
        }
    }

    // MARK: - Featured Card Stack

    private var featuredCardStack: some View {
        ZStack {
            // Background cards (parallax/tilted)
            backgroundCard(rotation: 6, offsetX: 20, opacity: 0.4)
            backgroundCard(rotation: -4, offsetX: -15, opacity: 0.5)

            // Main featured card
            mainFeaturedCard
        }
        .frame(height: 320)
    }

    private func backgroundCard(rotation: Double, offsetX: CGFloat, opacity: Double) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Theme.secondaryBg)
            .opacity(opacity)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.cardBorder, lineWidth: 0.5)
            )
            .frame(width: 260, height: 290)
            .rotationEffect(.degrees(rotation))
            .offset(x: offsetX)
    }

    private var mainFeaturedCard: some View {
        VStack(spacing: 0) {
            // Album art placeholder
            AlbumArtPlaceholder(songId: 1, size: 200, cornerRadius: 12)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                .padding(.top, 16)

            Spacer()
                .frame(height: 16)

            // Song info
            VStack(alignment: .leading, spacing: 4) {
                Text("After Hours")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.textPrimary)

                Text("The Weeknd")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Theme.textSecondary)

                // Genre tags
                HStack(spacing: 8) {
                    tagChip(text: "Alternative Rock", color: Theme.primary)
                    tagChip(text: "Melancholic", color: Theme.accentPink)
                }
                .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .frame(width: 260, height: 320)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.secondaryBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Tag Chip

    private func tagChip(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color.opacity(0.12))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.25), lineWidth: 0.5)
            )
    }

    // MARK: - Start Discovering Button

    private var startDiscoveringButton: some View {
        Button {
            Task {
                await viewModel.fetchSongsWithDefaultMood()
            }
        } label: {
            Text("Start Discovering")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Theme.primary)
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
