//
//  AppleMusicServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation
import MusicKit

protocol AppleMusicServiceProtocol {
    /// Searches Apple Music catalog for a song with the given title and artist.
    /// Returns the fetched MusicKit Song object.
    func searchSong(title: String, artist: String) async throws -> MusicKit.Song?
}
