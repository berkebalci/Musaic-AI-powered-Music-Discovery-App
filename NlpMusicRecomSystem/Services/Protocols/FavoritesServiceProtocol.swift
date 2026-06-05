//
//  FavoritesServiceProtocol.swift
//  NlpMusicRecomSystem
//
//  Favorites are now managed server-side via the swipe "like" action.
//  The client can only read favorites from the API.
//

import Foundation

protocol FavoritesServiceProtocol {
    /// Fetches all liked/favorited songs from the server.
    func fetchFavorites() async throws -> [Song]
}
