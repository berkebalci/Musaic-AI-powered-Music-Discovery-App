//
//  MockNLPService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class MockNLPService: NLPServiceProtocol {

    func analyzeMood(from text: String) async throws -> MoodVector {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000)

        let lowered = text.lowercased()

        // Simple keyword-based mock analysis returning 9-dimensional vector
        if lowered.contains("sad") || lowered.contains("melanchol") || lowered.contains("cry") {
            return MoodVector(danceability: 0.2, energy: 0.2, valence: 0.1, tempo: 0.3,
                            acousticness: 0.7, instrumentalness: 0.3, speechiness: 0.1, loudness: 0.3, liveness: 0.1)
        } else if lowered.contains("energetic") || lowered.contains("workout") || lowered.contains("pump") {
            return MoodVector(danceability: 0.9, energy: 0.9, valence: 0.7, tempo: 0.85,
                            acousticness: 0.1, instrumentalness: 0.1, speechiness: 0.2, loudness: 0.8, liveness: 0.3)
        } else if lowered.contains("chill") || lowered.contains("relax") || lowered.contains("mellow") || lowered.contains("rainy") {
            return MoodVector(danceability: 0.3, energy: 0.2, valence: 0.4, tempo: 0.3,
                            acousticness: 0.6, instrumentalness: 0.4, speechiness: 0.1, loudness: 0.3, liveness: 0.1)
        } else if lowered.contains("happy") || lowered.contains("joy") || lowered.contains("excited") {
            return MoodVector(danceability: 0.8, energy: 0.7, valence: 0.9, tempo: 0.7,
                            acousticness: 0.2, instrumentalness: 0.1, speechiness: 0.1, loudness: 0.6, liveness: 0.2)
        } else if lowered.contains("midnight") || lowered.contains("drive") || lowered.contains("night") {
            return MoodVector(danceability: 0.5, energy: 0.5, valence: 0.4, tempo: 0.55,
                            acousticness: 0.3, instrumentalness: 0.4, speechiness: 0.1, loudness: 0.5, liveness: 0.1)
        } else if lowered.contains("focused") || lowered.contains("study") || lowered.contains("concentrate") {
            return MoodVector(danceability: 0.3, energy: 0.4, valence: 0.5, tempo: 0.45,
                            acousticness: 0.4, instrumentalness: 0.7, speechiness: 0.05, loudness: 0.4, liveness: 0.1)
        } else {
            // Default balanced mood
            return MoodVector(danceability: 0.5, energy: 0.5, valence: 0.5, tempo: 0.5,
                            acousticness: 0.5, instrumentalness: 0.5, speechiness: 0.5, loudness: 0.5, liveness: 0.5)
        }
    }
}
