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

        // Simple keyword-based mock analysis
        if lowered.contains("sad") || lowered.contains("melanchol") || lowered.contains("cry") {
            return MoodVector(sadness: 0.8, energy: 0.2, tempo: 0.25)
        } else if lowered.contains("energetic") || lowered.contains("workout") || lowered.contains("pump") {
            return MoodVector(sadness: 0.1, energy: 0.9, tempo: 0.85)
        } else if lowered.contains("chill") || lowered.contains("relax") || lowered.contains("mellow") || lowered.contains("rainy") {
            return MoodVector(sadness: 0.3, energy: 0.2, tempo: 0.3)
        } else if lowered.contains("happy") || lowered.contains("joy") || lowered.contains("excited") {
            return MoodVector(sadness: 0.05, energy: 0.7, tempo: 0.7)
        } else if lowered.contains("midnight") || lowered.contains("drive") || lowered.contains("night") {
            return MoodVector(sadness: 0.4, energy: 0.5, tempo: 0.55)
        } else if lowered.contains("focused") || lowered.contains("study") || lowered.contains("concentrate") {
            return MoodVector(sadness: 0.15, energy: 0.4, tempo: 0.45)
        } else {
            // Default balanced mood
            return MoodVector(sadness: 0.3, energy: 0.5, tempo: 0.5)
        }
    }
}
