//
//  ChatViewModel.swift
//  NlpMusicRecomSystem
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ChatViewModel: ObservableObject {

    // MARK: - Published State

    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isAITyping: Bool = false
    @Published var statusText: String? = nil

    // MARK: - Session State

    /// The current session mood vector — evolves cumulatively with each chat message.
    private(set) var currentSessionVector: [Double] = Array(repeating: 0.5, count: 9)

    let moodPresets = [
        "Midnight drive",
        "Energetic & focused",
        "Mellow rainy day",
    ]

    // MARK: - Dependencies

    private let chatService: any ChatServiceProtocol
    private let recommendationService: any RecommendationServiceProtocol

    // MARK: - Init

    init(
        chatService: any ChatServiceProtocol,
        recommendationService: any RecommendationServiceProtocol
    ) {
        self.chatService = chatService
        self.recommendationService = recommendationService
    }

    // MARK: - Lifecycle

    /// Sets up the initial greeting message from the AI.
    func onAppear() {
        guard messages.isEmpty else { return }

        let greeting = ChatMessage.ai(
            "Hello! I'm your AI mood curator. Tell me how you're feeling, or describe a vibe you're looking for."
        )
        messages.append(greeting)
    }

    /// Called when user starts chat with a pre-set mood from the home screen.
    func startWithMood(_ moodText: String) {
        // Reset session for a fresh start
        currentSessionVector = Array(repeating: 0.5, count: 9)
        messages = []

        let greeting = ChatMessage.ai(
            "Hello! I'm your AI mood curator. Tell me how you're feeling, or describe a vibe you're looking for."
        )
        messages.append(greeting)

        // Auto-send the initial mood as a user message
        inputText = moodText
        Task { await sendMessage() }
    }

    // MARK: - User Intents

    func selectPreset(_ preset: String) {
        inputText = preset
        Task { await sendMessage() }
    }

    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // 1. Add user message
        let userMessage = ChatMessage.user(text)
        messages.append(userMessage)
        inputText = ""

        // 2. Show typing indicator
        isAITyping = true
        let loadingMessage = ChatMessage.loading()
        messages.append(loadingMessage)

        do {
            // 3. Send to chat endpoint with current session vector
            let response = try await chatService.sendMessage(
                text,
                sessionVector: currentSessionVector
            )

            // 4. Update session vector with the evolved one from backend
            currentSessionVector = response.vector
            print("🔄 Session vector updated: \(currentSessionVector.map { String(format: "%.2f", $0) })")

            // 5. Remove loading indicator
            messages.removeAll { $0.id == loadingMessage.id }

            // 6. Try to get song recommendations using the new vector
            statusText = "Curating a temporary playlist for this vibe..."

            var suggestedSongs: [Song] = []
            do {
                suggestedSongs = try await recommendationService.getRecommendations(
                    for: currentSessionVector,
                    count: 5
                )
                print("🎵 Chat returned \(suggestedSongs.count) songs:")
                for (index, song) in suggestedSongs.enumerated() {
                    print("   [\(index + 1)] \(song.title) - \(song.artistName)")
                }
            } catch {
                print("⚠️ Could not fetch song recommendations: \(error)")
            }

            statusText = nil

            // 7. Add AI reply with optional song suggestions
            let aiMessage = ChatMessage.ai(response.reply, songs: suggestedSongs)
            messages.append(aiMessage)

        } catch let error as APIError {
            // Remove loading indicator on error
            messages.removeAll { $0.id == loadingMessage.id }
            statusText = nil

            let errorText: String
            switch error {
            case .authenticationRequired:
                errorText = "Authentication required. Please make sure you're signed in and try again."
                print("❌ Chat auth error: Firebase user may not be signed in or token expired")
            case .networkUnavailable:
                errorText = "No internet connection. Please check your network and try again."
            default:
                errorText = "Something went wrong. Please try again."
            }

            let errorMessage = ChatMessage.ai(errorText)
            messages.append(errorMessage)
            print("❌ Chat error: \(error)")
        } catch {
            // Remove loading indicator on error
            messages.removeAll { $0.id == loadingMessage.id }
            statusText = nil

            let errorMessage = ChatMessage.ai(
                "Sorry, I couldn't process that. Please try again."
            )
            messages.append(errorMessage)
            print("❌ Chat error: \(error)")
        }

        isAITyping = false
    }

    /// Resets the chat session entirely.
    func resetSession() {
        messages = []
        currentSessionVector = Array(repeating: 0.5, count: 9)
        inputText = ""
        statusText = nil
        isAITyping = false
    }
}
