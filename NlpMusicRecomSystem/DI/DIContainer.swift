//
//  DIContainer.swift
//  NlpMusicRecomSystem
//

import Foundation

/// Dependency Injection container that holds all service instances.
/// Services are created once and injected into ViewModels via initializers.
final class DIContainer {
    let nlpService: any NLPServiceProtocol
    let recommendationService: any RecommendationServiceProtocol
    let favoritesService: any FavoritesServiceProtocol
    let feedbackService: any FeedbackServiceProtocol

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

    /// Creates a container with all mock services for UI development.
    static func mock() -> DIContainer {
        let favoritesService = MockFavoritesService()
        return DIContainer(
            nlpService: MockNLPService(),
            recommendationService: MockRecommendationService(),
            favoritesService: favoritesService,
            feedbackService: MockFeedbackService()
        )
    }
}
