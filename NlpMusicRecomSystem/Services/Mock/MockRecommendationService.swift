//
//  MockRecommendationService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class MockRecommendationService: RecommendationServiceProtocol {

    private let mockCatalog: [Song] = [
        Song(id: 1, title: "After Hours", artistName: "The Weeknd",
             genre: "Alternative R&B", imageUrl: nil, popularity: 85, score: 0.95),
        Song(id: 2, title: "Midnight City", artistName: "M83",
             genre: "Synth Pop", imageUrl: nil, popularity: 78, score: 0.88),
        Song(id: 3, title: "Levitating", artistName: "Dua Lipa",
             genre: "Pop", imageUrl: nil, popularity: 92, score: 0.91),
        Song(id: 4, title: "Heat Waves", artistName: "Glass Animals",
             genre: "Indie Pop", imageUrl: nil, popularity: 88, score: 0.87),
        Song(id: 5, title: "Starlight", artistName: "The Midnight",
             genre: "Synthwave", imageUrl: nil, popularity: 65, score: 0.82),
        Song(id: 6, title: "Numb Little Bug", artistName: "Em Beihold",
             genre: "Pop", imageUrl: nil, popularity: 74, score: 0.79),
        Song(id: 7, title: "Blinding Lights", artistName: "The Weeknd",
             genre: "Synth Pop", imageUrl: nil, popularity: 96, score: 0.93),
        Song(id: 8, title: "Somebody Else", artistName: "The 1975",
             genre: "Indie Pop", imageUrl: nil, popularity: 72, score: 0.85),
    ]

    func getRecommendations(for moodText: String) async throws -> RecommendationResult {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Simple mock: shuffle and return 5 songs
        // In production, the API handles NLP + recommendations
        let songs = Array(mockCatalog.shuffled().prefix(5))
        let mockVector = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
        return RecommendationResult(songs: songs, moodVector: mockVector)
    }
}
