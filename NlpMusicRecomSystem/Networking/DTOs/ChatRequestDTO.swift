//
//  ChatRequestDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /api/chat endpoint.
//  Authentication is handled via Firebase ID token in the Authorization header.
//

import Foundation

/// Request body sent to `POST /api/chat`.
/// Supports cumulative mood evolution by including the current session vector.
/// Matches the FastAPI `ChatRequest` model:
/// ```python
/// class ChatRequest(BaseModel):
///     message: str
///     current_session_vector: List[float]  # 9D mood vector
/// ```
struct ChatRequestDTO: Encodable {
    let message: String
    /// The current session mood vector (9D).
    /// Sent to the backend so the AI can refine the mood cumulatively.
    let currentSessionVector: [Double]

    init(message: String, currentSessionVector: [Double] = Array(repeating: 0.5, count: 9)) {
        self.message = message
        self.currentSessionVector = currentSessionVector
    }
}

/// Response from `POST /api/chat`.
/// The vector contains 9 Spotify audio features:
/// [danceability, energy, valence, tempo, acousticness, instrumentalness, speechiness, loudness, liveness]
struct ChatResponseDTO: Decodable {
    let reply: String
    let vector: [Double]
}
