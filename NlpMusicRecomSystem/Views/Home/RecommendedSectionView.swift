//
//  RecommendedSectionView.swift
//  NlpMusicRecomSystem
//
//  Horizontal scroll section showing recommended songs with cover art.
//  Data comes from the recommendation endpoint.
//

import SwiftUI

struct RecommendedSectionView: View {

    let songs: [Song]
    @ObservedObject var audioPlayer: AudioPlayerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Recommended for You")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Theme.textPrimary)
                .padding(.horizontal, 20)

            // Horizontal scroll cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(songs.prefix(10)) { song in
                        recommendedCard(song: song)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - Recommended Card

    private func recommendedCard(song: Song) -> some View {
        let isPlaying = audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying

        return Button {
            audioPlayer.play(song: song)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                // Album artwork
                ZStack(alignment: .bottomTrailing) {
                    if let artworkURL = song.artworkURL {
                        AsyncImage(url: artworkURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 150, height: 150)
                                    .clipped()
                            default:
                                AlbumArtPlaceholder(songId: song.id, size: 150, cornerRadius: 12)
                            }
                        }
                    } else {
                        AlbumArtPlaceholder(songId: song.id, size: 150, cornerRadius: 12)
                    }

                    // Play indicator
                    if isPlaying {
                        ZStack {
                            Circle()
                                .fill(Theme.primary)
                                .frame(width: 28, height: 28)

                            Image(systemName: "pause.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(x: -8, y: -8)
                    }
                }
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.2), radius: 6, y: 3)

                // Song info
                VStack(alignment: .leading, spacing: 2) {
                    Text(song.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isPlaying ? Theme.primary : Theme.textPrimary)
                        .lineLimit(1)

                    Text(song.artistName)
                        .font(Theme.captionFont)
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)
                }
                .frame(width: 150, alignment: .leading)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
