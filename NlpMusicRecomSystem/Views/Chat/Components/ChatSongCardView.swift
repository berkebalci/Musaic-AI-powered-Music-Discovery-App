//
//  ChatSongCardView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// A compact song recommendation card embedded within a chat bubble.
struct ChatSongCardView: View {

    let song: Song

    var body: some View {
        HStack(spacing: 12) {
            // Album art
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

            // Song info
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
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

            // Add/like button
            Button {} label: {
                ZStack {
                    Circle()
                        .fill(Theme.accentCyan.opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.accentCyan)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.cardBorder, lineWidth: 0.5)
        )
    }
}
