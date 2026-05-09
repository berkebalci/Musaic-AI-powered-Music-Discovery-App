//
//  RecommendRequestDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /recommend endpoint request.
//

import Foundation

/// Request body sent to `POST /recommend`.
/// Matches the FastAPI `RecommendRequest` model:
/// ```python
/// class RecommendRequest(BaseModel):
///     user_id: str
///     mood_vector: Optional[List[float]] = None
///     n: int = 10
/// ```
///
/// In our new architecture, the user sends a mood text string.
/// The server processes it via NLP and generates recommendations.
struct RecommendRequestDTO: Encodable {
    let userId: String
    let moodVector: [Double]
    let n: Int

    init(userId: String, moodVector: [Double], n: Int = 10) {
        self.userId = userId
        self.moodVector = moodVector
        self.n = n
    }
}
