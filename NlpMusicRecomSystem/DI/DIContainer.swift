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
    let chatService: any ChatServiceProtocol

    init(
        recommendationService: any RecommendationServiceProtocol,
        favoritesService: any FavoritesServiceProtocol,
        feedbackService: any FeedbackServiceProtocol,
        authService: any AuthServiceProtocol,
        chatService: any ChatServiceProtocol
    ) {
        self.recommendationService = recommendationService
        self.favoritesService = favoritesService
        self.feedbackService = feedbackService
        self.authService = authService
        self.chatService = chatService
    }

    /// Creates a container with all mock services for UI development.
    static func mock() -> DIContainer {
        DIContainer(
            recommendationService: MockRecommendationService(),
            favoritesService: MockFavoritesService(),
            feedbackService: MockFeedbackService(),
            authService: FirebaseAuthService(),
            chatService: MockChatService()
        )
    }

    /// Creates a container with real API-backed services for production.
    /// Authentication tokens are provided by FirebaseAuthService and injected
    /// into the APIClient, which attaches them to every request automatically.
    static func live() -> DIContainer {
        let authService = FirebaseAuthService()

        // Create APIClient with Firebase token provider
        // Every API request will automatically include the Authorization header
        let apiClient = APIClient(authTokenProvider: {
            try await authService.getIDToken()
        })

        return DIContainer(
            recommendationService: APIRecommendationService(apiClient: apiClient),
            favoritesService: APIFavoritesService(apiClient: apiClient),
            feedbackService: APIFeedbackService(apiClient: apiClient),
            authService: authService,
            chatService: APIChatService(apiClient: apiClient)
        )
    }
}

