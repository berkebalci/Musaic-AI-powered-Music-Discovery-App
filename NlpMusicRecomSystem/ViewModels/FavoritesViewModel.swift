//
//  FavoritesViewModel.swift
//  NlpMusicRecomSystem
//

import Foundation
import SwiftUI
import Combine

final class FavoritesViewModel: ObservableObject {

    // MARK: - Published State

    @Published var favorites: [Song] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    var filteredFavorites: [Song] {
        if searchText.isEmpty {
            return favorites
        }
        return favorites.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
            || $0.artistName.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Dependencies

    private let favoritesService: any FavoritesServiceProtocol

    // MARK: - Init

    init(favoritesService: any FavoritesServiceProtocol) {
        self.favoritesService = favoritesService
    }

    // MARK: - User Intents

    @MainActor
    func loadFavorites() async {
        isLoading = true
        do {
            favorites = try await favoritesService.fetchFavorites()
        } catch {
            print("[FavoritesVM] Error loading favorites: \(error)")
        }
        isLoading = false
    }

    @MainActor
    func removeFavorite(at offsets: IndexSet) {
        let songsToRemove = offsets.map { filteredFavorites[$0] }
        for song in songsToRemove {
            Task {
                try? await favoritesService.removeFavorite(songId: song.id)
                await loadFavorites()
            }
        }
    }

    @MainActor
    func removeFavorite(song: Song) {
        Task {
            try? await favoritesService.removeFavorite(songId: song.id)
            await loadFavorites()
        }
    }
}
