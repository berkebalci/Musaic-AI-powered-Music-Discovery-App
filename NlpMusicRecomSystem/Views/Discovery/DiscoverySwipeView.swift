//
//  DiscoverySwipeView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct DiscoverySwipeView: View {

    @ObservedObject var viewModel: DiscoveryViewModel
    @ObservedObject var audioPlayer: AudioPlayerViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 8)

            Spacer()

            // Card Stack
            CardStackView(viewModel: viewModel)
                .frame(height: 360)

            Spacer()
                .frame(height: 20)

            // Song info
            if let song = viewModel.currentSong {
                songInfoSection(song: song)
            }

            Spacer()
                .frame(height: 16)

            // Audio progress bar
            audioProgressBar
                .padding(.horizontal, 60)

            Spacer()
                .frame(height: 24)

            // Action buttons
            if let song = viewModel.currentSong {
                ActionButtonsView(
                    onDislike: {
                        Task { await viewModel.swipeLeft(on: song) }
                    },
                    onPlay: {
                        audioPlayer.play(song: song)
                    },
                    onLike: {
                        Task { await viewModel.swipeRight(on: song) }
                    }
                )
            }

            Spacer()
                .frame(height: 100)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                viewModel.goBackToMoodInput()
            } label: {
                ZStack {
                    Circle()
                        .fill(Theme.cardSurface)
                        .frame(width: 40, height: 40)

                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            Spacer()

            // Mood indicator
            Capsule()
                .fill(Theme.accentCyan.opacity(0.6))
                .frame(width: 40, height: 4)

            Spacer()

            Button {} label: {
                ZStack {
                    Circle()
                        .fill(Theme.cardSurface)
                        .frame(width: 40, height: 40)

                    Image(systemName: "bell.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }

    // MARK: - Song Info

    private func songInfoSection(song: Song) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                Text(song.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)

                Spacer()

                // Explicit label placeholder
                Image(systemName: "e.square.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.accentCyan.opacity(0.6))
            }

            HStack {
                Text(song.artistName)
                    .font(Theme.bodyFont)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
            }

            // Tags
            HStack(spacing: 8) {
                ForEach(Array(song.moodTags.prefix(2)), id: \.self) { tag in
                    tagChip(icon: tag == song.genre ? "music.note" : "face.smiling", text: tag)
                }

                if !song.genre.isEmpty {
                    tagChip(icon: "guitars.fill", text: song.genre)
                }

                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Tag Chip

    private func tagChip(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(Theme.accentCyan)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Theme.accentCyan.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(Theme.accentCyan.opacity(0.2), lineWidth: 0.5)
        )
    }

    // MARK: - Audio Progress

    private var audioProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.cardSurface)
                    .frame(height: 3)

                Capsule()
                    .fill(Theme.accentCyan)
                    .frame(
                        width: geometry.size.width * audioPlayer.progressFraction,
                        height: 3
                    )
                    .animation(.linear(duration: 0.1), value: audioPlayer.progressFraction)
            }
        }
        .frame(height: 3)
    }
}
