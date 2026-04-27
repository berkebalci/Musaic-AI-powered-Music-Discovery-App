//
//  MockFavoritesService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class MockFavoritesService: FavoritesServiceProtocol {

    private var favorites: [Song] = []

    func fetchFavorites() async throws -> [Song] {
        favorites
    }

    func addFavorite(_ song: Song) async throws {
        guard !favorites.contains(where: { $0.id == song.id }) else { return }
        favorites.insert(song, at: 0)
    }

    func removeFavorite(songId: String) async throws {
        favorites.removeAll { $0.id == songId }
    }
}
