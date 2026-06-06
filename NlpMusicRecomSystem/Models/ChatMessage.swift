//
//  ChatMessage.swift
//  NlpMusicRecomSystem
//

import Foundation

/// Represents a single message in the mood chat conversation.
struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    /// Optional song suggestions embedded within an AI reply.
    let suggestedSongs: [Song]
    /// When true, displays a typing indicator instead of content.
    let isLoading: Bool

    init(
        id: UUID = UUID(),
        content: String,
        isFromUser: Bool,
        timestamp: Date = Date(),
        suggestedSongs: [Song] = [],
        isLoading: Bool = false
    ) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.suggestedSongs = suggestedSongs
        self.isLoading = isLoading
    }

    // MARK: - Factory Helpers

    /// Creates a user message.
    static func user(_ text: String) -> ChatMessage {
        ChatMessage(content: text, isFromUser: true)
    }

    /// Creates an AI message with optional song suggestions.
    static func ai(_ text: String, songs: [Song] = []) -> ChatMessage {
        ChatMessage(content: text, isFromUser: false, suggestedSongs: songs)
    }

    /// Creates a loading placeholder for AI typing indicator.
    static func loading() -> ChatMessage {
        ChatMessage(content: "", isFromUser: false, isLoading: true)
    }
}
