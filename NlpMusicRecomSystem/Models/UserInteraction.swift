//
//  UserInteraction.swift
//  NlpMusicRecomSystem
//

import Foundation

struct UserInteraction: Identifiable, Codable {
    let id: String
    let songId: String
    let moodVector: MoodVector
    let label: Int // 1 = Like, 0 = Dislike
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        songId: String,
        moodVector: MoodVector,
        label: Int,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.songId = songId
        self.moodVector = moodVector
        self.label = label
        self.timestamp = timestamp
    }
}
