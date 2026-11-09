//
//  FavoriteButton.swift
//  NlpMusicRecomSystem
//

import SwiftUI

/// A heart button that reflects and toggles whether `song` is in the user's favorites.
/// Reads the shared `FavoritesViewModel` from the environment (injected once in `MainTabView`),
/// so every screen showing it stays in sync.
struct FavoriteButton: View {

    let song: Song
    var size: CGFloat = 18

    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel

    var body: some View {
        let isFavorite = favoritesViewModel.isFavorite(song)

        Button {
            Task { await favoritesViewModel.toggleFavorite(song) }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(isFavorite ? Color(hex: "#FF6B6B") : Theme.textSecondary)
                .symbolEffect(.bounce, value: isFavorite)
                .frame(minWidth: 32, minHeight: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }
}

