//
//  Song.swift
//  NlpMusicRecomSystem
//

import Foundation

struct Song: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artistName: String
    let albumName: String
    let artworkURLString: String?
    let previewURLString: String?
    let genre: String
    let moodTags: [String]
    let durationInSeconds: Int

    var artworkURL: URL? {
        guard let urlString = artworkURLString else { return nil }
        return URL(string: urlString)
    }

    var previewURL: URL? {
        guard let urlString = previewURLString else { return nil }
        return URL(string: urlString)
    }

    var formattedDuration: String {
        let minutes = durationInSeconds / 60
        let seconds = durationInSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
