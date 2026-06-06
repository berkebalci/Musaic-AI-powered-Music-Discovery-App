//
//  MainTabView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct MainTabView: View {

    // MARK: - Dependencies

    private let container: DIContainer

    // MARK: - State

    @State private var selectedTab: AppTab = .home
    @StateObject private var discoveryViewModel: DiscoveryViewModel
    @StateObject private var favoritesViewModel: FavoritesViewModel
    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel
    @StateObject private var chatViewModel: ChatViewModel

    // MARK: - Init

    init(container: DIContainer) {
        self.container = container
        _discoveryViewModel = StateObject(wrappedValue: DiscoveryViewModel(
            recommendationService: container.recommendationService,
            feedbackService: container.feedbackService
        ))
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(
            favoritesService: container.favoritesService
        ))
        _audioPlayerViewModel = StateObject(wrappedValue: AudioPlayerViewModel())
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(
            chatService: container.chatService,
            recommendationService: container.recommendationService
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .home:
                    HomeView(chatViewModel: chatViewModel)
                case .discovery:
                    DiscoveryContainerView(
                        viewModel: discoveryViewModel,
                        audioPlayer: audioPlayerViewModel
                    )
                case .yourMusic:
                    FavoritesView(
                        viewModel: favoritesViewModel,
                        audioPlayer: audioPlayerViewModel
                    )
                case .profile:
                    ProfileView(authService: container.authService)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

