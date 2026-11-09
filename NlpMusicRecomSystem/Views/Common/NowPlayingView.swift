//
//  NowPlayingView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// Large, non-swipeable presentation of the song that is currently playing.
/// Opened from the mini player's artwork. It reuses `SwipeCardView` (the card used by
/// `CardStackView`) with swiping disabled, scaled up.
struct NowPlayingView: View {

    @ObservedObject var audioPlayer: AudioPlayerViewModel

    private let cardScale: CGFloat = 1.15

    var body: some View {
        ZStack {
            GradientBackground()

            if let song = audioPlayer.currentSong {
                VStack(spacing: 28) {
                    Spacer(minLength: 0)

                    // isTopCard: false → no drag gesture, so the card is display-only.
                    SwipeCardView(
                        song: song,
                        isTopCard: false,
                        onSwipeLeft: {},
                        onSwipeRight: {}
                    )
                    .scaleEffect(cardScale)
                    .frame(width: 300 * cardScale, height: 400 * cardScale)

                    progressBar
                        .padding(.horizontal, 48)

                    controls(for: song)

                    Spacer(minLength: 0)
                }
                .padding(.top, 24)
            }
        }
    }

    // MARK: - Controls

    private func controls(for song: Song) -> some View {
        HStack(spacing: 40) {
            FavoriteButton(song: song, size: 28)

            Button {
                audioPlayer.togglePlayback()
            } label: {
                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Theme.accentCyan)
            }
            .buttonStyle(.plain)

            // Keeps the play button centered next to the heart.
            Color.clear
                .frame(width: 32, height: 32)
        }
    }

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.cardSurface)
                    .frame(height: 3)

                Capsule()
                    .fill(Theme.accentCyan)
                    .frame(width: geometry.size.width * audioPlayer.progressFraction, height: 3)
                    .animation(.linear(duration: 0.1), value: audioPlayer.progressFraction)
            }
        }
        .frame(height: 3)
    }
}

