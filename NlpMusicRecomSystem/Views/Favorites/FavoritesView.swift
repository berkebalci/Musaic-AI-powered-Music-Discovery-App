//
//  FavoritesView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct FavoritesView: View {

    @ObservedObject var viewModel: FavoritesViewModel
    @ObservedObject var audioPlayer: AudioPlayerViewModel
    @State private var showSearch = false

    var body: some View {
        ZStack(alignment: .bottom) {
            GradientBackground()

            VStack(spacing: 0) {
                // Header
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                // Search bar
                if showSearch {
                    searchBar
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Song list
                if viewModel.filteredFavorites.isEmpty {
                    emptyState
                } else {
                    songList
                }

                Spacer()
                    .frame(height: 0)
            }

            // Mini Player
            if audioPlayer.currentSong != nil {
                MiniPlayerView(audioPlayer: audioPlayer)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 90)
                    .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            Task { await viewModel.loadFavorites() }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button {} label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }

            Spacer()

            Text("Favorites")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3)) {
                    showSearch.toggle()
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.textTertiary)

            TextField("", text: $viewModel.searchText,
                      prompt: Text("Search favorites...")
                        .foregroundColor(Theme.textTertiary)
            )
            .foregroundColor(Theme.textPrimary)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.textTertiary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cardSurface)
        )
    }

    // MARK: - Song List

    private var songList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(viewModel.filteredFavorites) { song in
                    SongRowView(
                        song: song,
                        isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
                        onPlay: { audioPlayer.play(song: song) },
                        onDelete: { viewModel.removeFavorite(song: song) }
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, audioPlayer.currentSong != nil ? 160 : 100)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "heart.slash")
                .font(.system(size: 48))
                .foregroundColor(Theme.textTertiary)

            Text("No favorites yet")
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textSecondary)

            Text("Swipe right on songs you love\nto add them here")
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textTertiary)
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
        }
    }
}
