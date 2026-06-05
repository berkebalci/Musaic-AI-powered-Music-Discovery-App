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
}
