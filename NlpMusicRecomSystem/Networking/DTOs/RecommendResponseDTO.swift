//
//  RecommendResponseDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /api/recommend endpoint response.
//

import Foundation

/// Response from `POST /api/recommend`.
/// The structure is returned by the `RecommendationEngine.recommend()` on the server.
struct RecommendResponseDTO: Decodable {
    let mode: String?
    let feed: [SongDTO]
}

/// Individual song from the API response.
/// Maps to the data returned by the recommendation engine.
struct SongDTO: Decodable {
    let songId: Int?
    let trackName: String?
    let artists: String?
    let trackGenre: String?
    let popularity: Int?
    let matchScore: Double?
    let imageUrl: String?

    /// Converts the API response into the app's domain `Song` model.
    func toDomain(fallbackIndex: Int) -> Song {
        Song(
            id: songId ?? fallbackIndex,
            title: trackName ?? "Unknown",
            artistName: artists ?? "Unknown Artist",
            genre: trackGenre ?? "Unknown",
            imageUrl: imageUrl,
            popularity: popularity,
            score: matchScore
        )
    }
}
