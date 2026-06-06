//
//  ChatServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol ChatServiceProtocol {
    func sendMessage(_ message: String) async throws -> ChatResponseDTO
    func sendMessage(_ message: String, sessionVector: [Double]) async throws -> ChatResponseDTO
}
