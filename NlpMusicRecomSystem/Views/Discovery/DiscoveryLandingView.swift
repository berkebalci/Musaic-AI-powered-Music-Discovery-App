//
//  DiscoveryLandingView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// The new Discovery tab landing screen showing a featured song card stack
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
                Text("MoodTune")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.accentCyan, Color(hex: "#62ebd7")],
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
                    .font(.system(size: 28, weight: .bold, design: .rounded))
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
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .opacity(opacity * 0.3)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.cardGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.cardBorder, lineWidth: 0.5)
            )
            .frame(width: 260, height: 290)
            .rotationEffect(.degrees(rotation))
            .offset(x: offsetX)
    }

    private var mainFeaturedCard: some View {
        VStack(spacing: 0) {
            // Album art placeholder
            AlbumArtPlaceholder(songId: 1, size: 200, cornerRadius: 16)
                .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
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
                    tagChip(text: "Alternative Rock", color: Theme.accentCyan)
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
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.5)
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardGradient)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
            // Use the persistent mood vector (or default) to fetch recommendations
            Task {
                await viewModel.fetchSongsWithDefaultMood()
            }
        } label: {
            Text("Start Discovering")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Theme.backgroundDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.accentCyan.opacity(0.9), Theme.accentCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: Theme.accentCyan.opacity(0.3), radius: 12, y: 4)
        }
    }
}
