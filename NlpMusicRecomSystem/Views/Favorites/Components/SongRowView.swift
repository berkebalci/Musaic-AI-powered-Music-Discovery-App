//
//  SongRowView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct SongRowView: View {

    let song: Song
    let isPlaying: Bool
    let onPlay: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showDelete = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete background
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        onDelete()
                        offset = 0
                        showDelete = false
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Theme.accentPink)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.trailing, 8)
            }

            // Main row content
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
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -80)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3)) {
                            if value.translation.width < -50 {
                                offset = -80
                                showDelete = true
                            } else {
                                offset = 0
                                showDelete = false
                            }
                        }
                    }
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
