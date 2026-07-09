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
    /// Track name from the API (or updated via Apple Music).
    var title: String
    /// Artist name(s) from the API (or updated via Apple Music).
    var artistName: String
    /// Genre from the API (optional, not all endpoints return it).
    let genre: String
    /// Image URL string from the API (or updated via Apple Music).
    var imageUrl: String?
    /// Popularity score (optional, from recommend endpoint).
    let popularity: Int?
    /// Recommendation score (optional, from recommend endpoint).
    let score: Double?
    
    // MARK: - Apple Music Data
    
    /// The exact Apple Music catalog ID.
    var appleMusicId: String?
    /// The duration of the track in milliseconds.
    var durationInMillis: Int?
    /// 30-second preview URL from Apple Music.
    var previewURL: URL?
    
    /// Formatted duration string (e.g., "3:23").
    var durationString: String? {
        guard let durationInMillis = durationInMillis else { return nil }
        let totalSeconds = durationInMillis / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var artworkURL: URL? {
        guard let urlString = imageUrl, !urlString.isEmpty else { return nil }
        return URL(string: urlString)
    }
}
