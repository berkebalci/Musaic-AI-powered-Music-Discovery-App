//
//  ChatServiceProtocol.swift
//  NlpMusicRecomSystem
//

import Foundation

protocol ChatServiceProtocol {
    func sendMessage(_ message: String) async throws -> ChatResponseDTO
}
