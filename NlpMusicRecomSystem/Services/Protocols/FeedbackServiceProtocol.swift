//
//  FeedbackServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol FeedbackServiceProtocol {
    /// Records a user swipe action (like/dislike) for a specific song.
    func recordSwipe(songIndex: Int, action: String) async throws
}
