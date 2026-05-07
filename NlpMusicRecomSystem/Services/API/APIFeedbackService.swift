//
//  APIFeedbackService.swift
//  NlpMusicRecomSystem
//
//  Real implementation of FeedbackServiceProtocol that sends swipe actions
//  to the FastAPI backend via the /swipe endpoint.
//

import Foundation

final class APIFeedbackService: FeedbackServiceProtocol {

    private let apiClient: APIClientProtocol
    private let userId: String

    init(apiClient: APIClientProtocol, userId: String = UUID().uuidString) {
        self.apiClient = apiClient
        self.userId = userId
    }

    func recordSwipe(songIndex: Int, action: String) async throws {
        let requestBody = SwipeRequestDTO(
            userId: userId,
            songIndex: songIndex,
            action: action
        )

        _ = try await apiClient.post(
            url: APIEnvironment.swipeURL,
            body: requestBody,
            responseType: SwipeResponseDTO.self
        )
    }
}
