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
    private let appleMusicService: AppleMusicServiceProtocol

    init(apiClient: APIClientProtocol, appleMusicService: AppleMusicServiceProtocol) {
        self.apiClient = apiClient
        self.appleMusicService = appleMusicService
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

        let initialSongs = recommendResponse.feed.enumerated().map { index, song in
            song.toDomain(fallbackIndex: index)
        }
        
        let enrichedSongs = await fetchAppleMusicData(for: initialSongs)

        return RecommendationResult(songs: enrichedSongs, moodVector: chatResponse.vector)
    }

    /// Fetches song recommendations using a pre-computed mood vector.
    /// Used by ChatViewModel after the chat endpoint produces a session vector.
    func getRecommendations(for vector: [Double], count: Int = 5) async throws -> [Song] {
        let requestBody = RecommendRequestDTO(moodVector: vector, n: count)
        let response = try await apiClient.post(
            url: APIEnvironment.recommendURL,
            body: requestBody,
            responseType: RecommendResponseDTO.self
        )

        let initialSongs = response.feed.enumerated().map { index, song in
            song.toDomain(fallbackIndex: index)
        }
        
        return await fetchAppleMusicData(for: initialSongs)
    }
    
    // MARK: - Apple Music Enrichment
    
    private func fetchAppleMusicData(for songs: [Song]) async -> [Song] {
        var enrichedSongs = songs
        
        print("\n🎵 [3. AŞAMA] Apple Music API'den metadata çekiliyor...")
        
        await withTaskGroup(of: (Int, MusicKit.Song?).self) { group in
            for index in 0..<songs.count {
                let song = songs[index]
                group.addTask {
                    let amSong = try? await self.appleMusicService.searchSong(title: song.title, artist: song.artistName)
                    return (index, amSong)
                }
            }
            
            for await (index, amSong) in group {
                if let amSong = amSong {
                    enrichedSongs[index].appleMusicId = amSong.id.rawValue
                    enrichedSongs[index].title = amSong.title
                    enrichedSongs[index].artistName = amSong.artistName
                    if let duration = amSong.duration {
                        enrichedSongs[index].durationInMillis = Int(duration * 1000)
                    }
                    if let artworkUrl = amSong.artwork?.url(width: 600, height: 600) {
                        enrichedSongs[index].imageUrl = artworkUrl.absoluteString
                    }
                }
            }
        }
        
        print("🟢 [3. AŞAMA BAŞARILI] Tüm şarkılar Apple Music metadatası ile güncellendi.")
        return enrichedSongs
    }
}
