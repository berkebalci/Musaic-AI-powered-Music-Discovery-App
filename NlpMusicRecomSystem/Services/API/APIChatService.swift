//
//  APIChatService.swift
//  NlpMusicRecomSystem
//

import Foundation

final class APIChatService: ChatServiceProtocol {
    private let apiClient: APIClientProtocol
    private let userId: String

    init(apiClient: APIClientProtocol, userId: String = UUID().uuidString) {
        self.apiClient = apiClient
        self.userId = userId
    }

    func sendMessage(_ message: String) async throws -> ChatResponseDTO {
        let requestBody = ChatRequestDTO(
            userId: userId,
            message: message
        )
        
        print("💬 /chat isteği başlatıldı. Mesaj: '\(message)'")

        let response = try await apiClient.post(
            url: APIEnvironment.chatURL,
            body: requestBody,
            responseType: ChatResponseDTO.self
        )
        
        print("✅ /chat başarılı! Sunucu cevabı: \(response.reply)")
        print("Vektör uzunluğu: \(response.vector.count)")
        
        return response
    }
}
