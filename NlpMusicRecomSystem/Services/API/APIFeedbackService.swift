//
//  APIFeedbackService.swift
//  NlpMusicRecomSystem
//
//  Real implementation of FeedbackServiceProtocol that sends batch swipe actions
//  to the FastAPI backend via the /api/swipe endpoint.
//  The new API expects all swipes at once (liked songs with details,
//  disliked song IDs, and the current mood vector).
//  Authentication is handled by the APIClient's token provider.
//

import Foundation

final class APIFeedbackService: FeedbackServiceProtocol {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    /// Sends the complete swipe session to the API.
    /// - Parameters:
    ///   - likedSongs: Songs the user swiped right on (with full details for Firestore)
    ///   - dislikedSongIds: IDs of songs the user swiped left on
    ///   - currentMoodVector: The current mood vector to be updated by the server
    /// - Returns: The updated mood vector from the server
    @discardableResult
    func submitSwipeSession(
        likedSongs: [LikedSongItemDTO],
        dislikedSongIds: [Int],
        currentMoodVector: [Double]
    ) async throws -> [Double] {
        let requestBody = BatchSwipeRequestDTO(
            likedSongs: likedSongs,
            dislikedSongIds: dislikedSongIds,
            currentMoodVector: currentMoodVector
        )

        let response = try await apiClient.post(
            url: APIEnvironment.swipeURL,
            body: requestBody,
            responseType: BatchSwipeResponseDTO.self
        )

        print("✅ Swipe oturumu gönderildi: ")
        return response.newProfileVector
    }
}
