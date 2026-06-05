//
//  Song.swift
//  NlpMusicRecomSystem
//
//  Domain model representing a song.
//  Simplified to match the new API response structure.
//

import Foundation

struct Song: Identifiable, Equatable {
    /// Unique song identifier from the API (`song_id`).
    let id: Int
    /// Track name from the API.
    let title: String
    /// Artist name(s) from the API.
    let artistName: String
    /// Genre from the API (optional, not all endpoints return it).
    let genre: String
    /// Image URL string from the API.
    let imageUrl: String?
    /// Popularity score (optional, from recommend endpoint).
    let popularity: Int?
    /// Recommendation score (optional, from recommend endpoint).
    let score: Double?

    var artworkURL: URL? {
        guard let urlString = imageUrl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}
