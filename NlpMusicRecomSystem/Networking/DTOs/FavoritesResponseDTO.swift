//
//  FavoritesResponseDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /api/favorites endpoint response.
//

import Foundation

/// Response from `GET /api/favorites`.
/// Returns a paginated list of favorited songs.
struct FavoritesResponseDTO: Decodable {
    let favorites: [FavoriteSongDTO]
    let hasMore: Bool
}

/// Individual favorite song from the API response.
/// Matches the server response fields:
/// ```python
/// {
///     "song_id": doc.id,
///     "title": "...",
///     "artist": "...",
///     "album_art": "...",
///     "apple_music_id": "...",
///     "added_at": "..."
/// }
/// ```
struct FavoriteSongDTO: Decodable {
    let songId: String
    let title: String
    let artist: String
    let albumArt: String?
    let appleMusicId: String?
    let addedAt: String?

    /// Converts the API response into the app's domain `Song` model.
    func toDomain() -> Song {
        Song(
            id: Int(songId) ?? 0,
            title: title,
            artistName: artist,
            genre: "",
            imageUrl: albumArt,
            popularity: nil,
            score: nil
        )
    }
}
