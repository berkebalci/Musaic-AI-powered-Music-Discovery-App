//
//  APIRecommendationService.swift
//  NlpMusicRecomSystem
//
//  Real implementation of RecommendationServiceProtocol that communicates
//  with the FastAPI backend via the APIClient.
//

import Foundation

final class APIRecommendationService: RecommendationServiceProtocol {

    private let apiClient: APIClientProtocol
    private let userId: String

    init(apiClient: APIClientProtocol, userId: String = UUID().uuidString) {
        self.apiClient = apiClient
        self.userId = userId
    }

    /// Sends the mood text to the API and retrieves recommended songs.
    /// The NLP processing happens entirely on the server side.
    func getRecommendations(for moodText: String) async throws -> [Song] {
        // 1. /chat endpoint'ine gidip NLP sonucunu (vektörü) alıyoruz
        print("\n==============================================")
        print("🎵 [1. AŞAMA] /chat isteği başlatılıyor...")
        print("   - Hedef URL: \(APIEnvironment.chatURL)")
        print("   - Gönderilen Metin: '\(moodText)'")
        
        let chatRequest = ChatRequestDTO(userId: userId, message: moodText)
        let chatResponse = try await apiClient.post(
            url: APIEnvironment.chatURL,
            body: chatRequest,
            responseType: ChatResponseDTO.self
        )
        
        print("🟢 [1. AŞAMA BAŞARILI] HTTP 200 OK")
        print("   - Botun Cevabı: '\(chatResponse.reply)'")
        print("   - Alınan Vektör: \(chatResponse.vector)")
        print("==============================================\n")

        // 2. Aldığımız vektörle /recommend endpoint'ine gidip şarkıları çekiyoruz
        print("\n==============================================")
        print("🎵 [2. AŞAMA] /recommend isteği başlatılıyor...")
        print("   - Hedef URL: \(APIEnvironment.recommendURL)")
        
        let recommendRequest = RecommendRequestDTO(
            userId: userId,
            moodVector: chatResponse.vector,
            n: 10
        )
        let recommendResponse = try await apiClient.post(
            url: APIEnvironment.recommendURL,
            body: recommendRequest,
            responseType: RecommendResponseDTO.self
        )
        
        print("🟢 [2. AŞAMA BAŞARILI] HTTP 200 OK")
        print("   - Dönen Şarkı Sayısı: \(recommendResponse.recommendations.count)")
        print("   - Şarkı Listesi:")
        
        for (index, song) in recommendResponse.recommendations.enumerated() {
            let name = song.trackName ?? "Bilinmiyor"
            let artist = song.artists ?? "Bilinmeyen Sanatçı"
            let score = String(format: "%.3f", song.score ?? 0.0)
            print("     [\(index + 1)] \(name) - \(artist) (Skor: \(score))")
        }
        print("==============================================\n")

        return recommendResponse.recommendations.enumerated().map { index, song in
            song.toDomain(index: index)
        }
    }
}
