//
//  APIRecommendationService.swift
//  NlpMusicRecomSystem
//
//  Real implementation of RecommendationServiceProtocol that communicates
//  with the FastAPI backend via the APIClient.
//

import Foundation

final class APIRecommendationService: RecommendationServiceProtocol {

    private let apiClient: APIClientProtocol
    private let userId: String

    init(apiClient: APIClientProtocol, userId: String = UUID().uuidString) {
        self.apiClient = apiClient
        self.userId = userId
    }

    /// Sends the mood text to the API and retrieves recommended songs.
    /// The NLP processing happens entirely on the server side.
    func getRecommendations(for moodText: String) async throws -> [Song] {
        let requestBody = RecommendRequestDTO(
            userId: userId,
            moodText: moodText
        )

        let response = try await apiClient.post(
            url: APIEnvironment.recommendURL,
            body: requestBody,
            responseType: RecommendResponseDTO.self
        )

        return response.songs.map { $0.toDomain() }
    }
}
