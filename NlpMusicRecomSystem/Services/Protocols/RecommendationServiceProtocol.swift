//
//  RecommendationServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol RecommendationServiceProtocol {
    /// Takes a mood text string and returns recommended songs from the API.
    /// The NLP analysis is performed server-side.
    func getRecommendations(for moodText: String) async throws -> [Song]
}
