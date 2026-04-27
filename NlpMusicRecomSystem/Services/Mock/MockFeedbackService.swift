//
//  MockFeedbackService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class MockFeedbackService: FeedbackServiceProtocol {

    private var interactions: [UserInteraction] = []

    func recordInteraction(_ interaction: UserInteraction) async throws {
        interactions.append(interaction)
        print("[MockFeedback] Recorded: song=\(interaction.songId), label=\(interaction.label)")
    }
}
