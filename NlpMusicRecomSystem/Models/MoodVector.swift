//
//  MoodVector.swift
//  NlpMusicRecomSystem
//

import Foundation

struct MoodVector: Codable, Equatable {
    /// Sadness level (0.0 = happy, 1.0 = very sad)
    let sadness: Double
    /// Energy level (0.0 = calm, 1.0 = very energetic)
    let energy: Double
    /// Preferred tempo (0.0 = slow, 1.0 = fast)
    let tempo: Double

    var normalized: [Double] {
        [sadness, energy, tempo]
    }

    var dominantMood: String {
        if sadness > 0.6 { return "Melancholic" }
        if energy > 0.7 { return "Energetic" }
        if tempo < 0.3 && energy < 0.3 { return "Chill" }
        if sadness < 0.3 && energy > 0.5 { return "Upbeat" }
        return "Balanced"
    }
}
