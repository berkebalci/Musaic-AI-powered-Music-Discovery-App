//
//  SongRowView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct SongRowView: View {

    let song: Song
    let isPlaying: Bool
    let onPlay: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Album art — show real artwork if available
            if let artworkURL = song.artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 56, height: 56)
                            .cornerRadius(10)
                    } else {
                        AlbumArtPlaceholder(songId: song.id, size: 56, cornerRadius: 10)
                    }
                }
                .frame(width: 56, height: 56)
            } else {
                AlbumArtPlaceholder(songId: song.id, size: 56, cornerRadius: 10)
            }

            // Song info
            VStack(alignment: .leading, spacing: 3) {
                Text(song.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isPlaying ? Theme.accentCyan : Theme.textPrimary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(song.artistName)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(1)

                    if let duration = song.durationString {
                        Text("•")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                        Text(duration)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }

            Spacer()

            // Play button
            Button(action: onPlay) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Theme.accentCyan)
                    .shadow(color: Theme.accentCyan.opacity(0.3), radius: 4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isPlaying ? Theme.cardSurfaceHover : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }
}
