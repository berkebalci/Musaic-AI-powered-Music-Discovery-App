//
//  DiscoveryViewModel.swift
//  NlpMusicRecomSystem
//

import Foundation
import SwiftUI
import Combine

enum DiscoveryState: Equatable {
    case moodInput
    case loading
    case swipeCards
    case empty
    case error(String)
}

final class DiscoveryViewModel: ObservableObject {

    // MARK: - Published State

    @Published var moodText: String = ""
    @Published var state: DiscoveryState = .moodInput
    @Published var cards: [Song] = []
   
    var currentSong: Song? { cards.first }
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
    private let favoritesService: any FavoritesServiceProtocol
    private let feedbackService: any FeedbackServiceProtocol

    // MARK: - Init

    init(
        recommendationService: any RecommendationServiceProtocol,
        favoritesService: any FavoritesServiceProtocol,
        feedbackService: any FeedbackServiceProtocol
    ) {
        self.recommendationService = recommendationService
        self.favoritesService = favoritesService
        self.feedbackService = feedbackService
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

        do {
            let songs = try await recommendationService.getRecommendations(for: moodText)

            cards = songs

            state = songs.isEmpty ? .empty : .swipeCards
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    func swipeRight(on song: Song) async {
        print("saga kaydirildi, song title: \(song.title)")
        let songIndex = Int(song.id) ?? 0

        try? await feedbackService.recordSwipe(songIndex: songIndex, action: "like")
        try? await favoritesService.addFavorite(song)

        removeTopCard()
    }

    @MainActor
    func swipeLeft(on song: Song) async {
        let songIndex = Int(song.id) ?? 0

        try? await feedbackService.recordSwipe(songIndex: songIndex, action: "dislike")

        removeTopCard()
    }

    @MainActor
    func goBackToMoodInput() {
        state = .moodInput
        cards = []
        moodText = ""
    }

    // MARK: - Private Helpers

    @MainActor
    private func removeTopCard() {
        guard !cards.isEmpty else { return }
        cards.removeFirst()

        if cards.isEmpty {
            state = .empty
        }
    }
}
