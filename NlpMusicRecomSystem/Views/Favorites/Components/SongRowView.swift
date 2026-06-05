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
            // Album art
            AlbumArtPlaceholder(songId: song.id, size: 56, cornerRadius: 10)

            // Song info
            VStack(alignment: .leading, spacing: 3) {
                Text(song.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)

                Text(song.artistName)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
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
    }
}
