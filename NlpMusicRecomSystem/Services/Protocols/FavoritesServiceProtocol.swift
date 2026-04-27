//
//  FavoritesServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol FavoritesServiceProtocol {
    /// Fetches all liked/favorited songs.
    func fetchFavorites() async throws -> [Song]
    /// Adds a song to the favorites list.
    func addFavorite(_ song: Song) async throws
    /// Removes a song from the favorites list by its ID.
    func removeFavorite(songId: String) async throws
}
