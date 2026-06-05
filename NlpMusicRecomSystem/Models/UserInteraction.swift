//
//  UserInteraction.swift
//  NlpMusicRecomSystem
//
//  Represents a user interaction (swipe) with a song.
//  Simplified to match the new API structure where interactions
//  are managed server-side via Firebase.
//

import Foundation

struct UserInteraction: Identifiable, Codable {
    let id: String
    let songId: Int
    let action: String  // "like" or "dislike"
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        songId: Int,
        action: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.songId = songId
        self.action = action
        self.timestamp = timestamp
    }
}
