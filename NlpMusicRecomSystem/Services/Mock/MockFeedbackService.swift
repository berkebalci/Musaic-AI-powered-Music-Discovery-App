//
//  MockFeedbackService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class MockFeedbackService: FeedbackServiceProtocol {

    func recordSwipe(songIndex: Int, action: String) async throws {
        print("[MockFeedback] Recorded swipe: songIndex=\(songIndex), action=\(action)")
    }
}
