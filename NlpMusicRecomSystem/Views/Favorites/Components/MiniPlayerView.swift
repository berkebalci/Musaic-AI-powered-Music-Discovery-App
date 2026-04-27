//
//  MiniPlayerView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct MiniPlayerView: View {

    @ObservedObject var audioPlayer: AudioPlayerViewModel

    var body: some View {
        if let song = audioPlayer.currentSong {
            VStack(spacing: 0) {
                // Progress indicator at top
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Theme.accentCyan)
                        .frame(
                            width: geometry.size.width * audioPlayer.progressFraction,
                            height: 2
                        )
                        .animation(.linear(duration: 0.1), value: audioPlayer.progressFraction)
                }
                .frame(height: 2)

                HStack(spacing: 12) {
                    // Album art
                    AlbumArtPlaceholder(songId: song.id, size: 44, cornerRadius: 8)

                    // Song info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(song.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)

                        Text(song.artistName)
                            .font(.system(size: 12))
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Playback controls
                    HStack(spacing: 18) {
                        Button {} label: {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.accentCyan)
                        }

                        Button {
                            audioPlayer.togglePlayback()
                        } label: {
                            Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Theme.accentCyan)
                        }

                        Button {} label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.accentCyan)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 12, y: -4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.accentCyan.opacity(0.25), lineWidth: 1)
            )
        }
    }
}
