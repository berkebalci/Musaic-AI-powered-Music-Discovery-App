//
//  FeedbackServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol FeedbackServiceProtocol {
    /// Records a user interaction (like/dislike) for model retraining.
    func recordInteraction(_ interaction: UserInteraction) async throws
}
