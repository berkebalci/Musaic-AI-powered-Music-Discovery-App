//
//  APIFavoritesService.swift
//  NlpMusicRecomSystem
//
//  Server-side implementation of FavoritesServiceProtocol.
//  Fetches favorites from the API's GET /api/favorites endpoint.
//  Favorites are determined server-side by the user's "like" swipe interactions.
//

import Foundation

final class APIFavoritesService: FavoritesServiceProtocol {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    /// Fetches all liked songs from the server.
    /// The server determines favorites based on swipe "like" interactions stored in Firebase.
    func fetchFavorites() async throws -> [Song] {
        let response = try await apiClient.get(
            url: APIEnvironment.favoritesURL,
            responseType: FavoritesResponseDTO.self
        )
        let a = response.favorites.map { $0.toDomain() }
        print("burasi favori servis class'i")
        print(a)
        return a
    }
}
