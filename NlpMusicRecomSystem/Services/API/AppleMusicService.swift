//
//  AppleMusicService.swift
//  NlpMusicRecomSystem
//

import Foundation
import MusicKit

final class AppleMusicService: AppleMusicServiceProtocol {
    
    init() {}
    
    func searchSong(title: String, artist: String) async throws -> MusicKit.Song? {
        let searchTerm = "\(title) \(artist)"
        var request = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Song.self])
        request.limit = 1
        
        do {
            let response = try await request.response()
            return response.songs.first
        } catch {
            print("❌ AppleMusicService search error for \(searchTerm): \(error)")
            return nil
        }
    }
}
