//
//  MockRecommendationService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class MockRecommendationService: RecommendationServiceProtocol {

    private let mockCatalog: [Song] = [
        Song(id: "1", title: "After Hours", artistName: "The Weeknd", albumName: "After Hours",
             artworkURLString: nil, previewURLString: nil,
             genre: "Alternative R&B", moodTags: ["Melancholic", "Atmospheric"], durationInSeconds: 361),
        Song(id: "2", title: "Midnight City", artistName: "M83", albumName: "Hurry Up, We're Dreaming",
             artworkURLString: nil, previewURLString: nil,
             genre: "Synth Pop", moodTags: ["Energetic", "Nostalgic"], durationInSeconds: 244),
        Song(id: "3", title: "Levitating", artistName: "Dua Lipa", albumName: "Future Nostalgia",
             artworkURLString: nil, previewURLString: nil,
             genre: "Pop", moodTags: ["Upbeat", "Danceable"], durationInSeconds: 203),
        Song(id: "4", title: "Heat Waves", artistName: "Glass Animals", albumName: "Dreamland",
             artworkURLString: nil, previewURLString: nil,
             genre: "Indie Pop", moodTags: ["Chill", "Dreamy"], durationInSeconds: 238),
        Song(id: "5", title: "Starlight", artistName: "The Midnight", albumName: "Endless Summer",
             artworkURLString: nil, previewURLString: nil,
             genre: "Synthwave", moodTags: ["Atmospheric", "Uplifting"], durationInSeconds: 275),
        Song(id: "6", title: "Numb Little Bug", artistName: "Em Beihold", albumName: "Numb Little Bug",
             artworkURLString: nil, previewURLString: nil,
             genre: "Pop", moodTags: ["Melancholic", "Relatable"], durationInSeconds: 169),
        Song(id: "7", title: "Blinding Lights", artistName: "The Weeknd", albumName: "After Hours",
             artworkURLString: nil, previewURLString: nil,
             genre: "Synth Pop", moodTags: ["Energetic", "Retro"], durationInSeconds: 200),
        Song(id: "8", title: "Somebody Else", artistName: "The 1975", albumName: "I Like It When You Sleep",
             artworkURLString: nil, previewURLString: nil,
             genre: "Indie Pop", moodTags: ["Melancholic", "Atmospheric"], durationInSeconds: 325),
    ]

    func getRecommendations(for mood: MoodVector) async throws -> [Song] {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Simple mock: shuffle and return 5 songs
        // In production, the ML model would rank songs by mood vector similarity
        return Array(mockCatalog.shuffled().prefix(5))
    }
}
