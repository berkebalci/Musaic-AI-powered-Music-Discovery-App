//
//  DiscoveryViewModel.swift
//  NlpMusicRecomSystem
//

import Foundation
import SwiftUI
import Combine

enum DiscoveryState: Equatable {
    case landing
    case moodInput
    case loading
    case swipeCards
    case empty
    case error(String)
}

final class DiscoveryViewModel: ObservableObject {

    // MARK: - Published State

    @Published var moodText: String = ""
    @Published var state: DiscoveryState = .landing
    @Published var cards: [Song] = []
    
    var currentSong: Song? { cards.first }
    var currentIndex: Int {
        guard let currentSong = currentSong else { return 0 }
        return cards.firstIndex(of: currentSong) ?? 0
    }
    var visibleCards: [Song] { Array(cards.prefix(3)) }

    let moodPresets = [
        "Midnight drive",
        "Energetic & focused",
        "Mellow rainy day",
        "Sunday chill vibes",
        "Feeling sad today",
    ]

    // MARK: - Dependencies

    private let recommendationService: any RecommendationServiceProtocol
    private let feedbackService: any FeedbackServiceProtocol
    private let audioplayer: AudioPlayerViewModel

    // MARK: - Swipe Session State

    /// Accumulates liked songs during a swipe session (with full details for Firestore).
    private var likedSongs: [LikedSongItemDTO] = []
    /// Accumulates disliked song IDs during a swipe session.
    private var dislikedSongIds: [Int] = []
    /// The persistent mood vector representing the user's music taste.
    /// Initialized to a neutral 9D vector as per backend requirements.
    private var currentMoodVector: [Double] = Array(repeating: 0.5, count: 9)
    /// Tracks whether a swipe submission is in progress.
    private var isSubmitting: Bool = false

    // MARK: - Init

    init(
        recommendationService: any RecommendationServiceProtocol,
        feedbackService: any FeedbackServiceProtocol,
        audioPlayer: AudioPlayerViewModel
    ) {
        self.recommendationService = recommendationService
        self.feedbackService = feedbackService
        self.audioplayer = audioPlayer
    }

    // MARK: - User Intents

    func selectPreset(_ preset: String) {
        moodText = preset
    }

    /// Sends the mood text directly to the API.
    /// NLP analysis is performed server-side — no local MoodVector needed.
    @MainActor
    func analyzeMoodAndFetchSongs() async {
        guard !moodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        state = .loading

        // Reset swipe session for the new batch
        likedSongs = []
        dislikedSongIds = []

        do {
            let result = try await recommendationService.getRecommendations(for: moodText)

            cards = result.songs
            currentMoodVector = result.moodVector

            state = result.songs.isEmpty ? .empty : .swipeCards
            
            if let firstSong = result.songs.first {
                audioplayer.play(song: firstSong)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    func swipeRight(on song: Song) async {
        print("saga kaydirildi, song title: \(song.title)")

        // Accumulate the liked song with full details
        let likedItem = LikedSongItemDTO(
            songId: song.id,
            title: song.title,
            artist: song.artistName,
            albumArt: song.imageUrl ?? "",
            appleMusicId: song.appleMusicId ?? ""
        )
        likedSongs.append(likedItem)
        
        removeTopCard()
        
        if let nextSong = currentSong {
            audioplayer.play(song: nextSong)
        } else {
            audioplayer.stop()
        }
    }

    @MainActor
    func swipeLeft(on song: Song) async {
        // Accumulate the disliked song ID
        dislikedSongIds.append(song.id)
            
        removeTopCard()
        
        if let nextSong = currentSong {
            audioplayer.play(song: nextSong)
        } else {
            audioplayer.stop()
        }
    }
    
    
    /// Fetches songs using the persistent mood vector (or default neutral).
    /// Called from DiscoveryLandingView's "Start Discovering" button.
    @MainActor
    func fetchSongsWithDefaultMood() async {
        state = .loading

        // Reset swipe session for the new batch
        likedSongs = []
        dislikedSongIds = []

        do {
            let songs = try await recommendationService.getRecommendations(
                for: currentMoodVector,
                count: 15
            )
            cards = songs
            state = songs.isEmpty ? .empty : .swipeCards
            
            if let firstSong = songs.first {
                audioplayer.play(song: firstSong)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    func goBackToMoodInput() {
        state = .landing
        cards = []
        moodText = ""
        audioplayer.stop()
        // Only clear session data if not currently submitting
        if !isSubmitting {
            likedSongs = []
            dislikedSongIds = []
        }
    }

    // MARK: - Private Helpers

    @MainActor
    private func removeTopCard() {
        guard !cards.isEmpty else { return }
        cards.removeFirst()

        if cards.isEmpty {
            // All cards swiped — submit the session to the server BEFORE changing state
            // This ensures the data is captured before any UI cleanup
            Task {
                await submitSwipeSession()
                state = .empty
            }
        }
    }

    /// Sends all accumulated swipe data to the server in one batch request.
    /// Called automatically when all cards have been swiped.
    @MainActor
    private func submitSwipeSession() async {
        // Only submit if there's something to send
        guard !likedSongs.isEmpty || !dislikedSongIds.isEmpty else {
            print("⚠️ submitSwipeSession çağrıldı ama gönderilecek veri yok")
            return
        }

        isSubmitting = true
        print("📤 Swipe oturumu gönderiliyor...")
        print("   - Beğenilen: \(likedSongs.count) şarkı")
        print("   - Beğenilmeyen: \(dislikedSongIds.count) şarkı")
        print("   - Vektör boyutu: \(currentMoodVector.count)")

        do {
            let newVector = try await feedbackService.submitSwipeSession(
                likedSongs: likedSongs,
                dislikedSongIds: dislikedSongIds,
                currentMoodVector: currentMoodVector
            )
            currentMoodVector = newVector
            print("✅ Swipe oturumu başarıyla gönderildi. Yeni vektör: \(newVector)")
        } catch {
            print("❌ Swipe oturumu gönderilemedi: \(error)")
            print("   Hata detayı: \(error.localizedDescription)")
        }

        // Clear session data
        likedSongs = []
        dislikedSongIds = []
        isSubmitting = false
    }
}
