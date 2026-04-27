//
//  RecommendationServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol RecommendationServiceProtocol {
    /// Takes a mood vector and returns recommended songs from the ML model.
    func getRecommendations(for mood: MoodVector) async throws -> [Song]
}
