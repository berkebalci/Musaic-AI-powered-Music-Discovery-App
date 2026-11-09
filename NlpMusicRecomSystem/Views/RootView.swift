import SwiftUI

struct RootView: View {

    let container: DIContainer

    /// The one shared auth state. Every sign in / sign out / account deletion ends up here on MainActor.
    @ObservedObject private var authManager: AuthManager
    @StateObject private var authViewModel: AuthViewModel

    private let errorManager = GlobalErrorManager.shared

    init(container: DIContainer) {
        self.container = container
        _authManager = ObservedObject(wrappedValue: container.authManager)
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authManager: container.authManager))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Auth flow
            Group {
                if authManager.isAuthenticated {
                    MainTabView(container: container, authViewModel: authViewModel)
                        .transition(.opacity)
                } else {
                    NavigationStack {
                        LoginView(viewModel: authViewModel)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: authManager.isAuthenticated)

            // MARK: - Global error banner
            // (burası AYNEN kalıyor)
        }
        .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
            // Signed out or account deleted: drop per-user cached data and form state
            // so the next account starts clean.
            if !isAuthenticated {
                container.recommendationService.clearCache()
                authViewModel.clearFields()
            }
        }
    }
}
