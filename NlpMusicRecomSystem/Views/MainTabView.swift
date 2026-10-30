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
    @State private var isChatActive: Bool = false
    @StateObject private var discoveryViewModel: DiscoveryViewModel
    @StateObject private var favoritesViewModel: FavoritesViewModel
    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel
    @StateObject private var chatViewModel: ChatViewModel

    // MARK: - Init

    init(container: DIContainer) {
        self.container = container
        let player = AudioPlayerViewModel()
            _audioPlayerViewModel = StateObject(wrappedValue: player)
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(
            chatService: container.chatService,
            recommendationService: container.recommendationService
        ))
        
        // Favorites cache is shared by the Library and Profile tabs.
        // Discovery tells it to refetch only after liked songs were actually synced to the server.
        let favoritesVM = FavoritesViewModel(
            favoritesService: container.favoritesService,
            appleMusicService: AppleMusicService()
        )
        _favoritesViewModel = StateObject(wrappedValue: favoritesVM)
        
        _discoveryViewModel = StateObject(wrappedValue: DiscoveryViewModel(
            recommendationService: container.recommendationService,
            feedbackService: container.feedbackService,
            audioPlayer: player,
            onLikedSongsSynced: { [weak favoritesVM] in
                favoritesVM?.markStale()
            }
        ))
        
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .home:
                    LandingHomeView(
                        selectedTab: $selectedTab,
                        recommendationService: container.recommendationService,
                        audioPlayer: audioPlayerViewModel
                    )
                case .chat:
                    HomeView(
                        chatViewModel: chatViewModel,
                        audioPlayer: audioPlayerViewModel,
                        isChatActive: $isChatActive
                    )
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
                    ProfileView(
                        authService: container.authService,
                        favoritesViewModel: favoritesViewModel,
                        audioPlayer: audioPlayerViewModel
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar — hidden when chat is active
            if !isChatActive {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isChatActive)
        .ignoresSafeArea(.keyboard)
    }
}
