//
//  NLPServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol NLPServiceProtocol {
    /// Analyzes the user's natural language mood input and returns a normalized 3D mood vector.
    func analyzeMood(from text: String) async throws -> MoodVector
}
//
