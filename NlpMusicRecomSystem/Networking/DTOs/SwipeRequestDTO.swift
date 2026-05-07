//
//  SwipeRequestDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /swipe endpoint request.
//

import Foundation

/// Request body sent to `POST /swipe`.
/// Matches the FastAPI `SwipeRequest` model:
/// ```python
/// class SwipeRequest(BaseModel):
///     user_id: str
///     song_index: int
///     action: str  # "like" or "dislike"
/// ```
struct SwipeRequestDTO: Encodable {
    let userId: String
    let songIndex: Int
    let action: String  // "like" or "dislike"
}

/// Response from `POST /swipe`.
struct SwipeResponseDTO: Decodable {
    let status: String
    let totalLikes: Int
    let personalized: Bool
}
