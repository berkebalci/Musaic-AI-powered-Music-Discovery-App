//
//  RecommendationServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

/// Result from the recommendation flow containing both songs and the mood vector.
struct RecommendationResult {
    let songs: [Song]
    let moodVector: [Double]
}

protocol RecommendationServiceProtocol {
    /// Takes a mood text string and returns recommended songs along with the mood vector.
    /// The NLP analysis is performed server-side.
    func getRecommendations(for moodText: String) async throws -> RecommendationResult
}
