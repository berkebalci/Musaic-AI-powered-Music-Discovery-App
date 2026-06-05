//
//  MoodVector.swift
//  NlpMusicRecomSystem
//
//  Represents the 9-dimensional mood vector returned by the Gemini model.
//  All values are normalized to 0.0–1.0.
//

import Foundation

struct MoodVector: Codable, Equatable {
    /// How suitable the track is for dancing (0.0 = least, 1.0 = most)
    let danceability: Double
    /// Intensity and activity level (0.0 = calm, 1.0 = very energetic)
    let energy: Double
    /// Musical positiveness (0.0 = negative/sad, 1.0 = positive/happy)
    let valence: Double
    /// Tempo normalized (0.0 = 60 BPM, 1.0 = 180 BPM)
    let tempo: Double
    /// Confidence the track is acoustic (0.0 = electric, 1.0 = acoustic)
    let acousticness: Double
    /// Whether the track contains no vocals (0.0 = vocal, 1.0 = instrumental)
    let instrumentalness: Double
    /// Presence of spoken words (0.0 = music only, 1.0 = speech-like)
    let speechiness: Double
    /// Overall loudness normalized (0.0 = quiet, 1.0 = loud)
    let loudness: Double
    /// Probability of a live audience (0.0 = studio, 1.0 = live)
    let liveness: Double

    var normalized: [Double] {
        [danceability, energy, valence, tempo, acousticness,
         instrumentalness, speechiness, loudness, liveness]
    }

    var dominantMood: String {
        if valence < 0.3 && energy < 0.4 { return "Melancholic" }
        if energy > 0.7 && danceability > 0.6 { return "Energetic" }
        if acousticness > 0.7 && energy < 0.4 { return "Chill" }
        if valence > 0.6 && energy > 0.5 { return "Upbeat" }
        if instrumentalness > 0.7 { return "Atmospheric" }
        return "Balanced"
    }
}
