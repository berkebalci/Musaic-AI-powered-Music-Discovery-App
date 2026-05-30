//
//  DIContainer.swift
//  NlpMusicRecomSystem
//

import Foundation

/// Dependency Injection container that holds all service instances.
/// Services are created once and injected into ViewModels via initializers.
final class DIContainer {
    let recommendationService: any RecommendationServiceProtocol
    let favoritesService: any FavoritesServiceProtocol
    let feedbackService: any FeedbackServiceProtocol
    let authService: any AuthServiceProtocol

    init(
        recommendationService: any RecommendationServiceProtocol,
        favoritesService: any FavoritesServiceProtocol,
        feedbackService: any FeedbackServiceProtocol,
        authService: any AuthServiceProtocol
    ) {
        self.recommendationService = recommendationService
        self.favoritesService = favoritesService
        self.feedbackService = feedbackService
        self.authService = authService
    }

    /// Creates a container with all mock services for UI development.
    static func mock() -> DIContainer {
        DIContainer(
            recommendationService: MockRecommendationService(),
            favoritesService: MockFavoritesService(),
            feedbackService: MockFeedbackService(),
            authService: FirebaseAuthService()
        )
    }

    /// Creates a container with real API-backed services for production.
    static func live() -> DIContainer {
        let apiClient = APIClient()
        let userId = UserDefaults.standard.string(forKey: "user_id") ?? {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "user_id")
            return newId
        }()

        return DIContainer(
            recommendationService: APIRecommendationService(
                apiClient: apiClient,
                userId: userId
            ),
            favoritesService: MockFavoritesService(), // TODO: Replace with API-backed version
            feedbackService: APIFeedbackService(
                apiClient: apiClient,
                userId: userId
            ),
            authService: FirebaseAuthService()
        )
    }
}

