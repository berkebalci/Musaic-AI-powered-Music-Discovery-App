//
//  APIRecommendationService.swift
//  NlpMusicRecomSystem
//
//  Real implementation of RecommendationServiceProtocol that communicates
//  with the FastAPI backend via the APIClient.
//  Authentication is handled by the APIClient's token provider.
//

import Foundation

final class APIRecommendationService: RecommendationServiceProtocol {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    /// Sends the mood text to the API and retrieves recommended songs.
    /// The NLP processing happens entirely on the server side.
    func getRecommendations(for moodText: String) async throws -> RecommendationResult {
        // 1. /api/chat endpoint'ine gidip NLP sonucunu (vektörü) alıyoruz
        print("\n==============================================")
        print("🎵 [1. AŞAMA] /api/chat isteği başlatılıyor...")
        print("   - Hedef URL: \(APIEnvironment.chatURL)")
        print("   - Gönderilen Metin: '\(moodText)'")
        
        let chatRequest = ChatRequestDTO(message: moodText)
        let chatResponse = try await apiClient.post(
            url: APIEnvironment.chatURL,
            body: chatRequest,
            responseType: ChatResponseDTO.self
        )
        
        print("🟢 [1. AŞAMA BAŞARILI] HTTP 200 OK")
        print("   - Botun Cevabı: '\(chatResponse.reply)'")
        print("   - Alınan Vektör (\(chatResponse.vector.count) boyut): \(chatResponse.vector)")
        print("==============================================\n")

        // 2. Aldığımız vektörle /api/recommend endpoint'ine gidip şarkıları çekiyoruz
        print("\n==============================================")
        print("🎵 [2. AŞAMA] /api/recommend isteği başlatılıyor...")
        print("   - Hedef URL: \(APIEnvironment.recommendURL)")
        
        let recommendRequest = RecommendRequestDTO(
            moodVector: chatResponse.vector,
            n: 15
        )
        let recommendResponse = try await apiClient.post(
            url: APIEnvironment.recommendURL,
            body: recommendRequest,
            responseType: RecommendResponseDTO.self
        )
        
        print("🟢 [2. AŞAMA BAŞARILI] HTTP 200 OK")
        print("   - Dönen Şarkı Sayısı: \(recommendResponse.feed.count)")
        print("   - Şarkı Listesi:")
        
        for (index, song) in recommendResponse.feed.enumerated() {
            let name = song.trackName ?? "Bilinmiyor"
            let artist = song.artists ?? "Bilinmeyen Sanatçı"
            let score = String(format: "%.3f", song.matchScore ?? 0.0)
            print("     [\(index + 1)] \(name) - \(artist) (Skor: \(score))")
        }
        print("==============================================\n")

        let songs = recommendResponse.feed.enumerated().map { index, song in
            song.toDomain(fallbackIndex: index)
        }

        return RecommendationResult(songs: songs, moodVector: chatResponse.vector)
    }
}
