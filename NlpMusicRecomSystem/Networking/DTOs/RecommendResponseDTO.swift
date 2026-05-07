//
//  RecommendResponseDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /recommend endpoint response.
//

import Foundation

/// Response from `POST /recommend`.
/// The actual structure depends on the `RecommendationEngine.recommend()` output.
/// This is a flexible container that captures the recommendation results.
struct RecommendResponseDTO: Decodable {
    let mode: String?
    let recommendations: [SongDTO]
}

/// Individual song from the API response.
/// Maps to the data returned by the recommendation engine.
struct SongDTO: Decodable {
    let trackName: String?
    let artists: String?
    let trackGenre: String?
    let popularity: Int?
    let score: Double?

    /// Converts the API response into the app's domain `Song` model.
    func toDomain() -> Song {
        Song(
            id: UUID().uuidString,
            title: trackName ?? "Unknown",
            artistName: artists ?? "Unknown Artist",
            albumName: "Unknown Album",
            artworkURLString: nil,
            previewURLString: nil,
            genre: trackGenre ?? "Unknown",
            moodTags: [],
            durationInSeconds: 0
        )
    }
}
