//
//  AppleMusicService.swift
//  NlpMusicRecomSystem
//

import Foundation
import MusicKit

final class AppleMusicService: AppleMusicServiceProtocol {
    
    init() {}
    
    func searchSong(title: String, artist: String) async throws -> MusicKit.Song? {
        // Clean dataset noise (e.g. semicolons separating artists, slashes) for better search matching
        let sanitizedArtist = artist.replacingOccurrences(of: ";", with: " ")
            .replacingOccurrences(of: "/\\", with: " ")
            .replacingOccurrences(of: "/", with: " ")
        let searchTerm = "\(title) \(sanitizedArtist)".trimmingCharacters(in: .whitespaces)
        var request = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Song.self])
        request.limit = 1
        
        do {
            let response = try await request.response()
            return response.songs.first
        } catch {
            // If the task was cancelled (e.g., user navigated away or view dismissed), don't log as an error
            if Task.isCancelled || (error as? URLError)?.code == .cancelled {
                return nil
            }
            print("❌ AppleMusicService search error for \(searchTerm): \(error)")
            return nil
        }
    }
}
