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
    @Published private(set) var currentMoodVector: MoodVector?

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

    private let nlpService: any NLPServiceProtocol
    private let recommendationService: any RecommendationServiceProtocol
    private let favoritesService: any FavoritesServiceProtocol
    private let feedbackService: any FeedbackServiceProtocol

    // MARK: - Init

    init(
        nlpService: any NLPServiceProtocol,
        recommendationService: any RecommendationServiceProtocol,
        favoritesService: any FavoritesServiceProtocol,
        feedbackService: any FeedbackServiceProtocol
    ) {
        self.nlpService = nlpService
        self.recommendationService = recommendationService
        self.favoritesService = favoritesService
        self.feedbackService = feedbackService
    }

    // MARK: - User Intents

    func selectPreset(_ preset: String) {
        moodText = preset
    }

    @MainActor
    func analyzeMoodAndFetchSongs() async {
        guard !moodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        state = .loading

        do {
            let moodVector = try await nlpService.analyzeMood(from: moodText)
            currentMoodVector = moodVector

            let songs = try await recommendationService.getRecommendations(for: moodVector)
            cards = songs

            state = songs.isEmpty ? .empty : .swipeCards
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    func swipeRight(on song: Song) async {
        guard let mood = currentMoodVector else { return }

        let interaction = UserInteraction(
            songId: song.id,
            moodVector: mood,
            label: 1
        )

        try? await feedbackService.recordInteraction(interaction)
        try? await favoritesService.addFavorite(song)

        removeTopCard()
    }

    @MainActor
    func swipeLeft(on song: Song) async {
        guard let mood = currentMoodVector else { return }

        let interaction = UserInteraction(
            songId: song.id,
            moodVector: mood,
            label: 0
        )

        try? await feedbackService.recordInteraction(interaction)

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
