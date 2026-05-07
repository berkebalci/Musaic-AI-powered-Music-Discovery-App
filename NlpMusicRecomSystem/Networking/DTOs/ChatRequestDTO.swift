//
//  ChatRequestDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /chat endpoint.
//

import Foundation

/// Request body sent to `POST /chat`.
/// Matches the FastAPI `ChatRequest` model:
/// ```python
/// class ChatRequest(BaseModel):
///     user_id: str
///     message: str
/// ```
struct ChatRequestDTO: Encodable {
    let userId: String
    let message: String
}

/// Response from `POST /chat`.
struct ChatResponseDTO: Decodable {
    let reply: String
    let songs: [SongDTO]
}
