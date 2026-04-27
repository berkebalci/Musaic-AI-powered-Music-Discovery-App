//
//  MainTabView.swift
//  NlpMusicRecomSystem
//

import SwiftUI

struct MainTabView: View {

    // MARK: - State

    @State private var selectedTab: AppTab = .discovery
    @StateObject private var discoveryViewModel: DiscoveryViewModel
    @StateObject private var favoritesViewModel: FavoritesViewModel
    @StateObject private var audioPlayerViewModel: AudioPlayerViewModel

    // MARK: - Init

    init(container: DIContainer) {
        _discoveryViewModel = StateObject(wrappedValue: DiscoveryViewModel(
            nlpService: container.nlpService,
            recommendationService: container.recommendationService,
            favoritesService: container.favoritesService,
            feedbackService: container.feedbackService
        ))
        _favoritesViewModel = StateObject(wrappedValue: FavoritesViewModel(
            favoritesService: container.favoritesService
        ))
        _audioPlayerViewModel = StateObject(wrappedValue: AudioPlayerViewModel())
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
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
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}
