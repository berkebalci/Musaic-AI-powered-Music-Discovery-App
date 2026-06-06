//
//  APIChatService.swift
//  NlpMusicRecomSystem
//
//  Authentication is handled by the APIClient's token provider.
//

import Foundation

final class APIChatService: ChatServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func sendMessage(_ message: String) async throws -> ChatResponseDTO {
        try await sendMessage(message, sessionVector: Array(repeating: 0.5, count: 9))
    }

    func sendMessage(_ message: String, sessionVector: [Double]) async throws -> ChatResponseDTO {
        let requestBody = ChatRequestDTO(
            message: message,
            currentSessionVector: sessionVector
        )

        print("💬 /api/chat isteği başlatıldı. Mesaj: '\(message)'")

        let response = try await apiClient.post(
            url: APIEnvironment.chatURL,
            body: requestBody,
            responseType: ChatResponseDTO.self
        )

        print("✅ /api/chat başarılı! Sunucu cevabı: \(response.reply)")
        print("Vektör uzunluğu: \(response.vector.count)")

        return response
    }
}

