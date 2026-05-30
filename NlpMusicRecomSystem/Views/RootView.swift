//
//  RootView.swift
//  NlpMusicRecomSystem
//

import SwiftUI
import Combine

/// The app's root view. Observes Firebase auth state and switches between
/// the unauthenticated flow (LoginView) and the main app (MainTabView).
struct RootView: View {

    let container: DIContainer

    @StateObject private var authViewModel: AuthViewModel
    @State private var currentUser: AuthUser? = nil
    @State private var cancellables: Set<AnyCancellable> = []

    init(container: DIContainer) {
        self.container = container
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: container.authService))
    }

    var body: some View {
        Group {
            if currentUser != nil {
                MainTabView(container: container)
                    .transition(.opacity)
            } else {
                NavigationStack {
                    LoginView(viewModel: authViewModel)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentUser == nil)
        .onAppear {
            // Subscribe to auth state changes and update local @State
            container.authService.currentUserPublisher
                .receive(on: DispatchQueue.main)
                .sink { user in
                    currentUser = user
                }
                .store(in: &cancellables)
        }
    }
}
