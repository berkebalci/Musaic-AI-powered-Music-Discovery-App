//
//  RecommendRequestDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /api/recommend endpoint request.
//  Authentication is handled via Firebase ID token in the Authorization header.
//

import Foundation

/// Request body sent to `POST /api/recommend`.
/// Matches the FastAPI `RecommendRequest` model:
/// ```python
/// class RecommendRequest(BaseModel):
///     mood_vector: List[float]
///     n: int = 15
/// ```
struct RecommendRequestDTO: Encodable {
    let moodVector: [Double]
    let n: Int

    init(moodVector: [Double], n: Int = 15) {
        self.moodVector = moodVector
        self.n = n
    }
}
