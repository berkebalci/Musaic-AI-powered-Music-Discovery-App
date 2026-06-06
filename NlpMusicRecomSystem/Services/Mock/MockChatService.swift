//
//  MockChatService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class MockChatService: ChatServiceProtocol {

    private let mockReplies: [String] = [
        "I hear you. There's a specific kind of beauty in that mood. This should match the atmosphere perfectly:",
        "That's a great vibe! Let me find something that captures exactly that feeling...",
        "I know just the right sound for this moment. Here's what I'd recommend:",
        "Your mood paints a vivid picture. Let me curate something special for you:",
    ]

    func sendMessage(_ message: String) async throws -> ChatResponseDTO {
        try await sendMessage(message, sessionVector: Array(repeating: 0.5, count: 9))
    }

    func sendMessage(_ message: String, sessionVector: [Double]) async throws -> ChatResponseDTO {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000)

        let reply = mockReplies.randomElement() ?? mockReplies[0]
        // Slightly perturb the session vector to simulate evolution
        let mockVector = sessionVector.map { min(1.0, max(0.0, $0 + Double.random(in: -0.1...0.1))) }

        return ChatResponseDTO(reply: reply, vector: mockVector)
    }
}
