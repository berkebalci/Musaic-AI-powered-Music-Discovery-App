//
//  SwipeRequestDTO.swift
//  NlpMusicRecomSystem
//
//  Data Transfer Object for the /api/swipe endpoint.
//  The API uses a batch swipe model with separate liked/disliked collections.
//  Authentication is handled via Firebase ID token in the Authorization header.
//

import Foundation

/// A liked song with full details for Firestore storage.
/// Matches the FastAPI `LikedSongItem` model:
/// ```python
/// class LikedSongItem(BaseModel):
///     song_id: int
///     title: str
///     artist: str
///     album_art: Optional[str] = ""
///     apple_music_id: Optional[str] = ""
/// ```
struct LikedSongItemDTO: Encodable {
    let songId: Int
    let title: String
    let artist: String
    let albumArt: String
    let appleMusicId: String
}

/// Request body sent to `POST /api/swipe`.
/// Matches the FastAPI `BatchSwipeRequest` model:
/// ```python
/// class BatchSwipeRequest(BaseModel):
///     liked_songs: List[LikedSongItem]
///     disliked_song_ids: List[int]
///     current_mood_vector: List[float]
/// ```
struct BatchSwipeRequestDTO: Encodable {
    let likedSongs: [LikedSongItemDTO]
    let dislikedSongIds: [Int]
    let currentMoodVector: [Double]
}

/// Response from `POST /api/swipe`.
/// API returns: {"status": "success", "new_profile_vector": [...], "liked_count": N}
/// Note: APIClient uses `.convertFromSnakeCase` so property names auto-map.
struct BatchSwipeResponseDTO: Decodable {
    let status: String
    let newProfileVector: [Double]
    let likedCount: Int
}
