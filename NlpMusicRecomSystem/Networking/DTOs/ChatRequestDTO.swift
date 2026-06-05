//
//  ChatRequestDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /api/chat endpoint.
//  Authentication is handled via Firebase ID token in the Authorization header.
//

import Foundation

/// Request body sent to `POST /api/chat`.
/// Matches the FastAPI `ChatRequest` model:
/// ```python
/// class ChatRequest(BaseModel):
///     message: str
/// ```
struct ChatRequestDTO: Encodable {
    let message: String
}

/// Response from `POST /api/chat`.
/// The vector contains 9 Spotify audio features:
/// [danceability, energy, valence, tempo, acousticness, instrumentalness, speechiness, loudness, liveness]
struct ChatResponseDTO: Decodable {
    let reply: String
    let vector: [Double]
}
