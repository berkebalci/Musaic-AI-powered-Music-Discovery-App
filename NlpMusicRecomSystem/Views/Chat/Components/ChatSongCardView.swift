//
//  ChatSongCardView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// A compact song recommendation card embedded within a chat bubble.
struct ChatSongCardView: View {

    let song: Song
    @ObservedObject var audioPlayer: AudioPlayerViewModel

    /// Whether this particular song is currently loaded in the player.
    private var isCurrentSong: Bool {
        audioPlayer.currentSong?.id == song.id
    }

    var body: some View {
        HStack(spacing: 12) {
            // Album art with play overlay
            ZStack {
                if let artworkURL = song.artworkURL {
                    AsyncImage(url: artworkURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                                .cornerRadius(8)
                        } else {
                            AlbumArtPlaceholder(songId: song.id, size: 48, cornerRadius: 8)
                        }
                    }
                } else {
                    AlbumArtPlaceholder(songId: song.id, size: 48, cornerRadius: 8)
                }

                // Play / Pause overlay on artwork
                Button {
                    audioPlayer.play(song: song)
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(isCurrentSong ? 0.5 : 0.35))
                            .frame(width: 28, height: 28)

                        Image(systemName: isCurrentSong && audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 48, height: 48)

            // Song info
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isCurrentSong ? Theme.primary : Theme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(song.artistName)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                    
                    if let duration = song.durationString {
                        Text("•")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Theme.textSecondary)
                        Text(duration)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }

            Spacer()

            // Now-playing indicator or play button
            if isCurrentSong && audioPlayer.isPlaying {
                // Animated bars
                NowPlayingBars()
                    .frame(width: 24, height: 18)
            } else {
                Button {
                    audioPlayer.play(song: song)
                } label: {
                    ZStack {
                        Circle()
                            .fill(Theme.primary.opacity(0.15))
                            .frame(width: 32, height: 32)

                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.primary)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentSong ? Theme.primary.opacity(0.08) : Theme.tertiaryBg.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentSong ? Theme.primary.opacity(0.3) : Theme.cardBorder, lineWidth: isCurrentSong ? 1 : 0.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isCurrentSong)
    }
}

// MARK: - Now Playing Animated Bars

private struct NowPlayingBars: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Theme.primary)
                    .frame(width: 3)
                    .frame(height: isAnimating ? CGFloat.random(in: 8...18) : CGFloat(4 + index * 4))
                    .animation(
                        .easeInOut(duration: 0.4 + Double(index) * 0.15)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear { isAnimating = true }
    }
}
