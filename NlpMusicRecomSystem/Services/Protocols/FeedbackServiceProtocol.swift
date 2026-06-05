//
//  FeedbackServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol FeedbackServiceProtocol {
    /// Submits the complete swipe session to the server.
    /// The server writes liked songs to Firestore and updates the mood vector.
    /// - Returns: The updated mood vector from the server.
    @discardableResult
    func submitSwipeSession(
        likedSongs: [LikedSongItemDTO],
        dislikedSongIds: [Int],
        currentMoodVector: [Double]
    ) async throws -> [Double]
}
