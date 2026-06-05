//
//  MockFeedbackService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class MockFeedbackService: FeedbackServiceProtocol {

    @discardableResult
    func submitSwipeSession(
        likedSongs: [LikedSongItemDTO],
        dislikedSongIds: [Int],
        currentMoodVector: [Double]
    ) async throws -> [Double] {
        print("[MockFeedback] Session submitted: \(likedSongs.count) likes, \(dislikedSongIds.count) dislikes")
        return currentMoodVector
    }
}
