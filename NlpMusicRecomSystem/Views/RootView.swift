//
//  RootView.swift
//  NlpMusicRecomSystem
//

import SwiftUI
import Combine

/// The app's root view. Observes Firebase auth state and switches between
/// the unauthenticated flow (LoginView) and the main app (MainTabView).
/// Also hosts the global error banner overlay (Lottie-ready).
struct RootView: View {

    let container: DIContainer

    @StateObject private var authViewModel: AuthViewModel
    @State private var currentUser: AuthUser? = nil
    @State private var cancellables: Set<AnyCancellable> = []

    // @Observable singleton — direkt referans yeterli, @State gerekmez
    private let errorManager = GlobalErrorManager.shared

    init(container: DIContainer) {
        self.container = container
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: container.authService))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Auth flow
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

            // MARK: - Global error banner
            // Lottie için: Image(systemName:) yerine LottieView() koy, yapı hazır.
            if errorManager.showError, let error = errorManager.error {
                HStack(spacing: 12) {
                    // --- Lottie placeholder ---
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .font(.title3)
                    // --------------------------

                    Text(error.errorDescription ?? "Hata oluştu")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(2)

                    Spacer()

                    Button {
                        errorManager.clear()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
                .background(Color.black.opacity(0.85))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .shadow(radius: 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(999)
            }
        }
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
