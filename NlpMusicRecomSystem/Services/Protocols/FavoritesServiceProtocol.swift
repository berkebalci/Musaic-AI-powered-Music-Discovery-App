//
//  FavoritesServiceProtocol.swift
//  NlpMusicRecomSystem
//
//  Favorites live server-side. They are created by the swipe "like" action
//  or explicitly via the favorite (heart) buttons, and can be removed again.
//

import Foundation

protocol FavoritesServiceProtocol {
    /// Fetches all liked/favorited songs from the server.
    func fetchFavorites() async throws -> [Song]
    /// Adds a song to the user's favorites (`POST /api/favorites`).
    func addFavorite(_ song: Song) async throws
    /// Removes a song from the user's favorites (`DELETE /api/favorites/{song_id}`).
    /// Idempotent on the server: removing a song that is not a favorite still succeeds.
    func removeFavorite(songId: Int) async throws
}
