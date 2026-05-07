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
    let songs: [SongDTO]
    let moodVector: [Double]?
}

/// Individual song from the API response.
/// Maps to the data returned by the recommendation engine.
struct SongDTO: Decodable {
    let index: Int?
    let title: String?
    let artist: String?
    let album: String?
    let genre: String?
    let score: Double?
    let artworkUrl: String?
    let previewUrl: String?
    let durationInSeconds: Int?
    let moodTags: [String]?

    /// Converts the API response into the app's domain `Song` model.
    func toDomain() -> Song {
        Song(
            id: index.map(String.init) ?? UUID().uuidString,
            title: title ?? "Unknown",
            artistName: artist ?? "Unknown Artist",
            albumName: album ?? "Unknown Album",
            artworkURLString: artworkUrl,
            previewURLString: previewUrl,
            genre: genre ?? "Unknown",
            moodTags: moodTags ?? [],
            durationInSeconds: durationInSeconds ?? 0
        )
    }
}
